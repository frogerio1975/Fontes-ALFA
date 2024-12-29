#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM02
Realiza registro do boleto via API com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM02(cMsgErro)

Local _aArea        := GetArea()
Local _cJSon        := ""
Local _cJSonRet     := ""
Local _cCodBar      := ""
Local _cLinhaD      := ""
Local _cNossoNum    := ""
Local _cIDBol       := ""
Local lRetorno      := .T.
Local cStatus       := ""

Default cMsgErro    := ""

//------------------+
// Cria JSon Boleto |
//------------------+
_cJSon      := ""
_cJSonRet   := ""
_cCodBar    := ""
_cLinhaD    := ""
_cFilial    := XTM->XTM_FILIAL
_cTitulo    := XTM->XTM_NUMTIT
_cPrefixo   := XTM->XTM_PREFIX
_cParcela   := XTM->XTM_PARCEL
_cTipo      := XTM->XTM_TIPO
_cCliente   := XTM->XTM_CLIENT
_cLoja      := XTM->XTM_LOJA
_cEmpFat    := XTM->XTM_EMPFAT

lRetorno := GeraJSON(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cCliente, _cLoja, @_cNossoNum, @_cIdBol, @_cJSon, @cMsgErro)

If lRetorno
    lRetorno := EnviaJSON(_cEmpFat, _cJSon, @_cJSonRet, @_cCodBar, @_cLinhaD, @cMsgErro)
EndIf

If lRetorno
    DbSelectArea("SE1")
    DbSetOrder(2) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
    If DbSeek(_cFilial + _cCliente + _cLoja + _cPrefixo + _cTitulo + _cParcela + _cTipo)
        RecLock("SE1",.F.)
            REPLACE E1_NUMBCO  WITH _cNossoNum
            REPLACE E1_CODBAR  WITH _cCodBar
            REPLACE E1_CODDIG  WITH _cLinhaD
            REPLACE E1_XIDBOL  WITH _cIdBol
            REPLACE E1_XBOLETO WITH "1" // 1=Emitido
        MsUnlock()
    EndIf
EndIf

cStatus := IIF(lRetorno,"2","3") // 1=Pendente, 2=Processado, 3=Erro

// Registra Retorno do Processamento
RecLock("XTM",.F.)
    REPLACE XTM_STATUS  WITH cStatus
    REPLACE XTM_DTPROC  WITH DATE()
    REPLACE XTM_HRPROC  WITH TIME()
    REPLACE XTM_REQUES  WITH _cJSon
    REPLACE XTM_RESPON  WITH _cJSonRet
    REPLACE XTM_MSGERR  WITH cMsgErro
MsUnlock()

RestArea(_aArea)

Return lRetorno  

/**********************************************************************************/
/*/{Protheus.doc} GeraJSON
    @description Cria JSON para envio ao banco
    @type  Static Function
    @author Bernard M Margarido
    @since 01/07/2022
    @version version
/*/
/**********************************************************************************/
Static Function GeraJSON(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cCliente, _cLoja, _cNossoNum, _cIdBol, _cJSon, cMsgErro)

Local _aArea        := GetArea()
Local lRetorno      := .T.
Local _cBanco       := ""
Local _cAgencia     := ""
Local _cConta       := ""
Local _cSubCta      := ""
Local _cRecSEE      := 0
Local cFilBkp       := cFilAnt
Local _cTpBenef     := ""
Local _cCgcBenef    := ""
Local _cRazaoBenef  := ""
Local _cEndBenef    := ""
Local _cBairBenef   := ""
Local _cMunBenef    := ""
Local _cEstBenef    := ""
Local _cCEPBenef    := ""
Local _cTpCli       := ""
Local _cCgc         := ""
Local _cRazao       := ""
Local _cEnd         := ""
Local _cBairro      := ""
Local _cMunicipio   := ""
Local _cEstado      := ""
Local _cCEP         := ""
Local _cIDBenef     := ""
// Local _cIDCnab      := ""
// Local _cJuros       := ""
Local _cMensBol1    := ""
Local _cMensBol2    := ""
Local _cMensBol3    := ""
Local _cMensBol4    := ""

