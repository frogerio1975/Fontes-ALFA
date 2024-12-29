#Include "Protheus.ch"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4

/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ALFACadMod บ Autor ณ  Fabio Rogerio    บ Data ณ  05/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Modulos/Cursos.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ALFACadMod()
 
Local aArea 	:= GetArea()
Local aCores 	:= { { "Z00_LIBERA = '1' " , "BR_VERDE" }  , { "Z00_LIBERA = '2' " , "BR_VERMELHO" } }
Local aParamBox	:= {}
Local aRet		:= {}
Local cFiltro

Private bFiltraBrw 	:= {}
Private aIndZ00   	:= {}
Private cCadastro	:= "Cadastro de Modulos/Oferta/Licenca"
Private cZ00Produt  := "" //Variavel usada em Filtro no SXB da Z00 para selecionar somente os modulos do produto selecionado
Private aRotina := {;
{"Pesquisar"	,"AxPesqui"  	,0,1},;
{"Visualizar"	,"U_NewModInc" 	,0,2},;
{"Incluir"		,"U_NewModInc" 	,0,3},;
{"Alterar"		,"U_NewModInc" 	,0,4},;
{"Excluir"		,"U_NewModInc" 	,0,5},;
{"Copiar"		,"U_NewModInc" 	,0,6},;
{"Importa Menus","U_NewMenuSiga"	,0,7},;
{"Legenda"		,"U_NewModLeg"		,0,8 }}


Aadd(aParamBox,{3,"Produtos",1,{"Todos","SAP","TOTVS"},50,"",.T.})
Aadd(aParamBox,{3,"Tipos",2,{"Bloqueados","Liberados", "Ambos"},50,"",.T.})
Aadd(aParamBox,{3,"Modulo/Oferta/Licenca",1,{"Modulo","Oferta","Licenca"},50,"",.T.})
Aadd(aParamBox,{1,"Fornecedor",Space(6),"","","SA2","",0,.F.})

If ParamBox(aParamBox,"Filtros...",@aRet)

	IF MV_PAR01 == 2
		cFiltro := "Z00_PRODUT == '2'"
	ElseIF MV_PAR01 == 3
		cFiltro := "Z00_PRODUT == '1'"
	Else
		cFiltro := ".T. "
	EndIF

	IF MV_PAR02 == 1
		cFiltro += " .AND. Z00_LIBERA == '2'"
	ElseIF MV_PAR02 == 2
		cFiltro += " .AND. Z00_LIBERA == '1'"
	EndIF
	
	IF !Empty(MV_PAR04)
		cFiltro += " .AND. Z00_FORNEC == '" + Alltrim(MV_PAR04) + "' "
	EndIF

	IF MV_PAR03 == 1
		cFiltro += " .AND. Z00_TPMOD == '1'"
	ElseIF MV_PAR03 == 2
		cFiltro += " .AND. Z00_TPMOD == '2'"
	ElseIF MV_PAR03 == 3
		cFiltro += " .AND. Z00_TPMOD == '3'"
	EndIF

	bFiltraBrw := {|| FilBrowse("Z00",@aIndZ00,cFiltro)}
	Eval( bFiltraBrw )

Endif

DbSelectArea("Z00")
DbSetOrder(3)
DbGoTop()

mBrowse(6,1,22,75,"Z00",,,,,,aCores)

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NewModInc  บAutor  ณ  Alexandro Dias  บ Data ณ  02/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alteracao.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function NewModInc(cAlias,nReg,nOpc)

Local aArea    	:= GetArea()
Local aButtons	:= {}
Local nStyle 	:= GD_INSERT+GD_UPDATE+GD_DELETE
Local cQuery	:= ''
Local nX		:= 0
Local lOk		:= .F.
Local nPModulo  := 0

Private cModZ00     := ""
Private aSavHeader	:= {}
Private aSavaCols 	:= {}
Private aGets	  	:= {}
Private aTela 	  	:= {}
Private aHeaderZ01 	:= {}
Private aColsZ01	:= {}
Private aHeaderZ17 	:= {}
Private aColsZ17	:= {}
Private aCposAltZ17	:= {}
Private aCposAltZ01	:= {}

Private INCLUI
Private ALTERA

Private oItens
Private oModulos

IF nOpc == 3 .Or. nOpc == 6
	INCLUI := .T.
	ALTERA := .F.
Else
	INCLUI := .F.
	ALTERA := .T.
EndIF

RegToMemory("Z00",IIF(nOpc == 3,.T.,.F.))
M->Z00_TPMOD:= cValToChar(MV_PAR03)
cZ00Produt  := M->Z00_PRODUT

/*==================================================
CADASTRO DE MODULOS x Oferta
====================================================*/
If (M->Z00_TPMOD == "2")
	//Careggar o a Header da Z17
	LoadZ17aHeader()
	
	//Careggar o a Header da Z01
	LoadZ01aHeader()

	//Carrega o aCols da Z17
	LoadZ17aCols(nOpc)

	//Carrega o aCols da Z18/Z01
	lFirstLoad:= .T.
	LoadZ01aCols(nOpc,lFirstLoad)

	nPModulo:= aScan(aHeaderZ17, {|x| AllTrim(x[2]) == "Z17_MODULO"})
	cModZ00:= aColsZ17[1,nPModulo]
ElseIf (M->Z00_TPMOD == "1")	

	//Careggar o a Header da Z01
	LoadZ01aHeader()

	cModZ00:= M->Z00_MODULO	

	/*==================================================
	CADASTRO DE ITENS DOS MODULOS
	====================================================*/
	//Carrega o aCols da Z18/Z01
	LoadZ01aCols(nOpc)
EndIf

nPos:= aScan(aSavaCols,{|x| x[1] == cModZ00})
If (nPos > 0) .And. (Len(aSavaCols[nPos,2]) > 0)
	aColsZ01    := aSavaCols[nPos,2]
EndIf

IF nOpc == 6
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Quando copia reinicia as variaveis.                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	M->Z00_MODULO 	:= CriaVar("Z00_MODULO",.F.)
	M->Z00_MEMO1 	:= MSMM(Z00->Z00_CODM1) 
	M->Z00_CODM1  	:= CriaVar("Z00_CODM1",.F.)
	M->Z00_LIBERA 	:= "2"
EndIF

oSize := FwDefSize():New( .T.)

If (M->Z00_TPMOD == "3") //Licencas 
	oSize:AddObject( "ENCHOICE"	, 100, 100, .T., .T. ) // enchoice
ElseIF(M->Z00_TPMOD == "2") //Oferta
	oSize:AddObject( "ENCHOICE"	, 100, 40, .T., .T. ) // enchoice
	oSize:AddObject( "FOLDER2"	, 100, 20, .T., .T. ) // getadados modulo
	oSize:AddObject( "FOLDER"	, 100, 40, .T., .T. ) // getadados itens do modulo
ElseIf(M->Z00_TPMOD == "1") //Modulo
	oSize:AddObject( "ENCHOICE"	, 100, 40, .T., .T. ) // enchoice
	oSize:AddObject( "FOLDER"	, 100, 60, .T., .T. ) // getadados itens do modulo
EndIf

oSize:lProp := .T.
oSize:Process()

	
DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE cCadastro Of oMainWnd PIXEL 
	
