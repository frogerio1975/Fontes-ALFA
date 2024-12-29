#Include "Protheus.ch"      
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"
           
#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4   
#Define CRLF	Chr(10)+Chr(13)

Static lJaExecutou 		:= .F.		   		// Usado na funcao SyOrdCab()
Static cEmExecucaoPend 	:= '00:00'			// Usado na funcao SyMostraPend
Static oTimerCrd                   			// Objeto do timer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SYCRMA01 ³ Autor ³   Alexandro Dias      ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de relacionamentos.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYCRMA01()

Local aAlias 	:= GetArea()
Local aCores   := {	{"SUS->US_STATUS  = '6'"	, "BR_VERDE"    },;		//Cliente
					{"SUS->US_STATUS != '6'"	, "BR_AMARELO" 	}} 		//Lead

Private cCadastro 	:= OemToAnsi("Painel de Relacionamento")
Private aRotina	  	:= {}
Private aVend 		:= {}

aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Timer para agenda de pendencias.       				             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SyTimerPend(oMainWnd)

DbSelectArea('SUS')
DbSetOrder(1)
SUS->(DbClearFilter())
mBrowse(6, 1, 22, 75, 'SUS',,,,,,aCores)

RestArea(aAlias)

Return(.T.)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Fabio Rogerio       º Data ³  02/22/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta menu                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef() 

Local aRotina:= {}

aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'U_CRMAIncAlt'		, 0,3} ,;
				{ 'Alterar'			,'U_CRMAIncAlt'		, 0,4} ,;
				{ 'Excluir'			,'U_CRMAIncAlt'		, 0,5} ,;
				{ 'Legenda'			,'U_CRMA01Leg'		, 0,6} ,;
				{ 'Follow-up'		,'U_CRMA01Cal'		, 0,4} ,;
				{ 'Suspect'			,'U_SYTMKA341'		, 0,4} ,;
				{ 'Atualiza CNAEs'	,'U_SyConsCNPJ'		, 0,8}}
				
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CRMA01Cal ³ Autor ³    Alexandro Dias     ³ Data ³ 21/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela inicial do Call Center.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CRMA01Cal(cAlias,nReg,nOpc,cProposta,cAditivo,cEntidade,lDireto)

Local cNaoPermiteAlt
Local aAlias 		:= GetArea()
Local aButtons		:= {}
Local aAlterSU5		:= {'U5_CONTAT','U5_CELULAR','U5_FCOM1','U5_FCOM2','U5_EMAIL','U5_FUNCAO','U5_DFUNCAO'}
Local nlOrdemCols	:= .F.
Local cHistorico	:= ''
Local cEvento		:= ''
Local aObjects 		:= {}
Local aSize    		:= MsAdvSize()
Local bHist 		:= {|| cObsTmk := oGetHist:aCols[oGetHist:nAt,aScan(oGetHist:aHeader,{|x| AllTrim(x[2]) == 'SY_MEMO'} )] , oMemoTmk:Refresh() }
Local bHistAuto 	:= {|| TmkA01Obs(@cEvento,@cHistorico) , U_SyGravaSYP(@cHistorico,.T.,M->US_COD+M->US_LOJA,'SUS','','',cEvento,cProposta,cAditivo) , , cHistorico := '' }
Local bEvento		:= {|| CrmA01Eve(@cEvento,@oTelaCRM,@cHistorico,cProposta,cAditivo,cNaoPermiteAlt,@lOk,bHistAuto) }
Local bScript		:= {|| U_SyTk271Script(M->US_COD,"",@cHistorico) }
Local aCposSUSv 	:= {'US_COD','US_NOME','US_NREDUZ','US_TEL','US_CEP','US_END','US_BAIRRO','US_MUN','US_EST','US_CGC','US_CNAE','US_SEGMEN','NOUSER'}
Local aCposSUSa 	:= {'US_NREDUZ','US_TEL','US_CEP','US_END','US_BAIRRO','US_MUN','US_EST','NOUSER'}
Local aRotBKP		:= {}
Local nX			:= 0
Local lOk			:= .F. 
Local cNomeCli
Local oNomeCli
Local oDtUltCo
Local oDtPrxCo
Local dDtUltCo
Local dDtPrxCo
Local oNomeOpe
Local oNomeVen
Local oPnlMaster
Local oPanelFolder
Local oScrollMemo
Local oScrollSUS
Local oCadastro
Local nZ

Private bCampo 	    := {|nCPO| Field(nCPO) }
Private oFnt
Private oFnt2
Private oObsTohoma
Private oFntReuniao
Private oMemoTmk
Private oTelaCRM
Private cGrpPMS		:= 'COORDENACAO_TECNICA/PMO'
Private cObsTmk 	:= ''
Private cObsOld		:= ''
Private aGetSU5		:= {}
Private aHeaderSU5 	:= {}
Private aGetSZB		:= {}
Private aHeaderSZB 	:= {}
Private aHeaderHist	:= {}
Private oGetHist
Private aGetHist	:= {}
Private nStyle 		:= 0
Private cStatusOp	:= ''
Private aStatusOp 	:= {}
Private oStatusOp

Private oGetContatos
Private oPnlContatos

Default cProposta 	:= ''
Default cAditivo 	:= ''
Default lDireto	  	:= ''
                              
DEFINE FONT oFnt 		NAME "Courier New" SIZE 0,-14 BOLD
DEFINE FONT oFnt2 		NAME "Courier New" SIZE 0,-20 BOLD
DEFINE FONT oObsTohoma	NAME "Courier New" SIZE 0,-14 BOLD                                
DEFINE FONT oFntReuniao	NAME "Courier New" SIZE 0,-12 BOLD

IF Type('aRotina') == 'U'   
//	aRotBKP	:= aClone(aRotina)
aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'AxInclui'			, 0,3} ,;
				{ 'Alterar'			,'AxAltera'			, 0,4} }
EndIF
aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'AxInclui'			, 0,3} ,;
				{ 'Alterar'			,'AxAltera'			, 0,4} }
INCLUI:= .F.
ALTERA:= .T.
nOpc := IIF ( Alltrim(FunName()) $ "SHOWGRFVDA/SYCRMA01/SYCRMGRF" , 4 , nOpc )

IF (nOpc == 3) .Or. (nOpc == 4)
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nStyle := 0
EndIF   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os dados da tabela.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,IIF(nOpc == 3,.T.,.F.))

IF !Empty(cProposta)
	
	RegToMemory('Z02',.F.)

	cNaoPermiteAlt 	:= '5/9'
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega status da proposta.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF (M->Z02_STATUS $ cNaoPermiteAlt)
	
		Aadd( aStatusOp, '5-Aprovados')
		Aadd( aStatusOp, '9-Projeto Gerado')
	
	Else
	
		Aadd( aStatusOp, '1-Leads Qualificado')
		Aadd( aStatusOp, '2-Desqualificado')
		Aadd( aStatusOp, '3-Em Negociacao')
		Aadd( aStatusOp, '6-Suspensos')
		Aadd( aStatusOp, '7-Perdidos')
	
	EndIF

	nX 				:= Ascan(aStatusOp,M->Z02_STATUS)
	cNomeVen 		:= Capital(Alltrim(Posicione('SA3',1,xFilial('SA3')+M->Z02_VEND2,'A3_NREDUZ')))
	dDtUltCo		:= Ctod('')
	dDtPrxCo		:= Dtoc(dDataBase) + ' as 09:00'	

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega status do prospect.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aStatusOp, '0-Nao Qualificado')
	Aadd( aStatusOp, '1-Em Contato')
	Aadd( aStatusOp, '2-Repassado para EAR')
	Aadd( aStatusOp, '3-StandBy')
	Aadd( aStatusOp, '4-Desqualificado')
	Aadd( aStatusOp, '6-Cliente')
	Aadd( aStatusOp, '7-Telefone Errado')

	nX 				:= Ascan(aStatusOp,M->US_STATUS)
	cNomeVen 		:= Capital(Alltrim(Posicione('SA3',1,xFilial('SA3')+M->US_VEND,'A3_NREDUZ')))
	cNaoPermiteAlt 	:= '6'
	dDtUltCo		:= M->US_DTULTCO
	dDtPrxCo		:= Dtoc(M->US_DTPRXCO) + ' as ' + M->US_HRPRXCO 

