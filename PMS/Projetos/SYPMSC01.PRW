#include "protheus.ch"

User Function SYPMSC01()
Local oTela
Local oFnt2
Local oFnt3
Local oTimer
Local oKPI01
Local oKPI02
Local oKPI03
Local oKPI04
Local oKPI05
Local oKPI06
Local oKPI07
Local oKPI08
Local oSay01
Local oSay02
Local oSay03
Local oSay04
Local oSay05
Local oSay06
Local oSay07
Local oSay08
Local oMeta01a
Local oMeta02a
Local oMeta03a
Local oMeta04a
Local oMeta05a
Local oMeta06a
Local oMeta07a
Local oMeta08a
Local oMeta01b
Local oMeta02b
Local oMeta03b
Local oMeta04b
Local oMeta05b
Local oMeta06b
Local oMeta07b
Local oMeta08b
Local oInd01a
Local oInd02a
Local oInd03a
Local oInd04a
Local oInd05a
Local oInd06a
Local oInd07a
Local oInd08a
Local oInd01b
Local oInd02b
Local oInd03b
Local oInd04b
Local oInd05b
Local oInd06b
Local oInd07b
Local oInd08b
Local oSeta01
Local oSeta02
Local oSeta03
Local oSeta04
Local oSeta05
Local oSeta06
Local oSeta07
Local oSeta08
Local oUpdate
Local oBtn00
Local oBtn01
Local oBtn02
Local oBtn03
Local oBtn04
Local aSize    := MsAdvSize()
Local cStyle   := "QFrame{ border-style:solid; border-width:1px; border-color:#CDCDCD; background-color:#FFFFFF;}"
Local cImg     := ""
Local lHtml    := .T.
Local nMeta01P := 0
Local nMeta02P := 0
Local nMeta03P := 0
Local nMeta04P := 0
Local nMeta05P := 0
Local nMeta06P := 0
Local nMeta07P := 0
Local nMeta08P := 0
Local nMeta01V := 0
Local nMeta02V := 0
Local nMeta03V := 0
Local nMeta04V := 0
Local nMeta05V := 0
Local nMeta06V := 0
Local nMeta07V := 0
Local nMeta08V := 0
Local nInd01P  := 0
Local nInd02P  := 0
Local nInd03P  := 0
Local nInd04P  := 0
Local nInd05P  := 0
Local nInd06P  := 0
Local nInd07P  := 0
Local nInd08P  := 0
Local nInd01V  := 0
Local nInd02V  := 0
Local nInd03V  := 0
Local nInd04V  := 0
Local nInd05V  := 0
Local nInd06V  := 0
Local nInd07V  := 0
Local nInd08V  := 0
Local nMeta01a := 0
Local nMeta02a := 0
Local nMeta03a := 0
Local nMeta04a := 0
Local nMeta05a := 0
Local nMeta06a := 0
Local nMeta07a := 0
Local nMeta08a := 0
Local nMeta01b := 0
Local nMeta02b := 0
Local nMeta03b := 0
Local nMeta04b := 0
Local nMeta05b := 0
Local nMeta06b := 0
Local nMeta07b := 0
Local nMeta08b := 0
Local nInd01a  := 0
Local nInd02a  := 0
Local nInd03a  := 0
Local nInd04a  := 0
Local nInd05a  := 0
Local nInd06a  := 0
Local nInd07a  := 0
Local nInd08a  := 0
Local nInd01b  := 0
Local nInd02b  := 0
Local nInd03b  := 0
Local nInd04b  := 0
Local nInd05b  := 0
Local nInd06b  := 0
Local nInd07b  := 0
Local nInd08b  := 0
Local cTitle01 := ""
Local cTitle02 := ""
Local cTitle03 := ""
Local cTitle04 := ""
Local cTitle05 := ""
Local cTitle06 := ""
Local cTitle07 := ""
Local cTitle08 := ""
Local cUpdate  := ""
Local cMeta01a := ""
Local cMeta02a := ""
Local cMeta03a := ""
Local cMeta04a := ""
Local cMeta05a := ""
Local cMeta06a := ""
Local cMeta07a := ""
Local cMeta08a := ""
Local cMeta01b := ""
Local cMeta02b := ""
Local cMeta03b := ""
Local cMeta04b := ""
Local cMeta05b := ""
Local cMeta06b := ""
Local cMeta07b := ""
Local cMeta08b := ""
Local cInd01a  := ""
Local cInd02a  := ""
Local cInd03a  := ""
Local cInd04a  := ""
Local cInd05a  := ""
Local cInd06a  := ""
Local cInd07a  := ""
Local cInd08a  := ""
Local cInd01b  := ""
Local cInd02b  := ""
Local cInd03b  := ""
Local cInd04b  := ""
Local cInd05b  := ""
Local cInd06b  := ""
Local cInd07b  := ""
Local cInd08b  := ""
Local nOS      := 0
Local nLin     := 0
Local lPMO     := .F.
Local aDados   := {}
Local cSimba   := ""
Local cSimbb   := "" 
Local cImg     := ""
Local cHint    := ""
Local cCoord   := ""
Local dDataIni 
Local dDataFim
Local aParamBox:= {}
Local aRetParam:= {}
Local bAction1  := {|| Atualiza(@nInd01P,@nInd02P,@nInd03P,@nInd04P,;
								@nInd05P,@nInd06P,@nInd07P,@nInd08P,;
								@nInd01V,@nInd02V,@nInd03V,@nInd04V,;
								@nInd05V,@nInd06V,@nInd07V,@nInd08V,;
								@nInd01a,@nInd02a,@nInd03a,@nInd04a,;
								@nInd05a,@nInd06a,@nInd07a,@nInd08a,;
								@nInd01b,@nInd02b,@nInd03b,@nInd04b,;
								@nInd05b,@nInd06b,@nInd07b,@nInd08b,;
								@oInd01a,@oInd02a,@oInd03a,@oInd04a,;
								@oInd05a,@oInd06a,@oInd07a,@oInd08a,;
								@oInd01b,@oInd02b,@oInd03b,@oInd04b,;
								@oInd05b,@oInd06b,@oInd07b,@oInd08b,;
								@nMeta01P,@nMeta02P,@nMeta03P,@nMeta04P,;
								@nMeta05P,@nMeta06P,@nMeta07P,@nMeta08P,;
								@nMeta01V,@nMeta02V,@nMeta03V,@nMeta04V,;
								@nMeta05V,@nMeta06V,@nMeta07V,@nMeta08V,;
								@nMeta01a,@nMeta02a,@nMeta03a,@nMeta04a,;
								@nMeta05a,@nMeta06a,@nMeta07a,@nMeta08a,;
								@nMeta01b,@nMeta02b,@nMeta03b,@nMeta04b,;
								@nMeta05b,@nMeta06b,@nMeta07b,@nMeta08b,;
								@oMeta01a,@oMeta02a,@oMeta03a,@oMeta04a,;
								@oMeta05a,@oMeta06a,@oMeta07a,@oMeta08a,;
								@oMeta01b,@oMeta02b,@oMeta03b,@oMeta04b,;
								@oMeta05b,@oMeta06b,@oMeta07b,@oMeta08b,;
								@oSeta01,@oSeta02,@oSeta03,@oSeta04,;
								@oSeta05,@oSeta06,@oSeta07,@oSeta08,;
								@oTela,@oTimer,@oUpdate,cCoord,@aDados,dDataIni,dDataFim) }

Private cTipo    := GetMv("MV_SYDASH",,"P") //Visualização P-percentual ou V-valor
Private oFWLayer := FWLayer():New()

//Verifica se é coordenador ou PMO
DbSelectArea("AE8")
DbSetOrder(3)
IF DbSeek(xFilial("AE8")+__cUserID)

	IF AE8->AE8_EQUIPE == "4" 			//Coordenacao
		cCoord  := AE8->AE8_RECURS
		dDataIni:= FirstDay(dDatabase)
		dDataFim:= LastDay(dDatabase)
	ElseIF AE8->AE8_EQUIPE == "7" .Or. AE8->AE8_EQUIPE == "6" //PMO  DIRETORIA
/*		Aadd(aParamBox,{1,"Coordenador" , Space(100)  , ""   , "", "SYCOOR", "", 50 , .F.})
		Aadd(aParamBox,{1,"Data Inicial", FirstDay(dDatabase), PesqPict("SE1", "E1_VENCREA") , "", "", "", 50 , .F.})
		Aadd(aParamBox,{1,"Data Final"  , LastDay(dDatabase) , PesqPict("SE1", "E1_VENCREA") , "", "", "", 50 , .F.})
		IF !ParamBox(aParamBox,"Informe os Dados para Filtro",@aRetParam)
			Return
		Endif

		cCoord  := aRetParam[1]
		dDataIni:= FirstDay(aRetParam[2])
		dDataFim:= LastDay(aRetParam[3])

*/	
		cCoord  := Space(TamSX3("AE8_COORD")[1])
		dDataIni:= FirstDay(dDatabase)
		dDataFim:= LastDay(dDatabase)

		lPmo:= .T.
	Else    
		U_SYPMSA01()   
		FINAL()
		Return(.F.)
    EndIF
Else
/*
	Aadd(aParamBox,{1,"Coordenador" , Space(100)  , ""   , "", "SYCOOR", "", 50 , .F.})
	Aadd(aParamBox,{1,"Data Inicial", FirstDay(dDatabase), PesqPict("SE1", "E1_VENCREA") , "", "", "", 50 , .F.})
	Aadd(aParamBox,{1,"Data Final"  , LastDay(dDatabase) , PesqPict("SE1", "E1_VENCREA") , "", "", "", 50 , .F.})
	IF !ParamBox(aParamBox,"Informe os Dados para Filtro",@aRetParam)
		Return
	Endif

	cCoord  := aRetParam[1]
	dDataIni:= FirstDay(aRetParam[2])
	dDataFim:= LastDay(aRetParam[3])
*/
	cCoord  := Space(TamSX3("AE8_COORD")[1])
	dDataIni:= FirstDay(dDatabase)
	dDataFim:= LastDay(dDatabase)
	
