#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE	 TAM_A4 9			//A4     	210mm x 297mm  620 x 876

/***************************************************************************************/
/*/{Protheus.doc} ALFINR01
    @description Impressão de boletos Itau
    @type  Function
    @author Wilson A. Silva Jr
    @since 29/09/2022
/*/
/***************************************************************************************/
User Function ALFINR01(oPrintExt, cMsgErro)

Local _aArea            := GetArea()
Local lRetorno          := .T.
Local _cDirClient		:= ""
Local _cFile			:= "" 
Local _cDirExp			:= "" 
Local _lAdjustToLegacy	:= .F.
Local _lDisableSetup	:= .T.
Local _oPrint           := Nil
Local lRelAuto          := oPrintExt <> Nil

DEFAULT cMsgErro := ""

If oPrintExt <> NIL
    _oPrint := oPrintExt
Else
    _cDirClient		:= GetTempPath()
    _cFile			:= SE1->E1_CLIENTE +'-'+ Alltrim(SE1->E1_XNUMNFS) + '-' + StrZero(Day(dDataBase),2) + StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4) + '.PDF'
    _cDirExp		:= "\spool\" 

    _oPrint :=	FWMSPrinter():New(_cFile, IMP_PDF, _lAdjustToLegacy,_cDirExp, _lDisableSetup, , , , .T., , .F., )      
    _oPrint:cPathPdf := _cDirClient
    _oPrint:setResolution(78)
    _oPrint:SetPortrait()
    _oPrint:setPaperSize(TAM_A4)
    _oPrint:SetMargin(60,60,60,60)
EndIf

If lRelAuto
    lRetorno := ALFINR01A(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_EMPFAT, @_oPrint, @cMsgErro)
Else
    FwMsgRun(,{|| lRetorno := ALFINR01A(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_EMPFAT, @_oPrint, @cMsgErro)},"Aguarde...","Imprimindo boleto ITAU")
EndIf

//---------------------+
// Visualiza impressão |
//---------------------+
If !lRelAuto
    _oPrint:Preview()
EndIf

RestArea(_aArea)

Return lRetorno

/***************************************************************************************/
/*/{Protheus.doc} ALFINR01A
    @description Realiza a impressão do boleto banário 
    @type  Static Function
    @author Wilson A. Silva Jr
    @since 27/08/2021
/*/
/***************************************************************************************/
Static Function ALFINR01A(_cTitulo, _cPrefixo, _cParcela, _cTipo, _cEmpFat, _oPrint, cMsgErro)
Local _cBitMapBanco	    := GetSrvProfString("Startpath","")+"\logo-"+_cEmpFat+".jpeg"
Local _cNomeBenef       := ""
Local _cCnpjBenef       := ""
Local _cEndBenef        := ""
Local _cBairBenf        := ""
Local _cMuniBenf        := ""
Local _cUFBenef         := ""
Local _cCepBenef        := ""
Local _cCarteira		:= ""
Local _cFatorVcto		:= ""
Local _cNossoNum        := ""
Local _cDigitao	        := ""
Local _cDadosCta	    := ""
Local _cCodBar	        := ""
Local _cLinhaDigit	    := ""
Local _cNumBanco		:= ""
Local _cNumConta		:= ""
Local _cDigConta		:= ""
Local _cDtVencto		:= Ctod("")
Local _cNumTit			:= ""
Local _cBanco           := ""
Local _cAgencia         := ""
Local _cConta           := ""
Local _cSubCta          := ""
Local _cRecSEE          := 0
Local _cNumDoc          := ""

Local _nValorTit		:= 0
Local _nDesconto		:= 0
Local _nX               := 0

Local _oFont6  		    := TFont():New("Arial", 9, 06, .T., .F., 5, .T., 5, .T., .F.)
Local _oFont8  		    := TFont():New("Arial", 9, 08, .T., .F., 5, .T., 5, .T., .F.)
Local _oFont8B  		:= TFont():New("Arial", 9, 08, .T., .T., 5, .T., 5, .T., .F.)
Local _oFont10 		    := TFont():New("Arial", 9, 10, .T., .T., 5, .T., 5, .T., .F.)
Local _oFont11 		    := TFont():New("Arial", 9, 11, .T., .T., 5, .T., 5, .T., .F.)
Local _oFont14N		    := TFont():New("Arial", 9, 14, .T., .F., 5, .T., 5, .T., .F.)
Local _oFont22 		    := TFont():New("Arial", 9, 22, .T., .T., 5, .T., 5, .T., .F.)
Local _oDataBol         := JsonObject():New()