Local _nValorBol    := 0
Local _nAbatimento  := 0
Local _nPJuros      := GetMv("SY_PJURBOL",,1) // Percentual de Juros as ao Mês
Local _nPMulta      := GetMv("SY_PMULBOL",,2) // Percentual de Multa por atraso
// Local _nDCart       := GetMv("SY_DIACART",,10)
Local lHmlBol       := .F. //GetNewPar("SY_HMLBOL",.F.) // Habilita envio de boleto em homologação 

Local _oJSon        := Nil
Local _oBoleto      := Nil 
Local _oPagador     := Nil 
// Local _oSacador     := Nil 
Local _oDadosBol    := Nil 
Local _oMensagem    := Nil 
Local _oJuros       := Nil 
// Local _oProtesto    := Nil
Local _oBenef       := Nil 

cFilAnt := _cFilial

//------------------------+
// SE1 - Posiciona Titulo |
//------------------------+
dbSelectArea("SE1")
SE1->( dbSetOrder(2) )
If lRetorno .And. !SE1->( dbSeek(xFilial("SE1") + _cCliente + _cLoja + _cPrefixo + _cTitulo + _cParcela + _cTipo))
    cMsgErro := "Título não localizado."
    lRetorno := .F.
EndIf

If lRetorno .And. !U_ALFINM07(SE1->E1_EMPFAT, @_cBanco, @_cAgencia, @_cConta, @_cSubCta, @_cRecSEE)
    cMsgErro := "Cadastro de Banco não localizado. Banco: " + _cBanco + " Agência: " + _cAgencia + " Conta: " + _cConta
    lRetorno := .F.
EndIf

//----------------------------+
// SEE - Parametros Bancarios |
//----------------------------+
If lRetorno 
    dbSelectArea("SEE")
    SEE->( dbSetOrder(1) )
    SEE->( dbGoTo(_cRecSEE) )
EndIf

//-----------------------+
// SA6 - Posiciona Banco | 
//-----------------------+
dbSelectArea("SA6")
SA6->( dbSetOrder(1) )
If lRetorno .And. !SA6->( dbSeek(xFilial("SA6") + _cBanco + _cAgencia + _cConta))
    cMsgErro := "Cadastro de Banco não localizado. Banco: " + _cBanco + " Agência: " + _cAgencia + " Conta: " + _cConta
    lRetorno := .F.
EndIf

//-------------------------+
// SA1 - Posiciona cliente |
//-------------------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
If lRetorno .And. !SA1->( dbSeek(xFilial("SA1") + _cCliente + _cLoja) )
    cMsgErro := "Código de cliente não localizado: " + _cCliente + "/" + _cLoja
    lRetorno := .F.
EndIf 

If lRetorno
    //----------------------+
    // Dados beneficionario |
    //----------------------+
    _cTpBenef   := "J"
    _cCgcBenef  := RTrim(SEE->EE_XEMPCGC)
    _cRazaoBenef:= RTrim(SEE->EE_XNOMCOM)
    _cEndBenef  := RTrim(SEE->EE_XENDCOB)
    _cBairBenef := RTrim(SEE->EE_XBAICOB)
    _cMunBenef  := RTrim(SEE->EE_XCIDCOB)
    _cEstBenef  := SEE->EE_XESTCOB
    _cCEPBenef  := SEE->EE_XCEPCOB

    _cDVCont    := Alltrim(SEE->EE_DVCTA)

    //------------------+
    // Dados do cliente |
    //------------------+
    _cTpCli     := IIF(SA1->A1_PESSOA == "F","F","J")
    _cCgc       := RTrim(SA1->A1_CGC )
    _cRazao     := RTrim(SA1->A1_NOME)
    _cEnd       := IIF(Empty(SA1->A1_ENDCOB), RTrim(SA1->A1_END), RTrim(SA1->A1_ENDCOB))
    _cBairro    := IIF(Empty(SA1->A1_ENDCOB), RTrim(SA1->A1_BAIRRO), RTrim(SA1->A1_BAIRROC))
    _cMunicipio := IIF(Empty(SA1->A1_ENDCOB), RTrim(SA1->A1_MUN), RTrim(SA1->A1_MUNC))
    _cEstado    := IIF(Empty(SA1->A1_ENDCOB), SA1->A1_EST, SA1->A1_ESTC)
    _cCEP       := IIF(Empty(SA1->A1_ENDCOB), SA1->A1_CEP, SA1->A1_CEPC)
    _cCarteira  := Alltrim(SEE->EE_CODCART)

    // SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",,@_nAbatimento)
    // _nValorBol  := SE1->E1_SALDO
    // _nValorBol  += SE1->E1_ACRESC
    // _nValorTot  := _nValorBol - _nAbatimento

    _nValorBol  := SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

    _cNossoNum  := RetNossoNum(_cBanco, _cAgencia, _cConta, _cSubCta)
    _cIDBenef   := StrZero(Val(_cAgencia), 4) + StrZero(Val(_cConta), 7) + _cDVCont
    // _cIDCnab    := IIF(Empty(SE1->E1_IDCNAB), getIDCNAB() , RTrim(SE1->E1_IDCNAB))

    // _cJuros     :=  AllTrim(TransForm( Round(( (_nValorTot * ( _nPJuros / 100) ) / 30), 2 ), "@E 999,999,999.99") )
    // _cMensBol1  := "Juros valor por dia de atraso R$ " + _cJuros + " A partir de: " + dToC(DataValida(DaySum(SE1->E1_VENCREA,1),.T.))
    // _cMensBol2  := "Ultimo dia para pagamento " + dToC(DataValida(DaySum(SE1->E1_VENCREA,(_nDCart - 1)),.T.))
    // _cMensBol3  := "Protesto a partir do dia " + dToC(DataValida(DaySum(SE1->E1_VENCREA,_nDCart),.T.))
    // _cMensBol4  := "Eventuais necessidades consultar setor financeiro."

    _cIdBol := StrZero(Val(_cAgencia), 4)
    _cIdBol += StrZero(Val(_cConta), 7) 
    _cIdBol += _cDVCont
    _cIdBol += _cCarteira 
    _cIdBol += _cNossoNum
