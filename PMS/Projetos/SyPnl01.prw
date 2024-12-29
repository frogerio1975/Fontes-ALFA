#Include "Protheus.ch"
#Include "dbtree.ch"
#define PMS_TASK  1
#define PMS_WBS   2
#define PMS_MAX_DATE CToD("31/12/2050")
#define PMS_MIN_DATE CTod("01/01/1980")

Static lJaExecutou := .F.	// Usado na funcao SyOrdCab()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัอออออออัออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SyPnl01  ณAutor  ณ   Alexandro Dias   ณ Data ณ  08/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออฯอออออออฯออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Painel de Controle.			                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SyPnl01()

Local cMsgOrd 	  	:= Chr(13)+Chr(10) + 'Para ordenar! Clicar na celula e em seguida no cabe็alho da celula' + Chr(13)+Chr(10)
Local nlOrdemCols 	:= .F.
Local aArea 	  	:= GetArea()
Local aSize    	  	:= MsAdvSize()
Local aTxt 			:= { '' , '' , '' , '' , '' , '' , '' }
Local aVlr 			:= { 0 , 0 , 0 , 0 , 0 , 0 , 0 }
Local aButtons 	  	:= {}
Local aHedRMes 	  	:= {}
Local aRecMes	  	:= {}
Local aHedFMes 	  	:= {}
Local aFatMes	  	:= {}
Local aHedRJurid  	:= {}
Local aRecJurid	  	:= {}
Local aHedRAtras  	:= {}
Local aRecAtras	  	:= {}
Local aHedRBxMes  	:= {}
Local aRecBxMes	  	:= {}
Local aHedRTotal  	:= {}
Local aRecTotal   	:= {}
Local aHedPMes 	  	:= {}
Local aPagMes	  	:= {}
Local aHedPDia 	  	:= {}
Local aPagDia	  	:= {}
Local aHedPTotal  	:= {}
Local aPagTotal   	:= {}
Local aHedSE5 	  	:= {}
Local aDadosSE5   	:= {}
Local aHedSE8 	  	:= {}
Local aDadosSE8   	:= {}
Local aHRecSint  	:= {}
Local aDRecSint  	:= {}
Local aHDevSint  	:= {}
Local aDDevSint  	:= {}
Local aColunaA 		:= { 004, 150 }
Local aColunaB 		:= { 249, 390 }
Local nBancos	  	:= 0
Local nAplicacao  	:= 0
Local nPAtr       	:= 0
Local nPPortado   	:= 0
Local aGroups     	:= AllGroups()
Local cGrp        	:= ""
Local dDataOld		:= dDataBase
Local bBaixar 		:= {|| dDataOld := dDataBase , EpBxTitulo(oFolder2,@oPanel) , dDataBase := dDataOld }
Local bSyPosCliFor	:= {|| SyPosCliFor(oFolder2,@oPanel) 	}
Local bHistorico	:= {|| U_SyObsCli( 'PNL' , 0 , 2 , oFolder2) }
Local bCR 			:= {|| dDataOld := dDataBase , Fina740() , dDataBase := dDataOld, AtuTela(@aHedRMes,@aRecMes,@aHedRTotal,@aRecTotal,@aHedRAtras,@aRecAtras,@aHedRJurid,@aRecJurid,@aHRecSint,@aDRecSint,@aHDevSint,@aDDevSint,@aHedPMes,@aPagMes,@aHedPTotal,@aPagTotal,@aHedPDia,@aPagDia,@nBancos,@nAplicacao,@aHedSE8,@aDadosSE8,@aHedSE5,@aDadosSE5,@aHedFMes,@aFatMes) }
Local bCP 		    := {|| dDataOld := dDataBase , Fina750() , dDataBase := dDataOld, AtuTela(@aHedRMes,@aRecMes,@aHedRTotal,@aRecTotal,@aHedRAtras,@aRecAtras,@aHedRJurid,@aRecJurid,@aHRecSint,@aDRecSint,@aHDevSint,@aDDevSint,@aHedPMes,@aPagMes,@aHedPTotal,@aPagTotal,@aHedPDia,@aPagDia,@nBancos,@nAplicacao,@aHedSE8,@aDadosSE8,@aHedSE5,@aDadosSE5,@aHedFMes,@aFatMes) }
Local oFolder
Local oFolder2
Local oDlgPnl
Local oPanel
Local oPanel2
Local oPanel3
Local bColor
Local bColor2
Local bColor3
Local ni 
Private cEntidade 		:= ''
Private cCadastro 		:= "Painel de Controle SYMM"
Private lAdm			:= .F.
Private lPagar			:= .F.
Private lReceber		:= .F.
Private nFldRecSint     := 1
Private nFldDevSint     := 2
Private nFldRecMes		:= 3
Private nFldRecTot		:= 4
Private nFldAtrado		:= 5
Private nFldJuridico	:= 6
Private nFldPagDia		:= 7
Private nFldPagMes		:= 8
Private nFldPagTot		:= 9
Private nFldSaldo		:= 10
Private nFldMov			:= 11
Private nFldFat			:= 12

Private oJuridico
Private oAtrasados
Private oRecMes
Private oRecTotal
Private oPagMes
Private oPagTotal
Private oRecSint
Private oDevSint                      

Private __cPerg		:= ''
Private __aIndex   	:= {}
Private __cFiltro 	:= ''

Private cEmpFat:='1'

INCLUI:= .F.
ALTERA:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o usuario esta cadastrado como recurso de projetoณ
//ณe filtra as OS do usuario.                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nI:= 1 To Len(aGroups)
	IF (AllTrim(Upper((aGroups[nI,1,2]))) == "ADMINISTRADORES")
		cGrp+= aGroups[nI,1,1] + "/"
	EndIF
Next nI

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o usuario pertence ao grupo de administradores.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" )
	lAdm := .T.

ElseIF !Empty(cGrp)
	aGrp := UsrRetGrp(UsrRetName(__cUserID))
	For nI:= 1 To Len(aGrp)
		If aGrp[nI] $ cGrp
			lAdm := .T.
		EndIf
	Next nI
EndIF
                       
LjMsgRun( "Aguarde ... Filtrando Contas a Receber ...." 			,, {|| SyReceber(@aHedRMes,@aRecMes,@aHedRTotal,@aRecTotal,@aHedRAtras,@aRecAtras,@aHedRJurid,@aRecJurid,@aHRecSint,@aDRecSint,@aHDevSint,@aDDevSint) } )
LjMsgRun( "Aguarde ... Filtrando Contas a Pagar ...." 				,, {|| SyPagar(@aHedPMes,@aPagMes,@aHedPTotal,@aPagTotal,@aHedPDia,@aPagDia) } )
LjMsgRun( "Aguarde ... Filtrando Saldo Bancario ...." 				,, {|| SySaldo(@nBancos,@nAplicacao,@aHedSE8,@aDadosSE8) } )
LjMsgRun( "Aguarde ... Filtrando Movimenta็ใo Bancแria ...." 		,, {|| SyMovBanco(@aHedSE5,@aDadosSE5) } )
LjMsgRun( "Aguarde ... Filtrando Faturamento ...." 					,, {|| SyFaturamento(@aHedFMes,@aFatMes) } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula Contas a Receber. 							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPAtr    := aScan(aHedRMes,{|x| AllTrim(x[2]) == "A1_ATR"})
nPVencRea:= aScan(aHedRMes,{|x| AllTrim(x[2]) == "E1_VENCREA"})
nPValor  := aScan(aHedRMes,{|x| AllTrim(x[2]) == "E1_VALOR"})
nPVLBx   := aScan(aHedRMes,{|x| AllTrim(x[2]) == "E5_VALOR"})
nPSaldo  := aScan(aHedRMes,{|x| AllTrim(x[2]) == "E1_SALDO"})
nPPortado:= aScan(aHedRMes,{|x| AllTrim(x[2]) == "E1_PORTADO"})

//Contas a Receber no Mes
nCRMes  := 0
nQtCRMes:= 0
nTktMed := 0
nFatMes := 0
AEval(aRecMes,{|x| nCRMes  += IIf(x[nPPortado] == "999",0,x[nPSaldo]+x[nPVLBx])})
AEval(aRecMes,{|x| nQtCRMes+= IIf(x[nPPortado] == "999",0,1)})
AEval(aFatMes,{|x| nFatMes += 1})
nTktMed:= nCRMes/nQtCRMes

//Titulos Atrasado no Mes
nQtCRAtr:= 0
nCRAtr  := 0
AEval(aRecMes,{|x| nQtCRAtr+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. x[nPPortado] <> "999",1,0)})
AEval(aRecMes,{|x| nCRAtr  += IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. x[nPPortado] <> "999",x[nPSaldo],0)})

//Titulos Juridico
nQtCRJur:= 0
nCRJur  := 0
AEval(aRecJurid,{|x| nQtCRJur+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. x[nPPortado] == "999",1,0)})
AEval(aRecJurid,{|x| nCRJur  += IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. x[nPPortado] == "999",x[nPSaldo],0)})

//Titulos a Vencer no Mes
nQtCRAVC:= 0
nCRAVC  := 0
AEval(aRecMes,{|x| nQtCRAVC+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] <= 0 .And. x[nPPortado] <> "999",1,0)})
AEval(aRecMes,{|x| nCRAVC  += IIf(x[nPSaldo] > 0 .And. x[nPAtr] <= 0 .And. x[nPPortado] <> "999",x[nPSaldo],0)})

//Titulos Recebidos no Mes
nQtCRBx := 0
nCRBx   := 0
AEval(aRecMes,{|x| nQtCRBx  += IIf(x[nPVlBX] > 0 .And. x[nPSaldo] == 0 .And. x[nPPortado] <> "999",1,0)})
AEval(aRecMes,{|x| nCRBx    += IIf(x[nPVlBX] > 0 .And. x[nPPortado] <> "999" ,x[nPVlBX],0)})

//Titulos Juridico Recebidos no Mes
nQtCRBxJur := 0
nCRBxJur   := 0
AEval(aRecJurid,{|x| nQtCRBxJur  += IIf(x[nPVlBX] > 0 .And. x[nPSaldo] == 0 .And. x[nPPortado] == "999",1,0)})
AEval(aRecJurid,{|x| nCRBxJur    += IIf(x[nPVlBX] > 0 .And. x[nPPortado] == "999" ,x[nPVlBX],0)})

//Titulos a Receber no Futuro
nQtCRFut := 0
nCRFut   := 0
AEval(aRecTotal,{|x| nQtCRFut  += IIf(x[nPSaldo] > 0 .And. x[nPVencRea] >= LastDay(dDatabase),1,0)})
AEval(aRecTotal,{|x| nCRFut    += IIf(x[nPSaldo] > 0 .And. x[nPVencRea] >= LastDay(dDatabase),x[nPSaldo],0)})

//Titulos Atrasado fora do Mes
nQtCRFora := 0
nCRAtrFora:= 0
AEval(aRecAtras,{|x| nQtCRFora		+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. (Left(Dtos(x[nPVencRea]),6) < Left(Dtos(LastDay(dDatabase)),6)) .And. x[nPPortado] <> "999",1,0)})
AEval(aRecAtras,{|x| nCRAtrFora  	+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0 .And. (Left(Dtos(x[nPVencRea]),6) < Left(Dtos(LastDay(dDatabase)),6)) .And. x[nPPortado] <> "999",x[nPSaldo],0)})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Calcula Contas a Pagar. 							 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPAtr    := aScan(aHedPMes,{|x| AllTrim(x[2]) == "A1_ATR"})
nPVencRea:= aScan(aHedPMes,{|x| AllTrim(x[2]) == "E2_VENCREA"})
nPValor  := aScan(aHedPMes,{|x| AllTrim(x[2]) == "E2_VALOR"})
nPVLBx   := aScan(aHedPMes,{|x| AllTrim(x[2]) == "E5_VALOR"})
nPSaldo  := aScan(aHedPMes,{|x| AllTrim(x[2]) == "E2_SALDO"})

//Contas a Pagar no Mes
nCPMes  := 0
nQtCPMes:= 0
AEval(aPagMes,{|x| nCPMes  += x[nPSaldo]+x[nPVLBx]})
AEval(aPagMes,{|x| nQtCPMes+= 1})

//Titulos Atrasado
nQtCPAtr:= 0
nCPAtr  := 0
AEval(aPagMes,{|x| nQtCPAtr+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0,1,0)})
AEval(aPagMes,{|x| nCPAtr  += IIf(x[nPSaldo] > 0 .And. x[nPAtr] > 0,x[nPSaldo],0)})

//Titulos a Vencer no Mes
nQtCPAVC:= 0
nCPAVC  := 0
AEval(aPagMes,{|x| nQtCPAVC+= IIf(x[nPSaldo] > 0 .And. x[nPAtr] <= 0,1,0)})
AEval(aPagMes,{|x| nCPAVC  += IIf(x[nPSaldo] > 0 .And. x[nPAtr] <= 0,x[nPSaldo],0)})

//Titulos Pagos no Mes
nQtCPBx := 0
nCPBx:= 0
AEval(aPagMes,{|x| nQtCPBx  += IIf(x[nPVlBX] > 0 .And. x[nPSaldo] == 0,1,0)})
AEval(aPagMes,{|x| nCPBX += IIf(x[nPVlBX] > 0,x[nPVlBX],0)})

//Titulos a Pagar no Futuro
nQtCPFut := 0
nCPFut:= 0
AEval(aPagTotal,{|x| nQtCPFut  += IIf(x[nPSaldo] > 0 .And. x[nPVencRea] >= LastDay(dDatabase),1,0)})
AEval(aPagTotal,{|x| nCPFut    += IIf(x[nPSaldo] > 0 .And. x[nPVencRea] >= LastDay(dDatabase),x[nPSaldo],0)})