EndIF

//Chama a montagem dos dados
LjMsgRun("Montando Dashboard de Projetos...",,{|| KPIDADOS(cCoord,@aDados,dDataIni,dDataFim) })

//Chama a atualização do KPI01
KPI01(aDados,@nMeta01P,@nInd01P,@nMeta01V,@nInd01V,.F.)

//Chama a atualização do KPI02
KPI02(aDados,@nMeta02P,@nInd02P,@nMeta02V,@nInd02V,.F.)
		
//Chama a atualização do KPI03
KPI03(aDados,@nMeta03P,@nInd03P,@nMeta03V,@nInd03V,.F.)
				 
//Chama a atualização do KPI04
KPI04(aDados,@nMeta04P,@nInd04P,@nMeta04V,@nInd04V,.F.)

//Chama a atualização do KPI05
KPI05(aDados,@nMeta05P,@nInd05P,@nMeta05V,@nInd05V,.F.)

//Chama a atualização do KPI06
KPI06(aDados,@nMeta06P,@nInd06P,@nMeta06V,@nInd06V,.F.)

//Chama a atualização do KPI07
KPI07(aDados,@nMeta07P,@nInd07P,@nMeta07V,@nInd07V,.F.)

//Chama a atualização do KPI08
KPI08(aDados,@nMeta08P,@nInd08P,@nMeta08V,@nInd08V,.F.)

