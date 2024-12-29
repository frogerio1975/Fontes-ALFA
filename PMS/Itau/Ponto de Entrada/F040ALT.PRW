#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F040ALT
P.E. após a confirmação da alteração do título a receber.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F040ALT()

Local aAreaAtu := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local lApiBol  := GetNewPar("MV_XAPIBOL",.T.) // Habilita Integração de Boletos via API com o Itau
Local cTipBol  := GetNewPar("MV_XTIPBOL","NF,BOL") // Tipo de títulos que são boletos

If !EMPTY(SE1->E1_PROPOS) .AND. SE1->(FieldPos("E1_XASSPRO")) > 0 
    cQry := " UPDATE SE1010 SET E1_XASSPRO = '"+SE1->E1_XASSPRO+"'  "
    cQry += " WHERE E1_PROPOS = '"+SE1->E1_PROPOS+"'  AND D_E_L_E_T_ = '' "     
    TcSqlExec(cQry)
End

If lApiBol
    If Type("_lADtVencto") == "L"

        If _lADtVencto .And. !Empty(SE1->E1_EMPFAT) .And. AllTrim(SE1->E1_TIPO) $ cTipBol 
            // Inclui ação de alteração vencimento de boleto na fila de integração para o título posicionado
            U_ALFINM01("3")
        EndIf

        _lADtVencto := Nil
    EndIf
EndIf

RestArea(aAreaSE1)
RestArea(aAreaAtu)

Return .T.
