#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS55
Menu Comissão.

@author  Wilson A. Silva Jr
@since   11/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS55()

Local oMenuCom
Local oFnt

//Montagem da Tela
DEFINE FONT oFnt NAME "ARIAL" SIZE 0,-12 BOLD

DEFINE MSDIALOG oMenuCom FROM 0,0 TO 230,220 TITLE "Menu Comissões" Of oMainWnd PIXEL

	TButton():New( 000 , 015 , "Metas x Percentual"		,oMenuCom,{|| U_ALFPMS62() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 015 , "Cadastro de Metas"		,oMenuCom,{|| U_ALFPMS56() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )	
	TButton():New( 060 , 015 , "Fechamento de Vendas"   ,oMenuCom,{|| U_ALFPMS57() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 090 , 015 , "Extrato de Comissões"	,oMenuCom,{|| U_ALFPMS58() },80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oMenuCom CENTERED

Return .T.
