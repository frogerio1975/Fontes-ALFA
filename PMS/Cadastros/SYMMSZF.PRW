#INCLUDE "PROTHEUS.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4
#Define MAXGETDAD 99999
#Define MAXSAVERESULT 999

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSYMMSZF   บ Autor ณ Fabio Rogerio      บ Data ณ  22/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Metas        						     	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function SYMMSZF(nFolderOp,oGetOp)

Local aAlias 		:= GetArea()
Local aCores		:= {}
Local cFilSymm		:= ''

Private cCadastro 	:= "Cadastro de Metas"
Private bFiltraBrw  := {}
Private aIndexMa    := {}

Aadd(aCores,{ "AllTrim(ZF_ANO) == AllTrim(STR(YEAR(dDatabase)))"  , 'BR_VERDE' 		}) //Meta do Mes Atual
Aadd(aCores,{ "AllTrim(ZF_ANO) <> AllTrim(STR(YEAR(dDatabase)))"  , 'BR_VERMELHO'	}) //Meta de Meses Anteriores

aRotina:= MenuDef()

bFiltraBrw := {|| FilBrowse("SZF",@aIndexMa,@cFilSymm)}
Eval( bFiltraBrw )

DbSetOrder(1)  
mBrowse(6, 1, 22, 75,"SZF",,,,,,aCores)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Deleta o filtro utilizando a funcao FilBrowse                     	   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
EndFilBrw("SZF",aIndexMa)

RestArea(aAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณFabio Rogerio       บ Data ณ  02/22/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta menu                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef() 

Local aRotina := {}

Aadd( aRotina , { 'Visualizar'			, "U_SZFWIZARD(2)" , 0 , 2} )
Aadd( aRotina , { 'Incluir'				, "U_SZFWIZARD(3)" , 0 , 3} )
Aadd( aRotina , { 'Alterar'				, "U_SZFWIZARD(4)" , 0 , 4} )
Aadd( aRotina , { 'Excluir'				, "U_SZFWIZARD(5)" , 0 , 5} )

Return(aRotina)
                
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSZFWIZARD บAutor  ณ   Fabio Rogeiro    บ Data ณ  02/22/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Wizard para montagem de metas                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SZFWIZARD(nOpc)

Local oWizard
Local oMetas               
Local aArea		 := GetArea()
Local nGrava 	 := 0
Local aRecursos := {}
Local oRecursos := Nil                    
Local aSizeDlg   := MsAdvSize() //MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela principal.
Local oOk	 	 := LoadBitMap(GetResources(), "LBOK")
Local oNo		 := LoadBitMap(GetResources(), "LBNO")
Local aRotBKP    := aClone(aRotina)

Private oGetDad     := {}
Private aHeadZ03    := {}
Private oPnlTitulo  := {}
Private oPnlObjetivo:= {}
Private oPnlSayObj  := {}
Private aObj        := {}
Private oFolder
Private oPanelTot
Private oScroll
Private oResumo 
Private aTELA[0][0],aGETS[0]
Private aHeadRes  := {}
Private aColsRes  := {}
Private aHeadPar  := {}
Private aColsPar  := {}
Private aHeadComis:= {}
Private aColsComis:= {}
Private oFldEscopo
Private oFldPagto
Private oFnt := TFont():New( "Arial",,20,,.T.,,,,,.F.)
Private oFnt2 := TFont():New( "Arial",,18,,.T.,,,,,.F.)

aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
			 {"Visualizar","AxVisual",0,2} ,;
             {"Incluir","AxInclui",0,3} ,;
             {"Alterar","AxAltera",0,4} ,;
             {"Excluir","AxDeleta",0,5} }

/*IF nOpc == 4 .Or. nOpc == 5 
	IF Alltrim(SZF->ZF_ANO) <> AllTrim(STR(YEAR(dDatabase)))
		Aviso("Aten็ใo","Somente ้ permitido alterar/excluir meta do ano atual",{"Ok"})
		nOpc := 2
	EndIF
EndIF
*/
IF nOpc == 2 .Or. nOpc == 5
	INCLUI := .F.
	ALTERA := .F.
ElseIF nOpc == 3
	INCLUI := .T.
	ALTERA := .F.
ElseIF nOpc == 4
	INCLUI := .F.
	ALTERA := .T.
EndIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do Wizard principal.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oWizard:= APWizard():New( 	"Wizard para Cadastro de Metas - "+aRotina[nOpc,1]	,;
							"Identifica็ใo da metas",;
						  	"Preencha os dados para elabora็ใo da metas.",;
							 ,;
							 {||SZFWIZRecursos(@aRecursos,@oRecursos,nOpc,M->ZF_TIPO) },; 
							 {|| .F. } ,.T., , , .T.,{000,000,aSizeDlg[6]-30,aSizeDlg[5]} )

	oWizard:GETPANEL(1)                                                                     
	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPanel 1. - IdentIFicacao metas ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aBCposAlt := {}     
	aBCposVis := {}
	
	SX3->(DbSetOrder(1))
	SX3->(DbSeek('SZF'))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'SZF'
		IF ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			Aadd(aBCposAlt,SX3->X3_CAMPO)
			Aadd(aBCposVis,SX3->X3_CAMPO)				
		EndIF
		SX3->(DbSkip())
	EndDo
	
	RegToMemory("SZF",IIF(nOpc == 3,.T.,.F.))	

	aSize := MsAdvSize()
	
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .F. } )
	AAdd( aObjects, { 070, 100, .F., .T. } )
	AAdd( aObjects, { 100, 015, .T., .F. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosObj[1][3] := 230
	
    oMetas:=	MsMGet():New("SZF",SZF->(Recno()),nOpc,,,,aBCposVis,aPosObj[1],aBCposAlt,3,,,,oWizard:GETPANEL(1),,.F.,.T.)
	oMetas:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPanel 2. - Recursos 	   ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard  HEADER "Recursos" MESSAGE "Escolha os Recursos para a composi็ใo da metas" ;
			 BACK {|| .T.};
			 NEXT {|| .F.};
			 FINISH {||SZFGrv(oWizard,aRecursos,nOpc)} PANEL
	oWizard:GETPANEL(2)

	aRecursos:= {{.F.,"","",0,0,0,0,0,0,0,0,0,0,0,0,0}}
	oRecursos			:= TwBrowse():New(1,1,1,1,,{"","Recurso",Padr("Nome",50),Padr("Jan",10),Padr("Fev",10),Padr("Mar",10),Padr("Abr",10),Padr("Mai",10),Padr("Jun",10),Padr("Jul",10),Padr("Ago",10),Padr("Set",10),Padr("Out",10),Padr("Nov",10),Padr("Dez",10),Padr("Total",10)},, oWizard:GETPANEL(2),,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oRecursos:Align     := CONTROL_ALIGN_ALLCLIENT
	oRecursos:lColDrag	:= .T.
	oRecursos:SetArray(aRecursos)
	oRecursos:bLine := { || { 	IIF(aRecursos[oRecursos:nAt,1],oOk,oNo) ,;
							 aRecursos[oRecursos:nAt,2] ,;
							 aRecursos[oRecursos:nAt,3] ,;
							 TRANSFORM( aRecursos[oRecursos:nAt,4] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,5] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,6] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,7] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,8] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,9] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,10],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,11],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,12],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,13],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,14],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,15],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,16],"@E 99,999,999,999.99" )} }
	IF (nOpc == 3) .Or. (nOpc == 4)
		oRecursos:bLDblClick 	:= { || EditaCelula(oRecursos,aRecursos)}
		oRecursos:bHeaderClick	:= { || AEval(aRecursos,{|x| x[1]:= !x[1]}), oRecursos:Refresh()}
    EndIF


ACTIVATE WIZARD oWizard CENTERED WHEN {||.T.}

IF __lSX8 .And. (nGrava == 1)
	ConfirmSX8()
Else
	RollBackSX8()
EndIF

aRotina := aClone(aRotBKP)

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWIZRecursosบAutorณFabio Rogerio       บ Data ณ  02/22/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os Recursos para selecao                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SZFWIZRecursos(aRecursos,oRecursos,nOpc,cTipo)

Local aArea     := GetArea()
Local cQuery    := ""
Local nRec      := 0 
Local oOk	 	:= LoadBitMap(GetResources(), "LBOK")
Local oNo		:= LoadBitMap(GetResources(), "LBNO")

aRecursos:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega os Recursos Disponiveis.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery:= " SELECT * "
cQuery+= " FROM " + RetSqlName("AE8") + " AE8 "

If (M->ZF_TIPO == '2')
	cQuery+= " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.D_E_L_E_T_ = '' AND SA3.A3_FORNECE = AE8.AE8_CODFOR AND SA3.A3_FUNCAO IN ('1','2','6','7')"
EndIf

cQuery+= " WHERE AE8.D_E_L_E_T_ = ' ' "
cQuery+= " AND AE8.AE8_FILIAL  = '" + xFilial("AE8") + "' "

IF cTipo == '1'
	cQuery+= " AND AE8.AE8_EQUIPE IN ('1','2','4') "	//Consultor / Programador / Coordenador
Else
	cQuery+= " AND AE8.AE8_EQUIPE IN ('4','5','6','S') "	//Gestor, Vendedores, Diretor
