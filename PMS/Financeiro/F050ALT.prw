#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F050ALT
P.E. apos a gravação de todos os dados na alteracao.

@author  Wilson A. Silva Jr
@since   27/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F050ALT()

Local aArea := GetArea()
Local nOpca := PARAMIXB[1]

If nOpca == 1

    If ValType(__oRatAPag) == "J" .And. ValType(__oRatAPag['itens']) == "A"

        __oRatAPag['ZZD_PREFIX'] := SE2->E2_PREFIXO
        __oRatAPag['ZZD_NUM']    := SE2->E2_NUM
        __oRatAPag['ZZD_PARCEL'] := SE2->E2_PARCELA
        __oRatAPag['ZZD_TIPO']   := SE2->E2_TIPO
        __oRatAPag['ZZD_CLIFOR'] := SE2->E2_FORNECE
        __oRatAPag['ZZD_LOJA']   := SE2->E2_LOJA
        __oRatAPag['ZZD_RECPAG'] := "P"

        U_GravaZZD(__oRatAPag)
    EndIf

    __oRatAPag := Nil
EndIf

RestArea(aArea)

Return .T.
