
#INCLUDE "FWEditPanel.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "TBIConn.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Set.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS71
Descricao: Apuração  de contratos

@version 1.0
/*/
//-------------------------------------------------------------------
User Function FA080TIT()

	local aArea		:= GetArea()
	local lRet 		:= .T.
    Local cTit      := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA 
    Local cQryDados := ""
    Local cTmpCtb   := ''

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
            Z44->Z44_DTBX := ddatabase 
            Z44->Z44_STATUS := '3' // AGUARDANDO BAIXA
        Z44->(MSUNLOCK())
                
        (cTmpCtb)->(dbSkip())
    EndDo
    (cTmpCtb)->( DbCloseArea() )

    RestArea(aArea)

Return lRet
