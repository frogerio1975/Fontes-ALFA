#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F050BUT
P.E. para inclusão de botões de rotinas customizadas.

@author  Wilson A. Silva Jr
@since   27/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F050BUT()

Local aArea     := GetArea()
Local cPrefixo  := SE2->E2_PREFIXO
Local cNumTit   := SE2->E2_NUM
Local cParcela  := SE2->E2_PARCELA
Local cTipo     := SE2->E2_TIPO
Local cCliFor   := SE2->E2_FORNECE
Local cLoja     := SE2->E2_LOJA
Local cRecPag   := "P"
Local aNewBut   := {}

PUBLIC __oRatAPag

__oRatAPag := Nil

// Se diferente de inclusão carrega rateio do título
If _Opc <> 3
    __oRatAPag := U_LoadZZD(cPrefixo, cNumTit, cParcela, cTipo, cCliFor, cLoja, cRecPag)
EndIf

// Inclui rotina de RATEIO nos botões
AADD( aNewBut, {'RATEIO', {|| U_ALFPMS07() }, "Rateio por Empresa", "Rateio por Empresa"} )

RestArea(aArea)

Return aNewBut