DEFINE FONT oFnt 	NAME "Courier New" SIZE 0, -16 BOLD
DEFINE FONT oFnt2 	NAME "Courier New" SIZE 0, -22 BOLD

Aadd( aButtons , { "PROJETPMS"  , {|| Eval(bHistorico) } 	, "Historico <F4>"							, "Historico"		} )
Aadd( aButtons , { "POSCLI"  	, {|| Eval(bSyPosCliFor) } 	, "Posi็ใo do Cliente/Fornecedor <F5>"		, "Posi็ใo"			} )
//Aadd( aButtons , { "LJPRECO" 	, {|| Eval(bBaixar) }		, "Realizar Opera็๕es a Pagar/Receber <F6>" , "Pagar/Receber" 	} )
Aadd( aButtons , { "LJPRECO" 	, {|| Eval(bCR) }			, "Contas a Receber <F6>" 					, "Contas a Receber"} )
Aadd( aButtons , { "LJPRECO" 	, {|| Eval(bCP) }			, "Contas a Pagar <F7>" 					, "Contas a Pagar" 	} )
Aadd( aButtons , { "CLIENTE" 	, {|| Mata030() }			, "Cadastro de Cliente <F8>" 				, "Clientes" 	} )
Aadd( aButtons , { "FORNEC" 	, {|| Mata020() }			, "Cadastro de Fornecedor <F9>" 			, "Fornecedor" 	} )

SetKey( VK_F4 	, { || Eval(bHistorico) 	})
SetKey( VK_F5 	, { || Eval(bSyPosCliFor) 	})
SetKey( VK_F6 	, { || Eval(bCR) 		})
SetKey( VK_F7 	, { || Eval(bCP) 		})
SetKey( VK_F8 	, { || Mata030() 		})
SetKey( VK_F9 	, { || Mata020() 		})

DEFINE MSDIALOG oDlgPnl FROM 0,0 TO aSize[6],aSize[5] TITLE "Painel de Controle" Of oMainWnd PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem dos folders.               				 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder:= TFolder():New(0,0,{"Financeiro"},,oDlgPnl,,,,.T.,.F.)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

oPanel:= TPanel():New( 0 , 0 , "" , oFolder:aDialogs[1] , NIL , .F. , .F. , NIL , NIL , 0 , 95 , .F. , .T. )
oPanel:Align:= CONTROL_ALIGN_TOP

//Contas a Receber
IF lAdm .Or. __cUserID == '000092'
	@ 005,aColunaA[1]  SAY "A Receber (Mes)....." 	+ Padr(cValToChar(nQtCRMes),3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 016,aColunaA[1]  SAY "Atrasados(Mes)......" 	+ Padr(cValToChar(nQtCRAtr),3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 027,aColunaA[1]  SAY "A Vencer (Mes)......" 	+ Padr(cValToChar(nQtCRAVC),3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 038,aColunaA[1]  SAY "Recebidos(Mes)......" 	+ Padr(cValToChar(nQtCRBx) ,3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 049,aColunaA[1]  SAY "No Juridico........."	+ Padr(cValToChar(nQtCRJur),3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 060,aColunaA[1]  SAY "Juridico Recebido..." 	+ Padr(cValToChar(nQtCRBxJur),3)	Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 071,aColunaA[1]  SAY "A Vencer (Futuro)..." 	+ Padr(cValToChar(nQtCRFut),3) 		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 082,aColunaA[1]  SAY "Atrasados Fora Mes.."	+ Padr(cValToChar(nQtCRFora),3)		Of oPanel FONT oFnt COLOR CLR_BLACK Pixel SIZE 160,12
	@ 005,aColunaA[2]  MSGET nCRMes 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE	Pixel SIZE 070,10
	@ 016,aColunaA[2]  MSGET nCRAtr 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_WHITE,CLR_HRED 	Pixel SIZE 070,10
	@ 027,aColunaA[2]  MSGET nCRAVC 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 038,aColunaA[2]  MSGET nCRBx	 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE	Pixel SIZE 070,10
	@ 049,aColunaA[2]  MSGET nCRJur 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_WHITE,CLR_HRED 	Pixel SIZE 070,10
	@ 060,aColunaA[2]  MSGET nCRBxJur  		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE	Pixel SIZE 070,10
	@ 071,aColunaA[2]  MSGET nCRFut 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE	Pixel SIZE 070,10
	@ 082,aColunaA[2]  MSGET nCRAtrFora		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_WHITE,CLR_HRED 	Pixel SIZE 070,10
EndIF

//Contas a Pagar
IF lAdm .Or. __cUserID == '000033'
	IF __cUserID == '000033'
		aColunaB := aClone(aColunaA)
	EndIF
	@ 005,aColunaB[1]  SAY "A Pagar (Mes)........."		+ Padr(cValToChar(nQtCPMes),3) 	Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 016,aColunaB[1]  SAY "Atrasados(Mes)........"		+ Padr(cValToChar(nQtCPAtr),3) 	Of oPanel FONT oFnt COLOR CLR_BLACK  	Pixel SIZE 150,12
	@ 027,aColunaB[1]  SAY "A Vencer (Mes)........"		+ Padr(cValToChar(nQtCPAVC),3) 	Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 038,aColunaB[1]  SAY "Pagos(Mes)............"		+ Padr(cValToChar(nQtCPBX) ,3)	Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 049,aColunaB[1]  SAY "A Vencer (Futuro)....."		+ Padr(cValToChar(nQtCPFut),3) 	Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 060,aColunaB[1]  SAY "Ticket Medio (Mes)...." 	Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 071,aColunaB[1]  SAY "NF's Emitidas no Mes.."		Of oPanel FONT oFnt COLOR CLR_BLACK 	Pixel SIZE 150,12
	@ 005,aColunaB[2]  MSGET nCPMes 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 016,aColunaB[2]  MSGET nCPAtr 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_WHITE,CLR_HRED 	Pixel SIZE 070,10
	@ 027,aColunaB[2]  MSGET nCPAVC 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 038,aColunaB[2]  MSGET nCPBX 		Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 049,aColunaB[2]  MSGET nCPFut 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 060,aColunaB[2]  MSGET nTktMed 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
	@ 071,aColunaB[2]  MSGET nFatMes 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE 	Pixel SIZE 070,10
EndIF

//Saldos
@ 005,470  SAY "Sld Conciliado: "	Of oPanel FONT oFnt COLOR CLR_BLACK	 Pixel SIZE 120,12
@ 016,470  SAY "Sld Aplica็ใo:" 	Of oPanel FONT oFnt COLOR CLR_BLACK	 Pixel SIZE 120,12
@ 005,555  MSGET nBancos 	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE Pixel SIZE 070,10
@ 016,555  MSGET nAplicacao	Picture "@E 99,999,999" When .F. Of oPanel FONT oFnt COLOR CLR_HBLUE,CLR_WHITE Pixel SIZE 070,10

oPanel2:= TPanel():New( 0 , 0 , "" , oFolder:aDialogs[1] , NIL , .F. , .F. , NIL , NIL , 0 , 0 , .F. , .T. )
oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

oPanel2R:= TPanel():New( 0 , 0 , "" , oFolder:aDialogs[1] , NIL , .F. , .F. , NIL , NIL , 0 , 40 , .F. , .T. )
oPanel2R:Align:= CONTROL_ALIGN_BOTTOM

@ 005,004  SAY aTxt[1] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 015,004  SAY aTxt[2] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 025,004  SAY aTxt[3] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 005,200  SAY aTxt[4] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 015,200  SAY aTxt[5] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 025,200  SAY aTxt[6] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12
@ 005,400  SAY aTxt[7] 	Of oPanel2R FONT oFnt COLOR CLR_BLUE Pixel SIZE 150,12

@ 005,090  SAY aVlr[1] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 015,090  SAY aVlr[2] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 025,090  SAY aVlr[3] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 005,280  SAY aVlr[4] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 015,280  SAY aVlr[5] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 025,280  SAY aVlr[6] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12
@ 005,475  SAY aVlr[7] 	Of oPanel2R FONT oFnt COLOR CLR_HRED Pixel SIZE 120,12

IF __cUserID == '000092'
	oFolder2:= TFolder():New(0,0,{"A Receber no M๊s","A Receber - Futuro","A Receber - ATRASADOS","A Receber - Juridico","Saldos Bancarios","Movimenta็ใo Bancแria"},,oPanel2,,,,.T.,.F.)
	nFldRecMes		:= 1
	nFldRecTot		:= 2
	nFldAtrado		:= 3
	nFldJuridico	:= 4
	nFldSaldo		:= 5
	nFldMov			:= 6
ElseIF __cUserID == '000033'
	oFolder2:= TFolder():New(0,0,{"A Pagar - HOJE","A Pagar no M๊s","A Pagar Geral","Saldos Bancarios","Movimenta็ใo Bancแria"},,oPanel2,,,,.T.,.F.)
	nFldPagDia		:= 1
	nFldPagMes		:= 2
	nFldPagTot		:= 3
	nFldSaldo		:= 4
	nFldMov			:= 5
Else
	oFolder2:= TFolder():New(0,0,{"Recebimentos Mes - Sintetico","Devedores - Sintetico","Titulos A Receber no M๊s","A Receber - Futuro","A Receber - ATRASADOS","a Receber - Juridico","A Pagar - HOJE","A Pagar no M๊s","A Pagar Geral","Saldos Bancarios","Movimenta็ใo Bancแria","Faturamento do M๊s"},,oPanel2,,,,.T.,.F.)
EndIF

oFolder2:Align := CONTROL_ALIGN_ALLCLIENT
oFolder2:bSetOption:={|nAtu| MudaFolder(nAtu,oFolder2:nOption,oPanel2R,@aTxt,@aVlr,@oDlgPnl)}

nPAtr  := aScan(aHedRMes,{|x| AllTrim(x[2]) == "A1_ATR"})
nPSaldo:= aScan(aHedRMes,{|x| AllTrim(x[2]) == "E1_SALDO"})
nPValor:= aScan(aHedRMes,{|x| AllTrim(x[2]) == "E5_VALOR"})

IF lAdm .Or. __cUserID == '000092'

	bColor := &("{|| SyCorBrowse(4,oRecSint) }")
	oRecSint:= MsNewGetDados():New(0,0,oFolder2:nHeight*0.7,oFolder2:nWidth,0,,,,,,,,,,oFolder2:aDialogs[nFldRecSint],@aHRecSint,@aDRecSint)
	oRecSint:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRecSint:oBrowse:Refresh()
	oRecSint:oBrowse:SetBlkColor(bColor)
	oRecSint:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oRecSint,@nlOrdemCols) }
	oRecSint:oBrowse:cToolTip:= cMsgOrd

	bColor := &("{|| SyCorBrowse(4,oDevSint) }")
	oDevSint:= MsNewGetDados():New(0,0,oFolder2:nHeight*0.7,oFolder2:nWidth,0,,,,,,,,,,oFolder2:aDialogs[nFldDevSint],@aHDevSint,@aDDevSint)
	oDevSint:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oDevSint:oBrowse:Refresh()
	oDevSint:oBrowse:SetBlkColor(bColor)
	oDevSint:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oDevSint,@nlOrdemCols) }
	oDevSint:oBrowse:cToolTip:= cMsgOrd
	
	bColor := &("{|| SyCorBrowse(1,oJuridico) }")
	oJuridico:= MsNewGetDados():New(0,0,oFolder2:nHeight*0.7,oFolder2:nWidth,0,,,,,,,,,,oFolder2:aDialogs[nFldJuridico],@aHedRJurid,@aRecJurid)
	oJuridico:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oJuridico:oBrowse:Refresh()
	oJuridico:oBrowse:SetBlkColor(bColor)
	oJuridico:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oJuridico,@nlOrdemCols) }
	oJuridico:oBrowse:cToolTip:= cMsgOrd
	
	bColor := &("{|| SyCorBrowse(1,oAtrasados) }")
	oAtrasados:= MsNewGetDados():New(0,0,oFolder2:nHeight*0.7,oFolder2:nWidth,0,,,,,,,,,,oFolder2:aDialogs[nFldAtrado],@aHedRAtras,@aRecAtras)
	oAtrasados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oAtrasados:oBrowse:Refresh()
	oAtrasados:oBrowse:SetBlkColor(bColor)
	oAtrasados:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oAtrasados,@nlOrdemCols) }
	oAtrasados:oBrowse:cToolTip:= cMsgOrd
	
	bColor := &("{|| SyCorBrowse(1,oRecMes) }")
	oRecMes:= MsNewGetDados():New(0,0,oFolder2:nHeight*0.7,oFolder2:nWidth,0,,,,,,,,,,oFolder2:aDialogs[nFldRecMes],@aHedRMes,@aRecMes)
	oRecMes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRecMes:oBrowse:Refresh()
	oRecMes:oBrowse:SetBlkColor(bColor)
	oRecMes:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oRecMes,@nlOrdemCols) }
	oRecMes:oBrowse:cToolTip:= cMsgOrd
	
	bColor2 := &("{|| SyCorBrowse(1,oRecTotal) }")
	oRecTotal:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oFolder2:aDialogs[nFldRecTot],@aHedRTotal,@aRecTotal)
	oRecTotal:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRecTotal:oBrowse:Refresh()
	oRecTotal:oBrowse:SetBlkColor(bColor2)
	oRecTotal:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oRecTotal,@nlOrdemCols) }
	oRecTotal:oBrowse:cToolTip:= cMsgOrd
	
EndIF

