#Include "PrConst.ch"
#Include "Protheus.ch"      

#Define CRLF Chr(10)+Chr(13)

#Define DTFECHAMENTO 10

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ShowGrfVdaº Autor ³ Fabio Rogerio      º Data ³  20/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chama grafico dos indicadores de Vendas.					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ShowGrfVda()

Local aAlias 		:= GetArea()
Local bAtuFolder 	:= {|| AtuFolder(@oPanelOpor,@oGetOp,@aHeaderOp,@aColsOp,aStatus,Left(cStatusOp,1),Left(cVendaTp,1),aTermom,cVendCombo,@nlOrdemCols,cProposPsq,cClientePsq,@aAlter,@dDtIni,@dDtFim,@bAtuClientes,cBaseNovos) }
Local bAtuClientes 	:= {|| ListaClientes(@oPanelCli,@oGetCli,@aHeaderCli,@aColsCli,cVendCombo,@nlOrdemCols,Left(cVendaTp,1),dDtIni,dDtFim) }
Local aSize			:= MsAdvSize()
Local nI			:= 0
Local nX			:= 0	
Local aButtons		:= {}
Local aGrp			:= UsrRetGrp(UsrRetName(__cUserID))
Local aGroups     	:= AllGroups()                                                     
Local aStatus	 	:= {,,,,,,,,,,}
Local oResumo		:= {,,,,,,,,,,,,,,,}
Local aTermom		:= {,,}
Local cGrp			:= ''
Local aCampos		:= {}
Local aAlter 		:= {}
Local aHeaderOp		:= {}
Local aColsOp		:= {}
Local aHeaderCli	:= {}
Local aColsCli		:= {}
Local cVendCombo	:= 'TODOS'
Local aVendCombo	:= {}
Local oVendCombo
Local cStatusOp		:= '3-Em Negociação'
Local aStatusOp    	:= {}
Local oStatusOp
Local cVendaTp		:= 'TODOS'
Local aTpVenda    	:= {}
Local cBaseNovos	:= 'TODOS'
Local aBaseNovos    := {}
Local oBaseNovos
Local oTpVenda
Local oProposPsq
Local cProposPsq	:= CriaVar("Z02_PROPOS",.F.) 
Local oClientePsq
Local cClientePsq	:= CriaVar("Z02_RAZAO",.F.)
Local oDtIni
Local oDtFim
Local dDtIni 		:= Ctod('01/01/'+StrZero(Year(dDataBase),4))
Local dDtFim		:= Ctod('31/12/'+StrZero(Year(dDataBase),4))
Local oShowInd
Local oPnlMaster
Local oFolder
Local oGetOp
Local oGetCli
Local oScroll
Local oFntFolder 
Local oFnt 
Local oFntTit
Local cGrpCtr := ''
Local oFolderPai
Local oFolderFilho
Local oPanelOpor
Local oPanelCli

Private oVlrServico
Private nVlrServico	:= 0

Private oVlrSaaS
Private nVlrSaaS   	:= 0       

Private oVlrNetSAP
Private nVlrNetSAP	:= 0

Private oVlrMSaaS
Private nVlrMSaaS  	:= 0

Private oVlrOnPremise
Private nVlrOnPremise := 0

Private oVlrSetup
Private nVlrSetup 	:= 0

Private oVlrAMS
Private nVlrAMS 	:= 0

Private oVlrTotAMS
Private nVlrTOtAMS 	:= 0

Private lAdm 		:= .F.
Private cCadastro 	:= ''

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

DEFINE FONT oFnt 		NAME "Courier New" SIZE 0,-14 BOLD 
DEFINE FONT oFntTit		NAME "Courier New" SIZE 0,-22 BOLD

aTermom[1] := LoadBitmap(GetResources(), 'S4WB014A'		)	// Sem previsao
aTermom[2] := LoadBitmap(GetResources(), 'CLOCK01' 		)	// Previsao Furada
aTermom[3] := LoadBitmap(GetResources(), 'LJPRECO'		)	// Fechamento no Mes

aStatus[1]  := LoadBitmap(GetResources(), 'BR_BRANCO'	)	// Lead
aStatus[2]  := LoadBitmap(GetResources(), 'BR_PINK' 		)	// Desqualificado
aStatus[3]  := LoadBitmap(GetResources(), 'BR_AMARELO'	)	// Em Negociacao
aStatus[4]  := LoadBitmap(GetResources(), 'BR_AMARELO'	)	// 
aStatus[5]  := LoadBitmap(GetResources(), 'BR_VERDE'		)	// Aprovado
aStatus[6]  := LoadBitmap(GetResources(), 'BR_CINZA'		)	// Suspenso
aStatus[7]  := LoadBitmap(GetResources(), 'BR_VERMELHO'	)	// Perdido
aStatus[8]  := LoadBitmap(GetResources(), 'BR_VERMELHO'	)	// Limpeza
aStatus[9]  := LoadBitmap(GetResources(), 'BR_VERDE' 	)   // Gerou Projeto
aStatus[10] := LoadBitmap(GetResources(), 'BR_VERMELHO' )   // Cancelado
aStatus[11] := LoadBitmap(GetResources(), 'BR_MARROM' 	)   // Encerrado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra grupos.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI:= 1 To Len(aGroups)
	IF 	(AllTrim(Upper((aGroups[nI,1,2]))) == "ADMINISTRADORES") .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "PMO")  .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "COORDENACAO_COMERCIAL") 
		cGrp+= aGroups[nI,1,1] + "/"
	EndIF
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario pertence ao grupo de administradores.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" )
	lAdm := .T.

ElseIF !Empty(cGrp)
	For nI:= 1 To Len(aGrp)
		If aGrp[nI] $ cGrp
			lAdm:= .T.
		EndIf
	Next nI
EndIF 

cVendCombo := IIF( lAdm , 'TODOS' , Posicione('SA3',7,xFilial('SA3')+__cUserID,'A3_COD') )
cGrpCtr:= If(lAdm,'ADM','VEND')

IF !lAdm .And. Empty(cVendCombo)
	MsgAlert('Opção Não Permitida. O seu Usuário não esta Associado a nenhum Vendedor.')
	Return(.T.)
EndIF

IF ( cVendCombo != 'TODOS' )
	
	Aadd( aVendCombo , Posicione('SA3',7,xFilial('SA3')+__cUserID,'A3_COD') +'-'+ Posicione('SA3',7,xFilial('SA3')+__cUserID,'A3_NOME') ) 
	cVendCombo := aVendCombo[1]
	
Else

	Aadd( aVendCombo , 'TODOS' ) 
	SA3->(DbGoTop())
	While SA3->(!Eof())
		IF SA3->A3_MSBLQL <> '1'
			Aadd( aVendCombo , SA3->A3_COD+'-'+SA3->A3_NOME ) 
		EndIF
		SA3->(DbSkip())
	EndDo

EndIF

Aadd( aStatusOp , 'TODOS' )
Aadd( aStatusOp , '3-Em Negociacao' )
Aadd( aStatusOp , '5-Aprovados' )
Aadd( aStatusOp , '6-Suspensos' )
Aadd( aStatusOp , '7-Perdidos' )
Aadd( aStatusOp , 'C-Cancelado' ) 
Aadd( aStatusOp , 'E-Encerrado' ) 

Aadd( aTpVenda , 'TODOS' )
Aadd( aTpVenda , 'V-TOTVS (Todos)' )
Aadd( aTpVenda , '1-TOTVS (Servicos)' )
Aadd( aTpVenda , 'S-SAP (Todos)' )
Aadd( aTpVenda , '3-SAP (Cloud)' )
Aadd( aTpVenda , '4-SAP (OnPremise)' )
Aadd( aTpVenda , '5-SAP (Servicos)' )
Aadd( aTpVenda , '8-TOTVS (Licencas)' )

Aadd( aBaseNovos , 'TODOS' )
Aadd( aBaseNovos , 'B-Base' )
Aadd( aBaseNovos , 'N-Novos' )

aCampos 	:= {'Z02_OK','Z02_STATUS','Z02_OK2','Z02_DATAOP','Z02_DTAPRO','Z02_PROPOS','Z02_ADITIV','Z02_RAZAO','Z02_DESCRI','Z02_VLRSER','Z02_VLRSET','Z02_MENSAS','Z02_VLRSAS','Z02_MENSUP','Z02_VLRAMS','Z02_VLRONP','Z02_MNTONP','Z02_DOLAR','Z02_NETSAP','Z02_VEND2','A3_NREDUZ','Z02_ORIGEM','Z02_PROJET','Z02_VLHORA','Z02_VLCOOR','Z02_HRPROJ','Z02_DTCANC','Z02_DTENCE','Z02_TPFAT','Z02_TIPO'} 
aAlter 		:= {'Z02_VEND2','Z02_RAZAO','Z02_DESCRI'}

IF lAdm
	Aadd(aAlter,'Z02_DTAPRO')
	Aadd(aAlter,'Z02_DOLAR')
EndIF

DbSelectArea("SX3")
DbSetorder(2)
For nX := 1 To Len(aCampos)

	IF aCampos[nX] == 'Z02_OK'
		Aadd(aHeaderOp,{"","Z02_OK"	,"@BMP",02,0,".F.","û","C","","V","","" } )	

	ElseIF aCampos[nX] == 'Z02_OK2'
		Aadd(aHeaderOp,{"Docs?","Z02_OK2","@BMP",02,0,".F.","û","C","","V","","" } )	

	Else
		MsSeek(aCampos[nX])
		Aadd( aHeaderOp , { AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO } )
	
	EndIF

	IF aCampos[nX] $ 'Z02_VLRSER/Z02_VLRSET/Z02_MENSAS/Z02_VLRSAS/Z02_VLRONP/Z02_MNTONP/Z02_VLRAMS/Z02_MENSUP'
		aHeaderOp[Len(aHeaderOp),3]	:= '@E 9,999,999,999'	
	ElseIF aCampos[nX] == 'A3_NREDUZ'
		aHeaderOp[Len(aHeaderOp),3]	:= '@!'
		aHeaderOp[Len(aHeaderOp),4]	:= 12
	ElseIF aCampos[nX] == 'Z02_RAZAO'    
		aHeaderOp[Len(aHeaderOp),3]	:= '@!'
		aHeaderOp[Len(aHeaderOp),4]	:= 15
	ElseIF aCampos[nX] == 'Z02_DESCRI'
		aHeaderOp[Len(aHeaderOp),3]	:= '@!'
		aHeaderOp[Len(aHeaderOp),4]	:= 20
	EndIF
	
Next

