#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA050DEL
Ponto de Entrada na exclusao do Contas a Pagar.

@author  Wilson A. Silva Jr.
@since   22/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FA050DEL()

Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local cPrefixo  := SE2->E2_PREFIXO
Local cNumTit   := SE2->E2_NUM
Local cParcela  := SE2->E2_PARCELA
Local cTipo     := SE2->E2_TIPO
Local cCodFor   := SE2->E2_FORNECE
Local cLojFor   := SE2->E2_LOJA
Local cTMP1     := ""
Local cTMP2     := ""
Local cQuery    := ""
Local cTit      := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA 

// Exclui registros de rateio por empresa.
cQuery := " SELECT "+ CRLF
cQuery += "     ZZD.R_E_C_N_O_ AS RECZZD "+ CRLF
cQuery += " FROM "+RetSqlName("ZZD")+" ZZD (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     ZZD.ZZD_FILIAL = '"+xFilial("ZZD")+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_PREFIX = '"+cPrefixo+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_NUM = '"+cNumTit+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_PARCEL = '"+cParcela+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_TIPO = '"+cTipo+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_CLIFOR = '"+cCodFor+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_LOJA = '"+cLojFor+"' "+ CRLF
cQuery += "     AND ZZD.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    DbSelectArea("ZZD")
    DbGoTo((cTMP1)->RECZZD)

    RecLock("ZZD",.F.)
        DbDelete()
    MsUnlock()

    (cTMP1)->(DbSkip())
EndDo
(cTMP1)->(DbCloseArea())

If cPrefixo == "COM"
    cQuery := " SELECT "+ CRLF
    cQuery += "     Z16.R_E_C_N_O_ AS RECZ16 "+ CRLF
    cQuery += " FROM "+RetSqlName("Z16")+" Z16 (NOLOCK) "+ CRLF
    cQuery += " WHERE "+ CRLF
    cQuery += "     Z16.Z16_FILIAL = '"+xFilial("Z16")+"' "+ CRLF
    cQuery += "     AND Z16.Z16_E2PREF = '"+cPrefixo+"' "+ CRLF
    cQuery += "     AND Z16.Z16_E2NUM = '"+cNumTit+"' "+ CRLF
    cQuery += "     AND Z16.Z16_E2PARC = '"+cParcela+"' "+ CRLF
    cQuery += "     AND Z16.Z16_E2TIPO = '"+cTipo+"' "+ CRLF
    cQuery += "     AND Z16.Z16_CODFOR = '"+cCodFor+"' "+ CRLF
    cQuery += "     AND Z16.Z16_LOJFOR = '"+cLojFor+"' "+ CRLF
    cQuery += "     AND Z16.D_E_L_E_T_ = ' ' "+ CRLF

    cTMP2 := MPSysOpenQuery(cQuery)

    While (cTMP2)->(!EOF())

        DbSelectArea("Z16")
        DbGoTo((cTMP2)->RECZ16)

        RecLock("Z16",.F.)
            REPLACE Z16_E2PREF WITH " "
            REPLACE Z16_E2NUM  WITH " "
            REPLACE Z16_E2PARC WITH " "
            REPLACE Z16_E2TIPO WITH " "
            REPLACE Z16_STATUS WITH "1" // 1=Comissão Pendente
        MsUnlock()

        (cTMP2)->(DbSkip())
    EndDo

    (cTMP2)->(DbCloseArea())
EndIf

//Monta a consulta
cQryDados := " SELECT  Z44.R_E_C_N_O_ RECNO "
cQryDados += "FROM "        + CRLF
cQryDados += RetSqlName('Z44')+"  Z44 "+ CRLF
cQryDados += "WHERE "        + CRLF
cQryDados += " Z44_FILIAL = '" + FWxfilial('Z44') + "' "        + CRLF
cQryDados += " AND Z44_NUMTIT = '"+cTit+"' "        + CRLF
cQryDados += " AND Z44_FORNEC = '"+SE2->E2_FORNECE+"' "        + CRLF
cQryDados += " AND Z44_LJFOR  = '"+SE2->E2_LOJA+"' "        + CRLF  
cQryDados += " AND Z44.D_E_L_E_T_ = ' ' "        + CRLF
cTmpCtb := MPSysOpenQuery(cQryDados)
while (cTmpCtb)->(!eof())

    Z44->( DbGoTo(  (cTmpCtb)->RECNO ) )
    Z44->( RECLOCK('Z44',.F.) )
        Z44->Z44_DTBX   := ctod('')
        Z44->Z44_STATUS := '1' // AGUARDANDO BAIXA
        z44->Z44_NUMTIT := ''
    Z44->(MSUNLOCK())
            
    (cTmpCtb)->(dbSkip())
EndDo
(cTmpCtb)->( DbCloseArea() )


RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return .T.
