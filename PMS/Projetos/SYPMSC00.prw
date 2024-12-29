#Include "Protheus.ch"                                                      
#Include "topconn.ch" 
#INCLUDE "APWIZARD.CH" 

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SYPMSC00 ³ Autor ³ Cris Barroso         ³ Data ³27/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Portal de Projetos SYMM                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  SYMM                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SYPMSC00()

Local cPerg			:= "SYPMSC01"

Private lPMO		:= .F.
Private lDiretoria	:= .F. 
Private lAdm		:= .F.
Private cCodUsuario	:= RetCodUsr()
Private oOk     := LoadBitmap(GetResources(), "BR_VERDE")  
Private oPr  	:= LoadBitmap(GetResources(), "BR_VERMELHO")
Private o40     := LoadBitmap(GetResources(), "BR_AZUL")  
Private o70     := LoadBitmap(GetResources(), "BR_AMARELO")  
Private oHr    	:= LoadBitmap(GetResources(), "BR_PINK")
Private oBl     := LoadBitmap(GetResources(), "BR_PRETO" )
Private oAb     := LoadBitmap(GetResources(), "BR_BRANCO" )
Private oAv     := LoadBitmap(GetResources(), "BR_LARANJA" )
Private oSy     := LoadBitmap(GetResources(), "BR_MARROM" )
Private oEn     := LoadBitmap(GetResources(), "BR_CINZA" )
Private oAd     := LoadBitmap(GetResources(), "BPMSEDT1" )

Private a100FWCharts	:= Array(4)
Private cCodCoord   := ""
Private oFWLayer := FWLayer():New()

IF ( __cUserID $ "000000|000026|000147|000270|000301|000456|" )// 000270 usuário Lucas Leopoldo em base teste

	lDiretoria 	:= .T.
	lAdm		:= .T.

Else

	DbSelectArea("AE8")
	DbSetOrder(3)
	IF DbSeek(xFilial("AE8")+__cUserID)

		IF AE8->AE8_EQUIPE == "4" 			//Coordenacao
	
			cCodCoord := AE8->AE8_RECURS
			lPMO := .F.
	
		ElseIF AE8->AE8_EQUIPE == "7" .Or. AE8->AE8_EQUIPE == "5" //PMO  COMERCIAL
	
			lPMO := .T.
	
		Else
	
			Help("",1,"Atenção",,"Você não tem permissão para usar esta rotina.",1,1)
			Return(.F.)
	
		EndIF

	Else

		Help("",1,"Atenção",,"Você não tem permissão para usar esta rotina.",1,1)
		Return(.F.)
    
    EndIF

EndIF

nCount:= ncountHr := ncountPr := ncountTf := ncountOk := ncount40 := ncount70 := nCountAv:= nCountAb:= ncountBl:= nCountSy := nCountEn:= nCountAd:= 0 
PutSx1( cPerg ,"01","Do Coordenador         ","","","mv_ch1","C",06,0,1,"G","","SYCOOR","","","mv_par01","","","","","","","","","","","","","","","","",{"Coordenador" },{},{})
PutSx1( cPerg ,"02","Do Projeto             ","","","mv_ch2","C",10,0,1,"G","","AF8","","","mv_par02","","","","","","","","","","","","","","","","",{"Projeto inicial" },{},{})
PutSx1( cPerg ,"03","Ate o Projeto          ","","","mv_ch3","C",10,0,1,"G","","AF8","","","mv_par03","","","","","","","","","","","","","","","","",{"Projeto final" },{},{})
PutSx1( cPerg ,"04","Do Cliente             ","","","mv_ch4","C",06,0,1,"G","","SA1","","","mv_par04","","","","","","","","","","","","","","","","",{"Cliente inicial" },{},{})
PutSx1( cPerg ,"05","Da Loja                ","","","mv_ch5","C",02,0,1,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","",{"Loja inicial" },{},{})
PutSx1( cPerg ,"06","Ate o Cliente          ","","","mv_ch6","C",06,0,1,"G","","SA1","","","mv_par06","","","","","","","","","","","","","","","","",{"Cliente final" },{},{})
PutSx1( cPerg ,"07","Da Loja                ","","","mv_ch7","C",02,0,1,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","",{"Loja final" },{},{})
PutSx1( cPerg ,"08","Status Projetos        ","","","mv_ch8","N",01,0,1,"C","","","","","mv_par08","Ativos","Ativos","Ativos","Encerrados","Encerrados","Encerrados","Ambos","Ambos","Ambos","","","","","","","",{"Status de Projeto" },{},{})
PutSx1( cPerg ,"09","Do Tipo Serviço        ","","","mv_ch9","C",06,0,1,"G","","AA501","","","mv_par09","","","","","","","","","","","","","","","","",{"Serviço inicial" },{},{})
PutSx1( cPerg ,"10","Ate Tipo Serviço       ","","","mv_chA","C",06,0,1,"G","","AA501","","","mv_par10","","","","","","","","","","","","","","","","",{"Serviço final" },{},{})
PutSx1( cPerg ,"11","Projetos Bloqueados    ","","","mv_chB","N",01,0,1,"C","","","","","mv_par11","Bloqueados","Bloqueados","Bloqueados","Liberados","Liberados","Liberados","Ambos","Ambos","Ambos","Bloqueado Para Auditoria","Bloqueado Para Auditoria","Bloqueado Para Auditoria","","","","",{"Status de Projeto" },{},{})

If !Empty(cCodCoord)
	Pergunte(cPerg,.T.)
	
	//Se quem estiver acessando for coordenador já carrega todos os projetos em aberto
	MV_PAR01:= cCodCoord
/*	MV_PAR02:= Space(TamSX3("AF8_PROJET")[1])
	MV_PAR03:= Replicate("Z",TamSX3("AF8_PROJET")[1])
	MV_PAR04:= Space(TamSX3("A1_COD")[1])                
	MV_PAR05:= Space(TamSX3("A1_LOJA")[1])
	MV_PAR06:= Replicate("Z",TamSX3("A1_COD")[1])
	MV_PAR07:= Replicate("Z",TamSX3("A1_LOJA")[1])
	MV_PAR08:= 1 //Ativo
	MV_PAR09:= Space(TamSX3("AA5_CODSER")[1])
	MV_PAR10:= Replicate("Z",TamSX3("AA5_CODSER")[1])
	MV_PAR11:= 3 //Ambos [Bloqueados = Sim/Nao/Ambos]
*/	
Else
	IF !Pergunte(cPerg,.T.)
		Return	
	EndIf
Endif

SYPMSProc()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SYPMSProc ³ Autor ³ CrisBarroso          ³ Data ³28/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o Painel de Projetos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SYPMSProc()

Local nStyle 		:= 2
Local aAlter		:= {}
Local aButtons		:= {}
Local aAlias 		:= GetArea()
Local oTelaPRJ
Local oPanel1
Local oPanel2  
Local oPanelInd
Local nCoordY		:= 0
Local nCoordX		:= 0
Local nWidth 		:= 0
Local nHeight   	:= 0
Local aSize    		:= MsAdvSize()
Local cMesAtu 		:= Left( Dtos(FirstDay(dDataBase)) 	, 6 )
Local cMesAnt 		:= Left( Dtos(FirstDay(dDataBase)-1) , 6 )
Local aStatus 		:= { {'1','Pendente'},{'2','Encerrada'},{'3','Validada'},{'4','Entregue'},{'5','Aprovada Cliente'},{'6','Reprovada Cliente'},{'7','Reprovada Coordenador'} }
Local aMeses		:= {'Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'}
Local aMetas		:= {'Meta','Hrs. Realizado','Hrs. Abonadas'}
Local aResult		:= {}

Local aColsPRJ	 := {}
Local aHeadPRJ 	 := {}

Local aColsOkPRJ := {}
Local aHeadOkPRJ := {}
Local aColsPrPRJ := {}
Local aHeadPrPRJ := {}
Local aCols40PRJ := {}
Local aHead40PRJ := {}
Local aCols70PRJ := {}
Local aHead70PRJ := {}
Local aColsBlPRJ := {}
Local aHeadBlPRJ := {}
Local aColsHrPRJ := {}
Local aHeadHrPRJ := {}
Local aColsAvulso:= {}
Local aHeadAvulso:= {}
Local aColsAberto:= {}
Local aHeadAberto:= {}
Local aColsSymm  := {}
Local aHeadSymm  := {}
Local aColsEn    := {}
Local aHeadEn    := {}

Local aDados   := {}
Local cSimba   := ""
Local cSimbb   := "" 
Local cImg     := ""
Local cHint    := ""

Private oPrj 
Private oPrjOk
Private oPrjPr
Private oPrj40
Private oPrj70
Private oPrjBl
Private oPrjHr
Private oPrjAvulso
Private oPrjAberto
Private oPrjSymm     
Private oPrjEn     
Private aObjPrj:= {}

Private oFnt 
Private oFnt2
Private oFnt3

Private oTitPrjHr
Private oTitPrjPr
Private oTitPrj70
Private oTitPrj40
Private oTitPrjOk
Private oTitPrjBl
Private oTitPrjAvulso
Private oTitPrjAberto
Private oTitPrjSymm
Private oTitPrjEn
Private oFolder

Private oPanelPrj
Private oPanelHr
Private oPanelPr
Private oPanel70
Private oPanel40
Private oPanelOk
Private oPanelBl
Private oPanelAv
Private oPanelAb
Private oPanelSy

Private oMemoPrj
Private oMemoHr
Private oMemoPr
Private oMemo70
Private oMemo40
Private oMemoOk
Private oMemoBl
Private oMemoAv
Private oMemoAb
Private oMemoSy
Private oMemoEn

Private cMemoPrj := ""
Private cMemoHr  := ""
Private cMemoPr  := ""
Private cMemo70  := ""
Private cMemo40  := ""
Private cMemoOk  := ""
Private cMemoBl  := ""
Private cMemoAv  := ""
Private cMemoAb  := ""
Private cMemoSy  := ""
Private cMemoEn  := ""

Private cCliente  := ""
Private cPrjAtras := ""
Private cPrjEmDia := ""
Private cPrjAten  := ""
Private cTrfAtras := ""
Private cTrfEmDia := ""
Private cTrfAten  := ""

Private cTipo    := GetMv("MV_SYDASH",,"P") //Visualização P-percentual ou V-valor

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

nCor1 := RGB(255,255,255)  
nCor2 := RGB(155,193,209)  
nCor3 := RGB(255,254,212)  
nCor4 := RGB(130,153,166)

DEFINE FONT oFnt 		NAME "Courier New" SIZE 0,-14 BOLD
DEFINE FONT oFnt2 		NAME "Courier New" SIZE 0,-18 BOLD
DEFINE FONT oFnt3 		NAME "Courier New" SIZE 0,-16 BOLD  
DEFINE FONT oObsTohoma	NAME "Courier New" SIZE 0,-16 BOLD                                

Aadd(aButtons  , { "S4WB009N"	 	, {|| U_SYPMSA23() }  																, "Agenda"						} )  
Aadd(aButtons  , { "PRECO"	 		, {|| U_SYMMZ02()  }		  														, "Proposta"					} ) 
Aadd(aButtons  , { "NOTE"   	 	, {|| U_SYPMSA01() }      															, "Ordens de Serviço"			} ) 
Aadd(aButtons  , { "RELATORIO"    	, {|| U_SYPMSR03() } 																, "Rel.Faturamento"				} ) 
Aadd(aButtons  , { "IMPRESSAO" 	 	, {|| U_SYPMSR01() }      															, "OSs Impressão"				} ) 
Aadd(aButtons  , { "HISTORIC"  	 	, {|| U_SYFATR04() }      															, "OSs Extrato"					} ) 
Aadd(aButtons  , { "BTCALEND"	 	, {|| U_SYPMSA20(aObjPrj[oFolder:nOption], 	RetNumPrj(aObjPrj[oFolder:nOption]) ) }	, "Gestão do Projetos"			} ) 
Aadd(aButtons  , { "CLIPS"       	, {|| U_SyDocument( "AF8", RetNumPrj(aObjPrj[oFolder:nOption]) , 2, 1) }			, "Documentações do Projeto"	} ) 
Aadd(aButtons  , { "INSTRUME"    	, {|| SyPrjValOS( RetNumPrj(aObjPrj[oFolder:nOption]) ) }  							, "OSs do Projeto"				} ) 
Aadd(aButtons  , { "SOLICITA"	   	, {|| U_SYPMSA02()() } 																, "Aprova OS" 					} )
Aadd(aButtons  , { "PRODUTO"	 	, {|| U_SYPMSA30(RetNumPrj(aObjPrj[oFolder:nOption])) }	  							, "Manut.Projetos"  			} )

IF lPMO .Or. lDiretoria
	Aadd(aButtons  , { "DISCAGEM" 		, {|| U_SyPrjInativo() }  														, "Clientes Inativos"  			} )
	Aadd(aButtons  , { "POSCLI"	     	, {|| SyPrjCliente(aObjPrj[oFolder:nOption]) }                              	, "Clientes" 					} )
	Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_SyExporExcel(oFolder:aDialogs[oFolder:nOption]:cCaption,oPrj:aHeader,oPrj:aCols,lDiretoria) }, "Exportar"					} )
	Aadd(aButtons  , { "CHAVE2" 		, {|| SyPrjDesbloqueia(RetNumPrj(aObjPrj[oFolder:nOption])) } 					, "Desbloqueio de Auditoria"  	} )
ElseIf !Empty(cCodCoord)
	Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_SyExporExcel(oFolder:aDialogs[oFolder:nOption]:cCaption,oPrj:aHeader,oPrj:aCols,lDiretoria) }, "Exportar"					} )
	Aadd(aButtons  , { "BUDGETY"		, {|| U_SYPMSR06(cCodCoord) }, "Relatorio"					} )
EndIF

Aadd( aButtons	, {	"PROJETPMS"	, {|| U_PmsObs(	oFolder,;
												@oMemoPrj,;
												@oMemoOk,;
												@oMemoPr,;
												@oMemo40,;
												@oMemo70,;
												@oMemoHr,;
												@oMemoBl,;
												@oMemoAv,;
												@oMemoAb,;
												@oMemoSy,;
												@oMemoEn,;
												@cMemoPrj,;
												@cMemoOk,;
												@cMemoPr,;
												@cMemo40,;
												@cMemo70,;
												@cMemoHr,;
												@cMemoBl,;
												@cMemoAv,;
												@cMemoAb,;
												@cMemoSy,;
												@cMemoEn,;
												oPrjOk,;
												oPrjPr,;
												oPrj40,;
												oPrj70,;
												oPrjHr,;
												oPrjBl,;
												oPrjAvulso,;
												oPrjAberto,;
												oPrjSymm,;
												oPrjEn)},"Historico <F8>"	})

SetKey( VK_F8,{ || U_PmsObs(oFolder,;
							@oMemoPrj,;
							@oMemoOk,;
							@oMemoPr,;
							@oMemo40,;
							@oMemo70,;
							@oMemoHr,;
							@oMemoBl,;
							@oMemoAv,;
							@oMemoAb,;
							@oMemoSy,;
							@oMemoEn,;
							@cMemoPrj,;
							@cMemoOk,;
							@cMemoPr,;
							@cMemo40,;
							@cMemo70,;
							@cMemoHr,;
							@cMemoBl,;
							@cMemoAv,;
							@cMemoAb,;
							@cMemoSy,;
							@cMemoEn,;
							oPrjOk,;
							oPrjPr,;
							oPrj40,;
							oPrj70,;
							oPrjHr,;
							oPrjBl,;
							oPrjAvulso,;
							oPrjAberto,;
							oPrjSymm,;
							oPrjEn) })

MsgRun("Aguarde, Filtrando Projetos...",, {|| CursorWait(), SYPMSDados(,,,;
@aColsPrj,@aHeadPRJ,;
lDiretoria,lPMO,;
@aColsOkPRJ,@aHeadOkPRJ,;
@aColsPrPRJ,@aHeadPrPRJ,;
@aCols40PRJ,@aHead40PRJ,;
@aCols70PRJ,@aHead70PRJ,;
@aColsHrPRJ,@aHeadHrPRJ,;
@aColsBlPRJ,@aHeadBlPRJ,;
@aColsAvulso,@aHeadAvulso,;
@aColsAberto,@aHeadAberto ,;
@aColsSymm,@aHeadSymm ,;
@aColsEn,@aHeadEn) ,;
CursorArrow() })

DEFINE MSDIALOG oTelaPRJ FROM 0,0 To aSize[6],aSize[5] TITLE "Painel de Projetos" OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oTelaPRJ:lEscClose	:= .F.
//	oTelaPRJ:lMaximized	:= .T.

	oFWLayer:Init(oTelaPRJ,.T.)

	oFWLayer:AddCollumn('Col1',90,.F.)
	oFWLayer:AddWindow('Col1','Win1',"",100,.T.,.T.)

	oFWLayer:AddCollumn('Col2',10,.F.)
	oFWLayer:AddWindow('Col2','Win2',"",100,.T.,.T.)

	oPanelFW := oFWLayer:GetWinPanel('Col1','Win1')
	oPanelFW	:FreeChildren()
	oPanelFW:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelFw2 := oFWLayer:GetWinPanel('Col2','Win2')
	oPanelFw2	:FreeChildren()
	oPanelFw2:Align := CONTROL_ALIGN_ALLCLIENT


	/*******************Botoes laterais**************/

	nLin:= 0
