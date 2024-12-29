#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA040ALT
P.E. na validação tudoOk da alteração do titulo a receber.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FA040ALT()

Local aAreaAtu := GetArea()
Local lRetorno := .T.

Public _lADtVencto := .F.

// Valida se houve alteração na data de vencimento do título.
_lADtVencto := (M->E1_VENCREA <> SE1->E1_VENCREA)

RestArea(aAreaAtu)

Return lRetorno