EndIf

If lRetorno
    // Calcula código de barras e linha digitavel do Itau
    CB_RN_NN	:= Ret_cBarI(_cBanco, StrZero(Val(_cAgencia), 4), StrZero(Val(_cConta), 7), _cDVCont, _cNossoNum, _nValorBol, SE1->E1_VENCREA, _cCarteira)
EndIf

If lRetorno
    _oJSon                                                                              := JsonObject():New() 
    _oJSon["data"]                                                                      := JsonObject():New() 

    _oData                                                                              := _oJSon["data"]
    _oData["etapa_processo_boleto"]                                                     := If(lHmlBol,"validacao","efetivacao")
    _oData["codigo_canal_operacao"]                                                     := "API"
    _oData["beneficiario"]                                                              := JsonObject():New() 

    _oBenef                                                                             := _oData["beneficiario"]
    _oBenef["id_beneficiario"]                                                          := _cIDBenef
    _oBenef["nome_cobranca"]                                                            := _cRazaoBenef
    _oBenef["tipo_pessoa"]                                                              := JsonObject():New() 
    _oBenef["tipo_pessoa"]["codigo_tipo_pessoa"]                                        := _cTpBenef
    _oBenef["tipo_pessoa"]["numero_cadastro_nacional_pessoa_juridica"]                  := _cCgcBenef
    _oBenef["endereco"]                                                                 := JsonObject():New()
    _oBenef["endereco"]["nome_logradouro"]                                              := _cEndBenef
    _oBenef["endereco"]["nome_bairro"]                                                  := _cBairBenef
    _oBenef["endereco"]["nome_cidade"]                                                  := _cMunBenef
    _oBenef["endereco"]["sigla_UF"]                                                     := _cEstBenef
    _oBenef["endereco"]["numero_CEP"]                                                   := _cCEPBenef

    _oData["dado_boleto"]                                                               := JsonObject():New()

    _oBoleto                                                                            := _oData["dado_boleto"]
    _oBoleto["descricao_instrumento_cobranca"]                                          := "boleto"
    _oBoleto["tipo_boleto"]                                                             := "a vista" //If(SE1->E1_VENCREA == SE1->E1_EMISSAO, "a vista", "proposta")
    _oBoleto["codigo_carteira"]                                                         := _cCarteira
    _oBoleto["codigo_especie"]                                                          := "01"
    _oBoleto["codigo_aceite"]                                                           := "S"
    _oBoleto["valor_total_titulo"]                                                      := StrZero( _nValorBol * 100, 17 )
    _oBoleto["desconto_expresso"]                                                       := .F.

    // If _nAbatimento > 0 .And. _nAbatimento < _nValorBol
    //     _oBoleto["valor_abatimento"]                                                    := StrZero( _nAbatimento * 100, 17 )
    // EndIf 

    _oBoleto["data_emissao"]                                                            := SubStr(FwTimeStamp(3,SE1->E1_EMISSAO),1,10)

    _oBoleto["pagador"]                                                                 := JsonObject():New() 
    _oPagador                                                                           := _oBoleto["pagador"]
    _oPagador["pessoa"]                                                                 := JsonObject():New() 
    _oPagador["pessoa"]["nome_pessoa"]                                                  := _cRazao
    _oPagador["pessoa"]["tipo_pessoa"]                                                  := JsonObject():New() 
    _oPagador["pessoa"]["tipo_pessoa"]["codigo_tipo_pessoa"]                            := _cTpCli
    _oPagador["endereco"]                                                               := JsonObject():New() 
    _oPagador["endereco"]["nome_logradouro"]                                            := _cEnd
    _oPagador["endereco"]["nome_bairro"]                                                := SubStr(_cBairro,1,12)
    _oPagador["endereco"]["nome_cidade"]                                                := _cMunicipio
    _oPagador["endereco"]["sigla_UF"]                                                   := _cEstado
    _oPagador["endereco"]["numero_CEP"]                                                 := _cCEP

    If _cTpCli == "J"
        _oPagador["pessoa"]["nome_fantasia"]                                            := _cRazao 
        _oPagador["pessoa"]["tipo_pessoa"]["numero_cadastro_nacional_pessoa_juridica"]  := _cCgc
    ElseIf _cTpCli == "F"
        _oPagador["pessoa"]["tipo_pessoa"]["numero_cadastro_pessoa_fisica"]             := _cCgc
    EndIf 

    // _oBoleto["sacador_avalista"]                                                        := JsonObject():New()

    // _oSacador                                                                           := _oBoleto["sacador_avalista"]
    // _oSacador["pessoa"]                                                                 := JsonObject():New() 
    // _oSacador["pessoa"]["nome_pessoa"]                                                  := _cRazao 
    // _oSacador["pessoa"]["tipo_pessoa"]                                                  := JsonObject():New()
    // _oSacador["pessoa"]["tipo_pessoa"]["codigo_tipo_pessoa"]                            := _cTpCli

    // If _cTpCli == "J"
    //     _oSacador["pessoa"]["tipo_pessoa"]["numero_cadastro_nacional_pessoa_juridica"]  := _cCgc
    // ElseIf _cTpCli == "F"
    //     _oSacador["pessoa"]["tipo_pessoa"]["numero_cadastro_pessoa_fisica"]             := _cCgc
    // EndIf 

    // _oSacador["endereco"]                                                               := JsonObject():New()
    // _oSacador["endereco"]["nome_logradouro"]                                            := _cEnd
    // _oSacador["endereco"]["nome_bairro"]                                                := SubStr(_cBairro,1,12)
    // _oSacador["endereco"]["nome_cidade"]                                                := _cMunicipio
    // _oSacador["endereco"]["sigla_UF"]                                                   := _cEstado
    // _oSacador["endereco"]["numero_CEP"]                                                 := _cCEP

    _oBoleto["dados_individuais_boleto"]                                                := {JsonObject():New()}

    _oDadosBol                                                                          := _oBoleto["dados_individuais_boleto"][1]
    _oDadosBol["numero_nosso_numero"]                                                   := _cNossoNum
    _oDadosBol["dac_titulo"]                                                            := CB_RN_NN[4]
    _oDadosBol["id_boleto_individual"]                                                  := FWUUID(_cNossoNum)
    _oDadosBol["codigo_barras"]                                                         := CB_RN_NN[1]
    _oDadosBol["numero_linha_digitavel"]                                                := CB_RN_NN[2]
    _oDadosBol["data_vencimento"]                                                       := SubStr(FwTimeStamp(3,SE1->E1_VENCREA),1,10)
    _oDadosBol["valor_titulo"]                                                          := StrZero( _nValorBol * 100, 17 )
    _oDadosBol["texto_uso_beneficiario"]                                                := ""  
    _oDadosBol["texto_seu_numero"]                                                      := AllTrim(SE1->E1_XNUMNFS)  
    _oDadosBol["mensagens_cobranca"]                                                    := {}

    If !Empty(_cMensBol1)
        _oMensagem                                                                      := JsonObject():New()
        _oMensagem["mensagem"]                                                          := _cMensBol1
        aAdd(_oDadosBol["mensagens_cobranca"],_oMensagem)
    EndIf 

    If !Empty(_cMensBol2)
        _oMensagem                                                                      := JsonObject():New()
        _oMensagem["mensagem"]                                                          := _cMensBol2
        aAdd(_oDadosBol["mensagens_cobranca"],_oMensagem)
    EndIf 

    If !Empty(_cMensBol3)
        _oMensagem                                                                      := JsonObject():New()
        _oMensagem["mensagem"]                                                          := _cMensBol3
        aAdd(_oDadosBol["mensagens_cobranca"],_oMensagem)
    EndIf 

    If !Empty(_cMensBol4)
        _oMensagem                                                                      := JsonObject():New()
        _oMensagem["mensagem"]                                                          := _cMensBol4
        aAdd(_oDadosBol["mensagens_cobranca"],_oMensagem)
    EndIf 

    // _oBoleto["protesto"]                                                                := JsonObject():New() 
    // _oProtesto                                                                          := _oBoleto["protesto"]
    // _oProtesto["codigo_tipo_protesto"]                                                  := 1
    // _oProtesto["quantidade_dias_protesto"]                                              := 10
    // _oProtesto["protesto_falimentar"]                                                   := .F.

    _oBoleto["juros"]                                                                   := JsonObject():New() 
    _oJuros                                                                             := _oBoleto["juros"]    
    _oJuros["codigo_tipo_juros"]                                                        := "90" // Percentual mensal 
    _oJuros["percentual_juros"]                                                         := StrZero(_nPJuros * 100000,12)

    _oBoleto["multa"]                                                                   := JsonObject():New() 
    _oMulta                                                                             := _oBoleto["multa"]    
    _oMulta["codigo_tipo_multa"]                                                        := "02" // Cobrança de Percentual de Multa por Atraso
    _oMulta["percentual_multa"]                                                         := StrZero(_nPMulta * 100000,12)

    _cJSon := _oJSon:toJSON()