Aadd(aHeaderOp,{"","XXX","@!"	,02,0,".F.","û","C","","V","","" } )

Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(2,oGetOp) }					, "Proposta-Visualizar"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(3,oGetOp),Eval(bAtuFolder) }	, "Proposta-Incluir"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(4,oGetOp),Eval(bAtuFolder) }	, "Proposta-Alterar"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(5,oGetOp),Eval(bAtuFolder) }	, "Proposta-Excluir"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(6,oGetOp),Eval(bAtuFolder) }	, "Proposta-Copiar"				} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(7,oGetOp),Eval(bAtuFolder) }	, "Proposta-Aditivo de Contrato"} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(8,oGetOp) }					, "Proposta-Imprimir"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(9,oGetOp),Eval(bAtuFolder) }	, "Proposta-Aprovar"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(10,oGetOp),Eval(bAtuFolder) }, "Proposta-Cancelar Aprovacao"	} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(11,oGetOp),Eval(bAtuFolder) }, "Proposta-Gerar Projeto"		} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(12,oGetOp),Eval(bAtuFolder) }, "Proposta-Follow-up"			} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(15,oGetOp),Eval(bAtuFolder) }, "Proposta-Encerrar Contrato"	} )
Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(16,oGetOp),Eval(bAtuFolder) }, "Proposta-Cancelar Contrato"	} )

//Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(18,oGetOp),Eval(bAtuFolder) }, "Propsota-HANDOVER "	} )

//Aadd(aButtons,	{ ''	 	, "U_AF02HANDOVER()" 	 	, 0 , 	01,,.F. })
IF lAdm

	//Aadd(aButtons  , { 'SOLICITA' 		, {|| U_AFZ02TELA() }  							, "Extrair Tela"		  			} )

	Aadd(aButtons  , { 'PRECO' 			, {|| MntPropostas(13,oGetOp),Eval(bAtuFolder) }				, "Proposta-Aprovar Comissoes"	} )
	Aadd(aButtons  , { 'SOLICITA' 		, {|| MntPropostas(14,oGetOp),Eval(bAtuFolder)} 				, "Visualizar Reajustes de Valores do Cliente"} )
	Aadd(aButtons  , { 'SOLICITA' 		, {|| U_AtuBaseNovos() } 	 									, "Base ou Novos"				} )	
	Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_SyExporExcel(oFolderPai:aDialogs[oFolderPai:nOption]:cCaption,aHeaderOp,aColsOp,.F.) } 	, "Exportar Op"			} )
	Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_SyExporExcel(oFolderPai:aDialogs[oFolderPai:nOption]:cCaption,aHeaderCli,aColsCli,.F.) } 	, "Exportar Clientes"	} )
	Aadd(aButtons  , { 'SOLICITA' 		, {|| MATA040() } 	 											, "Vendedores" 				} )
	Aadd(aButtons  , { 'SOLICITA' 		, {|| U_AF02AtuCustos(4,oGetOp),Eval(bAtuFolder)  } 		 	, "Atualizar Custo"			} )	
	Aadd(aButtons  , { 'SOLICITA' 		, {|| U_SYMMSZF()  									} 		 	, "Metas"					} )	
	Aadd(aButtons  , { 'SOLICITA' 		, {|| MntPropostas(99,oGetOp),Eval(bAtuFolder)}  				, "e-Mail"					} )
	Aadd(aButtons  , { 'SOLICITA' 		, {|| MntPropostas(95,oGetOp),Eval(bAtuFolder)}  				, "Ajusta Contratos"					} )
EndIF
Aadd(aButtons  , { 'SOLICITA' 		, {|| MntPropostas(17,oGetOp),Eval(bAtuFolder)}  				, "Contratos-Visualizar"					} )
Aadd(aButtons  , { PmsBExcel()[1]	, {|| U_AFZ00_MVC() } 							, "Módulos"						} )
Aadd(aButtons  , { 'SOLICITA' 		, {|| U_SYFINA01() }  							, "Conf.Fornecedores"  			} ) 
Aadd(aButtons  , { 'SOLICITA' 		, {|| U_SYCRMA01() }  							, "Relacionamento"  			} ) 
Aadd(aButtons  , { 'SOLICITA' 		, {|| U_SYCADDESP() }  							, "Despesas"		  			} )
Aadd(aButtons  , { 'SOLICITA' 		, {|| PMSA200() }  								, "Projetos - Cadastro"		  			} )

//Aadd(aButtons  , { 'SOLICITA' 		, {|| U_ALFART01() }  							, "Projetos - Artia"		  			} )
Aadd(aButtons  , { 'SOLICITA' 		, {|| U_ALFOFC01() }  							, "Projetos - PSOffice"		  			} )
Aadd(aButtons  , { 'SOLICITA' 		, {|| U_ALFPMS70(cGrpCtr) }  					, "Cad.Contratos"		  			} )



DEFINE MSDIALOG oShowInd FROM aSize[7],0 To aSize[6]-10,aSize[5] TITLE "Indicadores de Desempenho: " + cVendCombo Of oMainWnd COLORS 0, 16777215 PIXEL STYLE WS_VISIBLE

oShowInd:lEscClose	:= .F.
oShowInd:lMaximized	:= .T.

