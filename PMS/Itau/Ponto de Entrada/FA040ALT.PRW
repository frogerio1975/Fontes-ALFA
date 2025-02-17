#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA040ALT
P.E. na valida��o tudoOk da altera��o do titulo a receber.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FA040ALT()

Local aAreaAtu := GetArea()
Local lRetorno := .T.

Public _lADtVencto := .F.

// Valida se houve altera��o na data de vencimento do t�tulo.
_lADtVencto := (M->E1_VENCREA <> SE1->E1_VENCREA)

RestArea(aAreaAtu)

Return lRetorno