EndIf

cFilAnt := cFilBkp

RestArea(_aArea)

Return lRetorno

/*********************************************************************************/
/*/{Protheus.doc} EnviaJSON
    @description Realiza o envio do boleto
    @type  Static Function
    @author Bernard M. Margarido
    @since 13/07/2022
    @version version
/*/
/*********************************************************************************/
Static Function EnviaJSON(_cEmpFat, _cJSon, _cJSonRet, _cCodBar, _cLinhaD, cMsgErro)

Local lRetorno  := .T.
Local _oBoleto  := ITAU():New()
Local _oJSon    := JsonObject():New()
Local _oDadBol  := Nil

_oBoleto:cEmpFat := _cEmpFat
_oBoleto:SetEmpresa()

_oBoleto:cJSon  := _cJSon
If _oBoleto:Boleto()
    _cJSonRet := _oBoleto:cJSonRet
    _oJSon:fromJson(_cJSonRet)
    
    If ValType(_oJSon["codigo"]) == "C"
        cMsgErro := _oJSon["codigo"] + " - " + _oJSon["mensagem"]
        lRetorno  := .F.
    ElseIf ValType(_oJSon["codigo_erro"]) == "C"
        cMsgErro := _oJSon["codigo_erro"] + " - " + _oJSon["mensagem_erro"]
        lRetorno  := .F.        
    Else
        _oDadBol := _oJSon["data"]["dado_boleto"]["dados_individuais_boleto"]
        
        If ValType(_oDadBol) == "A"
            _oDadBol := _oDadBol[1]
        EndIf 
        
        _cCodBar := _oDadBol["codigo_barras"]
        _cLinhaD := _oDadBol["numero_linha_digitavel"]
    EndIf
