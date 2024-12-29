#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFART00
Menu ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFART00()

Local oMenuArt
Local oFnt

//Montagem da Tela
DEFINE FONT oFnt NAME "ARIAL" SIZE 0,-12 BOLD

DEFINE MSDIALOG oMenuArt FROM 0,0 TO 230,220 TITLE "Menu ARTIA" Of oMainWnd PIXEL

	TButton():New( 015 , 015 , "Integração Projetos"		,oMenuArt,{|| U_ALFART01() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 045 , 015 , "Relatório Apontamentos"	    ,oMenuArt,{|| U_ALFART02() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 075 , 015 , "Integração Apontamentos"	,oMenuArt,{|| U_ALFART03() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oMenuArt CENTERED

Return .T.
