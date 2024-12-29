#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM04
Envia atualização de data de vencimento ao Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM04(cMsgErro)

Local _aArea    := GetArea()
Local lRetorno  := .T.
Local cStatus   := ""
Local _cJSonRet := ""

Default cMsgErro := ""

_cFilial    := XTM->XTM_FILIAL
_cTitulo    := XTM->XTM_NUMTIT
_cPrefixo   := XTM->XTM_PREFIX
_cParcela   := XTM->XTM_PARCEL
_cTipo      := XTM->XTM_TIPO
_cCliente   := XTM->XTM_CLIENT
_cLoja      := XTM->XTM_LOJA
_cEmpFat    := XTM->XTM_EMPFAT

lRetorno := EnvBoleto(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cCliente, _cLoja, _cEmpFat, @_cJSonRet, @cMsgErro)

cStatus := IIF(lRetorno,"2","3") // 1=Pendente, 2=Processado, 3=Erro

// Registra Retorno do Processamento
RecLock("XTM",.F.)
    REPLACE XTM_STATUS  WITH cStatus
    REPLACE XTM_DTPROC  WITH DATE()
    REPLACE XTM_HRPROC  WITH TIME()
    REPLACE XTM_REQUES  WITH ""
    REPLACE XTM_RESPON  WITH _cJSonRet
    REPLACE XTM_MSGERR  WITH cMsgErro
MsUnlock()

RestArea(_aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvBoleto
Envia atualização de data de vencimento ao Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvBoleto(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cCliente, _cEmpFat, _cLoja, _cJSonRet, cMsgErro)

Local _aArea     := GetArea()
Local lRetorno   := .T.
Local _oBoleto   := Itau():New()

Default cMsgErro := ""

DbSelectArea("SE1")
DbSetOrder(2) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
If !DbSeek(_cFilial + _cCliente + _cLoja + _cPrefixo + _cTitulo + _cParcela + _cTipo)
    cMsgErro := "Titulo não localizado."
    lRetorno := .F.
EndIf

If lRetorno .And. Empty(SE1->E1_XIDBOL)
    cMsgErro := "Titulo não registrado no banco."
    lRetorno := .F.
EndIf

//------------------------------+
// Se titulo já estiver baixado |
//------------------------------+
If lRetorno .And. (!Empty(SE1->E1_BAIXA) .Or. SE1->E1_SALDO == 0 ) 
    cMsgErro := "Titulo conciliado, não pode ser prorrogado."
    lRetorno := .F.
EndIf 

//--------------------------------------+
// Envia solicitação da baixa do titulo |
//--------------------------------------+
If lRetorno
    _oBoleto:cEmpFat := _cEmpFat
    _oBoleto:SetEmpresa()
    _oBoleto:cIdBol := SE1->E1_XIDBOL
    If _oBoleto:Vencimento(SE1->E1_VENCREA)
        cMsgErro := "Boleto prorrogado com sucesso."
        lRetorno := .T.
    Else 
        cMsgErro  := "Erro no envio do boleto."
        _cJSonRet := _oBoleto:cError
        lRetorno  := .F.
    EndIf 
EndIf 

RestArea(_aArea)

Return lRetorno 