Local _cJSonRet         := ""

DEFAULT cMsgErro := ""

//--------------------------------+
// SE1 - Titulos Contas a Receber |
//--------------------------------+
dbSelectArea("SE1")
SE1->( dbSetOrder(1) )
If !SE1->( dbSeek(xFilial("SE1") + _cPrefixo + _cTitulo + _cParcela + _cTipo) )
    cMsgErro := "Titulo não encontrado"
    Return .F.
EndIf

//----------------+
// SA1 - Clientes |
//----------------+
dbSelectArea("SA1")
SA1->( dbSetOrder(1) )
SA1->( dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA) )

If !U_ALFINM07(SE1->E1_EMPFAT, @_cBanco, @_cAgencia, @_cConta, @_cSubCta, @_cRecSEE)
    cMsgErro := "Parâmetros de banco (SEE) não encontrados"
    Return .F.
EndIf

//----------------------------+
// SEE - Parametros Bancarios |
//----------------------------+
dbSelectArea("SEE")
SEE->( dbSetOrder(1) )
SEE->( dbGoTo(_cRecSEE) )

//-------------+
// SA6 - Banco | 
//-------------+
// dbSelectArea("SA6")
// SA6->( dbSetOrder(1) )
// If !SA6->( dbSeek(xFilial("SA6") + _cBanco + _cAgencia + _cConta) )
//     Return .F.
// EndIf


If !RetBoleto(_cTitulo, _cPrefixo, _cParcela, _cTipo, _cEmpFat, @_cJSonRet, @cMsgErro)
    Help("BSFINA10",1,"HELP","",cMsgErro,1,0)
    Return .F.
EndIf

If Empty(_cJSonRet)
    cMsgErro := "Boleto ainda não disponivel para impressão, tente novamente mais tarde."
    Help("BSFINA10",1,"HELP","",cMsgErro,1,0)
    Return .F.
EndIf

//-----------------+
// JSON de Retorno |
//-----------------+
// _oDataBol:fromJson(RTrim(XTH->XTH_JSONR))
_oDataBol:fromJson(RTrim(_cJSonRet)) 

If _oDataBol["data"] == Nil .OR. Len(_oDataBol["data"]) == 0
    cMsgErro := "Boleto ainda não disponivel para impressão, tente novamente mais tarde."
    Help("BSFINA10",1,"HELP","",cMsgErro,1,0)
    Return .F.
EndIf

_oBoleto := _oDataBol["data"][1]

//-----------------------+
// Preenche as variaveis |
//-----------------------+
_cNomeBenef     := RTrim(SEE->EE_XNOMCOM)
_cCnpjBenef     := TransForm(SEE->EE_XEMPCGC, "@R 99.999.999/9999-99")
_cEndBenef      := RTrim(SEE->EE_XENDCOB)
_cBairBenf      := RTrim(SEE->EE_XBAICOB) 
_cMuniBenf      := RTrim(SEE->EE_XCIDCOB) 
_cUFBenef       := SEE->EE_XESTCOB
_cCepBenef      := Alltrim(Transform(SEE->EE_XCEPCOB,"@R 99999-999"))

_cCodCli        := RTrim(SA1->A1_COD) + RTrim(SA1->A1_LOJA)
_cNomeCli       := RTrim(SA1->A1_NOME)
_cCnpjCli       := TransForm(SA1->A1_CGC, "@R 99.999.999/9999-99")
_cEndCli        := IIF(Empty(SA1->A1_ENDCOB),RTrim(SA1->A1_END),RTrim(SA1->A1_ENDCOB))
_cBairCli       := IIF(Empty(SA1->A1_ENDCOB),RTrim(SA1->A1_BAIRRO),RTrim(SA1->A1_BAIRROC))
_cMuniCli       := IIF(Empty(SA1->A1_ENDCOB),RTrim(SA1->A1_MUN),RTrim(SA1->A1_MUNC))
_cUFCli         := IIF(Empty(SA1->A1_ENDCOB),RTrim(SA1->A1_EST),RTrim(SA1->A1_ESTC))
_cCepCli        := IIF(Empty(SA1->A1_ENDCOB),Alltrim(Transform(SA1->A1_CEP,"@R 99999-999")),Alltrim(Transform(SA1->A1_CEPC,"@R 99999-999")))