IF lAdm .Or. __cUserID == '000033'
	
	bColor3 := &("{|| SyCorBrowse(2,oPagDia) }")
	oPagDia:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oFolder2:aDialogs[nFldPagDia],@aHedPDia,@aPagDia)
	oPagDia:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oPagDia:oBrowse:Refresh()
	oPagDia:oBrowse:SetBlkColor(bColor3)
	oPagDia:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oPagDia,@nlOrdemCols) }
	oPagDia:oBrowse:cToolTip:= cMsgOrd
	
	bColor3 := &("{|| SyCorBrowse(2,oPagMes) }")
	oPagMes:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oFolder2:aDialogs[nFldPagMes],@aHedPMes,@aPagMes)
	oPagMes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oPagMes:oBrowse:Refresh()
	oPagMes:oBrowse:SetBlkColor(bColor3)
	oPagMes:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oPagMes,@nlOrdemCols) }
	oPagMes:oBrowse:cToolTip:= cMsgOrd
	
	bColor4 := &("{|| SyCorBrowse(2,oPagTotal) }")
	oPagTotal:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oFolder2:aDialogs[nFldPagTot],@aHedPTotal,@aPagTotal)
	oPagTotal:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oPagTotal:oBrowse:Refresh()
	oPagTotal:oBrowse:SetBlkColor(bColor4)
	oPagTotal:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oPagTotal,@nlOrdemCols) }
	oPagTotal:oBrowse:cToolTip:= cMsgOrd
	
EndIF

oGetSaldo:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oFolder2:aDialogs[nFldSaldo],@aHedSE8,@aDadosSE8)
oGetSaldo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetSaldo:oBrowse:Refresh()
oGetSaldo:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oGetSaldo,@nlOrdemCols) }
oGetSaldo:oBrowse:cToolTip:= cMsgOrd

oPanel3:= TPanel():New( 0 , 0 , "" , oFolder2:aDialogs[nFldMov] , NIL , .F. , .F. , NIL , NIL , 0 , 0 , .F. , .T. )
oPanel3:Align:= CONTROL_ALIGN_ALLCLIENT

bColor5 := &("{|| SyCorBrowse(3,oGetMovBanco) }")
oGetMovBanco:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oPanel3,@aHedSE5,@aDadosSE5)
oGetMovBanco:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetMovBanco:oBrowse:Refresh()
oGetMovBanco:oBrowse:SetBlkColor(bColor5)
oGetMovBanco:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oGetMovBanco,@nlOrdemCols) }
oGetMovBanco:oBrowse:cToolTip:= cMsgOrd

bColor5 := &("{|| SyCorBrowse(5,oGetFatMes) }")
oGetFatMes:= MsNewGetDados():New(0,0,0,0,0,,,,,,,,,,oPanel3,@aHedFMes,@aFatMes)
oGetFatMes:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetFatMes:oBrowse:Refresh()
oGetFatMes:oBrowse:SetBlkColor(bColor5)
oGetFatMes:oBrowse:bHeaderClick := {|oObj,nCol| U_SyOrdCab(nCol,@oGetFatMes,@nlOrdemCols) }
oGetFatMes:oBrowse:cToolTip:= cMsgOrd


IF lAdm .Or. __cUserID == '000092'
	MudaFolder(nFldRecSint,nFldRecSint,oPanel2R,@aTxt,@aVlr,@oDlgPnl)
	ACTIVATE MSDIALOG oDlgPnl ON INIT ( oRecMes:oBrowse:nAt:= Len(aRecMes), oRecMes:oBrowse:Refresh(),oRecMes:oBrowse:nAt:= 1, oRecMes:oBrowse:Refresh(), EnchoiceBar(oDlgPnl,{|| oDlgPnl:End() }, {|| oDlgPnl:End() },,aButtons) )
ElseIF __cUserID == '000033'
	MudaFolder(nFldPagDia,nFldPagDia,oPanel2R,@aTxt,@aVlr,@oDlgPnl)
	ACTIVATE MSDIALOG oDlgPnl ON INIT ( oPagDia:oBrowse:Refresh() 	, EnchoiceBar(oDlgPnl,{|| oDlgPnl:End() }, {|| oDlgPnl:End() },,aButtons) )
EndIF

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออัอออออัอออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SyReceber ณAutorณ   Alexandro Dias    ณ Data ณ  09/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออฯอออออฯอออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra o contas a receber.                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SyReceber(aHedRMes,aRecMes,aHedRTotal,aRecTotal,aHedRAtras,aRecAtras,aHedRJurid,aRecJurid,aHRecSint,aDRecSint,aHDevSint,aDDevSint)

Local nX	 	:= 0
Local aHeader	:= {}
Local aHeader2	:= {}
Local aDados	:= {}
Local cQuery 	:= ""
Local aCpos	 	:= {"E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_NUMNF","E1_SERIENF","E1_DTHIST","E1_VALOR","E1_SALDO","E1_EMISSAO","E1_VENCREA","E1_HIST","E1_BAIXA","E5_VALOR","A1_ATR","E1_TIPO","E1_PORTADO","E1_NATUREZ"}
Local aCposSint	:= {"E1_CLIENTE","E1_LOJA","E1_NOMCLI","QTDE","E1_SALDO","E5_VALOR","MEDIA"}
Local nPAtr     := 0
Local nPBaixa   := 0
Local nPVencRea := 0
Local nAt       := 0
Local nPPrefixo := 0
Local nPNum     := 0
Local nPParcela := 0
Local nPTipo    := 0
Local nPCliente := 0
Local nPLoja    := 0
Local nPValor   := 0
Local nPSaldo   := 0
Local nPNaturez := 0
Local nVlMes    := 0
Local aBaixa    := 0
Local nI 		:= 0

If Select("TRBFIN") > 0
	TRBFIN->(dbCloseArea())
EndIf	
//Verifica os titulos em Aberto
cQuery := " SELECT E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_NUMNF,E1_SERIENF,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_DTHIST,E1_TIPO,0 AS E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_HIST, 0 AS E5_VALOR,E1_NATUREZ,E1_PORTADO, R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName('SE1') + " SE1 "
cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+ "' "
cQuery += " AND SE1.E1_SALDO > 0 "
cQuery += " AND SUBSTRING(SE1.E1_TIPO,3,1) <> '-' "
cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
cQuery += " AND SE1.E1_FATURA IN ('','NOTFAT') "
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF


cQuery += " ORDER BY E1_FILIAL,E1_NOMCLI,E1_VENCREA "
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.F.,.T.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aCpos)
	If SX3->(DbSeek(aCpos[nX]))
		Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,IIF(SX3->X3_TIPO='N','@E 999,999.99',SX3->X3_PICTURE),SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})

		IF SX3->X3_TIPO != "C"
			TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
		EndIF
	EndIf	
Next
Aadd(aHeader,{'R_E_C_N_O_','R_E_C_N_O_','999999999',9,0,'','','N','','','','',".T."})