Else 
    _cJSonRet := _oBoleto:cError
    cMsgErro  := "Erro na API."
    lRetorno  := .F.
EndIf 

Return lRetorno

/*********************************************************************************/
/*/{Protheus.doc} Ret_cBarI
    @description Gerar código de barras para boleto Itau 
    @type  Static Function
    @author Wilson A. Silva Jr
    @since 02/09/2022
    @version version
/*/
/*********************************************************************************/
Static Function Ret_cBarI(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira)

LOCAL BlDocNuFinal := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
LOCAL blvalorfinal := Strzero((nValor)*100,10)
LOCAL dvCod        := 0
LOCAL cMoeda       := "9"
Local cFator       := Strzero(dVencto - ctod("07/10/1997"),4)

cCarteira := alltrim(cCarteira)

//Montagem DAC do NOSSO NUMERO
snn   := BlDocNuFinal  // Nosso Numero
dvCod := Alltrim(Str(modulo10(snn)))  //Digito verificador no Nosso Numero
cNN   := Strzero(val(cNroDoc),8) + dvCod

//MONTAGEM DA LINHA DIGITAVEL
// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 1
campo1  := cBanco + cMoeda + cCarteira + substr(cNN,1,2)
dvC1    := Alltrim(Str(modulo10(campo1)))
cCampo1 := campo1 + dvC1

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 2
campo2  := substr(cNN,3,6) + dvCod + substr(cAgencia,1,3)
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2 

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 3
campo3  := substr(cAgencia,4,1) + cConta + cDacCC + "000"
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 //+ substr(cAgencia,4,1)