EndIF

cQuery+= " AND AE8.AE8_ATIVO <> '2' "

cQuery+= " ORDER BY AE8_DESCRI "
TcQuery cQuery New Alias "TMP"

DbSelectArea("TMP")
DbGoTop()
While !TMP->(Eof())
	
	nPos:= aScan(aRecursos,{|x| x[2] == TMP->AE8_RECURS})
	IF (nPos == 0)
		Aadd(aRecursos,{.F.,TMP->AE8_RECURS,TMP->AE8_DESCRI,0,0,0,0,0,0,0,0,0,0,0,0,0,TMP->AE8_USER})

		If nOpc == 3
			aRecursos[Len(aRecursos),4] := M->ZF_METRICA
			aRecursos[Len(aRecursos),5] := M->ZF_METRICA
			aRecursos[Len(aRecursos),6] := M->ZF_METRICA
			aRecursos[Len(aRecursos),7] := M->ZF_METRICA
			aRecursos[Len(aRecursos),8] := M->ZF_METRICA
			aRecursos[Len(aRecursos),9] := M->ZF_METRICA
			aRecursos[Len(aRecursos),10]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),11]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),12]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),13]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),14]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),15]:= M->ZF_METRICA
			aRecursos[Len(aRecursos),16]:= M->ZF_METRICA * 12
		EndIf
	EndIF
		
	DbSkip()
	DbSelectArea("TMP")

EndDo
TMP->(DbCloseArea())

IF (Len(aRecursos) == 0)
	Aadd(aRecursos,{.F.,"","",0,0,0,0,0,0,0,0,0,0,0,0,0,""})
EndIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for inclusao, marca os Recursos ja gravados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF nOpc != 3
	cQuery:= " SELECT ZC_RECURSO,ZC_DTREF,ZC_VLRMETA,ZC_VLRLIC,ZC_VLRSRV "
	cQuery+= " FROM " + RetSqlName("SZC") + " SZC "
	cQuery+= " WHERE "
	cQuery+= " ZC_FILIAL = '" + xFilial("SZC") + "' "
	cQuery+= " AND ZC_CODIGO = '" + M->ZF_CODIGO + "' "
	cQuery+= " AND D_E_L_E_T_ = ' ' "
	cQuery+= " ORDER BY ZC_RECURSO "
	TcQuery cQuery New Alias "TMP"

	TcSetField("TMP", "ZC_DTREF"	, "D" , 8 , 0 )
	
	DbSelectArea("TMP")
	DbGoTop()
	While !TMP->(Eof())
		nRec:= aScan(aRecursos,{|x| AllTrim(x[2]) == AllTrim(TMP->ZC_RECURSO) })
		IF (nRec > 0)
			aRecursos[nRec,1] := .T.

			If (M->ZF_TIPO == '1')
				nMeta:= TMP->ZC_VLRMETA
			ElseIf(M->ZF_TIPO == '2')
				nMeta:=  TMP->ZC_VLRLIC 
			ElseIf(M->ZF_TIPO == '3')
				nMeta:=  TMP->ZC_VLRSRV 
			EndIf	

			nMes:= Month(TMP->ZC_DTREF)
			aRecursos[nRec,3+nMes]:= nMeta
			aRecursos[nRec,16]+= nMeta

		EndIF
		DbSkip()
		DbSelectArea("TMP")
	EndDo
	TMP->(dbCloseArea())

EndIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ordena pelo nome do recurso                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSort(aRecursos,,,{|x,y| x[3] < y[3] })

oRecursos:SetArray(aRecursos)
oRecursos:bLine := { || { 	IIF(aRecursos[oRecursos:nAt,1],oOk,oNo) ,;
							 aRecursos[oRecursos:nAt,2] ,;
							 aRecursos[oRecursos:nAt,3] ,;
							 TRANSFORM( aRecursos[oRecursos:nAt,4] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,5] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,6] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,7] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,8] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,9] ,"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,10],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,11],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,12],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,13],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,14],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,15],"@E 99,999,999,999.99" ),;
							 TRANSFORM( aRecursos[oRecursos:nAt,16],"@E 99,999,999,999.99" )} }
oRecursos:Refresh()
	
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSZFGrv         บAutor  ณFabio Rogerio  บ Data ณ  02/27/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a gravacao da metas                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SZFGrv(oWizard,aRecursos,nOpc)

Local aArea			:= GetArea()
Local cMay          := ""
Local cMemo         := ""
Local nX            := 0 
Local nI            := 0                    
Local nZ            := 0                    
Local nSaveSx8Len   := GetSx8Len()
Local bCampo 	    := {|nCPO| Field(nCPO) }
Local nMes          := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for visualiza็ใo sai sem alterar gravacao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF (nOpc == 2)
	RestArea(aArea)
	Return(.T.)