//Preenche o header dos dados sinteticos
SX3->(DbSetOrder(2))
For nX := 1 To Len(aCposSint)
	If SX3->(DbSeek(aCposSint[nX]))
		Aadd(aHeader2,{AllTrim(X3Titulo()),SX3->X3_CAMPO,IIF(SX3->X3_TIPO='N','@E 999,999.99',SX3->X3_PICTURE),SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})

		IF SX3->X3_TIPO != "C"
			TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
		EndIF
	Else 
		If aCposSint[nX] == "QTDE"
			SX3->(DbSeek("C5_QUANT"))
			Aadd(aHeader2,{"Qtd.Titulos","QTDE",IIF(SX3->X3_TIPO='N','@E 999,999.99',SX3->X3_PICTURE),SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
			SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
		ElseIf aCposSint[nX] == "MEDIA"
			SX3->(DbSeek("E1_VALOR"))
			Aadd(aHeader2,{"Ticket Medio","MEDIA",IIF(SX3->X3_TIPO='N','@E 999,999.99',SX3->X3_PICTURE),SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
			SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
		EndIf
	EndIf

Next
Aadd(aHeader2,{'R_E_C_N_O_','R_E_C_N_O_','999999999',9,0,'','','N','','','','',".T."})

aHedRMes 	:= aClone(aHeader)
aHedRTotal	:= aClone(aHeader)
aHedRAtras	:= aClone(aHeader)
aHedRJurid	:= aClone(aHeader)

aHRecSint   := aClone(aHeader2)
aHDevSint   := aClone(aHeader2)

nPAtr    := aScan(aHeader,{|x| AllTrim(x[2]) == "A1_ATR"})
nPBaixa  := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_BAIXA"})
nPVencRea:= aScan(aHeader,{|x| AllTrim(x[2]) == "E1_VENCREA"})
nPPrefixo:= aScan(aHeader,{|x| AllTrim(x[2]) == "E1_PREFIXO"})
nPNum    := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_NUM"})
nPParcela:= aScan(aHeader,{|x| AllTrim(x[2]) == "E1_PARCELA"})
nPTipo   := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_TIPO"})
nPNaturez:= aScan(aHeader,{|x| AllTrim(x[2]) == "E1_NATUREZ"})
nPCliente:= aScan(aHeader,{|x| AllTrim(x[2]) == "E1_CLIENTE"})
nPLoja   := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_LOJA"})
nPValor  := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_VALOR"})
nPVLBx   := aScan(aHeader,{|x| AllTrim(x[2]) == "E5_VALOR"})
nPSaldo  := aScan(aHeader,{|x| AllTrim(x[2]) == "E1_SALDO"})
nPQtde2  := aScan(aHeader2,{|x| AllTrim(x[2]) == "QTDE"})
nPVLBx2  := aScan(aHeader2,{|x| AllTrim(x[2]) == "E5_VALOR"})
nPSaldo2 := aScan(aHeader2,{|x| AllTrim(x[2]) == "E1_SALDO"})
nPMedia  := aScan(aHeader2,{|x| AllTrim(x[2]) == "MEDIA"})


DbSelectArea("TRBFIN")
TRBFIN->(DbGoTop())
While !TRBFIN->(Eof())
	
	//Contas a Receber no Mes
	SE1->(dbSetOrder(1))
	SE1->(dbSeek(xFilial("SE1")+TRBFIN->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
	
	nVlMes   := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,FirstDay(dDatabase)-1,FirstDay(dDatabase)-1,SE1->E1_LOJA,SE1->E1_FILIAL,1,1)
	
	IF (Left(Dtos(TRBFIN->E1_VENCREA),6) == Left(Dtos(LastDay(dDatabase)),6)) .And. (SE1->E1_PORTADO <> '999')
		
		Aadd( aRecMes , Array( Len(aHeader)+1 ) )
		nAt:= Len(aRecMes)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aRecMes[nAt,nX] := IIf( Empty(aRecMes[nAT,nPBaixa]) .Or.;
				(!Empty(aRecMes[nAT,nPBaixa]) .And. aRecMes[nAt,nPSaldo] > 0),dDatabase - aRecMes[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E1_VALOR")
				aRecMes[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aRecMes[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E1_NATUREZ,"ED_DESCRIC")
			ElseIF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
				aRecMes[nAT,nX] := TRBFIN->(Recno())
			ElseIF ( aHeader[nX][10] != "V" )
				aRecMes[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aRecMes[nAT,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aRecMes[nAt,Len(aHeader)+1] := .F.

		nPos:= aScan(aDRecSint,{|x| x[1] == SE1->E1_CLIENTE})
		If (nPos == 0)
			Aadd( aDRecSint , Array( Len(aHeader2)+1 ) )


			nAt:= Len(aDRecSint)
			For nX	:= 1 To Len(aHeader2)
				IF ( AllTrim(aHeader2[nX,2]) == "QTDE")
					aDRecSint[nAt,nX] := 1
				ElseIF ( AllTrim(aHeader2[nX,2]) == "MEDIA")
					aDRecSint[nAt,nX] := TRBFIN->E1_SALDO
				ElseIF ( AllTrim(aHeader2[nX,2]) == "R_E_C_N_O_")
					aDRecSint[nAt,nX] := TRBFIN->(Recno())
				ElseIF ( aHeader2[nX][10] != "V" )
					aDRecSint[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader2[nX,2])))
				Else
					aDRecSint[nAT,nX] := CriaVar(aHeader2[nX,2],.F.)
				EndIF
			Next nX
			aDRecSint[nAt,Len(aHeader2)+1] := .F.
		Else
			aDRecSint[nPos,nPQtde2] += 1	
			aDRecSint[nPos,nPSaldo2]+= TRBFIN->E1_SALDO
			aDRecSint[nPos,nPVlBx2] += TRBFIN->E5_VALOR
			aDRecSint[nPos,nPMedia] := aDRecSint[nPos,nPSaldo2]/aDRecSint[nPos,nPQtde2]
		EndIf
		
	EndIF
	
	//Atrasados
	If Dtos(TRBFIN->E1_VENCREA) < Dtos(FirstDay(dDataBase)) .And. TRBFIN->E1_SALDO > 0 .And. (SE1->E1_PORTADO <> '999')
		                                               
		Aadd( aRecAtras , Array( Len(aHeader)+1 ) )
		nAt:= Len(aRecAtras)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aRecAtras[nAt,nX] := IIf( Empty(aRecAtras[nAT,nPBaixa]) .Or.;
				(!Empty(aRecAtras[nAT,nPBaixa]) .And. aRecAtras[nAt,nPSaldo] > 0),dDatabase - aRecAtras[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E1_VALOR")
				aRecAtras[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aRecAtras[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E1_NATUREZ,"ED_DESCRIC")
			ElseIF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
				aRecAtras[nAt,nX] := TRBFIN->(Recno())
			ElseIF ( aHeader[nX][10] != "V" )
				aRecAtras[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aRecAtras[nAT,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aRecAtras[nAt,Len(aHeader)+1] := .F.

		nPos:= aScan(aDDevSint,{|x| x[1] == SE1->E1_CLIENTE})
		If (nPos == 0)
			Aadd( aDDevSint , Array( Len(aHeader2)+1 ) )


			nAt:= Len(aDDevSint)
			For nX	:= 1 To Len(aHeader2)
				IF ( AllTrim(aHeader2[nX,2]) == "QTDE")
					aDDevSint[nAt,nX] := 1
				ElseIF ( AllTrim(aHeader2[nX,2]) == "MEDIA")
					aDDevSint[nAt,nX] := TRBFIN->E1_SALDO
				ElseIF ( AllTrim(aHeader2[nX,2]) == "R_E_C_N_O_")
					aDDevSint[nAt,nX] := TRBFIN->(Recno())
				ElseIF ( aHeader2[nX][10] != "V" )
					aDDevSint[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader2[nX,2])))
				Else
					aDDevSint[nAT,nX] := CriaVar(aHeader2[nX,2],.F.)
				EndIF
			Next nX
			aDDevSint[nAt,Len(aHeader2)+1] := .F.
		Else
			aDDevSint[nPos,nPQtde2] += 1	
			aDDevSint[nPos,nPSaldo2]+= TRBFIN->E1_SALDO
			aDDevSint[nPos,nPVlBx2] += TRBFIN->E5_VALOR
			aDDevSint[nPos,nPMedia]:= aDDevSint[nPos,nPSaldo2]/aDDevSint[nPos,nPQtde2]
		EndIf
		
	EndIF
	
	//Juridico
//	If Dtos(TRBFIN->E1_VENCREA) < Dtos(dDataBase) .And. TRBFIN->E1_SALDO > 0 .And. (SE1->E1_PORTADO == '999')
	If TRBFIN->E1_SALDO > 0 .And. (SE1->E1_PORTADO == '999')
		
		Aadd( aRecJurid , Array( Len(aHeader)+1 ) )
		nAt:= Len(aRecJurid)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aRecJurid[nAt,nX] := IIf( Empty(aRecJurid[nAT,nPBaixa]) .Or.;
				(!Empty(aRecJurid[nAT,nPBaixa]) .And. aRecJurid[nAt,nPSaldo] > 0),dDatabase - aRecJurid[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E1_VALOR")
				aRecJurid[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aRecJurid[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E1_NATUREZ,"ED_DESCRIC")
			ElseIF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
				aRecJurid[nAt,nX] := TRBFIN->(Recno())
			ElseIF ( aHeader[nX][10] != "V" )
				aRecJurid[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aRecJurid[nAT,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aRecJurid[nAt,Len(aHeader)+1] := .F.
		
	EndIF
	
	//Receber Futuro
	IF (Left(Dtos(TRBFIN->E1_VENCREA),6) > Left(Dtos(LastDay(dDatabase)),6)) .And. (SE1->E1_PORTADO <> '999')
		
		Aadd( aRecTotal , Array( Len(aHeader)+1 ) )
		nAt:= Len(aRecTotal)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aRecTotal[nAt,nX] := IIf( Empty(aRecTotal[nAT,nPBaixa]) .Or.;
				(!Empty(aRecTotal[nAT,nPBaixa]) .And. aRecTotal[nAt,nPSaldo] > 0),dDatabase - aRecTotal[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E1_VALOR")
				aRecTotal[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aRecTotal[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E1_NATUREZ,"ED_DESCRIC")
			ElseIF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
				aRecTotal[nAt,nX] := TRBFIN->(Recno())
			ElseIF ( aHeader[nX,10] != "V" )
				aRecTotal[nAt,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aRecTotal[nAt,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aRecTotal[nAt,Len(aHeader)+1] := .F.
		
	EndIF
	
	DbSelectArea("TRBFIN")
	DbSkip()
	
EndDo

DbCloseArea("TRBFIN")

//Pega as Baixas dos titulos em aberto do mes
dbSelectArea("SE5")

For nI:= 1 To Len(aRecMes)
	aBaixa := Baixas(aRecMes[nI,nPNaturez],aRecMes[nI,nPPrefixo],aRecMes[nI,nPNum],aRecMes[nI,nPParcela],aRecMes[nI,nPTipo],1,"R",aRecMes[nI,nPCliente],dDataBase,aRecMes[nI,nPLoja]	,xFilial("SE5"),FirstDay(dDatabase),LastDay(dDatabase),.T.)
	aRecMes[nI,nPVLBx]+= aBaixa[10]

	nPos:= aScan(aDRecSint,{|x| x[nPCliente] == aRecMes[nI,nPCliente]})
	If (nPos > 0)
		aDRecSint[nPos,nPVlBx2] += aBaixa[10]
	EndIf

Next nI

//Pega as Baixas dos titulos atrasados
For nI:= 1 To Len(aRecAtras)
	aBaixa := Baixas(aRecAtras[nI,nPNaturez],aRecAtras[nI,nPPrefixo],aRecAtras[nI,nPNum],aRecAtras[nI,nPParcela],aRecAtras[nI,nPTipo],1,"R",aRecAtras[nI,nPCliente],dDataBase,aRecAtras[nI,nPLoja]	,xFilial("SE5"),FirstDay(dDatabase),LastDay(dDatabase),.T.)
	aRecAtras[nI,nPVLBx]+= aBaixa[10]

	nPos:= aScan(aDDevSint,{|x| x[nPCliente] == aRecAtras[nI,nPCliente]})
	If (nPos > 0)
		aDDevSint[nPos,nPVlBx2] += aBaixa[10]
	EndIf
Next nI

For nI:= 1 To Len(aRecTotal)
	aBaixa 	:= Baixas(aRecTotal[nI,nPNaturez],aRecTotal[nI,nPPrefixo],aRecTotal[nI,nPNum],aRecTotal[nI,nPParcela],aRecTotal[nI,nPTipo],1,"R",aRecTotal[nI,nPCliente],dDataBase,aRecTotal[nI,nPLoja],xFilial("SE5"),FirstDay(dDatabase),LastDay(dDatabase),.T.)
	aRecTotal[nI,nPVLBx]+= aBaixa[10]
Next nI

//Verifica se estแ vazio
IF (Len(aRecMes) == 0) .Or. (Len(aRecTotal) == 0)
	
	aDados := {}
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	nAt:= Len(aDados)
	For nX	:= 1 To Len(aHeader)
		IF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
			aDados[nAt,nX] := 0
		Else
			aDados[nAt,nX] := CriaVar(aHeader[nX][2],.F.)
		EndIf	
	Next nX
	aDados[nAt,Len(aHeader)+1] := .F.
	
	If (Len(aRecMes) == 0)
		aRecMes 	:= aClone(aDados)
	EndIF	
		
	If (Len(aRecTotal) == 0)
		aRecTotal	:= aClone(aDados)
	EndIf	

	If (Len(aDRecSint) == 0)
	
		aDados := {}
		Aadd( aDados , Array( Len(aHeader2)+1 ) )
		nAt:= Len(aDados)
		For nX	:= 1 To Len(aHeader2)
			IF ( AllTrim(aHeader2[nX,2]) == "QTDE")
				aDados[nAt,nX] := 0
			ElseIF ( AllTrim(aHeader2[nX,2]) == "MEDIA")
				aDados[nAt,nX] := 0
			ElseIF ( AllTrim(aHeader2[nX,2]) == "R_E_C_N_O_")
				aDados[nAt,nX] := 0
			Else
				aDados[nAt,nX] := CriaVar(aHeader2[nX][2],.F.)
			EndIF
		Next nX
		aDados[nAt,Len(aHeader2)+1] := .F.
		aDRecSint 	:= aClone(aDados)
	EndIf	
EndIf

//Verifica se estแ vazio
IF (Len(aRecAtras) == 0) .Or. (Len(aRecTotal) == 0)
	
	aDados := {}
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	nAt:= Len(aDados)
	For nX	:= 1 To Len(aHeader)
		IF ( AllTrim(aHeader[nX,2]) == "R_E_C_N_O_")
			aDados[nAt,nX] := 0
		Else
			aDados[nAt,nX] := CriaVar(aHeader[nX][2],.F.)
		EndIf	
	Next nX
	aDados[nAt,Len(aHeader)+1] := .F.
	
	
	aRecAtras 	:= aClone(aDados)
	aRecTotal	:= aClone(aDados)

	aDados := {}
	Aadd( aDados , Array( Len(aHeader2)+1 ) )
	nAt:= Len(aDados)
	For nX	:= 1 To Len(aHeader2)
		IF ( AllTrim(aHeader2[nX,2]) == "QTDE")
			aDados[nAt,nX] := 0
		ElseIF ( AllTrim(aHeader2[nX,2]) == "MEDIA")
			aDados[nAt,nX] := 0
		ElseIF ( AllTrim(aHeader2[nX,2]) == "R_E_C_N_O_")
			aDados[nAt,nX] := 0
		ElseIF ( aHeader2[nX][10] != "V" )
			aDados[nAt,nX] := TRBFIN->(FieldGet(FieldPos(aHeader2[nX,2])))
		Else
			aDados[nAt,nX] := CriaVar(aHeader2[nX][2],.F.)
		EndIF
	Next nX
	aDados[nAt,Len(aHeader2)+1] := .F.
	aDDevSint 	:= aClone(aDados)
	
EndIf

//Ordena por tempo de atraso
aRecAtras 	:= aSort( aRecAtras  , , , { |x,y| x[3] + Dtos(x[nPVencRea]) < y[3] + Dtos(y[nPVencRea])} )
aRecMes 	:= aSort( aRecMes    , , , { |x,y| x[3] + Dtos(x[nPVencRea]) < y[3] + Dtos(y[nPVencRea])} )
aRecTotal 	:= aSort( aRecTotal  , , , { |x,y| x[3] + Dtos(x[nPVencRea]) < y[3] + Dtos(y[nPVencRea])} )
aDRecSint 	:= aSort( aDRecSint  , , , { |x,y| x[nPSaldo2] > y[nPSaldo2]} )
aDDevSint 	:= aSort( aDDevSint  , , , { |x,y| x[nPSaldo2] > y[nPSaldo2]} )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออัอออออัอออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  SyPagar  ณAutorณ   Alexandro Dias    ณ Data ณ  09/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออฯอออออฯอออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra o contas a pagar.                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SyPagar(aHedPMes,aPagMes,aHedPTotal,aPagTotal,aHedPDia,aPagDia)

Local nX	 	:= 0
Local aHeader	:= {}
Local aDados	:= {}
Local cQuery 	:= ""
Local aCpos	 	:= {"E2_FORNECE","E2_LOJA","E2_NOMFOR","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_VALOR","E2_SALDO","E2_EMISSAO","E2_VENCREA","E2_BAIXA","E2_HIST","E5_VALOR","A1_ATR","E2_TIPO","E2_PORTADO","E2_NATUREZ"}
Local nPAtr    	:= 0
Local nPBaixa   := 0
Local nPVencRea := 0
Local nAt       := 0
Local nPPrefixo := 0
Local nPNum     := 0
Local nPParcela := 0
Local nPTipo    := 0
Local nPFornece := 0
Local nPLoja    := 0
Local nPValor   := 0
Local nPSaldo   := 0
Local nPNaturez := 0
Local nVlMes    := 0
Local aBaixa    := 0
Local ni 		:= 0
//Verifica os titulos em Aberto
cQuery := " SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,0 AS E2_VALOR,E2_SALDO,E2_EMISSAO,E2_VENCREA,E2_BAIXA,E2_HIST, 0 AS E5_VALOR,E2_NATUREZ,E2_DESCONT, R_E_C_N_O_ " 
cQuery += " FROM " + RetSqlName('SE2') + " SE2 "
cQuery += " WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+ "' "
//cQuery += " AND ((SE2.E2_SALDO > 0) OR (SE2.E2_BAIXA BETWEEN '" + Dtos(FirstDay(dDatabase)) + "' AND '" + Dtos(LastDay(dDatabase)) +"'))"
cQuery += " AND SE2.E2_SALDO > 0 "
cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY E2_FILIAL,E2_NOMFOR,E2_VENCREA "
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.F.,.T.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aCpos)
	SX3->(DbSeek(aCpos[nX]))
	Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,IIF(SX3->X3_TIPO='N','@E 999,999.99',SX3->X3_PICTURE),SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
	SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
	IF SX3->X3_TIPO != "C"
		TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	EndIF
Next
Aadd(aHeader,{'R_E_C_N_O_','R_E_C_N_O_','999999999',9,0,'','','N','','','','',".T."})

aHedPMes 	:= aClone(aHeader)
aHedPDia 	:= aClone(aHeader)
aHedPTotal	:= aClone(aHeader)

nPAtr    := aScan(aHeader,{|x| AllTrim(x[2]) == "A1_ATR"})
nPBaixa  := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_BAIXA"})
nPVencRea:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_VENCREA"})
nPPrefixo:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_PREFIXO"})
nPNum    := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_NUM"})
nPParcela:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_PARCELA"})
nPTipo   := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_TIPO"})
nPNaturez:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_NATUREZ"})
nPFornece:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_FORNECE"})
nPNomeFor:= aScan(aHeader,{|x| AllTrim(x[2]) == "E2_NOMFOR"})
nPLoja   := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_LOJA"})
nPValor  := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_VALOR"})
nPVLBx   := aScan(aHeader,{|x| AllTrim(x[2]) == "E5_VALOR"})
nPSaldo  := aScan(aHeader,{|x| AllTrim(x[2]) == "E2_SALDO"})

DbSelectArea("TRBFIN")
DbGoTop()
While !Eof()
	
	//Contas a Pagar no Mes
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(xFilial("SE2")+TRBFIN->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
	
	nVlMes   := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,FirstDay(dDatabase)-1,FirstDay(dDatabase)-1,SE2->E2_LOJA,SE2->E2_FILIAL,1,1) - SE2->E2_DESCONT
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Vencidos e para pagar no Dia.          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF ( Dtos(TRBFIN->E2_VENCREA) <= Dtos(dDatabase) .And. TRBFIN->E2_SALDO > 0 ) .Or. ( Dtos(TRBFIN->E2_VENCREA) == Dtos(dDatabase) )
		
		Aadd( aPagDia , Array( Len(aHeader)+1 ) )
		nAt:= Len(aPagDia)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aPagDia[nAt,nX] := IIf( Empty(aPagDia[nAT,nPBaixa]) .Or.;
				(!Empty(aPagDia[nAT,nPBaixa]) .And. aPagDia[nAt,nPSaldo] > 0),dDatabase - aPagDia[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E2_VALOR")
				aPagDia[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aPagDia[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E2_NATUREZ,"ED_DESCRIC")
			ElseIF ( aHeader[nX][10] != "V" )
				aPagDia[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aPagDia[nAT,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aPagDia[nAt,Len(aHeader)+1] := .F.
		
	EndIF
	
	IF (Left(Dtos(TRBFIN->E2_VENCREA),6) == Left(Dtos(LastDay(dDatabase)),6))
		
		Aadd( aPagMes , Array( Len(aHeader)+1 ) )
		nAt:= Len(aPagMes)
		For nX	:= 1 To Len(aHeader)
			IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
				aPagMes[nAt,nX] := IIf( Empty(aPagMes[nAT,nPBaixa]) .Or.;
				(!Empty(aPagMes[nAT,nPBaixa]) .And. aPagMes[nAt,nPSaldo] > 0),dDatabase - aPagMes[nAT,nPVencRea],0)
			ElseIF ( AllTrim(aHeader[nX,2]) == "E2_VALOR")
				aPagMes[nAT,nX] := nVlMes
			ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
				aPagMes[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E2_NATUREZ,"ED_DESCRIC")
			ElseIF ( aHeader[nX][10] != "V" )
				aPagMes[nAT,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
			Else
				aPagMes[nAT,nX] := CriaVar(aHeader[nX,2],.F.)
			EndIF
		Next nX
		aPagMes[nAt,Len(aHeader)+1] := .F.
	EndIF
	
	Aadd( aPagTotal , Array( Len(aHeader)+1 ) )
	nAt:= Len(aPagTotal)
	For nX	:= 1 To Len(aHeader)
		IF ( AllTrim(aHeader[nX,2]) == "A1_ATR")
			aPagTotal[nAt,nX] := IIf( Empty(aPagTotal[nAT,nPBaixa]) .Or.;
			(!Empty(aPagTotal[nAT,nPBaixa]) .And. aPagTotal[nAt,nPSaldo] > 0),dDatabase - aPagTotal[nAT,nPVencRea],0)
		ElseIF ( AllTrim(aHeader[nX,2]) == "E2_VALOR")
			aPagTotal[nAT,nX] := nVlMes
		ElseIF ( AllTrim(aHeader[nX,2]) == "ED_DESCRIC")
			aPagTotal[nAT,nX] := Posicione("SED",1,xFilial("SED")+TRBFIN->E2_NATUREZ,"ED_DESCRIC")
		ElseIF ( aHeader[nX,10] != "V" )
			aPagTotal[nAt,nX] := TRBFIN->(FieldGet(FieldPos(aHeader[nX,2])))
		Else
			aPagTotal[nAt,nX] := CriaVar(aHeader[nX,2],.F.)
		EndIF
	Next nX
	aPagTotal[nAt,Len(aHeader)+1] := .F.
	
	DbSelectArea("TRBFIN")
	DbSkip()
	
EndDo

DbCloseArea("TRBFIN")

//Pega as Baixas
dbSelectArea("SE2")
dbSelectArea("SE5")

For nI:= 1 To Len(aPagTotal)
	aBaixa := Baixas(aPagTotal[nI,nPNaturez],aPagTotal[nI,nPPrefixo],aPagTotal[nI,nPNum],aPagTotal[nI,nPParcela],aPagTotal[nI,nPTipo],1,"P",aPagTotal[nI,nPFornece],dDataBase,aPagTotal[nI,nPLoja],xFilial("SE5"),FirstDay(dDatabase),LastDay(dDatabase),.T.)
	aPagTotal[nI,nPVLBx]+= aBaixa[10]
Next nI

For nI:= 1 To Len(aPagMes)
	aBaixa := Baixas(aPagMes[nI,nPNaturez],aPagMes[nI,nPPrefixo],aPagMes[nI,nPNum],aPagMes[nI,nPParcela],aPagMes[nI,nPTipo],1,"P",aPagMes[nI,nPFornece],dDataBase,aPagMes[nI,nPLoja],xFilial("SE5"),FirstDay(dDatabase),LastDay(dDatabase),.T.)
	aPagMes[nI,nPVLBx]+= aBaixa[10]
Next nI

//Verifica se estแ vazio
IF (Len(aPagMes) == 0) .Or. (Len(aPagTotal) == 0)
	
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	nAt:= Len(aDados)
	For nX	:= 1 To Len(aHeader)
		aDados[nAt,nX] := CriaVar(aHeader[nX][2],.F.)
	Next nX
	aDados[nAt,Len(aHeader)+1] := .F.

	aPagMes 	:= aClone(aDados)
	aPagTotal	:= aClone(aDados)
	
EndIf

//Ordena por tempo de atraso
aPagDia 	:= aSort( aPagDia  , , , { |x,y| x[nPNomeFor]+Dtos(x[nPVencRea]) > y[nPNomeFor]+Dtos(y[nPVencRea]) } )
aPagMes 	:= aSort( aPagMes  , , , { |x,y| x[nPAtr] > y[nPAtr]} )
aPagTotal 	:= aSort( aPagTotal, , , { |x,y| x[nPAtr] > y[nPAtr]} )

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออัอออออัอออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  SySaldo  ณAutorณ   Fabio Rogerio     ณ Data ณ  11/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออฯอออออฯอออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra o saldo bancario.                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SySaldo(nBancos,nAplicacao,aHedSE8,aDadosSE8)

Local nX	 	:= 0
Local aHeader	:= {}
Local aDados	:= {}
Local cCtaBco   := GetNewPar("MV_SYCTABCO","14774/3212/174734")
Local cCtaApl   := GetNewPar("MV_SYCTAAPL","14774A")
Local cQuery 	:= ""
Local aCpos	 	:= {"E8_BANCO","E8_AGENCIA","E8_CONTA","A6_NOME","A6_NREDUZ","E8_DTSALAT","E8_SALATUA"}

cQuery := " SELECT SE8.E8_FILIAL,SE8.E8_BANCO,SE8.E8_AGENCIA,SE8.E8_CONTA,SA6.A6_NOME,SA6.A6_NREDUZ,SE8.E8_DTSALAT,SE8.E8_SALATUA "
cQuery += " FROM " + RetSqlName('SE8') + " SE8, " + RetSqlName('SA6') + " SA6, "
cQuery += " (SELECT E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,MAX(E8_DTSALAT) AS E8_DTSALAT FROM " + RetSqlName('SE8') + " SE8X WHERE SE8X.D_E_L_E_T_ = ' ' GROUP BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA ) AS SE8X "
cQuery += " WHERE SE8.E8_FILIAL = '"+xFilial("SE8")+ "' "
cQuery += " AND SUBSTRING(SE8.E8_BANCO,1,2) <> 'CX' "
cQuery += " AND SE8.D_E_L_E_T_ = ' ' "
cQuery += " AND SA6.D_E_L_E_T_ = ' ' "
cQuery += " AND SA6.A6_BLOCKED <> '1' "
cQuery += " AND SA6.A6_COD     = SE8.E8_BANCO "
cQuery += " AND SA6.A6_AGENCIA = SE8.E8_AGENCIA "
cQuery += " AND SA6.A6_NUMCON  = SE8.E8_CONTA "
cQuery += " AND SE8.E8_FILIAL  = SE8X.E8_FILIAL "
cQuery += " AND SE8.E8_BANCO   = SE8X.E8_BANCO  "
cQuery += " AND SE8.E8_AGENCIA = SE8X.E8_AGENCIA "
cQuery += " AND SE8.E8_CONTA   = SE8X.E8_CONTA "
cQuery += " AND SE8.E8_DTSALAT = SE8X.E8_DTSALAT "
cQuery += " ORDER BY E8_FILIAL,E8_BANCO,E8_AGENCIA,E8_CONTA,E8_DTSALAT "
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.F.,.T.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aCpos)
	SX3->(DbSeek(aCpos[nX]))
	Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
	SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
	IF SX3->X3_TIPO != "C"
		TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	EndIF
Next

DbSelectArea("TRBFIN")
DbGoTop()
IF Eof()
	
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	For nX	:= 1 To Len(aHeader)
		aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
	Next nX
	aDados[Len(aDados)][Len(aHeader)+1] := .F.
	
Else
	
	While !Eof()
		
		If (AllTrim(TRBFIN->E8_CONTA) $ cCtaBco)// .And. (TRBFIN->E8_DTSALAT == dDatabase)
			nBancos  += TRBFIN->E8_SALATUA
		ElseIf (AllTrim(TRBFIN->E8_CONTA) $ cCtaApl)// .And. (TRBFIN->E8_DTSALAT == dDatabase)
			nAplicacao  += TRBFIN->E8_SALATUA
		EndIf
		
		Aadd( aDados , Array( Len(aHeader)+1 ) )
		For nX	:= 1 To Len(aHeader)
			IF ( aHeader[nX][10] != "V" )
				aDados[Len(aDados)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
			EndIF
		Next nX
		aDados[Len(aDados)][Len(aHeader)+1] := .F.
		
		DbSkip()
		
	EndDo
	
EndIF

DbCloseArea("TRBFIN")

aHedSE8 	:= aClone(aHeader)
aDadosSE8 	:= aClone(aDados)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออัอออออัอออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSyMovBanco ณAutorณ   Fabio Rogerio     ณ Data ณ  11/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออฯอออออฯอออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra os movimentos bancarios.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SyMovBanco(aHedSE5,aDadosSE5)

Local nX	 	:= 0
Local aHeader	:= {}
Local aDados	:= {}
Local cQuery 	:= ""
Local aCpos	 	:= {"E5_BANCO","E5_AGENCIA","E5_CONTA","A6_NOME","A6_NREDUZ","E5_DATA","E5_VALOR","E5_HISTOR","E5_NATUREZ","E5_NUMCHEQ","E5_DOCUMEN","E5_RECPAG","E5_MOEDA"}

cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName('SE5') + " SE5, " + RetSqlName('SA6') + " SA6, "
cQuery += " WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+ "' "
cQuery += " AND SE5.E5_DATA >= '" + Dtos(FirstDay(dDatabase)) + "'"
cQuery += " AND SUBSTRING(SE5.E5_BANCO,1,2) <> 'CX' "
cQuery += " AND SE5.E5_MOEDA IN ('M1') "
cQuery += " AND SE5.D_E_L_E_T_ = ' ' "
cQuery += " AND SA6.D_E_L_E_T_ = ' ' "
cQuery += " AND SA6.A6_COD     = SE5.E5_BANCO "
cQuery += " AND SA6.A6_AGENCIA = SE5.E5_AGENCIA "
cQuery += " AND SA6.A6_NUMCON  = SE5.E5_CONTA "
cQuery += " ORDER BY E5_FILIAL,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_DATA "
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.F.,.T.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aCpos)
	SX3->(DbSeek(aCpos[nX]))
	Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
	SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
	IF SX3->X3_TIPO != "C"
		TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	EndIF
Next

DbSelectArea("TRBFIN")
DbGoTop()
IF Eof()
	
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	For nX	:= 1 To Len(aHeader)
		aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
	Next nX
	aDados[Len(aDados)][Len(aHeader)+1] := .F.
	
Else
	
	While !Eof()
		
		Aadd( aDados , Array( Len(aHeader)+1 ) )
		For nX	:= 1 To Len(aHeader)
			IF ( aHeader[nX][10] != "V" )
				aDados[Len(aDados)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
			EndIF
		Next nX
		aDados[Len(aDados)][Len(aHeader)+1] := .F.
		
		DbSkip()
		
	EndDo
	
EndIF

DbCloseArea("TRBFIN")

aHedSE5 	:= aClone(aHeader)
aDadosSE5 	:= aClone(aDados)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออัอออออัอออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSyMovBanco ณAutorณ   Fabio Rogerio     ณ Data ณ  11/08/08   บฑฑ
ฑฑฬออออออออออุอออออออออออฯอออออฯอออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Filtra os movimentos bancarios.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SyFaturamento(aHedFMes,aFatMes)

Local nX	 	:= 0
Local aHeader	:= {}
Local aDados	:= {}
Local cQuery 	:= ""
Local aCpos	 	:= {"F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","A1_NREDUZ","F2_EMISSAO","F2_VALBRUT"}

cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName('SF2') + " SF2, " + RetSqlName('SA1') + " SA1 "
cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+ "' "
cQuery += " AND SF2.F2_EMISSAO BETWEEN '" + Dtos(FirstDay(dDatabase)) + "' AND '" + Dtos(LastDay(dDatabase)) + "'"
cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND SF2.F2_CLIENTE = SA1.A1_COD "
cQuery += " AND SF2.F2_LOJA    = SA1.A1_LOJA "
cQuery += " ORDER BY F2_FILIAL,F2_EMISSAO,F2_SERIE,F2_DOC "
cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.F.,.T.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aCpos)
	SX3->(DbSeek(aCpos[nX]))
	Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
	SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,".T."})
	IF SX3->X3_TIPO != "C"
		TcSetField("TRBFIN",SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL)
	EndIF
Next

DbSelectArea("TRBFIN")
DbGoTop()
IF Eof()
	
	Aadd( aDados , Array( Len(aHeader)+1 ) )
	For nX	:= 1 To Len(aHeader)
		aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
	Next nX
	aDados[Len(aDados)][Len(aHeader)+1] := .F.
	
Else
	
	While !Eof()
		
		Aadd( aDados , Array( Len(aHeader)+1 ) )
		For nX	:= 1 To Len(aHeader)
			IF ( aHeader[nX][10] != "V" )
				aDados[Len(aDados)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			Else
				aDados[Len(aDados)][nX] := CriaVar(aHeader[nX][2],.F.)
			EndIF
		Next nX
		aDados[Len(aDados)][Len(aHeader)+1] := .F.
		
		DbSkip()
		
	EndDo
	
EndIF

DbCloseArea("TRBFIN")

aHedFMes 	:= aClone(aHeader)
aFatMes 	:= aClone(aDados)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณSYCORBROWSEบAutor  ณMicrosiga           บ Data ณ  06/29/09  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณDefini a cor do browse                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SYCorBrowse(nTipo,oBrowse)

Local cCor     := CLR_BLACK
Local nPAtr    := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "A1_ATR"})
Local nPVencRea:= aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_VENCREA"})
Local nPBaixa  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_BAIXA"})
Local nPSaldo  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_SALDO"})
Local nPRecPag := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E5_RECPAG"})
Local nPQtde   := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "QTDE"})
Local nPValNF  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "F2_VALBRUT"})

If (nTipo == 1) // Contas a Receber
	nPAtr    := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "A1_ATR"})
	nPVencRea:= aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_VENCREA"})
	nPBaixa  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_BAIXA"})
	nPSaldo  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E1_SALDO"})
ElseIf (nTipo == 2)
	nPAtr    := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "A1_ATR"})
	nPVencRea:= aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E2_VENCREA"})
	nPBaixa  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E2_BAIXA"})
	nPSaldo  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E2_SALDO"})
ElseIf (nTipo == 3)
	nPRecPag := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E5_RECPAG"})
ElseIf (nTipo == 4) //Sinteticos
	nPQtde  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "QTDE"})
	nPBaixa := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "E5_VALOR"})
ElseIf (nTipo == 5) //Faturamento
	nPValNF  := aScan(oBrowse:aHeader,{|x| AllTrim(x[2]) == "F2_VALBRUT"})
EndIf

Do Case
	Case (nTipo == 1 .Or. nTipo == 2)
		If !Empty(oBrowse:aCols[oBrowse:nAt,nPBaixa]) .And. (oBrowse:aCols[oBrowse:nAt,nPSaldo] == 0) //Baixado
			cCor:= CLR_BLUE
		ElseIf (oBrowse:aCols[oBrowse:nAt,nPAtr] > 0) //Atrasado
			cCor:= CLR_RED
		Else
			cCor:= CLR_GREEN
		EndIf
	Case (nTipo == 3)
		If (oBrowse:aCols[oBrowse:nAt,nPRecPag] == "R") //Receber
			cCor:= CLR_BLUE
		Else
			cCor:= CLR_RED
		EndIf
	Case (nTipo == 4)
		If (oBrowse:aCols[oBrowse:nAt,nPBaixa] == oBrowse:aCols[oBrowse:nAt,nPSaldo]) //Recebeu todo o titulo
			cCor:= CLR_GREEN
		ElseIf (oBrowse:aCols[oBrowse:nAt,nPBaixa] > 0) //Recebeu parte do titulo
			cCor:= CLR_BLUE
		Else
			cCor:= CLR_RED
		EndIf
	Case (nTipo == 5)
		cCor:= CLR_BLACK
EndCase

Return(cCor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Baixas      ณ Autor ณ Luกs C. Cunha      ณ Data ณ 17.08.93 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna uma matriz com os valores pagos ou recebidos de um ณฑฑ
ฑฑณ          ณ tกtulo.                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ aMatriz := Baixas ( ... )                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ๚ cNatureza ฟ                                              ณฑฑ
ฑฑณ          ณ ๚ cPrefixo  ด                                              ณฑฑ
ฑฑณ          ณ ๚ cNumero   ลฤ ๐ Identificao do tกtulo.                  ณฑฑ
ฑฑณ          ณ ๚ cParcela  ด                                              ณฑฑ
ฑฑณ          ณ ๚ cTipo     ู                                              ณฑฑ
ฑฑณ          ณ ๚ nMoeda    Moeda em que os valores sero processados.     ณฑฑ
ฑฑณ          ณ ๚ cModo ๚   R - Receber , P - Pagar                        ณฑฑ
ฑฑณ          ณ ๚ cFornec   Codigo do Fornecedor (Se Contas a Pagar )      ณฑฑ
ฑฑณ          ณ ๚ dData     Data para conversao da moeda                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Especกfico para os relatขrios FinR340 e FinR350.           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Baixas (cNatureza,cPrefixo,cNumero,cParcela,cTipo,nMoeda,cModo,cFornec,dData,cLoja,cFilTit,dDtIni,dDtFin,lConsDtBas)

Static aMotBaixas

Local aRetorno:={0,0,0,0,0,0,0,0," ",0,0,0,0,0,0,0,0,0}
Local cArea   :=Alias()
Local nOrdem  :=0
Local nMoedaTit
Local lNaoConv
Local aMotBx := {}
Local nI := 0
Local nT := 0
Local lContrRet := !Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ;
!Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
!Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )

Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local lImpComp := SuperGetMv("MV_IMPCMP",,"2") == "1"

Local nTamTit	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1

Default cFilTit:= xFilial("SE5")
Default lConsDtBas := .T.

If aMotBaixas == NIL
	// Monto array com codigo e descricao do motivo de baixa
	aMotBx := ReadMotBx()
	aMotBaixas := {}
	For NI := 1 to Len(aMotBx)
		AADD( aMotBaixas,{substr(aMotBx[nI],01,03),substr(aMotBx[nI],07,10)})
	Next
Endif

// Quando eh chamada do Excel, estas variaveis estao em branco
IF Empty(MVABATIM) .Or.;
	Empty(MV_CRNEG) .Or.;
	Empty(MVRECANT) .Or.;
	Empty(MV_CPNEG) .Or.;
	Empty(MVPAGANT) .Or.;
	Empty(MVPROVIS)
	CriaTipos()
Endif

cFornec:=IIF( cFornec == NIL, "", cFornec )
cLoja := IIF( cLoja == NIL, "" , cLoja )
nMoeda:=IIf(nMoeda==NIL,1,nMoeda)
dData:=IIf(dData==NIL,dDataBase,dData)
dDtIni:=IIf(dDtIni==NIL,CTOD("//"),dDtIni)
dDtFin:=IIf(dDtFin==NIL,CTOD("//"),dDtFin)

dbSelectArea("SE5")
nOrdem:=IndexOrd()
dbSetOrder(7)
If MsSeek(cFilTit+cPrefixo+cNumero+cParcela+cTipo)
	
	nMoedaTit := Iif( cModo == "R", SE1-> E1_MOEDA , SE2 -> E2_MOEDA )
	
	While cFilTit+cPrefixo+cNumero+cParcela+cTipo==SE5->E5_FILIAL+;
		SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO
		
		//Nas localizacoes e usada a movimentacao bancaria em mais de uma moeda
		//por isso, quando a baixa for contra um banco, devo pegar a E5_VLMOED2,
		//pois na E5_VALOR, estara grvado o movimento na moeda do banco.
		//Bruno. Paraguay 23/08/00
		lNaoConv	:=	(nMoeda == 1 .And.(cPaisLoc=="BRA".Or.Empty(E5_BANCO)).or.( nMoeda==Val(SE5->E5_MOEDA) .And. cPaisLoc<>"BRA" .And. !Empty(E5_BANCO)) )
		Do Case
			Case SE5->E5_SITUACA = "C" .or. ;
				SE5->E5_TIPODOC = "ES"
				dbSkip()
				Loop
				// Despresa as movimentaoes diferentes do tipo solicitado somente se
				// o tipo for != de RA e PA, pois neste caso o RECPAG sera invertido.
			Case SE5->E5_RECPAG != cModo .AND. !(SE5->E5_TIPO$MVRECANT+"/"+MVPAGANT+"/"+MV_CRNEG+"/"+MV_CPNEG)
				dbSkip()
				Loop
			Case TemBxCanc()
				dbSkip()
				Loop
			Case SE5->E5_CLIFOR+SE5->E5_LOJA != cFornec + cLoja
				dbSkip( )
				Loop
			Case (SE5->E5_DATA > dDataBase .or. SE5->E5_DATA > dData) .And. lConsDtBas
				dbSkip()
				Loop
			Case !Empty(dDtIni) .and. (SE5->E5_DATA < dDtIni .Or. SE5->E5_DATA > dDtFin)
				dbSkip()
				Loop
			Case SE5->E5_TIPODOC $ "VLüBA/V2/CP"
				IF cModo == "R"
					aRetorno[5]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,SE5->E5_DATA))
					If SE5->E5_MOTBX == "CMP" .and. SUBSTR(SE5->E5_DOCUMEN,nTamTit,3) == MV_CRNEG  //NCC
						aRetorno[13]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VALOR,nMoedaTit,nMoeda,SE5->E5_DATA))
						If lImpComp
							//Retorno valores de Pis e Cofins para as compensacoes
							aRetorno[14]+= SE5->E5_VRETPIS
							aRetorno[15]+= SE5->E5_VRETCOF
							aRetorno[18]+= SE5->E5_VRETCSL
						Endif
					Endif
				Else
					aRetorno[6]+=If(SE5->E5_TIPODOC == "BA" .and. SE5->E5_TIPO == "PA " .and. SE5->E5_RECPAG == "P" .and. SE5->E5_MOTBX <> "CMP",0,Iif(lNaoConv,SE5->E5_VALOR,xMoeda(Iif(cpaisLoc=="BRA",SE5->E5_VLMOED2,SE5->E5_VALOR),Iif(!Empty(Se5->E5_MOEDA).And. cPaisLoc<>"BRA",Val(SE5->E5_MOEDA),nMoedaTit),nMoeda,SE5->E5_DATA)))
					If lContrRet .And. lPCCBaixa .And. (SE5->E5_PRETPIS $ " #3")
						aRetorno[12]+= SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL)
					Endif
				Endif
				aRetorno[10]+= SE5->E5_VALOR
				aRetorno[11]+= 1   // Numero de baixas
				
				If	SE5->(FieldPos("E5_VLACRES")) >0  .and. SE5->(FieldPos("E5_VLDECRE")) >0
					aRetorno[16] += SE5->E5_VLACRES
					aRetorno[17] += SE5->E5_VLDECRE
				Endif
				
			Case SE5->E5_TIPODOC $ "DC/D2"
				aRetorno[2]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,SE5->E5_DATA))
			Case SE5->E5_TIPODOC $ "JR/J2"
				aRetorno[3]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(Iif(cpaisLoc=="BRA",SE5->E5_VLMOED2,SE5->E5_VALOR),Iif(!Empty(Se5->E5_MOEDA).And. cPaisLoc<>"BRA",Val(SE5->E5_MOEDA),nMoedaTit),nMoeda,SE5->E5_DATA))
			Case SE5->E5_TIPODOC $ "MT/M2"
				aRetorno[4]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,SE5->E5_DATA))
			Case SE5->E5_TIPODOC $ "CM/C2/CX"
				aRetorno[1]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(Iif(cpaisLoc=="BRA",SE5->E5_VLMOED2,SE5->E5_VALOR),Iif(!Empty(Se5->E5_MOEDA) .And. cPaisLoc<>"BRA",Val(SE5->E5_MOEDA),nMoedaTit),nMoeda,SE5->E5_DATA))
			Case SE5->E5_TIPODOC $ "RA /"+MV_CRNEG
				aRetorno[7]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(SE5->E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA))
			Case SE5->E5_TIPODOC = "PA" .or. SE5->E5_TIPODOC $ MV_CPNEG
				aRetorno[8]+=Iif(lNaoConv,SE5->E5_VALOR,xMoeda(Iif(cpaisLoc=="BRA",SE5->E5_VLMOED2,SE5->E5_VALOR),Iif(!Empty(Se5->E5_MOEDA) .And. cPaisLoc<>"BRA",Val(SE5->E5_MOEDA),nMoedaTit),nMoeda,E5_DATA))
		EndCase
		If ! Empty(SE5->E5_MOTBX )
			If SE5->E5_MOTBX == "NOR"
				aRetorno[9] := OemToAnsi( "Normal" ) //
			Elseif SE5->E5_MOTBX == "DEV"
				aRetorno[9] := OemToAnsi( "Devolucao" ) //
			Elseif SE5->E5_MOTBX == "DAC"
				aRetorno[9] := OemToAnsi( "DACAO" ) //
			Elseif SE5->E5_MOTBX == "VEN"
				aRetorno[9] := OemToAnsi( "VENDOR" ) //
			Elseif SE5->E5_MOTBX == "CMP"
				aRetorno[9] := OemToAnsi( "Compensacao" ) //
			Elseif SE5->E5_MOTBX == "CEC"
				aRetorno[9] := OemToAnsi( "Comp Carteiras" ) //
			Elseif SE5->E5_MOTBX == "DEB"
				aRetorno[9] := OemToAnsi( "Dbito C/C" ) //
			Elseif SE5->E5_MOTBX == "LIQ"
				aRetorno[9] := OemToAnsi( "Liquidao" ) //
			Elseif SE5->E5_MOTBX == "FAT"
				aRetorno[9] := OemToAnsi( "Faturado" ) //
			Else
				IF (nT := ascan(aMotBaixas,{|x| x[1]= SE5->E5_MOTBX })) > 0
					aRetorno[9] := aMotBaixas [nT][2]
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
Endif