_cNomeBanco     := "Banco Itaú S.A." // RTrim(SA6->A6_NOME)
_cNumBanco		:= RTrim(_cBanco)
_cDigBanco	    :=	"7"
_cDigConta      := SubStr(_cNumBanco,Len(_cNumBanco),1)
_cAgencia	    := StrZero(Val(_cAgencia),4)
_cNumConta	    := StrZero(Val(_cConta),5)
_cDigConta		:= Alltrim(SEE->EE_DVCTA)
_cNumTit		:= StrZero(Val(SE1->E1_NUM),9)
_cParcela		:= IIF(Empty(SE1->E1_PARCELA),"0",SE1->E1_PARCELA)
_cDtVencto      := SE1->E1_VENCREA
_cDtEmissao     := dToC(SE1->E1_EMISSAO)
_cFatorVcto     := StrZero(_cDtVencto - Ctod("07/10/1997"),4)
_nValorTit      := Val(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["valor_titulo"])
// _nDesconto      := SE1->E1_DECRESC

_cNossoNum	:=	_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_nosso_numero"]
_cDigitao	:=	cValToChar(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["dac_titulo"])
_cDadosCta	:=	_cAgencia + "/" + _cNumConta + "-" + _cDigConta          	
_cCarteira  :=  _oBoleto["dado_boleto"]["codigo_carteira"]
// _cBloco1    :=	Transform(SubStr(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"],1,10),"@R 99999.99999")
// _cBloco2	:= 	Transform(SubStr(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"],11,10),"@R 99999.99999")
// _cBloco3	:=	Transform(SubStr(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"],21,10),"@R 99999.99999")
// _cBloco4	:=	SubStr(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"],32)