/*
	//Acesso para a escolha da visualização em numeros relativos ou absolutos
	If (cTipo == "P")
		cImg:= "ABSOLUTO.PNG"
	Else
		cImg:= "RELATIVO.PNG"
	EndIf	

	nLin+= 040
	cHint:= "Visualiza os valores em números relativos ou absolutos"
	oBtn01 := TBtnBmp2():New( nLin, 05, 100, 30,cImg,,,,{||AbsRelativo(@oBtn00,bAction1)},oPanelFw2,cHint,,.T. )

	//Acesso para a rotina de Painel de Projetos
	nLin+= 35
	cHint:= "Acessa o Painel de Projetos"
	oBtn02 := TBtnBmp2():New( nLin, 05, 100, 30,"PROJETOS.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSC100(),oTimer:Activate())},oPanelFw2,cHint,,.T. )
*/
	//Acesso para a rotina de aprovacao de OS
	nOs  := OSNaoApr(aDados) 
	If (nOS > 0)
		cImg:= "APROVACAO2.PNG"
		cHint:= "Você tem " + cValToChar(nOs) + " OS ainda não aprovadas."
	Else
		cImg := "APROVACAO.PNG"
		cHint:= "Você não tem nenhuma OS pendente de aprovação."
	EndIf	
	
	nLin+= 35
	oBtn03 := TBtnBmp2():New( nLin, 05, 100, 30,cImg,,,,{||(oTimer:DeActivate(),U_SYPMSA02(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	//Acesso a agenda dos consultores
	nLin+= 35
	cHint:= "Acessa a Agenda de Consultores"
	oBtn04 := TBtnBmp2():New( nLin, 05, 100, 30,"AGENDAALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA23(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	//Acesso a ordem de serviço
	nLin+= 35
	cHint:= "Acessa a Ordem de Serviço"
	oBtn05 := TBtnBmp2():New( nLin, 05, 100, 30,"OSALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA01(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	//Acesso a proposta
	nLin+= 35
	cHint:= "Acessa a Proposta"
	oBtn06 := TBtnBmp2():New( nLin, 05, 100, 30,"PROPOSTA.PNG",,,,{||(oTimer:DeActivate(),U_SHOWGRFVDA(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	//Acesso a proposta
	nLin+= 35
	cHint:= "Acessa a Manutencao de OS x Projeto"
	oBtn07 := TBtnBmp2():New( nLin, 05, 100, 30,"TROCA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA31(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	nLin+= 35
	cHint:= "Acessa o KPI"
	oBtn08 := TBtnBmp2():New( nLin, 05, 100, 30,"KPIALFA.PNG",,,,{||(oTimer:DeActivate(),U_SyKPISrv(),oTimer:Activate())},oPanelFw2,cHint,,.T. )
	
	//Acesso ao KPI
	If lPMO .Or. lDiretoria .Or. lAdm

		nLin+= 35
		cHint:= "Acessa o Cadastro de Recursos"
		oBtn09 := TBtnBmp2():New( nLin, 05, 100, 30,"RECALFA.PNG",,,,{||(oTimer:DeActivate(),PMSA050(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa o Relatorio de Pagto."
		oBtn10 := TBtnBmp2():New( nLin, 05, 100, 30,"PGTOALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSR06(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa as Metas."
		oBtn11 := TBtnBmp2():New( nLin, 05, 100, 30,"METAALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYMMSZF(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa o Cadastro de Calendario."
		oBtn13 := TBtnBmp2():New( nLin, 05, 100, 30,"CALENDARIO.PNG",,,,{||(oTimer:DeActivate(),MATA780(),oTimer:Activate())},oPanelFw2,cHint,,.T. )

	EndIf

	nLin+= 35
	cHint:= "Acessa o Cadastro de Projetos."
	oBtn12 := TBtnBmp2():New( nLin, 05, 100, 30,"NEWPROJ.PNG",,,,{||(oTimer:DeActivate(),PMSA410(),oTimer:Activate())},oPanelFw2,cHint,,.T. )


	@ 004,120 SAY oTitPrjOk  VAR ncountOk
	@ 016,120 SAY oTitPrjPr  VAR ncountPr
	
	@ 004,320 SAY oTitPrj40  VAR ncount40
	@ 016,320 SAY oTitPrj70  VAR ncount70
	
	@ 004,480 SAY oTitPrjHr  VAR ncountHr
	@ 016,480 SAY oTitPrjBl  VAR ncountBl
	
	@ 004,640 SAY oTitPrjAvulso  VAR ncountAv
	@ 016,640 SAY oTitPrjAberto  VAR ncountAb
	
	@ 004,800 SAY oTitPrjSymm    VAR ncountSy
	@ 016,800 SAY oTitPrjEn      VAR ncountEn
	
	oFolder:=TFolder():New(0,0,{	"Estourados: "			+Alltrim(Str(ncountHr)),;
									"Atingiu >= 70%: "		+Alltrim(Str(ncount70)),;
									"Atingiu 40%: "			+Alltrim(Str(ncount40)),;
									"Projeto Ok: "			+Alltrim(Str(ncountOk)),;
									"Bloqueados: " 			+Alltrim(Str(ncountBl)),;
									"Em Auditoria: "		+Alltrim(Str(ncountAd)),;
									"Atendimento Avulso: "	+Alltrim(Str(ncountAv)),;
									"Encerrados: "			+Alltrim(Str(ncountEn)),;
									"Banco de Horas: "		+Alltrim(Str(ncountAb)),;
									"ALFA: "				+Alltrim(Str(ncountSy)),;
									"Todos os Projetos: "	+Alltrim(Str(ncountOk+ncountPr+ncount40+ncount70+ncountHr+ncountBl+nCountAv+nCountAb+nCountSy+nCountEn)),;
									"Indicadores"};
									,,oPanelFW,,,,.T.,.F.,0,0)
	
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Estourados.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjHr							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[1],aHeadHrPRJ,aColsHrPRJ)
	oPrjHr:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjHr:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjHr,@nlOrdemCols) }
	oPrjHr:oBrowse:lUseDefaultColors 	:= .F.
	oPrjHr:bLinhaOk					:= {|| CorGet(0,oPrjHr) }
	oPrjHr:oBrowse:bChange			:= {|| CorGet(1,oPrjHr),U_ObsView(@oMemoHr,@cMemoHr,oPrjHr) }
	//oPrjHr:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjHr) } )
	//oPrjHr:oBrowse:SetBlkColor( { || CorGet(3,oPrjHr) } )
	
	oPanelHr			:= TPanel():New(0, 0, '', oFolder:aDialogs[1], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelHr:Align		:= CONTROL_ALIGN_BOTTOM
	                                                       
	@ 0,0 GET oMemoHr VAR cMemoHr MEMO When .T. OF oPanelHr  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoHr:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Atingiu >= 70%.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrj70							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[2],aHead70PRJ,aCols70PRJ)
	oPrj70:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrj70:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrj70,@nlOrdemCols) }
	oPrj70:oBrowse:lUseDefaultColors 	:= .F.
	oPrj70:bLinhaOk					:= {|| CorGet(0,oPrj70) }
	oPrj70:oBrowse:bChange			:= {|| CorGet(1,oPrj70),U_ObsView(@oMemo70,@cMemo70,oPrj70) }
	//oPrj70:oBrowse:SetBlkBackColor( { || CorGet(2,oPrj70) } )
	//oPrj70:oBrowse:SetBlkColor( { || CorGet(3,oPrj70) } )
	
	oPanel70			:= TPanel():New(0, 0, '', oFolder:aDialogs[2], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanel70:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemo70 VAR cMemo70 MEMO When .T. OF oPanel70  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemo70:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Atingiu 40%.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrj40							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[3],aHead40PRJ,aCols40PRJ)
	oPrj40:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrj40:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrj40,@nlOrdemCols) }
	oPrj40:oBrowse:lUseDefaultColors 	:= .F.
	oPrj40:bLinhaOk					:= {|| CorGet(0,oPrj40) }
	oPrj40:oBrowse:bChange			:= {|| CorGet(1,oPrj40),U_ObsView(@oMemo40,@cMemo40,oPrj40) }
	//oPrj40:oBrowse:SetBlkBackColor( { || CorGet(2,oPrj40) } )
	//oPrj40:oBrowse:SetBlkColor( { || CorGet(3,oPrj40) } )
	
	oPanel40			:= TPanel():New(0, 0, '', oFolder:aDialogs[3], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanel40:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemo40 VAR cMemo40 MEMO When .T. OF oPanel40  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemo40:Align := CONTROL_ALIGN_ALLCLIENT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Ok.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjOk							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[4],aHeadOkPRJ,aColsOkPRJ)
	oPrjOk:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjOk:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjOk,@nlOrdemCols) }
	oPrjOk:oBrowse:lUseDefaultColors 	:= .F.
	oPrjOk:bLinhaOk					:= {|| CorGet(0,oPrjOk) }
	oPrjOk:oBrowse:bChange			:= {|| CorGet(1,oPrjOk),U_ObsView(@oMemoOk,@cMemoOk,oPrjOk) }
	//oPrjOk:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjOk) } )
	//oPrjOk:oBrowse:SetBlkColor( { || CorGet(3,oPrjOk) } )
	
	oPanelOk			:= TPanel():New(0, 0, '', oFolder:aDialogs[4], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelOk:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoOk VAR cMemoOk MEMO When .T. OF oPanelOk  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoOk:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Bloqueados.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjBl							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[5],aHeadBlPRJ,aColsBlPRJ)
	oPrjBl:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjBl:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjBl,@nlOrdemCols) }
	oPrjBl:oBrowse:lUseDefaultColors 	:= .F.
	oPrjBl:bLinhaOk					:= {|| CorGet(0,oPrjBl) }
	oPrjBl:oBrowse:bChange			:= {|| CorGet(1,oPrjBl),U_ObsView(@oMemoBl,@cMemoBl,oPrjBl) }
	//oPrjBl:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjBl) } )
	//oPrjBl:oBrowse:SetBlkColor( { || CorGet(3,oPrjBl) } )
	
	oPanelBl			:= TPanel():New(0, 0, '', oFolder:aDialogs[5], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelBl:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoBl VAR cMemoBl MEMO When .T. OF oPanelBl  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoBl:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos em Auditoria.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjPr							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[6],aHeadPrPRJ,aColsPrPRJ)
	oPrjPr:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjPr:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjPr,@nlOrdemCols) }
	oPrjPr:oBrowse:lUseDefaultColors 	:= .F.
	oPrjPr:bLinhaOk					:= {|| CorGet(0,oPrjPr) }
	oPrjPr:oBrowse:bChange			:= {|| CorGet(1,oPrjPr),U_ObsView(@oMemoPr,@cMemoPr,oPrjPr) }
	//oPrjPr:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjPr) } )
	//oPrjPr:oBrowse:SetBlkColor( { || CorGet(3,oPrjPr) } )
	
	oPanelPr			:= TPanel():New(0, 0, '', oFolder:aDialogs[6], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelPr:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoPr VAR cMemoPr MEMO When .T. OF oPanelPr  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoPr:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Avulsos.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjAvulso							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[7],aHeadAvulso,aColsAvulso)
	oPrjAvulso:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjAvulso:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjAvulso,@nlOrdemCols) }
	oPrjAvulso:oBrowse:lUseDefaultColors 	:= .F.
	oPrjAvulso:bLinhaOk					:= {|| CorGet(0,oPrjAvulso) }
	oPrjAvulso:oBrowse:bChange			:= {|| CorGet(1,oPrjAvulso),U_ObsView(@oMemoAv,@cMemoAv,oPrjAvulso) }
	//oPrjAvulso:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjAvulso) } )
	//oPrjAvulso:oBrowse:SetBlkColor( { || CorGet(3,oPrjAvulso) } )
	
	oPanelAv			:= TPanel():New(0, 0, '', oFolder:aDialogs[7], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelAv:Align		:= CONTROL_ALIGN_BOTTOM            
	
	@ 0,0 GET oMemoAv VAR cMemoAv MEMO When .T. OF oPanelAv  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoAv:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Encerrados.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjEn							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[8],aHeadEn,aColsEn)
	oPrjEn:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjEn:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjEn,@nlOrdemCols) }
	oPrjEn:oBrowse:lUseDefaultColors 	:= .F.
	oPrjEn:bLinhaOk					:= {|| CorGet(0,oPrjEn) }
	oPrjEn:oBrowse:bChange			:= {|| CorGet(1,oPrjEn),U_ObsView(@oMemoEn,@cMemoEn,oPrjEn) }
	
	oPanelEn			:= TPanel():New(0, 0, '', oFolder:aDialogs[8], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelEn:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoEn VAR cMemoEn MEMO When .T. OF oPanelEn  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoEn:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos Banco de Horas Abertos.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjAberto							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[9],aHeadAberto,aColsAberto)
	oPrjAberto:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjAberto:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjAberto,@nlOrdemCols) }
	oPrjAberto:oBrowse:lUseDefaultColors 	:= .F.
	oPrjAberto:bLinhaOk					:= {|| CorGet(0,oPrjAberto) }
	oPrjAberto:oBrowse:bChange			:= {|| CorGet(1,oPrjAberto),U_ObsView(@oMemoAb,@cMemoAb,oPrjAberto) }
	//oPrjAberto:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjAberto) } )
	//oPrjAberto:oBrowse:SetBlkColor( { || CorGet(3,oPrjAberto) } )
	
	oPanelAb			:= TPanel():New(0, 0, '', oFolder:aDialogs[9], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelAb:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoAb VAR cMemoAb MEMO When .T. OF oPanelAb  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoAb:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Projetos ALFA.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrjSymm							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oFolder:aDialogs[10],aHeadSymm,aColsSymm)
	oPrjSymm:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrjSymm:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrjSymm,@nlOrdemCols) }
	oPrjSymm:oBrowse:lUseDefaultColors 	:= .F.
	oPrjSymm:bLinhaOk					:= {|| CorGet(0,oPrjSymm) }
	oPrjSymm:oBrowse:bChange			:= {|| CorGet(1,oPrjSymm),U_ObsView(@oMemoSy,@cMemoSy,oPrjSymm) }
	//oPrjAberto:oBrowse:SetBlkBackColor( { || CorGet(2,oPrjAberto) } )
	//oPrjAberto:oBrowse:SetBlkColor( { || CorGet(3,oPrjAberto) } )
	
	oPanelSy			:= TPanel():New(0, 0, '', oFolder:aDialogs[10], NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelSy:Align		:= CONTROL_ALIGN_BOTTOM
	
	@ 0,0 GET oMemoSy VAR cMemoSy MEMO When .T. OF oPanelSy  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoSy:Align := CONTROL_ALIGN_ALLCLIENT


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Todos os Projetos.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanel1				:= TPanel():New(0, 0, '', oFolder:aDialogs[11], NIL, .T., .F., NIL,, 0,0, .T., .F. )
	oPanel1:Align		:= CONTROL_ALIGN_ALLCLIENT
	
	oPanel2				:= TPanel():New(0, 0, '', oFolder:aDialogs[11], NIL, .F., .F., NIL,, 0,30, .T., .F. )
	oPanel2:Align		:= CONTROL_ALIGN_BOTTOM
	//oPanel2:nClrPane 	:= Rgb(190,190,190)
	
	oPrj							:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanel1,aHeadPRJ,aColsPRJ)
	oPrj:oBrowse:Align       		:= CONTROL_ALIGN_ALLCLIENT
	oPrj:oBrowse:bHeaderClick		:= { |oObj,nCol| SyOrdena(nCol,@oPrj,@nlOrdemCols) }
	oPrj:oBrowse:lUseDefaultColors 	:= .F.
	oPrj:bLinhaOk					:= {|| CorGet(0,oPrj) }
	oPrj:oBrowse:bChange			:= {|| CorGet(1,oPrj),U_ObsView(@oMemoPrj,@cMemoPrj,oPrj) }
	//oPrj:oBrowse:SetBlkBackColor( { || CorGet(2,oPrj) } )
	//oPrj:oBrowse:SetBlkColor( { || CorGet(3,oPrj) } )
	
	oPanelPrj			:= TPanel():New(0, 0, '', oPanel1, NIL, .T., .F., NIL,, 0,100, .F., .T. )
	oPanelPrj:Align		:= CONTROL_ALIGN_BOTTOM                
	
	@ 0,0 GET oMemoPrj VAR cMemoPrj MEMO When .T. OF oPanelPrj  PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY READONLY
	oMemoPrj:Align := CONTROL_ALIGN_ALLCLIENT

	
	//Adiciona os objetos num vetor de acordo com a sequenacia do folder
	aAdd(aObjPrj,oPrjHr )
	aAdd(aObjPrj,oPrj70 )
	aAdd(aObjPrj,oPrj40 )
	aAdd(aObjPrj,oPrjOk )
	aAdd(aObjPrj,oPrjBl )
	aAdd(aObjPrj,oPrjPr )
	aAdd(aObjPrj,oPrjAvulso )
	aAdd(aObjPrj,oPrjEn )     
	aAdd(aObjPrj,oPrjAberto )
	aAdd(aObjPrj,oPrjSymm )     
	aAdd(aObjPrj,oPrj )
	aAdd(aObjPrj,oPrj )
	
	@ 004,010 BITMAP oBmp RESNAME "BR_VERDE"			SIZE 16,16 NOBORDER OF oPanel2 PIXEL 
	@ 016,010 BITMAP oBmp RESNAME "BR_VERMELHO" 		SIZE 16,16 NOBORDER OF oPanel2 PIXEL 
	
	@ 004,190 BITMAP oBmp RESNAME "BR_AZUL"   			SIZE 16,16 NOBORDER OF oPanel2 PIXEL 
	@ 016,190 BITMAP oBmp RESNAME "BR_AMARELO"			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	
	@ 004,380 BITMAP oBmp RESNAME "BR_PINK" 			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	@ 016,380 BITMAP oBmp RESNAME "BR_PRETO" 			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	
	@ 004,530 BITMAP oBmp RESNAME "BR_LARANJA" 			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	@ 016,530 BITMAP oBmp RESNAME "BR_BRANCO" 			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	
	@ 004,690 BITMAP oBmp RESNAME "BR_MARROM" 			SIZE 16,16 NOBORDER OF oPanel2 PIXEL
	
	@ 004,020 SAY "Projeto Ok          : " 				Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	@ 016,020 SAY "Projetos em Atraso  : " 				Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	
	@ 004,200 SAY "Projeto atingiu 40%         : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	@ 016,200 SAY "Projeto atingiu mais de 70% : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	
	@ 004,390 SAY "Projetos Estourados   : " 			Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	@ 016,390 SAY "Projetos Bloqueados   : " 			Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	
	@ 004,540 SAY "Projetos Avulsos         : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	@ 016,540 SAY "Banco de Horas		    : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	
	@ 004,700 SAY "Projetos Internos Symm   : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	@ 015,700 SAY "Projetos Encerrados      : " 		Of oPanel2 FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
	
	@ 004,120 SAY oTitPrjOk  VAR ncountOk 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	@ 016,120 SAY oTitPrjPr  VAR ncountPr 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	
	@ 004,320 SAY oTitPrj40  VAR ncount40 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	@ 016,320 SAY oTitPrj70  VAR ncount70 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	
	@ 004,480 SAY oTitPrjHr  VAR ncountHr 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	@ 016,480 SAY oTitPrjBl  VAR ncountBl 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	
	@ 004,640 SAY oTitPrjAvulso  VAR ncountAv 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	@ 016,640 SAY oTitPrjAberto  VAR ncountAb 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	
	@ 004,800 SAY oTitPrjSymm    VAR ncountSy 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	@ 016,800 SAY oTitPrjEn      VAR ncountEn 	Of oPanel2 FONT oFnt3  COLOR CLR_BLUE 	Pixel SIZE 200,15  Picture "999"
	
	A100Grf(cMesAtu,cMesAnt,aStatus,aMeses,aMetas,aResult)
	
	oPrj:oBrowse:Refresh()

	bAction1:={|| .T.}
	DEFINE TIMER oTimer INTERVAL 60000 ACTION (Eval(bAction1),oTimer:Activate() ) OF oTelaPRJ
	oTimer:Activate()

ACTIVATE MSDIALOG oTelaPRJ ON INIT MyEnchoBar(oTelaPRJ,aButtons) CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  MyEnchoBar  ³ Autor ³   Alexandro Dias  ³ Data ³ 16/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Botoes do Painel.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MyEnchoBar(oTelaPRJ,aButtons)

Local oBar
Local oBtn[Len(aButtons)+1]
Local nX

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oTelaPRJ 
             
For nX := 1 To Len(aButtons)
	DEFINE BUTTON oBtn[nX] RESOURCE aButtons[nX,1]	OF oBar ACTION .T. PROMPT '' TOOLTIP aButtons[nX,3]
	oBtn[nX]:bAction := aButtons[nX,2]
Next
DEFINE BUTTON oBtn[Len(aButtons)+1] RESOURCE "OK" OF oBar ACTION oTelaPRJ:End() PROMPT '' TOOLTIP	"Sair..."

oBar:bRClicked := {|| Alert("oBar:bRClicked") }

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  CorGet   ³ Autor ³ Cris Barroso         ³ Data ³02/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a cor da linha                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CorGet(nOpcao,oPrjCor)    

Local nScan 			:= 0
Local nPosPercentual 	:= Ascan(oPrjCor:aHeader,{ |x| x[2] == 'PERC'})	
//Local nPosBloqueio		:= Ascan(oPrjCor:aHeader,{ |x| x[2] == 'BLQPRJ'})
Local nPosServico		:= Ascan(oPrjCor:aHeader,{ |x| x[2] == 'SERVICO'})

IF nOpcao == 0															// bLinhaOk

	nScan := Ascan( oPrjCor:aCols , { |x| x[Len(oPrjCor:aHeader)] == 'X' } )
	IF nScan > 0                                  
		oPrjCor:aCols[nScan,Len(oPrjCor:aHeader)] := ''
		oPrjCor:oBrowse:Refresh()
	EndIF
	Return .T.

ElseIF nOpcao == 1														// bChange

	oPrjCor:aCols[oPrjCor:nAt,Len(oPrjCor:aHeader)] := 'X'
	oPrjCor:oBrowse:Refresh()
	Return .T.

ElseIF nOpcao == 2														// SetBlkBackColor (Cor Fundo)

	IF oPrjCor:aCols[oPrjCor:nAt,Len(oPrjCor:aHeader)] == 'X'
		Return(Rgb(0,0,255))											// Fundo - Azul
    
//	ElseIF 	oPrjCor:aCols[oPrjCor:nAt,nPosBloqueio] == 'S'
//		Return(Rgb(255,64,64)) 											// Fundo - Vermelho

	ElseIF 	oPrjCor:aCols[oPrjCor:nAt,nPosPercentual] >= 100 .And. !( oPrjCor:aCols[oPrjCor:nAt,nPosServico] == '000003' ) // Projeto Aberto
		Return(Rgb(0,0,0))												// Fundo - Preto
	Else
		Return(Rgb(248,248,255))
	EndIF

ElseIF nOpcao == 3 // SetBlkColor (Cor Fonte)
	
	IF 	oPrjCor:aCols[oPrjCor:nAt,Len(oPrjCor:aHeader)] == 'X' //.Or. oPrjCor:aCols[oPrjCor:nAt,nPosBloqueio] == 'S'
		Return(Rgb(255,255,255))										// Fonte - Branca	
	
	ElseIF 	oPrjCor:aCols[oPrjCor:nAt,nPosServico] == '000003' 
		Return(Rgb(0,0,0))												// Fundo - Preto
	
	ElseIF oPrjCor:aCols[oPrjCor:nAt,nPosPercentual] >= 75
		Return(Rgb(255,64,64))											// Fonte - Vermelho

	//ElseIF oPrjCor:aCols[oPrjCor:nAt,nPosPercentual] >= 100
	//	Return(Rgb(255,255,255))										// Fonte - Branca	
	
	Else 
		Return(Rgb(0,0,0))												// Fonte - Preto
	
	EndIF

EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SYPMSDados ³ Autor ³ Cris Barroso         ³ Data ³03/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Querys para a getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYMPMSC100                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SYPMSDados(cCliente,cLojaCli,cRecurso,aColsPrj,aHeadPRJ,lDiretoria,lPMO,;
aColsOkPRJ,aHeadOkPRJ,;
aColsPrPRJ,aHeadPrPRJ,;
aCols40PRJ,aHead40PRJ,;
aCols70PRJ,aHead70PRJ,;
aColsHrPRJ,aHeadHrPRJ,;
aColsBlPRJ,aHeadBlPRJ,;
aColsAvulso,aHeadAvulso,;
aColsAberto,aHeadAberto,;
aColsSymm,aHeadSymm,;
aColsEn,aHeadEn)

Local nX:= 0
Local aModPrj  := RetSx3Box( Posicione("SX3", 2, "AF8_MODPRJ", "X3CBox()" ),,, TamSX3("AF8_MODPRJ")[1] )
Local aProduto := RetSx3Box( Posicione("SX3", 2, "AF8_PRODUT", "X3CBox()" ),,, TamSX3("AF8_PRODUT")[1] )
Local cPerg			:= PADR("SYPMSC01",10)

Default lDiretoria := .F.  
Default lPMO	    := .F.
Default cCliente   := Space(TamSX3("A1_COD")[1])
Default cLojaCli   := Space(TamSX3("A1_LOJA")[1])


aColsPrj := {}
aHeadPRJ := {}

Pergunte(cPerg,.F.)
/*
MV_PAR01:= Space(TamSX3("AF8_COORD")[1])
MV_PAR02:= Space(TamSX3("AF8_PROJET")[1])
MV_PAR03:= Replicate("Z",TamSX3("AF8_PROJET")[1])
MV_PAR04:= cCliente
MV_PAR05:= cLojaCli
MV_PAR06:= Replicate("Z",TamSX3("A1_COD")[1])
MV_PAR07:= Replicate("Z",TamSX3("A1_LOJA")[1])
MV_PAR08:= 1 //Ativo
MV_PAR09:= Space(TamSX3("AA5_CODSER")[1])	
MV_PAR10:= Replicate("Z",TamSX3("AA5_CODSER")[1])
MV_PAR11:= 3 // Ambos
*/	
	