dbSetOrder(nOrdem)
dbSelectArea(cArea)
Return(aRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MudaFolder  ณ Autor ณ Alexandro Dias  ณ Data ณ  12/03/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza rodape na mudanca dos folders.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MudaFolder(nFldDest,nFldAtu,oPanel2R,aTxt,aVlr,oDlgPnl)

Local aDia		:= {}
Local aAtra 	:= {}
Local nMes 		:= 0
Local oGet		:= Nil
Local nx 		:= 0
lReceber := .F.
lPagar	 := .F.  
lRecSint := .F.
lDevSint := .F.

IF __cUserID == '000092' .Or. lAdm		//Receber
	
	IF nFldDest == nFldJuridico
		oGet 	 := oJuridico
		lReceber := .T.
	ElseIF nFldDest == nFldAtrado
		oGet 	 := oAtrasados
		lReceber := .T.
	ElseIF nFldDest == nFldRecMes
		oGet 	 := oRecMes
		lReceber := .T.
	ElseIF nFldDest == nFldRecTot
		oGet 	 := oRecTotal
		lReceber := .T.
	ElseIF nFldDest == nFldRecSint
		oGet 	 := oRecSint
		lRecSint := .T.
	ElseIF nFldDest == nFldDevSint
		oGet 	 := oDevSint
		lDevSint := .T.
	EndIF
	
EndIF

IF __cUserID == '000033' .Or. lAdm		//Pagar
	
	IF nFldDest == nFldPagDia
		oGet 	:= oPagDia
		lPagar	:= .T.
	ElseIF nFldDest == nFldPagMes
		oGet 	:= oPagMes
		lPagar	:= .T.
	ElseIF nFldDest == nFldPagTot
		oGet 	:= oPagTotal
		lPagar	:= .T.
	EndIF
	
EndIF

IF oGet == Nil
	For nX := 1 To Len(aVlr)
		aVlr[nX] := ''
		aTxt[nX] := ''
	Next
	oPanel2R:Refresh()
	Return(.T.)
Else
	For nX := 1 To Len(aVlr)
		aVlr[nX] := 0
		aTxt[nX] := ''
	Next
EndIF

IF lPagar .And. ( __cUserID == '000033' .Or. lAdm )		//Pagar
	
	nPCod := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E2_FORNECE"})
	nPVlr := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E2_VALOR"})
	nPSld := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E2_SALDO"})
	nPVto := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E2_VENCREA"})
	nPPgt := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E5_VALOR"})
	
	aTxt[1] := "Fornec. nใo Pagos: "
	aTxt[2] := "Fornec. em Dia: "
	aTxt[3] := ""
	aTxt[4] := "Valor Pago: "
	aTxt[5] := "Valor a Pagar: "
	aTxt[6] := "Pagtos Atrasados: "
	aTxt[7] := "Total a Pagar: "
	
	For nX :=1 To Len(oGet:aCols)
		IF oGet:aCols[nX,nPSld] > 0 .And. oGet:aCols[nX,nPVto] < dDataBase  		// Em Atrasados
			IF Ascan( aDia , oGet:aCols[nX,nPCod] ) == 0
				Aadd( aDia , oGet:aCols[nX,nPCod] )
			EndIF
		ElseIF oGet:aCols[nX,nPSld] == 0											// Em dia
			IF Ascan( aAtra , oGet:aCols[nX,nPCod] ) == 0
				Aadd( aAtra , oGet:aCols[nX,nPCod] )
			EndIF
		EndIF
	Next
	
	aVlr[1] := Len(aDia)
	aVlr[2] := Len(aAtra)
	AEval( oGet:aCols , { |x| aVlr[4] += x[nPPgt] } )																// Valor Pago
	AEval( oGet:aCols , { |x| aVlr[5] += IIF( ( x[nPSld] >  0 .And. x[nPVto] >= dDataBase ) , x[nPSld] , 0 ) } )	// Valor Em Dia
	AEval( oGet:aCols , { |x| aVlr[6] += IIF( ( x[nPSld] >  0 .And. x[nPVto] <  dDataBase ) , x[nPSld] , 0 ) } )	// Valor Em Atraso
	AEval( oGet:aCols , { |x| aVlr[7] += (x[nPSld]+x[nPPgt]) } )													// Total a Receber
	aVlr[1] := TransForm(aVlr[1],'@E 9999')
	aVlr[2] := TransForm(aVlr[2],'@E 9999')
	aVlr[3] := ''
	aVlr[4] := TransForm(aVlr[4],'@E 9,999,999.99')
	aVlr[5] := TransForm(aVlr[5],'@E 9,999,999.99')
	aVlr[6] := TransForm(aVlr[6],'@E 9,999,999.99')
	aVlr[7] := TransForm(aVlr[7],'@E 9,999,999.99')
	
ElseIF lReceber .And. ( __cUserID == '000092' .Or. lAdm	 )	//Receber
	
	nPCod := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_CLIENTE"})
	nPHis := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_DTHIST"})
	nPVlr := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_VALOR"})
	nPSld := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_SALDO"})
	nPVto := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_VENCREA"})
	nPPgt := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E5_VALOR"})
	
	aTxt[1] := "Clientes em Atraso: "
	aTxt[2] := "Clientes em Dia: "
	aTxt[3] := "Cobran็as M๊s  : "
	aTxt[4] := "Valor Recebido: "
	aTxt[5] := "Valor a Receber: "
	aTxt[6] := "Valor Atrasado: "
	aTxt[7] := "Total a Receber: "
	
	For nX :=1 To Len(oGet:aCols)
		IF oGet:aCols[nX,nPSld] > 0 .And. oGet:aCols[nX,nPVto] < dDataBase  		// Em Atrasados
			IF Ascan( aDia , oGet:aCols[nX,nPCod] ) == 0
				Aadd( aDia , oGet:aCols[nX,nPCod] )
			EndIF
		ElseIF oGet:aCols[nX,nPSld] == 0											// Em dia
			IF Ascan( aAtra , oGet:aCols[nX,nPCod] ) == 0
				Aadd( aAtra , oGet:aCols[nX,nPCod] )
			EndIF
		EndIF
	Next
	
	aVlr[1] := Len(aDia)
	aVlr[2] := Len(aAtra)
	AEval( oGet:aCols , { |x| aVlr[3] += IIF( ( x[nPHis] == dDataBase )	, 1 , 0 ) } )								// Historicos do Dia
	AEval( oGet:aCols , { |x| nMes 	  += IIF( ( !Empty(x[nPHis]) )		, 1 , 0 ) } )								// Historicos no Mes
	AEval( oGet:aCols , { |x| aVlr[4] += x[nPPgt] } )																// Valor Pago
	AEval( oGet:aCols , { |x| aVlr[5] += IIF( ( x[nPSld] >  0 .And. x[nPVto] >= dDataBase ) , x[nPSld] , 0 ) } )	// Valor Em Dia
	AEval( oGet:aCols , { |x| aVlr[6] += IIF( ( x[nPSld] >  0 .And. x[nPVto] <  dDataBase ) , x[nPSld] , 0 ) } )	// Valor Em Atraso
	AEval( oGet:aCols , { |x| aVlr[7] += (x[nPSld]+x[nPPgt]) } )													// Total a Receber
	aVlr[1] := TransForm(aVlr[1],'@E 9999')
	aVlr[2] := TransForm(aVlr[2],'@E 9999')
	aVlr[3] := Alltrim(TransForm(aVlr[3],'@E 9999')) + '/' + Alltrim(TransForm(nMes,'@E 9999'))
	aVlr[4] := TransForm(aVlr[4],'@E 9,999,999.99')                                                  
	aVlr[5] := TransForm(aVlr[5],'@E 9,999,999.99')
	aVlr[6] := TransForm(aVlr[6],'@E 9,999,999.99')
	aVlr[7] := TransForm(aVlr[7],'@E 9,999,999.99')
	
ElseIF lRecSint .And. ( __cUserID == '000092' .Or. lAdm	 )	//Sintetico
	
	nPCod := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_CLIENTE"})
	nPSld := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_SALDO"})
	nPPgt := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E5_VALOR"})
	nPQtd := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "QTDE"})
	
	aTxt[1] := "Titulos a Receber: "
	aTxt[2] := "Valor a Receber  : "
	aTxt[3] := "Valor Recebido   : "
	aTxt[4] := "Saldo a Receber  :"
	aTxt[5] := ""
	aTxt[6] := ""
	aTxt[7] := ""
	
	AEval( oGet:aCols , { |x| aVlr[1] += x[nPQtd] } )
	AEval( oGet:aCols , { |x| aVlr[2] += (x[nPSld]+x[nPPgt]) } )
	AEval( oGet:aCols , { |x| aVlr[3] += x[nPPgt] } )
	AEval( oGet:aCols , { |x| aVlr[4] += x[nPSld] } )

	aVlr[1] := TransForm(aVlr[1],'@E 9999')
	aVlr[2] := TransForm(aVlr[2],'@E 9,999,999.99')                                                  
	aVlr[3] := TransForm(aVlr[3],'@E 9,999,999.99')                                                  
	aVlr[4] := TransForm(aVlr[4],'@E 9,999,999.99')
	aVlr[5] := ""
	aVlr[6] := ""
	aVlr[7] := ""