oDlg:lEscClose 	:= .F.
oDlg:lMaximized := .T.

oEnchoice := MsmGet():New("Z00",Z00->(Recno()),nOpc,,,,,{oSize:GetDimension("ENCHOICE","LININI"),;
           									  			oSize:GetDimension("ENCHOICE","COLINI"),;
           									   			oSize:GetDimension("ENCHOICE","LINEND"),;
           									   			oSize:GetDimension("ENCHOICE","COLEND")},,,,,,oDlg,,,,,.T.)    


IF(M->Z00_TPMOD == "2") //Oferta

	/*==================================================================
	PANEL DOS MODULOS POR Oferta
	===================================================================*/
	oPanel2 := TPanel():New(	oSize:GetDimension("FOLDER2","LININI"),;
								oSize:GetDimension("FOLDER2","COLINI"),;
								'', oDlg, NIL, .T., .F., NIL,,;
								oSize:GetDimension("FOLDER2","XSIZE"),;
								oSize:GetDimension("FOLDER2","YSIZE"), .T., .F. )

	bColorMod 		:= &("{|| AFModCorBrw(@oModulos) }")

	oModulos:= MsNewGetDados():New(0,0,0,0,IIF(nOpc == 2 .Or. nOpc == 5,0,nStyle),"",,"+Z17_SEQ",aCposAltZ17,,9999,,,,oPanel2,@aHeaderZ17,@aColsZ17)

	oModulos:oBrowse:Align    := CONTROL_ALIGN_ALLCLIENT
	oModulos:bDelOk   := {|| SYZ17Del() }
	oModulos:bChange  := {|| LoadZ01aCols(nOpc,.F.),AtuItens() }
	oModulos:bFieldOk := {|| Eval(bColorMod),U_Z17FieldOK(ReadVar(),nOpc),AtuItens() }
	oModulos:bLinhaOk := {|| IIF(U_Z17LinOK(nOpc), LoadZ01aCols(nOpc,.F.),.F.)}

	//oModulos:oBrowse:SetBlkColor(bColorFont)
	//oModulos:oBrowse:bLostFocus := {|| SYZ00Horas() }

	oModulos:oBrowse:Refresh()

	/*==================================================================
	PANEL DOS ITENS DOS MODULOS
	===================================================================*/
	oPanel1 := TPanel():New(	oSize:GetDimension("FOLDER","LININI"),;
								oSize:GetDimension("FOLDER","COLINI"),;
								'', oDlg, NIL, .T., .F., NIL,,;
								oSize:GetDimension("FOLDER","XSIZE"),;
								oSize:GetDimension("FOLDER","YSIZE"), .T., .F. )

	bColor 		:= &("{|| U_AF02CorBrw(@oItens,1) }")
	bColorFont	:= &("{|| U_AF02CorBrw(@oItens,2) }")

	oItens:= MsNewGetDados():New(0,0,0,0,IIF(nOpc == 2 .Or. nOpc == 5,0,nStyle),"U_AFZ00LinOk()",,"+Z01_ORDEM",aCposAltZ01,,9999,,,,oPanel1,@aHeaderZ01,@aColsZ01)

	oItens:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oItens:oBrowse:SetBlkBackColor(bColor)
	oItens:oBrowse:SetBlkColor(bColorFont)
	oItens:bFieldOk := {|| SYZ00Horas(nOpc) }
	oItens:bChange  := {|| SYZ00Horas(nOpc) }
	oItens:bDelOk   := {|| SYZ00Horas(nOpc) }

	oItens:oBrowse:Refresh()


ElseIf(M->Z00_TPMOD == "1") //Modulo

	/*==================================================================
	PANEL DOS ITENS DOS MODULOS
	===================================================================*/

	oPanel1 := TPanel():New(	oSize:GetDimension("FOLDER","LININI"),;
								oSize:GetDimension("FOLDER","COLINI"),;
								'', oDlg, NIL, .T., .F., NIL,,;
								oSize:GetDimension("FOLDER","XSIZE"),;
								oSize:GetDimension("FOLDER","YSIZE"), .T., .F. )

	bColor 		:= &("{|| U_AF02CorBrw(@oItens,1) }")
	bColorFont	:= &("{|| U_AF02CorBrw(@oItens,2) }")

	oItens:= MsNewGetDados():New(0,0,0,0,IIF(nOpc == 2 .Or. nOpc == 5,0,nStyle),"U_AFZ00LinOk("+cValToChar(nOpc) + ")",,"+Z01_ORDEM",aCposAltZ01,,9999,,,,oPanel1,@aHeaderZ01,@aColsZ01)

	oItens:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oItens:oBrowse:SetBlkBackColor(bColor)
	oItens:oBrowse:SetBlkColor(bColorFont)
	oItens:bFieldOk := {|| SYZ00Horas(nOpc) }

	oItens:oBrowse:Refresh()
EndIf

	 
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| lOk := ( Obrigatorio(aGets,aTela) .And. IIf(M->Z00_TPMOD == "1" , oItens:TudoOk(),IIf(M->Z00_TPMOD == "2" ,oModulos:TudoOk(),.T.)) ) , IIF( lOk , oDlg:End() , .F. ) } , {|| oDlg:End() },,aButtons) )

IF ( lOk .And. nOpc != 2 )
	Processa({|| GravaDados(oItens,nOpc,oModulos) },"Aguarde...")
EndIF

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LoadaHeaderZ17 ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montas aHEader da Z17                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadZ17aHeader()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeaderZ17 a partir dos campos do SX3         	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeaderZ17:= GetAllFields('Z17')

/*
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z17')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z17' )
	
	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		
		IF !(Alltrim(SX3->X3_CAMPO) $ 'Z17_ESCOPO')
			Aadd( aCposAltZ17 , SX3->X3_CAMPO )
		EndIF
		
		AADD(aHeaderZ17,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo
*/
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LoadaHeaderZ01 ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montas aHEader da Z01                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadZ01aHeader()


