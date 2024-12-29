#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM03
Envia cancelamento do boleto ao Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM03(cMsgErro)

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
_cEmpFat    := XTM->XTM_EMPFAT

lRetorno := BaixaBoleto(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cEmpFat, @_cJSonRet, @cMsgErro)

If lRetorno
    DbSelectArea("SE1")
    DbSetOrder(1) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
    If DbSeek(_cFilial + _cPrefixo + _cTitulo + _cParcela + _cTipo)
        RecLock("SE1",.F.)
            REPLACE E1_NUMBCO  WITH ""
            REPLACE E1_CODBAR  WITH ""
            REPLACE E1_CODDIG  WITH ""
            REPLACE E1_XIDBOL  WITH ""
            REPLACE E1_XBOLETO WITH "2" // 2=Cancelado
        MsUnlock()
    EndIf
EndIf

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
/*/{Protheus.doc} BaixaBoleto
Envia cancelamento do boleto ao Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BaixaBoleto(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, _cEmpFat, _cJSonRet, cMsgErro)

Local _aArea     := GetArea()
Local lRetorno   := .T.
Local _oBoleto   := Itau():New()

Default cMsgErro := ""

If lRetorno .And. Empty(SE1->E1_XIDBOL)
    cMsgErro := "Boleto não registrado no banco."
    lRetorno := .F.
EndIf

//--------------------------------------+
// Envia solicitação da baixa do titulo |
//--------------------------------------+
If lRetorno
    _oBoleto:cEmpFat := _cEmpFat
    _oBoleto:SetEmpresa()
    _oBoleto:cIdBol := SE1->E1_XIDBOL
    If _oBoleto:Baixa()
        cMsgErro := "Boleto baixado com sucesso."
        lRetorno := .T.
    Else 
        cMsgErro  := "Erro na baixa do boleto."
        _cJSonRet := _oBoleto:cError
        lRetorno  := .F.
    EndIf 
EndIf 

RestArea(_aArea)

Return lRetorno