ElseIF lDevSint .And. ( __cUserID == '000092' .Or. lAdm	 )	//Sintetico
	
	nPCod := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_CLIENTE"})
	nPSld := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E1_SALDO"})
	nPPgt := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "E5_VALOR"})
	nPQtd := aScan( oGet:aHeader , {|x| AllTrim(x[2]) == "QTDE"})
	
	aTxt[1] := "Titulos Atrasados: "
	aTxt[2] := "Valor Atrasado   : "
	aTxt[3] := "Valor Recebido   : "
	aTxt[4] := ""
	aTxt[5] := ""
	aTxt[6] := ""
	aTxt[7] := ""
	
	AEval( oGet:aCols , { |x| aVlr[1] += x[nPQtd] } )
	AEval( oGet:aCols , { |x| aVlr[2] += x[nPSld] } )
	AEval( oGet:aCols , { |x| aVlr[3] += x[nPPgt] } )

	aVlr[1] := TransForm(aVlr[1],'@E 9999')
	aVlr[2] := TransForm(aVlr[2],'@E 9,999,999.99')                                                  
	aVlr[3] := TransForm(aVlr[3],'@E 9,999,999.99')                                                  
	aVlr[4] := ""
	aVlr[5] := ""
	aVlr[6] := ""
	aVlr[7] := ""
