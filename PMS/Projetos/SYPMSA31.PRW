#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4
#Define MAXGETDAD 99999
#Define MAXSAVERESULT 999

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYPMSA31  ºAutor  ³Fabio Rogerio       º Data ³  04/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para aprovacao Ordens de Serviço Symm.               º±±                           
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                             

User Function SYPMSA31()

Local aArea			:= GetArea()
Local aGroups   	:= AllGroups()
Local cGrp		 	:= ''

Local nX        	:= 0
Local aCoord    	:= {}
Local nPos      	:= 0
Local nPosCoord 	:= 0
Local cMsg      	:= ""
Local aParambox		:= {}
Local aRetParam		:= {}

Private aHeaderOS   := {}
Private aColsOS     := {}
Private aHeaderItens:= {}
Private aColsItens  := {}
Private cObservacoes:= ""
Private oAtividade
Private aStatus	 	 := {,,,,,,,}
Private cCoord    	 := ""
Private lCoord      := .F.
Private lPMO	     := .F.
Private lDir		 := .F.
Private lAdm	     := .F.
Private lConsultor	 := .F.
Private  dDataIni	 := FirstDay(dDatabase)
Private dDataFim	 := LastDay(dDatabase)
Private cRecurso	 := ""
Private cCliente	 := ""
Private cLoja    	 := ""
Private oOk			 := LoadBitmap(GetResources(), "BR_VERDE")  
Private oPr		     := LoadBitmap(GetResources(), "BR_VERMELHO")
Private o40			 := LoadBitmap(GetResources(), "BR_AZUL")  
Private o70			 := LoadBitmap(GetResources(), "BR_AMARELO")  
Private oHr			 := LoadBitmap(GetResources(), "BR_PINK")
Private oBl			 := LoadBitmap(GetResources(), "BR_PRETO" )
Private oAb			 := LoadBitmap(GetResources(), "BR_BRANCO" )
Private oAv			 := LoadBitmap(GetResources(), "BR_LARANJA" )
Private oSy			 := LoadBitmap(GetResources(), "BR_MARROM" )
Private oEn			 := LoadBitmap(GetResources(), "BR_CINZA" )
Private oAd			 := LoadBitmap(GetResources(), "BPMSEDT1" )
Private oOk			 := LoadBitmap(GetResources(), "LBOK")
Private oNo			 := LoadBitmap(GetResources(), "LBNO")

DbSelectArea("AE8")
DbSetOrder(3)
IF DbSeek(xFilial("AE8")+__cUserID)
	IF AE8->AE8_EQUIPE $ "4" 			//Coordenacao
		lCoord := .T.
		cCoord := AE8->AE8_RECURS 
	ElseIF AE8->AE8_EQUIPE $ "6" 		//Diretoria
		lDir   := .T.
		lAdm   := .T.
		cCoord := AE8->AE8_RECURS 
	ElseIF AE8->AE8_EQUIPE == "7" 		//pmo
		lAdm   := .T.
		lPMO := .T.
	EndIF 
EndIF

If lCoord
	Aadd(aParamBox,{1,"Coordenador" , cCoord  , ""   , "", "", "", 50 , .T.})
Else
	Aadd(aParamBox,{1,"Coordenador" , Space(100)  , ""   , "", "SYCOOR", "", 50 , .T.})
EndIf
	
aAdd(aParamBox,{1,"Data Inicial"	, FirstDay(dDatabase)		,PesqPict("SE1", "E1_VENCREA") 	, "(MV_PAR02 >= dDatabase - 180)", "", "", 50 , .F.})
aAdd(aParamBox,{1,"Data Final"  	, LastDay(dDatabase) 		,PesqPict("SE1", "E1_VENCREA") 	, "(MV_PAR03 >= MV_PAR02)", "", "", 50 , .F.})
aAdd(aParamBox,{1,"Consultor"		, CriaVar("AE8_RECURSO",.F.),PesqPict("AE8","AE8_RECURSO")	,""	,"AE8","",100,.F.})
aAdd(aParamBox,{1,"Cliente"			, CriaVar("A1_COD",.F.) 	,PesqPict("SA1","A1_COD")		,""	,"SA1","",100,.T.})


IF !ParamBox(aParamBox,"Informe os Dados para Filtro",@aRetParam)
	Return
Endif

