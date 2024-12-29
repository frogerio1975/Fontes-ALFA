#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA080
Ponto de Entrada na Baixa do Contas a Pagar.

@author  Wilson A. Silva Jr.
@since   22/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FINA080()

Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local cPrefixo  := SE2->E2_PREFIXO
Local cNumTit   := SE2->E2_NUM
Local cParcela  := SE2->E2_PARCELA
Local cTipo     := SE2->E2_TIPO
Local cTMP1     := ""
Local cQuery    := ""

If cPrefixo == "COM"
    cQuery := " SELECT "+ CRLF
    cQuery += "     Z39.R_E_C_N_O_ AS RECZ39 "+ CRLF
    cQuery += " FROM "+RetSqlName("Z39")+" Z39 (NOLOCK) "+ CRLF
    cQuery += " WHERE "+ CRLF
    cQuery += "     Z39.Z39_FILIAL = '"+xFilial("Z39")+"' "+ CRLF
    cQuery += "     AND Z39.Z39_E2PREF = '"+cPrefixo+"' "+ CRLF
    cQuery += "     AND Z39.Z39_E2NUM = '"+cNumTit+"' "+ CRLF
    cQuery += "     AND Z39.Z39_E2PARC = '"+cParcela+"' "+ CRLF
    cQuery += "     AND Z39.Z39_E2TIPO = '"+cTipo+"' "+ CRLF
    cQuery += "     AND Z39.D_E_L_E_T_ = ' ' "+ CRLF

    cTMP1 := MPSysOpenQuery(cQuery)

    While (cTMP1)->(!EOF())

        DbSelectArea("Z39")
        DbGoTo((cTMP1)->RECZ39)

        RecLock("Z39",.F.)
            REPLACE Z39_STATUS WITH "3" // 3=Pagamento Realizado
        MsUnlock()

        (cTMP1)->(DbSkip())
    EndDo

    (cTMP1)->(DbCloseArea())
EndIf

RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return .T.
