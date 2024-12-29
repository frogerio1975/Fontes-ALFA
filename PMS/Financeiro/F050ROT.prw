#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F050ROT
Adiciona novas opções no "Outras Ações" do Contas à Pagar.

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F050ROT()

Local aNewRot := ParamIXB
Local aRot580 := {}
Aadd( aNewRot, { "Rateio Título"        , "U_PMS30ALT"	        , 0 , 4} )
Aadd( aNewRot, { "Rel.Contas Pagar"     , "U_ALFREL02"	        , 0 , 6} )
Aadd( aNewRot, { "Rel.Despesas"         , "U_ALFREL04"	        , 0 , 6} )

Aadd( aNewRot, { "Rel.Rateio por empresa"   , "U_ALFREL07"	        , 0 , 6} )

Aadd( aNewRot, { "Alt./Exc. Titulos"    , "U_SYALTFIN(2)"	        , 0 , 6} )

Aadd( aNewRot, { "Rel. Baixas"             , "U_ALFREL08"	        , 0 , 6} )

Aadd( aNewRot, { "Importador"          , "U_zAltGen"	        , 0 , 6} )

/*
aRot580	:= {	{ 'Manual'    , "fA580Man", 0 , 2},; 
                { 'Automatica', "fA580Aut", 0 , 4}} 

aAdd( aNewRot,	{ 'Liberação',aRot580, 0 , 4}) 
*/

Return(aNewRot)
