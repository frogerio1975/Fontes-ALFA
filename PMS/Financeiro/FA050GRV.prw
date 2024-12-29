#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA050GRV
P.E. apos a gravação de todos os dados na inclusão.

@author  Wilson A. Silva Jr
@since   27/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FA050GRV()

Local aArea := GetArea()

If ValType(__oRatAPag) == "J" .And. ValType(__oRatAPag['itens']) == "A"

    // If _Opc == 3 // Inclusão
        __oRatAPag['ZZD_PREFIX'] := M->E2_PREFIXO
        __oRatAPag['ZZD_NUM']    := M->E2_NUM
        __oRatAPag['ZZD_PARCEL'] := M->E2_PARCELA
        __oRatAPag['ZZD_TIPO']   := M->E2_TIPO
        __oRatAPag['ZZD_CLIFOR'] := M->E2_FORNECE
        __oRatAPag['ZZD_LOJA']   := M->E2_LOJA
        __oRatAPag['ZZD_RECPAG'] := "P"
    // EndIf

    U_GravaZZD(__oRatAPag)
EndIf

__oRatAPag := Nil

RestArea(aArea)

Return .T.