IF ( "SYMOSPROJETO" $ Upper(ProcName(1)) ) .or. (( "SYPRJREC" $ Upper(ProcName(1)) ))

	MV_PAR04:= cCliente
	MV_PAR05:= cLojaCli
	MV_PAR06:= cCliente
	MV_PAR07:= cLojaCli
	MV_PAR08:= 1 //Ativo


	Aadd(aHeadPRJ,{""					,"FLAG"		,"@BMP"  			,03	,0,".F.","û","C",""	," " } ) 
	Aadd(aHeadPRJ,{"Coordenador"		,"COORD"	,"@S10"				,14	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Atendimento"		,"PROJETO"	,"@S40"				,51	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Orcado"	     	    ,"HRPREV"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Aporte"	     	    ,"HRAPORTE"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Realizado"       	,"REATRANS"	,"@E 999,999"     	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"% Realizado"     	,"PERC"		,"@E 9,999.99"		,08	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Saldo"	        	,"SALDO"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Abono"		    	,"ABONO"	,"@E 999,999"		,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Mod.Atendimento"	,"MODPRJ"   ,"@"				,06	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Produto"			,"PRODUTO"  ,"@"				,06	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Data Criação"		,"DATACRI"	,"@D"				,08	,0,".F.","û","D",""	," " } )
	Aadd(aHeadPRJ,{"Ultima Visita"		,"ULTVIS"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Inicio Previsto"	,"DATAINI"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Fim Previsto"		,"DATAFIN"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Inicio Real"		,"DATAINIR"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Fim Real"			,"DATAFINR"	,"@D"				,08	,0,".F.","û","D",""	," " } )
	Aadd(aHeadPRJ,{"Mod.Venda"   	   	,"SERVICO"	,"@!"				,06	,0,".F.","û","C",""	," " } )	
//	Aadd(aHeadPRJ,{"Revisao"			,"REVISA"	,"@!"				,04	,0,".F.","û","C",""	," " } )	

Else

	Aadd(aHeadPRJ,{""					,"FLAG"		,"@BMP"  			,03	,0,".F.","û","C",""	," " } ) 
	Aadd(aHeadPRJ,{"Coordenador"		,"COORD"	,"@S10"				,14	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Cliente"			,"CLIENTE"	,"@S15"          	,29	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Atendimento"		,"PROJETO"	,"@S40"				,51	,0,".F.","û","C",""	," " } )

	IF lDiretoria
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao mostrar horas da proposta para os coordenadores. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aHeadPRJ,{"Horas Proposta"	    ,"HRPROP"	,"@E 999,999"		,07	,0,".F.","û","N",""	," " } )
		Aadd(aHeadPRJ,{"Nr. Proposta"	    ,"PROPOSTA"	,"@!"				,07	,0,".F.","û","N",""	," " } )
	EndIF	
	Aadd(aHeadPRJ,{"Orcado"       		,"HRPREV"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Aporte"	     	    ,"HRAPORTE"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Realizado+Translado","REATRANS"	,"@E 999,999"     	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Alocadas"     		,"ALOCADAS"	,"@E 999,999"     	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Saldo"	    		,"SALDO"	,"@E 999,999"    	,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"% Realizado"  		,"PERC"		,"@E 9,999.99"		,08	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Realizado"     		,"REALIZA"	,"@E 999,999"     	,07	,0,".F.","û","N",""	," " } ) 
	Aadd(aHeadPRJ,{"Abono"		    	,"ABONO"	,"@E 999,999"		,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Traslado"		    ,"TRANSLA"	,"@E 999,999"		,07	,0,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Mod.Venda"	   	   	,"SERVICO"	,"@!"				,06	,0,".F.","û","C",""	," " } )	
	Aadd(aHeadPRJ,{"Mod.Atendimento"	,"MODPRJ"   ,"@"				,06	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Produto"			,"PRODUTO"  ,"@"				,06	,0,".F.","û","C",""	," " } )
	Aadd(aHeadPRJ,{"Data Criação"		,"DATACRI"	,"@D"				,08	,0,".F.","û","D",""	," " } )
	Aadd(aHeadPRJ,{"Ultima Visita"		,"ULTVIS"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Inicio Previsto"	,"DATAINI"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Fim Previsto"		,"DATAFIN"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Inicio Real"		,"DATAINIR"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Fim Real"			,"DATAFINR"	,"@D"				,08	,0,".F.","û","D",""	," " } )
//	Aadd(aHeadPRJ,{"Revisao"			,"REVISA"	,"@!"				,04	,0,".F.","û","C",""	," " } )	

EndIF

IF lDiretoria
	Aadd(aHeadPRJ,{"Horas Consultor"  ,"HRCON"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Horas Coordenador","HRCOR"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Vlr.Consultor"    ,"VLHORA"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Vlr.Coordenador"  ,"VLCOOR"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Custo"		  	  ,"CUSTO"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )
	Aadd(aHeadPRJ,{"Receita"	  	  ,"RECEITA","@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )	
	Aadd(aHeadPRJ,{"Lucro"		   	  ,"LUCRO"	,"@E 9,999,999.99"	,11	,2,".F.","û","N",""	," " } )	
EndIF

//Aadd(aHeadPRJ,{"Blq"	    		,"BLQPRJ"	,"@!"				,01	,0,".F.","û","C",""	," " } )
Aadd(aHeadPRJ,{""		    		,"XXX"		,"@!"				,01	,0,".F.","û","C",""	," " } )

IF !( "SYMOSPROJETO" $ Upper(ProcName(1)) ) .and. !(( "SYPRJREC" $ Upper(ProcName(1)) )) 
	aHeadOkPRJ := aClone(aHeadPRJ)
	aHeadPrPRJ := aClone(aHeadPRJ)
	aHead40PRJ := aClone(aHeadPRJ)
	aHead70PRJ := aClone(aHeadPRJ)
	aHeadHrPRJ := aClone(aHeadPRJ)
	aHeadBlPRJ := aClone(aHeadPRJ)
	aHeadAvulso:= aClone(aHeadPRJ)
	aHeadAberto:= aClone(aHeadPRJ)
	aHeadSymm  := aClone(aHeadPRJ)
	aHeadEn    := aClone(aHeadPRJ)
EndIF

cQuery1:=  " DROP TABLE #PROJ,#HORAS, #HORAS2,#HORAS3,#HORAS4,PROJETO,#PROJ2,#PROPOSTA,#COMP,#COMP2,#HORATRF,#HORASX "   
TcSqlExec(cquery1) 

cquery2 := "SELECT * INTO #PROPOSTA FROM "+RetSqlName("Z02") +"  WHERE D_E_L_E_T_=' ' "
TcSqlExec(cquery2) 

cclia := mv_par04+mv_par05
cclif := mv_par06+mv_par06

cQuery3:= " SELECT " 
cQuery3+= " 	AF8_PROJET 				AS PROJET, "
cQuery3+= " 	LEFT(AF8_DESCRI,40) 	AS DESCRI, " 
cQuery3+= " 	AF8_REVISA 				AS REVISA, " 
cQuery3+= " 	AF8_MODPRJ 				AS MODPRJ, " 
cQuery3+= " 	AF8_PRODUT 				AS PRODUTO, " 
cQuery3+= " 	AF8_CLIENT 				AS CODCLI, "
cQuery3+= " 	AF8_LOJA 				AS LOJACLI, " 
cQuery3+= " 	CASE WHEN AF8_COORD = ' ' THEN '133' ELSE AF8_COORD END AS RECURSO, " // 133-PMO
cQuery3+= " 	AF8_TPSERV 				AS TPSERV, "
cQuery3+= " 	AA5_DESCRI				AS DESCSRV, "
cQuery3+= " 	AF8_PROPOS 				AS PROPOSTA, "
cQuery3+= " 	AF8_DATA 				AS DATACRI, "
//cQuery3+= " 	AF8_START 				AS DATAINI, "
//cQuery3+= " 	AF8_FINISH 				AS DATAFIN, " 
//cQuery3+= " 	AF8_DTATUI 				AS DATAINIR, "
//cQuery3+= " 	AF8_DTATUF 				AS DATAFINR, " 
cQuery3+= " 	ISNULL(Z02_HRPROJ,0) 	AS HRPROJ, "  
cQuery3+= " 	ISNULL(Z02_HRCON,0) 	AS HRCON, "  
cQuery3+= " 	ISNULL(Z02_HRCOR,0) 	AS HRCOR, "  
cQuery3+= " 	ISNULL(Z02_VLHORA,0) 	AS VLHORA, "  
cQuery3+= " 	ISNULL(Z02_VLCOOR,0) 	AS VLCOOR, "  
cQuery3+= " 	AF8_HORAS 				AS HRPREV, " 
cQuery3+= " 	AF8_ENCPRJ 				AS ENCERRA, " 
cQuery3+= " 	AF8_BLQPRJ 				AS BLQPRJ " 
cQuery3+= " INTO #PROJ FROM " + RetSqlName("AF8") + " AF8"
cQuery3+= " LEFT OUTER JOIN #PROPOSTA ON AF8_PROPOS=Z02_PROPOS "
cQuery3+= " LEFT OUTER JOIN AA5010 AA5 ON AF8_TPSERV=AA5_CODSER AND AA5.D_E_L_E_T_=' '  "
cQuery3+= " WHERE  AF8.D_E_L_E_T_=' '  "

IF !( "SYMOSPROJETO" $ Upper(ProcName(1)) ) .and. !(( "SYPRJREC" $ Upper(ProcName(1)) ))
	IF (lPMO .Or. lDiretoria) .And. !Empty(MV_PAR01)
    	cQuery3+= " AND AF8.AF8_COORD = '" + MV_PAR01 + "'"
	Elseif !(lPMO .Or. lDiretoria)
		cQuery3+= " AND AF8.AF8_COORD = '" + cCodCoord + "' "
	EndIF  
EndIF

cQuery3+= " AND AF8.AF8_PROJET 	BETWEEN '" 			+ MV_PAR02 				+ "' AND '" + MV_PAR03 + "' "
cQuery3+= " AND AF8.AF8_CLIENT+AF8_LOJA  BETWEEN '" + mv_par04+MV_PAR05 	+ "' AND '" + mv_par06+MV_PAR07+ "' " 
cQuery3+= " AND AF8.AF8_TPSERV  BETWEEN '" 			+ mv_par09 				+ "' AND '" + mv_par10+ "' " 

If (MV_PAR08 == 1)
	cQuery3+= " AND AF8.AF8_ENCPRJ <> '1' "
ElseIf (MV_PAR08 == 2)
	cQuery3+= " AND AF8.AF8_ENCPRJ = '1' "
Endif

If (MV_PAR11 == 1)
	cQuery3+= " AND AF8.AF8_BLQPRJ = 'S' "	// Bloqueado
ElseIf (MV_PAR11 == 2)
	cQuery3+= " AND AF8.AF8_BLQPRJ = 'N' "	// Liberado
ElseIf (MV_PAR11 == 4)
	cQuery3+= " AND AF8.AF8_BLQPRJ = 'A' "	// Bloqueado para Auditoria
Endif

TcSqlExec(cquery3)

// Tarefas do Projeto
cQuery4:= " SELECT AF9_PROJET , SUM(AF9_HUTEIS) AS PREVISTA, SUM(AF9_APORTE) AS HRAPORTE INTO #HORATRF " 
cQuery4+= " FROM AF9010  WHERE D_E_L_E_T_=' ' "
cQuery4+= " GROUP BY AF9_PROJET "

TcSqlExec(cquery4)

// OSs X Atividades
cQuery5:= " SELECT Z3_HUTEIS AS UTEIS , CASE WHEN Z3_TPDESC = '1' THEN 0 ELSE Z3_NHABONO END AS ABONO, "
cQuery5+= " Z3_PROJETO AS PROJ , Z3_OS AS OS INTO #HORAS FROM " + RetSqlName("SZ3") + " SZ3 "
cQuery5+= " WHERE SZ3.D_E_L_E_T_ = ' ' AND Z3_PROJETO <> ' ' "  

TcSqlExec(cquery5)
    
// Somas as Horas das OSs
cQuery6:= " SELECT SUM(UTEIS) AS UTEIS, SUM(ABONO) AS ABONO, PROJ, OS INTO #HORAS2  "
cQuery6+= " FROM #HORAS  "
cQuery6+= " GROUP BY PROJ,OS  "
TcSqlExec(cquery6) 

cQuery7:= " SELECT UTEIS , ABONO , PROJ , Z2_PAGAR AS CUSTO , Z2_RECEBER AS RECEITA,
cQuery7+= " CASE WHEN Z2_STATUS <> '1' THEN Z2_DATA ELSE '' END AS ULTVIS,"
cQuery7+= " CASE WHEN Z2_TRANSLA = ' ' THEN 0 ELSE "
cQuery7+= " CONVERT(float,(DATEPART( hh,CONVERT(datetime,Z2_TRANSLA+':00',8))*60 + DATEPART( mi,CONVERT(datetime,Z2_TRANSLA+':00',8))))/60 END AS HTRANSLA "
cQuery7+= " INTO #HORAS3 FROM " + RetSqlName("SZ2") + "   SZ2 "
cQuery7+= " INNER JOIN #HORAS2 ON Z2_OS=OS  "
cQuery7+= " WHERE SZ2.D_E_L_E_T_=' '"
TcSqlExec(cquery7) 

cQuery8:= " SELECT SUM(UTEIS) AS REALIZA , SUM(ABONO) AS ABONO , SUM(CUSTO) AS CUSTO , SUM(RECEITA) AS RECEITA , SUM(HTRANSLA) AS TRANSLA , MAX(ULTVIS) AS ULTVIS,  "
cQuery8+= " PROJ INTO #HORAS4 FROM #HORAS3   "
cQuery8+= " GROUP BY PROJ "
TcSqlExec(cquery8) 

// OSs X Atividades
cQuery9:= " SELECT Z3_PROJETO PROJX, SUM(Z3_ALOC) AS ALOCADAS"
cQuery9+= " INTO #HORASX FROM " + RetSqlName("SZ3") + " SZ3, " + RetSqlName("SZ2") + " SZ2 "
cQuery9+= " WHERE SZ3.D_E_L_E_T_ = ' ' AND SZ2.D_E_L_E_T_ = ' 'AND SZ3.Z3_PROJETO <> ' ' AND SZ2.Z2_STATUS = '1' AND SZ2.Z2_OS = SZ3.Z3_OS"  
cQuery9+= " GROUP BY Z3_PROJETO "
cQuery9+= " HAVING SUM(Z3_ALOC) > 0"
TcSqlExec(cQuery9)    

cQuery10:= " SELECT " 
cQuery10+= " 	RECURSO, "
cQuery10+= " 	CODCLI, "
cQuery10+= " 	LOJACLI, "
cQuery10+= " 	PROJET, "
cQuery10+= " 	REVISA, "
cQuery10+= " 	DESCRI, "
cQuery10+= " 	TPSERV, "
cQuery10+= " 	DESCSRV, "
cQuery10+= " 	MODPRJ, "
cQuery10+= " 	PRODUTO, "
cQuery10+= " 	PROPOSTA, "
cQuery10+= " 	DATACRI, "
cQuery10+= " 	ULTVIS, "
//cQuery+= " 	DATAINI, "
//cQuery+= " 	DATAFIN, "
//cQuery+= " 	DATAINIR, "
//cQuery+= " 	DATAFINR, "
cQuery10+= " 	HRPROJ AS HRPROP, "
cQuery10+= " 	HRCON AS HRCON, "
cQuery10+= " 	HRCOR AS HRCOR, "
cQuery10+= " 	VLHORA AS VLHORA, "
cQuery10+= " 	VLCOOR AS VLCOOR, "
cQuery10+= " 	ISNULL(HRPREV,0) AS HRPREV, "
cQuery10+= " 	ISNULL(HRAPORTE,0) AS HRAPORTE, "
cQuery10+= " 	ISNULL(REALIZA,0) AS REALIZA, "
cQuery10+= " 	ISNULL(ALOCADAS,0) AS ALOCADAS, "
cQuery10+= " 	ISNULL(TRANSLA,0) AS TRANSLA, "
cQuery10+= " 	ISNULL(ABONO,0) AS ABONO, "
cQuery10+= " 	ISNULL(CUSTO,0) AS CUSTO, "
cQuery10+= " 	ISNULL(RECEITA,0) AS RECEITA, "
cQuery10+= " 	ENCERRA, "
cQuery10+= " 	BLQPRJ,SPACE(2) AS FLAG INTO #PROJ2 "
cQuery10+= " FROM #PROJ LEFT OUTER JOIN #HORAS4 ON PROJET=PROJ  " 
cQuery10+= " LEFT OUTER JOIN #HORASX ON PROJET=PROJX  "
cQuery10+= " LEFT OUTER JOIN #HORATRF ON PROJET=AF9_PROJET  "
TcSqlExec(cquery10) 

cQuery11:= " SELECT "
cQuery11+= " 	AE8_DESCRI AS COORD, "
cQuery11+= " 	CODCLI+'-'+A1_NREDUZ AS CLIENTE, "
cQuery11+= " 	Right(PROJET,4)+'-'+DESCRI AS PROJETO, "
cQuery11+= " 	Right(TPSERV,4) + '-' + DESCSRV AS SERVICO, "
cQuery11+= " 	MODPRJ, "
cQuery11+= " 	PRODUTO, "
cQuery11+= " 	PROPOSTA, "
cQuery11+= " 	DATACRI, "
cQuery11+= " 	ULTVIS, "
//cQuery11+= " 	DATAINI, "
//cQuery11+= " 	DATAFIN, "
//cQuery11+= " 	DATAINIR, "
//cQuery11+= " 	DATAFINR, "
cQuery11+= " 	HRPROP, "
cQuery11+= " 	HRCON, "
cQuery11+= " 	HRCOR, "
cQuery11+= " 	VLHORA, "
cQuery11+= " 	VLCOOR, "
cQuery11+= " 	CASE WHEN HRPREV=0 THEN (REALIZA+TRANSLA+ALOCADAS) ELSE HRPREV END AS HRPREV, "
cQuery11+= " 	HRAPORTE, "  
cQuery11+= " 	REALIZA+TRANSLA AS REATRANS,REALIZA, "  
cQuery11+= " 	ALOCADAS, "  
cQuery11+= " 	CASE WHEN HRPREV=0 THEN 0 ELSE ((REALIZA+TRANSLA+ALOCADAS)*100)/(HRPREV+HRAPORTE) END AS PERC, "
cQuery11+= " 	TRANSLA, "
cQuery11+= " 	ABONO, "
cQuery11+= " 	CUSTO, "
cQuery11+= " 	RECEITA, "
cQuery11+= " 	RECEITA-CUSTO AS LUCRO, "
cQuery11+= " 	CASE WHEN HRPREV=0 THEN 0 ELSE (HRPREV+HRAPORTE)-(REALIZA+TRANSLA+ALOCADAS) END AS SALDO, "
cQuery11+= " 	ENCERRA, "
cQuery11+= " 	BLQPRJ, "
cQuery11+= " 	FLAG, "
cQuery11+= " 	REVISA INTO PROJETO  "
cQuery11+= " FROM #PROJ2," + RetSqlName("SA1") + "   SA1, " + RetSqlName("AE8") + "   AE8 "
cQuery11+= " WHERE SA1.D_E_L_E_T_ = ' '  AND  AE8.D_E_L_E_T_ = ' '   "
cQuery11+= " AND A1_COD = CODCLI AND A1_LOJA = LOJACLI  AND AE8_RECURS = RECURSO  "
TcSqlExec(cquery11)  

cQuery12:= " SELECT SUM(Z3_HUTEIS) AS REATAREF,Z3_PROJETO,Z3_TAREFA INTO #COMP FROM " + RetSqlName("SZ3") + "   SZ3 "
cQuery12+= " WHERE SZ3.D_E_L_E_T_=' ' "
cQuery12+= " GROUP BY Z3_PROJETO,Z3_TAREFA   "
TcSqlExec(cquery12)  

cQuery13:= " SELECT AF9_PROJET,AF9_TAREFA,AF9_HUTEIS,REATAREF INTO #COMP2 FROM " + RetSqlName("AF9") + "   AF9  INNER JOIN #COMP  "
cQuery13+= " ON  AF9_PROJET=Z3_PROJETO  AND AF9_TAREFA=Z3_TAREFA  "
cQuery13+= " WHERE  AF9.D_E_L_E_T_=' ' AND AF9_HUTEIS<REATAREF "
TcSqlExec(cquery13)  

//Projetos Encerrados
cQuery14:= " UPDATE PROJETO SET FLAG='En' WHERE ENCERRA = '1'  "     
TcSqlExec(cquery14) 

//Projetos em Auditoria
cQuery14:= " UPDATE PROJETO SET FLAG='Ad' WHERE BLQPRJ IN ('A') AND ENCERRA <>'1' AND FLAG = '' "
TcSqlExec(cquery14) 

//Projetos em Auditoria
cQuery14:= " UPDATE PROJETO SET FLAG='Bl' WHERE BLQPRJ IN ('S') AND ENCERRA <>'1'  AND FLAG = '' "
TcSqlExec(cquery14) 

//Cobranca Avulsa
cQuery14:= " UPDATE PROJETO SET FLAG='Av' WHERE SERVICO LIKE ('%0001%') AND ENCERRA <>'1'  AND FLAG = ''  "     
TcSqlExec(cquery14) 

//Projetos Internos
cQuery14:= " UPDATE PROJETO SET FLAG='Sy' WHERE CLIENTE LIKE ('%000080%') AND ENCERRA <>'1'  AND FLAG = '' "     
TcSqlExec(cquery14) 

//Projetos Banco de Horas
//cQuery14:= " UPDATE PROJETO SET FLAG='Ab' WHERE SERVICO LIKE ('%0004%') AND ENCERRA <> '1'  "     
//TcSqlExec(cquery14) 

//Projeto Estourados
cQuery14:= " UPDATE PROJETO SET FLAG='Hr' WHERE REALIZA+TRANSLA>(HRPREV+HRAPORTE) AND SERVICO NOT LIKE ('%0001%') AND CLIENTE NOT LIKE ('%000080%') AND ENCERRA <>'1'  AND FLAG = '' "
TcSqlExec(cquery14) 

//Projetos com 40%
cQuery14:= " UPDATE PROJETO SET FLAG='40' WHERE PERC >= 40 AND ENCERRA <>'1'  AND SERVICO NOT LIKE ('%0001%') AND CLIENTE NOT LIKE ('%000080%')  AND FLAG = '' "
TcSqlExec(cquery14) 

//Projetos com 70%
cQuery14:= " UPDATE PROJETO SET FLAG='70' WHERE PERC >= 70 AND ENCERRA <> '1' AND SERVICO NOT LIKE ('%0001%') AND CLIENTE NOT LIKE ('%000080%')  AND FLAG = '' "
TcSqlExec(cquery14) 

//Projetos Ok
cQuery14:= " UPDATE PROJETO SET FLAG='Ok' WHERE PERC < 40 AND ENCERRA <> '1' AND SERVICO NOT LIKE ('%0001%') AND CLIENTE NOT LIKE ('%000080%')  AND FLAG = '' "     
TcSqlExec(cquery14) 

//Projetos Ok
cQuery15:= " UPDATE PROJETO SET FLAG='Ok' WHERE FLAG = ''"     
TcSqlExec(cquery15) 

cQuery15:= " SELECT * FROM PROJETO ORDER BY SALDO "

MemoWrite("\QUERY\C100_"+Dtos(dDatabase)+Substr(Time(),1,2)+SubStr(Time(),4,2)+".SQL",cQuery1+ CHR(10) + CHR(13) +;
cQuery2+ CHR(10) + CHR(13) +;
cQuery3+ CHR(10) + CHR(13) +;
cQuery4+ CHR(10) + CHR(13) +;
cQuery5+ CHR(10) + CHR(13) +;
cQuery6+ CHR(10) + CHR(13) +;
cQuery7+ CHR(10) + CHR(13) +;
cQuery8+ CHR(10) + CHR(13) +;
cQuery9+ CHR(10) + CHR(13) +;
cQuery10+ CHR(10) + CHR(13) +;
cQuery11+ CHR(10) + CHR(13) +;
cQuery12+ CHR(10) + CHR(13) +;
cQuery13+ CHR(10) + CHR(13) +;
cQuery14+ CHR(10) + CHR(13) +;
cQuery15+ CHR(10) + CHR(13) )

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery15),"PRJ",.F.,.T.)

DbSelectArea("PRJ")
DbGoTop()
ProcRegua( PRJ->(RecCount()) )
Do while PRJ->( !Eof() )
	
	IncProc()
	
	Aadd( aColsPrj , Array(Len(aHeadPRJ)+1) )
	
	aColsPrj[Len(aColsPrj),1] := &( "o" + IIf(Empty(PRJ->FLAG),"Ab",PRJ->FLAG) )
	
	For nX := 1 To Len(aHeadPRJ)
		
		IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
			IF aHeadPRJ[nX,8] == 'D'
				aColsPrj[Len(aColsPrj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
			ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
				aColsPrj[Len(aColsPrj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
			ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
				aColsPrj[Len(aColsPrj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
			Else
				aColsPrj[Len(aColsPrj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
			EndIF
		EndIF
	
	Next

	aColsPrj[Len(aColsPrj),Len(aHeadPRJ)]	:= ''
	aColsPrj[Len(aColsPrj),Len(aHeadPRJ)+1]:= .F.

	IF !( "SYMOSPROJETO" $ Upper(ProcName(1)) ) .and. !(( "SYPRJREC" $ Upper(ProcName(1)) ))
		
		&("ncount"+PRJ->FLAG)+=1

		IF PRJ->FLAG == 'Ok' 

			Aadd( aColsOkPrj , Array(Len(aHeadPRJ)+1) )
			
			aColsOkPrj[Len(aColsOkPrj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsOkPrj[Len(aColsOkPrj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsOkPrj[Len(aColsOkPrj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsOkPrj[Len(aColsOkPrj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsOkPrj[Len(aColsOkPrj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsOkPrj[Len(aColsOkPrj),Len(aHeadPRJ)]	:= ''
			aColsOkPrj[Len(aColsOkPrj),Len(aHeadPRJ)+1]:= .F.
		
		ElseIF PRJ->FLAG == 'Ad' 

			Aadd( aColsPrPrj , Array(Len(aHeadPRJ)+1) )
			
			aColsPrPrj[Len(aColsPrPrj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsPrPrj[Len(aColsPrPrj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsPrPrj[Len(aColsPrPrj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsPrPrj[Len(aColsPrPrj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsPrPrj[Len(aColsPrPrj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsPrPrj[Len(aColsPrPrj),Len(aHeadPRJ)]	:= ''
			aColsPrPrj[Len(aColsPrPrj),Len(aHeadPRJ)+1]:= .F.
		
		ElseIF PRJ->FLAG == '40' 

			Aadd( aCols40Prj , Array(Len(aHeadPRJ)+1) )
			
			aCols40Prj[Len(aCols40Prj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aCols40Prj[Len(aCols40Prj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aCols40Prj[Len(aCols40Prj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aCols40Prj[Len(aCols40Prj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aCols40Prj[Len(aCols40Prj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aCols40Prj[Len(aCols40Prj),Len(aHeadPRJ)]	:= ''
			aCols40Prj[Len(aCols40Prj),Len(aHeadPRJ)+1]:= .F.
						
		ElseIF PRJ->FLAG == '70' 

			Aadd( aCols70Prj , Array(Len(aHeadPRJ)+1) )
			
			aCols70Prj[Len(aCols70Prj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aCols70Prj[Len(aCols70Prj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aCols70Prj[Len(aCols70Prj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aCols70Prj[Len(aCols70Prj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aCols70Prj[Len(aCols70Prj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aCols70Prj[Len(aCols70Prj),Len(aHeadPRJ)]	:= ''
			aCols70Prj[Len(aCols70Prj),Len(aHeadPRJ)+1]:= .F.
				
		ElseIF PRJ->FLAG == 'Hr' 

			Aadd( aColsHrPrj , Array(Len(aHeadPRJ)+1) )
			
			aColsHrPrj[Len(aColsHrPrj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsHrPrj[Len(aColsHrPrj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsHrPrj[Len(aColshrPrj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColshrPrj[Len(aColshrPrj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsHrPrj[Len(aColsHrPrj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsHrPrj[Len(aColsHrPrj),Len(aHeadPRJ)]	:= ''
			aColsHrPrj[Len(aColsHrPrj),Len(aHeadPRJ)+1]:= .F.
			
		ElseIF PRJ->FLAG == 'Bl' 

			Aadd( aColsBlPrj , Array(Len(aHeadPRJ)+1) )
			
			aColsBlPrj[Len(aColsBlPrj),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsBlPrj[Len(aColsBlPrj),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsBlPrj[Len(aColsBlPrj),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsBlPrj[Len(aColsBlPrj),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsBlPrj[Len(aColsBlPrj),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsBlPrj[Len(aColsBlPrj),Len(aHeadPRJ)]	:= ''
			aColsBlPrj[Len(aColsBlPrj),Len(aHeadPRJ)+1]:= .F.

		ElseIF PRJ->FLAG == 'Av' 

			Aadd( aColsAvulso , Array(Len(aHeadPRJ)+1) )
			
			aColsAvulso[Len(aColsAvulso),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsAvulso[Len(aColsAvulso),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsAvulso[Len(aColsAvulso),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsAvulso[Len(aColsAvulso),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsAvulso[Len(aColsAvulso),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsAvulso[Len(aColsAvulso),Len(aHeadPRJ)]	:= ''
			aColsAvulso[Len(aColsAvulso),Len(aHeadPRJ)+1]:= .F.

		ElseIF PRJ->FLAG == 'Ab' 

			Aadd( aColsAberto , Array(Len(aHeadPRJ)+1) )
			
			aColsAberto[Len(aColsAberto),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsAberto[Len(aColsAberto),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsAberto[Len(aColsAberto),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsAberto[Len(aColsAberto),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsAberto[Len(aColsAberto),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsAberto[Len(aColsAberto),Len(aHeadPRJ)]	:= ''
			aColsAberto[Len(aColsAberto),Len(aHeadPRJ)+1]:= .F.

		ElseIF PRJ->FLAG == 'Sy' 

			Aadd( aColsSymm , Array(Len(aHeadPRJ)+1) )
			
			aColsSymm[Len(aColsSymm),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsSymm[Len(aColsSymm),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsSymm[Len(aColsSymm),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsSymm[Len(aColsSymm),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsSymm[Len(aColsSymm),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsSymm[Len(aColsSymm),Len(aHeadPRJ)]	:= ''
			aColsSymm[Len(aColsSymm),Len(aHeadPRJ)+1]:= .F.
		
		ElseIF PRJ->FLAG == 'En' 

			Aadd( aColsEn , Array(Len(aHeadPRJ)+1) )
			
			aColsEn[Len(aColsEn),1] := &( "o" + PRJ->FLAG )
			
			For nX := 1 To Len(aHeadPRJ)
				
				IF !(aHeadPRJ[nX,2] $ 'FLAG|XXX')
					IF aHeadPRJ[nX,8] == 'D'
						aColsEn[Len(aColsEn),nX] := STOD( &( 'PRJ->' + aHeadPRJ[nX,2] ) )
					ElseIf (aHeadPRJ[nX,2] $ 'PRODUTO')
						aColsEn[Len(aColsEn),nX] := aProduto[aScan(aProduto,{|x| Trim(x[2]) == Trim(PRJ->PRODUTO)})][03]
					ElseIf (aHeadPRJ[nX,2] $ 'MODPRJ')
						aColsEn[Len(aColsEn),nX] := aModPrj[aScan(aModPrj,{|x| Trim(x[2]) == Trim(PRJ->MODPRJ)})][03]
					Else
						aColsEn[Len(aColsEn),nX] := &( 'PRJ->' + aHeadPRJ[nX,2] )
					EndIF
				EndIF
			
			Next
		
			aColsEn[Len(aColsEn),Len(aHeadPRJ)]	:= ''
			aColsEn[Len(aColsEn),Len(aHeadPRJ)+1]:= .F.
		EndIF
		
	EndIF
	
	DbSkip()
	
Enddo

PRJ->(DbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyPrjCliente³ Autor ³ Cris Barroso        ³ Data ³02/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Clientes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyPrjCliente(oPrj)

Local cAlias := "SA1"
Local cFiltra := "ALLTRIM(A1_COORD) = '" + Substring( oPrj:aCols[ oPrj:nAt , Ascan( oPrj:aHeader , { |x| x[2] == 'COORD' } ) ] , 1 , 3 )+"' "    

Private cCadastro 	:= "Cadastro de Clientes"
Private aRotina 	:= {}
Private aIndexSA1 	:= {}
Private bFiltraBrw	:= {} 
Private aRotAuto 	:= Nil

aRotina := { 	{"Pesquisar","PesqBrw"    , 0 , 1,0 ,.F.},	{"Visualizar","A030Visual" , 0 , 2,0 ,NIL}}
IF (lPMO .Or. lDiretoria) 
    aAdd(aRotina,{"Alterar","A030Altera" , 0 , 4,82,NIL})
EndIF
Aadd(aRotina,{"Contatos","U_SyManContato(SA1->A1_COD+SA1->A1_LOJA)" , 0 , 6,82,NIL})
Aadd(aRotina,{"Documentos","U_SyDocument('SA1',SA1->A1_COD+SA1->A1_LOJA,2,1)" , 0 , 6,82,NIL})

IF !(lPMO .Or. lDiretoria)
  bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSA1,@cFiltra) } 
  Eval(bFiltraBrw)
EndIF

mBrowse(6,1, 22,75,cAlias,,,,,,,,,,,.T.,)   

EndFilBrw(cAlias,aIndexSA1)  

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyManContato³ Autor ³ Cris Barroso        ³ Data ³09/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Contatos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyManContato(cEntidade,cAliasTab)     

Local aArea			:= GetArea()
Local aSize    		:= MsAdvSize()
Local nStyle 	    := GD_INSERT+GD_UPDATE+GD_DELETE
Local aAlter		:= {}
Local oPanel1
Local oPanel2                                               
Local oFnt3                 

Local nCor1 := RGB(255,255,255)  
Local nCor2 := RGB(155,193,209)  
Local nCor3 := RGB(255,254,212)  
Local nCor4 := RGB(130,153,166)

Private aColsCon	:= {}
Private aHeadCon 	:= {}   
private oGetCon

Default cAliasTab := 'SA1'

INCLUI := .T.

aButCont		:= {}
//Aadd(aButCont , { "ATALHO"	 , {|| SyAltCont(oGetCon:aCols[oGetCon:nAt,1],cEntidade,cAliasTab) }  , "Inclui / Altera"  } ) 

IF cAliasTab == 'SA1'
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cEntidade))
Else
	SUS->(DbSetOrder(1))
	SUS->(DbSeek(xFilial("SUS")+cEntidade))
EndIF

DEFINE FONT oFnt3 NAME "Courier New" SIZE 0,-16 BOLD  
                      
DEFINE MSDIALOG oTelaCon FROM aSize[7],0 To aSize[6],aSize[5] TITLE "Contatos de : " + IIF( cAliasTab == 'SA1' , SA1->A1_NREDUZ , SUS->US_NREDUZ) OF oMainWnd PIXEL

oTelaCon:lEscClose	:= .F.
oTelaCon:lMaximized	:= .T.

oPanel1:= TPanel():New(0, 0,"Contatos",oTelaCon	,OFnt3,.F.,.F.,nCor1,nCor4, 0,10, .T., .F. )
oPanel1:Align:= CONTROL_ALIGN_TOP

oPanel2:= TPanel():New(0,0,'',oTelaCon	,,.F.,.F.,,, 0,0, .T., .F. )
oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

SyAtuCon(cEntidade,@aAlter,oPanel2,cAliasTab) 

oGetCon:= MsNewGetDados():New(0,0,0,0,nStyle,"U_VLDCONTATO","U_VLDCONTATO",,,,99999,,,,opanel2,aHeadCon,aColsCon)
oGetCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetCon:obrowse:Refresh() 

ACTIVATE MSDIALOG oTelaCon ON INIT ( EnchoiceBar(oTelaCon,{|| IIf(oGetCon:TudoOk(),(AtuAC8(cEntidade),oTelaCon:End()),"") }, {|| (oTelaCon:End()) },,aButCont) )

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyAtuCon   ³ Autor ³ Cris  Barroso        ³ Data ³10/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza GetDados de Contatos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyAtuCon(cEntidade,aAlter,oPanel2,cAliasTab)

Local aAlias 		:= GetArea()
Local nStatus       := 0
Local nStyle 	    := GD_INSERT+GD_UPDATE+GD_DELETE
Local nX            := 0

INCLUI	:= .F.
aHeadCon:= {}
aColsCon :={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SU5")
While !Eof() .And. (SX3->X3_ARQUIVO == "SU5")
	
	IF X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		
		IF ( AllTrim(X3_CAMPO) $ "U5_CODCONT/U5_CONTAT/U5_SOBREN/U5_CELULAR/U5_FCOM1/U5_EMAIL/U5_CONTPRI/U5_FUNCAO/U5_DFUNCAO" )
			AADD(aHeadCon,{ 	TRIM(x3titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO,SX3->X3_DECIMAL, SX3->X3_VALID,;
								SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3,SX3->X3_CONTEXT, SX3->X3_CBOX, SX3->X3_RELACAO, SX3->X3_WHEN})

			If AllTrim(X3_CAMPO) <> "U5_CODCONT"
				aAdd(aAlter,X3_CAMPO)
			EndIf	
			
		EndIF
		
	EndIF
	
	DbSkip()
	
EndDo

cQuery := " SELECT U5_CODCONT, U5_CONTAT, U5_SOBREN, U5_CELULAR, U5_FCOM1, U5_EMAIL, U5_CONTPRI, U5_FUNCAO "
cQuery += " FROM "+RetSqlName("SU5")+" SU5 "
cQuery += " INNER JOIN "+RetSqlName("AC8")+" AC8 ON (SU5.U5_CODCONT = AC8.AC8_CODCON) AND "
cQuery += " AC8.AC8_CODENT = '" + cEntidade 		+ "' AND " 
cQuery += " AC8.AC8_ENTIDA = '" + cAliasTab 		+ "' AND " 
cQuery += " AC8.AC8_FILIAL = '" + xFilial('AC8') 	+ "' AND "  
cQuery += " AC8.AC8_FILENT = '" + xFilial('SA1') 	+ "' AND " 
cQuery += " AC8.D_E_L_E_T_ = '' "
cQuery += " WHERE SU5.D_E_L_E_T_ = ''"
cQuery += " AND SU5.U5_EMAIL <> 'servicos@alfaerp.com.br'"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"CON",.F.,.T.)

DbSelectArea("CON")
DbGoTop()
If EOF()
	Aadd( aColsCon , Array(Len(aHeadCon)+1) )
	For nX := 1 to Len(aHeadCon)
		IF ( aHeadCon[nX][10] != "V" )
			aColsCon[Len(aColsCon)][nX] := CriaVar(aHeadCon[nX][2])
		EndIF
	Next
	aColsCon[Len(aColsCon),Len(aHeadCon)+1] := .F.
Else
	While !Eof()
		SU5->(dbSetOrder(1))
		SU5->(dbSeek(xFilial("SU5")+CON->U5_CODCONT))

		Aadd(aColsCon,Array(Len(aHeadCon)+1))
		
		For nI := 1 to Len(aHeadCon)
		
			IF (FieldPos(aHeadCon[nI,2]) > 0)
				IF ( aHeadCon[nI][10] != "V" )
					aColsCon[Len(aColsCon),nI] := FieldGet(FieldPos(aHeadCon[nI,2]))
				ELSE
					aColsCon[Len(aColsCon),nI] := CriaVar(aHeadCon[nI,2])
				ENDIF	
			Else	
				aColsCon[Len(aColsCon),nI] := CriaVar(aHeadCon[nI,2])
			EndIF
		
		Next nI
		aColsCon[Len(aColsCon),Len(aHeadCon)+1] := .F.

		DbSkip()
		
	EndDo
Endif

CON->(DbCloseArea())
RestArea(aAlias)

oGetCon:= MsNewGetDados():New(0,0,0,0,nStyle,"U_VLDCONTATO","U_VLDCONTATO",,,,,,,,oPanel2,aHeadCon,aColsCon)
oGetCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetCon:oBrowse:refresh()

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyAltCont   ºAutor  ³Cris Barroso 	 º Data ³  15/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui ou altera contatos                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSC100                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyAltCont(cContato,cCliente,cAliasTab)

Local aArea	  	:= GetArea()
Local nOpcA	    := 0
Local nAviso	:= 0
Local aAlter    := {}

cCadastro := " "
INCLUI    := .F.

aRotina	:= {	{ "Pesquisar"  	,"AxPesqui" ,0,1 },;
{ "Visualizar"  ,"AxVisual" ,0,2 },;
{ "Incluir"  	,"AxInclui" ,0,3 },;
{"Alterar"  	,"AxAltera" ,0,4 }}

nAviso := Aviso("Cadastro de Contatos","O Que Você Deseja Fazer?",{"Cadastrar", "Alterar" , "Excluir", "Sair" })

IF nAviso == 1
	
	cCadastro 	:= "Inclusão de Contatos"
	INCLUI 		:= .T.
	nOpcA 		:= AxInclui("SU5",0,3)
	
	If nOpcA == 1
		dbSelectArea("SUS")
		dbSetOrder(5)
		dbSeek(xfilial("SUS")+cCliente)
		cCodProsp := SUS->US_COD
		cLojProsp := SUS->US_LOJA
		RecLock('SU5',.F.)
		U5_PROSPEC := cCodProsp
		U5_LOJAPRO := cLojProsp
		MsUnLock()          
		
		DbSelectArea("AC8")
		DbSetOrder(1)
		IF !DbSeek(xFilial("AC8")+SU5->U5_CODCONT+"SA1"+xFilial("SA1")+cCliente)
			Reclock("AC8",.T.)
			Replace AC8_FILIAL  With xFilial("AC8")
			Replace AC8_ENTIDA  With cAliasTab
			Replace AC8_FILENT  With xFilial("SA1")
			Replace AC8_CODENT	With cCliente
			Replace AC8_CODCON	With SU5->U5_CODCONT
			MsUnlock()
		EndIF
	Endif
	INCLUI	:= .F.
	
ElseIf nAviso == 2
	
	cCadastro := "Alteração de Contatos"
	
	DbSelectArea("SU5")
	DbSetOrder(1)
	If DbSeek(xFilial("SU5") + cContato )
		INCLUI 	:= .F.
		nOpcA 	:= AxAltera("SU5",SU5->(Recno()),4)
	Endif
ElseIf nAviso == 3
	
	cCadastro := "Exclusção de Contatos"
	
	DbSelectArea("AC8")
	DbSetOrder(1)
	If DbSeek(xFilial("AC8")+cContato+cAliasTab+xFilial(cAliasTab)+cCliente)
		RecLock("AC8",.F.,.T.)
		dbDelete()
		MsUnLock()
		MsgAlert('Excluido com sucesso')
	Endif 
	nOpcA:= 1
Endif

IF nOpcA == 1            
	SyAtuCon(cCliente,@aAlter,Nil,cAliasTab)
EndIF

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuAC8      ºAutor  ³Fabio Rogerio 	 º Data ³  17/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a amarracao do contato com o cliente no AC8        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSC100                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function AtuAC8(cCliente)
Local nX:= 0
inclui:=.f.

For nX:=1 To Len(oGetCon:aCols)
	//Inclusao e Alteracao
	If !oGetCon:aCols[nX,Len(oGetCon:aHeader)+1]

		dbSelectArea("SU5")
		dbSetOrder(1)
		If dbSeek(xfilial("SU5")+oGetCon:aCols[nX,1])
			RecLock("SU5",.F.)
				
			For nI := 1 to Len(oGetCon:aHeader)
				IF (FieldPos(oGetCon:aHeader[nI,2]) > 0)
					FIELDPUT(FieldPos(oGetCon:aHeader[nI,2]),oGetCon:aCols[nX,nI])
				EndIF
			Next nI
			MsUnLock()

		else

			cCodCont:= GetSxeNum("SU5","U5_CODCONT")
			DbSelectArea("SU5")
			DbSetOrder(1) 
			While ( DbSeek(xFilial("SU5")+cCodCont)  )
				cCodCont:= GetSxeNum("SU5","U5_CODCONT")
				ConfirmSX8()
			EndDo
			
			RecLock("SU5",.T.)
			For nI := 1 to Len(oGetCon:aHeader)
				IF (FieldPos(oGetCon:aHeader[nI,2]) > 0)
					FIELDPUT(FieldPos(oGetCon:aHeader[nI,2]),oGetCon:aCols[nX,nI])
				EndIF
			Next nI
			Replace U5_FILIAL With xFilial("SU5")
			Replace U5_CODCONT With cCodCont
			MsUnLock()
		EndIf
		
		DbSelectArea("AC8")
		DbSetOrder(1)
		IF !DbSeek(xFilial("AC8")+SU5->U5_CODCONT+"SA1"+xFilial("SA1")+cCliente)
			Reclock("AC8",.T.)
			Replace AC8_FILIAL  With xFilial("AC8")
			Replace AC8_ENTIDA  With "SA1"
			Replace AC8_FILENT  With xFilial("SA1")
			Replace AC8_CODENT	With cCliente
			Replace AC8_CODCON	With SU5->U5_CODCONT
			MsUnlock()
		EndIF
		
	ELSE
		//Exclusao
		DbSelectArea("AC8")
		DbSetOrder(1)
		If DbSeek(xFilial("AC8")+oGetCon:aCols[nX,1]+"SA1"+xFilial("SA1")+cCliente)
			RecLock("AC8",.F.,.T.)
			dbDelete()
			MsUnLock()
		Endif 

		DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek(xFilial("SU5")+oGetCon:aCols[nX,1])
			RecLock("SU5",.F.,.T.)
			dbDelete()
			MsUnLock()
		Endif 
	EndIf

Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyPrjInativoºAutor  ³Cris Barroso 	 º Data ³  17/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Browse dos clientes inativos                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSC100                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

Static Function SyPrjInativo()

Local aAlias 		:= GetArea()  
Local aSize    		:= MsAdvSize()
Local nStyle 		:= 0
Local aAlter		:= {}
Local aButInat		:= {}
Local aGrp			:= UsrRetGrp(UsrRetName(__cUserID))
Local aGroups     	:= AllGroups()
Local cGrp			:= ''
Local nI                   
Local lExporta		:= .F.

Private aColsInat	:= {}
Private aHeadInat 	:= {}
Private oGetInat 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra quem pode exportar para Excel.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR"
	lFiltra := .T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra grupos.                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:= 1 To Len(aGroups)
		IF 	(AllTrim(Upper((aGroups[nI,1,2]))) == "ADMINISTRADORES") .Or.;
			(AllTrim(Upper((aGroups[nI,1,2]))) == "COORDENACAO_COMERCIAL") 
			cGrp+= aGroups[nI,1,1] + "/"
		EndIF
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario pertence ao grupo de administradores.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(cGrp)
		For nI:= 1 To Len(aGrp)
			If aGrp[nI] $ cGrp
				lExporta := .T.
			EndIf
		Next nI
	EndIf 
	
EndIF

Aadd(aButInat  , { "BMPGROUP" 		, {|| U_SyManContato(oGetInat:aCols[oGetInat:nAt,1]+oGetInat:aCols[oGetInat:nAt,2]) } 		, "Contatos"	} )

IF lExporta
	Aadd(aButInat  , { PmsBExcel()[1]	, {|| U_SyExporExcel('Clientes Inativos',oGetInat:aHeader,oGetInat:aCols,lDiretoria) 	}	, "Excel" 		} )                                                 
EndIF

nPrazo := 60 

DEFINE MSDIALOG oTelaPerg FROM 0,0  TO 100, 260 TITLE "Deseja Filtrar Clientes Inativos?" OF oMainWnd PIXEL 

@ 10,10 say "Prazo em dias para inatividade :"  PIXEL   SIZE 130, 10 
@ 10,90 MSGET nPrazo OF oTelaPerg PIXEL   SIZE 25, 10  PICTURE "999" 
DEFINE SBUTTON 	FROM 35,90 TYPE 1 ENABLE OF oTelaPerg ACTION (oTelaperg:End())

ACTIVATE MSDIALOG otelaPerg Centered

ddtfim:= datavalida(ddatabase-nprazo) 

SyAtuInat(ddtfim,lExporta) 

DEFINE MSDIALOG oTelaInat FROM aSize[7],0 To aSize[6],aSize[5] TITLE "Clientes Inativos" OF oMainWnd PIXEL

oTelaInat:lEscClose	 := .F.
oTelaInat:lMaximized := .T.

oPanel1:= TPanel():New(0,0,'',oTelaInat	,,.F.,.F.,,, 0,0, .T., .F. )
oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT

oGetInat:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanel1,aHeadInat,aColsInat)
oGetInat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetInat:oBrowse:GoTop()

ACTIVATE MSDIALOG oTelaInat ON INIT ( EnchoiceBar(oTelaInat,{|| ( oTelaInat:End()) }, {|| (oTelaInat:End()) },,aButInat) )

RestArea(aAlias)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyAtuInat  ³ Autor ³ Cris  Barroso        ³ Data ³17/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza GetDados de Clientes Inativos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyAtuInat(dDtFim,lExporta) 

Local cQuery 	:= ''
Local cCodVend	:= IIF( !(lPMO .Or. lDiretoria) , '' , Posicione('SA3',7,xFilial('SA3')+__cUserID,'A3_COD') )

aHeadInat:= {}
Aadd(aHeadInat,{"Cliente"			,"SYPRJ28","@!"  				,06	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Loja"    			,"SYPRJ29","@!"          		,02	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Nome"				,"SYPRJ30","@!"					,20	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Ult. Fat."	        ,"SYPRJ31","@D"                	,08	,0,".F.","û","D",""	," " } )
Aadd(aHeadInat,{"Ult. Visita"	    ,"SYPRJ32","@D"                	,08	,0,".F.","û","D",""	," " } ) 
//Aadd(aHeadInat,{"Contato"	    	,"SYPRJ33","@!"                	,20	,0,".F.","û","D",""	," " } )
//Aadd(aHeadInat,{"E-mail"		    ,"SYPRJ34","@!"                	,50	,0,".F.","û","D",""	," " } )
Aadd(aHeadInat,{"DDD"		    	,"SYPRJ35","@!"                	,03	,0,".F.","û","D",""	," " } )
Aadd(aHeadInat,{"Telefone"	    	,"SYPRJ36","@R 99-9999-9999"   	,15	,0,".F.","û","C",""	," " } )
//Aadd(aHeadInat,{"Telefone2 "	   	,"SYPRJ37","@R 99-9999-9999"   	,15	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Segmento"         	,"SYPRJ38","@!"             	,25	,0,".F.","û","C",""	," " } ) 
//Aadd(aHeadInat,{"Contato2"	    	,"SYPRJ39","@!"                	,20	,0,".F.","û","D",""	," " } )
Aadd(aHeadInat,{"Endereço"  	    ,"SYPRJ40","@!"         		,50	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Bairro"	    	,"SYPRJ41","@!"             	,30	,0,".F.","û","C",""	," " } )
Aadd(aHeadInat,{"Municipio"        	,"SYPRJ42","@!"             	,15	,0,".F.","û","C",""	," " } )  
Aadd(aHeadInat,{"UF"            	,"SYPRJ43","@!"             	,02	,0,".F.","û","C",""	," " } )

cQuery := " SELECT Z2_CLIENTE+Z2_LOJA AS CLIENTE , MAX(Z2_DATA) AS ULTIMA_OS "  
cQuery += " FROM " +RetSqlName("SZ2")
cQuery += " WHERE "                       
cQuery += " 	Z2_FILIAL = '" 	+xFilial("SZ2")	+	"' AND "
cQuery += " 	Z2_DATA < '"	+Dtos(dDtFim)	+	"' AND "  
cQuery += " 	Z2_STATUS >= '3' AND " // A partir das OSs Encerrada
cQuery += " 	D_E_L_E_T_ = '' " 
cQuery += " GROUP BY Z2_CLIENTE+Z2_LOJA "
cQuery += " ORDER BY ULTIMA_OS DESC " 

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"INA",.F.,.T.)

DbSelectArea("INA")
DbGoTop() 

While INA->( !Eof() )
	
	SA1->( DbSetOrder(1) )
	IF SA1->( DbSeek( xFilial('SA1') + INA->CLIENTE ) )

		IF !lExporta
			
			IF (SA1->A1_VEND != cCodVend)
				DbSkip()
				Loop
			EndIF
			
		EndIF
			
		Aadd( aColsInat , {SA1->A1_COD,;
		SA1->A1_LOJA,;
		SA1->A1_NREDUZ,;
		Dtoc(SA1->A1_ULTCOM),;
		Stod(INA->ULTIMA_OS),;
		SA1->A1_DDD,; 
		SA1->A1_TEL,;
		SA1->A1_SEGMEN,;
		SA1->A1_END,;
		SA1->A1_BAIRRO,;
		SA1->A1_MUN,;
		SA1->A1_EST,;
		.F. })

		//SA1->A1_CONTATO,; 
		//SA1->A1_EMAIL,; 
		//SA1->A1_TEL2,;
		//SA1->A1_CONTTEC,; 
				
	EndIF
	
	DbSkip()

Enddo

INA->(dbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyAtuTarefa³ Autor ³ Cris  Barroso        ³ Data ³10/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza GetDados de Tarefas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyAtuTarefas(cCodProj,aHeadRec,aColsRec)

Local cQuery
Local nTotal	:= 0
Local aArea 	:= GetArea()                                

aHeadRec	:= {}
aColsRec 	:= {}

Aadd(aHeadRec,{"Recurso"   	,"SYPRJ25","@!"          		,30	,0,".F.","û","C",""	," " } )
Aadd(aHeadRec,{"Horas"		,"SYPRJ26","@E 99999.99"    	,08	,2,".F.","û","N",""	," " } )
Aadd(aHeadRec,{"%"  		,"SYPRJ27","@E 999.99"	   		,06	,2,".F.","û","N",""	," " } )
      
cQuery := " SELECT RECURSO, NOME , SUM(HORAS) AS TOTAL FROM "
cQuery += " ( "
cQuery += " SELECT Z2_RECURSO AS RECURSO, AE8_DESCRI AS NOME, Z3_HUTEIS HORAS "
cQuery += " FROM " 
cQuery +=  	RetSqlName("SZ3")	+ " SZ3, "
cQuery += 	RetSqlName("SZ2")	+ " SZ2, "
cQuery += 	RetSqlName("AE8")	+ " AE8 "
cQuery += " WHERE " 
cQuery += " 	Z2_FILIAL  			= '" + xFilial('SZ2')	+ "' "
cQuery += " 	AND Z3_FILIAL  		= '" + xFilial('SZ3')	+ "' "
cQuery += " 	AND AE8_FILIAL 		= '" + xFilial('AE8') 	+ "' " 
cQuery += " 	AND Z3_PROJETO 		= '" + cCodProj			+ "' "
cQuery += " 	AND AE8_RECURS 		= Z2_RECURSO "
cQuery += " 	AND Z2_OS 			= Z3_OS "  
cQuery += " 	AND SZ2.D_E_L_E_T_ 	= '' "
cQuery += " 	AND SZ3.D_E_L_E_T_ 	= '' "
cQuery += " 	AND AE8.D_E_L_E_T_ 	= '' "
cQuery += " ) AS TMP "
cQuery += " GROUP BY RECURSO, NOME "
cQuery += " ORDER BY TOTAL DESC "

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")

DbGoTop()                                                          
While TRB->( !Eof() )
	nTotal += TRB->TOTAL
	DbSkip() 
Enddo

DbGoTop()
While TRB->( !Eof() )
	Aadd( aColsREC , { Alltrim(TRB->RECURSO)+"-"+TRB->NOME , TRB->TOTAL , IIF( nTotal == 0 , 0 , (TRB->TOTAL*100) / nTotal ) , .F. } )
	DbSkip()
Enddo

TRB->(DbCloseArea())

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SyOrdena ³ Autor ³    Cris Barroso       ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena ao clicar na coluna da GetDados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SyOrdena(nCol,oGetDados,lOrdemCols)

Local nPos := nCol

IF !lJaExecutou
	
	lJaExecutou := .T.
	lOrdemCols := !lOrdemCols
	
	IF lOrdemCols 
    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF
	
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
	oGetDados:oBrowse:SetFocus()

Else

	lJaExecutou := .F.

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyDocument  ºAutor  ³Cris Barroso 	 º Data ³  30/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Manutencao do banco de documentacao                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSC100                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SyDocument( cAlias, cbusca, nOpc, nOper)

Local aArea        := GetArea()
Local aSize 	   := MsAdvSize( )
Local aRecAC9      := {}
Local aRecACB      := {}
Local aPosObj      := {}
Local aPosObjMain  := {}
Local aObjects     := {}
Local aInfo        := {}
Local aGet		   := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aExclui      := {}
Local aButtons     := {}
Local aChave       := {}
Local cCodEnt      := ""
Local cCodDesc     := ""
Local cNomEnt      := ""
Local cEntidade    := ""
Local lGravou      := .F.
Local lTravas      := .T.
Local lRet		   := .T.
Local nCntFor      := 0
Local nGetCol      := 0
Local nOpcA	       := 0
Local nScan        := 0
Local oDlg
Local oGetD
Local oGet
Local oGet2
Local oOle
Local oScroll
Local	cQuery    := ""
Local	cSeek     := ""
Local	cWhile    := ""
Local aNoFields := {"AC9_ENTIDA","AC9_CODENT"}
Local bCond     := {|| .T.}
Local bAction1  := {|| SyVerAC9(@aTravas,@aRecAC9,@aRecACB,lTravas,nOper,nOpc) }
Local bAction2  := {|| .F. }

DEFAULT aRecAC9    		:= {}
DEFAULT aRecACB    		:= {}
DEFAULT nOper      		:= 1


PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE INCLUI     := .F.
PRIVATE cSyDir     := "  "
PRIVATE aRotina := {  { OemToAnsi("Pesquisar"),"AxPesqui",0,1,0,.F.},;
{ OemToAnsi("Visual"),"AxVisual" ,0,2,0,NIL},;
{ OemToAnsi("Exclusao"),"U_SyFLDelete" ,0,5,0,NIL} }

cEntidade := cAlias

dbSelectArea( cEntidade )
dbSeek(xfilial(cAlias)+cbusca)

if cEntidade ="SA1"
	cSyDir :="CLIENTE"+cbusca
ElseIf cEntidade = "AF8"
	cSyDir :="PROJETO"+cbusca
Endif
AAdd( aEntidade, { "SA1", { "A1_COD", "A1_LOJA" }, { || SA1->A1_NOME } } )
AAdd( aEntidade, { "AF8", { "AF8_PROJET" }       , { || AF8->AF8_DESCRI } } )

nScan := AScan( aEntidade, { |x| x[1] == cEntidade } )

if nScan > 0
	aChave   := aEntidade[ nScan, 2 ]
	cCodEnt  := MaBuildKey( cEntidade, aChave )
	cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nscan, 3 ] ) )
	cCodEnt  := PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )
	
	dbSelectArea("AC9")
	dbSetOrder(2)
	
	cQuery += "SELECT AC9.*,AC9.R_E_C_N_O_ AC9RECNO FROM " + RetSqlName( "AC9" ) + " AC9 "
	cQuery += "WHERE "
	cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
	cQuery += "AC9_FILENT='" + xFilial( cEntidade ) + "' AND "
	cQuery += "AC9_ENTIDA='" + cEntidade            + "' AND "
	cQuery += "AC9_CODENT='" + cCodEnt              + "' AND "
	cQuery += "D_E_L_E_T_<>'*' ORDER BY " + SqlOrder( AC9->( IndexKey() ) )
	
	cSeek  := xFilial( "AC9" ) + cEntidade + xFilial( cEntidade ) + cCodEnt
	cWhile := "AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT"
	
	
	Do Case
		Case nOper == 1
			
			SX2->( dbSetOrder( 1 ) )
			SX2->( DbSeek( cEntidade ) )
			
			cNomEnt := Capital( X2NOME() )
			
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek("AA2_CODTEC")
			aadd(aGet,{X3Titulo(),SX3->X3_PICTURE,SX3->X3_F3})
			
			dbSelectArea("AC9")
			dbSetOrder(2)
			dbGoTop()
			
			FillGetDados(nOpc,"AC9",2,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,,,cQuery,,,,,,)
			
			If ( lTravas )

				aObjects := {}
				AAdd( aObjects, { 100, 100, .T., .T. } )
				
				aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
				aPosObjMain := MsObjSize( aInfo, aObjects )
				
				aObjects := {}
				
				AAdd( aObjects, { 150, 100, .T., .T. } )
				AAdd( aObjects, { 100, 100, .T., .T., .T. } )
				
				aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 }
				aPosObj := MsObjSize( aInfo, aObjects, .T. , .T. )
				
				aInfo   := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3], 0, 4, 0, 0 }
				
				aObjects := {}
				AAdd( aObjects, { 100,  53, .T., .F., .T. } )
				AAdd( aObjects, { 100, 100, .T., .T. } )
				
				aPosObj2 := MsObjSize( aInfo, aObjects )
				
				aHide := {}
				
				INCLUI  := .T.
				
				AAdd( aButtons, { "MPWIZARD" , { || SyDocWizard( @oGetD ) }, "Inclui documento - Wizard", "Wizard" } )
				AAdd( aButtons, { "NORMAS" ,   { || SyBcoDoc( @oGetD,cbusca,cAlias ) }, "Exclui documento", "Banco de documentos" } )

				DEFINE MSDIALOG oDlg TITLE "Documentação do Projeto" FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
				
				oDlg:lEscClose	:= .F.
				oDlg:lMaximized	:= .T.
				
				@ 0, 0 BITMAP oBmp RESOURCE "PROJETOAP" of oDlg SIZE 100,1000 PIXEL
				
				@ aPosObj2[1,1],aPosObj2[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj2[1,3],aPosObj2[1,4] OF oDlg CENTERED LOWERED
				
				nGetCol := 40
				
				@ 004,005 SAY "Entidade"        SIZE 040,009 OF oPanel  PIXEL
				@ 013,005 GET oGet  VAR cNomEnt  SIZE 090,009 OF oPanel PIXEL WHEN .F.
				
				@ 027,005 SAY "Codigo Descricao"        SIZE 040,009 OF oPanel PIXEL
				@ 036,005 GET oGet2 VAR cCodDesc SIZE aPosObj2[1,3] - 60,009 OF oPanel PIXEL WHEN .F.
				
				oGetd:=MsGetDados():New(aPosObj2[2,1],aPosObj2[2,2],aPosObj2[2,3],aPosObj2[2,4], 2,"SyDocLok","AlwaysTrue",,.T.,NIL,NIL,NIL,1000)
				oScroll := TScrollBox():New( oDlg, aPosObj[2,1], aPosObj[2,2], aPosObj[2,4],aPosObj[2,3])
				
				oOle    := TOleContainer():New( 0, 0, aPosObj2[2,3],aPosObj2[2,4],oScroll, , "" )
				oOle:Hide()
				
				oScroll:Cargo := 1
				
				@  17.5, aPosObj2[1,3] - 45  BUTTON oButPrev PROMPT "Preview" SIZE 040,012 FONT oDlg:oFont ACTION     ( If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ) .and.  GDFieldGet( "AC9_GRV" )="1", ( oGetd:oBrowse:SetFocus(), SyFlPreview( oOle, @aExclui,odlg,ogetd ) ),(Aviso( "Atencao !", "Opção não disponível !", { "Ok" } ), .T. ) )) OF oPanel PIXEL
				@ 34.5, aPosObj2[1,3] - 45  BUTTON oButOpen PROMPT "Abrir"  SIZE 040,012 FONT oDlg:oFont ACTION ( If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ) .and.  GDFieldGet( "AC9_GRV" )="1", ( oGetd:oBrowse:SetFocus(), SyDocOpen( @oOle, @aExclui,odlg,ogetd ) ),(Aviso( "Atencao !", "Opção não disponível !", { "Ok" } ), .T. ) ))  OF oPanel PIXEL
				
				AAdd( aHide, oPanel )
				AAdd( aHide, oGetD  )
				AAdd( aHide, oButPrev )
				AAdd( aHide, oButOpen )
				
				n := 1
				
				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},, aButtons )
				
				If ( nOpcA == 1 )
					Begin Transaction
					lGravou := SyDocGrv( cEntidade, cCodEnt, aRecAC9 )
					If ( lGravou )
						EvalTrigger()
						If ( __lSx8 )
							ConfirmSx8()
						EndIf
					EndIf
					End Transaction
				EndIf
				
				
				If !Empty( aExclui )
					SyDocExclui( aExclui, .F. )
				EndIf
				
			EndIf
			If ( __lSx8 )
				RollBackSx8()
			EndIf
			For nCntFor := 1 To Len(aTravas)
				dbSelectArea(aTravas[nCntFor][1])
				dbGoto(aTravas[nCntFor][2])
				MsUnLock()
			Next nCntFor
			
		Case nOper == 3
			SyDocGrv( cEntidade, cCodEnt, , .T. )
		Case nOper == 4
			SyDocArray( cEntidade, cCodEnt, , , , ,@aRecACB )
	EndCase
Else
	If nOper == 1
		Aviso( "Atencao !", "Nao existe chave de relacionamento definida para o alias " + cAlias, { "Ok" } )
	EndIf
EndIf

RestArea( aArea )

Return(lGravou) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocGrv   ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao / Exclusao da amarracao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyDocGrv( cEntidade, cCodEnt, aRecAC9, lExclui )

Local lGravou   := .F.
Local nLoop     := 0
Local nLoop2    := 0
Local aArea     := {}
Local cQuery    := ""
Local cAliasQry := ""

DEFAULT lExclui := .F.


If lExclui
	
	AC9->( dbSetOrder( 2 ) )
	aArea := GetArea()
	cAliasQry := GetNextAlias()
	
	cQuery := ""
	cQuery += "SELECT AC9.R_E_C_N_O_ AC9RECNO FROM " + RetSqlName( "AC9" ) + " AC9 "
	cQuery += "WHERE "
	cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
	cQuery += "AC9_FILENT='" + xFilial( cEntidade ) + "' AND "
	cQuery += "AC9_ENTIDA='" + cEntidade            + "' AND "
	cQuery += "AC9_CODENT='" + cCodEnt              + "' AND "
	cQuery += "D_E_L_E_T_=' '
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
	
	While !( cAliasQry )->( Eof() )
		lGravou := .T.
		AC9->( dbGoto( ( cAliasQRY )->AC9RECNO ) )
		RecLock( "AC9", .F. )
		AC9->( dbDelete() )
		AC9->( MsUnLock() )
		( cAliasQRY )->( dbSkip() )
	EndDo
	
	( cAliasQry )->( dbCloseArea() )
	
	RestArea( aArea )
Else
	For nLoop := 1 To Len( aCols )
		lGravou := .T.
		If GDDeleted( nLoop )
			If nLoop <= Len( aRecAC9 )
				AC9->( MsGoto( aRecAC9[ nLoop ] ) )
				RecLock( "AC9", .F. )
				AC9->( dbDelete() )
				AC9->( MsUnlock() )
			EndIf
		Else
			If nLoop <= Len( aRecAC9 )
				AC9->( MsGoto( aRecAC9[ nLoop ] ) )
				RecLock( "AC9", .F. )
			Else
				RecLock( "AC9", .T. )
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( cEntidade )
				AC9->AC9_ENTIDA := cEntidade
				AC9->AC9_CODENT := cCodEnt
				AC9->AC9_GRV :="1"
			EndIf
			
			For nLoop2 := 1 To Len( aHeader )
				If ( aHeader[nLoop2,10] <> "V" ) .And. !( AllTrim( aHeader[nLoop2,2] ) $ "AC9_FILENT|AC9_ENTIDA|AC9_CODENT|AC9_GRV" )
					AC9->(FieldPut(FieldPos(aHeader[nLoop2,2]),aCols[nLoop,nLoop2]))
				EndIf
			Next nLoop2
			
			ACB->( dbSetOrder( 2 ) )
			If ACB->( DbSeek( xFilial( "ACB" ) + Upper(GDFieldGet( "AC9_OBJETO", nLoop ) ) ))
				AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
			EndIf
			
			AC9->( MsUnlock() )
		EndIf
	Next nLoop
EndIf

Return( lGravou )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocLOK   ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da linha da amarracao.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyDocLOK()

Local lRet    := .T.
Local nPosObj := GDFieldPos( "AC9_OBJETO" )
Local nLoop   := 0

If !GDDeleted()
	If Empty( GDFieldGet( "AC9_OBJETO" ) )
		lRet := .F.
	EndIf
	If lRet
		For nLoop := 1 To Len( aCols )
			If nLoop <> n .And. !GDDeleted( nLoop )
				If aCols[ nLoop, nPosObj ] == GDFieldGet( "AC9_OBJETO" )
					lRet := .F.
					Help( "", 1, "FTCONTDUP" )
				EndIf 	
			EndIf
		Next nLoop
	EndIf
EndIf	

Return( lRet )  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyFLDelete ³ Autor ³ Cris Barroso         ³ Data ³04/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui documento do banco de documentos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyFLDelete(cAlias,nReg,nOpcx)

Local aPosObj   := {}
Local aObjects  := {}
//Local aSize     := MsAdvSize()
Local aArea     := GetArea()
Local aRecno    := {}
Local aButtons		:= {}
Local bWhile    := {|| .T. }
Local cCadastro := OemToAnsi( "Banco de documentos" )
Local cTrab     := "ACC"
Local lContinua := .T.
Local lAltera   := .F.
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local oGetDad
Local oDlg
Local cSeek  := Nil
Local cWhile := Nil
Local cQuery    := ""

PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}
PRIVATE aExclui := {}
N := 1

AC9->( dbSetOrder( 1 ) )
If AC9->( dbSeek( xFilial( "AC9" ) + ACB->ACB_CODOBJ ) )
	Help( " ", 1, "FT340EXC" )
	lContinua := .F.
EndIf

If lContinua
	dbSelectArea("ACB")
	dbSetOrder(1)
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor
	
	cQuery := "SELECT ACC.*,ACC.R_E_C_N_O_ ACCRECNO "
	cQuery += "FROM "+RetSqlName("ACC")+" ACC "
	cQuery += "WHERE ACC.ACC_FILIAL='"+xFilial("ACC") +"' AND "
	cQuery +=       "ACC.ACC_CODOBJ='"+ACB->ACB_CODOBJ+"' AND "
	cQuery +=       "ACC.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY "+SqlOrder(ACC->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	cTrab  := CriaTrab( , .F. )
	
	cSeek  := xFilial("ACC")+ACB->ACB_CODOBJ
	cWhile :="ACC->ACC_FILIAL+ACC->ACC_CODOBJ"
	
	aCols	:={}
	aHeader :={}
	
	DbSelectArea("ACC")
	dbclosearea()
	
	FillGetDados( nOpcx , "ACC", 1	, cSeek,{||&(cWhile)}, , ,	, , cQuery, ,.F.,, ,{||Ft340Rec(aRecno,.T.,cTrab)},,,cTrab )
	
	If Select(cTrab) > 0
		dbSelectArea(cTrab)
		dbCloseArea()
	Endif
	dbSelectArea(cAlias)
	
	aObjects := {}
	AAdd( aObjects, {  60, 100, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 00,00 To aSize[3],aSize[4] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	
	oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",nOpcx!=2,,,,,,,,)
	
	If ( nOpcx!=2 )
		
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},,aButtons)) CENTERED
		
		
		If ( nOpcA == 1 )
			Begin Transaction
			SyDel(nOpcx,aRecno)
			EvalTrigger()
			End Transaction
		EndIf
	Else
		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},,aButtons)) CENTERED
	EndIf
	
	SyDocExclui( aExclui, .F. )
	
EndIf

MsUnLockAll()
RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDel      ³ Autor ³ Cris Barroso         ³ Data ³04/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Deleta os documentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
  
Static Function SyDel(aRecs)

Local aArea      := GetArea()
Local cCodObj    := M->ACB_CODOBJ
Local cFile      := ""
Local cExten     := ""
Local cDirDocs   := ""
Local nLoop      := 0
Local nLoop2     := 0
Local nPosKeyWrd := GDFieldPos( "ACC_KEYWRD" )
Local nCntSleep  := 0

Begin Transaction

ACB->( dbSetOrder( 1 ) )

If ACB->( dbSeek( xFilial( "ACB" ) + M->ACB_CODOBJ ) )
	cSeekACC := xFilial( "ACC" ) + ACB->ACB_CODOBJ
	If ACC->( dbSeek( cSeekACC ) )
		ACC->( dbEval( { || RecLock( "ACC", .F., .T. ),;
		ACC->( dbDelete() ), ACC->( MsUnLock() ) }, ,{ || cSeekACC;
		== ACC->ACC_FILIAL + ACC->ACC_CODOBJ }, , ,.T. ) )
	EndIf
	cDirDocs := Alltrim( ACB->ACB_PATH )
	RecLock( "ACB", .F., .T. )
	ACB->( dbDelete() )
	ACB->( MsUnLock() )
	
	nCntSleep := 0
	While !Empty( FErase( cDirDocs + "\" + M->ACB_OBJETO )) .And. nCntSleep < 100
		Sleep( 100 )
		nCntSleep++
	EndDo
EndIf

End Transaction

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyFlPreview³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o preview do objeto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyFlPreview( oOle, aExclui,odlg,ogetd, lPreview )

LOCAL   cDirDocs := ""
LOCAL   cFile    := AllTrim( GDFieldGet( "AC9_OBJETO" ) )
LOCAL   lCopied  := .F.

DEFAULT lPreview := .T.

cDirDocs := SyRetPath( cFile )
cPathFile := cDirDocs + "\" + cFile
cTempPath := GetTempPath()
cPathTerm := cTempPath + cFile
lAbre := .T.

If File( cPathTerm )
	lAbre := .F.
	If GDFieldGet( "AC9_PRVIEW" ) <> "1"
		nOpc := Aviso( "Atencao!", " 'O arquivo '"+ Capital( cFile ) +"' ja existe em sua area de trabalho. Qual a acao a ser efetuada ?' "  , { "Sobrepor", "Cancelar" }, 2 )
		If nOpc == 1
			lAbre := .T.
		EndIf
	Else
		lAbre   := .T.
		lCopied := .T.
	EndIf
EndIf

If lAbre
	If !lCopied
		cPathFile := Lower(cPathFile)
		cPathTerm := Lower(cPathTerm)
		Processa( { || lCopied := __CopyFile( cPathFile, ""+cPathTerm ) }, "Transferindo objeto", "Aguarde...", .F. )
	EndIf
	
	If lCopied
		If lPreview
			If !oOle:OpenFromFile( cPathTerm, .F. )
				Help( " ", 1, "MSDOCOPEN" )
			Else
				GDFieldPut( "AC9_PRVIEW", "1" )
				oOle:Show()
				@  17.5, aPosObj2[1,3] - 45  BUTTON oButPrev PROMPT "Close Preview" SIZE 040,012 FONT oDlg:oFont ACTION   ( oGetd:oBrowse:SetFocus(), SyClPreview( oOle, @aExclui,odlg,ogetd) ) OF oPanel PIXEL
			EndIf
		EndIf
	Else
		GDFieldPut( "AC9_PRVIEW", "1" )
		oOle:Show()
		@  17.5, aPosObj2[1,3] - 45  BUTTON oButPrev PROMPT "Close Preview" SIZE 040,012 FONT oDlg:oFont ACTION   ( oGetd:oBrowse:SetFocus(), SyClPreview( oOle, @aExclui,odlg,ogetd ) ) OF oPanel PIXEL
	EndIf
Else
	Aviso( "Atencao !", "'Nao foi possivel efetuar a transferencia do arquivo '" + cFile + "' do banco de conhecimento para a area de trabalho ! '", { "Ok" }, 2 )
EndIf

If Empty( AScan( aExclui, cPathTerm ) )
	AAdd( aExclui, cPathTerm )
EndIf

Return(.T.)
 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyClPreview³ Autor ³ Cris Barroso         ³ Data ³04/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fecha o Preview                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyClPreview( oOle, aExclui,odlg,ogetd )

oGetd:oBrowse:SetFocus()
oOle:Hide()
@  17.5, aPosObj2[1,3] - 45  BUTTON oButPrev PROMPT "Preview" SIZE 040,012 FONT oDlg:oFont ACTION  ( If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ) .and.  GDFieldGet( "AC9_GRV" )="1", ( oGetd:oBrowse:SetFocus(), SyFlPreview( oOle, @aExclui,odlg,ogetd ) ),(Aviso( "Atencao !", "Opção não disponível !", { "Ok" } ), .T. )) ) OF oPanel PIXEL      

Return(.T.) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyBcoDoc   ³ Autor ³ Cris Barroso         ³ Data ³04/06/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Browse do banco de conhecimento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyBcoDoc( oGetDad,cbusca,cAlias )

Local cFiltra := "SUBSTRING(ACB_PATH,18,"+STRZERO(LEN(cbusca),2,0)+") = '"+cbusca+"' "    
  
Private cCadastro := "Banco de Documentos"
Private aIndexDoc := {}
Private bFiltraBrw:= {} 
Private aRotAuto := Nil
nrec:= 0
bFiltraBrw:= { || FilBrowse("ACB",@aIndexDoc,@cFiltra) } 
Eval(bFiltraBrw)

mBrowse(6,1, 22,75,"ACB",,,,,,,,,,,.T.,)   

EndFilBrw("ACB",aIndexDoc)  

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocOpen  ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a abertura do documento posicionado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyDocOpen( oOle, aExclui,odlg,ogetd )

Local cOper     := "open"  
Local cFileName := ""
Local cParam    := ""
Local cDir      := ""
Local cDrive    := ""
Local nRet      := 0

cFileName := GetTempPath() + AllTrim( GDFieldGet( "AC9_OBJETO" ) )

If !Empty(cFileName)
	If GDFieldGet( "AC9_PRVIEW" ) <> "1"
		SyFlPreview( @oOle, @aExclui, odlg,ogetd,.F. )
	EndIf
	
	SplitPath(cFileName, @cDrive, @cDir )
	
	cDir := Alltrim(cDrive) + Alltrim(cDir)
	nRet := ShellExecute(cOper,cFileName,cParam,cDir, 1 )
	If nRet <= 32
		Aviso( "Atencao!", "'Nao foi possivel abrir o objeto '" + cFileName + "'!'", { "Ok" }, 2 )
	EndIf
Endif

Return( .T. )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocExclui³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui arquivos do diretorio temporario do windows         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyDocExclui( aExclui, lPergunta )

Local lRet        := .F.
Local lErro       := .F.
Local nRet        := 0
Local nLoop       := 0

DEFAULT lPergunta := .T.


If !Empty( aExclui )
	If !lPergunta .Or. Aviso( "Atencao" , "Esta rotina posicionou alguns arquivos em sua area temporaria. Deseja exclui-los ?", { "Sim", "Nao" }, 2 ) == 1
		lErro := .F.
		For nLoop := 1 To Len( aExclui )
			nRet := FErase( aExclui[ nLoop ] )
			lErro := If( lErro, .T., !Empty( nRet ) )
		Next nLoop
		If lErro
			If lPergunta
				Help( " ", 1, "MSDOCEXCLU" )
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyVerAC9   ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ AC9, adicionar recno no array aRecAC9 utilizado na gravacao³±±
±±³          ³ da tabela AC9 e verificar se conseguiu travar AC9.         ³±±
±±³          ³ Se retornar .T. considera o registro.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyVerAC9(aTravas,aRecAC9,aRecACB,lTravas,nOper,nOpc)

Local nTipo := IIf(nOper == 1,2,1)
Local lRet := .T.
Local nRecNoAC9

DEFAULT nOpc 	:= 2

nRecNoAC9 := AC9RECNO
AC9->( dbGoto( nRecNoAC9 ) )

If nTipo == 2 .AND. nOpc <> 2
	If ( SoftLock("AC9" ) )
		AAdd(aTravas,{ Alias() , RecNo() })
	Else
		lTravas := .F.
	EndIf
EndIf
AAdd(aRecAC9, AC9->( Recno() ) )
If nTipo == 1
	ACB->( dbSetOrder( 1 ) )
	If ACB->( dbSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ ) )
		AAdd( aRecACB, ACB->( RecNo() ) )
	EndIf
	lRet := .F.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyRetPath  ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o path do arquivo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyRetPath( cFile )

Local aArea		:= GetArea()
Local aAreaACB	:= ACB->( GetArea() )
Local cDirDoc	:= SyDocPath()

Default cFile	:= ""

If !Empty( cFile )
	ACB->( dbSetOrder( 2 ) )
	If ACB->( dbSeek( xFilial( "ACB" ) + Upper( cFile ) ) )
		If !Empty( Alltrim( ACB->ACB_PATH ) )
			cDirDoc := Alltrim( ACB->ACB_PATH )
		Else
			cDirDoc := SyDocPath()
		Endif
	Endif
Endif


RestArea( aAreaACB )
RestArea( aArea )

Return(cDirDoc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocPath  ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve o path do arquivo e cria caso nao exista           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyDocPath()

Local aDirStruct := {}
Local cDirDoc		:= ""
Local nRetCode		:= 0
Local cPasta		:= ""

AAdd( aDirStruct,  "\SYMMDOC" )
AAdd( aDirStruct,  substring(cSyDir,1,7) )
AAdd( aDirStruct,  substring(cSyDir,8,len(cSyDir)-7) )

cDirDoc := aDirStruct[ 1 ] + "\" + aDirStruct[ 2 ] + "\" + aDirStruct[ 3 ]


If Empty( StrTran( aDirStruct[ 1 ], "\", "" ) )
	Help( " ", 1, "DIRDOCPAR" )
EndIf
If Empty( Directory( cDirDoc, "D" ) )
	cPasta := ( aDirStruct[ 1 ] )
	If !ExistDir( cPasta ) .And. Empty( Directory( cPasta, "D" ) )
		nRetCode := MakeDir( cPasta )
	EndIf
	cPasta := ( aDirStruct[ 1 ] + "\" + aDirStruct[ 2 ] )
	If Empty( nRetCode ) .And. !ExistDir( cPasta ) .And. Empty( Directory( cPasta, "D" ) )
		nRetCode := MakeDir( cPasta )
	EndIf
	cPasta := ( aDirStruct[ 1 ] + "\" + aDirStruct[ 2 ] + "\" + aDirStruct[ 3 ] )
	If Empty( nRetCode ) .And. !ExistDir( cPasta ) .And. Empty( Directory( cPasta, "D" ) )
		nRetCode := MakeDir( cPasta )
	EndIf
	If !Empty( nRetCode )
		Help( " ", 1, "DIRDOCCREA" )
	EndIf
EndIf

Return(cDirDoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SyDocWizard³ Autor ³ Cris Barroso          ³ Data ³31/05/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Wizard para inclusao de conhecimentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SYPMSC100                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyDocWizard( oGetDad )  

Local aEnd1      := {}    
Local aColsWiz   := {} 
Local aHeaderWiz := {}
Local cBitmap    := "PROJETOAP"
Local cObj       := CriaVar( "ACB_OBJETO", .F. )
Local cDescri    := CriaVar( "ACB_DESCRI", .F. )
Local lRet       := .F.
Local nRadio1    := 1  
Local nCntFor    := 0
Local oRadio1
Local oWizard   
Local oPanel      
Local oPanel2      

If Empty( GDFieldGet( "AC9_OBJETO" ) ) .Or. SyDocLOK() 

	dbSelectArea("SX3")
	dbSetOrder(1)
	DbSeek("ACC")
    While ( !Eof() .And. SX3->X3_ARQUIVO == "ACC" )
    	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
    		Aadd(aHeaderWiz, {   AllTrim(X3Titulo()),;
    		SX3->X3_CAMPO,;
     		SX3->X3_PICTURE,;
    		SX3->X3_TAMANHO,;
    	   	SX3->X3_DECIMAL,;
    		SX3->X3_VALID,;
    		SX3->X3_USADO,;
     		SX3->X3_TIPO,;
    		SX3->X3_F3,;
    		SX3->X3_CONTEXT,;
    		X3Cbox(),;
    		SX3->X3_RELACAO,".T."})
    	EndIf
    	dbSelectArea("SX3")
    	dbSkip()
	EndDo
	
	nUsado := Len( aHeaderWiz ) 
	
	AAdd(aColsWiz,Array(nUsado+1))
	For nCntFor	:= 1 To nUsado
		aColsWiz[1,nCntFor] := CriaVar(aHeaderWiz[nCntFor,2])
	Next nCntFor
	aColsWiz[1,nUsado+1] := .F.
	
		DEFINE WIZARD oWizard TITLE "Assistente para inclusao e vinculo de documentos"  HEADER "Selecao do objeto";  
			MESSAGE "Selecione o objeto a ser incluido no banco de documentos, clicando no botao selecionar " TEXT " "; 
			NEXT {|| SyDocWzV1( cObj ) } FINISH {|| .t. } PANEL NOFIRSTPANEL 
		  
		@ 50,50  SAY "Objeto " of oWizard:GetPanel(1) PIXEL 
		@ 60,50  GET oObj VAR cObj SIZE 200,10 of oWizard:GetPanel(1) PIXEL READONLY 
		@ 76,210 BUTTON oButSel PROMPT "Selecionar"  SIZE 40, 12 OF oWizard:GetPanel(1) ACTION ( SyDocWzGet( @cObj, @cDescri ) ) PIXEL  

		CREATE PANEL oWizard  HEADER "Dados genericos" MESSAGE "Confirme clicando no botao Finalizar ";  
				 BACK {||.T.} FINISH  {|| aColsWiz := oGetD:aCols, SyDocWzEnd( cObj, cDescri, aHeaderWiz, aColsWiz, .T., oGetDad ) } PANEL   
	
		@ 15,50 SAY "Descricao"  of oWizard:GetPanel(2) PIXEL  
		@ 25,50 GET oDescri VAR cDescri VALID NaoVazio(cDescri) SIZE 200,10 of oWizard:GetPanel(2) PIXEL  
		
		@ 45, 50 SAY "Palavras chave ( opcional )" of oWizard:GetPanel(2) PIXEL  
		oGetD := MsNewGetDados():New(55, 50, 115, 250, GD_INSERT+GD_UPDATE+GD_DELETE,"SyLOK",,,,,100,,,,oWizard:GetPanel(2),aHeaderWIZ,aColsWiz)
		
	ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}
	
EndIf 
                      
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocWzV1  ³ Autor ³ Cris Barroso         ³ Data ³02/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo objeto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyDocWzV1( cObj )   

Local lRet := .T. 

If Empty( cObj )                 
	Help( " ", 1, "NVAZIO" ) 
	lRet := .F.
EndIf

Return(lRet)                                         
                                                                                     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocWzGet ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao do objeto                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyDocWzGet( cObj, cDescri )
               
Local cExten   := "" 
Local nTamDesc := Len( cDescri ) 

SyGetObj( @cObj )   

cObj := Upper( cObj ) 

SplitPath( cObj,,, @cDescri, @cExten )

If Len( AllTrim( cDescri ) ) > nTamDesc
	cDescri := Left( cDescri, nTamDesc - 3 ) + "..." 
EndIf      

cDescri := Pad( cDescri, nTamDesc ) 
cDescri := Upper( cDescri ) 

Return                                                 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocWzEnd ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de encerramento do Wizard                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyDocWzEnd( cObj, cDescri, aHeaderWiz, aColsWiz, lAssocia, oGetDad )

Local lRet    := .T.
Local nCntFor := 0

lRet := SyDocWzGrv( @cObj, @cDescri, aHeaderWiz, aColsWiz  )

If lRet
	If lAssocia
		nUsado := Len( aHeader )
		If !Empty( GDFieldGet( "AC9_OBJETO" ) )
			AAdd(aCols,Array(nUsado+1))
		EndIf
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := AC9->(FieldGet(FieldPos(aHeader[nCntFor][2])))
				If ExistIni(aHeader[nCntFor][2]) .And. Empty(aCols[Len(aCols)][nCntFor])
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				Endif
			Else
				If AllTrim( aHeader[nCntFor][2] ) == "AC9_OBJETO"
					aCols[Len(aCols)][nCntFor] := cObj
				ElseIf AllTrim( aHeader[nCntFor][2] ) == "AC9_DESCRI"
					aCols[Len(aCols)][nCntFor] := cDescri
				ElseIf !IsHeadRec( aHeader[nCntFor][2] )  .And. !IsHeadAlias( aHeader[nCntFor][2] )
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			EndIf
		Next
		aCols[Len(aCols)][nUsado+1] := .F.
		n := Len( aCols )
		oGetDad:oBrowse:nAt := N
		oGetDad:oBrowse:Refresh()
	EndIf
EndIf

oGetDad:lNewLine := .F.

Return(lRet) 
                                                    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyDocWzGrv ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de gravacao do Wizard                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyDocWzGrv( cObj, cDescri, aHeaderWiz, aColsWiz )
       
Local aRecno   := {}        
Local nSaveSX8 := 0 

Private aCols   := AClone( aColsWiz ) 
Private aHeader := AClone( aHeaderWiz ) 

M->ACB_OBJETO := cObj 

lRet := SyCpyObj( cObj )          

If lRet
	nSaveSX8 := GetSX8Len()
	M->ACB_CODOBJ := GetSXENum( "ACB", "ACB_CODOBJ" )
	M->ACB_DESCRI := cDescri
	cObj    := M->ACB_OBJETO
	cDescri := M->ACB_DESCRI
	SyGrv(1,aRecno)
	While (GetSx8Len() > nSaveSx8)
		ConfirmSX8()
	EndDo
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyGetObj   ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem o objeto a ser incluido no banco de conhecimentos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC01                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyGetObj(cObjeto)

Local cFile := ""

cFile := cGetFile( "Todos (*.*) |*.*|","Todos os arquivos",0,GetMv("MV_SPLPATH",.F.,"C:\"),.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.)


If cObjeto == NIL
	M->ACB_OBJETO := cFile
	M->ACB_TAMANH := SyTaman( M->ACB_OBJETO )
Else
	If !Empty( cFile )
		cObjeto := cFile
	EndIf
EndIf

Return(.T.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyTaman    ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Devolve o tamanho do arquivo do banco de conhecimento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyTaman( cFilePath )

Local aDir        := {}
Local cDirDocs	  := ""
Local cTamanho    := ""

DEFAULT cFilePath := ""

If !INCLUI .Or. !Empty( cFilePath )
	If Empty( cFilePath )  .And. !Empty(ACB->ACB_OBJETO)
		cDirDocs := MsRetPath( ACB->ACB_OBJETO )
		cDirDocs  := If( Right( cDirDocs, 1 ) == "\", Left( cDirDocs, Len( cDirDocs ) -1 ), cDirDocs )
		aDir      := Directory( Alltrim(cDirDocs + "\" +ACB->ACB_OBJETO ) )
	Else
		aDir      := Directory( cFilePath )
	EndIf
	If !Empty( aDir )
		cTamanho  := AllTrim( Str( aDir[ 1, 2 ] / 1024, 12 ) + " KB" )
	EndIf
EndIf

Return(cTamanho)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyCpyObj   ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia o objeto para o diretorio do banco de conhecimentos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyCpyObj( cGetFile, lVerifExis )

Local   cDirDocs   := ""
Local   cFile      := ""
Local   cExten     := ""
Local   cRmvName   := ""
Local   cNameTerm  := ""
Local   cNameServ  := ""
Local   cGet       := ""
Local   lRet       := .T.
Local   nOpca      := 0
Local   nCount     := 0
Local   oDlgNome
Local   oBut1
Local   oBut2
Local   oBmp
Local   oGet1
Local   oBold
Local 	aFiles

DEFAULT lVerifExis := .T.

aFiles := Directory(cGetFile, "D")
cGetFile := AllTrim( cGetFile )
SplitPath( cGetFile, , , @cFile, @cExten )
cNameTerm := cFile + cExten
cRmvName := SyRmvAc( cfile )
cNameServ := dtos(ddatabase)+"_"+substring(cSyDir,8,len(cSyDir)-7)+"_"+cRmvName+cExten
cDirDocs := SyRetPath( cNameServ )

If File( cDirDocs + "\" + cNameServ )
	lRet := .F.
	Aviso( "Atencao!", "O arquivo '" + cFile + cExten + ;
	"' nao pode ser incluido pois ja existe no diretorio do banco de conhecimento." + ;
	"Verifique e altere o nome antes de importar !", { "Ok" }, 2 )
Else
	lRet := .T.
EndIf
If lRet
	Processa( { || __CopyFile( cGetFile, cDirDocs + "\" + cNameServ ),lRet := File( cDirDocs + "\" + cNameServ ) }, "Transferindo objeto","Aguarde..." ,.F.)
	M->ACB_OBJETO := cNameServ
EndIf

If !lRet
	Help( " ", 1, "FT340CPT2S" )
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyRmvAc    ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Remove acentos de uma string                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyRmvAc( cString ) 
                 
Local cNewString := ""
Local cAddChar   := ""
Local cChar      := ""
Local cString    := upper(cString)
Local nLoop      := 0 

For nLoop := 1 To Len( cString )
	cChar := SubStr( cString, nLoop, 1 )
	Do Case
		Case (Asc(cChar) > 191 .and. Asc(cChar) < 198)
			cChar := "A"
		Case (Asc(cChar) > 199 .and. Asc(cChar) < 204)
			cChar := "E"
		Case (Asc(cChar) > 204 .and. Asc(cChar) < 207)
			cChar := "I"
		Case (Asc(cChar) > 209 .and. Asc(cChar) < 215)
			cChar := "O"
		Case (Asc(cChar) > 216 .and. Asc(cChar) < 221)
			cChar := "U"
		Case Asc(cChar) == 199
			cChar := "C"
	EndCase
	cNewString := cNewString+cChar
Next

Return(cNewString)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SyGrv      ³ Autor ³ Cris Barroso         ³ Data ³31/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Gravacao do Banco de Conhecimento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyGrv( nTipo, aRecs )

Local aArea      := GetArea()
Local cCodObj    := M->ACB_CODOBJ
Local cFile      := ""
Local cExten     := ""
Local cDirDocs   := ""
Local nLoop      := 0
Local nLoop2     := 0
Local nPosKeyWrd := GDFieldPos( "ACC_KEYWRD" )
Local nCntSleep  := 0

Begin Transaction

Do Case
	Case nTipo <> 3
		
		If nTipo == 1
			cObjeto := M->ACB_OBJETO
			SplitPath( cObjeto,,, @cFile, @cExten )
			M->ACB_OBJETO := Left( Upper( cFile + cExten ), Len( ACB->ACB_OBJETO ) )
		EndIf
		
		cSeekACB := xFilial( "ACB" ) + cCodObj
		
		ACB->( dbSetOrder( 1 ) )
		
		If ACB->( dbSeek( cSeekACB ) )
			RecLock( "ACB", .F. )
		Else
			RecLock( "ACB", .T. )
			ACB->ACB_FILIAL  := xFilial( "ACB" )
			ACB->ACB_CODOBJ  := M->ACB_CODOBJ
			ACB->ACB_PATH	:= SyRetPath( M->ACB_OBJETO )
		EndIf
		
		dbSelectArea( "ACB" )
		
		For nLoop := 1 To FCount()
			cCampo := FieldName( nLoop )
			cTpCpo:= FWSX3Util():GetFieldType( cCampo ) 
			If !( cCampo $ "ACB_FILIAL/ACB_CODOBJ/ACB_PATH" ) .And. cTpCpo <>"U"
				FieldPut( nLoop, M->&cCampo )
			EndIf
		Next nLoop
		
		ACB->( MsUnlock() )
		
		For nLoop := 1 To Len( aCols )
			If !( Len( aCols ) == 1 .And. ( Empty( aCols[ 1, nPosKeyWrd ] ) ) )
				If nLoop > Len( aRecs )
					If !GDDeleted( nLoop )
						RecLock( "ACC", .T. )
					EndIf
				Else
					ACC->( dbGoto( aRecs[ nLoop ] ) )
					RecLock( "ACC", .F. )
				EndIf
				If !GDDeleted( nLoop )
					ACC->ACC_FILIAL  := xFilial( "ACC" )
					ACC->ACC_CODOBJ  := ACB->ACB_CODOBJ
					dbSelectArea( "ACC" )
					For nLoop2 := 1 To Len( aHeader )
						cCampoAh  := AllTrim( aHeader[ nLoop2, 2 ] )
						If !( cCampoAh $ "ACC_CODOBJ/ACC_FILIAL" )
							nPosArq := ACC->( FieldPos( cCampoAh ) )
							If !Empty( nPosArq )
								ACC->( FieldPut( nPosArq, aCols[ nLoop, nLoop2 ] ) )
							EndIf
						EndIf
					Next nLoop2
				Else
					If nLoop <= Len( aRecs )
						ACC->( dbDelete() )
					EndIf
				EndIf
				ACC->( MsUnLock() )
			EndIf
		Next nLoop
	Otherwise
		ACB->( dbSetOrder( 1 ) )
		If ACB->( dbSeek( xFilial( "ACB" ) + M->ACB_CODOBJ ) )
			cSeekACC := xFilial( "ACC" ) + ACB->ACB_CODOBJ
			If ACC->( dbSeek( cSeekACC ) )
				ACC->( dbEval( { || RecLock( "ACC", .F., .T. ),;
				ACC->( dbDelete() ), ACC->( MsUnLock() ) }, ,{ || cSeekACC;
				== ACC->ACC_FILIAL + ACC->ACC_CODOBJ }, , ,.T. ) )
			EndIf
			cDirDocs := Alltrim( ACB->ACB_PATH )
			RecLock( "ACB", .F., .T. )
			ACB->( dbDelete() )
			ACB->( MsUnLock() )
			nCntSleep := 0
			While !Empty( FErase( cDirDocs + "\" + M->ACB_OBJETO )) .And. nCntSleep < 100
				Sleep( 100 )
				nCntSleep++
			EndDo
		EndIf
EndCase

End Transaction
RestArea(aArea)

Return(.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vldcontatoºAutor  ³Microsiga           º Data ³  07/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida contato ja informado                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VLDCONTATO()

Local aCont:= {}
Local nX   := 0
Local nPos := 0

For nX:= 1 To Len (oGetCon:aCols)
	If !oGetCon:aCols[nX,Len(oGetCon:aHeader)+1]
		nPos:= aScan(aCont,{|x| x[1] == oGetCon:aCols[nX,1]})
		If (nPos == 0)
			aAdd(aCont,{oGetCon:aCols[nX,1],1})
		Else
			Aviso("Atencao","Existem contatos duplicados. Favor alterar !",{"Ok"})
			Return(.F.)	
		EndIf
	EndIf	
Next nX

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYPRJVALOSºAutor  ³Microsiga           º Data ³  05/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyPrjValOS(cProjeto)

Local oTelaOS
Local aSize    	 	:= MsAdvSize()
Local oPanDlg
Local oFwLayer
Local oPanel1
Local oPanel2
Local oPanel3
Local oPanel4
Local oMemoOS
Local aColsREC		:= {}
Local aHeadREC 		:= {}
Local aButtons   	:= {}
Local nlOrdemCols	:= .F.      
Local bBlock		:= {|x|}
Local nStyle		:= 0
Local nOpcao		:= 0
Local aAlter		:= {}
Local cMemoOS       := ''
Local cSay			:= ''

Private oOk			:= LoadBitMap(GetResources(), "LBOK")
Private oNo			:= LoadBitMap(GetResources(), "LBNO")
Private aColsOS    	:= {}
Private aHeadOS    	:= {}
Private aColsItens 	:= {}
Private aHeadItens 	:= {}
Private oGetOS
Private oGetItens
Private oGetRecursos
Private cproj       := " " 
Private cCodSer     :=" "  
PRIVATE cCoord      :=" "

INCLUI:= .F.

Aadd(aButtons  , { "ALTERA"	 		, {|| SyAltOS(cProjeto) }															, "Altera OS" 	} )
Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_SyExporExcel("Ordens de Serviço",oGetOS:aHeader,oGetOS:aCols,lDiretoria) } 	, "Exportar"	} )

LjMsgRun("Aguarde, Filtrando Ordens de Serviço..."	,,{||SYOSACOLS(cProjeto,.T.) })
LjMsgRun("Aguarde, Filtrando Atividade da OS..."	,,{||SYOSACOLS(cProjeto,.F.,aColsOS[1,aScan( aHeadOS, {|x| AllTrim(x[2]) == "Z2_OS"})]) })
LjMsgRun("Aguarde, Agrupando Recursos x Horas..."	,,{||SyAtuTarefas(cProjeto,@aHeadRec,@aColsRec) })

AF8->(DbSetOrder(1))
AF8->( DbSeek(xFilial("AF8")+cProjeto) )

SA1->(DbSetOrder(1))
SA1->( DbSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA) )

cSay := Alltrim(SA1->A1_NOME) +" - "+ AF8->AF8_PROJET +" / "+ AF8->AF8_DESCRI

DEFINE MSDIALOG oTelaOS FROM 0,0  TO aSize[6], aSize[5] TITLE "Projeto: " + cSay OF oMainWnd PIXEL

oPanDlg:= TPanel():New(0, 0, "", oTelaOS, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPanDlg:Align:= CONTROL_ALIGN_ALLCLIENT

oFwLayer := FwLayer():New()
oFwLayer:Init(oPanDlg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Linha 1 - Cab.OS        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFWLayer:addLine("LINHA1",050, .F.)

oFWLayer:addCollumn("COL1",070, .T. , "LINHA1")
oFWLayer:addCollumn("COL2",030, .T. , "LINHA1")

oFWLayer:addWindow("COL1", "oPanel1", "Ordens de Serviço: " + cSay 	,100, .T., .F.,  {|| oGetOS:Refresh(),oGetOS:oWnd:Refresh() }	, "LINHA1")
oFWLayer:addWindow("COL2", "oPanel2", "Total Horas por Analista"	,100, .T., .F., 												, "LINHA1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Linha 2 - Resumo        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFWLayer:addLine("LINHA2",050, .F.)

oFWLayer:addCollumn("COL1"	,040, .F. , "LINHA2")
oFWLayer:addCollumn("COL2"	,060, .F. , "LINHA2")

oFWLayer:addWindow( "COL1", "oPanel3", "Itens de OS"			,100, .T., .F., , "LINHA2")
oFWLayer:addWindow( "COL2", "oPanel4", "Atividade Realizada"	,100, .T., .F., , "LINHA2")

oPanel1	:= oFWLayer:GetWinPanel("COL1", "oPanel1","LINHA1")
oPanel2	:= oFWLayer:GetWinPanel("COL2", "oPanel2","LINHA1")
oPanel3	:= oFWLayer:GetWinPanel("COL1", "oPanel3","LINHA2")
oPanel4	:= oFWLayer:GetWinPanel("COL2", "oPanel4","LINHA2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ OS                                       					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetOS:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanel1,aHeadOS,aColsOS)
oGetOS:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
oGetOS:oBrowse:bHeaderClick	:= { |oObj,nCol| U_SyOrdCab(nCol,@oGetOS,@nlOrdemCols),Eval(oGetOS:oBrowse:bLDblClick) }
oGetOS:oBrowse:bChange  	:= {||	SYOSACOLS(cProjeto,.F.,oGetOS:aCols[oGetOS:nAT,aScan( aHeadOS,{|x| AllTrim(x[2]) == "Z2_OS"})]),;
									oGetItens:aCols:= aColsItens,;
									oGetItens:oBrowse:Refresh(),;
									cMemoOS:= oGetItens:aCols[oGetItens:nAT,aScan(aHeadItens,{|x| AllTrim(x[2]) == "Z3_OBS"})],;
									oMemoOS:Refresh() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo de Recurso x Horas                					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetRecursos:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",,,,,,,oPanel2,aHeadREC,aColsREC)
oGetRecursos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Itens de OS                              					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetItens:= MsNewGetDados():New(0,0,0,0,nStyle,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanel3,aHeadItens,aColsItens)
oGetItens:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetItens:oBrowse:bChange  	:= {|| 	cMemoOS:= oGetItens:aCols[oGetItens:nAT,aScan(aHeadItens,{|x| AllTrim(x[2]) == "Z3_OBS"})],;
									oMemoOS:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MEMO											 			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 0,0 GET oMemoOS VAR cMemoOS MEMO When .T. OF oPanel4 PIXEL 
oMemoOS:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oTelaOS ON INIT ( EnchoiceBar(oTelaOS,{|| ( nOpcao:= 1,oTelaOS:End()) }, {|| (oTelaOS:End()) },,aButtons) )

aColsOS    := {}
aHeadOS    := {}
aColsItens := {}
aHeadItens := {}

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

Static Function SYOSACOLS(cProjeto,lCab,cOS) 

Local aArea     := GetArea()
Local lRet		 := .T.							//Retorno da funcao
Local nPos       := 0
Local nX         := 1
Local nOS        := 0
Local cQryTmp    := ''
Local aCamposSZ2 := {}
Local aCamposSZ3 := {}
Local aStatus	 := {,,,,,,,}
Local nCntFor    := 0

Default cOS 	 := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader a partir dos campos do SX3         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCab

	aStatus[1] := LoadBitmap(GetResources(), "SYESTRELA.JPG"	)	// Pago
	aStatus[2] := LoadBitmap(GetResources(), "BR_PINK" 		)	// Pendente
	aStatus[3] := LoadBitmap(GetResources(), "BR_AMARELO"		)	// Encerrada
	aStatus[4] := LoadBitmap(GetResources(), "BR_AZUL"		)		// Validada
	aStatus[5] := LoadBitmap(GetResources(), "BR_MARROM"		)	// Entregue
	aStatus[6] := LoadBitmap(GetResources(), "BR_VERDE"		)	// Aprovada Cliente
	aStatus[7] := LoadBitmap(GetResources(), "BR_PRETO"		)	// Reprovada Cliente
	aStatus[8] := LoadBitmap(GetResources(), "BR_VERMELHO"	)		// Reprovada Coorden
	
	aCamposSZ2 := { 'Z2_STATUS','Z2_DATA','Z2_OS','Z2_RECURSO',	'Z2_NOME',;
	'Z2_TOTALHR','Z2_HRINI1','Z2_HRFIM1','Z2_HRINI2','Z2_HRFIM2',;
	'Z2_HABONO','Z2_HUTEIS','Z2_TPATEND','Z2_PEDAGIO','Z2_VLESTAC'}
    
	aCamposSZ3 := {'Z3_ITEM','AF9_DESCRI','Z3_HORAS','Z3_PERC','Z3_HABONO','Z3_TPDESC','Z3_MOTIVO', 'Z3_PROJETO' , 'Z3_TAREFA' , 'Z3_REVISA',"Z3_OBS"}

	aHeadOS:= {}

	Aadd(aHeadOS,{"","Z2_OK","@BMP",02	,0,".F.","û","C",""	," " } )
	
	DbSelectArea("SX3")
	DbSetorder(2)
	For nX := 1 To Len(aCamposSZ2)
		
		MsSeek(aCamposSZ2[nX])
		
		Aadd(aHeadOS,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	
	Next

	aHeadItens := {}
	DbSelectArea("SX3")
	DbSetorder(2)
	
	For nX := 1 To Len(aCamposSZ3)
		
		MsSeek(aCamposSZ3[nX])
		
		Aadd(aHeadItens,{ AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	
	Next

	//Verifica as OS do projeto
	cQryTmp := " SELECT DISTINCT SZ2.*,SZ2.R_E_C_N_O_ Z2RECNO "
	cQryTmp += " FROM " + RetSqlName("SZ2") + " SZ2," + RetSqlName("SZ3") + " SZ3," + RetSqlName("AF8") + " AF8"
	cQryTmp += " WHERE SZ2.D_E_L_E_T_ <> '*' "
	cQryTmp += " AND   SZ3.D_E_L_E_T_ <> '*' "
	cQryTmp += " AND   AF8.D_E_L_E_T_ <> '*' " 
	cQryTmp += " AND   SZ2.Z2_FILIAL   = '"  + xFilial("SZ2") + "'"
	cQryTmp += " AND   SZ3.Z3_FILIAL   = '"  + xFilial("SZ3") + "'"
	cQryTmp += " AND   AF8.AF8_FILIAL  = '"  + xFilial("AF8") + "'"
	cQryTmp += " AND   AF8.AF8_PROJET  = '"  + cProjeto 	+ "'"
	cQryTmp += " AND   SZ2.Z2_OS       = SZ3.Z3_OS "
	cQryTmp += " AND   SZ3.Z3_PROJETO  = AF8.AF8_PROJET "
	cQryTmp += " ORDER BY Z2_OS DESC "
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)

	aStru:= SZ2->(dbStruct())
	aEval(aStru, {|e| If(e[2] != "C", TCSetField("TMP", e[1], e[2],e[3],e[4]),Nil)})
	
	DbSelectArea("TMP")
	DbGoTop()
	While !TMP->(Eof())
		
		SZ2->(dbGoTo(TMP->Z2RECNO))

		Aadd(aColsOS,Array(Len(aHeadOS)+1))
		
		For nCntFor	:= 1 To Len(aHeadOS)
			
			If AllTrim(aHeadOS[nCntFor,2]) == "Z2_OK"

				IF SZ2->Z2_STATUS == '1' // Pendente
					aColsOS[Len(aColsOS),nCntFor] := aStatus[2]
				ElseIF SZ2->Z2_STATUS == '2' // Encerrada
					aColsOS[Len(aColsOS),nCntFor] := aStatus[3]
				ElseIF SZ2->Z2_STATUS == '3' // Validada
					aColsOS[Len(aColsOS),nCntFor] := aStatus[4]
				ElseIF SZ2->Z2_STATUS == '4' // Entregue
					aColsOS[Len(aColsOS),nCntFor] := aStatus[5]
				ElseIF SZ2->Z2_STATUS == '5' // Aprovada Cliente
					aColsOS[Len(aColsOS),nCntFor] := aStatus[6]
				ElseIF SZ2->Z2_STATUS == '6' // Reprovada Cliente
					aColsOS[Len(aColsOS),nCntFor] := aStatus[7]
				ElseIF SZ2->Z2_STATUS == '7' // Reprovada Coordenador
					aColsOS[Len(aColsOS),nCntFor] := aStatus[8]
				EndIF
			
			ElseIF ( aHeadOS[nCntFor,10] != "V" )
				aColsOS[Len(aColsOS),nCntFor] := TMP->( FieldGet(FieldPos(aHeadOS[nCntFor,2])) )
			Else
				aColsOS[Len(aColsOS),nCntFor] := CriaVar(aHeadOS[nCntFor,2])
			EndIF
		Next nCntFor
		
		aColsOS[Len(aColsOS),Len(aHeadOS)+1] := .F.
	
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
		AAdd(aColsOS,Array(Len(aHeadOS)+1))
		For nX := 1 To Len(aHeadOS)
			If AllTrim(aHeadOS[nX,2]) == "Z2_OK"
				aColsOS[1,nX] := oNo
			Else
				aColsOS[1,nX] := CriaVar(aHeadOS[nX,2],.F.)															
			EndIf	
		Next nX
		aColsOS[1,Len(aHeadOS)+1] := .F.
	EndIF

Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as tarefas apontadas.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsItens:= {}
	nPos:= aScan(aHeadOS,{|x| AllTrim(x[2]) == "Z2_OS"})
	cQryTmp := ""
	cQryTmp += " SELECT R_E_C_N_O_ AS NUMREC "
	cQryTmp += " FROM " + RetSqlName("SZ3") + " SZ3"
	cQryTmp += " WHERE SZ3.Z3_FILIAL	 = '" + xFilial("SZ3") + "'"
	cQryTmp += " AND SZ3.Z3_OS	 		 = '" + cOS + "'"
	cQryTmp += " AND SZ3.D_E_L_E_T_ <> '*' "
	cQryTmp += " ORDER BY Z3_FILIAL,Z3_OS,Z3_ITEM
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)

	aStru:= SZ3->(dbStruct())
	aEval(aStru, {|e| If(e[2] != "C", TCSetField("TMP", e[1], e[2],e[3],e[4]),Nil)})
	
	DbSelectArea("TMP")
	DbGoTop()
	While !TMP->(Eof())
		SZ3->( dbGoTo(TMP->NUMREC) )		
		
		Aadd(aColsItens,Array(Len(aHeadItens)+1))
		
		For nCntFor	:= 1 To Len(aHeadItens)
			
			If AllTrim(aHeadItens[nCntFor,2]) == "Z3_OBS"
				aColsItens[Len(aColsItens),nCntFor] := MSMM(SZ3->Z3_CODOBS,80) + Chr(10) + Chr(13) + SZ3->Z3_TEXTO
			ElseIF AllTrim(aHeadItens[nCntFor,2]) == "AF9_DESCRI"
				aHeadItens[nCntFor,4] := 30 // Tamanho do Campo
				aColsItens[Len(aColsItens),nCntFor] := Posicione('AF9',1,xFilial('AF9')+SZ3->(Z3_PROJETO+Z3_REVISA+Z3_TAREFA),'Left(AF9_DESCRI,30)')
			ElseIF ( aHeadItens[nCntFor,10] != "V" )
				aColsItens[Len(aColsItens),nCntFor] := SZ3->( FieldGet(FieldPos(aHeadItens[nCntFor,2])) )
			Else
				aColsItens[Len(aColsItens),nCntFor] := CriaVar(aHeadItens[nCntFor,2])
			EndIF
		
		Next nCntFor
		
		aColsItens[Len(aColsItens),Len(aHeadItens)+1] := .F.
	
		DbSelectArea("TMP")
		DbSkip()
	EndDo
	
	DbSelectArea("TMP")
	DbCloseArea()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array com 1 elemento vazio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	IF Len(aColsItens) <= 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclusao, Monta o Array com 1 elemento vazio		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aColsItens,Array(Len(aHeadItens)+1))
		For nX := 1 To Len(aHeadItens)
			If AllTrim(aHeadItens[nX,2]) == "Z3_ITEM"
				aColsItens[1,nX] := StrZero(1,TamSX3("Z3_ITEM")[1])
			ElseIf AllTrim(aHeadItens[nX,2]) == "Z3_OBS"
				aColsItens[1,nX] := ""
			Else
				aColsItens[1,nX] := CriaVar(aHeadItens[nX,2])															
			EndIf	
		Next nX
		aColsItens[1,Len(aHeadItens)+1] := .F.
	EndIF

EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYALTOS   ºAutor  ³Microsiga           º Data ³  05/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera OS                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SYALTOS(cProjeto)

Local aArea  		:= GetArea()
Local nPosOS 		:= aScan(aHeadOS,{|x| AllTrim(x[2]) == "Z2_OS"})
Local nCntFor		:= 1      
Local nOS    		:= oGetOS:nAT
Local aGroups     	:= AllGroups()
Local cGrp		  	:= ''
Private lAdm		:= .F.
Private lCoord	 	:= .F.
Private lFabrica 	:= .F.
Private cproj       := " " 
Private cCodSer     :=" "  
PRIVATE cCoord      :=" "                
Private oOk         := LoadBitmap(GetResources(), "BR_VERDE")  
Private oPr  		:= LoadBitmap(GetResources(), "BR_VERMELHO")
Private o40     	:= LoadBitmap(GetResources(), "BR_AZUL")  
Private o70     	:= LoadBitmap(GetResources(), "BR_AMARELO")  
Private oHr    		:= LoadBitmap(GetResources(), "BR_PINK")
Private oBl     	:= LoadBitmap(GetResources(), "BR_PRETO" )
Private oAb     	:= LoadBitmap(GetResources(), "BR_BRANCO" )
Private oAv     	:= LoadBitmap(GetResources(), "BR_LARANJA" )
Private oSy     	:= LoadBitmap(GetResources(), "BR_MARROM" )
Private oEn     	:= LoadBitmap(GetResources(), "BR_CINZA" )
Private oAd    		:= LoadBitmap(GetResources(), "BPMSEDT1" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario esta cadastrado como recurso de projeto³
//³e filtra as OS do usuario.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:= 1 To Len(aGroups)
	If 	(AllTrim(Upper((aGroups[nI,1,2]))) == "FINANCEIRO") .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "ADMINISTRADORES") .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "PMO")
		cGrp+= aGroups[nI,1,1] + "/"
	EndIf
Next nI                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario pertence ao grupo de administradores.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" )
	lAdm := .T.
ElseIf !Empty(cGrp)
	aGrp := UsrRetGrp(UsrRetName(__cUserID))
	For nI:= 1 To Len(aGrp)
		If aGrp[nI] $ cGrp
			lAdm := .T.
		EndIf
	Next nI
EndIf

DbSelectArea("AE8")
DbSetOrder(3)
IF DbSeek(xFilial("AE8")+__cUserID)
	IF AE8->AE8_EQUIPE == "4" 			//Coordenacao
		lCoord := .T. 
		cCoord := AE8->AE8_RECURS
	EndIF
EndIF


aColsOS:= aClone(oGetOS:aCols)

SZ2->(dbOrderNickName("Z2OS"))
SZ2->(dbSeek(xFilial("SZ2")+oGetOS:aCols[oGetOS:nAt,nPosOS]))

U_PMS01CAD("SZ2",SZ2->(Recno()),4)

For nCntFor	:= 1 To Len(aHeadOS)
	If AllTrim(aHeadOS[nCntFor,2]) == "Z2_OK"
		aColsOS[nOS,nCntFor] := oNo
	ElseIF ( aHeadOS[nCntFor,10] != "V" )
		aColsOS[nOS,nCntFor] := SZ2->( FieldGet(FieldPos(aHeadOS[nCntFor,2])) )
	Else
		aColsOS[nOS,nCntFor] := CriaVar(aHeadOS[nCntFor,2])
	EndIF
Next nCntFor
aColsOS[nOS,Len(aHeadOS)+1] := .F.


SYOSACOLS(cProjeto,.F.,aColsOS[nOS,2])

oGetOS:aCols:= aClone(aColsOS)
oGetOS:oBrowse:Refresh()
oGetItens:oBrowse:Refresh()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetNumPrj ºAutor  ³Microsiga           º Data ³  05/22/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna numero do projeto.                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetNumPrj(oPrj)

Local nPosProj	:= Ascan(oPrj:aHeader,{ |x| x[2] == 'PROJETO'})
Local cProj 	:= StrZero( Val( Left( oPrj:acols[oPrj:nAt,nPosProj] , 4 ) ) , TamSX3("AF8_PROJET")[1] )

Return(cProj)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  A100Grf  ºAutor  ³Microsiga           º Data ³  06/29/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A100Grf(cMesAtu,cMesAnt,aStatus,aMeses,aMetas,aResult)

Local oPnlGrf
Local oGrfInd
Local oPanel1

oScroll:= TScrollBox():New(oFolder:aDialogs[12],0,0,0,0,.T.,.T.)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT 

oPnlGrf := TPanel():New(0, 0, "",oScroll,Nil, .T., .F., Nil, Nil,675,280 , .T. , .F.)

oGrfInd := FWLayer():New()
oGrfInd:Init(oPnlGrf, .F.) 
oGrfInd:AddCollumn('BLOCO1', 50 , .F.)
oGrfInd:AddCollumn('BLOCO2', 50 , .F.) 

oGrfInd:AddWindow('BLOCO1' , 'JANELA1'  , "OSs x Status [" +aMeses[Val(Right(cMesAtu,2))]+ " / " +aMeses[Val(Right(cMesAnt,2))]+ "]"	, 50, .F., .F.)
oGrfInd:AddWindow('BLOCO1' , 'JANELA2'  , "Coordenadores x Projetos Ativos"																, 50, .F., .F.)
oGrfInd:AddWindow('BLOCO2' , 'JANELA1'  , "Realizado Ultimos 12 Meses [Meta / Realizado / Abono] - Barras"								, 50, .F., .F.)
oGrfInd:AddWindow('BLOCO2' , 'JANELA2'  , "Realizado Ultimos 12 Meses [Meta / Realizado / Abono] - Linha" 								, 50, .F., .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o diretorio onde ficara os graficos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa( {|| PreparaDadosGrf(@oGrfInd,cMesAtu,cMesAnt,aStatus,aMeses,aMetas,aResult) }, "Preparando Dados para Graficos..."    )

Return(.T.)      
                                                                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PreparaDadosGrfº Autor ³ Microsiga     º Data ³  09/23/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PreparaDadosGrf(oGrfInd,cMesAtu,cMesAnt,aStatus,aMeses,aMetas,aResult)

Local aArea 	:= GetArea()
Local cAnoFim	:= Left( Dtos(FirstDay(dDataBase)) 	, 6 )
Local cAnoIni	:= StrZero( Val(Left(cAnoFim,4))-1 , 4 ) + Right(cAnoFim,2)
Local aResult	:= {}
Local dData
Local cQuery
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ OSs do Mês x Status.                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a100FWCharts[1] := FWChartFactory():New()
a100FWCharts[1] := a100FWCharts[1]:getInstance( BARCOMPCHART )
a100FWCharts[1]:init( oGrfInd:GetWinPanel('BLOCO1', 'JANELA1'), .T. )
a100FWCharts[1]:setColor("Random")
a100FWCharts[1]:setLegend( CONTROL_ALIGN_RIGHT )
a100FWCharts[1]:setMask( " *@* " )
a100FWCharts[1]:setPicture( "@E 999,999,999" )

cQuery := " SELECT "
cQuery += " 	Z2_STATUS 					AS STATUS, 	"
cQuery += " 	LEFT(SZ2.Z2_DATA,4) 		AS ANO, 	"
cQuery += " 	SUBSTRING(SZ2.Z2_DATA,5,2) 	AS MES, 	"
cQuery += " 	COUNT(*) 					AS TOTAL 	"
cQuery += " FROM "
cQuery += 			RetSqlName('SZ2') + " SZ2 "
cQuery += " WHERE "
cQuery += " 	SZ2.Z2_FILIAL		= '" + xFilial('SZ2')	+ "' 	AND "
cQuery += " 	LEFT(SZ2.Z2_DATA,6) >= '" + cMesAnt			+ "' 	AND "
cQuery += " 	LEFT(SZ2.Z2_DATA,6) <= '" + cMesAtu			+ "' 	AND "
cQuery += " 		SZ2.D_E_L_E_T_ = '' "
cQuery += " GROUP BY Z2_STATUS , LEFT(SZ2.Z2_DATA,4) , SUBSTRING(SZ2.Z2_DATA,5,2) "
cQuery += " ORDER BY Z2_STATUS , LEFT(SZ2.Z2_DATA,4) , SUBSTRING(SZ2.Z2_DATA,5,2) DESC "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
IF Eof()
	a100FWCharts[1]:addSerie( 'Nenhuma OS foi Lançada.' , aResult )	
Else
	While !Eof()

		cStatus	:= TRB->STATUS
		aResult	:= {}
		
		While !Eof() .And. TRB->STATUS == cStatus
			Aadd( aResult, {	aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2) , TRB->TOTAL } )
			DbSkip()
		EndDo

		nPos := Ascan( aStatus ,{ |x| x[1] == cStatus })
		IF nPos > 0
			a100FWCharts[1]:addSerie( aStatus[nPos,2] 	, aResult )
		Else
			a100FWCharts[1]:addSerie( 'Sem Status'		, aResult )
		EndIF
	
	EndDo
EndIF

TRB->(DbCloseArea())

a100FWCharts[1]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coordenadores x Projetos                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a100FWCharts[2] := FWChartFactory():New()
a100FWCharts[2] := a100FWCharts[2]:getInstance( PIECHART )
a100FWCharts[2]:init( oGrfInd:GetWinPanel('BLOCO1', 'JANELA2'), .T. )
a100FWCharts[2]:setColor("Random")
a100FWCharts[2]:setLegend( CONTROL_ALIGN_RIGHT )
a100FWCharts[2]:setMask( " *@* " )
a100FWCharts[2]:setPicture( "@E 999,999,999.99" )

cQuery := " SELECT AF8_COORD, COUNT(AF8_PROJET) AS QTDPRJ , MAX(AF8_REVISA) AS REVISA "
cQuery += " 	FROM "
cQuery += 			RetSqlName('AF8') + " AF8 "
cQuery += " WHERE "
cQuery += " 	AF8.AF8_FILIAL	= '" + xFilial('AF8')	+ "' 	AND "
IF !(lPMO .Or. lDiretoria)
	cQuery += "	AF8.AF8_COORD = '" + cCodCoord 			+ "'	AND "
EndIF
cQuery += " 	AF8.AF8_ENCPRJ = '' 							AND "
cQuery += " 	AF8.D_E_L_E_T_ = '' " 
cQuery += " 	GROUP BY AF8_COORD "
cQuery += " 	ORDER BY QTDPRJ DESC "
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	a100FWCharts[2]:addSerie( Capital(Posicione('AE8',1,xFilial('AE8')+TRB->AF8_COORD,'Left(AE8_DESCRI,12)')) + ' - ' + Alltrim(Transform(TRB->QTDPRJ,'@E 999,999')) , TRB->QTDPRJ )
	DbSkip()
EndDo
TRB->(DbCloseArea())

a100FWCharts[2]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metas do Ano.                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a100FWCharts[3] := FWChartFactory():New()
a100FWCharts[3] := a100FWCharts[3]:GetInstance( BARCOMPCHART )
a100FWCharts[3]:init( oGrfInd:GetWinPanel('BLOCO2', 'JANELA1'), .T. )
a100FWCharts[3]:setColor("Random")
a100FWCharts[3]:setLegend( CONTROL_ALIGN_BOTTOM )
a100FWCharts[3]:setMask( " *@* " )
a100FWCharts[3]:setPicture( "@E 9,999,999" )

cQuery := "	SELECT "
cQuery += "		ANO, MES, SUM(META) AS META , SUM(REALIZADO) AS REALIZADO , SUM(ABONO) ABONO "
cQuery += "	FROM "
cQuery += "	( "
cQuery += "		SELECT "
cQuery += "		ANO, 	MES, 	COUNT(*) AS META,	0 AS REALIZADO,	0 AS ABONO "
cQuery += "		FROM "
cQuery += "		( "
cQuery += "			SELECT "
cQuery += "				LEFT(Z2_DATA,4) AS ANO, "
cQuery += "				SUBSTRING(Z2_DATA,5,2) AS MES, "
cQuery += "				Z2_RECURSO AS RECURSO "
cQuery += "			FROM "
cQuery += 			RetSqlName('SZ2') + " SZ2 "
cQuery += "			WHERE "
cQuery += " 			SZ2.Z2_FILIAL		= '" + xFilial('SZ2')	+ "' 	AND "
cQuery += " 			LEFT(SZ2.Z2_DATA,6) >= '" + cAnoIni			+ "' 	AND "
cQuery += " 			LEFT(SZ2.Z2_DATA,6) <= '" + cAnoFim			+ "' 	AND "
cQuery += "				SZ2.D_E_L_E_T_ = ' ' "
cQuery += "			GROUP BY "
cQuery += "				LEFT(Z2_DATA,4)	, SUBSTRING(Z2_DATA,5,2) , Z2_RECURSO "
cQuery += "		) AS TAB "
cQuery += "		GROUP BY ANO, MES "
cQuery += "		UNION "
cQuery += "		SELECT "
cQuery += "			* "
cQuery += "	FROM "
cQuery += "		( "
cQuery += " SELECT "
cQuery += " 	LEFT(Z2_DATA,4) 		AS ANO, "
cQuery += " 	SUBSTRING(Z2_DATA,5,2) 	AS MES, "
cQuery += " 	0 						AS META, "
cQuery += " 	SUM(Z2_HUTEIS) 			AS REALIZADO, "
cQuery += " 	SUM(Z2_HABONO) 			AS ABONO "
cQuery += " FROM "
cQuery += 			RetSqlName('SZ2') + " SZ2, "
cQuery += 			RetSqlName('SZ3') + " SZ3 "
cQuery += " WHERE "
cQuery += " 	SZ2.Z2_FILIAL		= '" + xFilial('SZ2')	+ "' 	AND "
cQuery += " 	LEFT(SZ2.Z2_DATA,6) >= '" + cAnoIni			+ "' 	AND "
cQuery += " 	LEFT(SZ2.Z2_DATA,6) <= '" + cAnoFim			+ "' 	AND "
cQuery += " 	Z2_OS = Z3_OS										AND "
cQuery += " 	SZ2.D_E_L_E_T_ = ''									AND "
cQuery += " 	SZ3.Z3_FILIAL		= '" + xFilial('SZ3')	+ "' 	AND "
cQuery += " 	SZ3.D_E_L_E_T_ = '' "
cQuery += " GROUP BY LEFT(Z2_DATA,4) , SUBSTRING(Z2_DATA,5,2) " 
cQuery += " 	) AS TAB2 "
cQuery += " ) AS TAB3 "
cQuery += " GROUP BY ANO, MES "
cQuery += " ORDER BY ANO, MES "
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
IF Eof()
	a100FWCharts[3]:addSerie( 'Nenhuma OS foi Lançada.' , 0 )	
Else
	
	For nX := 1 To Len(aMetas)
	
		aResult := {}
		
		DbGoTop()
		
		While !Eof()
			
			dData := Stod(TRB->ANO+TRB->MES+'01')
			
			IF nX == 1 		// Meta
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->META * U_SyMetaRet(dData, "", "1") } )
			ElseIF nX == 2 //	Hrs.Realizadas
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->REALIZADO - TRB->ABONO 	} )
			ElseIF nX == 3 //	Hrs.Abonadas'
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->ABONO 		} )
			EndIF
			
			DbSkip()
	
		EndDo
		
		a100FWCharts[3]:addSerie( aMetas[nX] , aResult )
	
	Next
	
EndIF

//TRB->(DbCloseArea())

a100FWCharts[3]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estatisticas do Projeto.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a100FWCharts[4] := FWChartFactory():New()
a100FWCharts[4] := a100FWCharts[4]:GetInstance( LINECHART )
a100FWCharts[4]:init( oGrfInd:GetWinPanel('BLOCO2', 'JANELA2'), .T. )
a100FWCharts[4]:setColor("Random")
a100FWCharts[4]:setLegend( CONTROL_ALIGN_BOTTOM )
a100FWCharts[4]:setMask( " *@* " )
a100FWCharts[4]:setPicture( "@E 999,999,999.99" )

DbSelectArea("TRB")
DbGoTop()
IF Eof()
	a100FWCharts[4]:addSerie( 'Nenhuma OS foi Lançada.' , 0 )	
Else
	
	For nX := 1 To Len(aMetas)
	
		aResult := {}
		
		DbGoTop()
		
		While !Eof()
			
			dData := Stod(TRB->ANO+TRB->MES+'01')
			
			IF nX == 1 		// Meta
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->META * U_SyMetaRet(dData, "", "1") } )
			ElseIF nX == 2 //	Hrs.Realizadas
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->REALIZADO-TRB->ABONO 	} )
			ElseIF nX == 3 //	Hrs.Abonadas'
				Aadd( aResult, { aMeses[Val(TRB->MES)]+'/'+Right(TRB->ANO,2)	, TRB->ABONO 		} )
			EndIF
			
			DbSkip()
	
		EndDo
		
		a100FWCharts[4]:addSerie( aMetas[nX] , aResult )
	
	Next
	
EndIF

TRB->(DbCloseArea())

a100FWCharts[4]:Build()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  PmsObs   ³ Autor ³   Fabio Rogerio ³ Data ³ 21/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Chama tela para digitacao do Historico.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsObs(oFolder,;
					 oMemoPrj,;
					 oMemoOk,;
					 oMemoPr,;
					 oMemo40,;
					 oMemo70,;
					 oMemoHr,;
					 oMemoBl,;
					 oMemoAv,;
					 oMemoAb,;
					 oMemoSy,;
					 oMemoEn,;
					 cMemoPrj,;
					 cMemoOk,;
					 cMemoPr,;
					 cMemo40,;
					 cMemo70,;
					 cMemoHr,;
					 cMemoBl,;
					 cMemoAv,;
					 cMemoAb,;
					 cMemoSy,;
					 cMemoEn,;
					 oPrjOk,;
					 oPrjPr,;
					 oPrj40,;
					 oPrj70,;
					 oPrjHr,;
					 oPrjBl,;
					 oPrjAvulso,;
					 oPrjAberto,;
					 oPrjSymm,;
					 oPrjEn)

Local aArea    := GetArea()
Local nOpca   	:= 1
Local oDlgHist
Local oHistPrj
Local cHistorico:= Space(1000)
Local cObsPrj   := ""
Local oMemo

Do Case
	Case oFolder:nOption == 1
		Return
	Case oFolder:nOption == 2
		cProjeto:= RetNumPrj(oPrj)
		oMemo  := oMemoPrj
	Case oFolder:nOption == 3
		cProjeto:= RetNumPrj(oPrjOk)
		oMemo  := oMemoOk
	Case oFolder:nOption == 4
		cProjeto:= RetNumPrj(oPrjPr)
		oMemo  := oMemoPr
	Case oFolder:nOption == 5
		cProjeto:= RetNumPrj(oPrj40)
		oMemo  := oMemo40
	Case oFolder:nOption == 6
		cProjeto:= RetNumPrj(oPrj70)
		oMemo  := oMemo70
	Case oFolder:nOption == 7
		cProjeto:= RetNumPrj(oPrjHr)
		oMemo  := oMemoHr
	Case oFolder:nOption == 8
		cProjeto:= RetNumPrj(oPrjBl)
		oMemo  := oMemoBl
	Case oFolder:nOption == 9
		cProjeto:= RetNumPrj(oPrjAvulso)
		oMemo  := oMemoAv
	Case oFolder:nOption == 10
		cProjeto:= RetNumPrj(oPrjAberto)
		oMemo  := oMemoAb
	Case oFolder:nOption == 11
		cProjeto:= RetNumPrj(oPrjSymm)
		oMemo  := oMemoSy
	Case oFolder:nOption == 12
		cProjeto:= RetNumPrj(oPrjEn)
		oMemo  := oMemoEn
EndCase

	
DEFINE MSDIALOG oDlgHist FROM 005,005 TO 300,700 TITLE "Digite o Historico." PIXEL

@ 005,005 GET oHistPrj VAR cHistorico SIZE 340,120 OF oDlgHist MEMO PIXEL FONT oObsTohoma COLOR CLR_BLACK,CLR_HGRAY

DEFINE SBUTTON FROM 130,300 TYPE 1 ENABLE OF oDlgHist ACTION oDlgHist:End()

ACTIVATE MSDIALOG oDlgHist Centered


IF !Empty(cHistorico)
	dbSelectArea("AF8")
	dbSetOrder(1)
	If dbSeek(xFilial("AF8")+cProjeto)
		cObsPrj:= Alltrim(MSMM(AF8->AF8_CODMEM))
		cObsPrj := Alltrim(UsrRetName(__cUserID)) + "|" + Dtoc(dDataBase) + "|" + Left(Time(),5) + "| " + cHistorico + Chr(13)+Chr(10) + cObsPrj
		
		RecLock("AF8",.F.)
		MSMM(,TamSx3("AF8_OBS")[1],,cObsPrj,1,,,"AF8","AF8_CODMEM")
        MsUnLock()

		Do Case
			Case oFolder:nOption == 2
				cMemoPrj:= cObsPrj
			Case oFolder:nOption == 3
				cMemoOk:= cObsPrj
			Case oFolder:nOption == 4
				cMemoPr:= cObsPrj
			Case oFolder:nOption == 5
				cMemo40:= cObsPrj
			Case oFolder:nOption == 6
				cMemo70:= cObsPrj
			Case oFolder:nOption == 7
				cMemoHr:= cObsPrj
			Case oFolder:nOption == 8
				cMemoBl:= cObsPrj
			Case oFolder:nOption == 9
				cMemoAv:= cObsPrj
			Case oFolder:nOption == 10
				cMemoAb:= cObsPrj
			Case oFolder:nOption == 11
				cMemoSy:= cObsPrj
			Case oFolder:nOption == 12
				cMemoEn:= cObsPrj
		EndCase
				  
		oMemo:SetText(cObsPrj)
		oMemo:Refresh()
	EndIf

EndIF

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  ObsView   ³ Autor ³   Fabio Rogerio ³ Data ³ 21/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Chama tela para visualizacao do Historico.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObsView(oMemo,cMemo,oPrj)
Local aArea    := GetArea()
Local cObsPrj  := ""
Local cProjeto := ""

cProjeto:= RetNumPrj(oPrj)
dbSelectArea("AF8")
dbSetOrder(1)
If dbSeek(xFilial("AF8")+cProjeto)
	cObsPrj:= Alltrim(MSMM(AF8->AF8_CODMEM))
	cMemo:= cObsPrj
	oMemo:SetText(cObsPrj)
	oMemo:Refresh()
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  SyPrjAudit ³ Autor ³   Fabio Rogerio ³ Data ³ 08/07/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Rotina para bloqueio dos projetos para auditoria.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SyPrjAudit()
Local aPercAudit:= {}
Local cQuery    := ""
Local nPercPrj  := 0
Local nX        := 0

aPercAudit:= Separa(GetMV("SY_PRJAUD",,"20/40/60/80"),"/")
For nX:= 1  To Len(aPercAudit)
	aPercAudit[nX]:= Val(aPercAudit[nX])
Next nX

cQuery:= " SELECT AF8.R_E_C_N_O_ REG,AF8_PROJET, AF8_HORAS, SUM(Z3_HUTEIS) Z3_HUTEIS "
cQuery+= " FROM " + RetSqlName("AF8") + " AF8 "
cQuery+= " LEFT JOIN " + RetSqlName("SZ3") + " SZ3 ON SZ3.D_E_L_E_T_ = '' AND AF8.AF8_FILIAL+AF8.AF8_PROJET = SZ3.Z3_FILIAL+SZ3.Z3_PROJETO " 
cQuery+= " WHERE AF8.D_E_L_E_T_ = '' " 
cQuery+= " AND AF8.AF8_ENCPRJ <> '1' " 
cQuery+= " AND AF8.AF8_BLQPRJ NOT IN ('A','S') " 
cQuery+= " AND AF8.AF8_DTLIB <>  '" + Dtos(dDatabase) + "'" 
cQuery+= " AND AF8.AF8_TPSERV NOT IN ('000001','000009','000010') " 
cQuery+= " AND AF8.AF8_AUDIT <> '2' " 
cQuery+= " GROUP BY AF8.R_E_C_N_O_,AF8_PROJET, AF8_HORAS " 

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"AUDIT",.F.,.T.)

dbSelectArea("AUDIT")
dbGoTop()
While AUDIT->( !Eof() )
	nPercPrj:= (AUDIT->Z3_HUTEIS / AUDIT->AF8_HORAS) * 100 
	IF (nPercPrj >= aPercAudit[1] .And. nPercPrj <= aPercAudit[1]+5) .Or.; 	
	   (nPercPrj >= aPercAudit[2] .And. nPercPrj <= aPercAudit[2]+5) .Or.;
	   (nPercPrj >= aPercAudit[3] .And. nPercPrj <= aPercAudit[3]+5) .Or.;
	   (nPercPrj >= aPercAudit[4] .And. nPercPrj <= aPercAudit[4]+5) .Or.;
	   (nPercPrj >= 100)
	
		AF8->(dbGoTo(AUDIT->REG))
//		RecLock("AF8",.F.)
//		Replace AF8_BLQPRJ With "A"
//		MsUnLock()
	EndIf	
		
	dbSelectArea("AUDIT")
	dbSkip()
End
AUDIT->(dbCloseArea())

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o  ³ SyPrjDesbloqueia ³ Autor ³ Fabio Rogerio ³ Data ³ 08/07/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Rotina para desbloqueiar os projetos de auditoria.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SyPrjDesbloqueia(cProjeto)
Local aArea:= GetArea()

//aRes := getResArray("*")
//aEval(aRes,{|x| resource2File(x,"C:\temp\resources\" + x)})
	
dbSelectArea("AF8")
dbSetOrder(1)
If dbSeek(xFilial("AF8") + cProjeto,.T.) .And. (AF8->AF8_BLQPRJ == "A")
	
	
	If Aviso("Atencao","Confirma o Desbloqueio de Auditoria do Projeto " + AF8->AF8_DESCRI + " ?",{"Sim","Não"}) == 1
		RecLock("AF8",.F.)
		Replace AF8_BLQPRJ With "L"
		Replace AF8_DTLIB  With dDatabase
		Replace AF8_USRLIB With SubStr(cUsuario,7,15)
		MsUnlock()
	EndIf
Else
	Aviso("Atencao","O projeto selecionado não está bloqueado para auditoria.",{"Sair"})
EndIf

RestArea(aArea)
Return(.T.)

Static Function OSNaoApr(aDados)
Local nOS:= 0
Local nI := 0
Local nX := 0

/* ESTRUTURA ADADOS

[1]  - Código do Recurso 
[2]  - Nome do Recurso 
[3]  - Código do Coordenador 
[4]  - Nome do Coordenador 
[5]  - Meta de Horas do Mês 
[6]  - Quantidade de dias com agenda 
[7]  - Horas Apontadas 
[8]  - Horas Faturaveis 
[9]  - Horas Nao Faturaveis 
[10] - Entrada Apos 09:00 
[11] - Saida Antes das 18:00 
[12] - Qtde. OS 
[13] - Qtde. OS Encerradas 
[14] - Qtde. OS Não Aprovada pelo coordenador  
[15] - Valor de Vendas 
[16] - Equipe 
*/

For nI:= 1 To Len(aDados)
	nOS+= aDados[nI,14]
Next nI

Return(nOS)