oPnlMaster:= TPanel():New(0, 0, "", oShowInd, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPnlMaster:Align:= CONTROL_ALIGN_ALLCLIENT

oResumo:= TPanel():New(0, 0, '', oPnlMaster, NIL, .T., .F., NIL, NIL, 0,52, .T., .F. )
oResumo:Align 	:= CONTROL_ALIGN_TOP
oResumo:nClrPane	:= Rgb(255,255,255)   

@ 002,005 MSCOMBOBOX oVendCombo	VAR cVendCombo	ITEMS aVendCombo 	SIZE 120, 12 OF oResumo PIXEL When .T. ON CHANGE Eval(bAtuFolder)	

@ 014,005 MSCOMBOBOX oStatusOp	VAR cStatusOp	ITEMS aStatusOp		SIZE 120, 12 OF oResumo PIXEL When .T. ON CHANGE Eval(bAtuFolder)	

@ 027,005 MSCOMBOBOX oTpVenda	VAR cVendaTp	ITEMS aTpVenda		SIZE 120, 12 OF oResumo PIXEL When .T. ON CHANGE Eval(bAtuFolder)

@ 040,005 MSCOMBOBOX oBaseNovos	VAR cBaseNovos	ITEMS aBaseNovos	SIZE 120, 12 OF oResumo PIXEL When .T. ON CHANGE Eval(bAtuFolder)

oProposPsq  := TGet():New(002,130,bSetGet(cProposPsq) ,oResumo,050,012,X3Picture('Z02_PROPOS'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Proposta:",2,,CLR_BLUE,"Digite...")
oProposPsq:bChange := {|| cClientePsq := CriaVar("Z02_RAZAO",.F.), oProposPsq:Refresh() , Eval(bAtuFolder) } 

oClientePsq := TGet():New(015,130,bSetGet(cClientePsq),oResumo,050,012,X3Picture('Z02_RAZAO') ,,,,,,,.T.,,,,,,,,,,,,,,,,,"ou Cliente:",2,,CLR_BLUE,"Digite...")
oClientePsq:bChange := {|| cProposPsq := CriaVar("Z02_PROPOS",.F.) , oClientePsq:Refresh() , Eval(bAtuFolder) } 

oDtIni  		:= TGet():New(030,130,bSetGet(dDtIni) ,oResumo,045,012,X3Picture('Z02_DTAPROV'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Data De: "	,2,,CLR_BLUE,"Digite...")
oDtIni:bChange := {|| Eval(bAtuFolder) } 

oDtFim  		:= TGet():New(030,200,bSetGet(dDtFim) ,oResumo,045,012,X3Picture('Z02_DTAPROV'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Até:"		,2,,CLR_BLUE,"Digite...")
oDtFim:bChange := {|| Eval(bAtuFolder) } 

oSayTotal		:= TSay():New(002,270,{|| 'Serviço:'}		,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,050,11)
oSaySetup		:= TSay():New(012,270,{|| 'Setup:' }		,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,080,11)
oSayMSaaS		:= TSay():New(022,270,{|| 'Assinatura:' }	,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,050,11)
oSaySaaS		:= TSay():New(032,270,{|| 'Total SaaS:' }	,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,050,11)

@ 002,300 SAY oVlrServico	VAR	Transform(nVlrServico	,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 012,300 SAY oVlrSetup		VAR	Transform(nVlrSetup		,'@E 999,999,999,999') 	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 022,300 SAY oVlrMSaaS		VAR	Transform(nVlrMSaaS		,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 032,300 SAY oVlrSaaS		VAR	Transform(nVlrSaaS		,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12

oSayOnPremise	:= TSay():New(002,380,{|| 'OnPremise:' }	,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,080,11)
oSayAMS			:= TSay():New(012,380,{|| 'Suporte:' }		,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,080,11)
oSayTotAMS		:= TSay():New(022,380,{|| 'Total Suporte:'} ,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,080,11)
oSayNetSAP		:= TSay():New(032,380,{|| 'NET SAP:' 	}	,oResumo,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,080,11)

@ 002,430 SAY oVlrOnPremise	VAR	Transform(nVlrOnPremise	,'@E 999,999,999,999') 	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 012,430 SAY oVlrAMS		VAR	Transform(nVlrAMS		,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 022,430 SAY oVlrTotAMS	VAR	Transform(nVlrTotAMS	,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12
@ 032,430 SAY oVlrNetSAP	VAR	Transform(nVlrNetSAP	,'@E 999,999,999,999')	OF oResumo FONT oFnt COLOR CLR_BLUE 	Pixel SIZE 060,12

oFolderPai := TFolder():New(0,0,{'Dashboard','Oportunidades'},,oPnlMaster,,,,.T.,.F.,0,0)
oFolderPai:Align := CONTROL_ALIGN_ALLCLIENT

oFolderFilho := TFolder():New(0,0,{'Metas x Realizado','Ranking de Vendas','Base x Novos','Ranking de Clientes','Ranking de Fornecedores'},,oFolderPai:aDialogs[1],,,,.T.,.F.,0,0)
oFolderFilho:Align := CONTROL_ALIGN_ALLCLIENT
	
oPanelCli := TPanel():New(0, 0,'',oFolderFilho:aDialogs[4],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelCli:Align := CONTROL_ALIGN_ALLCLIENT

oPanelOpor := TPanel():New(0, 0,'',oFolderPai:aDialogs[2],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelOpor:Align := CONTROL_ALIGN_ALLCLIENT

TButton():New( 002 , 510 , "Incluir Lead"	,oResumo,{|| MntPropostas(97,oGetOp,oFolderFilho) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 016 , 510 , "Alterar Lead"	,oResumo,{|| MntPropostas(98,oGetOp,oFolderFilho) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

TBtnBmp2():New( 070 ,1020, 025, 025,"S4WB013N"	,,,,{|| Processa( {|| PreparaDadosGrf(oFolderFilho,cVendCombo,dDtIni,dDtFim,Left(cVendaTp,1)) }, "Preparando Dados para Graficos..." ) },oResumo,"Atualiza Graficos",,.T. )
TBtnBmp2():New( 070 ,1060, 025, 025,"PEDIDO"	,,,,{|| U_SyDocument( "Z02",'',2,1,@oGetOp) },oResumo,"Documentações da Proposta",,.T. )

Eval(bAtuFolder)

Processa( {|| PreparaDadosGrf(oFolderFilho,cVendCombo,dDtIni,dDtFim,cVendaTp) }, "Preparando Dados para Graficos..." )

ACTIVATE MSDIALOG oShowInd ON INIT ( EnchoiceBar(oShowInd,{|| oShowInd:End() } , {|| oShowInd:End() },,aButtons) )

Return(.T.)

Static Function AtuFolder(oPanelOpor,oGetOp,aHeaderOp,aColsOp,aStatus,cStatus,cVenda,aTermom,cVendCombo,nlOrdemCols,cProposPsq,cClientePsq,aAlter,dDtIni,dDtFim,bAtuClientes,cBaseNovos)

Local aArea			:= GetArea()
Local cResto		:= ''
Local cQuery		:= ''
Local nX

nVlrServico		:= 0
nVlrSetup 		:= 0
nVlrMSaaS		:= 0
nVlrSaaS   		:= 0   
nVlrAMS         := 0    
nVlrTotAMS      := 0    
nVlrNetSAP		:= 0
nVlrOnPremise 	:= 0

aColsOp 	:= {}

cQry := " UPDATE Z02010 SET Z02_DOCOK = '2' WHERE D_E_L_E_T_ = '' "
TcSqlExec(cQry)

cQry := " UPDATE Z02010 SET Z02_DOCOK = '1' FROM "
cQry += "	( 	SELECT AC9_CODENT FROM AC9010 AC9 "
cQry += "   	WHERE "
cQry += " 		AC9_ENTIDA = 'Z02' AND "
cQry += "   	AC9.D_E_L_E_T_ = '' "
cQry += "   	GROUP BY AC9_CODENT "
cQry += "	) AS TAB "
cQry += " WHERE Z02_PROPOS+Z02_ADITIV = AC9_CODENT AND "
cQry += " D_E_L_E_T_ = '' "
TcSqlExec(cQry)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Ajusta o calculo dos campos totais da proposta
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Ajusta o valor total de servicos
cQry := " UPDATE Z02010 SET Z02_VLRSER = X.TOTAL"
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN (SELECT Z02_PROPOS AS PROPOSTA, Z02_ADITIV ADITIVO, CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04_VALOR) * 0.8635,2) ELSE SUM(Z04_VALOR) END AS TOTAL "
cQry += " 			FROM Z02010 Z02 "
cQry += " 			INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 									AND Z04.Z04_MOD = '1' "
cQry += " 									AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 									AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 									AND Z02.Z02_TIPO IN ('0','1','5','7') "
cQry += " 									AND Z02.D_E_L_E_T_ = '' "
cQry += " 			GROUP BY Z02_PROPOS,Z02_ADITIV,Z02_IMPINC "
cQry += " ) X ON X.PROPOSTA = Z02.Z02_PROPOS AND X.ADITIVO = Z02_ADITIV AND Z02.Z02_TIPO IN ('0','1','5','7')"
TcSqlExec(cQry)

//Calcula o valor do suporte 
cQry := " UPDATE Z02010 SET Z02_VLRAMS = CASE WHEN Z02_IMPINC = '1' THEN ROUND(Z04_TOTAL * 0.8635,2) ELSE Z04_TOTAL END, "
cQry += " Z02_MENSUP = CASE WHEN Z02_IMPINC = '1' THEN ROUND(Z04_VALOR * 0.8635,2) ELSE Z04_VALOR END "
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 						AND Z04.Z04_MOD = '5' "
cQry += " 						AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 						AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 						AND Z02.D_E_L_E_T_ = '' AND Z02.Z02_TIPO IN ('2','3','6')"
TcSqlExec(cQry)


//Ajusta o valor total de setup
cQry := " UPDATE Z02010 SET Z02_VLRSET = CASE WHEN Z02_IMPINC = '1' THEN ROUND(Z04_TOTAL * 0.8635,2) ELSE Z04_TOTAL END "
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 						AND Z04.Z04_MOD = '3' "
cQry += " 						AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 						AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 						AND Z02.D_E_L_E_T_ = '' "
TcSqlExec(cQry)

//Ajusta o valor da mensalidade (soma as mensalidades de Licencas+Add-ons)
cQry := " UPDATE Z02010 SET Z02_MENSAS = X.TOTAL"
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN (SELECT Z02_PROPOS AS PROPOSTA, Z02_ADITIV ADITIVO, CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04_VALOR) * 0.8635,2) ELSE SUM(Z04_VALOR) END AS TOTAL "
cQry += " 			FROM Z02010 Z02 "
cQry += " 			INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 									AND Z04.Z04_MOD IN ('4') "
cQry += " 									AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 									AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 									AND Z02.D_E_L_E_T_ = '' AND Z02.Z02_TIPO IN ('3','4','8') "
cQry += " 			GROUP BY Z02_PROPOS,Z02_ADITIV,Z02_IMPINC "
cQry += " ) X ON X.PROPOSTA = Z02.Z02_PROPOS AND X.ADITIVO = Z02_ADITIV "
TcSqlExec(cQry)

//Ajusta o valor total das mensalidades (total do contrato mensal)
cQry := " UPDATE Z02010 SET Z02_VLRSAS = CASE WHEN Z02_IMPINC = '1' THEN ROUND(Z04_TOTAL * 0.8635,2) ELSE Z04_TOTAL END "
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 						AND Z04.Z04_MOD = '4' "
cQry += " 						AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 						AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 						AND Z02.D_E_L_E_T_ = '' AND Z02.Z02_TIPO IN ('3','4','8')"
TcSqlExec(cQry)

//Ajusta o valor total de contrato OnPremise
cQry := " UPDATE Z02010 SET Z02_VLRONP = CASE WHEN Z02_IMPINC = '1' THEN ROUND(Z04_TOTAL * 0.8635,2) ELSE Z04_TOTAL END "
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN Z04010 Z04 ON Z04.D_E_L_E_T_ = '' "
cQry += " 						AND Z04.Z04_MOD = '2' "
cQry += " 						AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "
cQry += " 						AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "
cQry += " 						AND Z02.D_E_L_E_T_ = '' AND Z02.Z02_TIPO IN ('4')"
TcSqlExec(cQry)

//Ajusta as Origem das Vendas do Ano para Ajustar os Calculos de Metas entre Base e Novos
cQry := " UPDATE Z02010 SET Z02_ORIGEM = A3_BASENEW 
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN SA3010 SA3 ON SA3.D_E_L_E_T_ = '' AND Z02.Z02_VEND2 = SA3.A3_COD "
cQry += " WHERE Z02.D_E_L_E_T_ = '' AND Z02.Z02_STATUS = '3' "
TcSqlExec(cQry)

//Ajusta o calculo do NETSAP
cQry := " UPDATE Z02010 SET Z02_ORIGEM = CASE WHEN YEAR(A1_DTCAD) < YEAR(Z02_DTAPRO) THEN 'B' ELSE A3_BASENEW END
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN SA3010 SA3 ON SA3.D_E_L_E_T_ = '' AND Z02.Z02_VEND2 = SA3.A3_COD "
cQry += " LEFT JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ = '' AND Z02.Z02_CLIENT = SA1.A1_COD "
cQry += " LEFT JOIN SUS010 SUS ON SUS.D_E_L_E_T_ = '' AND Z02.Z02_PROSPE = SUS.US_COD "
cQry += " WHERE Z02.D_E_L_E_T_ = '' AND YEAR(Z02.Z02_DTAPRO) = '" + CValToChar(Year(dDatabase)) + "'"
cQry += " AND Z02.Z02_TIPO IN ('3','4') "
TcSqlExec(cQry)
//Ajusta o calculo do desconto proporcional do item em relacao ao desconto total
cQry := " SELECT *, Z05.R_E_C_N_O_ AS Z05RECNO"
cQry += " FROM Z02010 Z02 "
cQry += " INNER JOIN Z05010 Z05 ON Z05.D_E_L_E_T_ = '' AND Z05.Z05_PROPOS = Z02.Z02_PROPOS AND Z05.Z05_ADITIV = Z02.Z02_ADITIV "
cQry += " WHERE Z02.D_E_L_E_T_ = '' AND Z02.Z02_DSCTOT > 0 AND Z05.Z05_DSCPRO = 0 AND (Z05.Z05_TOTAL > 0 OR Z05.Z05_VLRMES > 0)"
cQry:= ChangeQuery(cQry)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TMP2",.F.,.T.)
cPropos  := ""
nSaldoDsc:= 0
nDscTotal:= 0
nVlrTotal:= 0
While !Eof()
	If (cPropos <> TMP2->Z02_PROPOS+TMP2->Z02_ADITIV)
		If (nSaldoDsc > 0)
			RecLock("Z05",.F.)
			Z05->Z05_DSCPRO+= nSaldoDsc
			MsUnLock()
			nSaldoDsc:= 0
		EndIf

		cPropos:= TMP2->Z02_PROPOS+TMP2->Z02_ADITIV
		nDscTotal:= TMP2->Z02_DSCTOT
		nSaldoDsc:= TMP2->Z02_DSCTOT
		nVlrTotal:= TMP2->Z02_VLRLIQ + TMP2->Z02_DSCTOT
	EndIf

	Z05->(dbGoTo(TMP2->Z05RECNO))
	If !Z05->(Eof())
		RecLock("Z05",.F.)
		Z05->Z05_DSCPRO:= IIf(Z05->Z05_TOTAL > 0, NoRound((Z05->Z05_TOTAL/nVlrTotal)*nDscTotal,2), NoRound((Z05->Z05_VLRMES/nVlrTotal)*nDscTotal,2))
		MsUnLock()
		
		nSaldoDsc-= Z05->Z05_DSCPRO
	EndIf

	TMP2->(dbSkip())
End
TMP2->(dbCloseArea())



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os dados.						    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT A3_NREDUZ, Z02.* "
cQuery += " FROM "
cQuery += 		RetSqlName('Z02') + " Z02, "
cQuery += 		RetSqlName('SA3') + " SA3  "
cQuery += "	WHERE "
cQuery += " 	Z02.Z02_FILIAL		= '" + xFilial('Z02')	+ "' 	AND "

IF cVenda == 'S' // Todas as Vendas SAP

	cQuery += " Z02.Z02_TIPO IN ('3','4','5','6','7') AND "

ElseIF cVenda == 'V' // Todas as Vendas TOTVS

	cQuery += " Z02.Z02_TIPO IN ('0','1','2','8') AND "

ElseIF cVenda == '1' // Todas as Vendas de Servicos TOTVS

	cQuery += " Z02.Z02_TIPO IN ('1','2') AND "

ElseIF cVenda == '5' // Todas as Vendas de Servicos SAP

	cQuery += " Z02.Z02_TIPO IN ('5','6','7') AND "

ElseIF cVenda != 'T' // Se nao for Todos, filtra somente a opcao selecionada

	cQuery += " Z02.Z02_TIPO = '" + cVenda + "' AND "

EndIF

IF cStatus == '5'		// Aprovados (Incluindo Gerou Projetos)

	cQuery += " Z02.Z02_STATUS IN ('5','9') AND "
	cQuery += " Z02.Z02_DTAPRO >= '" + Dtos(dDtIni) + "' AND "
	cQuery += " Z02.Z02_DTAPRO <= '" + Dtos(dDtFim) + "' AND "

ElseIF cStatus != 'T'	// Filtra todos os Status por data de inclusao da Oportunidade

	cQuery += " Z02.Z02_STATUS = '" + cStatus + "' AND "
	cQuery += " Z02.Z02_DATAOP >= '" + Dtos(dDtIni) + "' AND "
	cQuery += " Z02.Z02_DATAOP <= '" + Dtos(dDtFim) + "' AND "
Else

	cQuery += " Z02.Z02_DATAOP >= '" + Dtos(dDtIni) + "' AND "
	cQuery += " Z02.Z02_DATAOP <= '" + Dtos(dDtFim) + "' AND "

EndIF

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += " 	Z02.Z02_VEND2 = '" + Left(cVendCombo,6) + "' AND "
EndIF

IF Left(cBaseNovos,5) != 'TODOS'
	cQuery += " 	Z02.Z02_ORIGEM = '" + Left(cBaseNovos,1) + "' AND "
EndIF

IF !Empty(cProposPsq)
	cQuery += " 		Z02.Z02_PROPOS = '" + Alltrim(cProposPsq) + "' AND "

ElseIF !Empty(cClientePsq)
	cQuery += " 		Z02.Z02_RAZAO LIKE '%"+Alltrim(cClientePsq)+"%' AND "
EndIF

cQuery	+= " Z02.D_E_L_E_T_ = ' ' 								AND "
cQuery	+= " SA3.A3_FILIAL		= '" + xFilial('SA3')	+ "' 	AND "
cQuery	+= " SA3.A3_COD = Z02.Z02_VEND2							AND "
cQuery	+= " SA3.D_E_L_E_T_ = '' "
cQuery	+= " ORDER BY Z02_DTAPRO DESC "

cQuery		:= ChangeQuery(cQuery)

MemoWrite('C:\Propostas\Z02Query.txt',cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os dados conforme a selecao do usuario.	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "Z02_DATAOP"	, "D" , 8 , 0 )
TcSetField("TMP", "Z02_DTAPRO"	, "D" , 8 , 0 )

While !TMP->(Eof())

	nVlrServico		+= TMP->Z02_VLRSER
	nVlrSetup		+= TMP->Z02_VLRSET
	nVlrOnPremise 	+= TMP->Z02_VLRONP
	nVlrMSaaS		+= TMP->Z02_MENSAS
	nVlrNetSAP		+= TMP->Z02_NETSAP
	nVlrAMS			+= TMP->Z02_MENSUP
	nVlrTotAMS		+= TMP->Z02_VLRAMS
	nVlrSaaS		+= TMP->Z02_VLRSAS

	Aadd(aColsOp,Array(Len(aHeaderOp)+1))
	
	For nX	:= 1 To Len(aHeaderOp)
		
		IF AllTrim(aHeaderOp[nX,2]) == "XXX"
			aColsOp[Len(aColsOp),nX] := ''
				
		ElseIF AllTrim(aHeaderOp[nX,2]) == "Z02_OK"
		
			IF TMP->Z02_STATUS == '1'
				aColsOp[Len(aColsOp),nX] := aStatus[1]
			ElseIF TMP->Z02_STATUS == '2'
				aColsOp[Len(aColsOp),nX] := aStatus[2]
			ElseIF TMP->Z02_STATUS == '3'
				aColsOp[Len(aColsOp),nX] := aStatus[3]
			ElseIF TMP->Z02_STATUS == '4'			
				aColsOp[Len(aColsOp),nX] := aStatus[4]			
			ElseIF TMP->Z02_STATUS == '5'
				aColsOp[Len(aColsOp),nX] := aStatus[5]			
			ElseIF TMP->Z02_STATUS == '6'
				aColsOp[Len(aColsOp),nX] := aStatus[6]			
			ElseIF TMP->Z02_STATUS == '7'
				aColsOp[Len(aColsOp),nX] := aStatus[7]			
			ElseIF TMP->Z02_STATUS == '8'						
				aColsOp[Len(aColsOp),nX] := aStatus[8]			
			ElseIF TMP->Z02_STATUS == '9'			
				aColsOp[Len(aColsOp),nX] := aStatus[9]			
			EndIF

		ElseIF AllTrim(aHeaderOp[nX,2]) == "Z02_OK2"
		
			IF TMP->Z02_STATUS $ '5/9' .And. TMP->Z02_DOCOK == '1'
				aColsOp[Len(aColsOp),nX] := LoadBitmap(GetResources(),'BR_VERDE')
			
			ElseIF TMP->Z02_STATUS $ '5/9' .And. TMP->Z02_DOCOK <> '1'
				aColsOp[Len(aColsOp),nX] := LoadBitmap(GetResources(),'CLOCK01')
		    
		    Else
		 	   aColsOp[Len(aColsOp),nX] := LoadBitmap(GetResources(),'BR_CINZA')
		    
		    EndIF

		ElseIF AllTrim(aHeaderOp[nX,2]) == "Z02_RAZAO"
		
			aColsOp[Len(aColsOp),nX]:= Left(TMP->Z02_RAZAO,AT(' ',TMP->Z02_RAZAO))
			cResto 					:= Alltrim(Substring(TMP->Z02_RAZAO,AT(' ',TMP->Z02_RAZAO),Len(TMP->Z02_RAZAO)))
			aColsOp[Len(aColsOp),nX]:= Alltrim(aColsOp[Len(aColsOp),nX] + Alltrim(Left(cResto,AT(' ',cResto))))
			
			IF Len(Alltrim(aColsOp[Len(aColsOp),nX])) <= 3
				aColsOp[Len(aColsOp),nX] := Alltrim(TMP->Z02_RAZAO)
			EndIF 

		ElseIF ( aHeaderOp[nX,10] != "V" )
			aColsOp[Len(aColsOp),nX] := TMP->( FieldGet(FieldPos(aHeaderOp[nX,2])) )
		Else
			aColsOp[Len(aColsOp),nX] := CriaVar(aHeaderOp[nX,2])
		EndIF
	Next nX
	
	aColsOp[Len(aColsOp),Len(aHeaderOp)+1] := .F.

	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

IF Len(aColsOp) <= 0

	Aadd(aColsOp,Array(Len(aHeaderOp)+1))

	For nX := 1 To Len(aHeaderOp)
		
		IF AllTrim(aHeaderOp[nX,2]) == "Z02_STATUS"
			aColsOp[Len(aColsOp),nX] := '1'

		ElseIF AllTrim(aHeaderOp[nX,2]) == "Z02_OK"          
			aColsOp[Len(aColsOp),nX] := aStatus[1]

		ElseIF AllTrim(aHeaderOp[nX,2]) == "XXX"
			aColsOp[Len(aColsOp),nX] := ''
		
		ElseIF aHeaderOp[nX,8] == 'C'
			aColsOp[Len(aColsOp),nX] := 'X'

		ElseIF aHeaderOp[nX,8] == 'N'
			aColsOp[Len(aColsOp),nX] := 1

		Else 
			aColsOp[Len(aColsOp),nX] := CriaVar(aHeaderOp[nX,2],.F.)
		EndIF
	Next nX

	aColsOp[Len(aColsOp),Len(aHeaderOp)]   := IIF( Len(aColsOp) == 1 , 'X' , '' )
	aColsOp[Len(aColsOp),Len(aHeaderOp)+1] := .F.

EndIF

oVlrServico:Refresh()
oVlrSetup:Refresh()
oVlrMSaaS:Refresh()
oVlrSaaS:Refresh()
oVlrNetSAP:Refresh()
oVlrOnPremise:Refresh()
oVlrAMS:Refresh()
oVlrTotAMS:Refresh()

IF Type('oGetOp') != 'U'
	oGetOp:Destroy()
EndIF

oGetOp:=MsNewGetDados():New(0,0,0,0,GD_UPDATE,"Allwaystrue","Allwaystrue","",aAlter,,,,,,oPanelOpor,@aHeaderOp,@aColsOp)
oGetOp:oBrowse:bHeaderClick		:= { |oObj,nCol| U_SyOrdena(nCol,@oGetOp,@nlOrdemCols,'OP') }
oGetOp:bFieldOk := { || EditaOpe(@oGetOp,@aColsOp)}
oGetOp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetOp:bChange := {||	GRfCor(1,oGetOp) }
oGetOp:oBrowse:SetBlkBackColor( { || GRfCor(2,oGetOp) } )
oGetOp:oBrowse:SetBlkColor( { || GRfCor(3,oGetOp) } )
oGetOp:oBrowse:Refresh()
oGetOp:oBrowse:GoTop()

Eval(bAtuClientes)

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  A20Cor   ³ Autor ³   Alexandro Diass    ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cor das tarefas atrasadas.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GRfCor(nOpcao,oBrw)    

Local nPos	:= Ascan(oBrw:aHeader,{|x| Alltrim(x[2]) == "A1_CURVA" })
Local nScan := 0

IF nOpcao == 1	// bChange

	nScan := Ascan( oBrw:aCols , { |x| x[Len(oBrw:aHeader)] == 'X' } )
	IF nScan > 0                                  
		oBrw:aCols[nScan,Len(oBrw:aHeader)] := ''
	EndIF

	oBrw:aCols[oBrw:nAt,Len(oBrw:aHeader)] := 'X'
	oBrw:oBrowse:Refresh()

ElseIF nOpcao == 2	// SetBlkBackColor (Cor Fundo)

	IF oBrw:aCols[oBrw:nAt,Len(oBrw:aHeader)] == 'X'
		Return(Rgb(0,0,255))	// Fundo - Azul
    Else
		
		IF nPos > 0
		
			IF oBrw:aCols[oBrw:nAt,nPos] == 'A'
				Return(Rgb(0,255,127))	// Fundo - Verde
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'B'		
				Return(Rgb(131,111,255))	// Fundo - LimeGreen
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'C'
				Return(Rgb(238,238,0))	// Fundo - Amarelo
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'I'
				Return(Rgb(190,190,190))	// Fundo - Cinza
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'P'
				Return(Rgb(255,0,0))	// Fundo - Vermelho
			EndIF
		Else
				
			Return(Rgb(248,248,255))
	    
	    EndIF
	
	EndIF

ElseIF nOpcao == 3 // SetBlkColor (Cor Fonte)
	
	IF 	oBrw:aCols[oBrw:nAt,Len(oBrw:aHeader)] == 'X'
	
		Return(Rgb(255,255,255))	// Fonte - Branca	
	
	Else 
		
		IF nPos > 0
		
			IF oBrw:aCols[oBrw:nAt,nPos] == 'A'
				Return(Rgb(0,0,0)) // Fonte - Preto
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'B'		
				Return(Rgb(255,255,255))	// Fonte - Branca	
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'C'
				Return(Rgb(0,0,0)) // Fonte - Preto
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'I'
				Return(Rgb(255,255,255))	// Fonte - Branca	
	
			ElseIF oBrw:aCols[oBrw:nAt,nPos] == 'P'
				Return(Rgb(255,255,255))	// Fonte - Branca	
			EndIF
		Else
		
			Return(Rgb(0,0,0)) // Fonte - Preto
	
		EndIF
		
	EndIF

EndIF

Return
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

Static Function PreparaDadosGrf(oFolderFilho,cVendCombo,dDtIni,dDtFim,cVenda)

Local aArea		 	:= GetArea()
Local aMeses	 	:= {'JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ'}
Local aSrvLegenda 	:= {'Meta','Vendas(Base)','Vendas(Novos)'}
Local aSrvMetaMes	:= {}
Local aLicLegenda 	:= {'Meta','SaaS','OnPremise'}
Local aLicMetaMes	:= {}
Local cAnoIni	 	:= Left( Dtos(FirstDay(dDtIni)) 		, 4 ) + '01'
Local cAnoFim	 	:= Left( Dtos(FirstDay(dDtFim)) 		, 4 ) + '12'
Local nAno 		 	:= Val(Left(cAnoIni,4))
Local nMes 		 	:= Val(Right(cAnoIni,2))
Local aFWCharts  	:= Array(6)
Local nTop		 	:= 0
Local nFWCharts  	:= 0
Local cCurva
Local cAnoMesAux
Local oGrfInd
Local cQuery
Local nPos
Local oFld1Grafico
Local oFld2Grafico
Local oFld3Grafico
Local nY
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Meta dos ultimos 12 meses. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To 12

	cAnoMesAux := StrZero(nAno,4) + StrZero(nMes,2)
	
	Aadd( aSrvMetaMes	, { cAnoMesAux , 500000 , 0 , 0 } )
	Aadd( aLicMetaMes 	, { cAnoMesAux , 500000 , 0 , 0 } )	

	nMes++
	IF nMes > 12
		nAno++
		nMes:= 1
	EndIF
	
Next

oFld1Grafico := TPanel():New(0, 0, "",oFolderFilho:aDialogs[1], NIL, .T., .F., NIL, NIL,640,220, .T., .F. )
oFld2Grafico := TPanel():New(0, 0, "",oFolderFilho:aDialogs[2], NIL, .T., .F., NIL, NIL,640,220, .T., .F. )
oFld3Grafico := TPanel():New(0, 0, "",oFolderFilho:aDialogs[3], NIL, .T., .F., NIL, NIL,640,220, .T., .F. )

oGrfIndA := FWLayer():New()
oGrfIndA:Init(oFld1Grafico, .F.) 
oGrfIndA:AddCollumn('BLOCO1',	50	, .F.)
oGrfIndA:AddCollumn('BLOCO2',	50	, .F.)
oGrfIndA:AddWindow(	'BLOCO1'		, 'JANELA'  , "SERVIÇOS - [ Ano: " + Left(Dtos(dDtIni),4) + " ] -> " + cVendCombo 	, 100, .F., .F.)
oGrfIndA:AddWindow(	'BLOCO2'		, 'JANELA'  , "LICENÇAS - [ Ano: " + Left(Dtos(dDtIni),4) + " ] -> " + cVendCombo 	, 100, .F., .F.)

oGrfIndB := FWLayer():New()
oGrfIndB:Init(oFld2Grafico, .F.) 
oGrfIndB:AddCollumn('BLOCO1', 100 , .F.)
oGrfIndB:AddCollumn('BLOCO2', 100 , .F.)
oGrfIndB:AddWindow(	'BLOCO1' 	, 'JANELA'  , "Ranking - Por Vendedor"	, 100, .F., .F.)
oGrfIndB:AddWindow(	'BLOCO2' 	, 'JANELA'  , "Ranking - Por Equioe"	, 100, .F., .F.)

oGrfIndC := FWLayer():New()
oGrfIndC:Init(oFld3Grafico, .F.) 
oGrfIndC:AddCollumn('BLOCO1', 50 , .F.)
oGrfIndC:AddCollumn('BLOCO2', 50 , .F.) 
oGrfIndC:AddWindow(	'BLOCO1' 	, 'JANELA'  , "Base x Novos" 		, 100, .F., .F.)
oGrfIndC:AddWindow(	'BLOCO2' 	, 'JANELA'  , "Vendas por Curva"	, 100, .F., .F.)

/* Valores do getInstance:BARCHART  
-  cria objeto BARCOMPCHART 
-  cria objeto LINECHART 
-  cria objeto PIECHART 
-  cria objeto FWChartPie
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1- Servicos (Metas x Realizado)                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFWCharts := 1
aFWCharts[nFWCharts] := FWChartFactory():New()
aFWCharts[nFWCharts] := aFWCharts[nFWCharts]:GetInstance( LINECHART )
aFWCharts[nFWCharts]:Init( oGrfIndA:GetWinPanel('BLOCO1', 'JANELA'),.T.,.F.)
aFWCharts[nFWCharts]:setColor("Random")
aFWCharts[nFWCharts]:setLegend( CONTROL_ALIGN_BOTTOM )
aFWCharts[nFWCharts]:setMask( "R$ *@*" )
aFWCharts[nFWCharts]:setPicture( "@E 999,999,999" )

cQuery := " SELECT "
cQuery += " 	Z02_TIPO 					AS TIPO, "
cQuery += " 	LEFT(Z02_DTAPRO,4) 			AS ANO,	 "
cQuery += " 	SUBSTRING(Z02_DTAPRO,5,2) 	AS MES,	 "

cQuery += " 	SUM( Case When Z02_TIPO IN ('0','1','2','5','6','7')	Then Z02_VLRSER + Z02_VLRAMS Else 0 End ) AS VLRSERVICO , "
cQuery += " 	SUM( Case When Z02_TIPO IN ('3','8')					Then Z02_VLRSAS	Else 0 End ) AS SAAS , "
cQuery += " 	SUM( Case When Z02_TIPO IN ('4')						Then Z02_VLRONP	Else 0 End ) AS VLRONP "

cQuery += " FROM "
cQuery += 			RetSqlName('Z02') + " Z02, "
cQuery += 			RetSqlName('SA3') + " SA3 "
cQuery += " WHERE "
cQuery += " 	Z02.Z02_FILIAL		= '" + xFilial('Z02')	+ "' 	AND "
cQuery += " 	LEFT(Z02.Z02_DTAPRO,6) >= '" + cAnoIni		+ "' 	AND "
cQuery += " 	LEFT(Z02.Z02_DTAPRO,6) <= '" + cAnoFim		+ "' 	AND "
cQuery += "		Z02.Z02_STATUS IN ('5','9')							AND " // 5=Aprovado ou 9=Gerado Projeto

IF cVenda == 'S' // Todas as Vendas SAP

	cQuery += " Z02_TIPO IN ('3','4','5','6','7') AND "

ElseIF cVenda == 'V' // Todas as Vendas TOTVS

	cQuery += " Z02_TIPO IN ('0','1','2','8') AND "

ElseIF cVenda != 'T' // Se nao for Todos, filtra somente a opcao selecionada

	cQuery += " Z02_TIPO = '" + cVenda + "' AND "

EndIF

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += "	Z02.Z02_VEND2 = '" + Left(cVendCombo,6)	+ "' AND "
EndIF

cQuery += " 	Z02.D_E_L_E_T_ = ''									AND "
cQuery += "		SA3.A3_FILIAL		= '" + xFilial('SA3')	+ "' 	AND "
cQuery += "		SA3.A3_COD = Z02.Z02_VEND2							AND "
cQuery += "		SA3.D_E_L_E_T_ = '' "
cQuery += " GROUP BY Z02_TIPO , LEFT(Z02_DTAPRO,4) , SUBSTRING(Z02_DTAPRO,5,2) " 
cQuery += " ORDER BY ANO , MES "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\MetaQuery.txt',cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()

While !Eof()

	nPos := aScan( aSrvMetaMes , { |x| x[1] == TRB->ANO+TRB->MES } )

	IF nPos > 0
		aSrvMetaMes[nPos,4] += TRB->VLRSERVICO
	EndIF

	DbSkip()

EndDo

For nX := 1 To Len(aSrvLegenda)
	
	aResult := {}
	
	For nY := 1 To Len(aSrvMetaMes)
			
		IF nX == 1		//	Meta
			Aadd( aResult, { aMeses[Val(Right(aSrvMetaMes[nY,1],2))]+'/'+Subs(aSrvMetaMes[nY,1],3,2)	, aSrvMetaMes[nY,2] } )
		ElseIF nX == 2	//	Servicos Base
			Aadd( aResult, { aMeses[Val(Right(aSrvMetaMes[nY,1],2))]+'/'+Subs(aSrvMetaMes[nY,1],3,2)	, aSrvMetaMes[nY,3] } )
		ElseIF nX == 3	//	Servicos Novos
			Aadd( aResult, { aMeses[Val(Right(aSrvMetaMes[nY,1],2))]+'/'+Subs(aSrvMetaMes[nY,1],3,2)	, aSrvMetaMes[nY,4] } )
		EndIF
		
	Next
	
	aFWCharts[nFWCharts]:addSerie( aSrvLegenda[nX] , aResult )
	
Next

aFWCharts[nFWCharts]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 2- Licencas (Metas x Realizado)                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFWCharts := 2
aFWCharts[nFWCharts] := FWChartFactory():New()
aFWCharts[nFWCharts] := aFWCharts[nFWCharts]:GetInstance( LINECHART )
aFWCharts[nFWCharts]:Init( oGrfIndA:GetWinPanel('BLOCO2', 'JANELA'),.T.,.F.)
aFWCharts[nFWCharts]:setColor("Random")
aFWCharts[nFWCharts]:setLegend( CONTROL_ALIGN_BOTTOM )
aFWCharts[nFWCharts]:setMask( "R$ *@*" )
aFWCharts[nFWCharts]:setPicture( "@E 999,999,999" )

DbSelectArea("TRB")
DbGoTop()

While !Eof()

	nPos := aScan( aLicMetaMes , { |x| x[1] == TRB->ANO+TRB->MES } )

	IF nPos > 0
		// O Service Desk TOTVS nao entra como SaaS
		aLicMetaMes[nPos,3] += TRB->SAAS
		aLicMetaMes[nPos,4] += TRB->VLRONP
	EndIF
	
	DbSkip()

EndDo

For nX := 1 To Len(aLicLegenda)
	
	aResult := {}
	
	For nY := 1 To Len(aLicMetaMes)
			
		IF nX == 1		//	Meta
			Aadd( aResult, { aMeses[Val(Right(aLicMetaMes[nY,1],2))]+'/'+Subs(aLicMetaMes[nY,1],3,2)	, aLicMetaMes[nY,2] } )
		ElseIF nX == 2	//	SaaS
			Aadd( aResult, { aMeses[Val(Right(aLicMetaMes[nY,1],2))]+'/'+Subs(aLicMetaMes[nY,1],3,2)	, aLicMetaMes[nY,3] } )
		ElseIF nX == 3	//	OnPremise
			Aadd( aResult, { aMeses[Val(Right(aLicMetaMes[nY,1],2))]+'/'+Subs(aLicMetaMes[nY,1],3,2)	, aLicMetaMes[nY,4] } )
		EndIF
		
	Next
	
	aFWCharts[nFWCharts]:addSerie( aLicLegenda[nX] , aResult )
	
Next

TRB->(DbCloseArea())

aFWCharts[nFWCharts]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3- Ranking de Vendas [ Propostas Aprovadas ].								      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFWCharts := 3
aFWCharts[nFWCharts] := FWChartFactory():New()
aFWCharts[nFWCharts] := aFWCharts[nFWCharts]:GetInstance( BARCHART )
aFWCharts[nFWCharts]:init( oGrfIndB:GetWinPanel('BLOCO1', 'JANELA'),.T.,.F.)
aFWCharts[nFWCharts]:setColor("Random")
aFWCharts[nFWCharts]:setLegend( CONTROL_ALIGN_RIGHT )
aFWCharts[nFWCharts]:setMask( "R$ *@*" )
aFWCharts[nFWCharts]:setPicture( "@E 999,999,999" )

cQuery := " SELECT A3_NREDUZ, SUM(Z02_VLRSER+Z02_VLRSET+Z02_VLRSAS+Z02_VLRONP+Z02_VLRAMS) AS VLRREALIZADO "
cQuery += "			FROM "
cQuery += 			RetSqlName('Z02') + " Z02, 	"
cQuery += 			RetSqlName('SA3') + " SA3 	"
cQuery += "			WHERE "
cQuery += " 			Z02.Z02_FILIAL		= '" + xFilial('Z02')	+ "' 	AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) >= '" + cAnoIni		+ "' 	AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) <= '" + cAnoFim		+ "' 	AND "
cQuery += "				Z02.Z02_STATUS IN ('5','9')							AND " // 5=Aprovado ou 9=Gerado Projeto
cQuery += "				Z02.D_E_L_E_T_ = ' ' 								AND "

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += "			Z02.Z02_VEND2 = '" + Left(cVendCombo,6)		+ "' 	AND "
EndIF

cQuery += " 			SA3.A3_FILIAL		= '" + xFilial('SA3')	+ "' 	AND "
cQuery += " 			SA3.A3_COD = Z02.Z02_VEND2							AND "
cQuery += " 			SA3.D_E_L_E_T_ = '' "
cQuery += " GROUP BY A3_NREDUZ "
cQuery += " ORDER BY VLRREALIZADO DESC "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\RankingQuery.txt',cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	aFWCharts[nFWCharts]:addSerie( Subs( TRB->A3_NREDUZ , 1 , IIF( At(" ",TRB->A3_NREDUZ) == 0 , 12 ,  At(" ",TRB->A3_NREDUZ) ) ) + ' - $ ' + Alltrim(Transform(TRB->VLRREALIZADO,'@E 999,999,999')) , TRB->VLRREALIZADO )
	DbSkip()
EndDo
TRB->(DbCloseArea())

aFWCharts[nFWCharts]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 4- Base x Novos por Valor.					       						          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFWCharts := 4
aFWCharts[nFWCharts] := FWChartFactory():New()
aFWCharts[nFWCharts] := aFWCharts[nFWCharts]:GetInstance( PIECHART )
aFWCharts[nFWCharts]:init( oGrfIndC:GetWinPanel('BLOCO1', 'JANELA'),.T.,.F.)
aFWCharts[nFWCharts]:setColor("Random")
aFWCharts[nFWCharts]:setLegend( CONTROL_ALIGN_RIGHT )
aFWCharts[nFWCharts]:setMask( "R$ *@*" )
aFWCharts[nFWCharts]:setPicture( "@E 999,999,999" )

cQuery := " SELECT Z02_ORIGEM, COUNT(*) AS QTD , SUM(Z02_VLRSER+Z02_VLRSET+Z02_VLRSAS+Z02_VLRONP+Z02_VLRAMS) AS VALOR "
cQuery += "			FROM "
cQuery += 			RetSqlName('Z02') + " Z02, 	"
cQuery += 			RetSqlName('SA3') + " SA3 	"
cQuery += "			WHERE "
cQuery += " 			Z02.Z02_FILIAL		= '" + xFilial('Z02')	+ "' 		AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) >= '" + cAnoIni		+ "' 		AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) <= '" + cAnoFim		+ "' 		AND "
cQuery += "				Z02.Z02_STATUS IN ('5','9')								AND " // 5=Aprovado ou 9=Gerado Projeto
cQuery += "				Z02.D_E_L_E_T_ = ' ' 									AND "

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += "	Z02.Z02_VEND2 			= '" + Left(cVendCombo,6)	+ "' 		AND "
EndIF

cQuery += " 			SA3.A3_FILIAL		= '" + xFilial('SA3')	+ "' 		AND "
cQuery += " 			SA3.A3_COD 			= Z02.Z02_VEND2						AND "
cQuery += " 			SA3.D_E_L_E_T_ = '' "
cQuery += " GROUP BY Z02_ORIGEM "
cQuery += " ORDER BY QTD DESC "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\BaseNovosQuery.txt',cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	aFWCharts[nFWCharts]:addSerie( IIF(TRB->Z02_ORIGEM == 'B','Base','Novos')  + ' - ' + Alltrim(Transform(TRB->QTD,'@E 9,999')) + ' - $ ' + Alltrim(Transform(TRB->VALOR,'@E 999,999,999')) , TRB->VALOR )
	DbSkip()
EndDo
TRB->(DbCloseArea())

aFWCharts[nFWCharts]:Build()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 5- Analise por Curva de Valores.			       						          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nFWCharts := 5
aFWCharts[nFWCharts] := FWChartFactory():New()
aFWCharts[nFWCharts] := aFWCharts[nFWCharts]:GetInstance( PIECHART )
aFWCharts[nFWCharts]:init( oGrfIndC:GetWinPanel('BLOCO2', 'JANELA'),.T.,.F.)
aFWCharts[nFWCharts]:setColor("Random")
aFWCharts[nFWCharts]:setLegend( CONTROL_ALIGN_RIGHT )
aFWCharts[nFWCharts]:setMask( "R$ *@*" )
aFWCharts[nFWCharts]:setPicture( "@E 999,999,999" )

cQuery := " SELECT A1_CURVA, COUNT(*) AS QTD , SUM(Z02_VLRSER+Z02_VLRSET+Z02_VLRSAS+Z02_VLRONP+Z02_VLRAMS) AS VALOR "
cQuery += "			FROM "
cQuery += 			RetSqlName('Z02') + " Z02, 	"
cQuery += 			RetSqlName('SA1') + " SA1, 	"
cQuery += 			RetSqlName('SA3') + " SA3 	"
cQuery += "			WHERE "
cQuery += " 			Z02.Z02_FILIAL		= '" + xFilial('Z02')	+ "' 		AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) >= '" + cAnoIni		+ "' 		AND "
cQuery += " 			LEFT(Z02.Z02_DTAPRO,6) <= '" + cAnoFim		+ "' 		AND "
cQuery += "				Z02.Z02_STATUS IN ('5','9')								AND " // 5=Aprovado ou 9=Gerado Projeto
cQuery += "				Z02.D_E_L_E_T_ = ' ' 									AND "

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += "			Z02.Z02_VEND2 		= '" + Left(cVendCombo,6)	+ "' 	AND "
EndIF

cQuery += " 			SA1.A1_FILIAL		= '" + xFilial('SA1')	+ "' 		AND "
cQuery += " 			SA1.A1_COD 			= Z02.Z02_CLIENT					AND "
cQuery += "				SA1.D_E_L_E_T_ = ' ' 									AND "
cQuery += " 			SA3.A3_FILIAL		= '" + xFilial('SA3')	+ "' 		AND "
cQuery += " 			SA3.A3_COD 				= Z02.Z02_VEND2					AND "
cQuery += " 			SA3.D_E_L_E_T_ = '' "
cQuery += " GROUP BY A1_CURVA "
cQuery += " ORDER BY QTD DESC "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\CurvaQuery.txt',cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	
	cCurva := 'Padrao'
	IF TRB->A1_CURVA == 'A'
		cCurva := 'VIP'
	ElseIF TRB->A1_CURVA == 'B'
		cCurva := 'Especial'
	ElseIF TRB->A1_CURVA == 'C'
		cCurva := 'Padrao'
	ElseIF TRB->A1_CURVA == 'I'
		cCurva := 'Inativo'
	ElseIF TRB->A1_CURVA == 'P'
		cCurva := 'Problematico'
	EndIF

	aFWCharts[nFWCharts]:addSerie( cCurva + ' - ' + Alltrim(Transform(TRB->QTD,'@E 9,999')) + ' - $ ' + Alltrim(Transform(TRB->VALOR,'@E 999,999,999')) , TRB->VALOR )
	DbSkip()
EndDo
TRB->(DbCloseArea())

aFWCharts[nFWCharts]:Build()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RetMeta  ³ Autor ³   Alexandro Dias      ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a Meta dos Vendedores.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetMeta(cAnoMes,cVendCombo)

Local aArea := GetArea()
Local nMeta := 0
Local cQuery

cQuery := " SELECT "

IF Left(cVendCombo,5) == 'TODOS'
	cQuery += "	SUM(ZC_VLRMETA+ZC_VLRCDU) AS VLRMETA " 
Else
	cQuery += "	ZC_VLRMETA+ZC_VLRCDU AS VLRMETA "
EndIF

cQuery += "	FROM "
cQuery += 			RetSqlName('SZC') + " SZC "
cQuery += "	WHERE "
cQuery += " 	ZC_FILIAL	= '" + xFilial('SZC')		+ "' 	AND "
cQuery += "		ZC_ANOMES 	= '" + cAnoMes				+ "' 	AND "

IF Left(cVendCombo,5) != 'TODOS'
	cQuery += " ZC_VEND 	= '" + Left(cVendCombo,6)	+ "' 	AND "
EndIF

cQuery += "		ZC_TIPO = '2' AND "
cQuery += "		D_E_L_E_T_ = '' "

IF Left(cVendCombo,5) == 'TODOS'
	cQuery += " GROUP BY ZC_ANOMES "
EndIF

cQuery += " ORDER BY ZC_ANOMES "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\CadMetaQuery.txt',cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	nMeta += TRB->VLRMETA
	DbSkip()
EndDo
TRB->(DbCloseArea())

RestArea(aArea)

Return(nMeta)                                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SyOrdena ³ Autor ³    			        ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena ao clicar na coluna da GetDados.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SYPMSC100                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SyOrdena(nPos,oGetDados,lOrdemCols,cOrig)

Local nPosProd	:= Ascan(oGetDados:aHeader,{|x| Alltrim(x[2]) == 'A1_PRODUTO' })
Local nPosCurva	:= Ascan(oGetDados:aHeader,{|x| Alltrim(x[2]) == 'A1_CURVA' })
Local nPosGrupo	:= Ascan(oGetDados:aHeader,{|x| Alltrim(x[2]) == 'A1_GRUPO' })

IF !lJaExecutou
	
	lJaExecutou := .T.
	lOrdemCols := !lOrdemCols
	
	IF cOrig == 'OP'
	
		IF lOrdemCols 
	    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] > y[nPos] } )
		Else
	    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] < y[nPos] } )
		EndIF
	
	Else // Clientes

		IF nPos == nPosProd
	
			IF lOrdemCols 
		    	aSort(oGetDados:aCols ,,, { |x,y| ( x[nPosProd] > y[nPosProd] ) .Or. ( x[nPosProd] == y[nPosProd] .And. x[nPosCurva] > y[nPosCurva] ) } )
			Else
		    	aSort(oGetDados:aCols ,,, { |x,y| ( x[nPosProd] < y[nPosProd] ) .Or. ( x[nPosProd] == y[nPosProd] .And. x[nPosCurva] < y[nPosCurva] ) } )
			EndIF

		ElseIF nPos == nPosCurva

			IF lOrdemCols 
		    	aSort(oGetDados:aCols ,,, { |x,y| ( x[nPosCurva] > y[nPosCurva] ) .Or. ( x[nPosCurva] == y[nPosCurva] .And. x[nPosProd] > y[nPosProd] ) } )
			Else
		    	aSort(oGetDados:aCols ,,, { |x,y| ( x[nPosCurva] < y[nPosCurva] ) .Or. ( x[nPosCurva] == y[nPosCurva] .And. x[nPosProd] < y[nPosProd] ) } )
			EndIF

		Else

			IF lOrdemCols 
		    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] > y[nPos] } )
			Else
	    		aSort( oGetDados:aCols ,,, {|x,y| x[nPos] < y[nPos] } )
			EndIF

		EndIF
	
	EndIF	
	
	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
	oGetDados:oBrowse:SetFocus()

Else

	lJaExecutou := .F.

EndIf

Return

Static Function MntPropostas(nOpcao,oGetOp,oFolderFilho)

Local aArea 	:= GetArea()
Local cProposta	:= oGetOp:aCols[oGetOp:nAt,aScan(oGetOp:aHeader,{|x| AllTrim(x[2]) == "Z02_PROPOS"})]
Local cAditivo	:= oGetOp:aCols[oGetOp:nAt,aScan(oGetOp:aHeader,{|x| AllTrim(x[2]) == "Z02_ADITIV"})]
Local nRet		:= 0

Private cCadastro 	:= ''

aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'AxInclui'			, 0,3} ,;
				{ 'Alterar'			,'AxAltera'			, 0,4} }

Private aTela[0][0]
Private aGets[0]

Inclui := .T.
Altera := .T.

// Incluir
IF nOpcao == 3

	U_AF02WIZARD(nOpcao)

Else

	DbSelectArea('Z02')
	DbSetOrder(1)
	IF !DbSeek( xFilial('Z02') + cProposta +cAditivo )
		MsgAlert('Proposta não encontrada: ' + cProposta + "/" + cAditivo)
		Return(.T.)
	EndIF

EndIF

IF nOpcao >= 2 .And. nOpcao <= 7 		// Vis, Inc, Alt, Exc e Copiar
	U_AF02WIZARD(nOpcao)
	
ElseIF nOpcao == 8 						// Imprimir
	U_AF02IMP()
	
ElseIF nOpcao == 9						// Aprovar
	U_AF02Aprov()
	
ElseIF nOpcao == 10 					// Cancelar Aprovacao
	U_AF02Canc()
	
ElseIF nOpcao == 11 					// Gerar Projeto
	U_SYPMSA04()
	
ElseIf nOpcao == 12
	DbSelectArea('SUS')
	
	IF !Empty(Z02->Z02_PROSPE)
		
		DbSetOrder(1)
		
		cProcpect := Z02->Z02_PROSPE + Z02->Z02_LOJAPR
		
	Else
		
		DbSetOrder(5)
		
		cProcpect := Z02->Z02_CLIENT + Z02->Z02_LOJA
		
	EndIF
	SUS->(DbSeek( xFilial('SUS') + cProcpect ))
	
	U_CRMA01Cal("SUS",SUS->(Recno()),4,cProposta,cAditivo)

ElseIf nOpcao == 13 //Aprovar Comissoes
	
	If !(Z02->Z02_STATUS $ '59') .Or. !Empty(Z02->Z02_DTCOMIS)
		Aviso("Atencao","Funcao permitida somente para propostas aprovadas!",{"Ok"})
	Else
		DbSelectArea("Z08")
		DbSetOrder(1)
		If DbSeek(xFilial("Z08")+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
			If Empty(Z08->Z08_NUM)
				If U_AF02WIZARD(nOpcao) .And. Aviso("Atencao","Aprova as Comissoes?",{"Sim","Nao"}) == 1
					U_SyAprvComis()
				EndIf
			Else
				Aviso("Atencao","Ja existem comissoes geradas para esta proposta!",{"OK"})
			EndIf
		Else
			SA3->(dbSetOrder(1))
			SA3->(dbSeek(xFilial("SA3")+Z02->Z02_VEND2))
			//Gera o Z08 apenas com o vendedor para acessar a rotina
			RecLock("Z08",.T.)
			Replace Z08_FILIAL With xFilial("Z08")
			Replace Z08_PROPOS With Z02->Z02_PROPOS
			Replace Z08_ADITIV With Z02->Z02_ADITIV
			Replace Z08_FORNEC With SA3->A3_FORNECE
			Replace Z08_LOJA With SA3->A3_LOJA
			Replace Z08_PERC With SA3->A3_COMIS
			Replace Z08_PARC With 4
			Replace Z08_DATA With dDataBase
			Replace Z08_HISTOR With "Comissao da Proposta " + Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV
			Replace Z08_QTPARC With 12
			MsUnlock()
			
		EndIf
	EndIf

ElseIf nOpcao == 14 //Exibe Historico de Reajuste
	U_ViewReajuste(Z02->Z02_CLIENT,Z02->Z02_LOJA)

ElseIf nOpcao == 15 //Encerrar Contrato
	If Aviso("Atencao","Confirma o Encerramento do Contrato Atual?",{"Sim","Nao"}) == 1
		U_FinalizaContrato(Z02->Z02_CLIENT,Z02->Z02_LOJA,Z02->Z02_PROPOS,Z02->Z02_ADITIV,"E")
	EndIf
ElseIf nOpcao == 16 //Cancelar Contrato
	If Aviso("Atencao","Confirma o Cancelamento do Contrato Atual?",{"Sim","Nao"}) == 1
		U_FinalizaContrato(Z02->Z02_CLIENT,Z02->Z02_LOJA,Z02->Z02_PROPOS,Z02->Z02_ADITIV,"C")
	EndIf

ElseIF nOpcao == 17	// Visualizar Contrato
	
	nRet :=	AxVisual('Z25',Z25->(Recno()),2,,,,,,,,,,,.T.,,,,,)
elseif nOpcao == 18	// handover
	
	U_AF02HANDOVER()

ElseIF nOpcao == 95	// Ajusta Contratos
	
	If Aviso("Atencao","Confirma o Ajuste dos Contratos?",{"Sim","Nao"}) == 1
		U_AjustaContratos()
	EndIf

ElseIF nOpcao == 97	// Incluir Lead
	
	nRet :=	AxInclui('SUS',SUS->(Recno()),3,,,,,,,,,,,.T.,,,,,)

ElseIF nOpcao == 98						// Alterar Cadastro de Cliente ou Prospect
	
	DbSelectArea('SUS')
	
	IF !Empty(Z02->Z02_PROSPE)
		
		DbSetOrder(1)
		
		cProcpect := Z02->Z02_PROSPE + Z02->Z02_LOJAPR
		
	Else
		
		DbSetOrder(5)
		
		cProcpect := Z02->Z02_CLIENT + Z02->Z02_LOJA
		
	EndIF
	
	IF DbSeek( xFilial('SUS') + cProcpect )
		
		nRet :=	AxAltera('SUS',SUS->(Recno()),4,,,,,,,,,,,.T.,,,,,)
		
	EndIF

ElseIf nOpcao == 99 //Teste
	U_EmailIncPro('APROVA',cProposta,cAditivo)
	//U_EmailIncPro('APROVA',cProposta,cAditivo)
EndIF

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EditaOpe    ³ Autor ³ Alexandro Dias  ³ Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Edita campos da Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function EditaOpe(oGetOp,aColsOp,cOrigem)

Local cProposta := oGetOp:aCols[oGetOp:nAt,aScan(oGetOp:aHeader,{|x| AllTrim(x[2]) == "Z02_PROPOS"})] 
Local cAditivo  := oGetOp:aCols[oGetOp:nAt,aScan(oGetOp:aHeader,{|x| AllTrim(x[2]) == "Z02_ADITIV"})] 

IF Alltrim(oGetOp:aHeader[oGetOp:oBrowse:ColPos,2]) $ 'Z02_VEND2/Z02_RAZAO/Z02_DESCRI/Z02_DOLAR'
		
	IF !lAdm .And. ( Alltrim(oGetOp:aHeader[oGetOp:oBrowse:ColPos,2]) == 'Z02_VEND2' )
		Return(.T.)
	EndIF
		
	DbSelectArea('Z02')
	DbSetOrder(1)
	IF DbSeek(xFilial('Z02')+cProposta)
		RecLock('Z02',.F.)
		FieldPut( FieldPos( oGetOp:aHeader[oGetOp:oBrowse:ColPos,2] ) , &( 'M->' + oGetOp:aHeader[oGetOp:oBrowse:ColPos,2] ) )
		MsUnLock()
	EndIF

	aColsOp := oGetOp:aCols
	
EndIF

Return(.T.) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuCli      ³ Autor ³ Alexandro Dias  ³ Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Edita campos do Cliente.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuCli(oGetCli)

Local aArea		:= GetArea()
Local nPosGrupo	:= aScan(oGetCli:aHeader,{|x| AllTrim(x[2]) == "A1_GRUPO"})
Local nPosCli 	:= aScan(oGetCli:aHeader,{|x| AllTrim(x[2]) == "A1_COD"})

Local nX, nColuna

For nX := 1 To Len(oGetCli:aCols)

	DbSelectArea('SA1')
	DbSetOrder(1)
	DbSeek( xFilial('SA1') + oGetCli:aCols[nX,nPosCli] )
	
	While !Eof() .And. ( xFilial('SA1') + oGetCli:aCols[nX,nPosCli] == SA1->A1_FILIAL + SA1->A1_COD )

		RecLock('SA1',.F.)
		
			For nColuna := 1 To Len(oGetCli:aHeader)-1
		
				FieldPut( FieldPos( oGetCli:aHeader[nColuna,2] ) , oGetCli:aCols[nX,nColuna] )

			Next
	
		MsUnLock()
	
		DbSkip()	
	
	EndDo	

Next

RestArea(aArea)

Return(.T.)

Static Function ListaClientes(oPanelCli,oGetCli,aHeaderCli,aColsCli,cVendCombo,nlOrdemCols,cVendaTp,dDtIni,dDtFim)

Local nX, cResto
Local aArea 	:= GetArea()
Local aCampos	:= {'A1_DTCAD','E1_EMISSAO','DIAS','A1_GRUPO','A1_CURVA','A1_PRODUTO','E1_VALOR','PAGO','E1_SALDO'}
Local aAlterCli	:= {}
Local cVenda	:= Left(cVendaTp,1)

IF !lAdm
	Return(.T.)
EndIF

aHeaderCli	:= {}
aColsCli	:= {}


DbSelectArea("SX3")
DbSetorder(2)
For nX := 1 To Len(aCampos)
	
	IF MsSeek(aCampos[nX])
		Aadd( aHeaderCli , { AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
		SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO } )
	EndIF
	
	IF aCampos[nX] == 'DIAS'
		Aadd(aHeaderCli,{"Inatividade","DIAS","@E 99,999",06,0,".F.","û","N","","","","" } )
		
	ElseIF aCampos[nX] == 'E1_VALOR'
		aHeaderCli[Len(aHeaderCli),1] := 'Faturamento'
		aHeaderCli[Len(aHeaderCli),3] := '@E 999,999,999'
		
	ElseIF aCampos[nX] == 'PAGO'
		Aadd(aHeaderCli,{"Recebido","PAGO",'@E 999,999,999',14,2,".F.","û","N","","","","" } )
		
	ElseIF aCampos[nX] == 'E1_SALDO'
		aHeaderCli[Len(aHeaderCli),1] := 'A Receber'
		aHeaderCli[Len(aHeaderCli),3] := '@E 999,999,999'
		
	ElseIF aCampos[nX] == 'E1_EMISSAO'
		aHeaderCli[Len(aHeaderCli),1] := 'Ult.Venda'
		
	EndIF
	
Next

Aadd(aHeaderCli,{"","XXX","@!"	,02,0,".F.","û","C","","V","","" } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os dados.						    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := " SELECT "
cQuery += " 	A1_GRUPO AS A1_GRUPO ,A1_CURVA, A1_PRODUTO , SUM(E1_VALOR) AS E1_VALOR , SUM(PAGO) AS PAGO , SUM(E1_SALDO) AS E1_SALDO , MAX(E1_EMISSAO) E1_EMISSAO , MIN(A1_DTCAD) A1_DTCAD "
cQuery += " FROM "
cQuery += 		RetSqlName('SA1') + " SA1, "
cQuery += " 	( "
cQuery += "   		SELECT "
cQuery += "   			E1_CLIENTE, MAX(E1_EMISSAO) E1_EMISSAO, SUM(E1_VALOR) AS E1_VALOR, SUM(E1_VALOR-E1_SALDO) AS PAGO , SUM(E1_SALDO) AS E1_SALDO "
cQuery += "   		FROM "
cQuery += 	    		RetSqlName('SE1') + " SE1 "
cQuery += "   		WHERE "
cQuery += "     		E1_FILIAL = '" + xFilial('SE1') + "' AND "
cQuery += " 			E1_EMISSAO >= '" + Dtos(dDtIni) + "' AND "
cQuery += " 			E1_EMISSAO <= '" + Dtos(dDtFim) + "' AND "
cQuery += "     		SUBSTRING(E1_TIPO,3,1) <> '-' AND "
cQuery += "     		SE1.D_E_L_E_T_ = '' " 
cQuery += "   		GROUP BY E1_CLIENTE "
cQuery += "   	) "
cQuery += "   	AS SE1 "
cQuery += "   	WHERE "
cQuery += " 		SA1.A1_FILIAL = '" + xFilial('SA1') + "' AND "
cQuery += " 		SA1.A1_COD = SE1.E1_CLIENTE AND "

IF cVenda == 'V' 		// Clientes TOTVS
	cQuery += " SA1.A1_PRODUTO = '1' AND "
ElseIF cVenda == 'S' 	// Clientes SAP
	cQuery += " SA1.A1_PRODUTO = '2' AND "
Else
	cQuery += " SA1.A1_PRODUTO <> '3' AND "
EndIF

IF ( Left(cVendCombo,5) != 'TODOS' ) 
	cQuery += " SA1.A1_VEND = '" + Left(cVendCombo,6)	+ "' AND "
EndIF

cQuery += " SA1.D_E_L_E_T_ = '' "
cQuery += " GROUP BY A1_GRUPO, A1_PRODUTO, A1_CURVA "
cQuery += " ORDER BY A1_GRUPO, E1_EMISSAO "
cQuery := ChangeQuery(cQuery)

MemoWrite('C:\Propostas\FatCliQuery.txt',cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra os dados conforme a selecao do usuario.	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "E1_EMISSAO"	, "D" , 8 , 0 )
TcSetField("TMP", "A1_DTCAD"	, "D" , 8 , 0 )

While !TMP->(Eof())
	
	Aadd(aColsCli,Array(Len(aHeaderCli)+1))
	
	For nX	:= 1 To Len(aHeaderCli)
		
		IF AllTrim(aHeaderCli[nX,2]) == "DIAS"
			
			IF Empty(TMP->E1_EMISSAO)
				aColsCli[Len(aColsCli),nX] := 0
			Else
				aColsCli[Len(aColsCli),nX] := dDataBase - TMP->E1_EMISSAO
			EndIF

		ElseIF AllTrim(aHeaderCli[nX,2]) == "PAGO"
			aColsCli[Len(aColsCli),nX] := TMP->PAGO

		ElseIF AllTrim(aHeaderCli[nX,2]) == "XXX"
			aColsCli[Len(aColsCli),nX] := ''
		
		ElseIF ( aHeaderCli[nX,10] != "V" )
			aColsCli[Len(aColsCli),nX] := TMP->( FieldGet(FieldPos(aHeaderCli[nX,2])) )
		
		Else
			aColsCli[Len(aColsCli),nX] := CriaVar(aHeaderCli[nX,2])
		
		EndIF
		
		IF AllTrim(aHeaderCli[nX,2]) == "A1_GRUPO"
			
			IF Empty( aColsCli[Len(aColsCli),nX] )
				aColsCli[Len(aColsCli),nX] := 'XXXXXX'
			EndIF
		
		ElseIF AllTrim(aHeaderCli[nX,2]) == "A1_CURVA"
			
			IF Empty( aColsCli[Len(aColsCli),nX] )
				aColsCli[Len(aColsCli),nX] := 'C'
			EndIF
        
        EndIF
	
	Next nX

	aColsCli[Len(aColsCli),Len(aHeaderCli)+1] := .F.

	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

IF Len(aColsCli) <= 0
	Aadd(aColsCli,Array(Len(aHeaderCli)+1))
	For nX := 1 To Len(aHeaderCli)
		
		IF AllTrim(aHeaderCli[nX,2]) $ "XXX/A1_GRUPO/A1_CURVA/A1_PRODUTO"
			aColsCli[Len(aColsCli),nX] := 'X'
		
		ElseIF AllTrim(aHeaderCli[nX,2]) $ "PAGO/DIAS"
			aColsCli[Len(aColsCli),nX] := 0
			
		Else
			aColsCli[Len(aColsCli),nX] := CriaVar(aHeaderCli[nX,2],.F.)
		EndIF
	Next nX
	aColsCli[Len(aColsCli),Len(aHeaderCli)]   := IIF( Len(aColsCli) == 1 , 'X' , '' )
	aColsCli[Len(aColsCli),Len(aHeaderCli)+1] := .F.
EndIF

IF Type('oGetCli') != 'U'
	oGetCli:Destroy()
EndIF

oGetCli:=MsNewGetDados():New(0,0,0,0,GD_UPDATE,"Allwaystrue","Allwaystrue","",aAlterCli,,,,,,oPanelCli,@aHeaderCli,@aColsCli)
oGetCli:oBrowse:bHeaderClick := { |oObj,nCol| U_SyOrdena(nCol,@oGetCli,@nlOrdemCols,'CL') }
oGetCli:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGetCli:bChange := {||	GRfCor(1,oGetCli) }
oGetCli:oBrowse:SetBlkBackColor( { || GRfCor(2,oGetCli) } )
oGetCli:oBrowse:SetBlkColor( { || GRfCor(3,oGetCli) } )
oGetCli:oBrowse:Refresh()
oGetCli:oBrowse:GoTop()

RestArea(aArea)

Return(.T.)



//user function AFZ02TELA()
//
//return