EndIF

oPanel2R:Refresh()
oGet:oBrowse:Refresh()
oGet:oBrowse:nColPos := 1
oGet:oBrowse:SetFocus()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SyPosCliFor ณ Autor ณ Alexandro Dias  ณ Data ณ  12/03/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Posicao do fornecedor/Cliente.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function SyPosCliFor(oFolder)

Local aArea		:= GetArea()
Local nFldDest	:= oFolder:nOption

Default oFolder := Nil

cEntidade	:= ''
lReceber 	:= .F.
lPagar	 	:= .F.

IF oFolder == Nil
	Return(.F.)
ElseIF ( __cUserID == '000092' .Or. lAdm )		//Receber
	
	IF nFldDest == nFldJuridico
		cEntidade := oJuridico:aCols[oJuridico:oBrowse:nAt,1]	+	oJuridico:aCols[oJuridico:oBrowse:nAt,2]
		lReceber := .T.
	ElseIF nFldDest == nFldAtrado
		cEntidade := oAtrasados:aCols[oAtrasados:oBrowse:nAt,1]	+	oAtrasados:aCols[oAtrasados:oBrowse:nAt,2]
		lReceber := .T.
	ElseIF nFldDest == nFldRecMes
		cEntidade := oRecMes:aCols[oRecMes:oBrowse:nAt,1]		+	oRecMes:aCols[oRecMes:oBrowse:nAt,2]
		lReceber := .T.
	ElseIF nFldDest == nFldRecTot
		cEntidade := oRecTotal:aCols[oRecTotal:oBrowse:nAt,1]	+	oRecTotal:aCols[oRecTotal:oBrowse:nAt,2]
		lReceber := .T.
	EndIF
	
EndIF

IF !lReceber .And. ( __cUserID == '000033' .Or. lAdm )		//Pagar
	
	IF nFldDest == nFldPagDia
		cEntidade := oPagDia:aCols[oPagDia:oBrowse:nAt,1]		+ 	oPagDia:aCols[oPagDia:oBrowse:nAt,2]
		lPagar	 := .T.
	ElseIF nFldDest == nFldPagMes
		cEntidade := oPagMes:aCols[oPagMes:oBrowse:nAt,1]		+ 	oPagMes:aCols[oPagMes:oBrowse:nAt,2]
		lPagar	 := .T.
	ElseIF nFldDest == nFldPagTot
		cEntidade := oPagTotal:aCols[oPagTotal:oBrowse:nAt,1]	+	oPagTotal:aCols[oPagTotal:oBrowse:nAt,2]
		lPagar	 := .T.
	EndIF
	
EndIF

aRotina := { {"Pesquisar"	,"AxPesqui",0,1} 	,;
{"Visualizar"	,"AxVisual",0,2} 	,;
{"Incluir"		,"AxInclui",0,3} 	,;
{"Alterar"		,"AxAltera",0,4} 	,;
{"Excluir"		,"AxDeleta",0,5} }