// Montagem das DACs do Codigo de Barras
//campo 4

//campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNroDoc+dvCod + cAgencia + cConta + cDacCC + "000"
campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNN + cAgencia + cConta + cDacCC + "000"
cDacCB  := Alltrim(Str(Modulo11(campo4,.T.)))
cCampo4 := cDacCB

// Montagem
//campo 5
cCampo5  := cFator + blvalorfinal
////////////////////////////////////////////////////////////////////////////

cCB      := cBanco + cMoeda + cDacCB + cFator + blvalorfinal + cCarteira + cNN + cAgencia + cConta + cDacCC + "000" // codigo de barras

////////////////////////////////////////////////////////////////////////////
//MONTAGEM DA LINHA DIGITAVEL

cRN := substr(cCampo1,1,5)+"."+substr(cCampo1,6,5)+space(2)+ substr(cCampo2,1,5)+"."+substr(cCampo2,6,6)+space(2)+ substr(cCampo3,1,5)+"."+substr(cCampo3,6,6)+space(2) + cCampo4 + space(2)+ cCampo5

Return({cCB,cRN,cNN,dvCod})

/*********************************************************************************/
/*/{Protheus.doc} Modulo10
    @description Modulo10
    @type  Static Function
    @author Wilson A. Silva Jr
    @since 02/09/2022
    @version version
/*/
/*********************************************************************************/
Static Function Modulo10(cData)

LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF

Return (D)

/*********************************************************************************/
/*/{Protheus.doc} Modulo11
    @description Modulo11
    @type  Static Function
    @author Wilson A. Silva Jr
    @since 02/09/2022
    @version version
/*/
/*********************************************************************************/
Static Function Modulo11(cData, lCodBarra)

LOCAL L, D, P := 0
Default lCodBarra := .F.

L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

//Tratamento para digito verificador.
If lCodBarra //Codigo de Barras
	//Se o resto for 0,1 ou 10 o digito é 1
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		D := 1
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
Else //Nosso Numero
	IF (D == 0 .Or. D == 1 .Or. D == 10)
		//Se o resto for 0 ou 1 o digito é 0
		IF (D == 0 .Or. D == 1)
			D := 0

		//Se o resto for 10 o digito é 1
		ELSEIF (D == 10)
			D := 1
		ENDIF
	ELSE
		D := 11 - (mod(D,11))	
	ENDIF 
EndIf	

Return (D)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetNossoNum
Retorna nosso numero para o banco informado.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetNossoNum(_cBanco, _cAgencia, _cConta, _cSubCta)

Local _aArea    := GetArea()
Local _cNumBco  := ""
Local _nTam     := 8

DbSelectArea("SEE")
DbSetOrder(1)
If DbSeek(xFilial("SEE") + _cBanco + _cAgencia + _cConta + _cSubCta)
    If Empty(SEE->EE_FAXATU)
        _cNumBco := StrZero(Val(SEE->EE_FAXINI),_nTam)
    Else 
        _cNumBco := StrZero(Val(SEE->EE_FAXATU),_nTam)
    EndIf 

    //--------------------------------+
    // Atualiza faixa do nosso numero |
    //--------------------------------+
    RecLock("SEE",.F.)
        REPLACE EE_FAXATU WITH SOMA1(_cNumBco)
    MsUnlock()
EndIf

RestArea(_aArea)

Return _cNumBco