EndIF

cEntidade		:= M->US_COD + M->US_LOJA
cNomeCli 		:= Left(M->US_NOME,25)
cNomeOpe 		:= Alltrim(UsrRetName(M->US_OPERADO))

IF nX > 0 
	cStatusOp := aStatusOp[nX] 
Else
	cStatusOp := aStatusOp[1]
EndIF

Processa({|| MontaDadosTela(nOpc,cEntidade) },"Aguarde, Filtrando Dados...",,.T.)

oSize := FwDefSize():New( .T.)
	 
oSize:AddObject( "ENCHOICE" , 100, 100, .T., .T. ) // enchoice
oSize:lProp := .T.
oSize:Process()

DEFINE MSDIALOG oTelaCRM FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE "Follow-up" Of oMainWnd PIXEL 

DEFINE TIMER oTimerCrd INTERVAL 60000 ACTION ( SyMostraPend() ) OF oTelaCRM

oTimerCrd:Activate()

oTelaCRM:lEscClose 	:= .F.
oTelaCRM:lMaximized := .T.    

oPnlMaster:= TPanel():New(0, 0, "", oTelaCRM, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPnlMaster:Align:= CONTROL_ALIGN_ALLCLIENT

oPnlTitulo:= TPanel():New(0, 0, '', oPnlMaster, NIL, .T., .F., NIL, NIL, 0,50, .T., .F. )
oPnlTitulo:Align 	:= CONTROL_ALIGN_TOP
oPnlTitulo:nClrPane	:= Rgb(255,255,255)   

@ 002,010 SAY "Empresa: "				OF oPnlTitulo FONT oFnt COLOR CLR_BLACK	Pixel SIZE 100,12
@ 014,010 SAY "Oportunidade: " 			OF oPnlTitulo FONT oFnt COLOR CLR_RED	Pixel SIZE 100,12
@ 026,010 SAY "Ultimo Contato: "		OF oPnlTitulo FONT oFnt COLOR CLR_BLUE	Pixel SIZE 100,12
@ 038,010 SAY "Proximo Contato: " 		OF oPnlTitulo FONT oFnt COLOR CLR_BLUE	Pixel SIZE 100,12

@ 002,080 SAY oNomeCli VAR cNomeCli 	OF oPnlTitulo FONT oFnt COLOR CLR_RED	Pixel SIZE 500,15
@ 014,080 SAY oCodProp VAR cProposta +'-'+ cAditivo + '-' + Left(Posicione('Z02',1,xFilial('Z02')+cProposta+cAditivo,'Z02_DESCRI'),40) OF oPnlTitulo FONT oFnt COLOR CLR_BLACK	Pixel SIZE 400,15
@ 026,080 SAY oDtUltCo VAR dDtUltCo 	OF oPnlTitulo FONT oFnt COLOR CLR_BLUE	Pixel SIZE 500,15
@ 038,080 SAY oDtPrxCo VAR dDtPrxCo 	OF oPnlTitulo FONT oFnt COLOR CLR_BLACK	Pixel SIZE 500,15

@ 002,300 SAY "Operador: "				OF oPnlTitulo FONT oFnt COLOR CLR_BLACK	Pixel SIZE 100,12
@ 014,300 SAY "Vendedor: "	 			OF oPnlTitulo FONT oFnt COLOR CLR_RED 	Pixel SIZE 100,12

@ 002,340 SAY oNomeOpe VAR cNomeOpe 	OF oPnlTitulo FONT oFnt COLOR CLR_RED	Pixel SIZE 500,15
@ 014,340 SAY oNomeVen VAR cNomeVen 	OF oPnlTitulo FONT oFnt COLOR CLR_BLACK	Pixel SIZE 500,15

TButton():New( 005 , 440 , "Follow-up" 	,oPnlTitulo,{|| Eval(bEvento) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
//TButton():New( 025 , 440 , "Script" 	,oPnlTitulo,{|| Eval(bScript) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

oPanelFolder:=TFolder():New(0,0,{'Contatos e Follow-up','Dados Cadastrais','Propostas em Aberto','Referências'},,oPnlMaster,,,,.T.,.F.,0,0)
oPanelFolder:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Folder para Contatos e Historicos.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPnlContatos:= TPanel():New(0,0,'',oPanelFolder:aDialogs[1],,,,,,,00)
oPnlContatos:Align:= CONTROL_ALIGN_ALLCLIENT

oHistorico:= TPanel():New(0,0,'',oPanelFolder:aDialogs[1],,,,,,,120)
oHistorico:Align:= CONTROL_ALIGN_BOTTOM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contatos.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetContatos:= MsNewGetDados():New(0,0,0,0,nStyle,"U_SU5LINOK","Allwaystrue",,aAlterSU5,,9999,,,,oPnlContatos,@aHeaderSU5,@aGetSU5)
oGetContatos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Historico.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRowA 		:= 2
nColA 		:= 2
nLarguraA 	:= ( (oHistorico:OWND:NCLIENTWIDTH/2) * 40 ) / 100
nAlturaA 	:= (oHistorico:NCLIENTHEIGHT/2)

oPnlA := TPanel():New(nRowA,nColA,,oHistorico,,.T.,.T.,CLR_BLACK ,,nLarguraA,nAlturaA,.T.,.T.) 

nRowB 		:= nRowA
nColB 		:= nLarguraA + 4
nLarguraB 	:= (oHistorico:OWND:NCLIENTWIDTH/2) - nLarguraA - 10
nAlturaB 	:= (oHistorico:NCLIENTHEIGHT/2) - 5

oPnlB := TPanel():New(nRowB,nColB,,oHistorico,,.T.,.T.,CLR_BLACK ,,nLarguraB,nAlturaB,.T.,.T.) 

oGetHist:=MsNewGetDados():New(2,2,2,2,0,"Allwaystrue","Allwaystrue","",,,,,,,oPnlA,aHeaderHist,aGetHist)
oGetHist:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetHist:bChange := {|| Eval(bHist) }

//oScrollMemo := TScrollBox():New(oPnlB, 0, 0, 0, 0, .T., .T., .T.)
//oScrollMemo:Align := CONTROL_ALIGN_ALLCLIENT

oMemoTmk := tMultiget():new(0,0,{| u | if( pCount() > 0, cObsTmk := u, cObsTmk )},oPnlB,0,0,,,,,,.T.)
oMemoTmk:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cadastro do Prospect.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oScrollSUS := TScrollBox():New(oPanelFolder:aDialogs[2], 0, 0, 0, 0, .T., .T., .T.)
oScrollSUS:Align := CONTROL_ALIGN_ALLCLIENT

oCadastro := MsmGet():New('SUS',SUS->(Recno()),4,,,,,{	oSize:GetDimension("ENCHOICE","LININI")-35,;
           									  			oSize:GetDimension("ENCHOICE","COLINI")-5,;
           									   			oSize:GetDimension("ENCHOICE","LINEND"),;
           									   			oSize:GetDimension("ENCHOICE","COLEND")-10},,,,,,oScrollSUS,,,,,.T.)    
   
ACTIVATE MSDIALOG oTelaCRM ON INIT EnchoiceBar( oTelaCRM ,;
 	{|| lOk := .T. , oTelaCRM:End() } ,;
  	{|| IIF( MsgNoYes('Deseja Sair sem Gravar as Informações?') , oTelaCRM:End() , .F. ) },,aButtons )

IF lOk
    
    IF !Empty(cProposta)

    	DbSelectArea('Z02')
    	DbSetOrder(1)
    	IF DbSeek(xFilial('Z02')+cProposta+cAditivo)
    	
    		RecLock('Z02',.F.)
	    	
	    	For nX := 1 TO FCount()
				IF ('FILIAL' $ FieldName(nX) )
					FieldPut(nX,xFilial('Z02'))
				Else
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				EndIF
			Next nX     
			
			MsUnLock()
			
		EndIF
    
    EndIF
   
   	IF nOpc == 3
		cMay := "SUS"+ Alltrim(xFilial("SUS"))
		DbSelectArea('SUS')
		DbSetOrder(1)
		While ( DbSeek(xFilial("SUS") + M->US_COD+M->US_LOJA) .Or. !MayIUseCode(cMay + M->US_COD + M->US_LOJA) )
			M->US_COD := GetSxeNum('SUS','US_COD')
			M->US_LOJA:= "01"
		EndDo
		ConfirmSX8()

 		RecLock('SUS',.T.)
	Else
		DbSelectArea('SUS')
		DbSetOrder(1)
		DbSeek(xFilial("SUS")+M->US_COD+M->US_LOJA)
		RecLock('SUS',.F.)
	EndIF
   
	For nX := 1 TO FCount()
		IF ('FILIAL' $ FieldName(nX) )
			FieldPut(nX,xFilial('SUS'))
		Else
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		EndIF
	Next nX     

	CC3->(DbSetOrder(1))
	IF CC3->(DbSeek(xFilial('CC3')+SUS->US_CNAE))
		Replace US_DCNAE1 With CC3->CC3_DESC
		Replace US_SEGMEN With CC3->CC3_SEGMEN
		Replace US_SUBSEG With CC3->CC3_SUBSEG
	EndIF
	
	MsUnLock()	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Contatos.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(oGetContatos:aCols)
		
		IF oGetContatos:aCols[nX,Len(oGetContatos:aHeader)+1]

			DbSelectArea('SU5')	
			DbSetOrder(1)
			IF	DbSeek( xFilial('SU5') + oGetContatos:aCols[nX,1] ) .And. SU5->U5_APRVOS != '1' // Nao apagar os aprovadores de OS.
				RecLock('SU5',.F.) 
				DbDelete()
				MsUnLock()
			EndIF
		
		Else
			
			IF Empty(oGetContatos:aCols[nX,2]) // Nome Contato
				Loop
			EndIF
					
			IF Empty(oGetContatos:aCols[nX,1]) // Codigo Contato
				oGetContatos:aCols[nX,1] := NewNumCont()
			EndIF
			
			DbSelectArea('SU5')	
			DbSetOrder(1)
			IF !DbSeek( xFilial('SU5') + oGetContatos:aCols[nX,1] )
				RecLock('SU5',.T.)
			Else
				RecLock('SU5',.F.) 
			EndIF
	
			For nZ := 1 To Len(oGetContatos:aHeader)
				IF oGetContatos:aHeader[nZ,10] != 'V'
					FieldPut( FieldPos( oGetContatos:aHeader[nZ,2] ) , oGetContatos:aCols[nX,nZ] )
				EndIF
			Next nZ
			
			SU5->U5_FILIAL  := xFilial("SU5")
			SU5->U5_PROSPEC := SUS->US_COD
			SU5->U5_LOJAPRO := SUS->US_LOJA
			
			MsUnLock()

		DbSelectArea("AC8")
		DbSetOrder(1)
		
			
			DbSelectArea("AC8")
			DbSetOrder(1)
			IF !DbSeek( xFilial("AC8")+SU5->U5_CODCONT+"SUS"+xFilial("SUS")+M->US_COD+M->US_LOJA )
				Reclock("AC8",.T.)
				Replace AC8_FILIAL  With xFilial("AC8")
				Replace AC8_ENTIDA  With "SUS"
				Replace AC8_FILENT  With xFilial("SUS")
				Replace AC8_CODENT	With M->US_COD+M->US_LOJA
				Replace AC8_CODCON	With SU5->U5_CODCONT
				MsUnlock()
			EndIF
	
		EndIF
			
	Next nX

EndIF

IF Len(aRotBKP) > 0
	aRotina := aClone(aRotBKP)
EndIF

RestArea(aAlias)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CRMA01Leg   ºAutor  ³Marcelo Kotaki   º Data ³  04/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legendas do browse de cadastro de Prospect                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CRMA01Leg()

BrwLegenda(cCadastro,'Legenda' ,{ 	{'BR_VERDE'    ,'Cliente'} ,;				// Cliente
									{'BR_AMARELO'  ,'Prospect Contactado'}	,; 	// Prospect Contactado
									{'BR_BRANCO'   ,'Prospect Sem Contato'}}) 	// Prospect Sem Contato

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontaDadosTela³ Autor ³   Alexandro Dias  ³ Data ³ 24/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Momta aCols.                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static  Function MontaDadosTela(nOpc,cEntidade)

Local n1, nX
Local cQuery 	:= ''
Local aAlias	:= GetArea()
Local nRec		:= 0
Local aHedCont	:= {'U5_CODCONT','U5_CONTAT','U5_CELULAR','U5_FCOM1','U5_EMAIL','U5_FUNCAO','U5_DFUNCAO','U5_APRVOS'}

IF Len(aHeaderHist) == 0

	Aadd( aHeaderHist , { 'Usuário'		, 'SY_USER' 	, '@!' 			, 12	, 0 , '' , '' , 'C' , '' , '' , '' , '' , .T. } )
	Aadd( aHeaderHist , { 'Data' 		, 'SY_DATA' 	, '99/99/99' 	, 8 	, 0 , '' , '' , 'D' , '' , '' , '' , '' , .T. } )
	Aadd( aHeaderHist , { 'Hora' 		, 'SY_HORA' 	, '99:99' 		, 5 	, 0 , '' , '' , 'C' , '' , '' , '' , '' , .T. } )
	Aadd( aHeaderHist , { 'Evento'		, 'SY_SITUA'	, '@!' 			, 12 	, 0 , '' , '' , 'C' , '' , '' , '' , '' , .T. } )
	Aadd( aHeaderHist , { 'Proposta'	, 'SY_DESCPRO'	, '@S50!'		, 60 	, 0 , '' , '' , 'C' , '' , '' , '' , '' , .T. } )
	Aadd( aHeaderHist , { 'Historico' 	, 'SY_MEMO' 	, '' 			, 20	, 0 , '' , '' , 'M' , '' , '' , '' , '' , .T. } )

EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega historico do relacionamento.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF nOpc != 3
	DbSelectArea("SUC")
	DbOrderNickName("SUCCLILOJA")
	IF DbSeek(xFilial("SUC")+cEntidade)
	
		While !Eof() .And. xFilial("SUC") == SUC->UC_FILIAL .And. SUC->UC_CLIENTE+SUC->UC_LOJA+SUC->UC_ORIGREG == cEntidade+'SUS'
			Aadd( aGetHist , { Alltrim(UsrRetName(SUC->UC_OPERADO)) , SUC->UC_DATA , SUC->UC_INICIO , Capital(Posicione('SU9',1,xFilial('SU9')+Left(SUC->UC_TIPO,5),'SU9->U9_DESC')) ,SUC->UC_DESCPRO, MSMM(SUC->UC_CODOBS,TamSx3("UC_OBS")[1]) , .F. } )
			DbSkip()
		EndDo
		
	EndIF
EndIF

IF Len(aGetHist) == 0                                      
	Aadd( aGetHist , { '' , Ctod('') , '' , '' , '' , '' , .F. } ) 
EndIF

aSort( aGetHist , , , { |x,y| Dtos(x[2])+x[3] > Dtos(y[2])+y[3] } )

IF Len(aHeaderSU5) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader dos Contatos.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	
	For n1 := 1 To Len(aHedCont)
		
		IF DbSeek( aHedCont[n1] )
			
			AADD(aHeaderSU5,{ 	TRIM(x3titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO,SX3->X3_DECIMAL, SX3->X3_VALID,;
			SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3,SX3->X3_CONTEXT, SX3->X3_CBOX, SX3->X3_RELACAO, SX3->X3_WHEN})
			
		EndIF
	
	Next
	
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra contatos do prospect.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aGetSU5 := {}

IF nOpc != 3
	
	cQuery := " SELECT R_E_C_N_O_ AS SU5_REC "
	cQuery += " FROM " +RetSqlName('SU5') + " SU5 "
	cQuery += " WHERE SU5.U5_FILIAL = '" + xFilial("SU5")	+ "' "
	cQuery += " AND SU5.U5_PROSPEC + SU5.U5_LOJAPRO  = '" + cEntidade + "' "
	cQuery += " AND SU5.D_E_L_E_T_ 	= ' ' "
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
	
	DbSelectArea("TRB")
	DbGoTop()
	While !Eof()
		
		DbSelectArea("SU5")
		DbGoto(TRB->SU5_REC)

		Aadd( aGetSU5 , Array(Len(aHeaderSU5)+1) )
		
		For nX := 1 to Len(aHeaderSU5)
			
			IF ( aHeaderSU5[nX][10] != "V" )
				aGetSU5[Len(aGetSU5)][nX] := FieldGet(FieldPos(aHeaderSU5[nX][2]))
			ElseIF Alltrim(aHeaderSU5[nX][2]) == "U5_DFUNCAO"
				IF !Empty(SU5->U5_FUNCAO)
					aGetSU5[Len(aGetSU5)][nX] := Posicione("SUM",1,xFilial("SUM")+SU5->U5_FUNCAO,"UM_DESC")
				Else
					aGetSU5[Len(aGetSU5)][nX] := ""
				EndIF
			Else
				aGetSU5[Len(aGetSU5)][nX] := CriaVar(aHeaderSU5[nX][2])
			EndIF
			
		Next nX
		
		aGetSU5[Len(aGetSU5),Len(aHeaderSU5)+1] := .F.
		
		DbSelectArea("TRB")
		DbSkip()
		
	EndDo
	TRB->(DbCloseArea())
	
EndIF

IF Len(aGetSU5) == 0
	Aadd( aGetSU5 , Array(Len(aHeaderSU5)+1) )
	For nX := 1 to Len(aHeaderSU5)
		IF ( aHeaderSU5[nX][10] != "V" )
			aGetSU5[Len(aGetSU5)][nX] := CriaVar(aHeaderSU5[nX][2])
		ElseIF Alltrim(aHeaderSU5[nX][2]) == "U5_DFUNCAO"
			aGetSU5[Len(aGetSU5)][nX] := ''
		EndIF
	Next
	aGetSU5[Len(aGetSU5),Len(aHeaderSU5)+1] := .F.
EndIF

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CrmA01Eve   º Autor ³ Alexandro Dias  º Data ³  22/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa eventos.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CrmA01Eve(cEvento,oTelaCRM,cHistorico,cProposta,cAditivo,cNaoPermiteAlt,lOk,bHistAuto)

Local aArea			:= GetArea()
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local dData			:= dDataBase
Local dFecha		:= IIF( Empty(cProposta) , Ctod('')	, M->Z02_PRVFEC)
Local cTermom		:= IIF( Empty(cProposta) , '' 			, M->Z02_TERMOM)
Local cHora			:= '09:00'
Local aPara			:= {}
Local cAssunto		:= ''
Local cMsgHist		:= ''
Local cHistMemo		:= ''
Local aEventos		:= {}
Local cHtml
Local oDlgEventos
Local oListEventos
Local oDlgHist

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle para fechamento da Janela Principal.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lOk := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega status do call center                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SU9->(DbSetOrder(2))
SU9->(DbSeek(xFilial("SU9")))
While !SU9->(Eof()) .And. SU9->U9_FILIAL == xFilial("SU9")
	IF !Empty(SU9->U9_ASSUNTO) .And. SU9->U9_TIPOATE == '1'
		Aadd( aEventos , { .F. , SU9->U9_ASSUNTO , SU9->U9_DESC  } )
	EndIF
	SU9->(DbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Status Atual.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !Empty(cProposta)
	nX := Ascan(aStatusOp,M->Z02_STATUS)
Else
	nX := Ascan(aStatusOp,M->US_STATUS)
EndIF

IF nX > 0 
	cStatusOp := aStatusOp[nX] 
Else
	cStatusOp := aStatusOp[1]
EndIF

DEFINE MSDIALOG oDlgEventos FROM 0,0 TO 590,680 TITLE "Lista de Eventos" Of oMainWnd PIXEL

oDlgEventos:lEscClose := .F.

oFwEventos:= FwLayer():New()
oFwEventos:Init(oDlgEventos,.F.)

oFwEventos:addLine	 	("STATUS"	,015		, .F.																			)
oFwEventos:addCollumn	("COLENT"	,100		, .T. 																, "STATUS"	)
oFwEventos:addWindow	("COLENT"	,"WINENT"	, "Status da Oportunidade: " + cProposta + '-' + cAditivo	, 100		, .T., .T., , "STATUS"	)

oPanelA :=oFwEventos:GetWinPanel("COLENT","WINENT","STATUS")

@ 002,010 MSCOMBOBOX oStatusOp	VAR cStatusOp ITEMS aStatusOp SIZE 120,12 OF oPanelA PIXEL When !(Left(cStatusOp,1) $ cNaoPermiteAlt ) FONT oFnt

oFwEventos:addLine	 	("MEMO"		,045		, .F.										)
oFwEventos:addCollumn	("COLENT"	,100		, .T. 											, "MEMO"	)
oFwEventos:addWindow	("COLENT"	,"WINENT"	, "Informe o Histórico"	, 100		, .T., .T., , "MEMO"	)

oPanelB :=oFwEventos:GetWinPanel("COLENT","WINENT","MEMO")

@ 0,0 GET oHistCli VAR cHistMemo MEMO When .T. OF oPanelB PIXEL FONT oObsTohoma COLOR CLR_WHITE , CLR_BLUE
oHistCli:Align := CONTROL_ALIGN_ALLCLIENT

oFwEventos:addLine	 	("EVENTOS"	,038		, .F.										)
oFwEventos:addCollumn	("COLENT"	,100		, .T. 											, "EVENTOS")
oFwEventos:addWindow	("COLENT"	,"WINENT"	, "Selecione o Evento"	, 100		, .T., .T.,	, "EVENTOS")

oPanelC :=oFwEventos:GetWinPanel("COLENT","WINENT","EVENTOS")

@ 10,10 LISTBOX oListEventos VAR cVar FIELDS HEADER '' , 'Codigo' , 'Eventos' ;
SIZE 230,095 OF oPanelC PIXEL ON DblClick( aEventos[oListEventos:nAt,1] := !aEventos[oListEventos:nAt,1] ,;
	oListEventos:Refresh() ,;
	cEvento := aEventos[oListEventos:nAt,2] ,;
	IIF( ExecAcoes( aEventos[oListEventos:nAt,2],oOk,oNo,@oListEventos,@aEventos,cHistMemo,@lOk,@dData,@cHora,cProposta,cAditivo,@dFecha,@cTermom) , oDlgEventos:End() , .F. ) )

oListEventos:Align:= CONTROL_ALIGN_ALLCLIENT
oListEventos:SetArray( aEventos )
oListEventos:bLine := {|| { IIF(aEventos[oListEventos:nAt,1],oOk,oNo),	aEventos[oListEventos:nAt,2],aEventos[oListEventos:nAt,3]}}

oHistCli:SetFocus()

ACTIVATE MSDIALOG oDlgEventos ON INIT ( EnchoiceBar(oDlgEventos,{|| ( IIf(ValEvento(aEventos),(lOk := .T. , oDlgEventos:End()),'')) }, {|| (oDlgEventos:End()) } ) ) CENTERED

IF lOk

	cHistorico := cHistMemo	
	
	Eval(bHistAuto)
	
	IF !Empty(cProposta)
		M->Z02_STATUS	:= Left(cStatusOp,1)
	Else
		M->US_DTULTCO	:= dDataBase	
		M->US_DTPRXCO 	:= dData
		M->US_HRPRXCO	:= cHora
		M->US_STATUS	:= Left(cStatusOp,1)
	EndIF
		
	IF Alltrim(cEvento) != 'RET' .Or. !Empty(cProposta)
		 
		cHtml:= '<HTML>'
		cHtml+= '<HEAD>'
		cHtml+= '<TITLE>Atualizacao de CRM</TITLE>'
		cHtml+= '<STYLE>'
		cHtml+= 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cHtml+= 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cHtml+= 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cHtml+= 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
		cHtml+= '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
		cHtml+= 'FORM {MARGIN: 0px}'
		cHtml+= '.S_A  {FONT-SIZE: 16px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}'
		cHtml+= '.S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}  '
		cHtml+= '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}  ' 			 
		cHtml+= '.S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}  ' 			 
		cHtml+= '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
		cHtml+= '</STYLE>'
		cHtml+= '</HEAD>'   
		cHtml+= '<BODY>'   
		cHtml+= '<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>'   
		cHtml+= '<TBODY>'
		cHtml+= '<TR><TD CLASS=S_A width="100%"><P align=center><B>Prospecção: ' + M->US_COD+'-'+M->US_LOJA + ' - ' + M->US_NREDUZ	+ '</B></P></TD></TR>'
		
		cHtml+= '</TBODY>'   		
		cHtml+= '</TABLE>'   		
		cHtml+= '<DIV align=center>&nbsp;</DIV>'  		
		cHtml+= '<TABLE style="WIDTH: 100%; HEIGHT: 26px" cellSpacing=0 border=1>' 			
		cHtml+= '<TBODY>'  				

		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Status</B></TD>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>' + cStatusOp +  '</B></TD>'
		cHtml+= '</TR>'

		IF !Empty(cProposta)

			cHtml+= '<TR>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Proposta</B></TD>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>' + cProposta +' - '+ cAditivo + ' ' + Alltrim(M->Z02_DESCRI) +  '</B></TD>'
			cHtml+= '</TR>'

			cHtml+= '<TR>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Valor</B></TD>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>' + Alltrim(Transform(M->Z02_VALOR,'@E 999,999,999')) +  '</B></TD>'
			cHtml+= '</TR>'

			cHtml+= '<TR>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>EAR</B></TD>'  					
			cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>' + Right(M->Z02_VEND2,3) +  '</B></TD>'
			cHtml+= '</TR>'

		EndIF
		
		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Segmento</B></TD>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>'+M->US_SEGMEN+ '</B></TD>'
		cHtml+= '</TR>'

		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_B style="WIDTH: 15%"><B>Data</B></TD>'  					
		cHtml+= '	<TD class=S_B style="WIDTH: 85%"><B>'+Dtoc(dDatabase) + ' - Horario: ' + SubStr(Time(),1,5)+ ' - Proximo Contato: ' + Dtoc(M->US_DTPRXCO) + 'as ' + M->US_HRPRXCO +  '</B></TD>'
		cHtml+= '</TR>'  			

		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Operadora</B></TD>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>'+SubStr(cUsuario,7,15)+ '</B></TD>'
		cHtml+= '</TR>' 
		
		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Situação</B></TD>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>'+Posicione( "SU9" , 1 , xFilial("SU9") + cEvento , "SU9->U9_DESC" )+ '</B></TD>'
		cHtml+= '</TR>' 

		cHtml+= '<TR>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 15%"><B>Detalhe</B></TD>'  					
		cHtml+= '	<TD class=S_D style="WIDTH: 85%"><B>'+ cHistMemo + '</B></TD>'
		cHtml+= '</TR>'  				

		cHtml+= '</TBODY>'  		
		cHtml+= '</TABLE>'
		cHtml+= '</BODY>'
		cHtml+= '</HTML>'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Enviar e-mail com o historico.  		           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
       	aPara := {}
		IF !( 'OPERADOR' $ SyGrpOpe() )
			Aadd( aPara , Lower(Alltrim(UsrRetMail(Posicione('SA3',1,xFilial('SA3')+M->US_VEND,'A3_CODUSR')))) )
		ElseIF 'VENDEDOR' $ SyGrpOpe()
			Aadd( aPara , Lower(Alltrim(UsrRetMail(M->US_OPERADO))) )
		EndIF
		
		cAssunto 	:= "Prospecção: " + M->US_NREDUZ	

		Aadd( aPara , 'jessica.salles@alfaerp.com.br')
		Aadd( aPara , 'liliane.bastos@alfaerp.com.br')
		Aadd( aPara , 'alexandro.dias@alfaerp.com.br' )

		LjMsgRun("Aguarde, enviando historico para Coordenação...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cHtml,.F.,Alltrim(M->US_SEGMEN)) } )

    EndIF
    
    oTelaCRM:End()

EndIF

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ExecAcoes ³ Autor ³   Alexandro Dias     ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa acoes.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExecAcoes(cEvento,oOk,oNo,oListEventos,aEventos,cHistMemo,lOk,dData,cHora,cProposta,cAditivo,dFecha,cTermom)

Local aArea			 	:= GetArea()
Local aSize    		 	:= MsAdvSize()
Local aTermom			:= {'1-Baixa','2-Media','3-Alta'}
Local cTermom			:= ''
Local oTermom			:= ''
Local oData
Local oHora
Local oFecha
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda situacao atual e grava a nova.		       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEvento := Left(cEvento,3)

IF Len(Alltrim(cHistMemo)) <= 0
		
	cMsgHist := 'Por favor, Digitar o histórico da conversa.' + CHR(13)+CHR(10) + CHR(13)+CHR(10)
	cMsgHist += 'Neste campo você deve digitar informações RELEVANTES que CONTRIBUAM no processo de VENDA.'
	MsgAlert(cMsgHist)
	aEventos[oListEventos:nAt,1] := .F.
	oListEventos:Refresh()
	RestArea(aArea)
		
	Return(.F.)
		
EndIF

IF !aEventos[oListEventos:nAt,1]
	RestArea(aArea)
	Return(.F.)
EndIF

SUS->(dbSetOrder(1))
SUS->(dbSeek(xFilial("SUS")+M->US_COD+M->US_LOJA))

IF !MsgYesNo("Executar Ação: " + Alltrim(Capital(Posicione( "SU9" , 1 , xFilial("SU9") + cEvento , "SU9->U9_DESC" ))) + ' ?' )
	aEventos[oListEventos:nAt,1] := .F.
	oListEventos:Refresh()
	RestArea(aArea)
	Return(.F.)
EndIF

IF ('Perdidos' $ cStatusOp) 
	lOk		:= .T.
	dData	:= dDataBase+120
	cHora	:= '09:00'

ElseIF ('Desqualificado' $ cStatusOp)
	lOk		:= .T.
	dData	:= dDataBase+180
	cHora	:= '09:00'

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retornar Ligacao.						           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlgPort TITLE Posicione( "SU9" , 1 , xFilial("SU9") + cEvento , "Alltrim(Capital(SU9->U9_DESC))" ) FROM 0,0 TO 200,500 PIXEL
		
	oDlgPort:lEscClose := .F.
		
	oFwPort:= FwLayer():New()
	oFwPort:Init(oDlgPort,.F.)
	
	oFwPort:addLine	 	("RETORNO"	,070		, .F.										)
	oFwPort:addCollumn	("COLENT"	,100		, .T. 										, "RETORNO"	)
	oFwPort:addWindow	("COLENT"	,"WINENT"	, "Informe a Data de Retorno da Ligação."	, 100		, .T., .T., , "RETORNO")
		
	oPanelR1 :=oFwPort:GetWinPanel("COLENT","WINENT","RETORNO")
		
	@ 007,005 SAY "Data de Retorno: " 	OF oPanelR1 FONT oFntReuniao COLOR CLR_BLUE Pixel SIZE 070,010
	@ 007,130 SAY "Horario: " 			OF oPanelR1 FONT oFntReuniao COLOR CLR_BLUE Pixel SIZE 050,010
	
	@ 006,065 MSGET oData 		VAR dData	OF oPanelR1 PICTURE PesqPict("SUS","US_DTPRXCO") When .T. SIZE 055,010 FONT oFntReuniao PIXEL
	@ 006,180 MSGET oHora 		VAR cHora	OF oPanelR1 PICTURE PesqPict("SUS","US_HRPRXCO") When .T. SIZE 055,010 FONT oFntReuniao PIXEL
		
	IF !Empty(cProposta)
	
		IF Left(cStatusOp,1) == "3" // Em Negociacao
			dFecha := LastDate(dDataBase)
		EndIF
	
		nX	:= Ascan(aTermom,M->Z02_TERMOM)
		IF nX > 0 
			cTermom := aTermom[nX] 
		Else
			cTermom := aTermom[1]
		EndIF
	
		@ 022,005 SAY "Prev.Fechamento: " 	OF oPanelR1 FONT oFntReuniao COLOR CLR_BLUE Pixel SIZE 070,010
		@ 022,130 SAY "Temperatura: "		OF oPanelR1 FONT oFntReuniao COLOR CLR_BLUE Pixel SIZE 050,010
	
		@ 021,065 MSGET 		oFecha 		VAR dFecha	OF oPanelR1 PICTURE PesqPict("SUS","US_DTPRXCO") When .T. SIZE 055,010 FONT oFntReuniao PIXEL
		@ 021,180 MSCOMBOBOX 	oTermom 	VAR cTermom ITEMS aTermom SIZE 055,010 OF oPanelR1 PIXEL FONT oFnt
		
	EndIF
	
	oData:bLostFocus := {|| SyVldData(@dData,@cHora,cEvento,'D',cProposta,cAditivo) }
	oHora:bLostFocus := {|| SyVldData(@dData,@cHora,cEvento,'H',cProposta,cAditivo) }
		
	ACTIVATE MSDIALOG oDlgPort ON INIT ( EnchoiceBar(oDlgPort,{|| IIF( Empty(dData) .Or. Empty(cHora) , MsgAlert('Informe a Data e Horario do Proximo Contato!') , ( lOk := .T. , oDlgPort:End() )  ) } , {|| (lOk := .F. , oDlgPort:End()) } ) ) CENTERED

EndIF

RestArea(aArea)

Return(lOk) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SyOrdCab ³ Autor ³    Alexandro Dias     ³ Data ³ 06/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena ao clicar na coluna da GetDados.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SyOrdCab(nCol,oGetDados,nlOrdemCols,bFuncao)

Local nPos := nCol

Default bFuncao := {||}

IF !lJaExecutou
	
	lJaExecutou := .T.
	
	nlOrdemCols := !nlOrdemCols
	IF nlOrdemCols
		aSort( oGetDados:aCols ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
		aSort( oGetDados:aCols ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
	oGetDados:oBrowse:SetFocus()
	Eval(bFuncao)
	
Else
	lJaExecutou := .F.
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  TmkA01Obs   ³ Autor ³   Alexandro Dias  ³ Data ³ 21/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Chama tela para digitacao do Historico.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TmkA01Obs(cEvento,cHistorico)

Local aArea := GetArea()

IF !Empty(cHistorico)
	
	Aadd( oGetHist:aCols , { Alltrim(UsrRetName(__cUserID)) , dDataBase , Left(Time(),5) , Posicione('SU9',1, xFilial("SU9")+cEvento,'SU9->U9_DESC') , cHistorico , .F. } ) 
	aSort( oGetHist:aCols,,,{ |x,y| Dtos(x[2])+x[3] > Dtos(y[2])+y[3] } )
	cObsTmk := cHistorico 
	oGetHist:Refresh()
	oMemoTmk:Refresh()

EndIF

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SyGravaSYP³ Autor ³   Alexandro Dias      ³ Data ³ 21/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Call Center.                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SyGravaSYP(cHistorico,lGrava,cEntidade,cAlias,cCodAte,cHtml,cEvento,cProposta,cAditivo)

Local cCodigo 		:= GetSxeNum("SUC","UC_CODIGO")
Local cNomeEntidade := ''
Local cSegmento		:= ''

DbSelectArea("SUC")
DbSetOrder(1)

While .T.
	IF ( DbSeek(xFilial('SUC')+cCodigo) )
		ConfirmSx8()
		cCodigo := GetSxeNum("SUC","UC_CODIGO")
   	Else
		Exit
	EndIF
EndDo

IF lGrava .And. !Empty(cHistorico)

	Reclock("SUC",.T.)
	
	Replace UC_FILIAL   With xFilial("SUC")
	Replace UC_CODIGO   With cCodigo 
	Replace UC_CLIENTE  With Left(cEntidade,6)
	Replace UC_LOJA	   	With Right(cEntidade,2)
	Replace UC_OPERADO  With __cUserID
	Replace UC_TIPO     With cEvento
	Replace UC_OPERACA  With "ATIVO"
	Replace UC_DATA     With dDataBase
	Replace UC_INICIO   With Time()
	Replace UC_FIM      With Time()
	Replace UC_PENDENT  With Ctod("")
	Replace UC_HRPEND   With "09:00"
	Replace UC_PROSPEC  With .F.
	Replace UC_DIASDAT  With (CTOD("01/01/2045") - UC_DATA)
	Replace UC_HORADAT  With 86400 - ( (VAL(Substr(UC_INICIO,1,2))*3600) + ( VAL(Substr(UC_INICIO,4,2))*60) + VAL(Substr(UC_INICIO,7,2))  )
	Replace UC_ORIGREG  With cAlias
	IF !Empty(cProposta)
		Replace UC_DESCPRO	With cProposta + '-' + cAditivo + '-' + Alltrim(M->Z02_DESCRI)
	EndIF
	MsUnlock()
	ConfirmSx8()    
	
	IF !Empty(cHistorico)
		MSMM(,TamSx3("UC_OBS")[1],,cHistorico,1,,,"SUC","UC_CODOBS")
	EndIF

	IF Valtype(oMemoTmk) == 'O'
		cObsTmk := cHistorico
		oMemoTmk:Refresh()
	EndIF

EndIF

cHistorico := ''

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SyVldData ³ Autor ³  Alexandro Dias ³ Data ³ 07/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as datas e horarios digitados.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyVldData(dData,cHora,cEvento,cTipo,cProposta,cAditivo)

Local lRet			:= .F.
Local cDescricao 	:= Alltrim(Posicione("SU9",1,xFilial("SU9")+cEvento,"SU9->U9_DESC") )
Local nPrMxRet	 	:= Posicione("SU9",1,xFilial("SU9")+cEvento,"SU9->U9_PRMXRET")

IF !Empty(cProposta)
	IF Left(cStatusOp,1) == '7' //Perdido
		Return(.T.)
	EndIF
EndIF

IF cTipo == 'D'
	
	IF dData < dDataBase
		MsgAlert('Informe uma data IGUAL ou SUPERIOR a data de HOJE.')
		
	ElseIF  ( dData > dDataBase + nPrMxRet ) 				//10
		MsgAlert('A data para [' +cDescricao+ '] deve ser inferior a ' + cValToChar(nPrMxRet) + ' dias.')
	Else
		lRet := .T.
	EndIF
	
ElseIF cTipo == 'H'
	
	IF dData <= dDataBase .And. cHora < Left(Time(),5)
		MsgAlert('Horário Inválido.')
	Else
		lRet := .T.
	EndIF
	
EndIF

IF !lRet
	IF cTipo == 'D'
		dData := Ctod('')
	Else
		cHora := CriaVar("US_HRPRXCO",.F.)
	EndIF
EndIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  SyGrpOpe    ³ Autor ³   Alexandro Dias  ³ Data ³ 24/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Valida se usuario e do grupo CALLCENTER.                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyGrpOpe(cGrupo)

Local aGrupos 	:= UsrRetGrp(UsrRetName(__cUserID))
Local cGrupo	:= ''
Local nX		:= 0

For nX := 1 To Len(aGrupos)
	cGrupo += Alltrim(Upper(GrpRetName(aGrupos[nX]))) + '/'
Next

Return(cGrupo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyTimerPend³ Autor ³  Alexandro Dias   º Data ³  06/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TimeOut para analise de pendencias.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyTimerPend(oDlg)

IF oTimerCrd == NIL
	DEFINE TIMER oTimerCrd INTERVAL 10000 ACTION ( SyMostraPend() ) OF oDlg
	oTimerCrd:Activate()
EndIF

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyTimerPend³ Autor ³  Alexandro Dias   º Data ³  06/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TimeOut para analise de pendencias.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyMostraPend()

Local aArea		:= GetArea()
Local aPend 	:= {}
Local cQuery 	:= ''
Local cHora		:= Left(Time(),5)
Local lOk		:= .F.
Local oDlgPend
Local oPanelA
Local oFwPend
Local oPend
Local oOk
Local oNo
Local cOco		:= ""

IF cHora < cEmExecucaoPend
	Return(Nil)
Else
	cHora := StrZero(Val(Left(cHora,2))+1,2)+SubStr(cHora,3,Len(cHora))
	cEmExecucaoPend := cHora
EndIF

oOk	:= LoadBitMap(GetResources(), "BR_AMARELO")
oNo	:= LoadBitMap(GetResources(), "BR_VERMELHO")

cQuery := " SELECT SUS.R_E_C_N_O_ AS SUS_REC "
cQuery += " FROM " +RetSqlName('SUS') + " SUS "
cQuery += " WHERE SUS.US_FILIAL =	'" + xFilial("SUS")		+"' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra operador ou vendedor.								             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF 'OPERADOR' $ SyGrpOpe()
	cQuery += " AND US_OPERADO = '" +__cUserID+ "' "
ElseIF 'VENDEDOR' $ SyGrpOpe()
	cQuery += " AND US_VEND = '" +Posicione("SA3",7,xFilial("SA3")+__cUserID,"A3_COD")+ "' "
EndIF
cQuery += " AND US_DTPRXCO 	   <>  '' "
cQuery += " AND US_DTPRXCO 	   <= 	'" + Dtos(dDataBase+1)	+"' "
cQuery += " AND SUS.D_E_L_E_T_ 	= 	' ' "
cQuery += " ORDER BY US_DTPRXCO DESC , US_HRPRXCO "
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

TcSetField("TRB", "US_DTPRXCO", "D" , 8 , 0 )

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	
	DbSelectArea("SUS")
	DbGoto(TRB->SUS_REC)
	
	Aadd( aPend , { IIF( Dtos(SUS->US_DTPRXCO) >= Dtos(dDataBase) , .T. , .F. ) ,;
	SUS->US_DTPRXCO 		,;
	SUS->US_HRPRXCO 	,;
	SUS->US_NREDUZ 		,;
	IIF( Len( Alltrim(SUS->US_TEL) ) == 8 , TransForm(Alltrim(SUS->US_TEL),'@R 9999-9999') , TransForm(Alltrim(SUS->US_TEL),'@R 99-9999-9999')) ,;
	'' ,;
	SUS->US_COD+SUS->US_LOJA ,;
	TRB->SUS_REC,;
	'' } )
	
	DbSelectArea("TRB")
	DbSkip()
	
EndDo
TRB->(DbCloseArea())

If Len(aPend)==0
	RestArea(aArea)
	Return(Nil)
Endif

DEFINE MSDIALOG oDlgPend FROM 0,0 TO 450,720 TITLE "Pendencias" Of oMainWnd PIXEL

oDlgPend:lEscClose := .F.

oFwPend:= FwLayer():New()
oFwPend:Init(oDlgPend,.F.)

oFwPend:addLine	 	("PENDENCIAS"	,090		, .F.										)
oFwPend:addCollumn	("COLENT"		,100		, .T. 											 , "PENDENCIAS")
oFwPend:addWindow	("COLENT"		,"WINENT"	, "Você Possui [" +Alltrim(Str(Len(aPend)))+ "] Pendências para Retornar", 100		, .T., .T., , "PENDENCIAS")

oPanelA :=oFwPend:GetWinPanel("COLENT","WINENT","PENDENCIAS")

@ 10,10 LISTBOX oPend VAR cVar FIELDS HEADER '' , 'Dt Retorno' , 'Hora' , 'Prospect' , 'Telefone' , 'Ocorrencia' ,'Codigo' , 'Recno','Cod.Ocorrencia';
SIZE 230,095 OF oPanelA PIXEL ON DblClick( SUS->(DbGoto(aPend[oPend:nAt,8])) , U_CRMA01Cal('SUS',aPend[oPend:nAt,8],4) )
oPend:Align:= CONTROL_ALIGN_ALLCLIENT
oPend:SetArray( aPend )
oPend:bLine := {|| { IIF(aPend[oPend:nAt,1],oOk,oNo),aPend[oPend:nAt,2],aPend[oPend:nAt,3],aPend[oPend:nAt,4],aPend[oPend:nAt,5],aPend[oPend:nAt,6],aPend[oPend:nAt,7],aPend[oPend:nAt,8],aPend[oPend:nAt,9]}}

ACTIVATE MSDIALOG oDlgPend ON INIT ( EnchoiceBar(oDlgPend,{|| ( lOk := .T. , cOco:= aPend[oPend:nAt,9], oDlgPend:End()) }, {|| (oDlgPend:End()) } ) ) CENTERED

RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValEvento ³ Autor ³   Alexandro Dias      ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do evento.                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValEvento(aEventos)

Local nI  := 0
Local lRet:= .F.

For nI:= 1 TO Len(aEventos)
	If aEventos[nI,1]
		lRet:= .T.
		Exit
	EndIf
Next nI

If !lRet
	Aviso("Atencao","Selecione um evento para registrar ao historico do cliente.",{"Ok"})
EndIf       

Return(lRet)          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Sy260CGC ³ Autor ³   Alexandro Dias      ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do CPF/CNPJ do Prospect.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Sy260CGC(cCgc)

Local aArea	:= GetArea()
Local lRet	:= .T.

Default cCgc	:= M->US_CGC

If (AllTrim(M->US_TPESSOA) == "PF") .And. (AllTrim(cCGC) == "0")
	lRet:= .T.
ElseIf !Empty(cCgc)
	lRet := (CGC(cCgc) .AND.;
			Existchav("SUS",cCgc,4,"US_CGC") .AND.;
			FreeForUse("SUS",cCgc) .AND.;
			TmkVeEnt(cCgc,"SUS"))
EndIf

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SU5LINOK ºAutor  ³Microsiga           º Data ³  08/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida contatos.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SU5LINOK()

Local nPNome   	:= aScan(oGetContatos:aHeader,{|x| AllTrim(x[2]) == 'U5_CONTAT'} )
Local lRet		:= .T.

IF Empty(oGetContatos:aCols[oGetContatos:nAt,nPNome])
	Help("",1,"Atenção",,"Informe o nome do Contato.",1,1)
	lRet := .F.
EndIF

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SyCRMMail ³ Autor ³ Vendas e CRM          ³ Data ³ 26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para o envio de emails                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyCRMMail(aPara,cAssunto,cHtml,lAttach,cSegmento)

Local cHtml,nX
Local aArea     	:= GetArea()
Local lResult   	:= .F.								// Se a conexao com o SMPT esta ok
Local lRet	   		:= .F.								// Se tem autorizacao para o envio de e-mail
Local lRelauth  	:= SuperGetMv("MV_RELAUTH",, .F.)	// Parametro que indica se existe autenticacao no e-mail
Local cContato		:= 'Prezado(a)'
Local cDir 			:= '\workflow\segmentos\'
Local cServer   	:= Alltrim(GetMV('MV_RELSERV')) 	// Ex.: smtp.ig.com.br ou 200.181.100.51
Local cCtaAut   	:= Alltrim(GetMV('MV_RELAUSR')) 	// usuario para Autenticacao Ex.: fuladetal
Local cConta    	:= Alltrim(GetMV('MV_RELAUSR'))
Local cPsw      	:= Alltrim(GetMV('MV_RELPSW'))		// Senha de acesso Ex.: 123abc
Local cFrom			:= cConta
Local cEmailTo  	:= ''								// E-mail de destino
Local cEmailBcc 	:= '' 								// E-mail de copia
Local cError    	:= ''								// String de erro
Local cEmail		:= ''
Local cAttach		:= ''
Local nCntFor

Default cAttach := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remonta os destinatarios utilizando o vetor.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEmail := ''
For nCntFor := 1 To Len(aPara)
	If !Empty(cEmail)
		cEmail += ';'
	EndIf
	cEmail += aPara[nCntFor]
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem anexo.				                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lAttach

	IF !Empty(cSegmento)
	
		aDirectory := Directory( cDir + '*.PDF')
		
		For nX := 1 To Len(aDirectory)
			
			IF Upper(Substr(cHtml,1,Len(cHtml)-5)) $ Upper(aDirectory[nX,1])
				cAttach += cDir + aDirectory[nX,1] + IIF(nX < Len(aDirectory) , ',' , '')
			EndIF
			 
	    Next
		
	Else
			
		cAttach := cDir + 'TOTVS - Software de Gestão.pdf,' 
			
		aDirectory := Directory( cDir + 'Institucional*.PDF')
		
		For nX := 1 To Len(aDirectory)
		
			IF Upper(Substr(cHtml,1,Len(cHtml)-4)) $ Upper(aDirectory[nX,1])
				cAttach += cDir + aDirectory[nX,1] + IIF(nX < Len(aDirectory) , ',' , '')
			EndIF
		 
	   	Next
		
	EndIF

EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata mensagem de envio.			            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ( ".HTML" $ cHtml )
	cHtml := SymmMsg(cContato,cHtml)
	IF Empty(cHtml)
		MsgAlert('Arquivo HTML sem conteudo.')
		Return(.F.)
	EndIF
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEmailTo := cEmail

lRet := TkSendMail(cConta,cPsw,cServer,cConta,cEmailTo,cAssunto,cHtml,cAttach)

/*
CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

// Se a conexao com o SMPT esta ok
If lResult

	// Se existe autenticacao para envio valida pela funcao MAILAUTH
	If lRelauth
		lRet := Mailauth( cCtaAut, cPsw )
	Else
		lRet := .T.	
    Endif    

	If lRet
		
		SEND MAIL; 
		FROM 		cFrom;
		TO      	cEmailTo;
		BCC     	cEmailBcc;
		SUBJECT 	cAssunto;
		BODY    	cHtml;
		ATTACHMENT  cAttach;
		RESULT 		lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Help(" ",1,'Erro',,cError+ " " + cEmailTo,4,5)	//Atenção
		Endif

	Else
		GET MAIL ERROR cError
		Help(" ",1,'Erro de autenticação, Verifique a conta e a senha para envio',,cError,4,5)
	Endif
		
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	Help(" ",1,'Atencao',,cError,4,5)
Endifadmin
*/

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  SYMMMSG     ³ Autor ³  Alexandro Dias  ³ Data ³ 04/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Leitura do Html do e-mail.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SymmMsg(cContato,cArqHtml)

Local nTamArq 	:= 0
Local nBytes 	:= 0
Local nFim   	:= 0
Local cHtml  	:= ''
Local cBuffer   := ''
Local nHandle 	:= FT_FUSE("\WORKFLOW\SEGMENTOS\"+cArqHtml)
Local cEOL    	:= 'CHR(13)+CHR(10)'

If nHandle == -1
	Tone(200,26)
	MsgAlert("O arquivo de nome "+cArqHtml+" nao pode ser aberto! Verifique os parametros.","Atenção!")
	Return(cHtml)
EndIF

FT_FGOTOP()        	

While ! FT_FEOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura da linha do arquivo texto.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBuffer := FT_FREADLN()
	
	IF !Empty(cBuffer)
		
		IF "NOME" $ cBuffer
			
			IF At(" ",cContato) > 0
				cContato := Subst( cContato , 1 , At( " " , cContato ) ) 
			EndIF 
			
			cBuffer := StrTran( cBuffer , 'NOME' , '<strong>'+Capital(Alltrim(cContato))+'</strong>' )
			cHtml 	+= cBuffer
				
		Else
		
			cHtml += cBuffer
		
		EndIF
	
	EndIF
	
	FT_FSKIP(1)
	
EndDo

FClose(nHandle)

Return(cHtml)

User Function CRMAIncAlt(cAlias,nReg,nOpc)

Local nRet := 0

IF nOpc == 3
	nRet :=	AxInclui('SUS',SUS->(Recno()),nOpc, /*aCposExiber*/,,/*aCposAlterar*/,/*"U_TudoOk()"*/,,,,,,,.T.,,,,,)

ElseIF nOpc == 4
	nRet :=	AxAltera('SUS',SUS->(Recno()),nOpc, /*aCposExiber*/,,/*aCposAlterar*/,/*"U_TudoOk()"*/,,,,,,,.T.,,,,,)

ElseIF nOpc == 5
	IF SUS->US_STATUS == '6'
		MsgAlert('Não é permitido Excluir Clientes.')
	Else
		nRet :=	AxDeleta('SUS',SUS->(Recno()),nOpc, /*aCposExiber*/,,/*aCposAlterar*/,/*"U_TudoOk()"*/,,,,,,,.T.,,,,,)
	EndIF
EndIF

IF nRet == 1 .And. nOpc <> 5
	U_CRMA01Cal(cAlias,nReg,nOpc,'','','')
EndIF	

Return(.T.)