// _cDigCodBar	:=	SubStr(_oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"],31,1)
// _cLinhaDigit	:=	_cBloco1 + "   " + _cBloco2 + "   " + _cBloco3 + "  " + _cDigCodBar + "   " + _cBloco4
_cLinhaDigit := _oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"]
_cLinhaDigit := Transform(_cLinhaDigit, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999")

_cCodBar	 := _oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["codigo_barras"]
_cNumDoc     := _oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["texto_seu_numero"]

//---------------------+
// Inicia nova pagina  |
//---------------------+
_oPrint:StartPage()

//----------------------------+
// Layout - Recibo do Pagador |
//----------------------------+
_oPrint:Box(100, 025, 128 ,390) 
_oPrint:Box(100, 390, 128, 550) 
_oPrint:Box(128, 025, 148, 390)
_oPrint:Box(128, 390, 148, 550)
_oPrint:Box(148, 025, 168, 088)
_oPrint:Box(148, 088, 168, 175)
_oPrint:Box(148, 175, 168, 213)
_oPrint:Box(148, 213, 168, 265)
_oPrint:Box(148, 265, 168, 390)
_oPrint:Box(148, 390, 168, 550)
_oPrint:Box(168, 025, 188, 088)
_oPrint:Box(168, 088, 188, 125)
_oPrint:Box(168, 125, 188, 163)
_oPrint:Box(168, 163, 188, 265)
_oPrint:Box(168, 265, 188, 390)
_oPrint:Box(168, 390, 188, 550)
_oPrint:Box(188, 390, 208, 550)
_oPrint:Box(188, 025, 288, 390)
_oPrint:Box(208, 390, 228, 550)
_oPrint:Box(228, 390, 248, 550)
_oPrint:Box(248, 390, 268, 550)
_oPrint:Box(268, 390, 288, 550)
_oPrint:Box(288, 025, 330, 550)

//-----------------+
// Layout - Boleto |
//-----------------+
_oPrint:Box(390, 025, 416, 390)
_oPrint:Box(390, 390, 416, 550)
_oPrint:Box(416, 025, 436, 390)
_oPrint:Box(416, 390, 436, 550)
_oPrint:Box(436, 025, 456, 088)
_oPrint:Box(436, 088, 456, 175)
_oPrint:Box(436, 175, 456, 213)
_oPrint:Box(436, 213, 456, 265)
_oPrint:Box(436, 265, 456, 390)
_oPrint:Box(436, 390, 456, 550)
_oPrint:Box(456, 025, 476, 088)
_oPrint:Box(456, 088, 476, 125)
_oPrint:Box(456, 125, 476, 163)
_oPrint:Box(456, 163, 476, 265)
_oPrint:Box(456, 265, 476, 390)
_oPrint:Box(456, 390, 476, 550)
_oPrint:Box(476, 390, 496, 550)
_oPrint:Box(476, 025, 576, 390)
_oPrint:Box(496, 390, 516, 550)
_oPrint:Box(516, 390, 536, 550)
_oPrint:Box(536, 390, 556, 550)
_oPrint:Box(556, 390, 576, 550)
_oPrint:Box(576, 025, 618, 550)

//------------------------------------+
// Inicio Informacoes Primeira Sessao |
//------------------------------------+
If File(_cBitMapBanco)
    _oPrint:SayBitmap(065, 026, _cBitMapBanco, 030, 030 ) // _oPrint:SayBitmap(065, 021, _cBitMapBanco, 120, 028 )    
Else
    _oPrint:Say(095, 030, RTrim(_cNomeBanco), _oFont11)
EndIf                    

 _oPrint:Say(095, 65, _cNumBanco + "-" + _cDigBanco, _oFont22) // _oPrint:Say(095, 145, _cNumBanco + "-" + _cDigBanco, _oFont22)
_oPrint:Say(095, 450, "RECIBO DO PAGADOR", _oFont10 ,100)    
_oPrint:say(107, 027, "Beneficiario",_oFont8,100) 
_oPrint:Say(117, 027, _cNomeBenef + ' CNPJ: ' + _cCnpjBenef ,_oFont10,100)
_oPrint:Say(107, 392, "Vencimento",_oFont8,100)
_oPrint:Say(120, 485, dToc(_cDtVencto),_oFont10,400,,,1)
_oPrint:Say(135, 027, "Endereço Beneficiario\Sacador Avalista",_oFont8,100)
_oPrint:Say(135, 392, "Agêcia/Código Beneficiario",_oFont8,100)
_oPrint:Say(145, 030, _cEndBenef + " " + _cBairBenf + " " + _cMuniBenf + " - " + _cUFBenef + " " + _cCepBenef  ,_oFont10,100)
_oPrint:Say(145, 485, _cDadosCta,_oFont10,116,,,1)
_oPrint:Say(155, 027, "Data Documento",_oFont8,100)
_oPrint:Say(155, 093, "Número do Documento",_oFont8,100)
_oPrint:Say(155, 180, "Esp.Doc.",_oFont8,100)
_oPrint:Say(155, 218, "Aceite",_oFont8,100)
_oPrint:Say(155, 270, "Data Processamento",_oFont8,100)
_oPrint:Say(155, 392, "Carteira/Nosso Número",_oFont8,100)
_oPrint:Say(164, 027, _cDtEmissao,_oFont10,100)
_oPrint:Say(164, 093, _cNumDoc,_oFont10,100)    //Numero do Documento
_oPrint:Say(164, 180, "DM",_oFont10,100)
_oPrint:Say(164, 215, "N",_oFont10,100)
_oPrint:Say(164, 273, _cDtEmissao,_oFont10,100)
_oPrint:Say(164, 485, _cCarteira + "/" + _cNossoNum + "-" + _cDigitao,_oFont10,100,,,1)
_oPrint:Say(175, 027, "Uso do Banco",_oFont8,100)
_oPrint:Say(175, 093, "Carteira",_oFont8,100)
_oPrint:Say(175, 130, "Espécie",_oFont8,100)
_oPrint:Say(175, 168, "Quantidade",_oFont8,100)
_oPrint:Say(175, 273, "Valor",_oFont8,100)
_oPrint:Say(175, 392, "(=) Valor do Documento",_oFont8,100)
_oPrint:Say(185, 093, _cCarteira,_oFont10,100)                              // carteira
_oPrint:Say(185, 130, "R$",_oFont10,100)                                                                                                                 
_oPrint:Say(185, 485, AllTrim(TransForm(_nValorTit, "@E 999,999,999.99")),_oFont10,100,,,1)           //Valor
_oPrint:Say(195, 027, "Instruções de responsabilidade do Beneficiário. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO.",_oFont6,100)
_oPrint:Say(195,392,"(-) Abatimento",_oFont8,100)
_oPrint:Say(215,392,"(-) Desconto",_oFont8,100)
_oPrint:Say(235,392,"(+) Mora/Multa/Outros Recebimentos",_oFont8,100)
_oPrint:Say(255,392,"(+) Juros",_oFont8,100)
_oPrint:Say(275,392,"(=) Valor Cobrado",_oFont8,100)

_nLin := 205
aMsgCob := _oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["mensagens_cobranca"]
If ValType(aMsgCob) == "A"
    For _nX := 1 To Len(aMsgCob)
        _oPrint:Say(_nLin, 027, AllTrim(DecodeUtf8(aMsgCob[_nX]["mensagem"])), _oFont10)
        _nLin += 10
    Next _nX 
EndIf

_oPrint:Say(294, 027, "Pagador", _oFont8, 100)
_oPrint:Say(301, 027, _cNomeCli + ' - ' + _cCodCli , _oFont8B, 100)
_oPrint:Say(301, 375, 'CNPJ ' + _cCnpjCli ,_oFont8B, 100)
_oPrint:Say(310, 027, _cEndCli + ' - ' + _cBairCli , _oFont8B, 100)
_oPrint:say(320, 027, _cCepCli + ' - ' + _cMuniCli + ' - ' + _cUFCli , _oFont8B, 100 )
_oPrint:Say(328, 027, 'Sacador/Avalista'+" " /*+ _cNomeBenef*/,_oFont8,500)
// _oPrint:Say(328, 375, 'CNPJ ' + _cCnpjBenef , _oFont8, 100)
_oPrint:Say(338, 375, 'Autenticação Mecânica', _oFont8, 100) 

_oPrint:Say(350, 025, Replicate("-",203), _oFont8, 100)

//+----------------------------------+
//|Inicio Informacoes Segunda Sessao |
//+----------------------------------+
If File(_cBitMapBanco)
    _oPrint:SayBitmap(354, 026, _cBitMapBanco, 030, 030 ) // _oPrint:SayBitmap(360, 021, _cBitMapBanco, 120, 028 )
Else
    _oPrint:Say(384, 030, RTrim(_cNomeBanco), _oFont11)
EndIf 

_oPrint:Say(384, 65, _cNumBanco + "-" + _cDigBanco, _oFont22, 100) //_oPrint:Say(384, 137, _cNumBanco + "-" + _cDigBanco, _oFont22, 100)
_oPrint:Say(384, 190, _cLinhaDigit, _oFont14N, 100 )                     
_oPrint:Say(396, 027, "Local de Pagamento",_oFont8,100)
_oPrint:Say(396, 392, "Vencimento",_oFont8,100)
_oPrint:Say(407, 027, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",_oFont10,100)
_oPrint:Say(411, 490, dToC(_cDtVencto), _oFont10, 100,,,1)                 
_oPrint:Say(423, 027, "Beneficiário",_oFont8,100)
_oPrint:Say(423, 392, "Agência/Código Beneficiário",_oFont8,100)
_oPrint:Say(433, 030, _cEndBenef + " " + _cBairBenf + " " + _cMuniBenf + " - " + _cUFBenef + " " + _cCepBenef  ,_oFont10,100) //Endere? Beneficiario...
_oPrint:Say(433, 485, _cDadosCta,_oFont10,116,,,1)          //Agencia/Codigo do Cedente
_oPrint:Say(444, 027, "Data Documento",_oFont8,100)
_oPrint:Say(444, 093, "Número do Documento",_oFont8,100)
_oPrint:Say(444, 180, "Esp.Doc.",_oFont8,100)
_oPrint:Say(444, 218, "Aceite",_oFont8,100)
_oPrint:Say(444, 270, "Data Processamento",_oFont8,100)
_oPrint:Say(444, 392, "Carteira/Nosso Número",_oFont8,100)
_oPrint:Say(453, 027, _cDtEmissao,_oFont10,100)
_oPrint:Say(453, 093, _cNumDoc,_oFont10,100)    //Numero do Documento
_oPrint:Say(453, 180, "DM",_oFont10,100)
_oPrint:Say(453, 218, "N",_oFont10,100)
_oPrint:Say(453, 270, _cDtEmissao,_oFont10,100)
_oPrint:Say(453, 485, _cCarteira + "/" + _cNossoNum + "-" + _cDigitao,_oFont10,100,,,1)
_oPrint:Say(464, 027, "Uso do Banco",_oFont8,100)
_oPrint:Say(464, 093, "Carteira",_oFont8,100)
_oPrint:Say(464, 130, "Espécie",_oFont8,100)
_oPrint:Say(464, 168, "Quantidade",_oFont8,100)
_oPrint:Say(464, 270, "Valor",_oFont8,100)
_oPrint:Say(464, 392, "(=) Valor do Documento",_oFont8,100)
_oPrint:Say(474, 093, _cCarteira ,_oFont10,100)                              // carteira
_oPrint:Say(474, 130, "R$",_oFont10,100)
_oPrint:Say(474, 490, AllTrim(TransForm(_nValorTit, "@E 999,999,999.99")),_oFont10,100,,,1)           //Valor
_oPrint:Say(484, 392, "(-) Abatimento",_oFont8,100)
_oPrint:Say(504, 392, "(-) Desconto",_oFont8,100)
_oPrint:Say(524, 392, "(+) Mora/Multa/Outros Recebimentos",_oFont8,100)
_oPrint:Say(544, 392, "(+) Juros",_oFont8,100)
_oPrint:Say(564, 392, "(=) Valor Cobrado",_oFont8,100)
_oPrint:Say(484, 027, "Instruções de responsabilidade do Beneficiário. Qualquer dúvida sobre este boleto, contate o BENEFICIÁRIO.",_oFont6,100) 

_nLin := 494
aMsgCob := _oBoleto["dado_boleto"]["dados_individuais_boleto"][1]["mensagens_cobranca"]
If ValType(aMsgCob) == "A"
    For _nX := 1 To Len(aMsgCob)
        _oPrint:Say(_nLin, 027, AllTrim(DecodeUtf8(aMsgCob[_nX]["mensagem"])), _oFont10)
        _nLin += 10
    Next _nX 
EndIf

_oPrint:Say(582, 027, "Pagador", _oFont8, 100)
_oPrint:Say(589, 027, _cNomeCli + ' - ' + _cCodCli, _oFont8B, 100)
_oPrint:Say(589, 375, 'CNPJ ' + _cCnpjCli ,_oFont8B, 100)
_oPrint:Say(596, 027, _cEndCli + ' - ' + _cBairCli , _oFont8B, 100)
_oPrint:Say(606, 027, _cCepCli + ' - ' + _cMuniCli + ' - ' + _cUFCli, _oFont8B, 100 )
_oPrint:Say(614, 027, 'Sacador/Avalista'+" " /*+ _cNomeBenef*/,_oFont8,500)
// _oPrint:Say(614, 375, 'CNPJ ' + _cCnpjBenef, _oFont8, 100)
_oPrint:Say(624, 375, 'Autenticação Mecânica - Ficha de Compensação', _oFont8, 100)                                           

//+------------------------------+
//|Impressao do codigo de barras |
//+------------------------------+
_oPrint:FWMSBAR("INT25" ,54 ,3 ,_cCodBar ,_oPrint,.F.,,.T.,0.025,1.4,,,,.F.,,,)

//-------------------+
// Encerra impressão |
//-------------------+
_oPrint:EndPage()

Return .T.

/***************************************************************************************/
/*/{Protheus.doc} RetBoleto
    @description Consulta Boleto no Itau
    @type  Function
    @author Wilson A. Silva Jr
    @since 29/09/2022
/*/
/***************************************************************************************/
Static Function RetBoleto(_cTitulo, _cPrefixo, _cParcela, _cTipo, _cEmpFat, _cJSonRet, cMsgErro)

Local _aArea     := GetArea()
Local lRetorno   := .T.
Local _oBoleto   := Itau():New()
Local cGetParams := ""

DbSelectArea("SE1")
DbSetOrder(1) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
If !DbSeek(xFilial("SE1") + _cPrefixo + _cTitulo + _cParcela + _cTipo)
    cMsgErro := "Titulo não localizado."
    lRetorno := .F.
EndIf

If lRetorno .And. Empty(SE1->E1_XIDBOL)
    cMsgErro := "Titulo não registrado no banco."
    lRetorno := .F.
EndIf

If lRetorno
    _oBoleto:cEmpFat := _cEmpFat
    _oBoleto:SetEmpresa()

    cGetParams += "id_beneficiario=" + Escape(SubStr(SE1->E1_XIDBOL,1,12))
    cGetParams += "&codigo_carteira=" + Escape(SubStr(SE1->E1_XIDBOL,13,3))
    cGetParams += "&nosso_numero=" + Escape(SubStr(SE1->E1_XIDBOL,17,8))

    If _oBoleto:GetBoleto(cGetParams)
        _cJSonRet := _oBoleto:cJSonRet
        lRetorno  := .T.
    Else 
        cMsgErro  := _oBoleto:cError
        _cJSonRet := ""
        lRetorno  := .F.
    EndIf 
EndIf 

RestArea(_aArea)

Return lRetorno