IF lReceber
	
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial('SA1') + cEntidade ) )
	
	Pergunte("FIC010",.F.)
	
	MV_PAR01 := FirstDay(dDataBase-3000)
	MV_PAR02 := LastDay(dDataBase+3000)
	
	MV_PAR03 := FirstDay(dDataBase-3000)
	MV_PAR04 := LastDay(dDataBase+3000)
	
	MV_PAR06 := ''
	MV_PAR07 := 'ZZZ'
	
	Fc010Con()
	
ElseIF lPagar
	
	SA2->( DbSetOrder(1) )
	SA2->( DbSeek( xFilial('SA2') + cEntidade ) )
	
	FinC030("Fc030Con")
	
EndIF

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EpBxTitulo  ณ Autor ณ Alexandro Dias  ณ Data ณ  12/03/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza operacoes Gerais do Contas a Pagar/Receber.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function EpBxTitulo(oFolder,oPanel)

Local oPanelA
Local oPlnOld	:= oPanel
Local aArea		:= GetArea()
Local nFldDest	:= oFolder:nOption
Local __nRecno	:= 0
Local nPos		:= 0
Local oGet		:= Nil
Local nx 		:= 0
Private	__aIndex   	:= {}
Private	__cFiltro 	:= ''
Private	__cPerg		:= 'SYFINA0701'
Private	__nRecno	:= 0

lReceber 	:= .F.
lPagar	 	:= .F.

IF __cUserID == '000092' .Or. lAdm		//Receber
	
	IF nFldDest == nFldJuridico
		oGet 	 := oJuridico
		lReceber := .T.
	ElseIF nFldDest == nFldAtrado
		oGet 	 := oAtrasados
		lReceber := .T.
	ElseIF nFldDest == nFldRecMes
		oGet 	 := oRecMes
		lReceber := .T.
	ElseIF nFldDest == nFldRecTot
		oGet 	 := oRecTotal
		lReceber := .T.
	EndIF
	
EndIF

IF __cUserID == '000033' .Or. lAdm		//Pagar
	
	IF nFldDest == nFldPagDia
		oGet 	:= oPagDia
		lPagar	:= .T.
	ElseIF nFldDest == nFldPagMes
		oGet 	:= oPagMes
		lPagar	:= .T.
	ElseIF nFldDest == nFldPagTot
		oGet 	:= oPagTotal
		lPagar	:= .T.
	EndIF
	
EndIF

IF lReceber
	
	nAviso := Aviso("Contas a Receber","O Que Voc๊ Deseja Fazer?",{"Incluir", "Alterar" , "Baixar" , "Sair" })
	
	IF nAviso == 4
		Return(.T.)
	EndIF
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Realiza operacoes de contas a Receber.                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	__aIndex   	:= {}
	__cFiltro 	:= ''
	__cPerg		:= 'SYFINA0701'
	__nRecno	:= oGet:aCols[oGet:oBrowse:nAt,aScan(oGet:aHeader,{|x| AllTrim(x[2]) == "R_E_C_N_O_"})]
	
	U_SyPergBx(__cPerg,'SE1')
	
	IF nAviso == 1	// Incluir
		
		IF !Pergunte(__cPerg,.T.)
			Return(.T.)
		EndIF
		
	Else
		
		DbSelectArea('SE1')
		DbGoTo(__nRecno)
		
		Pergunte(__cPerg,.F.)
		MV_PAR01 := SE1->E1_CLIENTE
		MV_PAR02 := SE1->E1_CLIENTE
		MV_PAR03 := Ctod('01/01/00')	//FirstDay(dDataBase-1000)
		MV_PAR04 := Ctod('31/12/49')	//LastDay(MV_PAR03+1000)
		
	EndIF
	
	__cFiltro := " E1_FILIAL == '"+xFilial("SE1") +"' "
	__cFiltro += " .And. E1_CLIENTE >= '"+MV_PAR01		 +"' "
	__cFiltro += " .And. E1_CLIENTE	<= '"+MV_PAR02		 +"' "
	__cFiltro += " .And. Dtos(E1_VENCREA) >= '"+Dtos(MV_PAR03) +"' "
	__cFiltro += " .And. Dtos(E1_VENCREA) <= '"+Dtos(MV_PAR04) +"' "
	
ElseIF lPagar
	
	nAviso := Aviso("Contas a Pagar","O Que Voc๊ Deseja Fazer?",{"Incluir", "Alterar" , "Baixar" , "Sair" })
	
	IF nAviso == 4
		Return(.T.)
	EndIF
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Realiza operacoes de contas a Pagar.                              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	__aIndex   	:= {}
	__cFiltro 	:= ''
	__cPerg		:= 'SYFINA0801'
	__nRecno	:= oGet:aCols[oGet:oBrowse:nAt,aScan(oGet:aHeader,{|x| AllTrim(x[2]) == "R_E_C_N_O_"})]
	
	U_SyPergBx(__cPerg,'SE2')
	
	IF nAviso == 1	// Incluir
		IF !Pergunte(__cPerg,.T.)
			Return(.T.)
		EndIF
		
	Else
		DbSelectArea('SE2')
		DbGoTo(__nRecno)
		
		Pergunte(__cPerg,.F.)
		MV_PAR01 := SE2->E2_FORNECE
		MV_PAR02 := SE2->E2_FORNECE
		MV_PAR03 := Ctod('01/01/00')	//FirstDay(dDataBase-1000)
		MV_PAR04 := Ctod('31/12/49')	//LastDay(MV_PAR03+1000)
		
	EndIF
	
	__cFiltro := " E2_FILIAL == '"+xFilial("SE2") +"' "
	__cFiltro += " .And. E2_FORNECE >= '"+MV_PAR01		 +"' "
	__cFiltro += " .And. E2_FORNECE <= '"+MV_PAR02		 +"' "
	__cFiltro += " .And. Dtos(E2_VENCREA) >= '"+Dtos(MV_PAR03) +"' "
	__cFiltro += " .And. Dtos(E2_VENCREA) <= '"+Dtos(MV_PAR04) +"' "
	
EndIF

oPanelA:= TPanel():New( 0 , 0 , "" , oPanel , NIL , .F. , .F. , NIL , NIL , 0 , 0 , .F. , .T. )
oPanelA:Align:= CONTROL_ALIGN_ALLCLIENT

SyAtuRodape(lReceber,@oPanelA)

IF lReceber 
	SetFunName("FINA740")
	FinA740()
Else       
	SetFunName("FINA750")
	FinA750()
EndIF
EndFilBrw( IIF(lReceber,"SE1","SE2") , __aIndex )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza o browser conforme a baixa.      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF lPagar
	DbSelectArea('SE2')
Else
	DbSelectArea('SE1')
EndIF
DbGoTo(__nRecno)

nPos := aScan( oGet:aCols , { |x| x[ Len(oGet:aHeader) ] == __nRecno } )

For nX := 1 to Len(oGet:aHeader)
	IF FieldPos(oGet:aHeader[nX,2]) > 0
		oGet:aCols[nPos][nX] := FieldGet(FieldPos(oGet:aHeader[nX][2]))
	EndIF
Next nX

oGet:oBrowse:nAt := nPos
oGet:oBrowse:Refresh()
oGet:oBrowse:SetFocus()

oPanel := oPlnOld
oPanelA:Hide()
oPanel:Show()

RestArea(aArea)

Return(Nil)

Static Function SyAtuRodape(lReceber,oPanelA)

Local cQuery 	:= ''
Local aRodape	:= {'',0,0,0,0}

IF lReceber
	
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial('SA1') + MV_PAR01 ) )
	
	aRodape[1]  := Capital( Alltrim(SA1->A1_NOME) +'/'+ Alltrim(SA1->A1_NREDUZ) )
	
	cQuery := " SELECT E1_CLIENTE , E1_LOJA , E1_VALOR AS VALOR , E1_SALDO AS SALDO , E1_TIPO AS TIPO "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
	cQuery += " AND SE1.E1_CLIENTE 	= '" + SA1->A1_COD + "'"
	cQuery += " AND SE1.E1_LOJA 	= '" + SA1->A1_LOJA + "'"
	cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
	
Else
	
	SA2->( DbSetOrder(1) )
	SA2->( DbSeek( xFilial('SA2') + MV_PAR01 ) )
	
	aRodape[1]  := Capital( Alltrim(SA2->A2_NOME) +'/'+ Alltrim(SA2->A2_NREDUZ) )
	
	cQuery := " SELECT E2_FORNECE , E2_LOJA , E2_VALOR AS VALOR , E2_SALDO AS SALDO , E2_TIPO AS TIPO "
	cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
	cQuery += " AND SE2.E2_FORNECE 	= '" + SA2->A2_COD + "'"
	cQuery += " AND SE2.E2_LOJA 	= '" + SA2->A2_LOJA + "'"
	cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
	
EndIF

cQuery	:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBFIN",.T.,.T.)

DbSelectArea("TRBFIN")
DbGoTop()
While !Eof()
	
	IF TRBFIN->SALDO > 0	// Pendentes
		aRodape[2] += 1
		aRodape[3] += TRBFIN->SALDO
		IF TRBFIN->TIPO $ 'PA /AB-'
			aRodape[3] -= TRBFIN->SALDO
		EndIF
	ElseIF TRBFIN->SALDO == 0	// Baixados
		aRodape[4] += 1
		aRodape[5] += TRBFIN->VALOR
		IF TRBFIN->TIPO $ 'PA /AB-'
			aRodape[5] -= TRBFIN->VALOR
		EndIF
	EndIF
	
	DbSelectArea("TRBFIN")
	DbSkip()
	
EndDo
f->(dbCloseArea())

aRodape[2] 	:= Transform(aRodape[2],'@E 9999')
aRodape[3] 	:= 'R$ ' + Alltrim(Transform(aRodape[3],'@E 9,999,999.99'))
aRodape[4] 	:= Transform(aRodape[4],'@E 9999')
aRodape[5] 	:= 'R$ ' + Alltrim(Transform(aRodape[5],'@E 9,999,999.99'))

@ 001,050 SAY "CONTAS A RECEBER: "	Of oPanelA FONT oFnt2 	COLOR CLR_HRED 	Pixel SIZE 120,12
@ 001,165 SAY aRodape[1] Of oPanelA FONT oFnt2 COLOR CLR_BLACK 	Pixel SIZE 500,12

@ 015,050 SAY "Titulos Pendentes: "	Of oPanelA FONT oFnt 	COLOR CLR_BLACK Pixel SIZE 120,12
@ 015,130 SAY aRodape[2] Of oPanelA FONT oFnt  COLOR CLR_HRED 	Pixel SIZE 050,12

@ 015,170 SAY "Valor Pendente:" 	Of oPanelA FONT oFnt 	COLOR CLR_BLACK Pixel SIZE 100,12
@ 015,250 SAY aRodape[3] Of oPanelA FONT oFnt  COLOR CLR_HRED 	Pixel SIZE 100,12

@ 015,330 SAY "Titulos Pagos: 	" 	Of oPanelA FONT oFnt COLOR CLR_HBLUE Pixel SIZE 120,12
@ 015,395 SAY aRodape[4] Of oPanelA FONT oFnt COLOR CLR_HRED Pixel SIZE 050,12

@ 015,430 SAY "Valor Pago: " 		Of oPanelA FONT oFnt COLOR CLR_HBLUE Pixel SIZE 100,12
@ 015,490 SAY aRodape[5] Of oPanelA FONT oFnt COLOR CLR_HRED Pixel SIZE 100,12

oPanelA:Refresh()

Return(.T.)                                                               


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuTela  บAutor  ณMicrosiga           บ Data ณ  03/26/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os objetos da tela                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuTela(aHedRMes,aRecMes,aHedRTotal,aRecTotal,aHedRAtras,aRecAtras,aHedRJurid,aRecJurid,aHRecSint,aDRecSint,aHDevSint,aDDevSint,aHedPMes,aPagMes,aHedPTotal,aPagTotal,aHedPDia,aPagDia,nBancos,nAplicacao,aHedSE8,aDadosSE8,aHedSE5,aDadosSE5,aHeadFMes,aFatMes)


LjMsgRun( "Aguarde ... Filtrando Contas a Receber ...." 			,, {|| SyReceber(@aHedRMes,@aRecMes,@aHedRTotal,@aRecTotal,@aHedRAtras,@aRecAtras,@aHedRJurid,@aRecJurid,@aHRecSint,@aDRecSint,@aHDevSint,@aDDevSint) } )
LjMsgRun( "Aguarde ... Filtrando Contas a Pagar ...." 				,, {|| SyPagar(@aHedPMes,@aPagMes,@aHedPTotal,@aPagTotal,@aHedPDia,@aPagDia) } )
LjMsgRun( "Aguarde ... Filtrando Saldo Bancario ...." 				,, {|| SySaldo(@nBancos,@nAplicacao,@aHedSE8,@aDadosSE8) } )
LjMsgRun( "Aguarde ... Filtrando Movimenta็ใo Bancแria ...." 		,, {|| SyMovBanco(@aHedSE5,@aDadosSE5) } )
LjMsgRun( "Aguarde ... Filtrando Faturamento ...." 					,, {|| SyFaturamento(@aHedFMes,@aFatMes) } )

oJuridico:oBrowse:Refresh()
oAtrasados:oBrowse:Refresh()
oRecMes:oBrowse:Refresh()
oRecTotal:oBrowse:Refresh()
oPagMes:oBrowse:Refresh()
oPagTotal:oBrowse:Refresh()
oRecSint:oBrowse:Refresh()
oDevSint:oBrowse:Refresh()                      
oGetFatMes:oBrowse:Refresh()                      

Return