//Montagem da Tela
DEFINE FONT oFnt NAME "ARIAL" SIZE 0,-12 BOLD
DEFINE FONT oFnt2 NAME "ARIAL" SIZE 0,-32 BOLD
DEFINE FONT oFnt3 NAME "ARIAL" SIZE 0,-6 BOLD
DEFINE MSDIALOG oTela FROM 0,0 TO aSize[6],aSize[5] TITLE "Dashboard de Projetos" Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS


	oFWLayer:Init(oTela,.T.)

	oFWLayer:AddCollumn('Col1',90,.F.)
	oFWLayer:AddWindow('Col1','Win1',"",100,.F.,.T.)

	oFWLayer:AddCollumn('Col2',10,.F.)
	oFWLayer:AddWindow('Col2','Win2',"",100,.F.,.T.)

	oPanel1 := oFWLayer:GetWinPanel('Col1','Win1')
	oPanel1	:FreeChildren()
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanel2 := oFWLayer:GetWinPanel('Col2','Win2')
	oPanel2	:FreeChildren()
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT


	/*******************Botoes laterais**************/
	//Acesso para a escolha da visualização em numeros relativos ou absolutos
	If (cTipo == "P")
		cImg:= "ABSOLUTO.PNG"
	Else
		cImg:= "RELATIVO.PNG"
	EndIf	

	nLin:= 040
	cHint:= "Visualiza os valores em números relativos ou absolutos"
	oBtn01 := TBtnBmp2():New( nLin, 05, 100, 30,cImg,,,,{||AbsRelativo(@oBtn00,bAction1)},oPanel2,cHint,,.T. )

	//Acesso para a rotina de Painel de Projetos
	nLin+= 35
	cHint:= "Acessa o Painel de Projetos"
	oBtn02 := TBtnBmp2():New( nLin, 05, 100, 30,"PROJETOS.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSC00(),oTimer:Activate())},oPanel2,cHint,,.T. )

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
	oBtn03 := TBtnBmp2():New( nLin, 05, 100, 30,cImg,,,,{||(oTimer:DeActivate(),U_SYPMSA02(),AtuBtn(@oBtn02,aDados),oTimer:Activate())},oPanel2,cHint,,.T. )

	//Acesso a agenda dos consultores
	nLin+= 35
	cHint:= "Acessa a Agenda de Consultores"
	oBtn04 := TBtnBmp2():New( nLin, 05, 100, 30,"AGENDAALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA23(),oTimer:Activate())},oPanel2,cHint,,.T. )

	//Acesso a ordem de serviço
	nLin+= 35
	cHint:= "Acessa a Ordem de Serviço"
	oBtn05 := TBtnBmp2():New( nLin, 05, 100, 30,"OSALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA01(),oTimer:Activate())},oPanel2,cHint,,.T. )

	//Acesso a proposta
	nLin+= 35
	cHint:= "Acessa a Proposta"
	oBtn06 := TBtnBmp2():New( nLin, 05, 100, 30,"PROPOSTA.PNG",,,,{||(oTimer:DeActivate(),U_SHOWGRFVDA(),oTimer:Activate())},oPanel2,cHint,,.T. )

	//Acesso a proposta
	nLin+= 35
	cHint:= "Acessa a Manutencao de OS x Projeto"
	oBtn07 := TBtnBmp2():New( nLin, 05, 100, 30,"TROCA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSA31(),oTimer:Activate())},oPanel2,cHint,,.T. )

	nLin+= 35
	cHint:= "Acessa o KPI"
	oBtn08 := TBtnBmp2():New( nLin, 05, 100, 30,"KPIALFA.PNG",,,,{||(oTimer:DeActivate(),U_SyKPISrv(),oTimer:Activate())},oPanel2,cHint,,.T. )
	
	//Acesso ao KPI
	If lPMO

		nLin+= 35
		cHint:= "Acessa o Cadastro de Recursos"
		oBtn09 := TBtnBmp2():New( nLin, 05, 100, 30,"RECALFA.PNG",,,,{||(oTimer:DeActivate(),PMSA050(),oTimer:Activate())},oPanel2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa o Relatorio de Pagto."
		oBtn10 := TBtnBmp2():New( nLin, 05, 100, 30,"PGTOALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYPMSR06(),oTimer:Activate())},oPanel2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa as Metas."
		oBtn11 := TBtnBmp2():New( nLin, 05, 100, 30,"METAALFA.PNG",,,,{||(oTimer:DeActivate(),U_SYMMSZF(),oTimer:Activate())},oPanel2,cHint,,.T. )

		nLin+= 35
		cHint:= "Acessa o Cadastro de Calendario."
		oBtn13 := TBtnBmp2():New( nLin, 05, 100, 30,"CALENDARIO.PNG",,,,{||(oTimer:DeActivate(),MATA780(),oTimer:Activate())},oPanel2,cHint,,.T. )

	EndIf

	nLin+= 35
	cHint:= "Acessa o Cadastro de Projetos."
	oBtn12 := TBtnBmp2():New( nLin, 05, 100, 30,"NEWPROJ.PNG",,,,{||(oTimer:DeActivate(),PMSA410(),oTimer:Activate())},oPanel2,cHint,,.T. )

	
	//****************KPI01 - HORAS APONTADAS  ******************
	cTitle01:= '<font size="3" color="#FFD700">Horas Apontadas</font>'
	oSay01:= TSay():New( 023, 010,{|| cTitle01}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI01:= TPanelCSS():New(030,10,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI01:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta01a:= nMeta01P
    	nMeta01b:= nMeta01V
    	nInd01a := nInd01P
    	nInd01b := nInd01V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta01a:= nMeta01V
    	nMeta01b:= nMeta01P
    	nInd01a := nInd01V
    	nInd01b := nInd01P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	
	
	cMeta01a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta01a) +  cSimba + '</font>'
	cMeta01b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta01b) +  cSimbb + '</font>'
	oMeta01a:= TSay():New( 095, 90,{|| cMeta01a}, oKPI01,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta01b:= TSay():New( 110, 95,{|| cMeta01b}, oKPI01,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd01a >= nMeta01a)
		cInd01a:= '<font size="30" color="#228B22">' + cValToChar(nInd01a) +  cSimba + '</font>'
		cInd01b:= '<font size="6" color="#228B22">' + cValToChar(nInd01b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd01a:= '<font size="30" color="#FA8072">' + cValToChar(nInd01a) +  cSimba + '</font>'
		cInd01b:= '<font size="6" color="#FA8072">' + cValToChar(nInd01b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd01a:= TSay():New( 030, 030,{|| cInd01a}, oKPI01,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd01b:= TSay():New( 070, 060,{|| cInd01b}, oKPI01,,oFnt,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta01 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(1,aDados,cMeta01a,cInd01a)},oKPI01,,,.T. )

	//****************KPI02 - OS Encerradas  ******************
	cTitle02:= '<font size="3" color="#FFD700">OS Encerradas</font>'
	oSay02:= TSay():New( 023, 145,{|| cTitle02}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI02:= TPanelCSS():New(030,145,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI02:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta02a:= nMeta02P
    	nMeta02b:= nMeta02V
    	nInd02a := nInd02P
    	nInd02b := nInd02V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta02a:= nMeta02V
    	nMeta02b:= nMeta02P
    	nInd02a := nInd02V
    	nInd02b := nInd02P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta02a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta02a) +  cSimba + '</font>'
	cMeta02b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta02b) +  cSimbb + '</font>'
	oMeta02a:= TSay():New( 095, 90,{|| cMeta02a}, oKPI02,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta02b:= TSay():New( 110, 95,{|| cMeta02b}, oKPI02,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd02a >= nMeta02a)
		cInd02a:= '<font size="30" color="#228B22">' + cValToChar(nInd02a) +  cSimba + '</font>'
		cInd02b:= '<font size="6" color="#228B22">' + cValToChar(nInd02b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd02a:= '<font size="30" color="#FA8072">' + cValToChar(nInd02a) +  cSimba + '</font>'
		cInd02b:= '<font size="6" color="#FA8072">' + cValToChar(nInd02b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd02a:= TSay():New( 030, 030,{|| cInd02a}, oKPI02,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd02b:= TSay():New( 070, 060,{|| cInd02b}, oKPI02,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta02 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(2,aDados,cMeta02a,cInd02a)},oKPI02,,,.T. )

	//****************KPI03 - Recursos Alocados  ******************
	cTitle03:= '<font size="3" color="#FFD700">Recursos Alocados</font>'
	oSay03:= TSay():New( 023, 285,{|| cTitle03}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI03:= TPanelCSS():New(030,285,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI03:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta03a:= nMeta03P
    	nMeta03b:= nMeta03V
    	nInd03a := nInd03P
    	nInd03b := nInd03V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta03a:= nMeta03V
    	nMeta03b:= nMeta03P
    	nInd03a := nInd03V
    	nInd03b := nInd03P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta03a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta03a) +  cSimba + '</font>'
	cMeta03b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta03b) +  cSimbb + '</font>'
	oMeta03a:= TSay():New( 095, 90,{|| cMeta03a}, oKPI03,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta03b:= TSay():New( 110, 95,{|| cMeta03b}, oKPI03,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd03a >= nMeta03a)
		cInd03a:= '<font size="30" color="#228B22">' + cValToChar(nInd03a) +  cSimba + '</font>'
		cInd03b:= '<font size="6" color="#228B22">' + cValToChar(nInd03b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd03a:= '<font size="30" color="#FA8072">' + cValToChar(nInd03a) +  cSimba + '</font>'
		cInd03b:= '<font size="6" color="#FA8072">' + cValToChar(nInd03b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd03a:= TSay():New( 030, 030,{|| cInd03a}, oKPI03,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd03b:= TSay():New( 070, 060,{|| cInd03b}, oKPI03,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta03 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(3,aDados,cMeta03a,cInd03a)},oKPI03,,,.T. )

	//****************KPI04 - Horas Faturáveis  ******************
	cTitle04:= '<font size="3" color="#FFD700">Horas Faturáveis</font>'
	oSay04:= TSay():New( 023, 425,{|| cTitle04}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI04:= TPanelCSS():New(030,425,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI04:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta04a:= nMeta04P
    	nMeta04b:= nMeta04V
    	nInd04a := nInd04P
    	nInd04b := nInd04V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta04a:= nMeta04V
    	nMeta04b:= nMeta04P
    	nInd04a := nInd04V
    	nInd04b := nInd04P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta04a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta04a) +  cSimba + '</font>'
	cMeta04b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta04b) +  cSimbb + '</font>'
	oMeta04a:= TSay():New( 095, 90,{|| cMeta04a}, oKPI04,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta04b:= TSay():New( 110, 95,{|| cMeta04b}, oKPI04,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd04a >= nMeta04a)
		cInd04a:= '<font size="30" color="#228B22">' + cValToChar(nInd04a) +  cSimba + '</font>'
		cInd04b:= '<font size="6" color="#228B22">' + cValToChar(nInd04b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd04a:= '<font size="30" color="#FA8072">' + cValToChar(nInd04a) +  cSimba + '</font>'
		cInd04b:= '<font size="6" color="#FA8072">' + cValToChar(nInd04b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd04a:= TSay():New( 030, 030,{|| cInd04a}, oKPI04,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd04b:= TSay():New( 070, 060,{|| cInd04b}, oKPI04,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)

	oSeta04 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(4,aDados,cMeta04a,cInd04a)},oKPI04,,,.T. )

	//****************KPI05 - Horas Nâo Faturáveis  ******************
	cTitle05:= '<font size="3" color="#FFD700">Horas Não Faturáveis</font>'
	oSay05:= TSay():New( 153, 010,{|| cTitle05}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI05:= TPanelCSS():New(160,10,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI05:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta05a:= nMeta05P
    	nMeta05b:= nMeta05V
    	nInd05a := nInd05P
    	nInd05b := nInd05V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta05a:= nMeta05V
    	nMeta05b:= nMeta05P
    	nInd05a := nInd05V
    	nInd05b := nInd05P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta05a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta05a) +  cSimba + '</font>'
	cMeta05b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta05b) +  cSimbb + '</font>'
	oMeta05a:= TSay():New( 095, 90,{|| cMeta05a}, oKPI05,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta05b:= TSay():New( 110, 95,{|| cMeta05b}, oKPI05,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	//**********Neste KPI a analise é inversa. Quanto menor o percentual de horas NÃO FATURÀVEIS melhor é*****
	If (nInd05a <= nMeta05a)
		cInd05a:= '<font size="30" color="#228B22">' + cValToChar(nInd05a) +  cSimba + '</font>'
		cInd05b:= '<font size="6" color="#228B22">' + cValToChar(nInd05b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd05a:= '<font size="30" color="#FA8072">' + cValToChar(nInd05a) +  cSimba + '</font>'
		cInd05b:= '<font size="6" color="#FA8072">' + cValToChar(nInd05b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd05a:= TSay():New( 030, 030,{|| cInd05a}, oKPI05,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd05b:= TSay():New( 070, 060,{|| cInd05b}, oKPI05,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta05 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(5,aDados,cMeta05a,cInd05a)},oKPI05,,,.T. )

	//****************KPI06 - Entrada no Horário  ******************
	cTitle06:= '<font size="3" color="#FFD700">Entrada no Horário</font>'
	oSay06:= TSay():New( 153, 145,{|| cTitle06}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI06:= TPanelCSS():New(160,145,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI06:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta06a:= nMeta06P
    	nMeta06b:= nMeta06V
    	nInd06a := nInd06P
    	nInd06b := nInd06V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta06a:= nMeta06V
    	nMeta06b:= nMeta06P
    	nInd06a := nInd06V
    	nInd06b := nInd06P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta06a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta06a) +  cSimba + '</font>'
	cMeta06b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta06b) +  cSimbb + '</font>'
	oMeta06a:= TSay():New( 095, 90,{|| cMeta06a}, oKPI06,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta06b:= TSay():New( 110, 95,{|| cMeta06b}, oKPI06,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd06a <= nMeta06a)
		cInd06a:= '<font size="30" color="#228B22">' + cValToChar(nInd06a) +  cSimba + '</font>'
		cInd06b:= '<font size="6" color="#228B22">' + cValToChar(nInd06b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd06a:= '<font size="30" color="#FA8072">' + cValToChar(nInd06a) +  cSimba + '</font>'
		cInd06b:= '<font size="6" color="#FA8072">' + cValToChar(nInd06b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd06a:= TSay():New( 030, 030,{|| cInd06a}, oKPI06,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd06b:= TSay():New( 070, 060,{|| cInd06b}, oKPI06,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta06 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(6,aDados,cMeta06a,cInd06a)},oKPI06,,,.T. )

	//****************KPI07 - Saída no Horário  ******************
	cTitle07:= '<font size="3" color="#FFD700">Saída no Horário</font>'
	oSay07:= TSay():New( 153, 285,{|| cTitle07}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI07:= TPanelCSS():New(160,285,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI07:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta07a:= nMeta07P
    	nMeta07b:= nMeta07V
    	nInd07a := nInd07P
    	nInd07b := nInd07V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta07a:= nMeta07V
    	nMeta07b:= nMeta07P
    	nInd07a := nInd07V
    	nInd07b := nInd07P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta07a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta07a) +  cSimba + '</font>'
	cMeta07b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta07b) +  cSimbb + '</font>'
	oMeta07a:= TSay():New( 095, 90,{|| cMeta07a}, oKPI07,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta07b:= TSay():New( 110, 95,{|| cMeta07b}, oKPI07,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd07a <= nMeta07a)
		cInd07a:= '<font size="30" color="#228B22">' + cValToChar(nInd07a) +  cSimba + '</font>'
		cInd07b:= '<font size="6" color="#228B22">' + cValToChar(nInd07b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd07a:= '<font size="30" color="#FA8072">' + cValToChar(nInd07a) +  cSimba + '</font>'
		cInd07b:= '<font size="6" color="#FA8072">' + cValToChar(nInd07b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd07a:= TSay():New( 030, 030,{|| cInd07a}, oKPI07,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd07b:= TSay():New( 070, 060,{|| cInd07b}, oKPI07,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta07 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(7,aDados,cMeta07a,cInd07a)},oKPI07,,,.T. )

	//****************KPI08 - VENDAS NO MES  ******************
	cTitle08:= '<font size="3" color="#FFD700">Vendas no Mês</font>'
	oSay08:= TSay():New( 153, 425,{|| cTitle08}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	oKPI08:= TPanelCSS():New(160,425,nil,oPanel1,nil,nil,nil,nil,nil,125,120,nil,nil)
    oKPI08:setCSS(cStyle)

    If (cTipo == "P")
    	nMeta08a:= nMeta08P
    	nMeta08b:= nMeta08V
    	nInd08a := nInd08P
    	nInd08b := nInd08V
    	cSimba  := "%"
    	cSimbb  := ""
	Else
    	nMeta08a:= nMeta08V
    	nMeta08b:= nMeta08P
    	nInd08a := nInd08V
    	nInd08b := nInd08P
    	cSimba  := ""
    	cSimbb  := "%"
	EndIf	

	cMeta08a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta08a) +  cSimba + '</font>'
	cMeta08b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta08b) +  cSimbb + '</font>'
	oMeta08a:= TSay():New( 095, 90,{|| cMeta08a}, oKPI08,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)
	oMeta08b:= TSay():New( 110, 95,{|| cMeta08b}, oKPI08,,oFnt,,,,.T.,,,50,50,,,,,,lHtml)

	If (nInd08a >= nMeta08a)
		cInd08a:= '<font size="30" color="#228B22">' + cValToChar(nInd08a) +  cSimba + '</font>'
		cInd08b:= '<font size="6" color="#228B22">' + cValToChar(nInd08b)  +  cSimbb + '</font>'
		cImg:= "SETAVERDE.PNG"
	Else
		cInd08a:= '<font size="30" color="#FA8072">' + cValToChar(nInd08a) +  cSimba + '</font>'
		cInd08b:= '<font size="6" color="#FA8072">' + cValToChar(nInd08b)  +  cSimbb + '</font>'
		cImg:= "SETAVERMELHA.PNG"
	EndIf

	oInd08a:= TSay():New( 030, 030,{|| cInd08a}, oKPI08,,oFnt2,,,,.T.,,,200,200,,,,,,lHtml)
	oInd08b:= TSay():New( 070, 060,{|| cInd08b}, oKPI08,,oFnt ,,,,.T.,,,200,200,,,,,,lHtml)
	oSeta08 := TBtnBmp2():New( 100, 010, 40, 40,cImg,,,,{||Detalhe(8,aDados,cMeta08a,cInd08a)},oKPI08,,,.T. )

	cUpdate:= '<font size="4" color="#FFD700">Última Atualização em ' + Dtoc(U_SyDate()) + ' - ' + Time() + '</font>'
	oUpdate:= TSay():New( 315, 475,{|| cUpdate}, oPanel1,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

	DEFINE TIMER oTimer INTERVAL 60000 ACTION (Eval(bAction1),oTimer:Activate() ) OF oTela
	oTimer:Activate()

ACTIVATE MSDIALOG oTela ON INIT ( EnchoiceBar(	oTela,;
												{|| oTela:End()  },;
												{|| oTela:End() }) ) CENTERED

Return

/*
Chama rotina para atualizar numeros na tela
*/
Static Function Atualiza(nInd01P,nInd02P,nInd03P,nInd04P,;
						 nInd05P,nInd06P,nInd07P,nInd08P,;
						 nInd01V,nInd02V,nInd03V,nInd04V,;
						 nInd05V,nInd06V,nInd07V,nInd08V,;
						 nInd01a,nInd02a,nInd03a,nInd04a,;
						 nInd05a,nInd06a,nInd07a,nInd08a,;
						 nInd01b,nInd02b,nInd03b,nInd04b,;
						 nInd05b,nInd06b,nInd07b,nInd08b,;
						 oInd01a,oInd02a,oInd03a,oInd04a,;
						 oInd05a,oInd06a,oInd07a,oInd08a,;
						 oInd01b,oInd02b,oInd03b,oInd04b,;
						 oInd05b,oInd06b,oInd07b,oInd08b,;
						 nMeta01P,nMeta02P,nMeta03P,nMeta04P,;
						 nMeta05P,nMeta06P,nMeta07P,nMeta08P,;
						 nMeta01V,nMeta02V,nMeta03V,nMeta04V,;
						 nMeta05V,nMeta06V,nMeta07V,nMeta08V,;
						 nMeta01a,nMeta02a,nMeta03a,nMeta04a,;
						 nMeta05a,nMeta06a,nMeta07a,nMeta08a,;
						 nMeta01b,nMeta02b,nMeta03b,nMeta04b,;
						 nMeta05b,nMeta06b,nMeta07b,nMeta08b,;
						 oMeta01a,oMeta02a,oMeta03a,oMeta04a,;
						 oMeta05a,oMeta06a,oMeta07a,oMeta08a,;
						 oMeta01b,oMeta02b,oMeta03b,oMeta04b,;
						 oMeta05b,oMeta06b,oMeta07b,oMeta08b,;
						 oSeta01,oSeta02,oSeta03,oSeta04,;
						 oSeta05,oSeta06,oSeta07,oSeta08,;
						 oTela,oTimer,oUpdate,cCoord,aDados,dDataIni,dDataFim)
Local cInd01:= ""
Local cInd02:= ""
Local cInd03:= ""
Local cInd04:= ""
Local cInd05:= ""
Local cInd06:= ""
Local cInd07:= ""
Local cInd08:= ""
Local cImg  := ""
Local cSimba:= ""
Local cSimbb:= ""

oTimer:DeActivate()		

//Chama a atualização do KPI02
KPIDADOS(cCoord,@aDados,dDataIni,dDataFim)

//Chama a atualização do KPI01
KPI01(aDados,@nMeta01P,@nInd01P,@nMeta01V,@nInd01V,.F.)

//Chama a atualização do KPI02
KPI02(aDados,@nMeta02P,@nInd02P,@nMeta02V,@nInd02V,.F.)
		
//Chama a atualização do KPI03
KPI03(aDados,@nMeta03P,@nInd03P,@nMeta03V,@nInd03V,.F.)
				 
//Chama a atualização do KPI04
KPI04(aDados,@nMeta04P,@nInd04P,@nMeta04V,@nInd04V,.F.)

//Chama a atualização do KPI05
KPI05(aDados,@nMeta05P,@nInd05P,@nMeta05V,@nInd05V,.F.)

//Chama a atualização do KPI06
KPI06(aDados,@nMeta06P,@nInd06P,@nMeta06V,@nInd06V,.F.)

//Chama a atualização do KPI07
KPI07(aDados,@nMeta07P,@nInd07P,@nMeta07V,@nInd07V,.F.)

//Chama a atualização do KPI08
KPI08(aDados,@nMeta08P,@nInd08P,@nMeta08V,@nInd08V,.F.)


/********** Atualiza o KPI01 *************/
If (cTipo == "P")
	nMeta01a:= nMeta01P
	nMeta01b:= nMeta01V
	nInd01a := nInd01P
	nInd01b := nInd01V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta01a:= nMeta01V
	nMeta01b:= nMeta01P
	nInd01a := nInd01V
	nInd01b := nInd01P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta01a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta01a) + cSimba + '</font>'
cMeta01b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta01b) + cSimbb + '</font>'
If (nInd01a >= nMeta01a)
	cInd01a:= '<font size="30" color="#228B22">' + cValToChar(nInd01a) + cSimba + '</font>'
	cInd01b:= '<font size="6" color="#228B22">' + cValToChar(nInd01b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd01a:= '<font size="30" color="#FA8072">' + cValToChar(nInd01a) + cSimba + '</font>'
	cInd01b:= '<font size="6" color="#FA8072">' + cValToChar(nInd01b)  + cSimbb +  '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta01a:SetText(cMeta01a)
oMeta01b:SetText(cMeta01b)
oMeta01a:Refresh()
oMeta01b:Refresh()
 
oInd01a:SetText(cInd01a) 
oInd01b:SetText(cInd01b) 
oInd01a:Refresh()
oInd01b:Refresh()

oSeta01:LoadBitmaps(cImg) 
oSeta01:Refresh()

/********** Atualiza o KPI02 *************/
If (cTipo == "P")
	nMeta02a:= nMeta02P
	nMeta02b:= nMeta02V
	nInd02a := nInd02P
	nInd02b := nInd02V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta02a:= nMeta02V
	nMeta02b:= nMeta02P
	nInd02a := nInd02V
	nInd02b := nInd02P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta02a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta02a) + cSimba + '</font>'
cMeta02b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta02b) + cSimbb + '</font>'
If (nInd02a >= nMeta02a)
	cInd02a:= '<font size="30" color="#228B22">' + cValToChar(nInd02a) + cSimba + '</font>'
	cInd02b:= '<font size="6" color="#228B22">' + cValToChar(nInd02b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd02a:= '<font size="30" color="#FA8072">' + cValToChar(nInd02a) + cSimba + '</font>'
	cInd02b:= '<font size="6" color="#FA8072">' + cValToChar(nInd02b)  + cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta02a:SetText(cMeta02a)
oMeta02b:SetText(cMeta02b)
oMeta02a:Refresh()
oMeta02b:Refresh()
 
oInd02a:SetText(cInd02a) 
oInd02b:SetText(cInd02b) 
oInd02a:Refresh()
oInd02b:Refresh()

oSeta02:LoadBitmaps(cImg) 
oSeta02:Refresh()

/********** Atualiza o KPI03 *************/
If (cTipo == "P")
	nMeta03a:= nMeta03P
	nMeta03b:= nMeta03V
	nInd03a := nInd03P
	nInd03b := nInd03V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta03a:= nMeta03V
	nMeta03b:= nMeta03P
	nInd03a := nInd03V
	nInd03b := nInd03P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta03a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta03a) + cSimba + '</font>'
cMeta03b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta03b) + cSimbb + '</font>'
If (nInd03a >= nMeta03a)
	cInd03a:= '<font size="30" color="#228B22">' + cValToChar(nInd03a) + cSimba + '</font>'
	cInd03b:= '<font size="6" color="#228B22">' + cValToChar(nInd03b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd03a:= '<font size="30" color="#FA8072">' + cValToChar(nInd03a) + cSimba + '</font>'
	cInd03b:= '<font size="6" color="#FA8072">' + cValToChar(nInd03b)  + cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta03a:SetText(cMeta03a)
oMeta03b:SetText(cMeta03b)
oMeta03a:Refresh()
oMeta03b:Refresh()
 
oInd03a:SetText(cInd03a) 
oInd03b:SetText(cInd03b) 
oInd03a:Refresh()
oInd03b:Refresh()

oSeta03:LoadBitmaps(cImg) 
oSeta03:Refresh()

/********** Atualiza o KPI04 *************/
If (cTipo == "P")
	nMeta04a:= nMeta04P
	nMeta04b:= nMeta04V
	nInd04a := nInd04P
	nInd04b := nInd04V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta04a:= nMeta04V
	nMeta04b:= nMeta04P
	nInd04a := nInd04V
	nInd04b := nInd04P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta04a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta04a) + cSimba + '</font>'
cMeta04b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta04b) + cSimbb + '</font>'
If (nInd04a >= nMeta04a)
	cInd04a:= '<font size="30" color="#228B22">' + cValToChar(nInd04a) + cSimba + '</font>'
	cInd04b:= '<font size="6" color="#228B22">' + cValToChar(nInd04b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd04a:= '<font size="30" color="#FA8072">' + cValToChar(nInd04a) + cSimba + '</font>'
	cInd04b:= '<font size="6" color="#FA8072">' + cValToChar(nInd04b)  + cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta04a:SetText(cMeta04a)
oMeta04b:SetText(cMeta04b)
oMeta04a:Refresh()
oMeta04b:Refresh()
 
oInd04a:SetText(cInd04a) 
oInd04b:SetText(cInd04b) 
oInd04a:Refresh()
oInd04b:Refresh()

oSeta04:LoadBitmaps(cImg) 
oSeta04:Refresh()

/********** Atualiza o KPI05 *************/
/**********Neste KPI a analise é inversa. Quanto menor o percentual de horas NÃO FATURÀVEIS melhor é*****/
If (cTipo == "P")
	nMeta05a:= nMeta05P
	nMeta05b:= nMeta05V
	nInd05a := nInd05P
	nInd05b := nInd05V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta05a:= nMeta05V
	nMeta05b:= nMeta05P
	nInd05a := nInd05V
	nInd05b := nInd05P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta05a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta05a) + cSimba + '</font>'
cMeta05b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta05b) + cSimbb + '</font>'
If (nInd05a <= nMeta05a) 
	cInd05a:= '<font size="30" color="#228B22">' + cValToChar(nInd05a) + cSimba + '</font>'
	cInd05b:= '<font size="6" color="#228B22">' + cValToChar(nInd05b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd05a:= '<font size="30" color="#FA8072">' + cValToChar(nInd05a) + cSimba + '</font>'
	cInd05b:= '<font size="6" color="#FA8072">' + cValToChar(nInd05b)  + cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta05a:SetText(cMeta05a)
oMeta05b:SetText(cMeta05b)
oMeta05a:Refresh()
oMeta05b:Refresh()
 
oInd05a:SetText(cInd05a) 
oInd05b:SetText(cInd05b) 
oInd05a:Refresh()
oInd05b:Refresh()

oSeta05:LoadBitmaps(cImg) 
oSeta05:Refresh()

/********** Atualiza o KPI06 *************/
If (cTipo == "P")
	nMeta06a:= nMeta06P
	nMeta06b:= nMeta06V
	nInd06a := nInd06P
	nInd06b := nInd06V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta06a:= nMeta06V
	nMeta06b:= nMeta06P
	nInd06a := nInd06V
	nInd06b := nInd06P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta06a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta06a) + cSimba + '</font>'
cMeta06b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta06b) + cSimbb + '</font>'
If (nInd06a <= nMeta06a)
	cInd06a:= '<font size="30" color="#228B22">' + cValToChar(nInd06a) + cSimba + '</font>'
	cInd06b:= '<font size="6" color="#228B22">' + cValToChar(nInd06b)  + cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd06a:= '<font size="30" color="#FA8072">' + cValToChar(nInd06a) +  cSimba + '</font>'
	cInd06b:= '<font size="6" color="#FA8072">' + cValToChar(nInd06b)  +  cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta06a:SetText(cMeta06a)
oMeta06b:SetText(cMeta06b)
oMeta06a:Refresh()
oMeta06b:Refresh()
 
oInd06a:SetText(cInd06a) 
oInd06b:SetText(cInd06b) 
oInd06a:Refresh()
oInd06b:Refresh()

oSeta06:LoadBitmaps(cImg) 
oSeta06:Refresh()

/********** Atualiza o KPI07 *************/
If (cTipo == "P")
	nMeta07a:= nMeta07P
	nMeta07b:= nMeta07V
	nInd07a := nInd07P
	nInd07b := nInd07V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta07a:= nMeta07V
	nMeta07b:= nMeta07P
	nInd07a := nInd07V
	nInd07b := nInd07P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta07a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta07a) +  cSimba + '</font>'
cMeta07b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta07b) +  cSimbb + '</font>'
If (nInd07a <= nMeta07a)
	cInd07a:= '<font size="30" color="#228B22">' + cValToChar(nInd07a) +  cSimba + '</font>'
	cInd07b:= '<font size="6" color="#228B22">' + cValToChar(nInd07b)  +  cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd07a:= '<font size="30" color="#FA8072">' + cValToChar(nInd07a) +  cSimba + '</font>'
	cInd07b:= '<font size="6" color="#FA8072">' + cValToChar(nInd07b)  +  cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta07a:SetText(cMeta07a)
oMeta07b:SetText(cMeta07b)
oMeta07a:Refresh()
oMeta07b:Refresh()
 
oInd07a:SetText(cInd07a) 
oInd07b:SetText(cInd07b) 
oInd07a:Refresh()
oInd07b:Refresh()

oSeta07:LoadBitmaps(cImg) 
oSeta07:Refresh()

/********** Atualiza o KPI08 *************/
If (cTipo == "P")
	nMeta08a:= nMeta08P
	nMeta08b:= nMeta08V
	nInd08a := nInd08P
	nInd08b := nInd08V
	cSimba  := "%"
	cSimbb  := ""
Else
	nMeta08a:= nMeta08V
	nMeta08b:= nMeta08P
	nInd08a := nInd08V
	nInd08b := nInd08P
	cSimba  := ""
	cSimbb  := "%"
EndIf	

cMeta08a:= '<font size="6" color="#4682B4">' + cValToChar(nMeta08a) +  cSimba + '</font>'
cMeta08b:= '<font size="3" color="#4682B4">' + cValToChar(nMeta08b) +  cSimbb + '</font>'
If (nInd08a >= nMeta08a)
	cInd08a:= '<font size="30" color="#228B22">' + cValToChar(nInd08a) +  cSimba + '</font>'
	cInd08b:= '<font size="6" color="#228B22">' + cValToChar(nInd08b)  +  cSimbb + '</font>'
	cImg:= "SETAVERDE.PNG"
Else
	cInd08a:= '<font size="30" color="#FA8072">' + cValToChar(nInd08a) +  cSimba + '</font>'
	cInd08b:= '<font size="6" color="#FA8072">' + cValToChar(nInd08b)  +  cSimbb + '</font>'
	cImg:= "SETAVERMELHA.PNG"
EndIf
oMeta08a:SetText(cMeta08a)
oMeta08b:SetText(cMeta08b)
oMeta08a:Refresh()
oMeta08b:Refresh()
 
oInd08a:SetText(cInd08a) 
oInd08b:SetText(cInd08b) 
oInd08a:Refresh()
oInd08b:Refresh()

oSeta08:LoadBitmaps(cImg) 
oSeta08:Refresh()

cUpdate:= '<font size="4" color="#FFD700">Última Atualização em ' + Dtoc(U_SyDate()) + ' - ' + Time() + '</font>'
oUpdate:SetText(cUpdate)

oTela:Refresh()
				 
oTimer:Activate()		
Return						 

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI
****************************************************************************/
Static Function KPIDADOS(cCoord,aDados,dDataIni,dDataFim)
Local cQuery:= ""
Local nPos  := 0
Local nPosOS:= 0
Local nPosDt:= 0
Local aOS   := {} //Para o controle da repeticao das OS visto que pode ter mais de um item por OS
Local cInRec:= ""

DEFAULT cCoord   := ""
DEFAULT aDados   := {} 

aDados:= {}

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

//Pega os recursos
cQuery:= " SELECT AE8_RECURS,AE8_DESCRI,AE8_COORD,AE8_EQUIPE "
cQuery+= " FROM " + RetSqlName("AE8") + " AE8"
cQuery+= " WHERE "
cQuery+= " AE8.D_E_L_E_T_ = '' "
cQuery+= " AND AE8.AE8_ATIVO <> '2' "
cQuery+= " AND AE8.AE8_EQUIPE IN ('1','2','4','B') "

If !Empty(cCoord)
	cQuery+= " AND (AE8.AE8_COORD = '" + cCoord + "' OR AE8.AE8_RECURS = '" + cCoord + "')"
EndIf

cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHAE8"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	//Alimenta o aDados 
	aAdd(aDados,{TRB->AE8_RECURS,TRB->AE8_DESCRI,TRB->AE8_COORD,"",0,0,0,0,0,0,0,0,0,0,0,TRB->AE8_EQUIPE})

	aDados[Len(aDados),4]:= Posicione("AE8",1,xFilial("AE8")+TRB->AE8_COORD,"AE8_DESCRI")
	
	If !Empty(cInRec)
		cInRec+= ","
	EndIf	
	cInRec+= "'" + AllTrim(TRB->AE8_RECURS) + "'"
	
	dbSkip()
End
TRB->(dbCloseArea())

If Len(aDados) == 0
	aAdd(aDados,{"","","","",0,0,0,0,0,0,0,0,0,0,0,""})
	cInRec:= "''"
EndIf

//Meta de Horas Apontadas
cQuery:= " SELECT ZC_RECURSO,ZC_VLRMETA "
cQuery+= " FROM " + RetSqlName("SZC") + " SZC "
cQuery+= " WHERE "
cQuery+= " SZC.D_E_L_E_T_ = '' "
cQuery+= " AND SZC.ZC_ANOMES = '" + Left(Dtos(dDataIni),6) + "'"
cQuery+= " AND SZC.ZC_TIPO = '1'"
cQuery+= " AND SZC.ZC_RECURSO IN (" + cInRec + ")"

cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHSZC"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	
	//[5]  - Meta de Horas do Mês 
	nPos:= aScan(aDados,{|x| x[1] == TRB->ZC_RECURSO})
	If (nPos > 0)
		aDados[nPos,5]+= TRB->ZC_VLRMETA
	EndIf
	
	DbSkip()
EndDo
TRB->(dbCloseArea())


//Verifica as datas que tiveram agenda para o recurso e os horarios de entrada e saida pois pode existir mais de 1 OS por recurso no mesmo dia
cQuery:= " SELECT Z2_RECURSO,Z2_DATA,MIN(Z2_HRINI1) Z2_HRINI1,MAX(Z2_HRFIM2) Z2_HRFIM2
cQuery+= " FROM " + RetSqlName("SZ2") + " SZ2 "
cQuery+= " WHERE SZ2.D_E_L_E_T_ = ''
cQuery+= " AND SZ2.Z2_DATA BETWEEN '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "'"
cQuery+= " AND SZ2.Z2_RECURSO IN (" + cInRec + ")"
//cQuery+= " AND SZ2.Z2_STATUS <> '1'"
cQuery+= " GROUP BY Z2_RECURSO,Z2_DATA"
cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHSZ2"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()

	nPos:= aScan(aDados,{|x| x[1] == TRB->Z2_RECURSO})
	If (nPos > 0)
		//Adiciona 1 na quantidade de agendas do recurso
		//[6]  - Quantidade de dias com agenda
		aDados[nPos,6]+= 1

		//Verifica Entrada Depois das 09:00
		//[10]  - Entrada Depois das 09:00
		If TRB->Z2_HRINI1 > "09:00" .And. !Empty(TRB->Z2_HRINI1)
			aDados[nPos,10]+= 1
		EndIf	

		//Verifica Saida antes das 18:00
		//[11]  - Saida Antes das 18:00
		If TRB->Z2_HRFIM2 < "18:00"  .And. !Empty(TRB->Z2_HRFIM2)
			aDados[nPos,11]+= 1
		EndIf	

	EndIf

	DbSkip()
End
TRB->(dbCloseArea())

//Pega as horas por tipo de hora 01=Faturavel outras=Nao Faturavel
cQuery:= " SELECT	Z2_RECURSO,Z3_TPHORA,SUM(Z3_HUTEIS) Z3_HUTEIS "
cQuery+= " FROM " + RetSqlName("SZ2") + " SZ2 ," + RetSqlName("SZ3") + " SZ3 "
cQuery+= " WHERE "
cQuery+= " SZ2.D_E_L_E_T_ = '' "
cQuery+= " AND SZ3.D_E_L_E_T_ = '' "
cQuery+= " AND SZ2.Z2_OS = SZ3.Z3_OS "
cQuery+= " AND SZ2.Z2_DATA BETWEEN '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "'"
cQuery+= " AND SZ2.Z2_RECURSO IN (" + cInRec + ")"
cQuery+= " AND SZ2.Z2_STATUS <> '1'"
cQuery+= " GROUP BY Z2_RECURSO,Z3_TPHORA"
cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHSZ3"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()

	nPos:= aScan(aDados,{|x| x[1] == TRB->Z2_RECURSO})
	If (nPos > 0)
		
		//[7]  - Horas Apontadas
		aDados[nPos,7]+= TRB->Z3_HUTEIS
		
		//[8]  - Horas Faturaveis
		If TRB->Z3_TPHORA == "01"
			aDados[nPos,8]+= TRB->Z3_HUTEIS
		Else	
		//[9]  - Horas Nao Faturaveis
			aDados[nPos,9]+= TRB->Z3_HUTEIS
		EndIf	
	EndIf
	
	DbSkip()
End
TRB->(dbCloseArea())


//Verifica se ainda existem OS nao encerradas e tb quantas ainda faltam aprovacao do coordenador
cQuery:= " SELECT Z2_RECURSO,Z2_STATUS,COUNT(*) QTDE "
cQuery+= " FROM " + RetSqlName("SZ2") + " SZ2 "
cQuery+= " WHERE SZ2.D_E_L_E_T_ = ''"
cQuery+= " AND SZ2.Z2_DATA BETWEEN '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "'"
cQuery+= " AND SZ2.Z2_RECURSO IN (" + cInRec + ")"
cQuery+= " GROUP BY Z2_RECURSO,Z2_STATUS "
cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHSZ2_2"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()

	nPos:= aScan(aDados,{|x| x[1] == TRB->Z2_RECURSO})
	If (nPos > 0)
 
		//[12] - Qtde. OS
		aDados[nPos,12]+= TRB->QTDE

		//[13] - Qtde. OS Encerradas
		If TRB->Z2_STATUS <> "1"
			aDados[nPos,13]+= TRB->QTDE
		EndIf

		//[14] - Qtde. OS Não Aprovada pelo coordenador 
		If TRB->Z2_STATUS == "02"
			aDados[nPos,14]+= TRB->QTDE
		EndIf
			
	EndIf
	
	DbSkip()
End
TRB->(dbCloseArea())

//Verifica as vendas
cQuery:= " SELECT AE8_RECURS,AE8_DESCRI,SUM(Z02_VALOR) Z02_VALOR"
cQuery+= " FROM " + RetSqlName("AE8") + " AE8 ," + RetSqlName("SA3") + " SA3 ," + RetSqlName("Z02") + " Z02 "
cQuery+= " WHERE "
cQuery+= " AE8.D_E_L_E_T_ = '' "
cQuery+= " AND SA3.D_E_L_E_T_ = '' "
cQuery+= " AND Z02.D_E_L_E_T_ = '' "
cQuery+= " AND AE8.AE8_USER = SA3.A3_CODUSR "
cQuery+= " AND AE8.AE8_EQUIPE = '4' "
cQuery+= " AND SA3.A3_COD = Z02.Z02_VEND2 "
cQuery+= " AND Z02.Z02_DTAPRO BETWEEN '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "'"
cQuery+= " AND Z02.Z02_STATUS IN ('5','9') "
cQuery+= " GROUP BY AE8_RECURS,AE8_DESCRI "

cQuery := ChangeQuery(cQuery)

MemoWrite("\LOGS\DASHSA3"+__cUserID+Dtos(U_SyDate())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+".TXT",cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	//[15] - Valor de Vendas no Mês
	nPos:= aScan(aDados,{|x| x[1] == TRB->AE8_RECURS})
	If (nPos > 0)
		aDados[nPos,15]+= TRB->Z02_VALOR
	EndIf

	DbSkip()
End
TRB->(dbCloseArea())

Return

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 01 - Horas Apontadas
****************************************************************************/
Static Function KPI01(aDados,nMeta01P,nInd01P,nMeta01V,nInd01V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta01P := 0 
DEFAULT nInd01P  := 0 
DEFAULT nMeta01V := 0 
DEFAULT nInd01V  := 0 
DEFAULT lDetalhe := .F. 

nMeta01P:= 0
nMeta01V:= 0
nInd01P := 0
nInd01V := 0

//KPI 01 - Meta de Horas Apontadas
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta01V+= Round(aDados[nX,5],0)
		nInd01V += Round(aDados[nX,7],0)
	Next nX

	nInd01P:= Round((nInd01V/nMeta01V)*100,0)
	nMeta01P  := 100
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 02 - OS Encerradas
****************************************************************************/
Static Function KPI02(aDados,nMeta02P,nInd02P,nMeta02V,nInd02V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta02P := 0 
DEFAULT nInd02P  := 0 
DEFAULT nMeta02V := 0 
DEFAULT nInd02V  := 0 
DEFAULT lDetalhe := .F. 

nMeta02P:= 0
nMeta02V:= 0
nInd02P := 0
nInd02V := 0

//KPI 02 - Meta de OS Encerradas
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta02V += Round(aDados[nX,12],0)
		nInd02V  += Round(aDados[nX,13],0)
	Next nX

	nInd02P := Round((nInd02V/nMeta02V)*100,0)
	nMeta02P:= 100
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 03 - Recursos Alocados
****************************************************************************/
Static Function KPI03(aDados,nMeta03P,nInd03P,nMeta03V,nInd03V,lDetalhe)
Local nX   := 0
Local nY   := 0
Local nI   := 0
Local nDias:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta03P := 0 
DEFAULT nInd03P  := 0 
DEFAULT nMeta03V := 0 
DEFAULT nInd03V  := 0 
DEFAULT lDetalhe := .F. 

nMeta03P:= 0
nMeta03V:= 0
nInd03P := 0
nInd03V := 0

//KPI 03 - Meta de Recursos Alocados
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

//Verifica a quantidade de dias úteis
/*
For nI:= FirstDay(dDatabase) To LastDay(dDatabase)
	If nI == DataValida(nI)
		nDias++
	EndIf
Next nI
*/

If lDetalhe
Else

	//Calcula a alocacao multiplicando a quantidade de dias uteis pela quantidade de recursos
//	nMeta03V  := nDias * Len(aDados)
	
	//Verifica quantos dias por recurso tem agenda
	For nX:= 1 To Len(aDados)
		//Calcula a alocacao dividindo a meta de horas por 9 porque podem ter recursos que entraram no meio do mes
		nMeta03V+= Round(aDados[nX,5]/9,0)
		nInd03V += aDados[nX,6]
	Next nX

	nInd03P := Round((nInd03V/nMeta03V)*100,0)
	nMeta03P:= 100
EndIf

Return()


/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 04 - Horas Faturáveis
****************************************************************************/
Static Function KPI04(aDados,nMeta04P,nInd04P,nMeta04V,nInd04V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta04P := 0 
DEFAULT nInd04P  := 0 
DEFAULT nMeta04V := 0 
DEFAULT nInd04V  := 0 
DEFAULT lDetalhe := .F. 

nMeta04P:= 0
nMeta04V:= 0
nInd04P := 0
nInd04V := 0

//KPI 04 - Meta de Horas Faturáveis
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta04V+= Round(aDados[nX,7],0)
		nInd04V += Round(aDados[nX,8],0)
	Next nX

	nInd04P := Round((nInd04V/nMeta04V)*100,0)
	nMeta04P:= 90
	nMeta04V:= Round(0.90 * nMeta04V,0)
	
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 05 - Horas Não Faturáveis
****************************************************************************/
Static Function KPI05(aDados,nMeta05P,nInd05P,nMeta05V,nInd05V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta05P := 0 
DEFAULT nInd05P  := 0 
DEFAULT nMeta05V := 0 
DEFAULT nInd05V  := 0 
DEFAULT lDetalhe := .F. 

nMeta05P:= 0
nMeta05V:= 0
nInd05P := 0
nInd05V := 0

//KPI 05 - Meta de Horas NÃO Faturáveis
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta05V+= Round(aDados[nX,7],0)
		nInd05V += Round(aDados[nX,9],0)
	Next nX

	nInd05P := Round((nInd05V/nMeta05V)*100,0)
	nMeta05P:= 10
	nMeta05V:= Round(0.10 * nMeta05V,0)
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 06 - Entrada Após 09:00
****************************************************************************/
Static Function KPI06(aDados,nMeta06P,nInd06P,nMeta06V,nInd06V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta06P := 0 
DEFAULT nInd06P  := 0 
DEFAULT nMeta06V := 0 
DEFAULT nInd06V  := 0 
DEFAULT lDetalhe := .F. 

nMeta06P:= 0
nMeta06V:= 0
nInd06P := 0
nInd06V := 0

//KPI 06 - Meta de Entrada no Horário
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta06V+= Round(aDados[nX,6],0)
		nInd06V += Round(aDados[nX,10],0)
	Next nX

	nInd06P := Round((nInd06V/nMeta06V)*100,0)
	nMeta06P:= 5
	nMeta06V:= Round(0.05 * nMeta06V,0)
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 07 - Saída antes das 18:00
****************************************************************************/
Static Function KPI07(aDados,nMeta07P,nInd07P,nMeta07V,nInd07V,lDetalhe)
Local nX:= 0
Local nY:= 0

DEFAULT aDados   := {} 
DEFAULT nMeta07P := 0 
DEFAULT nInd07P  := 0 
DEFAULT nMeta07V := 0 
DEFAULT nInd07V  := 0 
DEFAULT lDetalhe := .F. 

nMeta07P:= 0
nMeta07V:= 0
nInd07P := 0
nInd07V := 0

//KPI 07 - Meta de Saída no Horário
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		nMeta07V+= Round(aDados[nX,6],0)
		nInd07V += Round(aDados[nX,11],0)
	Next nX

	nInd07P := Round((nInd07V/nMeta07V)*100,0)
	nMeta07P:= 5
	nMeta07V:= Round(0.05 * nMeta07V,0)
EndIf

Return()

/***************************************************************************
Executa rotina que irá calcula e se necessário exibir os detalhes do KPI

KPI 08 - Valor de Vendas
****************************************************************************/
Static Function KPI08(aDados,nMeta08P,nInd08P,nMeta08V,nInd08V,lDetalhe)
Local nX    := 0
Local nY    := 0
Local nVenda:= GetMv("MV_SYMETAVD",,80000)

DEFAULT aDados   := {} 
DEFAULT nMeta08P := 0 
DEFAULT nInd08P  := 0 
DEFAULT nMeta08V := 0 
DEFAULT nInd08V  := 0 
DEFAULT lDetalhe := .F. 

nMeta08P:= 0
nMeta08V:= 0
nInd08P := 0
nInd08V := 0

//KPI 08 - Valor de Vendas
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

If lDetalhe
Else
	
	For nX:= 1 To Len(aDados)
		If (aDados[nX,16] == "4") // Coordenador
			nInd08V += Round(aDados[nX,15],0)
			nMeta08V+= Round(nVenda,0)
		EndIf
	Next nX

	nInd08P := Round((nInd08V/nMeta08V)*100,0)
	nMeta08P:= 100
EndIf

Return()

/*****************************
Troca de valores absolutos e vice versa
******************************/
Static Function AbsRelativo(oBtn00,bAction1)

//Muda a imagem do botao e a variavel de controle
If (cTipo == "P")
	cImg:= "RELATIVO.PNG"
	cTipo:= "V"
Else
	cImg:= "ABSOLUTO.PNG"
	cTipo:= "P"
EndIf	

oBtn00:LoadBitmaps(cImg)
oBtn00:Refresh()

//Grava no parametro para iniciar com a ultima configuracao
PUTMV("MV_SYDASH",cTipo)

//Executa o calculo e atualiza a tela
Eval(bAction1)

Return

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


/*****************************
Verifica OS pendentes para troca de botão
******************************/
Static Function AtuBtn(oBtn02,aDados)
Local nOS     := 0
Local cImg    := ""
Local cToolTip:= ""

nOS:= OSNaoApr(aDados)
//Muda a imagem do botao e a variavel de controle
If (nOS > 0)
	cImg    := "APROVACAO2.PNG"
	cToolTip:= "Você tem " + cValToChar(nOs) + " OS ainda não aprovadas." 
Else
	cImg    := "APROVACAO.PNG"
	cToolTip:= "Você não tem nenhuma OS pendente de aprovação."
EndIf	

oBtn02:LoadBitmaps(cImg)
oBtn02:cToolTip:= cToolTip 
oBtn02:Refresh()
Return

/*****************************
Exibe os detalhes do KPI
******************************/
Static Function Detalhe(nKPI,aDados,cMetaa,cInda)
Local oTela
Local oList
Local oPanel
Local oMeta
Local oMetaa
Local oInd
Local oInda
Local oFnt
Local aSize := MsAdvSize()
Local oOk   := LoadBitmap( GetResources(), "ENABLE")
Local oNo   := LoadBitmap( GetResources(), "DISABLE")
Local aList := {}
Local nI    := 0
Local nX    := 0
Local nInd  := 0
Local nMeta := 0
Local cStyle:= "QFrame{ border-style:solid; border-width:1px; border-color:#CDCDCD; background-color:#FFFFFF;}"
Local cTitle:= ""

/*
KPI01 - Horas Apontadas
KPI02 - OS Encerradas
KPI03 - Recursos Alocados
KPI04 - Horas Faturáveis
KPI05 - Horas Nâo Faturáveis
KPI06 - Entrada no Horário
KPI07 - Saída no Horário
KPI08 - Vendas no Mês

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

*/

If (nKPI == 1)
	cTitle:= "Horas Apontadas por Recurso"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= aDados[nI,5]
		nInd := aDados[nI,7]

		AADD(aList,{IIf(nInd >= nMeta,.T.,.F.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 2)
	cTitle:= "OS Encerradas no Prazo"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= 0
		nMeta+= aDados[nI,12]
		nInd += aDados[nI,13]

		AADD(aList,{IIf(nInd >= nMeta,.T.,.F.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 3)
	cTitle:= "Recursos com Agendas Alocadas"

/*	For nI:= FirstDay(dDatabase) To LastDay(dDatabase)
		If nI == DataValida(nI)
			nMeta++
		EndIf
	Next nI
*/
	For nI := 1 to Len(aDados)
		//Calcula a quantidade de dias dividindo a meta do recurso por 9 
		nMeta:= Round(aDados[nI,5]/9,0)
		nInd := aDados[nI,6]

		AADD(aList,{IIf(nInd >= nMeta,.T.,.F.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 4)
	cTitle:= "Horas Faturáveis por Recurso"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= 0
		nMeta+= aDados[nI,7]
		nInd += aDados[nI,8]

		AADD(aList,{IIf(nInd >= nMeta,.T.,.F.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 5)
	cTitle:= "Horas Não Faturáveis por Recurso"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= 0
		nInd+= aDados[nI,9]

		AADD(aList,{IIf(nInd >= nMeta,.F.,.T.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 6)
	cTitle:= "Recursos com Entrada Após as 09:00hrs"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= 0
		nInd+= aDados[nI,10]

		AADD(aList,{IIf(nInd >= nMeta,.F.,.T.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 7)
	cTitle:= "Recursos com Saida Antes das 18:00hrs"
	For nI := 1 to Len(aDados)
		nInd := 0
		nMeta:= 0
		nInd+= aDados[nI,11]

		AADD(aList,{IIf(nInd >= nMeta,.F.,.T.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],nMeta,nInd})
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
ElseIf (nKPI == 8)
	cTitle:= "Vendas no Mês"
	For nI := 1 to Len(aDados)
		If aDados[nI,16] == "4"
			nInd:= aDados[nI,15]

			AADD(aList,{IIf(nInd >= 80000,.T.,.F.),aDados[nI,1],aDados[nI,2],aDados[nI,3],aDados[nI,4],80000,nInd})
		EndIf
	Next nI

	aList:= aSort(aList,,,{|x,y| x[7]>y[7]})
EndIf

If (Len(aList) == 0)
	Aviso("Atenção","KPI sem detalhes para exibir",{"Ok"})
	Return
EndIf

DEFINE FONT oFnt NAME "ARIAL" SIZE 0,-12 BOLD

DEFINE MSDIALOG oTela FROM 0,0 TO aSize[6],aSize[5] TITLE "Detalhe do KPI " + cTitle Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oPanel:= TPanelCSS():New(040,40,nil,oTela,nil,nil,nil,nil,nil,40,40,nil,nil)
    oPanel:setCSS(cStyle)
    oPanel:Align:= CONTROL_ALIGN_BOTTOM

	cMeta := '<font size="6" color="#4682B4">Meta</font>'
	oMeta := TSay():New( 010, 020,{|| cMeta}, oPanel,,oFnt,,,,.T.,,,50,50,,,,,,.T.)
	oMetaa:= TSay():New( 010, 080,{|| cMetaa}, oPanel,,oFnt,,,,.T.,,,50,50,,,,,,.T.)

	cInd := '<font size="6" color="#4682B4">Resultado</font>'
	oInd := TSay():New( 010, 200,{|| cInd}, oPanel,,oFnt,,,,.T.,,,100,100,,,,,,.T.)
	oInda:= TSay():New( 010, 300,{|| cInda}, oPanel,,oFnt,,,,.T.,,,200,200,,,,,,.T.)
	
	@ 30,20 LISTBOX oList VAR cList FIELDS HEADER "","Consultor","Nome","Coordenador","Nome","Meta","Indice Alcancado" SIZE 273,090 NoScroll OF oTela PIXEL
	
	oList:SetArray(aList)
	oList:bLine := { || {	If(aList[oList:nAt,1],oOk,oNo),;
							aList[oList:nAt,2],;
							aList[oList:nAt,3],;
							aList[oList:nAt,4],;
							aList[oList:nAt,5],;
							Transform(aList[oList:nAt,6],PesqPict("SE2","E2_VALOR")),;
							Transform(aList[oList:nAt,7],PesqPict("SE2","E2_VALOR"))}}
	oList:Align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oTela ON INIT ( EnchoiceBar(	oTela,;
												{|| oTela:End()  },;
												{|| oTela:End() }) ) CENTERED

Return


/*
Static Function KPIDADOS(cCoord,aDados)
Local cQuery:= ""
Local nPos  := 0
Local nPosOS:= 0
Local nPosDt:= 0
Local aOS   := {} //Para o controle da repeticao das OS visto que pode ter mais de um item por OS
Local cInRec:= ""

DEFAULT cCoord   := ""
DEFAULT aDados   := {} 

aDados:= {}

// ESTRUTURA ADADOS

[1] - Código do Recurso
[2] - Nome do Recurso
[3] - Código do Coordenador
[4] - Nome do Coordenador
[5] - Meta de Horas do Mês
[6] - Array of OS
[6,1] - Data
[6,2] - Horas Apontadas
[6,3] - Horas Faturaveis
[6,4] - Horas Nao Faturaveis
[6,5] - Entrada Apos 09:00
[6,6] - Saida Antes das 18:00
[6,7] - Qtde. OS Encerradas
[6,8] - Qtde. OS 
[6,9] - Qtde. OS Não Aprovada pelo coordenador 
[6,10]- Horário de Entrada no dia
[6,11]- Horário de Saida no dia
[7] - Valor de Vendas
[8] - Equipe


//Pega os recursos
cQuery:= " SELECT AE8_RECURS,AE8_DESCRI,AE8_COORD,AE8_EQUIPE "
cQuery+= " FROM " + RetSqlName("AE8") + " AE8"
cQuery+= " WHERE "
cQuery+= " AE8.D_E_L_E_T_ = '' "
cQuery+= " AND AE8.AE8_ATIVO <> '2' "
cQuery+= " AND AE8.AE8_EQUIPE IN ('1','2','4','B') "

If !Empty(cCoord)
	cQuery+= " AND (AE8.AE8_COORD = '" + cCoord + "' OR AE8.AE8_RECURS = '" + cCoord + "')"
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	aAdd(aDados,{TRB->AE8_RECURS,TRB->AE8_DESCRI,TRB->AE8_COORD,"",0,{},0,TRB->AE8_EQUIPE})

	aDados[Len(aDados),4]:= Posicione("AE8",1,xFilial("AE8")+TRB->AE8_COORD,"AE8_DESCRI")
	
	If !Empty(cInRec)
		cInRec+= ","
	EndIf	
	cInRec+= "'" + AllTrim(TRB->AE8_RECURS) + "'"
	
	dbSkip()
End
TRB->(dbCloseArea())

//Meta de Horas Apontadas
cQuery:= " SELECT ZC_RECURSO,ZC_VLRMETA "
cQuery+= " FROM " + RetSqlName("SZC") + " SZC "
cQuery+= " WHERE "
cQuery+= " SZC.D_E_L_E_T_ = '' "
cQuery+= " AND SZC.ZC_ANOMES = '" + Left(Dtos(dDatabase),6) + "'"
cQuery+= " AND SZC.ZC_TIPO = '1'"
cQuery+= " AND SZC.ZC_RECURSO IN (" + cInRec + ")"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	
	nPos:= aScan(aDados,{|x| x[1] == TRB->ZC_RECURSO})
	If (nPos > 0)
		aDados[nPos,5]+= TRB->ZC_VLRMETA
	EndIf
	
	DbSkip()
EndDo
TRB->(dbCloseArea())

//Selecionas as OS (Todos os status)
cQuery:= " SELECT * "
cQuery+= " FROM " + RetSqlName("SZ2") + " SZ2 ," + RetSqlName("SZ3") + " SZ3 "
cQuery+= " WHERE "
cQuery+= " SZ2.D_E_L_E_T_ = '' "
cQuery+= " AND SZ3.D_E_L_E_T_ = '' "
cQuery+= " AND SZ2.Z2_OS = SZ3.Z3_OS "
cQuery+= " AND SZ2.Z2_DATA BETWEEN '" + Dtos(FirstDay(dDatabase)) + "' AND '" + Dtos(LastDay(dDatabase)) + "'"
cQuery+= " AND SZ2.Z2_RECURSO IN (" + cInRec + ")"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()

	nPos:= aScan(aDados,{|x| x[1] == TRB->Z2_RECURSO})
	If (nPos > 0)
		
		nPosDt:= aScan(aDados[nPos,6],{|x| x[1] = TRB->Z2_DATA })
		If (nPosDt == 0)
			aAdd(aDados[nPos,6],{TRB->Z2_DATA,0,0,0,0,0,0,0,0,"",""})
			nPosDt:= Len(aDados[nPos,6])
		EndIf

		//Horas Apontadas
		aDados[nPos,6,nPosDt,2]+= TRB->Z3_HUTEIS
	
		//Horas Apontadas - FATURÁVEIS/NÂO FATURÀVEIS
		If TRB->Z3_TPHORA == "01"
			aDados[nPos,6,nPosDt,3]+= TRB->Z3_HUTEIS
		Else
			aDados[nPos,6,nPosDt,4]+= TRB->Z3_HUTEIS
		EndIf	
	
		//Verifica a Quantidade de OS do Recurso
		nPosOS:= aScan(aOS,TRB->Z2_OS )
		If (nPosOS == 0)
			aAdd(aOS,TRB->Z2_OS)

			//Verifica Entrada Depois das 09:00
			If TRB->Z2_HRINI1 > "09:00"
				aDados[nPos,6,nPosDt,5]+= 1
			EndIf	

			//Verifica Saida antes das 18:00
			If TRB->Z2_HRFIM2 < "18:00"
				aDados[nPos,6,nPosDt,6]+= 1
			EndIf	

			//Verifica OS Encerradas
			If TRB->Z2_STATUS <> "1"
				aDados[nPos,6,nPosDt,7]+= 1
			ElseIf TRB->Z2_STATUS == "2" //OS encerrada e nao aprovada pelo coordenador ainda
				aDados[nPos,6,nPosDt,9]+= 1
			EndIf	

			aDados[nPos,6,nPosDt,8]+= 1
		EndIf

	EndIf

	dbSkip()
End
TRB->(dbCloseArea())

//Verifica as vendas
cQuery:= " SELECT AE8_RECURS,AE8_DESCRI,SUM(Z02_VALOR) Z02_VALOR"
cQuery+= " FROM " + RetSqlName("AE8") + " AE8 ," + RetSqlName("SA3") + " SA3 ," + RetSqlName("Z02") + " Z02 "
cQuery+= " WHERE "
cQuery+= " AE8.D_E_L_E_T_ = '' "
cQuery+= " AND SA3.D_E_L_E_T_ = '' "
cQuery+= " AND Z02.D_E_L_E_T_ = '' "
cQuery+= " AND AE8.AE8_USER = SA3.A3_CODUSR "
cQuery+= " AND AE8.AE8_EQUIPE = '4' "
cQuery+= " AND SA3.A3_COD = Z02.Z02_VEND2 "
cQuery+= " AND Z02.Z02_DTAPRO BETWEEN '" + Dtos(FirstDay(dDatabase)) + "' AND '" + Dtos(LastDay(dDatabase)) + "'"
cQuery+= " AND Z02.Z02_STATUS IN ('5','9') "
cQuery+= " GROUP BY AE8_RECURS,AE8_DESCRI "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbGoTop()
While !EOF()
	nPos:= aScan(aDados,{|x| x[1] == TRB->AE8_RECURS})
	If (nPos > 0)
		aDados[nPos,7]+= TRB->Z02_VALOR
	EndIf
End
TRB->(dbCloseArea())

Return
*/