If !lCoord
	cCoord  := aRetParam[1]
EndIf
	
dDataIni:= FirstDay(aRetParam[2])
dDataFim:= LastDay(aRetParam[3])
cRecurso:= aRetParam[4]
cCliente:= aRetParam[5]

LjMsgRun("Aguarde, Filtrando Ordens de Serviço..."	,,{|| A31ShowOS() })


RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A31ShowOS ºAutor  ³Fabio Rogerio       º Data ³  05/04/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe OS para Manutencao                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A31ShowOS()

Local aSize     	:= MsAdvSize()
Local nStyle    	:= GD_INSERT+GD_UPDATE+GD_DELETE
Local oDlg 
Local oTimer
Local aButtons     := {}
Local nPosStatus   := 0
Local cOS          := ""
Local nOpc			:= 0
Local cProjeto     := CriaVar("AF8_PROJET",.F.)
Local cTarefa      := CriaVar("AF9_TAREFA",.F.)
Local cDescPrj     := CriaVar("AF8_DESCRI",.F.)
Local cDescTrf     := CriaVar("AF9_DESCRI",.F.)
Local cRevisa      := CriaVar("AF9_REVISA",.F.)
Local aAlter	    := {'AF8_PRJNEW'}
Private oGetOS

aStatus[1] := LoadBitmap(GetResources(), "SYESTRELA.JPG")	// Pago
aStatus[2] := LoadBitmap(GetResources(), "BR_PINK" 		)	// Pendente
aStatus[3] := LoadBitmap(GetResources(), "BR_AMARELO"	)	// Encerrada
aStatus[4] := LoadBitmap(GetResources(), "BR_AZUL"		)	// Validada
aStatus[5] := LoadBitmap(GetResources(), "BR_MARROM"	)	// Entregue
aStatus[6] := LoadBitmap(GetResources(), "BR_VERDE"		)	// Aprovada Cliente
aStatus[7] := LoadBitmap(GetResources(), "BR_PRETO"		)	// Reprovada Cliente
aStatus[8] := LoadBitmap(GetResources(), "BR_VERMELHO"	)	// Reprovada Coorden

LjMsgRun("Aguarde, Filtrando Ordens de Serviço..."	,,{||SYOSACOLS(cCoord,dDataIni,dDataFim,cRecurso,cCliente) })

IF Len(aColsOs) == 0
	Aviso("Atencao","Nao hã dados!",{"Ok"})
	Return(.T.)
EndIf

//Monta a Tela de Aprovação
DEFINE FONT oObsTohoma	NAME "Courier New" SIZE 0,-16 BOLD                                

DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] TITLE "Manutencao em Ordem de Servico" Of oMainWnd PIXEL STYLE DS_MODALFRAME 

oDlg:lEscClose := .F.
oDlg:lMaximized := .T.

oPanDlg:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPanDlg:Align:= CONTROL_ALIGN_ALLCLIENT

oFwLayer := FwLayer():New()
oFwLayer:Init(oPanDlg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Linha 1 - Cab.OS        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFWLayer:addLine("LINHA1",010, .F.)
oFWLayer:addCollumn("COL1"	,100, .F. , "LINHA1")
oFWLayer:addWindow( "COL1", "oPanel1", "Dados"			,100, .T., .F., , "LINHA1")
oPanel1	:= oFWLayer:GetWinPanel("COL1", "oPanel1","LINHA1")

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + cCliente,.F.))
cLoja:= SA1->A1_LOJA

@ 05,010 SAY "Cliente" of oPanel1  PIXEL SIZE 100,20

//Cliente
If lCoord
	@ 05,030 MSGET cCliente SIZE 50,10 OF oPanel1 PIXEL WHEN .F.
	AtuVariaveis(1)
Else
	@ 05,030 MSGET cCliente SIZE 50,10 OF oPanel1 PIXEL F3 "SYMOS1" VALID !Empty(cCliente) .And. AtuVariaveis(1)
EndIf 
@ 05,080 MSGET SA1->A1_LOJA SIZE 30,10 OF oPanel1 PIXEL WHEN .F.
@ 05,100 MSGET SA1->A1_NOME SIZE 150,10 OF oPanel1 PIXEL WHEN .F.