EndIF	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for exclusao solicita confirmacao do usuario.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF (nOpc == 5)
	IF (Aviso("Atencao","Confirma exclusใo da metas ?",{"Sim","Nao"}) == 2)
		RestArea(aArea)
		Return(.F.)
	EndIF	
EndIF	

IF (nOpc == 3) .Or. (nOpc == 4)
	IF (Aviso("Atencao","Confirma a grava็ใo das metas ?",{"Sim","Nao"}) == 2)
		RestArea(aArea)
		Return(.F.)
	EndIF	
EndIF	

Begin Transaction

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe for altera็ใo ou exclusใo deleta tudo para gravar novamente.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF (nOpc == 4 .Or. nOpc == 5)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga as comissoes da metas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	DbSelectArea("SZC")
	DbSetOrder(3)     
	DbSeek(xFilial("SZC") + M->ZF_CODIGO,.T.)
	While !Eof() .And. (xFilial("SZC")+M->ZF_CODIGO == SZC->(ZC_FILIAL+ZC_CODIGO))
		RecLock("SZC",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		DbSelectArea("SZC")
		DbSkip()
	End
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga o cabecalho da metas.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SZF")
	DbSetOrder(1)  
	If DbSeek(xFilial("SZF")+M->ZF_CODIGO,.T.)
		RecLock("SZF",.F.,.T.)
		DbDelete()
		MsUnLock()
	EndIf
EndIF

IF (nOpc != 5)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ verifica a Numeracao do pedido de venda                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SZF")
	DbSetOrder(1)  
	DbSeek(xFilial("SZF") + M->ZF_CODIGO)
	
	IF INCLUI
		cMay := "SZF"+ Alltrim(xFilial("SZF"))
		While ( DbSeek(xFilial("SZF") + M->ZF_CODIGO) .Or. !MayIUseCode(cMay + M->ZF_CODIGO) )
			M->ZF_CODIGO := GetSxeNum('SZF','ZF_CODIGO')
		EndDo
		ConfirmSX8()
	EndIF
	
	RecLock("SZF",.T.)
	For nX := 1 TO FCount()
		IF ("FILIAL" $ FieldName(nX) )
			FieldPut(nX,xFilial("SZF"))
		Else
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		EndIF
	Next nX

	MsUnLock()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava as metas por recursos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI:= 1 To Len(aRecursos)
		AE8->(dbSetOrder(1))
		AE8->(dbSeek(xFilial("AE8")+aRecursos[nI,2]))

		SA3->(dbSetOrder(9))
		SA3->(dbSeek(xFilial("A3")+AE8->AE8_CODFOR))
	
		IF (aRecursos[nI,1])
			For nMes:= 1 To 12
				DbSelectArea("SZC")
				RecLock("SZC",.T.)
				SZC->ZC_FILIAL := xFilial("SZC")
				SZC->ZC_CODIGO := M->ZF_CODIGO
				SZC->ZC_ANOMES := M->ZF_ANO + StrZero(nMes,2)
				SZC->ZC_DTREF  := Ctod("01/"+ StrZero(nMes,2) + "/" + M->ZF_ANO   )
				SZC->ZC_VEND   := SA3->A3_COD
				SZC->ZC_RECURSO:= AE8->AE8_RECURS

				If (M->ZF_TIPO == '1')
					SZC->ZC_VLRMETA:= aRecursos[nI,3+nMes]
				ElseIf(M->ZF_TIPO == '2')
					SZC->ZC_VLRLIC := aRecursos[nI,3+nMes]
				ElseIf(M->ZF_TIPO == '3')
					SZC->ZC_VLRSRV:= aRecursos[nI,3+nMes]
				EndIf	
				MsUnLock()
			Next nMes	
		EndIF
	Next nI
	
EndIF

End Transaction

RestArea(aArea)

Return(.T.)

Static Function EditaCelula(oRecursos,aRecursos)
Local cPict 	:= "@E 99,999,999,999.99"
Local nTotal    := 0
Local nX        := 0

If ((oRecursos:ColPos) >= 4) .And. ((oRecursos:ColPos) <= 15)
	lEditCell(@aRecursos,oRecursos,cPict,oRecursos:ColPos)

	For nX:= 4 To 15
		nTotal+= aRecursos[oRecursos:nAt,nX]
	Next nX

	aRecursos[oRecursos:nAt,16]:= nTotal
Else
	aRecursos[oRecursos:nAt,1]:= !aRecursos[oRecursos:nAt,1]
EndIf
	
oRecursos:Refresh()

Return
