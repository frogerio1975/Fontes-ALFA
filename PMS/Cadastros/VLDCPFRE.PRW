#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} VLDCPFRE
 
Descricao: valida campo AE8_CPF

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function VLDCPFRE(  )

Local lRet:= .T.
Local cQuery:= ""
Local cTmp:= GetNextAlias()
local aArea := getArea()

IF INCLUI
    cQuery+=" SELECT R_E_C_N_O_ AE8REC FROM "+RetSqlName('AE8')+" " +CRLF
    cQuery+=" WHERE "+CRLF
    cQuery+=" AE8_FILIAL='"+xFilial("AE8")+"' "+CRLF
    cQuery+=" AND AE8_CPF = '"+M->AE8_CPF+"' "+CRLF
    cQuery+=" AND AE8_ATIVO = '1' "+CRLF
    cQuery+=" AND D_E_L_E_T_ = '' "+CRLF

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
    If (cTmp)->(!Eof())
        lRet:= .F.
        //Alert( '')
        Help(,, 'HELP',, "Cpf informado ja esta cadastrado e ativo no sistema.", 1, 0)				 
    EndIf

    (cTmp)->(DbCloseArea())

END

RestArea(aArea)
Return lRet