aHeaderZ17:= GetAllFields('Z01')

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeaderZ01 a partir dos campos do SX3         	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z01')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z01' )
	
	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		
		IF !(Alltrim(SX3->X3_CAMPO) $ 'Z01_FUNCAO')
			Aadd( aCposAltZ01 , SX3->X3_CAMPO )
		EndIF
		
		AADD(aHeaderZ01,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo
*/
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LoadaColsZ17 ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montas aCols da Z17                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadZ17aCols(nOpc)
Local cQuery  := ""
Local aAreaZ00:= Z00->(GetArea())

IF nOpc == 3 //.Or. Len(aColsZ17) == 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria aCols auxiliares vazios.                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Aadd(aColsZ17,Array(Len(aHeaderZ17)+1))
	For nX := 1 To Len(aHeaderZ17)
		aColsZ17[Len(aColsZ17),nX] := CriaVar(aHeaderZ17[nX,2])
	Next nX
	aColsZ17[Len(aColsZ17),Len(aHeaderZ17)+1] := .F.
Else
	//Se for a opcao 2 = Oferta Primeiro verifica se ja tem os itens do modulo vinculado ao Oferta, se nao tiver traz os itens padroes do modulo.
	cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlName("Z17") + " Z17 "
	cQuery += " WHERE Z17_FILIAL 	= '" 	+ xFilial("Z18") 	+ "'"
	cQuery += " AND Z17_ESCOPO 		= '" 	+ M->Z00_MODULO  	+ "'"
	cQuery += " AND Z17.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY Z17_SEQ"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ17",.T.,.T.)

	DbSelectArea("TMPZ17")
	DbGoTop()
	While !Eof()
		
		DbSelectarea("Z17")
		DbGoto( TMPZ17->RECNO )
		
		Aadd(aColsZ17,Array(Len(aHeaderZ17)+1))
		For nX	:= 1 To Len(aHeaderZ17)
			IF ( aHeaderZ17[nX][10] != "V" )
				aColsZ17[Len(aColsZ17)][nX] := Z17->(FieldGet(FieldPos(aHeaderZ17[nX][2])))
			Else
				aColsZ17[Len(aColsZ17)][nX] := CriaVar(aHeaderZ17[nX][2])
			EndIF
		Next nX
		aColsZ17[Len(aColsZ17)][Len(aHeaderZ17)+1] := .F.
		
		//Carrega o aSavaCols se gravado anteriormente
		//Carrega o aSavCols com os dados do Z17
		aAdd(aSavaCols,{Z17->Z17_MODULO,{},Z17->Z17_SEQ})

		DbSelectarea("TMPZ17")
		DbSkip()
	EndDo

	TMPZ17->(DbCloseArea())
EndIf

RestArea(aAreaZ00)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LoadaColsZ01 ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montas aCols da Z01                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadZ01aCols(nOpc,lFirstLoad)
Local cQuery   := ""
Local nX       := 0
Local cMod     := ""
Local lEscopo  := .F.
Local cModZ00  := ""
Local lSobrepoe:= .F.
Local aArea    := GetArea()
Local aAreaZ00 := Z00->(GetArea())
Local nPModulo := aScan(aHeaderZ17,{|x| Alltrim(x[2]) == "Z17_MODULO"})
DEFAULT lFirstLoad:= .T.

//Limpa o aCols temporario
aColsZ01:= {}

//Verifica se existe o objeto dos modulos
IF (M->Z00_TPMOD == "1")
	cModZ00:= M->Z00_MODULO
//Se for a opcao 2 = Oferta Primeiro verifica se ja tem os itens do modulo vinculado ao Oferta, se nao tiver traz os itens padroes do modulo.
ElseIf (M->Z00_TPMOD == "2") .And. lFirstLoad .And. (nOpc <> 3)//Oferta de Projeto
	cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlName("Z18") + " Z18 "
	cQuery += " WHERE Z18_FILIAL 	= '" 	+ xFilial("Z18") 	+ "'"
	cQuery += " AND Z18_CODESC 		= '" 	+ M->Z00_MODULO  	+ "'"
	//cQuery += " AND Z18_MODULO 		= '" 	+ cModZ00  	+ "'"
	cQuery += " AND Z18.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY Z18_MODULO,Z18_ORDEM"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ18",.T.,.T.)
	
	DbSelectArea("TMPZ18")
	DbGoTop()
	While !Eof()
		
		DbSelectarea("Z18")
		DbGoto( TMPZ18->RECNO )
		
		//Atualiza o vetor de gravacao
		If (cMod <> Z18->Z18_MODULO) 
			If !Empty(cMod)
				nPos:= aScan(aSavaCols,{|x| x[1] == cMod})
				If (nPos > 0)
					aSavaCols[nPos,2]:= aColsZ01	
				Else
					Z17->(DbSetOrder(1))
					Z17->(DbSeek(xFilial("Z17")+M->Z00_MODULO+cMod))
					aAdd(aSavaCols,{cMod,aColsZ01,Z17->Z17_SEQ})
				EndIf
			EndIf	
			aColsZ01:= {}
			cMod    := Z18->Z18_MODULO
		EndIf

		Aadd(aColsZ01,Array(Len(aHeaderZ01)+1))
		For nX	:= 1 To Len(aHeaderZ01)
			IF AllTrim(aHeaderZ01[nX][2]) == "Z01_MEMO"
				aColsZ01[Len(aColsZ01)][nX] := MSMM(Z18->Z18_CODMEM)
			ElseIF ( aHeaderZ01[nX][10] != "V" )
				aColsZ01[Len(aColsZ01)][nX] := FieldGet(FieldPos("Z18" + SubString(aHeaderZ01[nX][2],4,Len(aHeaderZ01[nX][2]))))
			Else
				aColsZ01[Len(aColsZ01)][nX] := CriaVar(aHeaderZ01[nX][2])
			EndIF
		Next nX
		aColsZ01[Len(aColsZ01)][Len(aHeaderZ01)+1] := .F.

		DbSelectarea("TMPZ18")
		DbSkip()
		lEscopo:= .T.
		
	EndDo
	TMPZ18->(DbCloseArea())

	//Se terminou de ler a tabela armazena os ultimos registros no vetor
	If (Len(aColsZ01) > 0)
		nPos:= aScan(aSavaCols,{|x| x[1] == cMod})
		If (nPos > 0)
			aSavaCols[nPos,2]:= aColsZ01	
		Else
			Z17->(DbSetOrder(1))
			Z17->(DbSeek(xFilial("Z17")+M->Z00_MODULO+cMod))
			aAdd(aSavaCols,{cMod,aColsZ01,Z17->Z17_SEQ})
		EndIf
	EndIf

	If Type("oModulos") <> "U"
		cModZ00:= oModulos:aCols[oModulos:nAT,nPModulo]
	Else
		cModZ00:= aSavaCols[Len(aSavaCols),1]
	EndIf	
//Se for a opcao 2 = Oferta e estแ digitando o modulo novamente pergunta se deseja sobrepor o escopo.
ElseIf (ReadVar() == "M->Z17_MODULO") .And.(M->Z00_TPMOD == "2") .And. !lFirstLoad .And. (nOpc <> 3)//Oferta de Projeto
	cModZ00:= M->Z17_MODULO
	If Aviso("Atencao","Deseja sobrepor os itens do modulo " + cModZ00 + " ?",{"Sim","Nao"}) == 1
		lSobrepoe:= .T.
		aColsZ01:= {}		
	EndIf
Else
	If Type("oModulos") <> "U"
		cModZ00:= oModulos:aCols[oModulos:nAT,nPModulo]
	EndIf	
EndIf

//Verifica se jแ adicionou o vetor de gravacoes
nPos:= aScan(aSavaCols,{|x| x[1] == cModZ00})
If (nPos > 0) .And. !lSobrepoe
	aColsZ01:= aSavaCols[nPos,2]
ElseIf (!lEscopo .And. !Empty(cModZ00) .And. (Len(aColsZ01) == 0)) .Or. lSobrepoe
	aColsZ01:= {}

	cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlName("Z01") + " Z01 "
	cQuery += " WHERE Z01_FILIAL 	= '" 	+ xFilial("Z01") 	+ "'"
	cQuery += " AND Z01_MODULO 		= '" 	+ cModZ00  	+ "'"
	cQuery += " AND Z01.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY Z01_ORDEM"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ01",.T.,.T.)

	DbSelectArea("TMPZ01")
	DbGoTop()
	While !Eof()
		
		DbSelectarea("Z01")
		DbGoto( TMPZ01->RECNO )
		
		Aadd(aColsZ01,Array(Len(aHeaderZ01)+1))
		For nX	:= 1 To Len(aHeaderZ01)
			IF AllTrim(aHeaderZ01[nX][2]) == "Z01_MEMO"
				aColsZ01[Len(aColsZ01)][nX] := MSMM(Z01->Z01_CODMEM)
			ElseIF ( aHeaderZ01[nX][10] != "V" )
				aColsZ01[Len(aColsZ01)][nX] := Z01->(FieldGet(FieldPos(aHeaderZ01[nX][2])))
			Else
				aColsZ01[Len(aColsZ01)][nX] := CriaVar(aHeaderZ01[nX][2])
			EndIF
		Next nX
		aColsZ01[Len(aColsZ01)][Len(aHeaderZ01)+1] := .F.
		
		DbSelectarea("TMPZ01")
		DbSkip()
		
	EndDo
	TMPZ01->(DbCloseArea())

	nPos:= aScan(aSavaCols,{|x| x[1] == cModZ00})
	If (nPos == 0)
		Z00->(dbSetOrder(1))
		Z00->(DbSeek(xFilial("Z00")+cModZ00))
		aAdd(aSavaCols,{cModZ00,aColsZ01,Z00->Z00_SEQ})
	Else
		aSavaCols[nPos,2]:= aColsZ01
	EndIf
ElseIF (Len(aColsZ01) == 0)
	Aadd(aColsZ01,Array(Len(aHeaderZ01)+1))
	For nX	:= 1 To Len(aHeaderZ01)
		aColsZ01[Len(aColsZ01)][nX] := CriaVar(aHeaderZ01[nX][2])
	Next nX
	aColsZ01[Len(aColsZ01)][Len(aHeaderZ01)+1] := .F.
EndIf

RestArea(aAreaZ00)
RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AFZ00LinOk ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a LinhaOk                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AFZ00LinOk(nOpc)

Local lRet		:= .T.
Local nPEtapa  	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_ETAPA" })
Local nProces 	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_PROCES" })

IF M->Z00_TPPROD $ '4/5' // Valida somente quando o Oferta for Servicos

	IF Empty(oItens:aCols[oItens:nAt,nPEtapa])
		Help("",1,"Aten็ใo",,"Preencha o campo Etapa.",1,1)
		lRet := .F.
	
	ElseIF Empty(oItens:aCols[oItens:nAt,nProces])
		Help("",1,"Aten็ใo",,"Preencha o campo Processo.",1,1)
		lRet := .F.
	EndIF
	
	SYZ00Horas(nOpc)
	
EndIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ Z17LinOk บAutor  ณMicrosiga           บ Data ณ  27/09/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Linha dos Modulos pertencentes ao Oferta           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Z17LinOk(nOpc)

Local lRet		:= .T.
Local nPProdut  := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_PRODUT" })
Local nPModulo  := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_MODULO" })
Local nPSeq     := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_SEQ" })
Local nPos      := 0
Local nX        := 0
Local cProd     := Posicione("Z00",1,xFilial("Z00")+oModulos:aCols[oModulos:nAT,nPModulo],"Z00_PRODUT")

IF M->Z00_TPPROD $ '4/5' .And. (cProd <> M->Z00_PRODUT) // Valida somente quando o Oferta for Servicos

	Help("",1,"Aten็ใo",,"Este modulo nao pertence ao produto selecionado!.",1,1)
	lRet := .F.
	
Else
	//Verifica se os itens do modulo estao salvos
	nPos:= aScan(aSavaCols,{|x| x[1] == oModulos:aCols[oModulos:nAT,nPModulo] })
	If (nPos == 0)
		aAdd(aSavaCols,{oModulos:aCols[oModulos:nAT,nPModulo],oItens:aCols,oModulos:aCols[oModulos:nAT,nPSeq]})
		SYZ17Horas()
		
	ElseIf (nPos > 0 .And. aSavaCols[nPos,3] == oModulos:aCols[oModulos:nAT,nPSeq])
		aSavaCols[nPos,2]:= oItens:aCols
		SYZ17Horas()

	ElseIf (nPos > 0 .And. aSavaCols[nPos,3] <> oModulos:aCols[oModulos:nAT,nPSeq])
		Help("",1,"Aten็ใo",,"Este modulo ja faz parte do Escopo desta Oferta!.",1,1)
		lRet := .F.
	EndIf
EndIF


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ GRAVADADOS บAutor  ณMicrosiga           บ Data ณ  27/09/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados.                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaDados(oItens,nOpc,oModulos)

Local aArea	  := GetArea()
Local cQuery  := ''
Local nPMemo  := 0
Local nProces := 0
Local nX,nZ
Local cCampo  := ""

IF nOpc == 2
	
	RestArea(aArea)
	Return(.T.)
	
Else
	
	IF nOpc == 5
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Exclui.                      				 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("Z00")
		DbSetOrder(1)
		DbSeek(xFilial("Z00")+M->Z00_MODULO)
		While !Eof() .And. Z00->Z00_FILIAL + Z00->Z00_MODULO == xFilial("Z00")+M->Z00_MODULO
			RecLock("Z00",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		EndDo
	EndIF
	
	IF nOpc == 5 .Or. nOpc == 4
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Exclui/Altrar.                				 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Deleta os itens do Modulo
		DbSelectArea("Z01")
		DbSetOrder(1)
		DbSeek(xFilial("Z01")+M->Z00_MODULO)
		While !Eof() .And. Z01->Z01_FILIAL + Z01->Z01_MODULO == xFilial("Z01")+M->Z00_MODULO
			RecLock("Z01",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		EndDo

		//Deleta os Modulos do Oferta
		DbSelectArea("Z17")
		DbSetOrder(1)
		DbSeek(xFilial("Z17")+M->Z00_MODULO)
		While !Eof() .And. Z17->Z17_FILIAL + Z17->Z17_ESCOPO == xFilial("Z17")+M->Z00_MODULO
			RecLock("Z17",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		EndDo

		//Deleta os Itens do Modulos
		DbSelectArea("Z18")
		DbSetOrder(1)
		DbSeek(xFilial("Z18")+M->Z00_MODULO,.T.)
		While !Eof() .And. Z18->Z18_FILIAL + Z18->Z18_CODESC == xFilial("Z18")+M->Z00_MODULO
			RecLock("Z18",.F.)
			DbDelete()
			MsUnLock()
			DbSkip()
		EndDo
	EndIF
	
EndIF

IF ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inclui/Altrar.                				 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("Z00")
	DbSetOrder(1)
	IF DbSeek(xFilial("Z00")+M->Z00_MODULO)
		RecLock("Z00",.F.)
	Else
		RecLock("Z00",.T.)
	EndIF
	
	ProcRegua(Z00->(FCount()))
	For nX := 1 To Z00->(FCount())
		cCampo:= AllTrim(FieldName(nX))

		IncProc()
		
		If ("FILIAL" $ cCampo)
			Z00_FILIAL:= xFilial("Z00")
		ElseIf (FieldPos(cCampo) > 0)
			FieldPut(nX, &('M->' + cCampo))
		EndIF
		
	Next nX
	Z00_FILIAL	:= xFilial('Z00')
	MsUnLock()
	
	MSMM(Z00->Z00_CODM1,,,M->Z00_MEMO1,1,,,"Z00","Z00_CODM1")
	
	If Type("oItens") <> "U"

		nPMemo  := aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_MEMO" })
		nProces := aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_PROCES" })

		If (M->Z00_TPMOD == "2")
			ProcRegua(Len(aSavaCols))
			For nX := 1 To Len(aSavaCols)
				
				IncProc()
				
				For nY:= 1 To Len(aSavaCols[nX,2])
					IF !aSavaCols[nX,2,nY,Len(oItens:aHeader)+1]
						
						IF !Empty(aSavaCols[nX,2,nY,nProces])
							//Cadastro dos Itens dos Modulos x Oferta
							DbSelectArea('Z18')
							RecLock("Z18",.T.)
							For nZ := 1 To Len(oItens:aHeader)
								IF oItens:aHeader[nZ,10] <> "V"
									Z18->( FieldPut( FieldPos("Z18"+SubString(oItens:aHeader[nZ,2],4,Len(oItens:aHeader[nZ,2]))) , aSavaCols[nX,2,nY,nZ] ) )
								EndIF
							Next nZ
							Z18_FILIAL	:= xFilial('Z18')
							Z18_CODESC	:= M->Z00_MODULO
							Z18_MODULO	:= aSavaCols[nX,1]
							MsUnLock()                                      
							
							IF nPMemo > 0
								MSMM(Z18->Z18_CODMEM,,,aSavaCols[nX,2,nY,nPMemo],1,,,"Z18","Z18_CODMEM")
							EndIF
						EndIF
						
					EndIF
				Next nY				
			Next nX
		Else
			ProcRegua(Len(oItens:aCols))
			For nX := 1 To Len(oItens:aCols)
				
				IncProc()
				
				IF !oItens:aCols[nX,Len(oItens:aHeader)+1]
					
					IF !Empty(oItens:aCols[nX,nProces])
						DbSelectArea('Z01')
						RecLock("Z01",.T.)
						For nZ := 1 To Len(oItens:aHeader)
							IF oItens:aHeader[nZ,10] <> "V"
								Z01->( FieldPut( FieldPos(oItens:aHeader[nZ,2]) , oItens:aCols[nX,nZ] ) )
							EndIF
						Next nZ
						Z01_FILIAL	:= xFilial('Z01')
						Z01_MODULO	:= M->Z00_MODULO
						MsUnLock()                                      
						
						IF nPMemo > 0
							MSMM(Z01->Z01_CODMEM,,,oItens:aCols[nX,nPMemo],1,,,"Z01","Z01_CODMEM")
						EndIF
					EndIF
				EndIF
			Next nX
		EndIf	
	EndIf	

	If Type("oModulos") <> "U"
		ProcRegua(Len(oModulos:aCols))
		For nX := 1 To Len(oModulos:aCols)
			
			IncProc()
			
			IF !oModulos:aCols[nX,Len(oModulos:aHeader)+1]
				
				IF !Empty(oModulos:aCols[nX,nProces])
					
					DbSelectArea('Z17')
					RecLock("Z17",.T.)
					For nZ := 1 To Len(oModulos:aHeader)
						IF oModulos:aHeader[nZ,10] <> "V"
							Z17->( FieldPut( FieldPos(oModulos:aHeader[nZ,2]) , oModulos:aCols[nX,nZ] ) )
						EndIF
					Next nZ
					Z17_FILIAL	:= xFilial('Z17')
					Z17_ESCOPO	:= M->Z00_MODULO
					MsUnLock()                                      
					
				EndIF
				
			EndIF
			
		Next nX
	EndIf	
EndIF

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ NewCadModLeg บAutor  ณ Alexandro Dias  บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legendas do browse.                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function NewModLeg()

BrwLegenda(cCadastro,"Legenda" , { {"BR_VERDE","Liberado"} , {"BR_VERMELHO","Bloqueado"} })

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SYZ00HorasบAutor  ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma o total de horas do Oferta                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SYZ00Horas(nOpc)

Local nI      	:= 0
Local nX        := 0
Local nHoras  	:= 0
Local nPEscopo	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_ESCOPO" })
Local nPHoras 	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_HORAS" })
Local nPDias	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_DIAS" })
Local nPSeq		:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_ORDEM" })
Local nPDelete  := Len(oItens:aHeader) + 1
Local nPEtapa  	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_ETAPA" })
Local nPProces 	:= aScan(oItens:aHeader,{|x| Alltrim(x[2]) == "Z01_PROCES" })
Local nPModulo  := 0
Local nPHorasMod:= 0
Local nPCustoMod:= 0
Local nPTotalMod:= 0
Local cVar      := ReadVar()
Local nSavnAt   := 0

//Se for visualizar sai fora
If (nOpc == 2)
	Return(.T.)
EndIf

nSavnAt:= oItens:nAT
IF Type("oModulos") <> "U"
	nPHorasMod:= aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_HORAS" })
	nPCustoMod:= aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_CUSTO" })
	nPTotalMod:= aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_TOTAL" })
	nPModulo  := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_MODULO" })
	cModZ00   := oModulos:aCols[oModulos:nAt,nPModulo]
Else
	cModZ00:= M->Z00_MODULO
EndIf

//Ajusta a linha

If (cVar == "M->Z01_ESCOPO")
	If (M->Z01_ESCOPO == "1") .And. (oItens:aCols[oItens:nAt,nPDias] == 0)
		oItens:aCols[oItens:nAt,nPDias] := 1
		oItens:aCols[oItens:nAt,nPHoras]:= 10
	ElseIf(M->Z01_ESCOPO == "2") // Nao faz parte do escopo
		oItens:aCols[oItens:nAt,nPDias] := 0
		oItens:aCols[oItens:nAt,nPHoras]:= 0
	EndIf	
	oItens:aCols[oItens:nAt,nPEscopo]:= M->Z01_ESCOPO
ElseIF (cVar == "M->Z01_DIAS")
	oItens:aCols[oItens:nAt,nPDias] := M->Z01_DIAS
	oItens:aCols[oItens:nAt,nPHoras]:= M->Z01_DIAS * 10
ElseIF (cVar == "M->Z01_HORAS")
	oItens:aCols[oItens:nAt,nPDias] := M->Z01_HORAS / 10
	oItens:aCols[oItens:nAt,nPHoras]:= M->Z01_HORAS
ElseIF (cVar == "M->Z01_ORDEM")
	nPos:= aScan(oItens:aCols,{|x| x[nPSeq] == M->Z01_ORDEM})
	If (nPos > 0)
		Aviso("Atencao","A sequencia informada jแ existe.Favor informar novo codigo de sequencia.",{"OK"})
		Return(.F.)
	EndIf
	
	//Ordena o vetor
	cEtapa := oItens:aCols[oItens:nAt,nPEtapa]
	cProces:= oItens:aCols[oItens:nAt,nPProces]

	oItens:aCols[oItens:nAt,nPSeq]:= M->Z01_ORDEM
	oItens:aCols:= aSort(oItens:aCols,,,{|x,y| IIf(x[nPDelete],'x','')+x[nPSeq] < IIf(y[nPDelete],'x','')+y[nPSeq] })

	nPos:= aScan(oItens:aCols,{|x| x[nPEtapa] == cEtapa .And. x[nPProces] == cProces })
	If (nPos > 0)
		oItens:nAT:= nPos
		oItens:oBrowse:nAT:= nPos
		oItens:oBrowse:Refresh()
	EndIf

EndIf

nHoras:= 0
For nI:= 1 To Len(oItens:aCols) 

	IF oItens:aCols[nI,Len(oItens:aHeader)+1] == .F.

		If (oItens:aCols[nI,nPEscopo] == "1")
			nHoras+= oItens:aCols[nI,nPHoras]
		Else
			nHoras+= 0
		EndIf	
	EndIF		

Next nI

If Type("oModulos") <> "U"
	oModulos:aCols[oModulos:nAt,nPHorasMod]:= nHoras
	oModulos:aCols[oModulos:nAt,nPTotalMod]:= nHoras * oModulos:aCols[oModulos:nAt,nPCustoMod]
	oModulos:Refresh()
	SYZ17Horas()
Else
	M->Z00_HORAS := nHoras
	oEnchoice:Refresh()
EndIf

//Atualiza o vetor de gravacao
nPos:= aScan(aSavaCols,{|x| x[1] == cModZ00})
If (nPos > 0)
	aSavaCols[nPos,2]:= oItens:aCols
EndIf	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SYZ17Horas  บAutor  ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma o total de horas do Oferta                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SYZ17Horas()

Local nI      	:= 0
Local nX        := 0
Local nHoras  	:= 0
Local nPHoras 	:= aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_HORAS" })
Local nPModulo  := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_MODULO" })
Local nItem     := oModulos:nAt
Local nPos      := 0

For nI:= 1 To Len(oModulos:aCols) 

	IF oModulos:aCols[nI,Len(oModulos:aHeader)+1] == .F.
		If ReadVar() == "M->Z17_HORAS" .And. (nI == nItem)
			nHoras+= M->Z17_HORAS
		ElseIf ReadVar() == "M->Z17_MODULO" .And. (nI == nItem)
			nHoras+= Z00->Z00_HORAS
		Else	
			nHoras+= oModulos:aCols[nI,nPHoras]
		EndIf	
	EndIF		

Next nI

M->Z00_HORAS := nHoras
oEnchoice:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SYZ17Del  บAutor  ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Soma o total de horas do Oferta                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SYZ17Del()

Local nPModulo  := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_MODULO" })
Local nItem     := oModulos:nAt
Local nPos      := 0

IF oModulos:aCols[nItem,Len(oModulos:aHeader)+1] == .F.

	nPos:= aScan(aSavaCols,{|x| x[1] == oModulos:aCols[nItem,nPModulo]})
	If (nPos > 0) .And. (nItem == nPos)
		aDel(aSavaCols,nPos)
		aSize(aSavaCols,nPos)
	EndIf

	oModulos:aCols[nItem,Len(oModulos:aHeader)+1]:= .T.
EndIF

SYZ17Horas()
oModulos:aCols[nItem,Len(oModulos:aHeader)+1]:= .F.

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MontaZ01  ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montas Accols da Z01                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaZ01(aColsZ01,aHeaderZ01,cModZ00,aCposAltZ01,nOpc)
Local aArea    := GetArea()
Local lDeleted := .F.
Local lEscopo  := .F.
Local lSobrepoe:= .F.
Local aSavZ17  := {}
Local nPModulo := 0
Local nPSeq    := 0
Local cSeq     := ""
Local nPos     := 0
Local nSavnAT  := 0
Local cVar     := ReadVar()

DEFAULT cModZ00:= ""

aColsZ01  := {}
aHeaderZ01:= {}

//Verifica se esta usando a tela com o modo de OFERTA
If Type("oModulos") <> "U"
	nPModulo:= aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_MODULO" })
	nPSeq   := aScan(oModulos:aHeader,{|x| Alltrim(x[2]) == "Z17_SEQ" })

	//Verifica qual o modulo atual
	cModZ00 := oModulos:aCols[oModulos:nAt,nPModulo]
	lDeleted:= oModulos:aCols[oModulos:nAt,Len(oModulos:aHeader)+1]

	//Salva a posicao atual e o aCols atual
	nSavnAT:= oModulos:nAt
	aSavZ17:= oModulos:aCols
EndIf

//Ajusta a Sequencia
If (cVar == "M->Z17_SEQ")

	//Pega a sequencia atual
	cSeq:= &(cVar)
	
	//Tenta verificar se 'e um numero e nao tem outros caracteres
	If Val(cSeq) == 0
		Aviso("Atencao","Sequencia invalida! Informe apenas numeros como codigo de sequencia.",{"Ok"})
		Return(.F.)
	EndIf

	//Verifica se a sequencia ja existe
	nPos:= aScan(aSavZ17,{|x| x[nPSeq] == cSeq})
	If (nPos > 0) .And. (nPos <> nSavnAt)
		//Aviso("Atencao","Esta sequencia ja foi informada! Informe outro numero de sequencia.",{"Ok"})
		//Return(.F.)
	EndIf

	//Atualiza a sequencia
	aSavZ17[nSavnAt,nPSeq]:= cSeq
	
	//Ordena o vetor
	aSavZ17:= aSort(aSavZ17,,,{|x,y| x[nPSeq] < y[nPSeq] })

	//Pesquisa qual a posicao em que ficou a sequencia
	nPos  := aScan(aSavZ17,{|x| x[nPModulo] == cModZ00})

	//Atualiza o acols na tela
	oModulos:aCols   := aSavZ17
	oModulos:nAT     := nPos

	nPosSv:= aScan(aSavaCols,{|x| x[1] == cModZ00})
	If (nPosSv > 0)
		aSavaCols[nPosSv,3]:= cSeq
	EndIf	

	//Limpa o retorno para nao ficar atualizando a sequencia errada pois o acols foi alterado a ordem dos registros
	//M->Z17_SEQ:= Space(Len(Z17->Z17_SEQ)) 

ElseIf (cVar == "M->Z17_MODULO")
	cModZ00:= M->Z17_MODULO

	//Se o acols ja estiver preenchido pergunta se deseja sobrepor o Escopo
	If !Empty(oModulos:aCols[oModulos:nAt,nPModulo])
		If Aviso("Atencao","Deseja SOBREPOR as funcionalidades pelo Escopo Padrao do Modulo?",{"Nao","Sim"}) == 2
			lSobrepoe:= .T.
		EndIf	
	EndIf	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeaderZ01 a partir dos campos do SX3         	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z01')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z01' )
	
	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		
		IF !(Alltrim(SX3->X3_CAMPO) $ 'Z01_FUNCAO')
			Aadd( aCposAltZ01 , SX3->X3_CAMPO )
		EndIF
		
		AADD(aHeaderZ01,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, "", SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

//Atualiza o vetor de gravacao

If Type("oItens") <> "U"
	oItens:aHeader:= aHeaderZ01
	oItens:aCols  := aColsZ01
	oItens:oBrowse:Refresh()

	SYZ17Horas()
EndIf	

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Z00FILTRO  บAutor  ณ Fabio Rogerio       บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o filtro dos modulos dependendo do software               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Z00FILTRO()

Local cFiltroZ00 := ''

//Servicos TOTVS
IF M->Z02_TIPO == "1"
	cFiltroZ00:= "Z00->Z00_TIPO == '1'"
	
	//Service Desk TOTVS
ElseIF M->Z02_TIPO == "2"
	cFiltroZ00:= "Z00->Z00_TIPO == '2'"
	
	//SAP Cloud
ElseIF M->Z02_TIPO == "3"
	cFiltroZ00:= "Z00->Z00_TPPROD $ '013'"
	
	//SAP OnPremise
ElseIF M->Z02_TIPO == "4"
	cFiltroZ00:= "Z00->Z00_TPPROD $ '23'"
	
	//SAP Servicos
ElseIF M->Z02_TIPO == "5"
	cFiltroZ00:= "Z00->Z00_TIPO == '5'"
	
	//SAP Service Desk
ElseIF M->Z02_TIPO == "6"
	cFiltroZ00:= "Z00->Z00_TIPO == '6'"
	
	//MiniProposta SAP
ElseIF M->Z02_TIPO == "7"
	cFiltroZ00:= "Z00->Z00_TIPO == '5'"
	
	//TOTVS Licenciamento
ElseIF M->Z02_TIPO == "8"
	cFiltroZ00:= "Z00->Z00_TPPROD $ '013'"

	//MiniProposta TOTVS
ElseIF M->Z02_TIPO == "0"
	cFiltroZ00:= "Z00->Z00_TIPO == '1'"

EndIF

If !Empty(cFiltroZ00)
	cFiltroZ00+= " .AND. "
EndIf

cFiltroZ00 += "Z00->Z00_TPMOD  <> '2' " //Nao carrega o codigo de ofertas, somente dos modulos
cFiltroZ00 += ".AND. Z00->Z00_LIBERA == '1' "

Return ( &(cFiltroZ00) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AtuItens ณ Fabio Rogerio   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o acols do itens                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuItens()

If Type("oItens") <> "U"
	oItens:aCols:= aColsZ01
	oItens:oBrowse:Refresh()
EndIf

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณU_Z17FieldOK   บAutor  ณFabio Rogerio       บ Data ณ  12/10/2020บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Tratar Gatilhos e Validacoes da Z17            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Z17FieldOk(cVar,nOpc)

Local aArea			:= GetArea()
Local nPSeq  	    := 0
Local nPModulo  	:= 0
Local nPHoras       := 0
Local nSavnAT       := 0
Local cSeq          := ""
Local nSeq          := 0
Local nHoras        := 0
Local lRet          := .T.
DEFAULT cVar        := ReadVar()

//Se a variavel de memoria estiver vazia nao faz nada
If Type("aHeaderZ17") == "U"
	Return(.T.)
EndIF

//Se a variavel de memoria estiver vazia nao faz nada
If Empty(cVar) .Or. ValType(cVar) == "U"
	Return(.T.)
EndIF

nPSeq  	    	:= aScan(aHeaderZ17,{|x| AllTrim(x[2]) == "Z17_SEQ"})
nPModulo  		:= aScan(aHeaderZ17,{|x| AllTrim(x[2]) == "Z17_MODULO"})
nPHoras  		:= aScan(aHeaderZ17,{|x| AllTrim(x[2]) == "Z17_HORAS"})

//Se o modulo nao tiver sido informado nao faz nada.
If Empty(oModulos:aCols[oModulos:nAT,nPModulo]) .And. Empty(M->Z17_MODULO)
	Return(.F.)
EndIF

//Salva os itens do acols pois serแ reconstruido
aSavZ17:= oModulos:aCols
nSavnAT:= oModulos:nAt

//Posiciona no cadastro do modulo/licenca selecionado para buscar os valores, custo etc.
IF ('M->Z17_MODULO' == cVar)
	cModulo:= &(cVar) 
	aSavZ17[nSavnAT,nPModulo]:= cModulo

	Z00->(dbSetOrder(1))
	Z00->(dbSeek(xFilial("Z00")+cModulo))

	//Atualiza as variaveis com o conteudo do cadastro
	cSeq        := Z00->Z00_SEQ
	nHoras      := Z00->Z00_HORAS

	//Atualiza para o novo codigo de sequencia e reordena o vetor para atualizar o acols
	aSavZ17[nSavnAt,nPSeq]:= cSeq
	aSavZ17:= aSort(aSavZ17,,,{|x,y| x[nPSeq] < y[nPSeq] })

	LoadZ01aCols(nOpc,.F.)

Else

	//Pega os valores atuais que estao no Acols
	cModulo		 := oModulos:aCols[oModulos:nAt,nPModulo]
	cSeq         := oModulos:aCols[oModulos:nAt,nPSeq]
	nHoras		 := oModulos:aCols[oModulos:nAt,nPHoras]
EndIf	

//Verifica se a chamada partiu do campo de Ordem (Sequencia)
IF ( 'M->Z17_SEQ' == cVar )	
	cSeq:= &(cVar)
	
	//Verifica se a sequencia ja existe
	nPos:= aScan(aSavZ17,{|x| x[1] == cSeq})
	If (nPos > 0) .And. (nPos <> nSavnAT)
		//Aviso("Atencao","Esta sequencia ja foi informada! Informe outro numero de sequencia.",{"Ok"})
		//Return(.F.)
	EndIf

	//Tenta verificar se 'e um numero e nao tem outros caracteres
	If Val(cSeq) == 0
		Aviso("Atencao","Sequencia invalida! Informe apenas numeros como codigo de sequencia.",{"Ok"})
		Return(.F.)
	EndIf

	//Atualiza para o novo codigo de sequencia e reordena o vetor para atualizar o acols
	aSavZ17[nSavnAt,nPSeq]:= cSeq
	aSavZ17:= aSort(aSavZ17,,,{|x,y| x[nPSeq] < y[nPSeq] })

EndIF

//Atualiza o Acols que sera utilizado para a gravacao
For nX:= 1 To Len(aSavZ17)
	nPos:= aScan(aSavaCols,{|x| x[1] == aSavZ17[nX,nPModulo]})
	If (nPos > 0)
		aSavaCols[nPos,3]:= aSavZ17[nX,nPSeq]
	EndIf
Next nX

//Verifica qual a nova posicao no vetor
nPos:= aScan(aSavZ17,{|x| x[nPModulo] == cModulo})
If (nPos == 0)
	nPos:= 1
EndIf	

//Atualiza o acols na tela
oModulos:aCols:= aSavZ17
oModulos:nAT  := nPos

//Atualiza os campos de sequencia de execucao para compatibilidade com licencas e outros servicos de unica sequencia
oModulos:aCols[oModulos:nAt,nPSeq]   := cSeq
oModulos:aCols[oModulos:nAt,nPHoras] := nHoras

//Retorna na posicao original
oModulos:nAT  := nSavnAt
oModulos:oBrowse:Refresh()


RestArea(aArea)

Return(lRet)



Static Function AjustaOrdem()

dbSelectArea("Z01")
cAliasZ01 := "Z01"
cIndexZ01 := CriaTrab(nil,.f.)
cChaveZ01 := "Z01_FILIAL+Z01_MODULO+Z01_FASE+Z01_ETAPA+Z01_PROCES"

IndRegua(cAliasZ01,cIndexZ01,cChaveZ01,,"","Selecionando Registros")
nIndexZ01 := RetIndex("Z01")
dbSelectArea(cAliasZ01)
dbSetOrder(nIndexZ01+1)
dbGoTop()


cModulo:= ""
While !Eof() 
	nRec:= Recno()	

	If (cModulo <> Z01->Z01_MODULO)
		cModulo:= Z01->Z01_MODULO
		nOrdem:= 0
	EndIf	

	nOrdem++
	RecLock("Z01",.F.)
	Replace Z01_ORDEM With StrZero(nOrdem,2)
	MsUnLock()

	dbSelectArea("Z01")
	dbGoTo(nRec)
	dbSkip()
End
Ferase(cIndexZ01+GetDBExtension())



dbSelectArea("Z17")
dbSetOrder(1)
dbSeek(xFilial("Z17"),.T.)

cModulo:= ""
While !Eof() 
	
	If (cModulo <> Z17->Z17_ESCOPO)
		cModulo:= Z17->Z17_ESCOPO
		nOrdem:= 0
	EndIf	

	nOrdem++
	RecLock("Z17",.F.)
	Replace Z17_SEQ With StrZero(nOrdem,3)
	MsUnLock()


	dbSelectArea("Z17")
	dbSkip()
End


dbSelectArea("Z18")
cAliasZ01 := "Z18"
cIndexZ01 := CriaTrab(nil,.f.)
cChaveZ01 := "Z18_FILIAL+Z18_CODESC+Z18_MODULO+Z18_FASE+Z18_ETAPA+Z18_PROCES"

IndRegua(cAliasZ01,cIndexZ01,cChaveZ01,,"","Selecionando Registros")
nIndexZ01 := RetIndex("Z18")
dbSelectArea(cAliasZ01)
dbSetOrder(nIndexZ01+1)
dbGoTop()

cModulo:= ""
cCodEsc:= ""
While !Eof() 

	If (cCodEsc <> Z18->Z18_CODESC)
		cModulo:= ''
		cCodEsc:= Z18->Z18_CODESC
	EndIf	

	If (cModulo <> Z18->Z18_MODULO)
		cModulo:= Z18->Z18_MODULO
		nOrdem:= 0
	EndIf	

	nOrdem++
	RecLock("Z18",.F.)
	Replace Z18_ORDEM With StrZero(nOrdem,2)
	MsUnLock()

	dbSelectArea("Z18")
	dbSkip()
End
Ferase(cIndexZ01+GetDBExtension())


dbSelectArea("Z03")
cAliasZ01 := "Z03"
cIndexZ01 := CriaTrab(nil,.f.)
cChaveZ01 := "Z03_FILIAL+Z03_PROPOS+Z03_ADITIV+Z03_MODULO+Z03_NITEM"

IndRegua(cAliasZ01,cIndexZ01,cChaveZ01,,"","Selecionando Registros")
nIndexZ01 := RetIndex("Z03")
dbSelectArea(cAliasZ01)
dbSetOrder(nIndexZ01+1)
dbGoTop()

cPropos:= ""
cModulo:= ""
cAditiv:= ""
While !Eof() 

	If (cPropos + cAditiv <> Z03->Z03_PROPOS + Z03->Z03_ADITIV)
		cPropos:= Z03->Z03_PROPOS
		cAditiv:= Z03->Z03_ADITIV
		cModulo:= ''
	EndIf	

	If (cModulo <> Z03->Z03_MODULO)
		cModulo:= Z03->Z03_MODULO
		cOrdem:= "00"
	EndIf	

	cOrdem:= Soma1(cOrdem,2)
	RecLock("Z03",.F.)
	Replace Z03_ORDEM With cOrdem
	MsUnLock()


	dbSelectArea("Z03")
	dbSkip()
End
Ferase(cIndexZ01+GetDBExtension())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณU_Z00PRODUT   บAutor  ณFabio Rogerio    บ Data ณ  02/03/2021บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilho do Campo Produto           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Z00PRODUT()
Local cRet:= ""

//Verifica o produto a alimenta os outros campos

//Escopo de Modulo
IF (M->Z00_TPMOD == "1")

	//TOTVS
	IF(M->Z00_PRODUT == "1")
		M->Z00_TIPO  := "1"		//Tipo da Proposta - TOTVS Servicos
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAOA"//Fornecedor - ALFA
		M->Z00_MOD   := "3"     //Servico 
		M->Z00_TPPROD:= "5"     //Tipo Produto (TOTVS Servicos)
		cRet:= "5"
	//SAP
	Else
		M->Z00_TIPO  := "5"		//Tipo da Proposta - SAP Servicos
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAOA"//Fornecedor - ALFA
		M->Z00_MOD   := "3"     //Servico 
		M->Z00_TPPROD:= "4"     //Tipo Produto (SAP Servicos)
		cRet:= "4"
	EndIF
		
//Escopo de Oferta
ElseIf (M->Z00_TPMOD == "2")
	//TOTVS
	IF(M->Z00_PRODUT == "1")
		M->Z00_TIPO  := "1"		//Tipo da Proposta - TOTVS Servicos
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAOA"//Fornecedor - ALFA
		M->Z00_MOD   := "3"     //Servico 
		M->Z00_TPPROD:= "5"     //Tipo Produto (TOTVS Servicos)
		cRet:= "5"
	//SAP
	Else
		M->Z00_TIPO  := "5"		//Tipo da Proposta - SAP Servicos
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAOA"//Fornecedor - ALFA
		M->Z00_MOD   := "3"     //Servico 
		M->Z00_TPPROD:= "4"     //Tipo Produto (SAP Servicos)
		cRet:= "4"
	EndIF
//Licenca
Else
	//TOTVS
	IF(M->Z00_PRODUT == "1")
		M->Z00_TIPO  := "1"		//Tipo da Proposta - TOTVS Servicos
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAOA"//Fornecedor - ALFA
		M->Z00_MOD   := "3"     //Servico 
		M->Z00_TPPROD:= "5"     //Tipo Produto (TOTVS Servicos)
		cRet:= "5"
	//SAP
	Else
		M->Z00_TIPO  := "3"		//Tipo da Proposta - SAP Licencas (Saas)
		M->Z00_TPSERV:= "1"		//Tipo Servico - Consultoria
		M->Z00_IMPESC:= "1"     //Imprime Escopo - Sim
		M->Z00_FORNEC:= "FOPAJZ"//Fornecedor - SAP
		M->Z00_MOD   := "1"     //Licenca
		M->Z00_TPPROD:= "1"     //Tipo Produto (SAP SaaS)
		cRet:= "1"
	EndIF
EndIf

Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFModCorBrwบ Autor ณ Fabio Rogerio      บ Data ณ  22/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cores da linha do browser do escopo.						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function AFModCorBrw(oBrw)
Local nI:= 0

IF oBrw:aCols[oBrw:nAt,Len(oBrw:aHeader)+1]
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cinza quando Deletado.  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Return(Rgb(181,181,181))

Else



	Return(Rgb(255,255,0))	
//	Else							// Cor da Fonte - Preto
//		Return(Rgb(0,0,0))	
//	EndIF
EndIF

Return(Rgb(255,255,255))