/*
//Projeto / Tarefa
@ 25,010 SAY "Projeto" of oPanel1  PIXEL SIZE 100,20
@ 25,030 MSGET cProjeto SIZE 050,10 OF oPanel1 PIXEL F3 "SYMPR2" VALID !Empty(cProjeto) .And. AtuVariaveis(2,@cProjeto,@cDescPrj,@cTarefa,@cDescTrf,@cRevisa)
@ 25,080 MSGET cRevisa  SIZE 050,10 OF oPanel1 PIXEL WHEN .F.
@ 25,140 MSGET cDescPrj SIZE 150,10 OF oPanel1 PIXEL WHEN .F.

@ 45,010 SAY "Tarefa" of oPanel1  PIXEL SIZE 100,20
@ 45,030 MSGET cTarefa  SIZE 50,10 OF oPanel1 PIXEL WHEN .F.
@ 45,080 MSGET cDescTrf SIZE 150,10 OF oPanel1 PIXEL WHEN .F.
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ OS                                       					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFWLayer:addLine("LINHA2",090, .F.)
oFWLayer:addCollumn("COL1",100, .T. , "LINHA2")
oFWLayer:addWindow("COL1", "oPanel2", "Ordens de Serviço" 	,100, .T., .F.,  {|| oGetOS:Refresh(),oGetOS:oWnd:Refresh() }	, "LINHA2")
oPanel2	:= oFWLayer:GetWinPanel("COL1", "oPanel2","LINHA2")

nPosStatus:= aScan(aHeaderOS,{|x| AllTrim(x[2]) == "Z2_STATUS"})

oGetOS:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanel2,aHeaderOS,aColsOS)
oGetOS:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
oGetOS:oBrowse:bHeaderClick	:= { |oObj,nCol| U_SyOrdCab(nCol,@oGetOS,@nlOrdemCols),Eval(oGetOS:oBrowse:bLDblClick) }
//oGetOS:oBrowse:bLDblClick	:= { || SyDblClick(@oGetOS,@aColsOS,aHeaderOS) }
 
ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| (aColsOS:= oGetOS:aCols, oDlg:End(),nOpc:=1) } , {|| (oDlg:End(),nOpc:=2) }) ) 

If (nOpc == 1) 
	If Aviso("Atencao","Confirma a troca de projeto e tarefas?",{"Sim","Nao"})==1
		LjMsgRun("Aguarde, Gravando dados..."	,,{|| A31Grava(aColsOS,aHeaderOS,cCliente,cProjeto,cTarefa,cRevisa) })
	EndIf	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AtuVariaveis  ³ Autor ³   Fabio Rogerio   ³ Data ³ 16/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Variaveis.		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuVariaveis(nTipo,cProjeto,cDescPrj,cTarefa,cDescTrf,cRevisa)

DEFAULT nTipo   := 1
DEFAULT cDescPrj:= ""
DEFAULT cTarefa := ""
DEFAULT cDescTrf:= ""
DEFAULT cRevisa := ""

Do Case
	Case (nTipo == 1)
		cLoja   := SA1->A1_LOJA
		cProjeto:= CriaVar("AF8_PROJET",.F.)
		cDescPrj:= CriaVar("AF8_DESCRI",.F.)
		cTarefa := CriaVar("AF9_TAREFA",.F.)
		cDescTrf:= CriaVar("AF9_DESCRI",.F.)
		cRevisa := CriaVar("AF9_REVISA",.F.)

	Case (nTipo == 2)
		cProjeto:= AF8->AF8_PROJET
		cRevisa := AF8->AF8_REVISA
		cDescPrj:= AF8->AF8_DESCRI
		U_SYTRF(cProjeto,@cTarefa,@cDescTrf)
		
EndCase

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  SyDblClick  ³ Autor ³   Fabio Rogerio   ³ Data ³ 16/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Duplo Click.		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyDblClick(oGetOS,aColsOS,aHeaderOS)

If !aColsOS[oGetOS:nAt,Len(aHeaderOS)]
	aColsOS[oGetOS:nAt,1]:= oOk
	aColsOS[oGetOS:nAt,Len(aHeaderOS)]:= .T.
Else
	aColsOS[oGetOS:nAt,1]:= oNo
	aColsOS[oGetOS:nAt,Len(aHeaderOS)]:= .F.
EndIf	

oGetOS:aCols:= aColsOS
oGetOS:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYOSACOLS ºAutor  ³Microsiga           º Data ³  05/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SYOSACOLS(cCoord,dDataIni,dDataFim,cRecurso,cCliente) 

Local aArea       := GetArea()
Local lRet		  := .T.							//Retorno da funcao
Local nPos        := 0
Local nX          := 1
Local nOS         := 0
Local cQryTmp     := ''
Local aCamposSZ2  := {}
Local aCamposSZ3  := {}
Local nCntFor     := 0
Local oOk   	   := LoadBitmap( GetResources(), "LBOK")
Local oNo         := LoadBitmap( GetResources(), "LBNO")

Default cCoord	:= ""
Default dDataIni:= FirstDay(dDatabase)
Default dDataFim:= LastDay(dDatabase)
Default cRecurso:= ""
Default cCliente:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader a partir dos campos do SX3         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCamposSZ2 := { 'AF8_PROJET','Z2_DATA','Z2_OS','AE8_DESCRI','Z2_CLIENTE',;
				'Z2_TOTALHR','Z2_HRINI1','Z2_HRFIM1','Z2_HRINI2','Z2_HRFIM2',;
				'Z2_HABONO','Z2_HUTEIS','Z2_TPATEND','Z2_STATUS'}

aHeaderOS:= {}

Aadd(aHeaderOS,{"","Z2_OK"	,"@BMP"	,02	,0,".F.","û","C",""	," " } )
Aadd(aHeaderOS,{"Projeto(Novo)"	,"AF8_PRJNEW"	,"@!"	,10	,0,"U_AtuDsc(1)","û","C","SYMPR2"	," " } )
Aadd(aHeaderOS,{"Descricao"		,"AF8_DESCNEW"	,"@!"	,30	,0,".F.","û","C",""	," " } )
Aadd(aHeaderOS,{"Tarefa(Nova)"	,"AF9_TRFNEW"	,"@!"	,10 ,0,"U_AtuDsc(2)","û","C",""	," " } )
Aadd(aHeaderOS,{"Descricao"		,"AF9_DESCNEW"	,"@!"	,30	,0,".F.","û","C",""	," " } )

DbSelectArea("SX3")
DbSetorder(2)
For nX := 1 To Len(aCamposSZ2)
	
	MsSeek(aCamposSZ2[nX])
	
	Aadd(aHeaderOS,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
	SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

Next
Aadd(aHeaderOS,{"","LOK","",02	,0,".F.","û","C",""	," " } )


//Verifica as OS do projeto
cQryTmp := " SELECT RIGHT(AF8_PROJET,4)+'-'+RTRIM(AF8_DESCRI) AS AF8_PROJET,RTRIM(AF9_TAREFA)+'-'+RTRIM(AF9_DESCRI) AS AF9_DESCRI,Z2_DATA,Z2_OS,RTRIM(Z2_RECURSO)+'-'+RTRIM(AE8_DESCRI) AS AE8_DESCRI,RTRIM(Z2_CLIENTE)+'-'+RTRIM(A1_NREDUZ) AS Z2_CLIENTE,Z2_TOTALHR,Z2_HRINI1,Z2_HRFIM1,Z2_HRINI2,Z2_HRFIM2,Z2_HABONO,Z2_HUTEIS,Z2_TPATEND,Z2_STATUS,SZ2.R_E_C_N_O_ as Z2RECNO"
cQryTmp += " FROM " + RetSqlName("SZ2") + " SZ2," + RetSqlName("SZ3") + " SZ3, " + RetSqlName("AF8") + " AF8 , " + RetSqlName("AE8") + " AE8 , " + RetSqlName("AF9") + " AF9 , " + RetSqlName("SA1") + " SA1 "
cQryTmp += " WHERE SZ2.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   SZ3.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   AF8.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   AF9.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   AE8.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   SA1.D_E_L_E_T_ <> '*' "
cQryTmp += " AND   SZ2.Z2_FILIAL   = '"  + xFilial("SZ2") + "'"
cQryTmp += " AND   SZ3.Z3_FILIAL   = '"  + xFilial("SZ3") + "'"
cQryTmp += " AND   AE8.AE8_FILIAL  = '"  + xFilial("AE8") + "'"
cQryTmp += " AND   SA1.A1_FILIAL   = '"  + xFilial("SA1") + "'"
cQryTmp += " AND   AF8.AF8_FILIAL  = '"  + xFilial("AF8") + "'"
cQryTmp += " AND   AF9.AF9_FILIAL  = '"  + xFilial("AF9") + "'"
cQryTmp += " AND   SZ2.Z2_RECURSO  = AE8.AE8_RECURS "
cQryTmp += " AND   SZ2.Z2_OS       = SZ3.Z3_OS "
cQryTmp += " AND   SZ3.Z3_PROJETO  = AF8.AF8_PROJET "
cQryTmp += " AND   AF8.AF8_PROJET  = AF9.AF9_PROJET "
cQryTmp += " AND   AF8.AF8_REVISA  = AF9.AF9_REVISA "
cQryTmp += " AND   SZ3.Z3_TAREFA   = AF9.AF9_TAREFA "
cQryTmp += " AND   SZ2.Z2_DATA BETWEEN '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "'"

If !Empty(cCliente)
	cQryTmp += " AND   SZ2.Z2_CLIENTE  =  '" + cCliente + "'"
EndIf
cQryTmp += " AND   SZ2.Z2_CLIENTE  = SA1.A1_COD "

If !Empty(cRecurso)
	cQryTmp += " AND   SZ2.Z2_RECURSO  =  '" + cRecurso + "'"
EndIf

If !Empty(cCoord)
	cQryTmp += " AND   AF8.AF8_COORD   =  '"  + cCoord + "'"
EndIf
	
cQryTmp += " ORDER BY AF8_COORD,Z2_CLIENTE,AF8_PROJET,Z2_DATA,Z2_RECURSO"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)

aStru:= SZ2->(dbStruct())
aEval(aStru, {|e| If(e[2] != "C", TCSetField("TMP", e[1], e[2],e[3],e[4]),Nil)})

DbSelectArea("TMP")
DbGoTop()
While !TMP->(Eof())
	
	SZ2->(dbGoTo(TMP->Z2RECNO))

	Aadd(aColsOS,Array(Len(aHeaderOS)+1))
	
	For nCntFor	:= 1 To Len(aHeaderOS)
		
		If AllTrim(aHeaderOS[nCntFor,2]) == "Z2_OK"
			aColsOS[Len(aColsOS),nCntFor] := oNo
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "AF8_PROJET"
			aHeaderOS[nCntFor,4] := 30
			aColsOS[Len(aColsOS),nCntFor] := TMP->( FieldGet(FieldPos(aHeaderOS[nCntFor,2])) )
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "AF8_PRJNEW"
			aColsOS[Len(aColsOS),nCntFor] := CriaVar("AF8_PROJET",.F.)
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "AF8_DESCNEW"
			aColsOS[Len(aColsOS),nCntFor] := CriaVar("AF8_DESCRI",.F.)
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "AF9_TRFNEW"
			aColsOS[Len(aColsOS),nCntFor] := CriaVar("AF9_TAREFA",.F.)
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "AF9_DESCNEW"
			aColsOS[Len(aColsOS),nCntFor] := CriaVar("AF9_DESCRI",.F.)
		ElseIF AllTrim(aHeaderOS[nCntFor,2]) == "LOK"
			aColsOS[Len(aColsOS),nCntFor] := .F.
		ElseIF ( aHeaderOS[nCntFor,10] != "V" )
			aColsOS[Len(aColsOS),nCntFor] := TMP->( FieldGet(FieldPos(aHeaderOS[nCntFor,2])) )
		Else
			aColsOS[Len(aColsOS),nCntFor] := CriaVar(aHeaderOS[nCntFor,2])
		EndIF
	Next nCntFor
	
	aColsOS[Len(aColsOS),Len(aHeaderOS)]   := .F.
	aColsOS[Len(aColsOS),Len(aHeaderOS)+1] := .F.

	DbSelectArea("TMP")
	DbSkip()
	
EndDo

DbSelectArea("TMP")
DbCloseArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array com 1 elemento vazio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
IF Len(aColsOS) <= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao, Monta o Array com 1 elemento vazio		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd(aColsOS,Array(Len(aHeaderOS)+1))
	For nX := 1 To Len(aHeaderOS)
		If AllTrim(aHeaderOS[nX,2]) == "Z2_OK"
			aColsOS[1,nX] := oNo
		ElseIF AllTrim(aHeaderOS[nX,2]) == "AF8_PRJNEW"
			aHeaderOS[nX,4] := 30 // Tamanho do Campo
			aColsOS[Len(aColsOS),nX] := CriaVar("AF8_PROJET",.F.)
		ElseIF AllTrim(aHeaderOS[nX,2]) == "AF8_DESCNEW"
			aHeaderOS[nX,4] := 30 // Tamanho do Campo
			aColsOS[Len(aColsOS),nX] := CriaVar("AF8_DESCRI",.F.)
		ElseIF AllTrim(aHeaderOS[nX,2]) == "AF9_TRFNEW"
			aHeaderOS[nX,4] := 30 // Tamanho do Campo
			aColsOS[Len(aColsOS),nX] := CriaVar("AF9_TAREFA",.F.)
		ElseIF AllTrim(aHeaderOS[nX,2]) == "AF9_DESCNEW"
			aHeaderOS[nX,4] := 30 // Tamanho do Campo
			aColsOS[Len(aColsOS),nX] := CriaVar("AF9_DESCRI",.F.)
		ElseIF AllTrim(aHeaderOS[nX,2]) == "LOK"
			aColsOS[Len(aColsOS),nX] := .F.
		Else
			aColsOS[1,nX] := CriaVar(aHeaderOS[nX,2],.F.)															
		EndIf	
	Next nX
	aColsOS[1,Len(aHeaderOS)]   := .F.
	aColsOS[1,Len(aHeaderOS)+1] := .F.
EndIF


RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYPRJ2    ºAutor  ³Microsiga           º Data ³  05/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SYPRJ2()
Local cPerg	:= PADR("SYPMSC01",10)

Pergunte(cPerg,.F.)

MV_PAR01:= cRecurso
MV_PAR02:= Space(TamSX3("AF8_PROJET")[1])
MV_PAR03:= Replicate("Z",TamSX3("AF8_PROJET")[1])
MV_PAR04:= cCliente
MV_PAR05:= cLoja
MV_PAR06:= cCliente
MV_PAR07:= cLoja
MV_PAR08:= 1 //Ativo
MV_PAR09:= Space(TamSX3("AA5_CODSER")[1])	
MV_PAR10:= Replicate("Z",TamSX3("AA5_CODSER")[1])
MV_PAR11:= 3 // Ambos

U_SYPRJREC(cCliente,cLoja,cRecurso)

cProjeto:= AF8->AF8_PROJET

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYTRF     ºAutor  ³Fabio Rogerio       º Data ³  02/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para selecionar a tarefa do projeto                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYTRF(cProjeto,cTarefa,cDescTrf)

Local aArea		:= GetArea()
Local aHeadPRJ	:= {}
Local aColsPrj	:= {}
Local nPrj		:= 0
Local aSaldo	:= {0,0,0,0,0}
Local nStyle	:= 0
Local oOk		:= LoadBitmap(GetResources(), "BR_VERDE")   
Local oPr		:= LoadBitmap(GetResources(), "BR_AMARELO")
Local oNo		:= LoadBitmap(GetResources(), "BR_VERMEHO")
Local cQuery     
Local oDlg
Local oPrj
LOcal cRevisa:= ""

Aadd(aHeadPRJ,{""						,"FLAG"		,"@BMP"  			,03	,0,".F.","û","C",""	," " } ) 
Aadd(aHeadPRJ,{"EDT"					,"EDT"		,"@!"				,TamSX3("AFC_EDT")[1]		,0,".F.","û","C",""	," " } )
Aadd(aHeadPRJ,{"Descricao EDT"			,"DESCEDT"	,"@S20!"			,TamSX3("AFC_DESCRI")[1]	,0,".F.","û","C",""	," " } )
Aadd(aHeadPRJ,{"Tarefa"       			,"TAREFA"	,"@!"    			,TamSX3("AF9_TAREFA")[1]	,0,".F.","û","C",""	," " } )
Aadd(aHeadPRJ,{"Descricao da Tarefa"   	,"DESCTRF"	,"@S40!"   			,TamSX3("AF9_DESCRI")[1]	,0,".F.","û","C",""	," " } )
Aadd(aHeadPRJ,{"Horas Tarefa"			,"HUTEIS"	,"@E 99,999.99"    	,TamSX3("AF9_HUTEIS")[1]	,2,".F.","û","N",""	," " } )
Aadd(aHeadPRJ,{"Realizado"				,"REAL"		,"@E 99,999.99"    	,TamSX3("AF9_HUTEIS")[1]	,2,".F.","û","N",""	," " } )
Aadd(aHeadPRJ,{"Abono"					,"ABONO"	,"@E 99,999.99"    	,TamSX3("AF9_HUTEIS")[1]	,2,".F.","û","N",""	," " } )
Aadd(aHeadPRJ,{"Saldo"					,"SALDO"	,"@E 99,999.99"    	,TamSX3("AF9_HUTEIS")[1]	,2,".F.","û","N",""	," " } )

AF8->(dbSetOrder(1))
AF8->(dbSeek(xFilial("AF8")+cProjeto))
cRevisa:= AF8->AF8_REVISA

cQuery := " SELECT "
cQuery += "		AF9_PROJET , AF9_REVISA , AFC_EDT , AFC_DESCRI , AF9_TAREFA , AF9_DESCRI , AF9_HUTEIS "
cQuery += " FROM "
cQuery += 		RetSqlName("AFC") + " AFC , " + RetSqlName("AF9") + " AF9 (NOLOCK)"
cQuery += " WHERE "
cQuery += " 	AFC_FILIAL		= '" + xFilial("AFC") + "' AND "
cQuery += "		AFC_PROJET 		= AF9_PROJET 	AND "
cQuery += "		AFC_REVISA 		= AF9_REVISA 	AND "
cQuery += "		AFC_EDT 		= AF9_EDTPAI 	AND "
cQuery += "		AF9.D_E_L_E_T_  = ''  			AND "
cQuery += " 	AF9_FILIAL	 	= '" + xFilial("AF9") + "' AND "
cQuery += "		AFC_PROJET 		= '" + AF8->AF8_PROJET	+ "' AND "
cQuery += "		AFC_REVISA 		= '" + AF8->AF8_REVISA 	+ "' "
cQuery += " ORDER BY AF9_PROJET, AF9_REVISA , AFC_EDT "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRF",.T.,.T.)

DbSelectArea("TRF")
DbGoTop()
While !Eof()
	
	cProjeto := TRF->AF9_PROJET+' - Revisão: '+TRF->AF9_REVISA
	aSaldo	 := U_SYSaldoTarefa( TRF->AF9_PROJET , TRF->AF9_TAREFA , TRF->AF9_HUTEIS)

	Aadd( aColsPrj , { 	IIF ( aSaldo[4] <= 0 , oNo , IF ( ((aSaldo[2]/TRF->AF9_HUTEIS)*100) >= 75 , oPr , oOk ) ) ,;
						TRF->AFC_EDT ,;
						TRF->AFC_DESCRI,;
						TRF->AF9_TAREFA,;
						TRF->AF9_DESCRI,;
						aSaldo[1],;
						aSaldo[2],;
						aSaldo[3],;
						aSaldo[4], .F. } )


	DbSelectArea("TRF")
	DbSkip()
EndDo
TRF->(DbCloseArea())

IF (Len(aColsPrj) == 0)
	Help("",1,"Atenção",,"Não existem Tarefas para este Projetos.",1,1)
	RestArea(aArea)
	Return(.T.)
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO 400,960 TITLE "Tarefas do Projetos: "+cProjeto Of oMainWnd PIXEL

oPanel1				:= TPanel():New(0, 0, '', oDlg, NIL, .T., .F., NIL,, 0,0, .T., .F. )
oPanel1:Align		:= CONTROL_ALIGN_ALLCLIENT

oPrj:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",,,,,,,oPanel1,aHeadPRJ,aColsPrj)
oPrj:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg, {|| nPrj:= 1,oDlg:End() } , {|| nPrj:= 0,oDlg:End() }) ) CENTERED

IF (nPrj <> 0)
	cTarefa := oPrj:aCols[oPrj:nAt,aScan(oPrj:aHeader,{|x| Alltrim(x[2]) == "TAREFA" })]
	cDescTrf:= oPrj:aCols[oPrj:nAt,aScan(oPrj:aHeader,{|x| Alltrim(x[2]) == "DESCTRF" })]

	AF9->(dbSetOrder(1))
	AF9->(dbSeek(xFilial("AF9")+cProjeto+cRevisa+cTarefa))
Else

	cTarefa := CriaVar("AF9_PROJET",.F.)
	cDescTrf:= CriaVar("AF9_DESCRI",.F.)

EndIF

RestArea(aArea)

Return(.T.)                                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A31Grava  ºAutor  ³Fabio Rogerio       º Data ³  02/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para selecionar a tarefa do projeto                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A31Grava(aColsOS,aHeaderOS,cCliente,cProjeto,cTarefa,cRevisa)
Local nI      := 0
Local nPOS    := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "Z2_OS"})
Local nPPrj   := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF8_PRJNEW"})
Local nPTrf   := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF9_TRFNEW"})

For nI:= 1 To Len(aColsOS)
	If aColsOS[nI,Len(aHeaderOS)]
	
		AF8->(dbSetOrder(1))
		AF8->(dbSeek(xFilial("AF8")+aColsOS[nI,nPPrj]))
	
		dbSelectArea("SZ2")
		dbSetOrder(1)
		If dbSeek(xFilial("SZ2")+aColsOS[nI,nPOS],.T.) .And. (SZ2->Z2_CLIENTE <> cCliente)
			RecLock("SZ2",.F.)
			Replace Z2_CLIENTE  With cCliente
			MsUnlock()
		EndIf
	
		dbSelectArea("SZ3")
		dbSetOrder(1)
		dbSeek(xFilial("SZ3")+aColsOS[nI,nPOS],.T.)
		While !Eof() .And. (xFilial("SZ3")+aColsOS[nI,nPOS] == SZ3->Z3_FILIAL+SZ3->Z3_OS)
			RecLock("SZ3",.F.)
			Replace Z3_PROJETO With aColsOS[nI,nPPrj]//cProjeto 
			Replace Z3_REVISA  With AF8->AF8_REVISA//cRevisa
			Replace Z3_TAREFA  With aColsOS[nI,nPTrf]//cTarefa
			Replace Z3_CODSER  With AF8->AF8_TPSERV
			MsUnlock()
			
			
			dbSelectArea("SZ3")
			dbSkip()
		End
	EndIf
Next nI

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuDsc    ºAutor  ³Fabio Rogerio       º Data ³  02/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para atualizar descricoes			                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AtuDsc()
Local nPPrj   := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF8_PRJNEW"})
Local nPTrf   := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF9_TRFNEW"})
Local nPDsc1  := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF8_DESCNEW"})
Local nPDsc2  := aScan(aHeaderOS,{|x| AllTrim(x[2]) == "AF9_DESCNEW"})
Local cTarefa := ""
Local cDescTrf:= ""

If !Empty(M->AF8_PRJNEW)
	AF8->(dbSetOrder(1))
	AF8->(dbSeek(xFilial("AF8")+M->AF8_PRJNEW))

	aColsOS[oGetOS:nAt,nPPrj] := AF8->AF8_PROJET
	aColsOS[oGetOS:nAt,nPDsc1]:= AF8->AF8_DESCRI

	U_SYTRF(AF8->AF8_PROJET,@cTarefa,@cDescTrf)
	
	M->AF9_TAREFA:= cTarefa
	M->AF9_DESCRI:= cDescTrf
	
	aColsOS[oGetOS:nAt,nPTrf] := cTarefa
	aColsOS[oGetOS:nAt,nPDsc2]:= cDescTrf

	aColsOS[oGetOS:nAt,1]:= oOk
	aColsOS[oGetOS:nAt,Len(aHeaderOS)]:= .T.
Else
	aColsOS[oGetOS:nAt,nPPrj] := CriaVar("AF8_PROJET",.F.)
	aColsOS[oGetOS:nAt,nPDsc1]:= CriaVar("AF8_DESCRI",.F.)
	aColsOS[oGetOS:nAt,nPTrf] := CriaVar("AF9_TAREFA",.F.)
	aColsOS[oGetOS:nAt,nPDsc2]:= CriaVar("AF9_DESCRI",.F.)

	aColsOS[oGetOS:nAt,1]:= oNo
	aColsOS[oGetOS:nAt,Len(aHeaderOS)]:= .F.

EndIf
oGetOS:aCols:= aColsOS
oGetOS:oBrowse:Refresh()

Return(.T.)