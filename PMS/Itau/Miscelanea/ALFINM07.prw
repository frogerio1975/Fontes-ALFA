#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM07
Inclui ações na fila de integração com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM07(_cEmpFat, _cBanco, _cAgencia, _cConta, _cSubCta, _cRecSEE, cMsgErro)

Local aAreaAtu := GetArea()
Local cTMP1    := ""
Local cQuery   := ""
Local lRetorno := .T.

Default _cEmpFat := ""
Default cMsgErro := ""

cQuery := " SELECT "+ CRLF
cQuery += "     SEE.EE_CODIGO "+ CRLF
cQuery += "     ,SEE.EE_AGENCIA "+ CRLF
cQuery += "     ,SEE.EE_CONTA "+ CRLF
cQuery += "     ,SEE.EE_SUBCTA "+ CRLF
cQuery += "     ,SEE.R_E_C_N_O_ AS RECSEE "+ CRLF
cQuery += " FROM "+RetSqlName("SEE")+" SEE (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SEE.EE_FILIAL = '"+xFilial("SEE")+"' "+ CRLF
cQuery += "     AND SEE.EE_CODIGO = '341' "+ CRLF
cQuery += "     AND SEE.EE_XEMPFAT = '"+_cEmpFat+"' "+ CRLF
cQuery += "     AND SEE.EE_XEMPFAT <> ' ' "+ CRLF
cQuery += "     AND SEE.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    _cBanco     := (cTMP1)->EE_CODIGO
    _cAgencia   := (cTMP1)->EE_AGENCIA
    _cConta	    := (cTMP1)->EE_CONTA
    _cSubCta	:= (cTMP1)->EE_SUBCTA
    _cRecSEE    := (cTMP1)->RECSEE
Else
    cMsgErro := "Configuraçao (SEE) da empresa de faturamento não localizada. Empresa: " + _cEmpFat
    lRetorno := .F.
EndIf

RestArea(aAreaAtu)

Return lRetorno
