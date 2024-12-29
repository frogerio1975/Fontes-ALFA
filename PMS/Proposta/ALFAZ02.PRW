#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"
#Include "vkey.ch"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4
#Define MAXGETDAD 99999
#Define MAXSAVERESULT 999

#Define cEOL CHR(13) + CHR(10)

#Define ZOOFLAG		1
#Define Z00SEQ     	2
#Define Z00MODULO  	3
#Define Z00DESCRI  	4
#Define Z00CODM1   	5
#Define Z00CUSTO   	6
#Define Z00PRCTAB  	7
#Define Z00HORAS   	8
#Define Z00FORNEC	9
#Define Z00MODAL   10
#Define Z00PRCVEN  11

#Define MOD_FLAG	1
#Define MOD_FORNEC  2
#Define MOD_DESCRI  3
#Define MOD_PRCVEN  4
#Define MOD_CUSTO   5
#Define MOD_HORAS   6
#Define MOD_LIMMIN 	7
#Define MOD_LIMMAX  8
#Define MOD_MODULO	9
#Define MOD_SEQ   	10

#Define TITMOD		1
#Define TITDATA		2
#Define TITVALOR	3
#Define TITHIST		4
#Define TITQTDPAR	5
#Define TITPARCEL	6

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � ALFAZ02  � Autor �                    � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Cadastro de Propostas        							  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function ALFAZ02(nFolderOp,oGetOp)

Local aAlias 		:= GetArea()
Local aCores		:= {}
Local cVendedor 	:= Posicione('SA3',7,xFilial('SA3')+__cUserID,'A3_COD')
Local aGrp			:= UsrRetGrp(UsrRetName(__cUserID))
Local aGroups     	:= AllGroups()
Local nAviso		:= 0
Local cFilSymm		:= ''
Local cRazao		:= ''
Local cGrp			:= ''
Local nI

Private lAdm	   := .F.
Private bFiltraBrw := {}
Private aIndexMa   := {}
Private aHeader    := {}
Private aHeaderZ03 := {}
Private aColsZ03   := {}
Private aHeaderZ05 := {}
Private aColsZ05   := {}
Private aHeaderZ04 := {}
Private aColsZ04   := {}
Private aHeaderZ08 := {}
Private aColsZ08   := {}
Private aHeaderSU5 := {}
Private aColsSU5   := {}
Private aHeadEscopo:= {}
Private aColsEscopo:= {}
Private aHeadResumo:= {}
Private aColsResumo:= {}
Private aSaveEscopo:= {}
Private lSobrepoe  := .F.
Private lLicenca   := .F.
Private lServico   := .F.
Private lSD        := .F.
Private lSAP       := .F.
Private lTOTVS     := .F.
Private aGets2[0]

Aadd(aCores,{ "Z02_STATUS == '1' " , 'BR_BRANCO' 		}) //
Aadd(aCores,{ "Z02_STATUS == '2' " , 'BR_PINK'	 		}) //
Aadd(aCores,{ "Z02_STATUS == '3' " , 'BR_LARANJA' 		}) //
Aadd(aCores,{ "Z02_STATUS == '4' " , 'BR_AMARELO' 		}) //
Aadd(aCores,{ "Z02_STATUS == '5' " , 'BR_AZUL'	 		}) //5=Aprovado;
Aadd(aCores,{ "Z02_STATUS == '6' " , 'BR_VERMELHO' 		}) //6=Suspenso;
Aadd(aCores,{ "Z02_STATUS == '7' " , 'BR_PRETO' 		}) //7=Perdida;     
Aadd(aCores,{ "Z02_STATUS == '9' " , 'BR_VERDE'		 	}) //9=Gerou Projeto     
//1=Leads Qualificado;2=Desqualificado;3=Em Negociacao;5=Aprovados;6=Suspensos;7=Perdidos;9=Projeto Gerado;C=Cancelado;E=Encerrado
aRotina:= MenuDef(aGrp)

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//� Filtra grupos.                                              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
For nI:= 1 To Len(aGroups)
	IF 	(AllTrim(Upper((aGroups[nI,1,2]))) == "ADMINISTRADORES") .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "PMO")  .Or.;
		(AllTrim(Upper((aGroups[nI,1,2]))) == "COORDENACAO_COMERCIAL") 
		cGrp+= aGroups[nI,1,1] + "/"
	EndIF
Next nI

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//覓erifica se o usuario pertence ao grupo de administradores.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
IF (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" )
	lAdm := .T.

ElseIF !Empty(cGrp)
	For nI:= 1 To Len(aGrp)
		If aGrp[nI] $ cGrp
			lAdm:= .T.
		EndIf
	Next nI
EndIf 

IF !lAdm .And. Empty(cVendedor)
	MsgAlert('Op誽o N緌 Permitida. O seu Usu嫫io n緌 esta Associado a nenhum Vendedor.')
	Return(.T.)
EndIF

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Mostra somente as contas do Vendedor.                             	   �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF !lAdm
	cFilSymm += " Z02_VEND2 == '" +cVendedor+ "' "
EndIF

IF (oGetOp != Nil)
	
	IF nFolderOp != 1
	
		cRazao	:= Alltrim( oGetOp:aCols[oGetOp:nAt,aScan(oGetOp:aHeader,{|x| AllTrim(x[2]) == "Z02_RAZAO"})] )	
		nAviso	:= Aviso( "Filtro de Oportunidades" , "Mostrar somente as Oportunidades de: " +cRazao+ "?" , {"Sim", "N嫪","Cancelar"} )
		
		IF nAviso == 1
			IF Empty(cFilSymm)
				cFilSymm := " Alltrim(Z02_RAZAO) == '" +cRazao+ "' "
			Else
				cFilSymm += " .And. Alltrim(Z02_RAZAO) == '" +cRazao+ "' "
			EndIF	
		ElseIF nAviso == 3
			Return(.T.)
		EndIF
		
	EndIF
	
EndIF

bFiltraBrw := {|| FilBrowse("Z02",@aIndexMa,@cFilSymm)}
Eval( bFiltraBrw )

DbSetOrder(1)  
mBrowse(6, 1, 22, 75,"Z02",,,,,,aCores)  

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF !lAdm
	EndFilBrw("Z02",aIndexMa)
EndIF

RestArea(aAlias)

Return

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � MENUDEF  � Autor �                    � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao �                 							                  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function MenuDef(aGrp)

Local aRotina := {}
Local aRot001 := {}
Local cUserHandover:= SuperGetMv("AF_USRHAND",.F.,"000000")

Aadd( aRot001 , { 'Proposta - Visualizar'			, "U_AF02WIZARD(2)" , 0 , 2} )
Aadd( aRot001 , { 'Proposta - Incluir'				, "U_AF02WIZARD(3)" , 0 , 3} )
Aadd( aRot001 , { 'Proposta - Alterar'				, "U_AF02WIZARD(4)" , 0 , 4} )
Aadd( aRot001 , { 'Proposta - Excluir'				, "U_AF02WIZARD(5)" , 0 , 5} )
Aadd( aRot001 , { 'Proposta - Copiar'				, "U_AF02WIZARD(6)"	, 0 , 6} )
Aadd( aRot001 , { 'Proposta - Imprimir'				, "U_AF02IMP()" 	, 0 , 7} )
Aadd( aRot001 , { 'Proposta - Aprovar'				, "U_AF02Aprov()" 	, 0 , 8} )
Aadd( aRot001 , { 'Proposta - Cancelar Aprova誽o'	, "U_AF02Canc()" 	, 0 , 9} )	
Aadd( aRot001 , { 'Proposta - Aditivo'				, "U_AF02WIZARD(7)" , 0 , 10} )	

Aadd( aRotina,	{ 'Pesquisar'	 	, "PesqBrw" 	 	, 0 , 	01,,.F. })
Aadd( aRotina,	{ 'Follow-up'		, "U_CRMA01Cal"		, 0 , 	03 }) 
Aadd( aRotina,	{ 'Gerar Projeto'	, "U_SYPMSA04()"	, 0 , 	06,,.F. }) 
Aadd( aRotina,	{ 'Propostas'	 	, aRot001		 	, 0 , 	03 })           

IF lAdm
	Aadd( aRot001 , { 'Proposta - Aprovar Comissoes'	, "U_SyAprComis()" 	, 0 , 8} )
	Aadd( aRotina,	{ "Desempenho"	 , "U_SYCRMA02"	 	, 0 ,	10,,.F. })
EndIF

//If __cUserID $ cUserHandover	
//	Aadd( aRotina,	{ 'HANDOVER - Aprovar'	 	, "U_AF02HANDOVER()" 	 	, 0 , 	01,,.F. })
//End

Return(aRotina)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  莧F02WIZARD� Autor �                    � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Wizard para montagem de proposta			                  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function AF02WIZARD(nOpcMenu)

Local oDlg
Local oALFA             := LoadBitmap( nil, "ALFA" ) 
Local aArea				:= GetArea()
Local aBCposAlt 		:= {}
Local aBCposVis 		:= {}
Local aRotBKP   		:= aClone(aRotina)
Local aSizeDlg  		:= MsAdvSize()
Local cCopiarDaProposta := ''
Local cProposta         := ""
Local cAditivo          := ""
Local nGrava 			:= 0

Private INCLUI
Private ALTERA

Private oFntP 			:= TFont():New( "Arial",,18,,.T.,,,,,.F.)
Private oFntSay 		:= TFont():New( "Arial",,14,,.T.,,,,,.F.)
Private oProposta
Private oContatos
Private oWizard
Private oFldEscopo
Private oFldPagto
Private oEscopo
Private oResumo
Private oParcelas
Private oNumParcelas
Private oHrTot
Private oTotTabela
Private oCustoTotal
Private oComissoes
Private oComis
Private oDetalhe
Private oDesconto
Private oPercDesconto
Private oLucro
Private oPercLucro
Private oSubTotal
Private oTotal
Private oVlrEscopo

Private nOpc			:= nOpcMenu
Private nStyle 			:= GD_INSERT+GD_UPDATE+GD_DELETE
Private nQtdUser		:= 0
Private nNumParcelas	:= 0
Private nHrCoord  		:= 0
Private nHrConsult 		:= 0
Private nHrCoordFS 		:= 0
Private nHrDesenv 		:= 0
Private nTotHrsProj		:= 0
Private nTotTabela		:= 0
Private nTotSetup 		:= 0 
Private nCustoTotal		:= 0
Private nComissoes		:= 0
Private nDesconto		:= 0
Private nPercDesconto	:= 0
Private nDscTotal		:= 0
Private nPercDscTotal	:= 0
Private nLucro			:= 0 
Private nPercLucro		:= 0
Private nSubTotal		:= 0
Private nValorTotal    	:= 0
Private nImpostos		:= M->Z02_IMPOST

Private aGETS[0],aTELA[0]
Private aPanel[3]
Private aHeaderSU5 := {}
Private aColsSU5   := {}
Private aHeaderZ03 := {}
Private aColsZ03   := {}
Private aHeaderZ04 := {}
Private aColsZ04   := {}
Private aHeaderZ05 := {}
Private aColsZ05   := {}
Private aHeaderZ08 := {}
Private aColsZ08   := {}
Private aHeadEscopo:= {}
Private aColsEscopo:= {}
Private aHeadResumo:= {}
Private aColsResumo:= {}
Private aSaveEscopo:= {}
Private lSobrepoe  := .F.
Private lLicenca   := .F.
Private lServico   := .F.
Private lSD        := .F.
Private lSAP       := .F.
Private lTOTVS     := .F.

aRotina := { 	{"Pesquisar","AxPesqui",0,1} 	,;
				{"Visualizar","AxVisual",0,2}	,;
				{"Incluir","AxInclui",0,3} 		,;
				{"Alterar","AxAltera",0,4} 		,;
				{"Excluir","AxDeleta",0,5} 		,;
				{"Copiar","",0,6} 				,;
				{"Copiar","",0,7} 				,;
				{"Copiar","",0,8} 				,;
				{"Copiar","",0,9} 				,;
				{"Copiar","",0,10} 				,;
				{"Copiar","",0,11} 				,;
				{"Copiar","",0,12} 				,;
				{"Copiar","",0,13} 				,;
				{"Aprovacao de Comissoes","",0,14}}

//術ao permite alterar proposta aprovada.�
 IF !(nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7 .Or. nOpc == 14) .And. ( Z02->Z02_STATUS $ '5/9' )
	MsgAlert('N緌 � possivel alterar Propostas Aprovadas. Proposta ser� exibida em modo de Visualiza誽o!')
	nOpc := 2
EndIF

//術ao permite criar aditivo de outro aditivo.�
 IF (nOpc == 7) .And. ( Z02->Z02_ADITIV <> '00' )
	MsgAlert('Somente � possivel criar aditivo a partir do contrato original. Proposta ser� exibida em modo de Visualiza誽o!')
	nOpc := 2
EndIF

//袖o permite gerar Aditivo de Proposta APROVADA.�
IF (nOpc == 7) .And. !( Z02->Z02_STATUS $ '5/9' ) .And. ( Z02->Z02_ADITIV == '00' )
	MsgAlert('Somente � possivel gerar aditivo de Proposta APROVADA!')
	aRotina := aClone(aRotBKP)
	Return(.F.)
EndIF

//袖o permite excluir propostas com o status de Aberta.�
IF (nOpc == 5) .And. ( Z02->Z02_STATUS $ '5/9' )
	MsgAlert('N緌 � possivel excluir Propostas Aprovadas.')
	aRotina := aClone(aRotBKP)
	Return(.F.)
EndIF

//Visualizacao ou Exclusao
IF nOpc == 2 .Or. nOpc == 5
	INCLUI := .F.
	ALTERA := .F.
//Inclusao, C鏕ia ou Aditivo
ElseIF nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 7
	INCLUI := .T.
	ALTERA := .F.
//Demais Opcoes
Else
	INCLUI := .F.
	ALTERA := .T.
EndIF

//Se for Inclusao, ALteracao, Copia, Aditivo permitira editar os objetos GRID
IF (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 .Or. nOpc == 14)
	nStyle := GD_INSERT+GD_UPDATE+GD_DELETE
Else
	nStyle := 0
EndIF

//Atualiza os Vetores que Permitirao a Edicao do Campos do Cabecalho da Proposta
SX3->(DbSetOrder(1))
SX3->(DbSeek('Z02'))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'Z02'
	
	IF ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )

		IF Alltrim(SX3->X3_CAMPO) $ "Z02_STATUS"
			Aadd(aBCposVis,SX3->X3_CAMPO)
		Else
			Aadd(aBCposAlt,SX3->X3_CAMPO)
			Aadd(aBCposVis,SX3->X3_CAMPO)
			
		EndIF
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo
Aadd( aBCposVis , 'NOUSER' )
Aadd( aBCposVis , 'NOUSER' )

//Carrega os campos do cadastro da Proposta para as variaveis de memoria
RegToMemory("Z02",IIF(nOpc == 3,.T.,.F.))

//� Inicializa os campos principais do cabecalho dependendo do tipo da proposta 
//Inclusao de Novo Contrato
If (nOpc == 3)
	cProposta:= M->Z02_PROPOS
	cAditivo := "00"
	cMay := "Z02"+ Alltrim(xFilial("Z02"))
		
	While ( DbSeek(xFilial("Z02")+cProposta) .Or. !MayIUseCode(cMay+cProposta) )
		cProposta := GetSxeNum('Z02','Z02_PROPOS')
	EndDo
		
	ConfirmSX8()
	M->Z02_PROPOS := cProposta
	M->Z02_ADITIV := cAditivo
	M->Z02_TPCONT := "1" //Contrato
		
	M->Z02_TXTTIT := AfTxtProp('TITULO')
	M->Z02_TXTOBJ := AfTxtProp('OBJETIVO')
	M->Z02_TXTGER := AfTxtProp('GERAIS')
	M->Z02_TXTRES := AfTxtProp('RESTRICOES')
	M->Z02_TXTPRE := AfTxtProp('PREMISSAS')
	M->Z02_TXCONT := AfTxtProp('CONTRATO')

//Copia de Proposta
ElseIF nOpc == 6
	
	cCopiarDaProposta	:= Z02->Z02_PROPOS
	cProposta			:= GetSXENum("Z02","Z02_PROPOS")
	cAditivo            := "00"
	M->Z02_PROPOS 		:= cProposta
	M->Z02_ADITIV       := cAditivo
	M->Z02_STATUS 		:= '3'
	M->Z02_DATAOP 		:= CriaVar("Z02_DATAOP",.T.)
	M->Z02_DTAPRO 		:= CriaVar("Z02_DTAPRO",.T.)
	M->Z02_PROJET 		:= CriaVar("Z02_PROJET",.T.)
	M->Z02_PRVFEC 		:= CriaVar("Z02_PRVFEC",.T.)

	M->Z02_TXTTIT := AfTxtProp('TITULO')
	M->Z02_TXTOBJ := AfTxtProp('OBJETIVO')
	M->Z02_TXTGER := AfTxtProp('GERAIS')
	M->Z02_TXTRES := AfTxtProp('RESTRICOES')
	M->Z02_TXTPRE := AfTxtProp('PREMISSAS')
	M->Z02_TXCONT := AfTxtProp('CONTRATO')
//Aditivo de Contrato Existente
ElseIF nOpc == 7
	
	cProposta			:= Z02->Z02_PROPOS
	cAditivo            := Z02->Z02_ADITIV
	M->Z02_PROPOS 		:= cProposta
	M->Z02_ADITIV       := ProximoAditivo(cProposta)
	M->Z02_STATUS 		:= '3'
	M->Z02_DATAOP 		:= CriaVar("Z02_DATAOP",.T.)
	M->Z02_DTAPRO 		:= CriaVar("Z02_DTAPRO",.T.)
	M->Z02_PROJET 		:= CriaVar("Z02_PROJET",.T.)
	M->Z02_PRVFEC 		:= CriaVar("Z02_PRVFEC",.T.)
	M->Z02_TPCONT       := "2" //Aditivo

	M->Z02_TXTTIT := AfTxtProp('TITULO')
	M->Z02_TXTOBJ := AfTxtProp('OBJETIVO')
	M->Z02_TXTGER := AfTxtProp('GERAIS')
	M->Z02_TXTRES := AfTxtProp('RESTRICOES')
	M->Z02_TXTPRE := AfTxtProp('PREMISSAS')
	M->Z02_TXCONT := AfTxtProp('CONTRATO')

Else	
	cProposta:= Z02->Z02_PROPOS
	cAditivo := Z02->Z02_ADITIV
	nDscTotal:= Z02->Z02_DSCTOT
	nTotSetup:= Z02->Z02_VLRSET
EndIF


//矬闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//彪riacao da Tela Principal
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡囁
//矬闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//彪riacao do Wizard principal.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡囁
oWizard:= APWizard():New( 	"Wizard para Cadastro de Propostas - "+aRotina[nOpc,1]	,;
							"Identifica誽o da Proposta",;
						  	"Preencha os dados para elabora誽o da proposta: " + M->Z02_PROPOS + '/' + M->Z02_ADITIV ,;
							 ,;
							 {|| VldCapaProposta(nOpc,cCopiarDaProposta,oWizard,cProposta,cAditivo) },; 
							 {|| .F. } ,.T.,"ALFA" , , .T.,{000,000,aSizeDlg[6]-40,aSizeDlg[5]} )
//----------------------
// Cria objetos da Pagina 1
//----------------------
CriaCabecalho(oWizard,nOpc,aBCposAlt,aBCposVis,cProposta,cAditivo)

//----------------------
// Cria o Panel da Pagina 2 que contera o Escopo dos Modulos
//----------------------*/
CREATE PANEL oWizard  HEADER "Escopo da Proposta" MESSAGE "" ;
	BACK   {|| AF02Back(oWizard,nOpc,M->Z02_PROPOS, M->Z02_ADITIV), .T.};
	NEXT   {|| AF02MontaResumo(oWizard:GetPanel(3),nOpc,M->Z02_PROPOS, M->Z02_ADITIV) };
	FINISH {|| .F. } PANEL
		

//----------------------
// Cria o Panel da Pagina 3 que contera o Resumo Financeiro da Proposta
//----------------------*/
CREATE PANEL oWizard  HEADER "Resumo da Proposta" MESSAGE "" ;
	BACK   {|| AF02Back(oWizard,nOpc,M->Z02_PROPOS, M->Z02_ADITIV), .T.};
	NEXT   {|| .F. };
	FINISH {|| IIF( AF02ValResumo(nOpc,.F.) , IIf(AF02Grv(oWizard,nOpc),(nGrava:= 1,.T.),.F.) , .F. ), IIf(AF02ValResumo(nOpc,.T.),.T.,.F.)} PANEL

ACTIVATE WIZARD oWizard CENTERED WHEN {||.T.}

IF (nGrava == 1)
	lRet:= .T.
	ConfirmSX8()
Else
	lRet:= .F.
	RollBackSX8()
EndIF

aRotina := aClone(aRotBKP)

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋芼控
控摺rograma  � CriaPanel � Autor �                    � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋迋芧控
控慣escricao � Cria Panels Dinamicamente    			                   滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function CriaPanel(oWizard,nOpc,cProposta,cAditivo)

IF lLicenca //Licencas
	aPanel[2]:= Nil
	aPanel[3]:= oWizard:GetPanel(3)
	AF02MontaResumo(aPanel[3],nOpc,cProposta,cAditivo)
	oWizard:nPanel:= 2 //Seta o painel ativo para 2 para que o sistema faca o incremento
Else
	oWizard:nPanel:= 1 //Seta o painel ativo para 1 para que o sistema faca o incremento

	aPanel[2]:= oWizard:GetPanel(2)	
	AF02Escopo(aPanel[2],nOpc,cProposta,cAditivo)


EndIf

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋芼控
控摺rograma  � CriaCabecalho � Autor �                � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋迋芧控
控慣escricao � Constru誽o da p墔ina 1	    			                   滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function CriaCabecalho(oWizard,nOpc,aBCposAlt,aBCposVis,cProposta,cAditivo)

Local oPnlCli
Local oPnlContato
Local oLayerCab
Local aAlterSU5   := {}

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//袈anel 1. - IdentIFicacao Proposta �	
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 .Or. nOpc == 14 )
	Aadd(aAlterSU5,"U5_CONTAT")
	Aadd(aAlterSU5,"U5_SOBREN")
	Aadd(aAlterSU5,"U5_EMAIL")
	Aadd(aAlterSU5,"U5_DDD")
	Aadd(aAlterSU5,"U5_FCOM1")
	Aadd(aAlterSU5,"U5_CELULAR")
	Aadd(aAlterSU5,"U5_FUNCAO")
	Aadd(aAlterSU5,"U5_XAPROV")
EndIf

aPanel[1]:= oWizard:GETPANEL(1)
MontaSU5(@aColsSU5,@aHeaderSU5,M->Z02_TIPO)

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴admin
//蛉onta os dados do cliente e contatos.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
aSize := MsAdvSize()

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .F. } )
AAdd( aObjects, { 070, 100, .F., .T. } )
AAdd( aObjects, { 100, 015, .T., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPosObj[1][3] := 200 //230

oLayerCab := FWLayer():New()
oLayerCab:Init(aPanel[1],.F.)

oLayerCab:addLine ( "Lin1", 60, .F.)
oLayerCab:addLine ( "Lin2", 40, .F.)

oLayerCab:addCollumn("Col1",100	, .T. , "Lin1")
oLayerCab:addCollumn("Col1",100	, .T. , "Lin2")

oLayerCab:addWindow("Col1", "Win1", "IDENTIFICACAO DO CLIENTE",100, .F., .T., , "Lin1")
oLayerCab:addWindow("Col1", "Win1", "IDENTIFICACAO DOS CONTATOS",100, .F., .T., , "Lin2")

oPnlCli    := oLayerCab:GetWinPanel("Col1","Win1","Lin1")
oPnlContato:= oLayerCab:GetWinPanel("Col1","Win1","Lin2")

oProposta:=	MsMGet():New("Z02",Z02->(Recno()),IIF(nOpc == 7,3,nOpc),,,,aBCposVis,aPosObj[1],aBCposAlt,3,,,,oPnlCli,,.F.,.T.)
oProposta:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oContatos:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue",,aAlterSU5,,99999,,,,oPnlContato,@aHeaderSU5,@aColsSU5)
oContatos:oBrowse:Refresh()
oContatos:nAt:= 1
oContatos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oContatos:bChange := {|| SetaContato(nOpc,@oProposta)}

//dDataBase:= Date()

//Se for Aditivo ajusta a numeracao do aditivo
If (nOpc == 7)
	M->Z02_PROPOS:= cProposta
	M->Z02_ADITIV:= ProximoAditivo(cProposta)
	oProposta:oBox:Refresh()
EndIf

Return

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋芼控
控摺rograma  � AF02Back      � Autor �                � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋迋芧控
控慣escricao �                      	    			                   滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function AF02Back(oWizard,nOpc,cProposta,cAditivo)
Local nPModulo:= 0
Local nPID    := 0
Local cModulo := ""
Local cID     := ""
Local nZ05    := 0

//Se for licenca vai pra tela inicial
If lLicenca
	oWizard:nPanel:= 2
ElseIf Type("oResumo") <> "U"
	nPModulo:= aScan(oResumo:aHeader,{|x| Alltrim(x[2]) == "Z05_MODULO" })
	nPID    := aScan(oResumo:aHeader,{|x| Alltrim(x[2]) == "Z05_ID" })

	cModulo:= oResumo:aCols[oResumo:nAT,nPModulo]
	cID    := oResumo:aCols[oResumo:nAT,nPID]

	oEscopo:aCols:= aClone(oResumo:aCols)
	oEscopo:nAt  := oResumo:nAt
	oEscopo:oBrowse:Refresh()
	oEscopo:Refresh()

	oResumo:= NIL

	//Atualiza o detalhe dos modulos
	MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cID,cModulo,cProposta,cAditivo)
	oDetalhe:aCols:= aColsZ03
	oDetalhe:oBrowse:Refresh()
EndIf


Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋芼控
控摺rograma  � AF02Escopo    � Autor �                � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋迋芧控
控慣escricao �                      	    			                   滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function AF02Escopo(oPanel,nOpc,cProposta,cAditivo)

Local nI,nI2,nA
Local nPos      	:= 0
Local aAlterZ03 	:= {}
Local aAlterZ05 	:= {}
Local nPVlrTab  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nPVlHrFim 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local nPTotal   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPCustoT	 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
Local nPrcTabela   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nQuantidade	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local lRet			:= .T.

nTotHrsProj		:= 0
nTotTabela		:= 0
nCustoTotal		:= 0
nDesconto		:= 0

nNumParcelas 	:= IIF( Val(M->Z02_CONDPG) == 0 ,1, Val(M->Z02_CONDPG) )
nImpostos       := M->Z02_IMPOST

//Carrega os Acols Principal (Itens da Z05 -  Escopo de Projeto)
IF Len(aColsZ05) == 0
	aSaveEscopo:= {}
	MontaZ05(@aColsZ05,@aHeaderZ05,nOpc,M->Z02_TIPO,cProposta,cAditivo)
	aHeadEscopo:= aClone(aHeaderZ05)
	aColsEscopo:= aClone(aColsZ05)
EndIf	

IF ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 .Or. nOpc == 14 )
	
	Aadd(aAlterZ05,"Z05_CUSTO")
	Aadd(aAlterZ05,"Z05_SEQ")
	Aadd(aAlterZ05,"Z05_PRCTAB")
	Aadd(aAlterZ05,"Z05_OBSERV")
	Aadd(aAlterZ05,"Z05_MOD")
	Aadd(aAlterZ05,"Z05_MODULO")
	Aadd(aAlterZ05,"Z05_DESCRI")
	Aadd(aAlterZ05,"Z05_VLHRDE")
	Aadd(aAlterZ05,"Z05_QUANT")
	Aadd(aAlterZ05,"Z05_PERDES")		
	Aadd(aAlterZ05,"Z05_VALDES")		
	Aadd(aAlterZ05,"Z05_OBSERV")		
	
	Aadd(aAlterZ03,"Z03_ESCOPO")
	Aadd(aAlterZ03,"Z03_HORAS")
	Aadd(aAlterZ03,"Z03_SUBMEN")
	Aadd(aAlterZ03,"Z03_PROCES")
	Aadd(aAlterZ03,"Z03_ORDEM")
	Aadd(aAlterZ03,"Z03_FASE")
	Aadd(aAlterZ03,"Z03_MEMO")
	
EndIF

SetKey(VK_F8 ,{||  U_AFMODULOS()    })

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//蛉onta o resumo do escopo do projeto.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
oEscLayer := Nil
oEscLayer := FWLayer():New()
oEscLayer:Init(oPanel,.F.)

oEscLayer:addLine ( "Lin1", 40, .F.)
oEscLayer:addLine ( "Lin2", 60, .F.)

oEscLayer:addCollumn("Col1",100	, .T. , "Lin1")
oEscLayer:addCollumn("Col1",100	, .T. , "Lin2")

oEscLayer:addWindow("Col1", "Win1", "ESCOPO DA PROPOSTA - F8 PARA ADICIONAR MODULOS"	,100, .F., .T., , "Lin1")
oEscLayer:addWindow("Col1", "Win1", "DETALHE DO ESCOPO"	,100, .F., .T., , "Lin2")

oPnlEscopo := Nil
oPnlDetalhe:= Nil
oPnlEscopo := oEscLayer:GetWinPanel("Col1","Win1","Lin1")
oPnlDetalhe:= oEscLayer:GetWinPanel("Col1","Win1","Lin2")

nStyle:= GD_INSERT+GD_UPDATE+GD_DELETE
oEscopo:= Nil
oEscopo:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue","+Z05_ID",aAlterZ05,,99999,,,,oPnlEscopo,@aHeadEscopo,@aColsEscopo)
oEscopo:nAt:= 1
oEscopo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oEscopo:bFieldOk  	  := {|| BrwCor(1,@oEscopo) .And. Z05Change(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cProposta,cAditivo) .And. Z05CalculaValores(nOpc,@oEscopo)}
oEscopo:bChange  	  := {|| BrwCor(1,@oEscopo) .And. Z05Change(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cProposta,cAditivo) .And. Z05CalculaValores(nOpc,@oEscopo)}
oEscopo:oBrowse:bDelOk := {|| (Z05DelOk(@oEscopo),Z05CalculaValores(nOpc,@oEscopo),BrwCor(1,@oEscopo))}
oEscopo:oBrowse:SetBlkBackColor( { || BrwCor(2,@oEscopo) } )
oEscopo:oBrowse:SetBlkColor( { || BrwCor(3,@oEscopo) } )
oEscopo:oBrowse:Refresh()


bColor 		:= &("{|| U_AF02CorBrw(@oDetalhe,1) }")
bColorFont	:= &("{|| U_AF02CorBrw(@oDetalhe,2) }")

oDetalhe:= Nil
oDetalhe:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue","AllWaysTrue","+Z03_NITEM",aAlterZ03,,99999,,,,oPnlDetalhe,@aHeaderZ03,@aColsZ03)
oDetalhe:bLinhaOk  	   := {|| Z03LinhaOK()}
oDetalhe:bFieldOk  	   := {|| Z03FieldOK(nOpc,@oEscopo)}
oDetalhe:bChange  	   := {|| Z03FieldOK(nOpc,@oEscopo)}
oDetalhe:oBrowse:bDelOk:= {|| Z03FieldOK(nOpc,@oEscopo)}
oDetalhe:oBrowse:SetBlkBackColor(bColor)
oDetalhe:oBrowse:SetBlkColor(bColorFont)
oDetalhe:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
oDetalhe:oBrowse:Refresh()


Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋芼控
控摺rograma  莧F02MontaResumo� Autor �                � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋迋芧控
控慣escricao �                      	    			                   滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function AF02MontaResumo(oPanel,nOpc,cProposta,cAditivo)
Local nI,nI2,nA
Local nPos      	:= 0
Local aAlterZ03 	:= {}
Local aAlterZ04 	:= {}
Local aAlterZ08 	:= {}
Local aAlterZ05 	:= {}
Local nPVlrTab  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nPVlHrFim 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local nPTotal   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPCustoT	 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
Local nPrcTabela   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nQuantidade	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPDataPgto	:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_DATA"})
Local nPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPModulo		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
Local nPTotHrMod  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local lRet			:= .T.
Local nLin			:= 2
Local cPreReq       := SuperGetMv("MV_PRESAP",.F.,"SAP-I000") //"SAP-I000" - Pre-Requisitos do Cliente (Nao tem horas)
Local nItem         := 0
Local nSavN         := 1


nTotHrsProj		:= 0
nTotTabela		:= 0
nCustoTotal		:= 0
nDesconto		:= 0

nNumParcelas 	:= IIF( Val(M->Z02_CONDPG) == 0 ,1, Val(M->Z02_CONDPG) )
nImpostos       := M->Z02_IMPOST

//Carrega os Acols Principal (Itens da Z05 - Licencas ou Escopo de Projeto)
If Len(aColsZ05) == 0
	MontaZ05(@aColsZ05,@aHeaderZ05,nOpc,M->Z02_TIPO,cProposta,cAditivo)
	aHeadResumo:= aClone(aHeaderZ05)
	aColsResumo:= aClone(aColsZ05)
ElseIF lServico .Or. lSD//Servicos

	//Atualiza o Vetor da Z05
	aColsZ05:= aClone(oEscopo:aCols)

	//Salva a Posicao em que se encontrou quasndo mudou de Pagina	
	nSavN:= oEscopo:nAT
	
	For nI:=1 To Len(oEscopo:aCols)
		//Se a linha estiver deletada pula o registro
		If (oEscopo:aCols[nI,Len(aHeaderZ05)+1])
			Loop 
		EndIf

		//Nao permite avanca se alguma linha estiver com o modulo em branco
		If Empty(oEscopo:aCols[nI,nPModulo])  
			Aviso("Atencao","Nao � possivel avancar sem selecionar o escopo do projeto!",{"Ok"})
			Return(.F.)
		//Nao permite avancar se nao colocou a quantidade de licencas
		ElseIf (nQuantidade > 0)
			If (oEscopo:aCols[nI,nQuantidade] == 0)
				Aviso("Atencao","Nao � possivel avancar sem informar a quantidade de licencas!",{"Ok"})
				Return(.F.)
			EndIf
		//Nao permite avancar se nao colocou a quantidade de horas
		ElseIf (nPTotHrMod > 0)
			If (oEscopo:aCols[nI,nPTotHrMod] == 0) .And. (AllTrim(oEscopo:aCols[nI,nPModulo]) <> cPreReq)
				Aviso("Atencao","Nao � possivel avancar sem informar a quantidade de horas do servi蔞!",{"Ok"})
				Return(.F.)
			EndIf	

			//Valida se os itens do escopo estao preenchidos
			For nItem:= 1 To Len(oDetalhe:aCols)
				If !Z03LinhaOK(nItem)
					Return(.F.)
				EndIf	
			Next nItem
		EndIf
	Next nI

	//Atualiza o acols Resumo com o escopo atualizado dos servicos
	aHeadResumo:= aClone(oEscopo:aHeader)
	aColsResumo:= aClone(oEscopo:aCols)
EndIf

IF ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 .Or. nOpc == 14 )
	
	Aadd(aAlterZ08,"Z08_FORNEC")
	Aadd(aAlterZ08,"Z08_DATA")
	Aadd(aAlterZ08,"Z08_EMISSA")
	Aadd(aAlterZ08,"Z08_HISTOR")
	Aadd(aAlterZ08,"Z08_QTPARC")	
	Aadd(aAlterZ08,"Z08_PARC")	
	//Aadd(aAlterZ08,"Z08_PERC")	

	//Aadd(aAlterZ08,"Z08_BASE")	

	Aadd(aAlterZ04,"Z04_DATA")
	Aadd(aAlterZ04,"Z04_HIST")
	Aadd(aAlterZ05,"Z05_CUSTO")
	Aadd(aAlterZ05,"Z05_PRCTAB")
	Aadd(aAlterZ05,"Z05_SEQ")
	IF lSD	// Service Desk
		
		//Aadd(aAlterZ04,"Z04_QTDPAR")
		Aadd(aAlterZ04,"Z04_VALOR")
		Aadd(aAlterZ05,"Z05_MOD")
		Aadd(aAlterZ05,"Z05_MODULO")
		Aadd(aAlterZ05,"Z05_DESCRI")
		Aadd(aAlterZ05,"Z05_VLHRDE")
		Aadd(aAlterZ05,"Z05_QUANT")
		Aadd(aAlterZ03,"Z03_HORAS")
		Aadd(aAlterZ05,"Z05_PERDES")		
		Aadd(aAlterZ05,"Z05_VALDES")		
		Aadd(aAlterZ03,"Z03_MEMO")
		
	ElseIF lLicenca 		// Licencas
		
		//Aadd(aAlterZ04,"Z04_QTDPAR")
		Aadd(aAlterZ04,"Z04_VALOR")
		Aadd(aAlterZ05,"Z05_MODULO")
		Aadd(aAlterZ05,"Z05_MOD")
		Aadd(aAlterZ05,"Z05_DESCRI")
		Aadd(aAlterZ05,"Z05_QUANT")
		Aadd(aAlterZ05,"Z05_PRCVEN")
		Aadd(aAlterZ05,"Z05_PERDES")		
		Aadd(aAlterZ05,"Z05_VALDES")		
		
	ElseIF lServico 	// Servicos
		
		Aadd(aAlterZ04,"Z04_VALOR")
		Aadd(aAlterZ05,"Z05_MODULO")
		Aadd(aAlterZ05,"Z05_MOD")
		Aadd(aAlterZ05,"Z05_DESCRI")
		Aadd(aAlterZ05,"Z05_VLHRDE")
		Aadd(aAlterZ05,"Z05_QUANT")
		Aadd(aAlterZ05,"Z05_PERDES")		
		Aadd(aAlterZ05,"Z05_VALDES")		
		Aadd(aAlterZ03,"Z03_ESCOPO")
		Aadd(aAlterZ03,"Z03_HORAS")
		Aadd(aAlterZ03,"Z03_ORDEM")	
		Aadd(aAlterZ03,"Z03_MEMO")

	EndIF
	
EndIF

RecalcularParcelas()


SetKey(VK_F8 ,{||  U_AFMODULOS()    })

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//蛉onta o resumo do escopo do projeto.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
oResLayer := Nil
oResLayer := FWLayer():New()
oResLayer:Init(oPanel,.F.)

oResLayer:addLine("LIN1",050,.F.)
oResLayer:addLine("LIN2",050,.F.)

oResLayer:addCollumn("L1_COL1",100,.T.,"LIN1")
oResLayer:addCollumn("L2_COL1",030,.T.,"LIN2")
oResLayer:addCollumn("L2_COL2",070,.T.,"LIN2")

oResLayer:addWindow("L1_COL1","L1_WIN1","Resumo do Escopo: - F8 PARA ADICIONAR MODULOS "	,100,.F.,.F.,,"LIN1")

oResLayer:addWindow("L2_COL1","L2_WIN1","Resumo Financeiro"	,100,.F.,.F.,,"LIN2")
oResLayer:addWindow("L2_COL2","L2_WIN2","Comiss髊s"  		,100,.F.,.F.,,"LIN2")

oFldEscopo:= Nil
oFldEscopo:= oResLayer:GetWinPanel("L1_COL1","L1_WIN1","LIN1")

oVlrEscopo:= Nil
oVlrEscopo:= oResLayer:GetWinPanel("L2_COL1","L2_WIN1","LIN2")
oVlrEscopo:nClrPane:= Rgb(207,207,207)
oVlrEscopo:oFont:= oFntP
oVlrEscopo:Refresh()

oRodape:= Nil
oRodape:= oResLayer:GetWinPanel("L2_COL2","L2_WIN2","LIN2")

nStyle:= IIF(lLicenca,nStyle,0)
oResumo:= Nil
oResumo:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue","+Z05_ID",aAlterZ05,,99999,,,,oFldEscopo,@aHeadResumo,@aColsResumo)
oResumo:bFieldOk  	  := {|| ResBrwCor(1,@oResumo) .And. Z05CalculaValores(nOpc,@oResumo)}
oResumo:bChange  	  := {|| ResBrwCor(1,@oResumo) .And. Z05CalculaValores(nOpc,@oResumo)}
oResumo:oBrowse:bAdd:= { || oResumo:AddLine() .And. ResBrwCor(1,@oResumo) } 
oResumo:oBrowse:bDelOk:= {|| Z05CalculaValores(nOpc,@oResumo)}
oResumo:nAt:= IIF(lLicenca,1,nSavN)
oResumo:oBrowse:nAt:= IIF(lLicenca,1,nSavN)
oResumo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oResumo:oBrowse:SetBlkBackColor( { || (ResBrwCor(2,@oResumo)) } )
oResumo:oBrowse:SetBlkColor( { || (ResBrwCor(3,@oResumo) )} )
oResumo:oBrowse:Refresh()

IF lServico	// Servicos

	@ nLin		,005 SAY "Parcelas?"	OF oVlrEscopo FONT oFntP COLOR CLR_BLACK 	Pixel SIZE 50,11
	@ nLin+12	,005 SAY "Total Horas"	OF oVlrEscopo FONT oFntP COLOR CLR_BLUE 	Pixel SIZE 50,11

	@ nLin-1	,070 GET oNumParcelas	VAR nNumParcelas PICTURE '@E 999'			OF oVlrEscopo FONT oFntP COLOR CLR_BLACK Pixel SIZE 40,10 VALID (nNumParcelas > 0) .And. RecalcularParcelas() WHEN ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7 )
	@ nLin+12	,070 GET oHrTot			VAR	nTotHrsProj	 PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_BLUE 	Pixel SIZE 070,11 WHEN .F.

	nLin := 14

Else

	@ nLin		,005 SAY "Pre蔞 Tabela" OF oVlrEscopo FONT oFntP COLOR CLR_BLACK 	Pixel SIZE 50,15
	@ nLin		,070 GET oTotTabela		VAR	nTotTabela	PICTURE '@E 9,999,999.99' OF oVlrEscopo FONT oFntP COLOR CLR_BLACK 	Pixel SIZE 070,11 WHEN .F.

EndIF

@ nLin+13	,005 SAY "Custo"			OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 60,11
@ nLin+26	,005 SAY "Comiss髊s"		OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 60,11
@ nLin+38	,005 SAY "Desc.Itens($ - %)"OF oVlrEscopo FONT oFntP COLOR CLR_RED		Pixel SIZE 60,11
@ nLin+50	,005 SAY "Desc.Total($ - %)"OF oVlrEscopo FONT oFntP COLOR CLR_RED		Pixel SIZE 60,11
@ nLin+62	,005 SAY "Margem($ - %)"	OF oVlrEscopo FONT oFntP COLOR CLR_BLUE		Pixel SIZE 60,11
@ nLin+74	,005 SAY "SubTotal"		 	OF oVlrEscopo FONT oFntP COLOR CLR_BLACK	Pixel SIZE 60,11
@ nLin+86	,005 SAY "Com Impostos"		OF oVlrEscopo FONT oFntP COLOR CLR_BLACK 	Pixel SIZE 60,11

@ nLin+13,070	GET oCustoTotal			VAR	nCustoTotal 	PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 070,11 WHEN .F.
@ nLin+26,070	GET oComissoes			VAR	nComissoes  	PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 070,11 WHEN .F.
@ nLin+38,070	GET oDesconto			VAR	nDesconto		PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 070,11 WHEN .F.
@ nLin+38,140	GET oPercDesconto		VAR	nPercDesconto	PICTURE '@E 999.99'			OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 030,11 WHEN .F.
@ nLin+50,070	GET oDscTotal			VAR	nDscTotal		PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 070,11 WHEN (INCLUI .OR. ALTERA) VALID IIf(nDscTotal < 50, Z05CalculaValores(nOpc,@oResumo,"NDSCTOTAL"), (Alert("Desconto Nao Permitido."),.F.))
@ nLin+50,140	GET oPercDscTotal		VAR	nPercDscTotal	PICTURE '@E 999.99'			OF oVlrEscopo FONT oFntP COLOR CLR_RED 		Pixel SIZE 030,11 WHEN .F.
@ nLin+62,070	GET oLucro				VAR	nLucro			PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_BLUE 	Pixel SIZE 070,11 WHEN .F.
@ nLin+62,140	GET oPercLucro			VAR	nPercLucro		PICTURE '@E 999.99'			OF oVlrEscopo FONT oFntP COLOR CLR_BLUE 	Pixel SIZE 030,11 WHEN .F.
@ nLin+74,070	GET oSubTotal			VAR	nSubTotal   	PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_BLACK	Pixel SIZE 070,11 WHEN .F.
@ nLin+86,070	GET oTotal				VAR	nValorTotal 	PICTURE '@E 9,999,999.99'	OF oVlrEscopo FONT oFntP COLOR CLR_BLACK	Pixel SIZE 070,11 WHEN .F.

//矬闡闡闡闡闡闡闡闡闡闡闡闡醴
//蛉onta o resumo financeiro.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡囁
oFldPagto:= Nil
oFldPagto:=TFolder():New(1,1,{"Condi誽o de Pagamento","Comissoes"},{"HEADER","HEADER","HEADER"},oRodape,,,,.T.,.F.,1,1)
oFldPagto:Align := CONTROL_ALIGN_ALLCLIENT

nStyle:= GD_INSERT+GD_UPDATE+GD_DELETE
oParcelas:= Nil
oParcelas:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue","AllWaysTrue",,aAlterZ04,,99999,,,,oFldPagto:aDialogs[1],@aHeaderZ04,@aColsZ04)
oParcelas:lInsert:= .F.
oParcelas:oBrowse:Refresh()
oParcelas:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

nStyle:= GD_INSERT+GD_UPDATE+GD_DELETE
oComis:= Nil
oComis:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue","AllWaysTrue",,aAlterZ08,,99999,,,,oFldPagto:aDialogs[2],@aHeaderZ08,@aColsZ08)
oComis:oBrowse:Refresh()
oComis:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
oComis:bChange       := {|| Z05CalculaValores(nOpc,@oResumo)}
oComis:oBrowse:bDelOk:= {|| Z05CalculaValores(nOpc,@oResumo)}

oComis:bFieldOk := {|| Z8FieldOK( ReadVar(),aHeaderZ08,aColsZ08 ) }

//Calcula os valores ao exibir a tela
If lLicenca
	cCampo := "M->Z05_QUANT"
	nPQuant:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
	M->Z05_QUANT:= oResumo:aCols[oResumo:nAt,nPQuant]
else
	cCampo := "M->Z05_HORASA"
	nPHorasa:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
	M->Z05_HORASA:= oResumo:aCols[oResumo:nAt,nPHorasa]
EndIf		

Z05CalculaValores(nOpc,@oResumo,cCampo)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋跼�
控摺rograma  � Z05CalculaValores � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋僚�
控慣escricao �                              			                    滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function Z05CalculaValores(nOpc,oBrw,cCampo,lComis)

Local nI,nX,nA
Local nDif		 	:= 0
Local nPID  	    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
Local nPModulo	    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
Local nPrcTabela   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nQuantidade	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPerDes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PERDES"})
Local nPTotal   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPCusto	 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTO"})
Local nPCustoT	 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
Local nPDataPgto	:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_DATA"})
Local nPVlParcela	:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_VALOR"})
Local nQtParcelas	:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_QTDPAR"})
Local nModPar		:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_MOD"})
Local nTotal		:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_TOTAL"})
Local nHist			:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_HIST"})
Local nPDscPar		:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_DSCPAR"})
Local nPVlrOri		:= aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_VLRORI"})
Local nPTotHrMod  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nPVlrTab  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nPVlHrFim 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local nPZ05Mod 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MOD"})
Local nMesAtual		:= 0
Local nAno			:= 0
Local nTotProd		:= 0
Local nTotMes		:= 0
Local nTotSup       := 0
Local nDscMes       := 0
Local nDscSup       := 0
Local nDscPrd       := 0
Local dVencimento
Local cModulo       := ""
Local cID           := ""
Local cDiaFixo		:= '05'
Local lPostergar 	:= .F.
Local lRet			:= .T.

DEFAULT lComis      := .T.
DEFAULT cCampo      := IIf(Empty(ReadVar()),"M->Z05_MODULO",ReadVar())

IF ValType(oBrw) == "U"
	Return(.T.)
EndIF

If Empty(oBrw:aCols[oBrw:nAT,nPModulo]) .And. Empty(M->Z05_MODULO)
	Return(.F.)
EndIF

//Valida os campos do Acols
If (nOpc <> 2) .And. (nOpc <> 5) .And. !U_VLDFIELD(cCampo,oBrw)
	Return(.F.)
EndIf

//Realiza os calculos
nTotTabela		:= 0
nCustoTotal		:= 0
nDesconto		:= 0
nLucro			:= 0
nSubTotal		:= 0
nValorTotal     := 0
nTotHrsProj     := 0
nQtdUser		:= 0

For nA := 1 To Len(oBrw:aCols)

	If (cCampo == "M->Z05_MODULO") .And. (nA == oBrw:nAT)
		cModulo:= IIF(&(cCampo)==NIL,oBrw:aCols[nA,nPModulo],&(cCampo))
		cCampo:= ""
	Else
		cID    := oBrw:aCols[nA,nPID]
		cModulo:= oBrw:aCols[nA,nPModulo]
	EndIf	

	IF (oBrw:aCols[nA,Len(oBrw:aHeader)+1]) .Or. Empty(cModulo)// Linha Deletada
		Loop
	EndIF
	
	Z00->( DbSetOrder(1) )
	IF !Z00->( DbSeek( xFilial('Z00') + cModulo ) )
		//MsgAlert( 'Item n緌 encontrado: ' + cModulo )
		Loop
	EndIF
	
	IF Z00->Z00_CLOUD == '1' // Exige Cloud = 1 (Sim)

		IF oBrw:nAt == nA
			oBrw:aCols[nA,nQuantidade] := IIF ( 'M->Z05_QUANT' == ReadVar(), &(ReadVar()) , oBrw:aCols[nA,nQuantidade] )
		EndIF 
			
		nQtdUser += oBrw:aCols[nA,nQuantidade]
				
	EndIF

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Calcula os Totais.							          �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	IF nPTotal > 0
		nTotProd += oBrw:aCols[nA,nPTotal]
	EndIF
	
	IF nPVlrMes > 0 .And. (oBrw:aCols[nA,nPZ05Mod] $ "4") //SaaS ou OnPremise
		nTotMes += oBrw:aCols[nA,nPVlrMes]
	ElseIf nPVlrMes > 0 .And. (oBrw:aCols[nA,nPZ05Mod] == "5") //Suporte Mensal
		nTotSup  += oBrw:aCols[nA,nPVlrMes]
	EndIF


	IF nPrcTabela > 0 .And. nQuantidade > 0
		nTotTabela += Round(oBrw:aCols[nA,nQuantidade] * oBrw:aCols[nA,nPrcTabela],2)
	ElseIf  (nPTotHrMod > 0) .And. (nPVlrTab > 0)
		nTotTabela += Round(oBrw:aCols[nA,nPTotHrMod] * oBrw:aCols[nA,nPVlrTab],2)
	EndIF
	
	IF nPCustoT > 0 .And. (nQuantidade > 0)
		nCustoTotal += Round(oBrw:aCols[nA,nQuantidade] * oBrw:aCols[nA,nPCusto],2)
	ElseIf  (nPCustoT > 0) .And. (nPTotHrMod > 0)
		nCustoTotal += Round(oBrw:aCols[nA,nPTotHrMod] * oBrw:aCols[nA,nPCusto],2)
	EndIF

	IF nPerDes > 0	.And. (nQuantidade > 0) .And. (nPrcTabela > 0) 
		If (oBrw:aCols[nA,nPrcTabela] > oBrw:aCols[nA,nPrcVen] )
			nDesconto += Round( oBrw:aCols[nA,nQuantidade] * oBrw:aCols[nA,nPrcTabela] ,2) - Round( oBrw:aCols[nA,nQuantidade] * oBrw:aCols[nA,nPrcVen] ,2)
		EndIf 			
	ElseIf  (nPTotHrMod > 0) .And. ( nPerDes > 0) .And. (nPVlrTab > 0) .And. (nPVlHrFim > 0)
		If (oBrw:aCols[nA,nPVlrTab] > oBrw:aCols[nA,nPVlHrFim])
			nDesconto += ( Round(oBrw:aCols[nA,nPTotHrMod] * oBrw:aCols[nA,nPVlrTab],2) ) - ( Round(oBrw:aCols[nA,nPTotHrMod] * oBrw:aCols[nA,nPVlHrFim],2) )
		EndIf	
	EndIF

	IF (nPVlrMes > 0) 
		nSubTotal 	+= oBrw:aCols[nA,nPVlrMes]
	Else
		nSubTotal 	+= oBrw:aCols[nA,nPTotal] 
	EndIf		
	
	//Se for servicos soma o total de horas
	If lServico
		nTotHrsProj += oBrw:aCols[nA,nPTotHrMod]
	EndIf
Next nA

nPercDesconto:= Round((nDesconto / nTotTabela) * 100,2)	
nPercDscTotal:= Round((nDscTotal / (nTotTabela-nDesconto)) * 100,2)	
nFatorDsc    := Round(1 - (nPercDscTotal/100),2)

nSubTotal-= nDscTotal
nValorTotal	:= Round( nSubTotal / nImpostos , 2 )
nLucro 		 := ( nTotTabela - nCustoTotal - nDesconto - nDscTotal - nComissoes)
nPercLucro	 := Round(( nLucro 	/ (nTotTabela - nDesconto - nDscTotal)) * 100,2)


//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//� Calcula as parcelas somente se for inclusao ou alteracao
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
If (nOpc <> 2) .And. (nOpc <> 5)


	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Calcula o Valor do SETUP do Cloud.			          �
	//� R$ 2.000 de partida + R$ 200,00 por usuario.          �
	//� Abate o imposto.							          �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	IF ( 'M->Z05_QUANT' == ReadVar() ) .And. (nQtdUser > 0)
		nTotSetup := Round(( 2000 + ( nQtdUser * 200 ) ) * 0.8635,2)
	EndIF

	IF lServico	// Servicos

		nDif := nValorTotal
		
		For nI:= 1 To Len(aColsZ04)
			aColsZ04[nI,nPVlParcela] := Round( nValorTotal / Len(aColsZ04) , 2 )
			aColsZ04[nI,nPVlrOri]    := Round( (nValorTotal + nDscTotal) / Len(aColsZ04) , 2 )
			aColsZ04[nI,nPDscPar]    := aColsZ04[nI,nPVlrOri] - aColsZ04[nI,nPVlParcela]
			nDif-= aColsZ04[nI,nPVlParcela]
		Next nI
		
		//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
		//� Joga as diferencas de centavos para 1a parcela.    											 �
		//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁		
		aColsZ04[1,nPVlParcela] += nDif

	ElseIF lSD	// Service Desk

		IF Len(aColsZ04) <> 2
			
			aColsZ04 := {}	
			
			For nX := 1 To 2
				
				Aadd(aColsZ04,Array(Len(aHeaderZ04)+1))
				For nI := 1 to Len(aHeaderZ04)
					aColsZ04[Len(aColsZ04),nI] := CriaVar(aHeaderZ04[nI,2],.T.)
				Next nI
				aColsZ04[Len(aColsZ04),Len(aHeaderZ04)+1] := .F.
			Next
		
		EndIF

		nMesAtual	:= Month(dDataBase)
		nAno		:= Year(dDataBase)
			
		nMesAtual++
		IF nMesAtual > 12
			nMesAtual := 1
			nAno += 1
		EndIF
				
		dVencimento := DataValida( Ctod( cDiaFixo + '/' + StrZero(nMesAtual,2) + '/' + StrZero(nAno,4) ) , lPostergar )

		aColsZ04[1,nModPar] 	:= '5' // Mensal Service Desk
		aColsZ04[1,nQtParcelas]	:= VAL(M->Z02_DURAC)
		aColsZ04[1,nPVlParcela]	:= Round((nTotSup * nFatorDsc) / nImpostos,2)
		aColsZ04[1,nTotal]		:= Round(aColsZ04[1,nQtParcelas] * aColsZ04[1,nPVlParcela],2)
		aColsZ04[1,nPDataPgto] 	:= dVencimento
		aColsZ04[1,nHist] 		:= M->Z02_DESCRI
		aColsZ04[1,nPVlrOri] 	:= Round(nTotSup  / nImpostos,2)
		aColsZ04[1,nPDscPar] 	:= aColsZ04[1,nPVlrOri] - aColsZ04[1,nPVlParcela]

		aColsZ04[2,nModPar] 	:= '1' // Servicos
		aColsZ04[2,nQtParcelas]	:= IIF(aColsZ04[2,nQtParcelas] > 1,aColsZ04[2,nQtParcelas],1)
		aColsZ04[2,nPVlParcela]	:= Round(((nTotProd * nFatorDsc)/ aColsZ04[2,nQtParcelas]) / nImpostos,2)
		aColsZ04[2,nTotal]		:= Round(aColsZ04[2,nPVlParcela] * aColsZ04[2,nQtParcelas],2)
		aColsZ04[2,nPDataPgto] 	:= dVencimento
		aColsZ04[2,nHist] 		:= 'Servi蔞s Adicionais ao Contrato de Service Desk'
		aColsZ04[2,nHist] 		:= aColsZ04[2,nHist] + Space( Len(Z04->Z04_HIST) - Len(aColsZ04[2,nHist]) ) 
		aColsZ04[2,nPVlrOri] 	:= Round((nTotProd / aColsZ04[2,nQtParcelas])  / nImpostos,2)
		aColsZ04[2,nPDscPar] 	:= aColsZ04[2,nPVlrOri] - aColsZ04[2,nPVlParcela]
		
	Else

		IF Len(aColsZ04) <> 4
			
			aColsZ04 := {}	
			
			For nX := 1 To 4
				
				Aadd(aColsZ04,Array(Len(aHeaderZ04)+1))
				For nI := 1 to Len(aHeaderZ04)
					aColsZ04[Len(aColsZ04),nI] := CriaVar(aHeaderZ04[nI,2],.T.)
				Next nI
				aColsZ04[Len(aColsZ04),Len(aHeaderZ04)+1] := .F.
			Next
		
		EndIF

		//Se for inclusao calcula a data de vencimento
		If (nOpc == 3)
			nMesAtual	:= Month(dDataBase)
			nAno		:= Year(dDataBase)
				
			nMesAtual++
			IF nMesAtual > 12
				nMesAtual := 1
				nAno += 1
			EndIF
					
			dVencimento := DataValida( Ctod( cDiaFixo + '/' + StrZero(nMesAtual,2) + '/' + StrZero(nAno,4) ) , lPostergar )
		Else
			Z04->(DBSetOrder(1))
			Z04->(DbSeek(xFilial("Z04") + M->Z02_PROPOS + M->Z02_ADITIV,.T.))
			
			dVencimento := IIf(nOpc == 7, dDatabase, Z04->Z04_DATA)
		EndIf		

		aColsZ04[1,nModPar] 	:= '2' // Produtos
		aColsZ04[1,nQtParcelas]	:= 1
		aColsZ04[1,nPVlParcela]	:= Round((nTotProd * nFatorDsc)  / nImpostos,2)
		aColsZ04[1,nTotal]		:= Round(aColsZ04[1,nQtParcelas] * aColsZ04[1,nPVlParcela],2)
		aColsZ04[1,nPDataPgto] 	:= dVencimento
		aColsZ04[1,nHist] 		:= 'Licenciamento de Produto'
		aColsZ04[1,nHist] 		:= aColsZ04[1,nHist] + Space( Len(Z04->Z04_HIST) - Len(aColsZ04[1,nHist]) ) 
		aColsZ04[1,nPVlrOri] 	:= Round(nTotProd / nImpostos,2)
		aColsZ04[1,nPDscPar] 	:= aColsZ04[1,nPVlrOri] - aColsZ04[1,nPVlParcela]
		
		aColsZ04[2,nModPar] 	:= '3' // Setup ou Adesao
		aColsZ04[2,nQtParcelas]	:= 1
		aColsZ04[2,nPVlParcela]	:= Round(nTotSetup / nImpostos,2)
		aColsZ04[2,nTotal]		:= Round(aColsZ04[2,nQtParcelas] * aColsZ04[2,nPVlParcela],2)
		aColsZ04[2,nPDataPgto] 	:= dVencimento
		aColsZ04[2,nHist] 		:= 'Setup Inicial do Cloud (Montagem e Disponibilizacao do Ambiente)'
		aColsZ04[2,nHist] 		:= aColsZ04[2,nHist] + Space( Len(Z04->Z04_HIST) - Len(aColsZ04[2,nHist]) ) 
		aColsZ04[2,nPVlrOri] 	:= Round(nTotSetup / nImpostos,2)
		aColsZ04[2,nPDscPar] 	:= aColsZ04[2,nPVlrOri] - aColsZ04[2,nPVlParcela]
		
		aColsZ04[3,nModPar] 	:= '4' // Mensal
		aColsZ04[3,nQtParcelas]	:= VAL(M->Z02_DURAC)
		aColsZ04[3,nPVlParcela]	:= Round((nTotMes * nFatorDsc) / nImpostos,2)
		aColsZ04[3,nTotal]		:= Round(aColsZ04[3,nQtParcelas] * aColsZ04[3,nPVlParcela],2)
		aColsZ04[3,nPDataPgto] 	:= dVencimento
		aColsZ04[3,nHist] 		:= 'SaaS - Servicos Mensais' 
		aColsZ04[3,nHist] 		:= aColsZ04[3,nHist] + Space( Len(Z04->Z04_HIST) - Len(aColsZ04[3,nHist]) ) 
		aColsZ04[3,nPVlrOri] 	:= Round(nTotMes / nImpostos,2)
		aColsZ04[3,nPDscPar] 	:= aColsZ04[3,nPVlrOri] - aColsZ04[3,nPVlParcela]

		aColsZ04[4,nModPar] 	:= '5' // Suporte Mensal
		aColsZ04[4,nQtParcelas]	:= VAL(M->Z02_DURAC)
		aColsZ04[4,nPVlParcela]	:= Round((nTotSup * nFatorDsc) / nImpostos,2)
		aColsZ04[4,nTotal]		:= Round(aColsZ04[4,nQtParcelas] * aColsZ04[4,nPVlParcela],2)
		aColsZ04[4,nPDataPgto] 	:= dVencimento
		aColsZ04[4,nHist] 		:= 'Suporte Mensal' 
		aColsZ04[4,nHist] 		:= aColsZ04[4,nHist] + Space( Len(Z04->Z04_HIST) - Len(aColsZ04[4,nHist]) ) 
		aColsZ04[4,nPVlrOri] 	:= Round(nTotSup / nImpostos,2)
		aColsZ04[4,nPDscPar] 	:= aColsZ04[4,nPVlrOri] - aColsZ04[4,nPVlParcela]

		nDif := nValorTotal
		For nI:= 1 To Len(aColsZ04)
			If aColsZ04[nI,nModPar] $ '45' //Calcula a diferenca dos centavos da divisao das parcelas do servico
				nDif-= aColsZ04[nI,nPVlParcela]
			EndIf	
		Next nI
		
		//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
		//� Joga as diferencas de centavos para 1a parcela.    											 �
		//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁		
		If (nDif <> 0) 
			If (aColsZ04[4,nPVlParcela] > 0)
				aColsZ04[4,nPVlParcela] += nDif
				aColsZ04[4,nTotal]		:= Round(aColsZ04[4,nQtParcelas] * aColsZ04[4,nPVlParcela],2)
			ElseIf len(aColsZ04) > 4 .and. (aColsZ04[5,nPVlParcela] > 0)
				aColsZ04[5,nPVlParcela] += nDif
				aColsZ04[5,nTotal]		:= Round(aColsZ04[5,nQtParcelas] * aColsZ04[5,nPVlParcela],2)
			EndIf	

		EndIf
	EndIF
EndIf

//Verifica se os objetos foram criados pois a mesma rotina 'e chamada no detalhe do escopo no Folder2
If Type("oParcelas") <> "U"
	
	oParcelas:aCols:= aColsZ04
	oParcelas:oBrowse:Refresh()

	//Atualiza os objetos
	IF lServico
		oHrTot:Refresh()
	Else
		oTotTabela:Refresh()
	EndIF

	oCustoTotal:CtrlRefresh()
	oComissoes:CtrlRefresh()
	oDesconto:CtrlRefresh()
	oPercDesconto:CtrlRefresh()
	oLucro:CtrlRefresh()
	oPercLucro:CtrlRefresh()
	oSubTotal:CtrlRefresh()
	oTotal:CtrlRefresh()

	oVlrEscopo:Refresh()
	oFldEscopo:Refresh()
	oFldPagto:Refresh() 

EndIf

Return(lRet)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � AF02Grv  � Autor �  Alexandro Dias    � Data �  03/07/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Grava proposta.                                            滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function AF02Grv(oWizard,nOpc)

Local lRet := .T.

LjMsgRun("Aguarde. Gravando Proposta Comercial...","Grava誽o",{|| lRet := AF02GravaProposta(oWizard,nOpc) })

IF lRet

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//逐erifica se deseja imprimir a proposta.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	IF (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 6 .Or. nOpc == 7)
		
		Z02->( DbSetOrder(1) )
		IF Z02->( DbSeek( xFilial('Z02') + M->Z02_PROPOS + M->Z02_ADITIV ) )
			If Aviso("Atencao","Deseja imprimir a proposta?",{"Sim","Nao"}) == 1
				U_AF02Imp()

				//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
				//� Envia Proposta para Diretoria.		  �
				//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
				U_EmailIncPro('',M->Z02_PROPOS,M->Z02_ADITIV)
			EndIf	
		Else
			MsgAlert('N緌 foi possivel encontrar a proposta para impress緌.')
		EndIF	
	EndIF

EndIF

Return(lRet)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋跼�
控摺rograma  蛄ravaProposta � Autor �   Fabio Rogerio    � Data �02/27/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋僚�
控慣esc.     袒otina para a gravacao da proposta                          滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function AF02GravaProposta(oWizard,nOpc)

Local nX, nI, nZ
Local aArea			:= GetArea()
Local cMay       	:= ""
Local cProposta 	:= M->Z02_PROPOS
Local cAditivo 		:= M->Z02_ADITIV
Local bCampo 	   	:= {|nCPO| Field(nCPO) }
Local nPMemo      	:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_MEMO"})
Local nPObserv      := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_OBSERV"})
Local nPCodCont     := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_CODCONT"})
Local nPNome        := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_CONTAT"})
Local nPSobren      := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_SOBREN"})
Local nPEmail       := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_EMAIL"})
Local nPFCom1       := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_FCOM1"})
Local nPCelular     := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_CELULAR"})
Local nPFuncao      := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_FUNCAO"})
Local nPAprov       := aScan(oContatos:aHeader,{|x| AllTrim(x[2]) == "U5_XAPROV"})
	
//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//袖e for visualiza誽o sai sem alterar gravacao.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
IF (nOpc == 2) 
	RestArea(aArea)
	Return(.T.)
EndIF	

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//袖e for exclusao solicita confirmacao do usuario.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF (nOpc == 5)

	//Valida  se existe alguma nota fiscal emitida
	If HasNotaFin(M->Z02_CLIENT,cProposta,cAditivo)
		MsgAlert('Existe notas fiscais emitidas para esta Proposta. Verificar com Administrativo Financeiro!!!.') 
		RestArea(aArea)
		Return(.F.)
	End

	IF (Aviso("Atencao","Confirma exclus緌 da proposta ?",{"Sim","Nao"}) == 2)
		RestArea(aArea)
		Return(.F.)
	EndIF	
EndIF	

Begin Transaction

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//袖e for altera誽o ou exclus緌 deleta tudo para gravar novamente.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
IF (nOpc == 4 .Or. nOpc == 5 .Or. nOpc == 14)
	
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//莧paga o resumo da proposta.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡�

	DbSelectArea("Z05")
	DbOrderNickName("Z05MODULO")
	DbSeek(xFilial("Z05")+cProposta+cAditivo)
	While !Eof() .And. (xFilial("Z05")+cProposta+cAditivo == Z05->(Z05_FILIAL+Z05_PROPOS+Z05_ADITIV))
		RecLock("Z05",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		DbSelectArea("Z05")
		DbSkip()
	End
	
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//莧paga as parcelas da proposta.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	DbSelectArea("Z04")
	DbOrderNickName("Z04PARCEL")
	DbSeek(xFilial("Z04")+cProposta+cAditivo)
	While !Eof() .And. (xFilial("Z04")+cProposta+cAditivo == Z04->(Z04_FILIAL+Z04_PROPOS+Z04_ADITIV))
		RecLock("Z04",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		DbSelectArea("Z04")
		DbSkip()
	End
	
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//莧paga as comissoesda proposta.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡�

	DbSelectArea("Z08")
	DBSetOrder(1)
	DbSeek(xFilial("Z08")+cProposta+cAditivo)
	While !Eof() .And. (xFilial("Z08")+cProposta+cAditivo == Z08->(Z08_FILIAL+Z08_PROPOS+Z08_ADITIV))
		RecLock("Z08",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		DbSelectArea("Z08")
		DbSkip()
	End

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//莧paga os itens da proposta.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡�
	DbSelectArea("Z03")
	DbOrderNickName("Z03NITEM")
	DbSeek(xFilial("Z03")+cProposta+cAditivo)
	While !Eof() .And. (xFilial("Z03")+cProposta+cAditivo == Z03->(Z03_FILIAL+Z03_PROPOS+Z03_ADITIV))
		RecLock("Z03",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		DbSelectArea("Z03")
		DbSkip()
	End
	
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//� Apaga o cabecalho da proposta. �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	IF nOpc == 5
		
		DbSelectArea("Z02")
		DbOrderNickName("Z02PROPOS")
		
		IF DbSeek(xFilial("Z02")+cProposta+cAditivo)
			RecLock("Z02",.F.,.T.)
			DbDelete()
			MsUnLock()
		EndIF
	
	EndIF
EndIF

IF (nOpc != 5)

	DbSelectArea("Z02")
	DbOrderNickName("Z02PROPOS")
	IF DbSeek(xFilial("Z02")+cProposta+cAditivo)
		
		RecLock("Z02",.F.)	
	
	Else
		//Tratativa para o lancamento de propostas retroativas a recuperacao dos dados em 11/12/2020
		IF !Empty(M->Z02_NUMANT)
			cProposta:= M->Z02_NUMANT
			cAditivo := M->Z02_ADITIV
		Else			
			//Se for Inclusao ou Copia de Proposta pega um numero novo
			If (nOpc == 3) .Or. (nOpc == 6)
				cMay    := "Z02"+ Alltrim(xFilial("Z02"))
				cAditivo:= "00"
				While ( DbSeek(xFilial("Z02")+cProposta+cAditivo) .Or. !MayIUseCode(cMay+cProposta+cAditivo) )
					cProposta := GetSxeNum('Z02','Z02_PROPOS')
				EndDo
			
				ConfirmSX8()
			EndIf
		EndIf

		RecLock("Z02",.T.)
		
	EndIF
	
	M->Z02_PROPOS := cProposta
	M->Z02_ADITIV := cAditivo
	For nX := 1 TO FCount()
		IF ("FILIAL" $ FieldName(nX) )
			FieldPut(nX,xFilial("Z02"))
		Else
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		EndIF
	Next nX
	
	Z02_HRPROJ := nTotHrsProj
	Z02_HRCOOR := nHrCoord
	Z02_DESCON := nDesconto
	Z02_DSCTOT := nDscTotal
	Z02_VALOR  := nValorTotal
	Z02_VLRLIQ := Round(nValorTotal * M->Z02_IMPOST,2)
	Z02_HRCON  := nTotHrsProj - nHrCoord 
	Z02_HRCOR  := nHrCoord 
	Z02_CONDPG := StrZero(nNumParcelas,3)
	Z02_ATIVO  := '1'
	
	IF !Empty(M->Z02_CLIENT)
		Z02_RAZAO := Posicione("SA1",1,xFilial("SA1")+M->Z02_CLIENT+M->Z02_LOJA,"Alltrim(A1_NREDUZ)")
	Else
		Z02_RAZAO := Posicione("SUS",1,xFilial("SUS")+M->Z02_PROSPE+M->Z02_LOJAPR,"Alltrim(US_NREDUZ)")
	EndIF
	MsUnLock()
	//ESSES CAMPOS FORAM SUBSTITUIDOS POR MEMO REAL
	//MSMM(Z02->Z02_TITCOD,,,M->Z02_TITMEM,1,,,"Z02","Z02_TITCOD")
	//MSMM(Z02->Z02_OBJCOD,,,M->Z02_OBJMEM,1,,,"Z02","Z02_OBJCOD")
	//MSMM(Z02->Z02_GERCOD,,,M->Z02_GERMEM,1,,,"Z02","Z02_GERCOD")
	//MSMM(Z02->Z02_RESCOD,,,M->Z02_RESMEM,1,,,"Z02","Z02_RESCOD")
	//MSMM(Z02->Z02_PRECOD,,,M->Z02_PREMEM,1,,,"Z02","Z02_PRECOD")

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//蛄rava os contatos.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	For nI:= 1 To Len(oContatos:aCols)

		dbSelectArea("SU5")
		dbSetOrder(1)
		If dbSeek(xFilial("SU5")+oContatos:aCols[nI,nPCodCont])
			//Se a linha estiver deletada apaga do cadastro de contato e da amarracao contato x cliente
			If (oContatos:aCols[nI,Len(oContatos:aHeader)+1])
				dbSelectArea("AC8")
				dbSetOrder(1)
				dbSeek(xFilial("AC8")+oContatos:aCols[nI,nPCodCont],.T.)
				While !Eof() .And. (xFilial("AC8") == AC8->AC8_FILIAL) .And. (oContatos:aCols[nI,nPCodCont] == AC8->AC8_CODCON)
					RecLock("AC8",.F.,.T.)
					AC8->(DbDelete())
					MsUnLock()

					dbSkip()
				End

				dbSelectArea("SU5")
				RecLock("SU5",.F.,.T.)
				SU5->(dbDelete())
				MSUnlock()
			Else
				//Atualiza o cadastro se existir
				RecLock("SU5",.F.)
				Replace U5_CONTAT  With oContatos:aCols[nI,nPNome]
				Replace U5_SOBREN  With oContatos:aCols[nI,nPSobren]
				Replace U5_EMAIL   With oContatos:aCols[nI,nPEmail]
				Replace U5_FCOM1   With oContatos:aCols[nI,nPFCom1]
				Replace U5_CELULAR With oContatos:aCols[nI,nPCelular]
				Replace U5_FUNCAO  With oContatos:aCols[nI,nPFuncao]				
				Replace U5_XAPROV  With oContatos:aCols[nI,nPAprov]				
				
				MsUnLock()
			EndIf
		Else
			//Cria o novo contato
			RecLock("SU5",.T.)
			Replace U5_FILIAL  With xFilial("SU5")
			Replace U5_CODCONT With oContatos:aCols[nI,nPCodCont]
			Replace U5_CONTAT  With oContatos:aCols[nI,nPNome]
			Replace U5_SOBREN  With oContatos:aCols[nI,nPSobren]
			Replace U5_EMAIL   With oContatos:aCols[nI,nPEmail]
			Replace U5_FCOM1   With oContatos:aCols[nI,nPFCom1]
			Replace U5_CELULAR With oContatos:aCols[nI,nPCelular]
			Replace U5_FUNCAO  With oContatos:aCols[nI,nPFuncao]
			Replace U5_XAPROV  With oContatos:aCols[nI,nPAprov]	
			MsUnLock()

			//Cria a amarracap do novo contato
			RecLock("AC8",.T.)
			Replace AC8_FILIAL  With xFilial("SU5")
			Replace AC8_CODCON  With oContatos:aCols[nI,nPCodCont]
			
			If !Empty(M->Z02_CLIENT)
				Replace AC8_ENTIDA  With "SA1"
				Replace AC8_CODENT  With M->Z02_CLIENT+M->Z02_LOJA
				Replace AC8_FILENT  With xFilial("SA1")
			Else
				Replace AC8_ENTIDA  With "SUS"
				Replace AC8_CODENT  With M->Z02_PROSPE+M->Z02_LOJAPR
				Replace AC8_FILENT  With xFilial("SUS")
			EndIf

			MsUnLock()
		EndIf
	Next nI

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//蛄rava os itens do escopo do projeto.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	If lSD .Or. lServico
		For nI:= 1 To Len(aSaveEscopo)
			If !aSaveEscopo[nI,Len(aSaveEscopo[nI])]
				For nX:=1 To Len(aSaveEscopo[nI,5])
					IF !(aSaveEscopo[nI,5,nX,Len(oDetalhe:aHeader)+1])
						DbSelectArea("Z03")
						RecLock("Z03",.T.)
						For nZ := 1 To Len(aHeaderZ03)
							IF aHeaderZ03[nZ,10] <> "V"
								Z03->(FieldPut(FieldPos(aHeaderZ03[nZ,2]),aSaveEscopo[nI,5,nX,nZ]))
							EndIF
						Next nZ
						Z03->Z03_FILIAL := xFilial("Z03")
						Z03->Z03_PROPOS := M->Z02_PROPOS
						Z03->Z03_ADITIV := M->Z02_ADITIV
						Z03->Z03_ID     := aSaveEscopo[nI,1]
						Z03->Z03_MODULO := aSaveEscopo[nI,2]
						Z03->Z03_TIPO   := aSaveEscopo[nI,6]
						MsUnLock()
						
						MSMM(Z03->Z03_CODMEM,,,aSaveEscopo[nI,5,nX,nPMemo],1,,,"Z03","Z03_CODMEM")
					EndIF
				Next nX
			EndIf
		Next nI
	EndIf

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//蛄rava as parcelas do projeto.�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	For nI:= 1 To Len(oParcelas:aCols)
		IF !(oParcelas:aCols[nI,Len(oParcelas:aHeader)+1])
			DbSelectArea("Z04")
			RecLock("Z04",.T.)
			For nZ := 1 To Len(oParcelas:aHeader)
				IF oParcelas:aHeader[nZ,10] <> "V"
					Z04->(FieldPut(FieldPos(oParcelas:aHeader[nZ,2]),oParcelas:aCols[nI,nZ]))
				EndIF
			Next nZ
			Z04->Z04_FILIAL := xFilial("Z04")
			Z04->Z04_PARCEL := StrZero(nI,TamSX3("Z04_PARCEL")[1])
			Z04->Z04_PROPOS := M->Z02_PROPOS
			Z04->Z04_ADITIV := M->Z02_ADITIV
			MsUnLock()
		EndIF
	Next nI
	
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//蛄rava o resumo do projeto   .�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	For nI:= 1 To Len(oResumo:aCols)
		
		IF !(oResumo:aCols[nI,Len(oResumo:aHeader)+1])
		
			DbSelectArea("Z05")
			RecLock("Z05",.T.)
			For nZ := 1 To Len(oResumo:aHeader)
				IF oResumo:aHeader[nZ,10] <> "V"
					Z05->(FieldPut(FieldPos(oResumo:aHeader[nZ,2]),oResumo:aCols[nI,nZ]))
				EndIF
			Next nZ
			//Z05->Z05_SEQ	:= Posicione("Z00",1,xFilial("Z00")+oEscopo:aCols[nI,1],"Z00_SEQ")
			Z05->Z05_FILIAL	:= xFilial("Z05")
			Z05->Z05_PROPOS	:= M->Z02_PROPOS
			Z05->Z05_ADITIV	:= M->Z02_ADITIV
			MsUnLock()

			MSMM(Z05->Z05_CODOBS,,,oResumo:aCols[nI,nPObserv],1,,,"Z05","Z05_CODOBS")

		EndIF                                        
	
	Next nI	


	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//蛄rava as comissoes do projeto   .�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	For nI:= 1 To Len(oComis:aCols)
		
		IF !(oComis:aCols[nI,Len(oComis:aHeader)+1])
		
			DbSelectArea("Z08")
			RecLock("Z08",.T.)
			For nZ := 1 To Len(oComis:aHeader)
				IF oComis:aHeader[nZ,10] <> "V"
					Z08->(FieldPut(FieldPos(oComis:aHeader[nZ,2]),oComis:aCols[nI,nZ]))
				EndIF
			Next nZ
			Z08->Z08_FILIAL	:= xFilial("Z08")
			Z08->Z08_PROPOS	:= M->Z02_PROPOS
			Z08->Z08_ADITIV	:= M->Z02_ADITIV
			Z08->Z08_LOJA	:= "01"
			MsUnLock()

		EndIF                                        
	
	Next nI	
EndIF

End Transaction

RestArea(aArea)

Return(.T.)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋迋跼�
控摺rograma  覓ldCapaProposta� Autor � Alexandro Dias � Data � 03/07/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋迋僚�
控慣escricao � Valida campos obrigatorios da proposta.             	      滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function VldCapaProposta(nOpc,cCopiarDaProposta,oWizard,cProposta,cAditivo)

Local lRet      := .T.
Local nX        := 0
Local nContatos := 0
Local cQuery 	:= ''
Local cTmp 		:= ''
//Alimenta as variaveis Private de lLicenca e lServico
IF (M->Z02_TIPO $ "348") //Licencas
	lLicenca:= .T.
	lServico:= .F.
	lSD	    := .F.
	lSAP    := .T.
	lTOTVS  := .F.
ElseIF (M->Z02_TIPO $ "26") //SD
	lLicenca:= .F.
	lServico:= .F.
	lSD	    := .T.
	lSAP    := IIF(M->Z02_TIPO == "6",.T.,.F.)
	lTOTVS  := IIF(M->Z02_TIPO == "2",.T.,.F.)
Else //Servicos
	lLicenca:= .F.
	lServico:= .T.
	lSD	    := .F.
	lSAP    := IIF(M->Z02_TIPO $ "57",.T.,.F.)
	lTOTVS  := IIF(M->Z02_TIPO $ "01",.T.,.F.)
EndIf		

IF nOpc != 2 // Visualizar

	lRet := Obrigatorio(aGets,aTela)

	IF !lRet
		Return(.F.)
	EndIF
	
	IF ( Empty(M->Z02_CLIENT) .And. Empty(M->Z02_PROSPE) )
		MsgAlert('Informe o Cliente ou Prospect para emiss緌 da Proposta.')
		Return(.F.)
	EndIF
		
	//Valida se foi preenchido os contatos
	For nX:= 1 To Len(oContatos:aCols)
		IF (oContatos:aCols[nX,Len(oContatos:aHeader)+1]) .Or. Empty(oContatos:aCols[nX,2])// Linha Deletada
			Loop
		EndIF		
		
		//Verifica o preenchimento do contato
		If Empty(oContatos:aCols[nX,2])
			MsgAlert('Informe o Nome do contato. Linha: ' + cValToChar(nX))
			Return(.F.)
		EndIf

		//Verifica o preenchimento do sobrenome do contato
		If Empty(oContatos:aCols[nX,3])
			MsgAlert('Informe o Sobrenome do contato. Linha: ' + cValToChar(nX) + ' ' + oContatos:aCols[nX,2])
			Return(.F.)
		EndIf

		//Verifica o preenchimento do email do contato
		If Empty(oContatos:aCols[nX,4]) .Or. !("@" $ oContatos:aCols[nX,4] )
			MsgAlert('Informe o E-mail do contato. Linha: ' + cValToChar(nX) + ' ' + oContatos:aCols[nX,2])
			Return(.F.)
		EndIf

		nContatos++
	Next nX
	
	If (nContatos == 0)
		MsgAlert('Informe ao menos 1 contato valido.')
		Return(.F.)
	EndIf
	//VALIDA SE N鬃 EXISTE PROPOSTA ABERTA COM O MESMO TIPO
	//OBRIGAR O VENDEDOR A FAZER UM ADITIVO DE PROPOSTA
	IF  INCLUI .AND. !Empty(M->Z02_CLIENT)  .AND. M->Z02_ADITIV == '00' .and. !M->Z02_TIPO $ "0,1,2,8"
		cQuery+=" SELECT "+CRLF
		cQuery+=" Z02_PROPOS,Z02_ADITIV,Z02_TIPO"+CRLF
		cQuery+=" FROM "+RetSqlName('Z02')+"  Z02"+CRLF
		cQuery+=" WHERE "+CRLF
		cQuery+=" Z02_FILIAL = '"+xFilial('Z02')+"'"+CRLF
		cQuery+=" AND D_E_L_E_T_='' "+CRLF
		cQuery+=" AND Z02_CLIENT = '"+M->Z02_CLIENT+"' "+CRLF
		cQuery+=" AND Z02_STATUS IN ('5','9')"+CRLF
		cQuery+=" AND Z02_TIPO = '"+M->Z02_TIPO+"' "+CRLF
		cQuery+=" AND Z02_DTENCE = '' "+CRLF
		cQuery+=" AND Z02_DTCANC = '' "+CRLF 
		cTmp := MPSysOpenQuery(cQuery)
		If (cTmp)->(!eof())
			MsgAlert('Existe proposta ativa para esse cliente, realizar um aditivo de contrato!.')
			lRet:= .F.
		End
		(cTmp)->(DbCloseArea())
	End

EndIF

//Cria os proximos panels dinamicamente
CriaPanel(oWizard,nOpc,cProposta,cAditivo)	

Return(lRet)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  莧F02VALRESUMO 態utor  蚶abio Rogerio   � Data �  03/07/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣esc.     � Valida o resumo da proposta (valores)                      滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function AF02VALRESUMO(nOpc,lShowMsg)

Local lRet   		:= .T.
Local cMsg			:= ''
Local nValParcela	:= 0
Local nPVlParcela 	:= 0
Local nPData 		:= 0
Local nPModulo 		:= 0
Local nI            := 0
Local nPTotal     := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPQtParc    := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_QTPARC"})

DEFAULT nOpc        := 3
DEFAULT lShowMsg    := .T.

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡i闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Nao executa se for Visualizacao ou Exclusao             �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
If (nOpc == 2) .Or. (nOpc == 5)
	Return(.T.)
EndIf	

nPVlParcela := aScan(oParcelas:aHeader ,{|x| AllTrim(x[2]) == "Z04_VALOR"})
nPData 		:= aScan(oParcelas:aHeader ,{|x| AllTrim(x[2]) == "Z04_DATA"})
nPModulo 	:= aScan(oResumo:aHeader ,{|x| AllTrim(x[2]) == "Z05_MODULO"})

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Verifica se ha divergencia na somatoria das parcelas x total.              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
aEval(oParcelas:aCols, {|x| nValParcela += x[nPVlParcela]})
nValParcela := Round(nValParcela,2)

IF ( nValParcela <> nValorTotal ) .And. (lServico)	// Servicos

	cMsg := 'O valor das parcelas nao bate com o valor do projeto.'+cEOL+cEOL
	cMsg += 'Projeto ' + Alltrim(Transform(nValorTotal,'@E 9,999,999.99')) + ' - Parcelas ' + Alltrim(Transform(nValParcela,'@E 9,999,999.99')) + ' <> ' + Alltrim( Transform( nValorTotal - nValParcela , '@E 9,999,999.99') )
	
	If lShowMsg
		Aviso('Atencao:',cMsg,{'Ok'})
	EndIf

	Return(.F.)

EndIF

//Valida se est� preenchido a data
For nI:= 1 To Len(oParcelas:aCols)
	If (nValParcela == 0) .Or. (Empty(oParcelas:aCols[nI,nPData]))
		If lShowMsg
			Aviso("Atencao","Parcela sem data de pagamento! Favor informar uma data de pagamento v嫮ida.",{"Ok"})
		EndIf

		Return(.F.)
	ElseIf 	(oParcelas:aCols[nI,nPData] < dDatabase)
		If lShowMsg
			Aviso("Atencao","Parcela com data de pagamento inv嫮ida! Favor informar uma data de pagamento maior que a data atual."+;
					Chr(10)+Chr(13)+"Dt.Parcela:" + Dtoc(oParcelas:aCols[nI,nPData]) +;
					Chr(10)+Chr(13)+"Data Atual:" + Dtoc(dDatabase),{"Ok"})
		EndIf

		Return(.F.)
	EndIf	
Next nI

//Valida se nao tem nenhuma linha do escopo em branco
For nI:= 1 To Len(oResumo:aCols)
	If !oResumo:aCols[nI,Len(oResumo:aHeader)+1] .And. Empty(oResumo:aCols[nI,nPModulo])
		Aviso("Atencao", "Modulo nao preenchido na linha " + cValToChar(nI),{"Ok"})
		Return(.F.)
	EndIf
Next nI

/*
nBaseComis:= 0
For nI:=1 To Len(oResumo:aCols)
	If !oResumo:aCols[nI,Len(oResumo:aHeader)+1]
		IF lServico // Servicos
			nBaseComis	+= oResumo:aCols[nI,nPTotal]
		Else
			nBaseComis	+= oResumo:aCols[nI,nPVlrMes]
		EndIF
	EndIf
Next nI
nBaseComis-= nDscTotal
nBaseComis:= Round(nBaseComis * aColsZ08[1,nPQtParc],2)

nZ08_BASE 	:= aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_BASE"})
aColsZ08 	:= oComis:aCOLS
nAuxZ8 	 	:= 0

for nI := 1 to len(aColsZ08)
	IF !aColsZ08[ nI ,Len(aHeaderZ08)+1]        
		nAuxZ8+= aColsZ08[nI][nZ08_BASE]
	EndIf
next
If nAuxZ8 > nBaseComis//nSubTotal	 	
	lRet:= .f.
	Alert('Valor base distribuido maior que o permitido')
End
*/

Return(lRet)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  AF02Imp   態utor  蛉icrosiga           � Data �  03/19/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣esc.     �                                                            滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

User Function AF02Imp()

LjMsgRun("Aguarde...Imprimindo Proposta","Impressao",{|| AF02IMPRIMIR() })

Return(.T.) 

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � VldField � Autor �                    � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Rotina para Tratar Gatilhos e Validacoes da Z05			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function VldField(cVar,oBrw)

Local aArea			:= GetArea()
Local nPSeq  	    := 0
Local nPModulo  	:= 0
Local nPModalidade 	:= 0
Local nPCusto   	:= 0
Local nPCusTot 		:= 0
Local nPPrcTab   	:= 0
Local nPMargem		:= 0
Local nPPerDes 		:= 0
Local nPValDes      := 0
Local nPQuant		:= 0
Local nPPrcVen		:= 0
Local nPTotal   	:= 0
Local nPVlrMes		:= 0
Local nPHorasa		:= 0
Local nPVlHrDe		:= 0
Local nPVlHora		:= 0
Local nPTotCIP		:= 0
Local nPTpServ		:= 0
Local nPPerMan      := 0
Local nPTpManu      := 0
Local nPVlrMnt      := 0
Local nPTpCalc      := 0
Local nPLimMin      := 0
Local nPLimMax      := 0
Local nPModLic      := 0
Local nPDelete      := 0
Local nPObserv      := 0
Local nQuant		:= 0
Local nPrecoVenda	:= 0
Local nPrecoTabela	:= 0
Local nPercDesconto := 0
Local nPID          := 0
Local nDescItem     := 0
Local nCusto        := 0
Local nDesconto     := 0
Local nSavnAT       := 1
Local nSeq          := 0
Local nDescUni      := 0
Local nPerMan       := 0    
Local nVlrMnt       := 0    
Local nX            := 0
Local nRet          := 0
Local cModalidade   := ""
Local cSeq          := ""
Local cTpManu       := ""
Local cTpCalc       := ""
Local cLimMin       := ""
Local cLimMax       := ""
Local cObserv       := ""
Local cTpServ       := ""
Local cID           := ""
Local cModLic       := ""
Local lRet          := .T.
DEFAULT cVar        := ReadVar()

//Se a variavel de memoria estiver vazia nao faz nada
If Type("aHeaderZ05") == "U"
	Return(.T.)
EndIF

//Se nao tiver conteudo retorna e nao faz nada
If &(cVar) == NIL
	Return(.F.)
EndIF

//Se for licenciamento 
If ValType(oBrw) == "U"
	If (lLicenca)
		oBrw:= oResumo
	else
		oBrw:= oEscopo
	EndIf	
EndIf

//Salva a posicao atual
nSavnAT:= oBrw:nAt

nPID  	    	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
nPSeq  	    	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_SEQ"})
nPModulo  		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
nPModalidade 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MOD"})
nPCusto   		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTO"})
nPCusTot 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
nPPrcTab   		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
nPMargem		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MARGEM"})
nPPerDes 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PERDES"})
nPValDes 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VALDES"})
nPQuant			:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
nPPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
nPTotal   		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
nPHorasa		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
nPVlHrDe		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
nPVlHora		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
nPTotCIP		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTCIP"})
nPTpServ		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TPSERV"})
nPData		    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_DATA"})
nPPerMan		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PERMAN"})
nPTpManu		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TPMANU"})
nPVlrMnt		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMNT"})
nPTpCalc		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TPCALC"})
nPLimMin		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_LIMMIN"})
nPLimMax		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_LIMMAX"})
nPObserv		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_OBSERV"})
nPModLic		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODLIC"})
nPDelete        := Len(aHeaderZ05)+1

//Se o modulo nao tiver sido informado nao faz nada.
If Empty(oBrw:aCols[oBrw:nAT,nPModulo]) .And. Empty(M->Z05_MODULO)
	Return(.F.)
EndIF

//Se o modulo estiver deletado sai fora
If oBrw:aCols[oBrw:nAT,nPDelete]
	Return(.T.)
EndIF

//Posiciona no cadastro do modulo/licenca selecionado para buscar os valores, custo etc.
IF ('M->Z05_MODULO' == cVar)
	
	cModulo:= &(cVar) 

	Z00->(dbSetOrder(1))
	Z00->(dbSeek(xFilial("Z00")+cModulo))

	//Atualiza as variaveis com o conteudo do cadastro
	cModalidade := Z00->Z00_MOD
	cTpServ     := IIF(Empty(Z00->Z00_TPSERV),"1",Z00->Z00_TPSERV)
	
	cID := oBrw:aCols[oBrw:nAt,nPID]
	cSeq:= oBrw:aCols[oBrw:nAt,nPSeq]
	If Empty(cSeq)
		cSeq:= Z00->Z00_SEQ
		If Val(cSeq) == 0
			cSeq := '999'
		EndIf 
	ENDIF

	If lLicenca
		nRet:= GetTabPrc(cModulo,1)
		If nRet <> 0
			Z24->( DbGoto(nRet) )
		EndIf
		nQuant      := 1//IIF(nRet == 0 ,1, Z00->Z00_HORAS)
		nCusto	    := IIF(nRet == 0 ,Z00->Z00_CUSTO, Z24->Z24_CUSTO) //Z00->Z00_CUSTO
		nPrecoVenda := IIF(nRet == 0 ,Z00->Z00_PRCVEN,Z24->Z24_PRCVEN)
		nPrecoTabela:= IIF(nRet == 0 ,Z00->Z00_PRCTAB,Z24->Z24_PRCTAB)
		nPercDesconto:=IIF(nRet == 0 ,Z00->Z00_DESCON,Z24->Z24_DESCON)
		cLimMin      := IIF(nRet == 0 ,Z00->Z00_LIMMIN,cValToChar(Z24->Z24_QTDMIN))
		cLimMax      := IIF(nRet == 0 ,Z00->Z00_LIMMAX,cValToChar(Z24->Z24_QTDMAX))	
		nDescItem    := nPrecoTabela - nPrecoVenda
		nPerMan      := IIF( lLicenca ,Z00->Z00_PERMAN/100,0)
		cTpManu      := IIF( lLicenca ,Z00->Z00_TPMANU,"")
		nVlrMnt      := IIF( lLicenca ,Z00->Z00_VLRMNT,0)
		cTpCalc      := IIF( lLicenca ,Z00->Z00_TPCALC,"")
		cModLic      := IIF( lLicenca ,Z00->Z00_MODLIC,"")		
	Else
		nQuant      := IIF(lLicenca ,1, Z00->Z00_HORAS)
		nCusto	    := Z00->Z00_CUSTO
		nPrecoVenda := IIF(lLicenca ,Z00->Z00_PRCVEN,M->Z02_VLHORA)
		nPrecoTabela:= IIF(lLicenca ,Z00->Z00_PRCTAB,M->Z02_VLCOOR)
		nPercDesconto:=IIF(lLicenca ,Z00->Z00_DESCON,0)
		nDescItem    := nPrecoTabela - nPrecoVenda
		nPerMan      := IIF(lLicenca ,Z00->Z00_PERMAN/100,0)
		cTpManu      := IIF(lLicenca ,Z00->Z00_TPMANU,"")
		nVlrMnt      := IIF(lLicenca ,Z00->Z00_VLRMNT,0)
		cTpCalc      := IIF(lLicenca ,Z00->Z00_TPCALC,"")
		cLimMin      := IIF(lLicenca ,Z00->Z00_LIMMIN,"")
		cLimMax      := IIF(lLicenca ,Z00->Z00_LIMMAX,"")	
		cModLic      := IIF(lLicenca ,Z00->Z00_MODLIC,"")	
	EndIf
	cObserv		 := Z00->Z00_MEMO2 //Alltrim(Z00->Z00_MEMO0)//

Else

	//Pega os valores atuais que estao no Acols
	cID		         := oBrw:aCols[oBrw:nAt,nPID]
	cModulo		     := oBrw:aCols[oBrw:nAt,nPModulo]
	cModalidade      := oBrw:aCols[oBrw:nAt,nPModalidade]
	cModLic          := oBrw:aCols[oBrw:nAt,nPModLic]
	cSeq             := oBrw:aCols[oBrw:nAt,nPSeq]
	cTpServ     	 := oBrw:aCols[oBrw:nAt,nPTpServ]

	If (lServico .Or. lSD)
		nQuant		 := oBrw:aCols[oBrw:nAt,nPHorasa]
		nPrecoVenda  := oBrw:aCols[oBrw:nAt,nPVlHrDe]
		nPrecoTabela := oBrw:aCols[oBrw:nAt,nPVlHora]
		cObserv  	 := oBrw:aCols[oBrw:nAt,nPObserv]
	Else
		nQuant		 := oBrw:aCols[oBrw:nAt,nPQuant]
		nPrecoVenda  := oBrw:aCols[oBrw:nAt,nPPrcVen]
		nPrecoTabela := oBrw:aCols[oBrw:nAt,nPPrcTab]
		nPerMan 	 := oBrw:aCols[oBrw:nAt,nPPerMan]
		cTpManu 	 := oBrw:aCols[oBrw:nAt,nPTpManu]
		nVlrMnt  	 := oBrw:aCols[oBrw:nAt,nPVlrMnt]
		cTpCalc		 := oBrw:aCols[oBrw:nAt,nPTpCalc]
		cLimMin  	 := oBrw:aCols[oBrw:nAt,nPLimMin]
		cLimMax  	 := oBrw:aCols[oBrw:nAt,nPLimMax]
	EndIf

	nPercDesconto    := oBrw:aCols[oBrw:nAt,nPPerDes]
	nDescItem    	 := Round(oBrw:aCols[oBrw:nAt,nPValDes] / nQuant,2)
	nCusto		     := oBrw:aCols[oBrw:nAt,nPCusto]

EndIf

If ( 'M->Z05_PRCTAB' == cVar )	
	nPrecoTabela := &(cVar)
	If nPrecoVenda >= nPrecoTabela
		nPrecoVenda 	:= nPrecoTabela
		nPercDesconto   := 0
		nDescItem    	:= 0
	Else
		nPercDesconto:= Round(( 1 - ( nPrecoVenda / nPrecoTabela ) ) * 100,2)
		nDescItem    := nPrecoTabela - nPrecoVenda

		If (nPercDesconto <= 0)
			nPercDesconto:= 0
			nDescItem    := 0
		EndIf
				
	EndIf
//Verifica se a chamada partiu do campo de Ordem (Sequencia)
ElseIF ( 'M->Z05_SEQ' == cVar )	
	cSeq:= &(cVar)
	
	//Verifica se a sequencia ja existe
	nPos:= aScan(oBrw:aCols,{|x| x[1] == cSeq .And. !x[nPDelete]})
	If (nPos > 0) .And. (nPos <> oBrw:nAt)
		Aviso("Atencao","Esta sequencia ja foi informada! Informe outro numero de sequencia.",{"Ok"})
		Return(.F.)
	EndIf

	//Tenta verificar se 'e um numero e nao tem outros caracteres
	If Val(cSeq) == 0
		Aviso("Atencao","Sequencia invalida! Informe apenas numeros como codigo de sequencia.",{"Ok"})
		Return(.F.)
	EndIf

	//Atualiza para o novo codigo de sequencia e reordena o vetor para atualizar o acols
	oBrw:aCols[nSavnAt,nPSeq]:= cSeq
	oBrw:aCols:= aSort(oBrw:aCols,,,{|x,y| IIf(x[nPDelete],'a','z')+x[nPSeq] < IIf(y[nPDelete],'a','z')+y[nPSeq] })
	nPos:= aScan(oBrw:aCols,{|x| x[1] == cSeq .And. !x[nPDelete]})
	
//Verifica se a chamada partiu do campo Quantidade
ElseIF ( 'M->Z05_QUANT' == cVar )	
	nQuant		 := &(cVar)
	/*
	//Valida os Limites Minimos e Maximo
	If lLicenca .And. (Val(cLimMin) > 0) .And. (Val(cLimMax) > 0)
		If (nQuant < Val(cLimMin)) .Or.; 
		(nQuant > Val(cLimMax))

			Aviso("Atencao","A quantidade informada est� fora dos Limites Minimos e Maximo permitidos para este tipo de licenca.",{"Ok"})
			Return(.F.)
		EndIf
	EndIf
	*/
	If lLicenca
		nRet:= GetTabPrc(cModulo,nQuant)
		If nRet <> 0
			Z24->( DbGoto(nRet) )
			
			nCusto	    := Z24->Z24_CUSTO
			nPrecoVenda := Z24->Z24_PRCVEN
			nPrecoTabela:= Z24->Z24_PRCTAB
			nPercDesconto:=Z24->Z24_DESCON
			cLimMin      := cValToChar(Z24->Z24_QTDMIN)
			cLimMax      := cValToChar(Z24->Z24_QTDMAX)
			
		Else
			Aviso("Atencao","A quantidade informada nao est� cadastrada na tabela de preco para este modulo.",{"Ok"})
			Return(.F.)					
		EndIf

	EndIf
ElseIF ( 'M->Z05_PRCVEN' == cVar )	
	nPrecoVenda	 := &(cVar)
	nPercDesconto:= Round(( 1 - ( nPrecoVenda / nPrecoTabela ) ) * 100,2)
	nDescItem    := nPrecoTabela - nPrecoVenda
	If (nPercDesconto < 0)
		nPercDesconto:= 0
		nDescItem    := 0
	EndIf	

ElseIF ( 'M->Z05_PERDES' == cVar )
	nPercDesconto:= &(cVar)
	If (nPercDesconto > 100)
		nPercDesconto:= 100
	EndIf	

	nPrecoVenda	 := Round(nPrecoTabela * (1- (nPercDesconto/100)),2)
	nDescItem    := nPrecoTabela - nPrecoVenda

ElseIF ( 'M->Z05_VALDES' == cVar )
	nValDesc     := &(cVar)
	nDescUni     := Round(nValDesc / nQuant,2)

	If nDescUni > nPrecoTabela
		nDescUni:= nPrecoTabela
	EndIf

	nPrecoVenda	 := nPrecoTabela - nDescUni
	nPercDesconto:= Round((nDescUni / nPrecoTabela) * 100,2)
	nDescItem:= nDescUni

ElseIF ( 'M->Z05_CUSTO' == cVar )
	nCusto       := &(cVar) 
	
ElseIF ( 'M->Z05_HORASA' == cVar )
	If ValType(&cVar) == "N"
		nQuant		 := &(cVar)
	Else
		nQuant		 := 1
	EndIf	

ElseIF ( 'M->Z05_VLHRDE' == cVar )
	nPrecoVenda  := &(cVar)
	nPercDesconto:= Round(( 1 - ( nPrecoVenda / nPrecoTabela ) ) * 100,2)
	nDescItem    := nPrecoTabela - nPrecoVenda

	If (nPercDesconto < 0)
		nPercDesconto:= 0
		nDescItem    := 0
	EndIf
EndIF
//Analisar o maximo de desconto permitido
If lLicenca .and. nPercDesconto > 0
	nRet:= GetTabPrc(cModulo,nQuant)
	If nRet <> 0
		Z24->( DbGoto(nRet) )
		If Z24->Z24_MAXDES <> 0 .and. nPercDesconto > Z24->Z24_MAXDES 
			Aviso("Atencao","O percentual maximo de desconto permitido para este modulo e' : "+Alltrim(TRANSFORM( Z24->Z24_MAXDES,PesqPict("Z24","Z24_MAXDES") ) )+" %" ,{"Ok"})
			Return(.F.)		
		EndIf
	EndIf
EndIf

//Atualiza o Acols que sera utilizado para a gravacao
For nX:= 1 To Len(oBrw:aCols)
	nPos:= aScan(aSaveEscopo,{|x| x[1] == oBrw:aCols[nX,nPID]})
	If (nPos > 0)
		aSaveEscopo[nPos,4]:= nX
	EndIf
Next nX

//Verifica qual a nova posicao no vetor
nPos:= aScan(oBrw:aCols,{|x| x[nPID] == cID .And. !x[nPDelete]})
If (nPos == 0)
	nPos:= 1
EndIf	

//Atualiza o acols na tela
oBrw:nAT  := nPos
oBrw:oBrowse:nAT  := nPos

//Atualiza os campos de modalidade de proposta (1-Licenca SAAS, 2-Licenca OnPremise , 3-Servico, 4-Suporte Mensal)
oBrw:aCols[oBrw:nAt,nPModalidade]:= cModalidade

//Atualiza os campos de sequencia de execucao para compatibilidade com licencas e outros servicos de unica sequencia
oBrw:aCols[oBrw:nAt,nPSeq]   := cSeq

//Atualiza os campos do tipo do projeto 1-Consultoria ou 2- Desenvolvimento . Necessario para a criacao automatica dos projetoss
oBrw:aCols[oBrw:nAt,nPTpServ]:= cTpServ

IF cModalidade == '4' .And. lLicenca// SaaS
	
	oBrw:aCols[oBrw:nAt,nPQuant]  := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := 0
	oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( nQuant * nPrecoVenda  , 2 )
	oBrw:aCols[oBrw:nAt,nPPrcVen] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPPrcTab] := nPrecoTabela
	oBrw:aCols[oBrw:nAt,nPLimMin] := cLimMin
	oBrw:aCols[oBrw:nAt,nPLimMax] := cLimMax
	oBrw:aCols[oBrw:nAt,nPModLic] := cModLic

ElseIF cModalidade == '5' .And. lLicenca// Suporte
	
	oBrw:aCols[oBrw:nAt,nPQuant]  := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := 0
	oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( nQuant * nPrecoVenda  , 2 )
	oBrw:aCols[oBrw:nAt,nPPrcVen] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPPrcTab] := nPrecoTabela
ElseIF cModalidade == '2' .And. lLicenca // On Premise

	oBrw:aCols[oBrw:nAt,nPQuant]  := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := Round ( ( nQuant * nPrecoVenda ) , 2 )
	oBrw:aCols[oBrw:nAt,nPPrcVen] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPPrcTab] := nPrecoTabela

	Do Case 
		Case (cTpCalc == '1') //Calculo da Manutencao por Percentual
			oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( ( nQuant * ( nPrecoTabela * nPerMan) ) / IIf(cTpManu == "1",12,1), 2 )
		Case (cTpCalc == '2') //Calculo da Manutencao por Usuario
			oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( ( nQuant * nVlrMnt ) / IIf(cTpManu == "1",12,1), 2 )
		Case (cTpCalc == '3') //Calculo da Manutencao por Valor Fixo
			oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( nVlrMnt / IIf(cTpManu == "1",12,1), 2 )
	EndCase

	oBrw:aCols[oBrw:nAt,nPPerMan] := nPerMan	
	oBrw:aCols[oBrw:nAt,nPTpManu] := cTpManu
	oBrw:aCols[oBrw:nAt,nPVlrMnt] := nVlrMnt	
	oBrw:aCols[oBrw:nAt,nPTpCalc] := cTpCalc
	oBrw:aCols[oBrw:nAt,nPLimMin] := cLimMin
	oBrw:aCols[oBrw:nAt,nPLimMax] := cLimMax
	oBrw:aCols[oBrw:nAt,nPModLic] := cModLic
ElseIF cModalidade == '3' .And. lLicenca// On Adesao
	
	oBrw:aCols[oBrw:nAt,nPQuant]  := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := Round( ( nQuant * nPrecoVenda ) , 2 )
	oBrw:aCols[oBrw:nAt,nPVlrMes] := 0
	oBrw:aCols[oBrw:nAt,nPPrcVen] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPPrcTab] := nPrecoTabela
	oBrw:aCols[oBrw:nAt,nPModLic] := cModLic

ElseIF cModalidade == '5' .And. M->Z02_TIPO $ "26"//Suporte Mensal
	
	oBrw:aCols[oBrw:nAt,nPHorasa] := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := 0
	oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( nQuant * nPrecoVenda  , 2 )
	oBrw:aCols[oBrw:nAt,nPVlHrDe] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPVlHora] := nPrecoTabela
	oBrw:aCols[oBrw:nAt,nPObserv] := cObserv

ElseIF cModalidade == '4' .And. lSD// Service Desk
	
	oBrw:aCols[oBrw:nAt,nPHorasa] := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := 0
	oBrw:aCols[oBrw:nAt,nPVlrMes] := Round( nQuant * nPrecoVenda  , 2 )
	oBrw:aCols[oBrw:nAt,nPVlHrDe] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPVlHora] := nPrecoTabela
ElseIf !Empty(cModalidade) // Servico
	If ValType(nQuant) <> "N"
		Alert("nQuant:" + ValType(nQuant))
	ElseIf ValType(nPrecoVenda) <> "N"
		Alert("nPrecoVenda:" + ValType(nPrecoVenda))
	EndIf

	oBrw:aCols[oBrw:nAt,nPHorasa] := nQuant
	oBrw:aCols[oBrw:nAt,nPTotal]  := Round( ( nQuant * nPrecoVenda ) , 2 )
	oBrw:aCols[oBrw:nAt,nPVlHrDe] := nPrecoVenda
	oBrw:aCols[oBrw:nAt,nPVlHora] := nPrecoTabela
	oBrw:aCols[oBrw:nAt,nPObserv] := cObserv

EndIF

oBrw:aCols[oBrw:nAt,nPTotCIP] := Round(oBrw:aCols[oBrw:nAt,nPTotal] / M->Z02_IMPOST, 2 )
oBrw:aCols[oBrw:nAt,nPPerDes] := nPercDesconto
oBrw:aCols[oBrw:nAt,nPValDes] := nDescItem * nQuant
oBrw:aCols[oBrw:nAt,nPCusto]  := nCusto
oBrw:aCols[oBrw:nAt,nPCusTot] := Round(nQuant * nCusto,2)
oBrw:aCols[oBrw:nAt,nPData]   := dDatabase + 30
oBrw:aCols[oBrw:nAt,nPMargem] := Round(( ( nPrecoVenda - nCusto ) / nPrecoVenda ) * 100,2)
oBrw:oBrowse:Refresh()
oBrw:Refresh()

If Type("oResumo") <> "U"
	//Se for servico
	If lServico
		oResumo:aCols:= aClone(oBrw:aCols)
		oResumo:nAt:= oBrw:nAt
	EndIf	

	//Atualiza as comissoes
	U_AtuZ08()
else
	oEscopo:aCols:= aClone(oBrw:aCols)
	oEscopo:nAt:= oBrw:nAt
EndIf

RestArea(aArea)

Return(lRet)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � CalculaHorasCoordenacao � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Calcula as horas de coodenacao               			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function CalculaHorasCoordenacao()

Local aArea         := GetArea()
Local aTemp         := {}
Local nLCoordena    := 0
Local nA            := 0
Local nPID		  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
Local nPSeq		  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_SEQ"})
Local nPModulo  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
Local nPDescri  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_DESCRI"})
Local nPModalidade 	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MOD"})
Local nPCusto   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTO"})
Local nPCusTot 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
Local nPPrcTab   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nPMargem		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MARGEM"})
Local nPPerDes 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PERDES"})
Local nPQuant		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPTotal   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPHorasa		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nPVlHrDe		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local nPVlHora		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nPTotCIP		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTCIP"})
Local nPHoras		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_HORAS"})
Local nPDias		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_DIAS"})
Local nPTpServ		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TPSERV"})
Local nPObserv		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_OBSERV"})
Local nQuant		:= 0
Local nPrecoVenda	:= 0
Local nPrecoTabela	:= 0
Local nPercDesconto := 0
Local nCusto        := 0
Local nDesconto     := 0
Local nSavnAT       := 1
Local nX            := 0
Local nHorasDia     := GetNewPar("MV_AFHRDIA",10) //Horas por Dia
Local nHoraCusto    := GetNewPar("MV_HORACUS",70) //Valor Hora Padrao
Local nLenItem      := 0
Local nPDelete      := Len(aHeaderZ05)+1
Local cModalidade   := ""
Local cCampo        := ""
Local cProdGP       := GetNewPar("MV_AFGP","SAP-I001") //Produto do Gerente de Projeto SAP
Local cProdGPFS     := GetNewPar("MV_AFGPFS","SAP-I003") //Produto do Gerente de Desenvolvimento SAP

//Salva as posicoes do vetor
nHrConsult:= 0
nHrCoord  := 0
nHrDesenv := 0
nHrCoordFS:= 0

For nA := 1 To Len(oEscopo:aCols)
	IF (oEscopo:aCols[nA,Len(oEscopo:aHeader)+1]) .Or. Empty(oEscopo:aCols[nA,nPModulo])// Linha Deletada
		Loop
	EndIF

	//Verifica se o m鏚ulo/atividade � desenvolvimento ou consultoria
	If (oEscopo:aCols[nA,nPTpServ] == '1') .And. (AllTrim(oEscopo:aCols[nA,nPModulo]) <> cProdGP)
		nHrConsult += oEscopo:aCols[nA,nPHorasa]
	ElseIf (oEscopo:aCols[nA,nPTpServ] == '2') .And. (AllTrim(oEscopo:aCols[nA,nPModulo]) <> cProdGPFS)
		nHrDesenv += oEscopo:aCols[nA,nPHorasa]
	EndIf	
Next nA

nHrCoord  := Round(nHrConsult * 0.2,0)
nHrCoordFS:= Round(nHrDesenv * 0.2,0)

nPrecoTabela := M->Z02_VLCOOR
nPercDesconto:= 0
nPrecoVenda  := M->Z02_VLCOOR
nCusto		 := nHoraCusto
nTotHrsProj  := nHrConsult + nHrDesenv + nHrCoord + nHrCoordFS

//Adiciona as horas de coordenacao de projeto de consultoria
If (nHrCoord > 0)
	aTemp:= aClone(oEscopo:aCols)

	//Pega o ultimo ID
	aTemp := aSort(aTemp,,,{|x,y| x[nPID] < y[nPID] })
	cMaxID:= aTemp[Len(aTemp),nPID]

	//Pega a ultima sequencia
	aTemp := aSort(aTemp,,,{|x,y| IIf(x[nPDelete],'a','z')+x[nPSeq] < IIf(y[nPDelete],'a','z')+y[nPSeq] })
	cSeq:= aTemp[Len(aTemp),nPSeq]

	nPos:= aScan(oEscopo:aCols,{|x| AllTrim(x[nPModulo]) == cProdGP .And. !x[nPDelete] })
	If (nPos == 0)
		//Se nao existir a coordenacao cria uma nova linha
		aAdd(oEscopo:aCols,Array(Len(oEscopo:aHeader)+1))
		nLCoordena   := Len(oEscopo:aCols)
		For nX := 1 To Len(oEscopo:aHeader)
			If (Alltrim(oEscopo:aHeader[nX,2]) == "XXX")
				oEscopo:aCols[nLCoordena,nX] := IIF(Len(oEscopo:aCols) == 1,'X','')
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_ID")
				cID:= Soma1(cMaxID)
				oEscopo:aCols[nLCoordena,nX] := cID
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_SEQ")
				cSeq:= Soma1(cSeq)
				oEscopo:aCols[nLCoordena,nX] := cSeq
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_MODULO")
				oEscopo:aCols[nLCoordena,nX] := cProdGP
			Else
				oEscopo:aCols[nLCoordena,nX] := CriaVar(oEscopo:aHeader[nX,2])
			EndIf	
		Next nX
		oEscopo:aCols[nLCoordena,Len(oEscopo:aHeader)+1] := .F.
	Else
		nLCoordena   := nPos
		cID := oEscopo:aCols[nLCoordena,nPID]
		cSeq:= oEscopo:aCols[nLCoordena,nPSeq]
	EndIf	

	Z00->(dbSetOrder(1))
	Z00->(DbSeek(xFilial("Z00")+cProdGP))
	oEscopo:aCols[nLCoordena,nPDescri]    	:= Z00->Z00_DESCRI
	oEscopo:aCols[nLCoordena,nPModalidade]	:= "3"
	oEscopo:aCols[nLCoordena,nPObserv]    	:= Alltrim(Z00->Z00_MEMO0)//MSMM(Z00->Z00_CODM1)
	oEscopo:aCols[nLCoordena,nPHorasa] 		:= nHrCoord
	oEscopo:aCols[nLCoordena,nPTotal]		:= Round ( ( nHrCoord * nPrecoVenda ) , 2 )
	oEscopo:aCols[nLCoordena,nPVlHrDe] 		:= nPrecoVenda
	oEscopo:aCols[nLCoordena,nPVlHora] 		:= nPrecoTabela
	oEscopo:aCols[nLCoordena,nPTotCIP] 		:= Round (oEscopo:aCols[nLCoordena,nPTotal] / M->Z02_IMPOST, 2 )
	oEscopo:aCols[nLCoordena,nPPerDes] 		:= nPercDesconto
	oEscopo:aCols[nLCoordena,nPCusto]  		:= nCusto
	oEscopo:aCols[nLCoordena,nPCusTot] 		:= Round(nHrCoord * nCusto,2)
	oEscopo:aCols[nLCoordena,nPMargem] 		:= Round(( ( nPrecoVenda - nCusto ) / nPrecoVenda ) * 100,2)
	oEscopo:aCols[nLCoordena,nPTpServ] 		:= "1"

	//Verifica se os itens do modulo estao salvos
	nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
	If (nPos > 0)
		//Atualiza os itens da coordenacao
		nLenItem:= Len(aSaveEscopo[nPos,5])
		If (nLenItem > 0)
			aSaveEscopo[nPos,5,nLenItem,nPHoras]:= nHrCoord
			aSaveEscopo[nPos,5,nLenItem,nPDias] := nHrCoord / nHorasDia
		EndIf
	EndIf
EndIf

//Adiciona as horas de coordenacao de projeto de desenvolvimento
If (nHrCoordFS > 0)
	aTemp:= aClone(oEscopo:aCols)
	aTemp := aSort(aTemp,,,{|x,y| x[nPID] < y[nPID] })
	cMaxID:= aTemp[Len(aTemp),nPID]

	//Pega a ultima sequencia
	aTemp := aSort(aTemp,,,{|x,y| IIf(x[nPDelete],'a','z')+x[nPSeq] < IIf(y[nPDelete],'a','z')+y[nPSeq] })
	cSeq:= aTemp[Len(aTemp),nPSeq]

	nPos:= aScan(oEscopo:aCols,{|x| AllTrim(x[nPModulo]) == cProdGPFS  .And. !x[nPDelete]})
	If (nPos == 0)
		//Se nao existir a coordenacao cria uma nova linha
		aAdd(oEscopo:aCols,Array(Len(oEscopo:aHeader)+1))
		nLCoordena   := Len(oEscopo:aCols)
		For nX := 1 To Len(oEscopo:aHeader)
			If (Alltrim(oEscopo:aHeader[nX,2]) == "XXX")
				oEscopo:aCols[nLCoordena,nX] := IIF(Len(oEscopo:aCols) == 1,'X','')
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_ID")
				cID:=  Soma1(cMaxID)
				oEscopo:aCols[nLCoordena,nX] := cID
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_SEQ")
				cSeq:= Soma1(cSeq)
				oEscopo:aCols[nLCoordena,nX] := cSeq
			ElseIf (Alltrim(oEscopo:aHeader[nX,2]) == "Z05_MODULO")
				oEscopo:aCols[nLCoordena,nX] := cProdGPFS
			Else
				oEscopo:aCols[nLCoordena,nX] := CriaVar(oEscopo:aHeader[nX,2])
			EndIf	
		Next nX
		oEscopo:aCols[nLCoordena,Len(oEscopo:aHeader)+1] := .F.
	Else
		nLCoordena   := nPos
		cID := oEscopo:aCols[nLCoordena,nPID]
		cSeq:= oEscopo:aCols[nLCoordena,nPSeq]
	EndIf	

	Z00->(dbSetOrder(1))
	Z00->(DbSeek(xFilial("Z00")+cProdGPFS))
	oEscopo:aCols[nLCoordena,nPDescri]    := Z00->Z00_DESCRI
	oEscopo:aCols[nLCoordena,nPModalidade]:= "3"
	oEscopo:aCols[nLCoordena,nPObserv]    := Alltrim(Z00->Z00_MEMO0)//MSMM(Z00->Z00_CODM1)
	oEscopo:aCols[nLCoordena,nPHorasa] 	  := nHrCoordFS
	oEscopo:aCols[nLCoordena,nPTotal]	  := Round ( ( nHrCoordFS * nPrecoVenda ) , 2 )
	oEscopo:aCols[nLCoordena,nPVlHrDe] 	  := nPrecoVenda
	oEscopo:aCols[nLCoordena,nPVlHora] 	  := nPrecoTabela
	oEscopo:aCols[nLCoordena,nPTotCIP] 	  := Round (oEscopo:aCols[nLCoordena,nPTotal] / M->Z02_IMPOST, 2 )
	oEscopo:aCols[nLCoordena,nPPerDes] 	  := nPercDesconto
	oEscopo:aCols[nLCoordena,nPCusto]  	  := nCusto
	oEscopo:aCols[nLCoordena,nPCusTot] 	  := Round(nHrCoordFS * nCusto,2)
	oEscopo:aCols[nLCoordena,nPMargem] 	  := Round(( ( nPrecoVenda - nCusto ) / nPrecoVenda ) * 100,2)
	oEscopo:aCols[nLCoordena,nPTpServ] 	  := "2"

	//Atualiza os itens da coordenacao
	//Verifica se os itens do modulo estao salvos
	nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
	If (nPos > 0)
		//Atualiza os itens da coordenacao
		nLenItem:= Len(aSaveEscopo[nPos,5])
		If (nLenItem > 0)
			aSaveEscopo[nPos,5,nLenItem,nPHoras]:= nHrCoordFS
			aSaveEscopo[nPos,5,nLenItem,nPDias] := nHrCoordFS / nHorasDia
		EndIf
	EndIf
EndIf

oEscopo:nAt:= Len(oEscopo:aCols)
oEscopo:oBrowse:Refresh()
oEscopo:Refresh()

RestArea(aArea)

Return

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � MontaZ05                � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Montas Accols da Z05                         			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function MontaZ05(aColsZ05,aHeaderZ05,nOpc,cTipo,cProposta,cAditivo)

Local aArea    := GetArea()
Local lDeleted := .F.
Local nX       := 0
Local nLin     := 0
Local cMiniPrj := SuperGetMv("MV_MPSAP",.F.,"SAP-I002") //"SAP-I002" - Produto da MiniProposta SAP
Local cID      := ""
Local cModulo  := ""
Local cID      := ""

aColsZ05  := {}
aHeaderZ05:= {}

If ReadVar() == "M->Z05_MODULO"
	cModulo:= M->Z05_MODULO

	//Se o acols ja estiver preenchido pergunta se deseja sobrepor o escopo
	If !Empty(oEscopo:aCols[oEscopo:nAt,1])
		If Aviso("Atencao","Deseja SOBREPOR as funcionalidades pelo Escopo Padrao do Modulo?",{"Nao","Sim"}) == 2
			lSobrepoe:= .T.
		EndIf	
	EndIf	
ElseIf Type("oEscopo") <> "U"
	cModulo := oEscopo:aCols[oEscopo:nAt,nPModulo]
	lDeleted:= oEscopo:aCols[oEscopo:nAt,Len(oEscopo:aHeader)+1]
EndIf

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Monta aHeaderZ05 a partir dos campos do SX3         	 �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z05')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z05' )

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
        //Nao exibe campos de servico quando for licenca
        If lLicenca .And. Alltrim(SX3->X3_CAMPO) $ "Z05_HORAS///Z05_TRANSL/Z05_CODOBS" //Licencas//Z05_HORASA/Z05_VLHORA/Z05_VLHRDE
            SX3->(DbSkip())
            Loop
        EndIf    

        //Nao exibe campos de LICENCA quando for SERVICO
        If lServico .And. Alltrim(SX3->X3_CAMPO) $ "Z05_QUANT/Z05_VLRMES/Z05_MANUTA/Z05_PRCTAB/Z05_PRCVEN/Z05_TRANSL/Z05_TPMANU/Z05_PERMAN/Z05_TPCALC/ZO5_VLRMNT/Z05_LIMMIN/Z05_LIMMAX" //SERVICOS
            SX3->(DbSkip())
            Loop
        EndIf    

        //Nao exibe campos de LICENCA quando for SERVICE DESK
        If lSD .And. Alltrim(SX3->X3_CAMPO) $ "Z05_QUANT/Z05_MANUTA/Z05_PRCTAB/Z05_PRCVEN/Z05_TRANSL/Z05_TPMANU/Z05_PERMAN/Z05_TPCALC/ZO5_VLRMNT/Z05_LIMMIN/Z05_LIMMAX" //SERVICOS
            SX3->(DbSkip())
            Loop
        EndIf    

		AADD(aHeaderZ05,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

//Adiciona o Controle de Cor (X)
Aadd(aHeaderZ05,{"","XXX","@!"	,02,0,".F.","�","C","","V","","" } )

IF nOpc != 3 .And. nOpc != 7 .And. !lDeleted .And. !lSobrepoe
	
	nI:= 0

    cQuery := " SELECT R_E_C_N_O_ AS RECNO "
    cQuery += " FROM " + RetSqlName("Z05") + " Z05 "
    cQuery += " WHERE Z05_FILIAL 	= '" 	+ xFilial("Z05") 	+ "'"
    cQuery += " AND Z05_PROPOS 		= '" 	+ cProposta  	+ "'"
    cQuery += " AND Z05_ADITIV 		= '" 	+ cAditivo  	+ "'"
    cQuery += " AND Z05.D_E_L_E_T_ 	= ' ' "
    cQuery += " ORDER BY Z05_SEQ,Z05_MODULO"
    
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
    
    DbSelectArea("TMP")
    DbGoTop()
    While !Eof()
        
        DbSelectarea("Z05")
        DbGoto( TMP->RECNO )
        
        Aadd(aColsZ05,Array(Len(aHeaderZ05)+1))
        For nX	:= 1 To Len(aHeaderZ05)
			If (AllTrim(aHeaderZ05[nX][2]) == "XXX")
				aColsZ05[Len(aColsZ05)][nX] := IIF(Len(aColsZ05) == 1,'X','')
            ElseIF ( aHeaderZ05[nX][10] != "V" )
                aColsZ05[Len(aColsZ05)][nX] := FieldGet(FieldPos(aHeaderZ05[nX][2]))
            Else
                aColsZ05[Len(aColsZ05)][nX] := CriaVar(aHeaderZ05[nX][2])
            EndIF
        Next nX
        
		aColsZ05[Len(aColsZ05)][Len(aHeaderZ05)+1] := .F.

		//Carrega o vetor do aCols
		nI++
		
		nPos:= aScan(aSaveEscopo,{|x| x[1] == Z05->Z05_ID})
		If (nPos == 0)
			aAdd(aSaveEscopo,{Z05->Z05_ID,Z05->Z05_MODULO,aColsZ05[nI],nI,{},Z05->Z05_TPSERV,.F.})
			MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,Z05->Z05_ID,Z05->Z05_MODULO,cProposta,cAditivo)
		EndIf

        DbSelectarea("TMP")
        DbSkip()
        
    EndDo
    TMP->(DbCloseArea())
EndIF

IF nOpc == 3 .Or. Len(aColsZ05) == 0 .Or. lSobrepoe
	//Se estiver indicado uma oferta ja alimenta o acols com os modulos
	If !Empty(M->Z02_OFERTA)

		DbSelectArea("Z17")
		DbSetOrder(1)
		DbSeek(xFilial("Z17")+M->Z02_OFERTA)
		While !Eof() .And. (xFilial("Z17")+M->Z02_OFERTA == Z17->Z17_FILIAL+Z17->Z17_ESCOPO)

			Z00->(dbSetOrder(1))
			Z00->(dbSeek(xFilial("Z00")+Z17->Z17_MODULO))

			nQuant       := IIF(lLicenca ,1, Z17->Z17_HORAS)
			nPercDesconto:= 0
			nCusto		 := Z00->Z00_CUSTO
			nPrecoVenda  := IIF(lLicenca ,Z00->Z00_PRCTAB,M->Z02_VLHORA)
			nPrecoTabela := IIF(lLicenca ,Z00->Z00_PRCTAB,M->Z02_VLHORA)

			Aadd(aColsZ05,Array(Len(aHeaderZ05)+1))
			nLin:= Len(aColsZ05)
			For nX	:= 1 To Len(aHeaderZ05)
				If (AllTrim(aHeaderZ05[nX][2]) == "Z05_ID")
					cId:= StrZero(nLin,6)
					aColsZ05[nLin][nX] := cId
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MODULO")
					aColsZ05[nLin][nX] := Z17->Z17_MODULO
					cModulo            := Z17->Z17_MODULO
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_DESCRI")
					aColsZ05[nLin][nX] := Z00->Z00_DESCRI
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_HORASA")
					aColsZ05[nLin][nX] := Z17->Z17_HORAS	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_CUSTO")
					aColsZ05[nLin][nX] := nCusto	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_VLHORA")
					aColsZ05[nLin][nX] := nPrecoTabela	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_VLHRDE")
					aColsZ05[nLin][nX] := nPrecoVenda	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TOTAL")
					aColsZ05[nLin][nX] := Round( ( nQuant * nPrecoVenda ) , 2 )	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_CUSTOT")
					aColsZ05[nLin][nX] := Round(nQuant * nCusto	,2)
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TOTCIP")
					aColsZ05[nLin][nX] := Round( ( nQuant * nPrecoVenda ) / M->Z02_IMPOST, 2 )	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MARGEM")
					aColsZ05[nLin][nX] := Round(( ( nPrecoVenda - nCusto ) / nPrecoVenda ) * 100,2)
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MOD")
					aColsZ05[nLin][nX] := Z00->Z00_MOD
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_DATA")
					aColsZ05[nLin][nX] := dDatabase+30
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TPSERV")
					aColsZ05[nLin][nX] := Z00->Z00_TPSERV
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_SEQ")
					aColsZ05[nLin][nX] := Z00->Z00_SEQ
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "XXX")
					aColsZ05[nLin][nX] := IIF(nLin == 1,'X','')
				Else
					aColsZ05[nLin][nX] := CriaVar(aHeaderZ05[nX][2])
				EndIF
			Next nX
			aColsZ05[nLin][Len(aHeaderZ05)+1] := .F.

			//Carrega o vetor do aCols
			nPos:= aScan(aSaveEscopo,{|x| x[1] == cId})
			If (nPos == 0)
				aAdd(aSaveEscopo,{cId,cModulo,aColsZ05[nLin],nLin,{},Z00->Z00_TPSERV,.F.})
				MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cId,cModulo,cProposta,cAditivo)
			EndIf

			Z05Change(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cProposta,cAditivo)

			DbSelectarea("Z17")
			DbSkip()
			
		EndDo

	EndIf


	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cria aCols auxiliares vazios.                                 �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	If Len(aColsZ05) == 0
		Aadd(aColsZ05,Array(Len(aHeaderZ05)+1))
		For nX := 1 To Len(aHeaderZ05)
			If (AllTrim(aHeaderZ05[nX][2]) == "Z05_ID")
				cId:= StrZero(1,6)
				aColsZ05[Len(aColsZ05)][nX]:= cId
			ElseIf (AllTrim(aHeaderZ05[nX][2]) == "XXX")
				aColsZ05[Len(aColsZ05)][nX]:= IIF(Len(aColsZ05) == 1,'X','')
			Else	
				aColsZ05[Len(aColsZ05)][nX]:= CriaVar(aHeaderZ05[nX,2])
			EndIf	
		Next nX
		aColsZ05[Len(aColsZ05),Len(aHeaderZ05)+1] := .F.

		//Verifica se 'e uma MiniProposta e ja prerenche automatico
		If (M->Z02_TIPO $ "7")

			cModulo:= Padr(cMiniPrj,TamSX3("Z00_MODULO")[1])  //Modulo para MiniProposta
			Z00->(dbSetOrder(1))
			Z00->(dbSeek(xFilial("Z00")+cModulo,.T.))

			Z01->(dbSetOrder(1))
			Z01->(dbSeek(xFilial("Z01")+Z00->Z00_MODULO,.T.))

			nQuant       := Z01->Z01_HORAS
			nPercDesconto:= 0
			nCusto		 := Z00->Z00_CUSTO
			nPrecoVenda  := Z00->Z00_PRCTAB
			nPrecoTabela := Z00->Z00_PRCVEN

			nLin:= Len(aColsZ05)
			For nX	:= 1 To Len(aHeaderZ05)
				If (AllTrim(aHeaderZ05[nX][2]) == "Z05_ID")
					cID			   	   := StrZero(nLin,6)
					aColsZ05[nLin][nX] := cID
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MODULO")
					aColsZ05[nLin][nX] := Z00->Z00_MODULO
					cModulo			   := Z00->Z00_MODULO
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_DESCRI")
					aColsZ05[nLin][nX] := Z00->Z00_DESCRI
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_HORASA")
					aColsZ05[nLin][nX] := Z01->Z01_HORAS	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_CUSTO")
					aColsZ05[nLin][nX] := nCusto	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_VLHORA")
					aColsZ05[nLin][nX] := nPrecoTabela	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_VLHRDE")
					aColsZ05[nLin][nX] := nPrecoVenda	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TOTAL")
					aColsZ05[nLin][nX] := Round ( ( nQuant * nPrecoVenda ) , 2 )	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_CUSTOT")
					aColsZ05[nLin][nX] := nQuant * nCusto	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TOTCIP")
					aColsZ05[nLin][nX] := Round( ( nQuant * nPrecoVenda ) / M->Z02_IMPOST, 2 )	
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MARGEM")
					aColsZ05[nLin][nX] := Round( (( nPrecoVenda - nCusto ) / nPrecoVenda ) * 100	,2)
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_MOD")
					aColsZ05[nLin][nX] := Z00->Z00_MOD
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_DATA")
					aColsZ05[nLin][nX] := dDatabase+30
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_TPSERV")
					aColsZ05[nLin][nX] := Z00->Z00_TPSERV
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_SEQ")
					aColsZ05[nLin][nX] := Z00->Z00_SEQ
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "Z05_OBSERV")
					aColsZ05[nLin][nX] := Alltrim(Z00->Z00_MEMO0)//MSMM(Z00->Z00_CODM1)
				ElseIf (AllTrim(aHeaderZ05[nX][2]) == "XXX")
					aColsZ05[nLin][nX] := IIF(nLin == 1,'X','')
				Else
					aColsZ05[nLin][nX] := CriaVar(aHeaderZ05[nX][2])
				EndIF
			Next nX
			aColsZ05[nLin][Len(aHeaderZ05)+1] := .F.

			//Carrega o vetor do aCols
			nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
			If (nPos == 0)
				aAdd(aSaveEscopo,{cID,cModulo,aColsZ05[nLin],nLin,{},Z00->Z00_TPSERV,.F.})
				MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cID,cModulo,cProposta,cAditivo)
			EndIf
		ENDIF

	EndIf	
EndIF

/*==================================================
ESCOPO DA PROPOSTA
====================================================*/
nPModulo:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
nPID    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
cID     := IIF(Len(aColsZ05) > 0,aColsZ05[1,nPID],StrZero(1,6))
cModulo := IIF(Len(aColsZ05) > 0,aColsZ05[1,nPModulo],"")
MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,M->Z02_TIPO,cID,cModulo,cProposta,cAditivo)

/*==================================================
PARCELAS DA PROPOSTA
====================================================*/
MontaZ04(@aColsZ04,@aHeaderZ04,nOpc,M->Z02_TIPO,cProposta,cAditivo)

/*==================================================
COMISSOES DA PROPOSTA
====================================================*/
MontaZ08(@aColsZ08,@aHeaderZ08,nOpc,M->Z02_TIPO,cProposta,cAditivo)

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � MontaZ04                � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Montas Accols da Z04                         			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function MontaZ04(aColsZ04,aHeaderZ04,nOpc,cTipo,cProposta,cAditivo)

Local aArea    := GetArea()
Local nX       := 0

aColsZ04  := {}
aHeaderZ04:= {}

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Monta aHeaderZ04 a partir dos campos do SX3         	 �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z04')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z04' )

	//Nao exibe campos de LICENCAS OU SERVICE DESK quando for SERVICOS
	If lServico .And. Alltrim(SX3->X3_CAMPO) $ "Z04_QTDPAR/Z04_TOTAL" 
		SX3->(DbSkip())
		Loop
	EndIf    

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		AADD(aHeaderZ04,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

IF nOpc != 3 .And. nOpc != 7
	
    cQuery := " SELECT R_E_C_N_O_ AS RECNO "
    cQuery += " FROM " + RetSqlName("Z04") + " Z04 "
    cQuery += " WHERE Z04_FILIAL 	= '" 	+ xFilial("Z04") 	+ "'"
    cQuery += " AND Z04_PROPOS 		= '" 	+ cProposta  	+ "'"
    cQuery += " AND Z04_ADITIV 		= '" 	+ cAditivo  	+ "'"
    cQuery += " AND Z04.D_E_L_E_T_ 	= ' ' "
    cQuery += " ORDER BY Z04_PARCEL"
    
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
    
    DbSelectArea("TMP")
    DbGoTop()
    While !Eof()
        
        DbSelectarea("Z04")
        DbGoto( TMP->RECNO )
        
        Aadd(aColsZ04,Array(Len(aHeaderZ04)+1))
        For nX	:= 1 To Len(aHeaderZ04)
            IF ( aHeaderZ04[nX][10] != "V" )
				//Se for aditivo ajusta a data para o dia atual
				If (Alltrim(aHeaderZ04[nX][2]) == "Z04_DATA") .And. (nOpc == 7)
	                aColsZ04[Len(aColsZ04)][nX] := dDataBase
                Else
					aColsZ04[Len(aColsZ04)][nX] := FieldGet(FieldPos(aHeaderZ04[nX][2]))
				EndIf	
            Else
                aColsZ04[Len(aColsZ04)][nX] := CriaVar(aHeaderZ04[nX][2])
            EndIF
        Next nX
        aColsZ04[Len(aColsZ04)][Len(aHeaderZ04)+1] := .F.
        
        DbSelectarea("TMP")
        DbSkip()
        
    EndDo
    TMP->(DbCloseArea())
EndIF

IF nOpc == 3 .Or. Len(aColsZ04) == 0
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cria aCols auxiliares vazios.                                 �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	Aadd(aColsZ04,Array(Len(aHeaderZ04)+1))
	For nX := 1 To Len(aHeaderZ04)
		//Se for aditivo ajusta a data para o dia atual
		If (Alltrim(aHeaderZ04[nX][2]) == "Z04_DATA") .And. (nOpc == 7)
	        aColsZ04[Len(aColsZ04)][nX] := dDataBase
		Else
			aColsZ04[Len(aColsZ04),nX] := CriaVar(aHeaderZ04[nX,2])
		EndIf	
	Next nX
	aColsZ04[Len(aColsZ04),Len(aHeaderZ04)+1] := .F.
EndIF

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � MontaZ08                � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Montas Accols da Z08                         			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function MontaZ08(aColsZ08,aHeaderZ08,nOpc,cTipo,cProposta,cAditivo)

Local aArea    := GetArea()
Local nPVend   := 0
Local nX       := 0

aColsZ08  := {}
aHeaderZ08:= {}

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Monta aHeaderZ08 a partir dos campos do SX3         	 �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z08')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z08' )

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		AADD(aHeaderZ08,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

IF (nOpc != 3) .And. (nOpc != 7)
	
    cQuery := " SELECT R_E_C_N_O_ AS RECNO "
    cQuery += " FROM " + RetSqlName("Z08") + " Z08 "
    cQuery += " WHERE Z08_FILIAL 	= '" 	+ xFilial("Z08") 	+ "'"
    cQuery += " AND Z08_PROPOS 		= '" 	+ cProposta		  	+ "'"
    cQuery += " AND Z08_ADITIV 		= '" 	+ cAditivo  		+ "'"
    cQuery += " AND Z08.D_E_L_E_T_ 	= ' ' "
    cQuery += " ORDER BY Z08_FORNEC"
    
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
    
    DbSelectArea("TMP")
    DbGoTop()
    While !Eof()
        
        DbSelectarea("Z08")
        DbGoto( TMP->RECNO )
        
        Aadd(aColsZ08,Array(Len(aHeaderZ08)+1))
        For nX	:= 1 To Len(aHeaderZ08)
            IF ( aHeaderZ08[nX][10] != "V" )
                aColsZ08[Len(aColsZ08)][nX] := FieldGet(FieldPos(aHeaderZ08[nX][2]))
            Else
                aColsZ08[Len(aColsZ08)][nX] := CriaVar(aHeaderZ08[nX][2])
            EndIF
        Next nX
        aColsZ08[Len(aColsZ08)][Len(aHeaderZ08)+1] := .F.
        
        DbSelectarea("TMP")
        DbSkip()
        
    EndDo
    TMP->(DbCloseArea())
EndIF

IF (nOpc == 3) .Or. (nOpc == 7) .Or. (Len(aColsZ08) == 0)
	nPVend      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_FORNEC"})

 	nPNome      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_NOME"})
	nPComis     := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_PERC"})

	npVlBase 	:= aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_BASE"})

	

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cria aCols auxiliares vazios.                                 �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	Aadd(aColsZ08,Array(Len(aHeaderZ08)+1))
	For nX := 1 To Len(aHeaderZ08)
		aColsZ08[Len(aColsZ08),nX] := CriaVar(aHeaderZ08[nX,2])
	Next nX
	
	aColsZ08[Len(aColsZ08),nPVend]:= Posicione("SA3",1,xFilial("SA3")+M->Z02_VEND2,"A3_FORNECE")
	
	aColsZ08[Len(aColsZ08),nPNome]:= Posicione("SA3",1,xFilial("SA3")+M->Z02_VEND2,"A3_NOME")
	aColsZ08[Len(aColsZ08),nPComis]:= Posicione("SA3",1,xFilial("SA3")+M->Z02_VEND2,"A3_COMIS")

	aColsZ08[Len(aColsZ08),Len(aHeaderZ08)+1] := .F.
	
EndIF

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � MontaSU5                � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Montas Accols da SU5                         			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function MontaSU5(aColsSU5,aHeaderSU5,cTipo)

Local aArea    := GetArea()
Local nX       := 0

aColsSU5  := {}
aHeaderSU5:= {}

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Monta aHeaderSU5 a partir dos campos do SX3         	 �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('SU5')
While !Eof() .And. (SX3->X3_ARQUIVO == 'SU5' )

	//Nao exibe campos nao necessarios
	If !Alltrim(SX3->X3_CAMPO) $ "U5_CODCONT/U5_CONTAT/U5_SOBREN/U5_DDD/U5_FCOM1/U5_CELULAR/U5_FUNCAO/U5_DFUNCAO/U5_EMAIL/U5_XAPROV"
		SX3->(DbSkip())
		Loop
	EndIf    

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		AADD(aHeaderSU5,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
//	If ALLTRIM(SX3->X3_CAMPO) == "U5_CODCONT"
//		AADD(aHeaderSU5,{  "Apr.Proposta", "U5_XAPROV" ,PesqPict("SU5","U5_XAPROV"),1,0,"PERTENCE('SN')",,"C",,,'S=SIM,N=NAO'})
	//EndIf
	SX3->(DbSkip())
	
EndDo

cQuery := " SELECT SU5.R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName("SU5") + " SU5, "
cQuery += RetSqlName("AC8") + " AC8 "
cQuery += " WHERE SU5.U5_FILIAL = '" 	+ xFilial("SU5") 	+ "'"
cQuery += " AND SU5.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.AC8_FILIAL  = SU5.U5_FILIAL "
cQuery += " AND SU5.U5_CODCONT	= AC8.AC8_CODCON "

If !Empty(M->Z02_CLIENT)
	cQuery += " AND  AC8.AC8_ENTIDA = 'SA1' AND AC8.AC8_CODENT = '" + M->Z02_CLIENT+M->Z02_LOJA + "'"
Else
	cQuery += " AND  AC8.AC8_ENTIDA = 'SUS' AND AC8.AC8_CODENT = '" + M->Z02_PROSPE+M->Z02_LOJAPR + "'"
EndIf

cQuery += " AND SU5.U5_MSBLQL <> '2'"
cQuery += " ORDER BY U5_CONTAT"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	DbSelectarea("SU5")
	DbGoto( TMP->RECNO )
	
	Aadd(aColsSU5,Array(Len(aHeaderSU5)+1))
	For nX	:= 1 To Len(aHeaderSU5)
		IF ( aHeaderSU5[nX][10] != "V" )
			aColsSU5[Len(aColsSU5)][nX] := FieldGet(FieldPos(aHeaderSU5[nX][2]))
		Else
			aColsSU5[Len(aColsSU5)][nX] := CriaVar(aHeaderSU5[nX][2])
		EndIF
	Next nX
	aColsSU5[Len(aColsSU5)][Len(aHeaderSU5)+1] := .F.
	
	DbSelectarea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

IF Len(aColsSU5) == 0
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cria aCols auxiliares vazios.                                 �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	Aadd(aColsSU5,Array(Len(aHeaderSU5)+1))
	For nX := 1 To Len(aHeaderSU5)
		aColsSU5[Len(aColsSU5),nX] := CriaVar(aHeaderSU5[nX,2])
	Next nX
	aColsSU5[Len(aColsSU5),Len(aHeaderSU5)+1] := .F.
EndIF

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迕迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  � AtuZ08                  � Autor �     � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迍迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Atualiza Comissoes.                          			  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function AtuZ08(cVend,nLin)

Local aArea       := GetArea()
Local cFuncao     := ""
Local nParc       := 0
Local nI          := 0
Local nPVend      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_FORNEC"})
Local nPNome      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_NOME"})
Local nPComis     := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_PERC"})
Local nPFuncao    := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_FUNCAO"})
Local nPBase      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_BASE"})
Local nPQtParc    := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_QTPARC"})
Local nPValor     := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_VALOR"})
Local nPParc      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_PARC"})
Local nPVlrParc   := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_VLRPAR"})
Local nPData      := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_DATA"})
Local nPHistor 	  := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_HISTOR"})
Local nPEmissao	  := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_EMISSA"})
Local nPModalidade:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MOD"})
Local nPTotal     := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPParcelas  := aScan(aHeaderZ04,{|x| AllTrim(x[2]) == "Z04_QTDPAR"})
Local nBaseComis  := 0
Local nDesconto   := 0
Local lDentroZ08  := ( "M->Z08_" $ Alltrim(ReadVar()) )
Local xY          := 0
Local nQtdComis   := SuperGetMv("MV_QTDCOM",.F.,4) //Quantidade de parcelas de comissoes

DEFAULT cVend     := ''
DEFAULT nLin      := 1

If Type("oComis") <> "U"
	aColsZ08:= oComis:aCols
EndIf

nDesconto	:= 0
nBaseComis	:= 0
If Type("oResumo") <> "U"
	For nI:=1 To Len(oResumo:aCols)
		If !oResumo:aCols[nI,Len(oResumo:aHeader)+1]
			IF lServico // Servicos
				nBaseComis	+= oResumo:aCols[nI,nPTotal]
			Else
				nBaseComis	+= oResumo:aCols[nI,nPVlrMes]
			EndIF
		EndIf
	Next nI
END
//Abate o Desconto no Total da Proposta se houver
nBaseComis-= nDscTotal

// Se estiver dentro do aCols da Z08, sair do Loop para rodar apenas na linha correspondente
IF lDentroZ08
	nLin := oComis:nAt
EndIF
IF nBaseComis > 0
	For xY := nLin To IIF( lDentroZ08 , nLin , Len(aColsZ08) )
		//lLicenca
		aColsZ08[xY,nPEmissao]		:= dDatabase
		aColsZ08[xY,nPData]   		:= LastDay(dDataBase+30)
		aColsZ08[xY,nPComis]		:= IIF(Alltrim(ReadVar()) == "M->Z08_PERC",M->Z08_PERC,aColsZ08[xY,nPComis])
		aColsZ08[xY,nPHistor]  		:= "Comissao da Proposta " + M->Z02_PROPOS + '/' + M->Z02_ADITIV +  " - " + M->Z02_DESCRI
		
		IF lServico // Servicos
			aColsZ08[xY,nPQtParc]	:= nNumParcelas
			aColsZ08[xY,nPParc]		:= nNumParcelas
			aColsZ08[xY,nPBase] 	:= nBaseComis
		Else					// Software
			aColsZ08[xY,nPQtParc]	:= 12 	// Quando SaaS pagar comissao somente sobre o Total de 12 parcelas
			aColsZ08[xY,nPParc] 	:= IIF(lLicenca,4,nQtdComis) 	// Paga o Total da Comissao em 4 parcelas
			aColsZ08[xY,nPBase] 	:= Round(nBaseComis * aColsZ08[xY,nPQtParc],2)
			//If aColsZ08[xY,nPBase] > 0 .and. aColsZ08[xY,nPBase] <> Round(nBaseComis * aColsZ08[xY,nPQtParc],2) 
			//	aColsZ08[xY,nPBase] 	:= aColsZ08[xY,nPBase]
			//Else
			//	aColsZ08[xY,nPBase] 	:= Round(nBaseComis * aColsZ08[xY,nPQtParc],2)
			//End
			
		EndIF
		
		aColsZ08[xY,nPValor] 		:= Round(aColsZ08[xY,nPBase] * ( aColsZ08[xY,nPComis] / 100 ),2)
		aColsZ08[xY,nPVlrParc]		:= Round(aColsZ08[xY,nPValor] / aColsZ08[xY,nPParc],2)
		
		IF aColsZ08[xY,nPFuncao] == "4" // SDR
			
			aColsZ08[xY,nPComis]	:= 0
			aColsZ08[xY,nPBase]	 	:= 0
			aColsZ08[xY,nPQtParc] 	:= 0
			aColsZ08[xY,nPParc]   	:= 1
			aColsZ08[xY,nPData]   	:= LastDay(dDataBase)

			If aColsZ08[xY,nPBase] >= 100000
			
				aColsZ08[xY,nPValor] 	:= 200
				aColsZ08[xY,nPVlrParc]	:= 200
			
			ElseIf aColsZ08[xY,nPBase] >= 20000
			
				aColsZ08[xY,nPValor] 	:= 100
				aColsZ08[xY,nPVlrParc]	:= 100

			Else
			
				aColsZ08[xY,nPValor] 	:= 70
				aColsZ08[xY,nPVlrParc]	:= 70

			EndIf
		
		ElseIf (aColsZ08[xY,nPFuncao] == "3") //"Marketing"
		
			aColsZ08[xY,nPData]   := LastDay(dDataBase)
		
		EndIF

	Next
END 
//Calcula o total de comissoes

nComissoes := 0

For nI:= 1 To Len(aColsZ08)
	
	IF !(aColsZ08[nI,Len(aHeaderZ08)+1])
		
		IF lServico	// Servicos
			nComissoes += aColsZ08[nI,nPValor]
		Else					// Software
			nComissoes += aColsZ08[nI,nPValor] / aColsZ08[nI,nPParc]
		EndIF
		
	EndIf
	
Next nI

If Type("oComissoes") <> "U"
	oComis:aCols:= aColsZ08
	oComis:oBrowse:Refresh()
	oComissoes:Refresh()
EndIf

RestArea(aArea)

Return( &(ReadVar()) )

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迕迋迋迋迕迋迋迋迋迋迋迋迋敊迋迋迕迋迋迋迋迋跼�
控摺rograma  � VldZ02Tipo        � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迍迋迋迋迍迋迋迋迋迋迋迋迋玵迋迋迍迋迋迋迋迋僚�
控慣escricao � Valida o tipo de proposta selecionada                        滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function VldZ02Tipo()

//Se mudou o tipo da proposta limpa os arrays e os objetos para recria-los com nova estrutura
If Len(aColsZ05) > 0

	Aviso("Atencao","Os itens de escopo selecionados serao perdidos!",{"Ok"})

	aColsZ03   := {}
	aColsZ04   := {}
	aColsZ05   := {}
	aColsZ08   := {}
	aHeaderZ03 := {}
	aHeaderZ04 := {}
	aHeaderZ05 := {}
	aHeaderZ08 := {}
	aSaveEscopo:= {}
	M->Z02_OFERTA:= CriaVar("Z02_OFERTA")
	If Type("oEscopo") <> "U"
		oEscopo:= Nil
		oDetalhe:= Nil
		FreeObj(oEscopo)
		FreeObj(oDetalhe)
	EndIf	

	If Type("oParcelas") <> "U"
		oParcelas:= Nil
		FreeObj(oParcelas)
	EndIf

	If Type("oComis") <> "U"
		oComis:= Nil
		FreeObj(oComis)
	EndIf

	If Type("oVlrEscopo") <> "U"
		oVlrEscopo:FreeChildren()
		FreeObj(oVlrEscopo)
	EndIf

	nNumParcelas:= 0
	nTotHrsProj	:= 0
	nTotTabela	:= 0
	nCustoTotal	:= 0
	nComissoes	:= 0
	nPercDesconto:= 0
	nPercLucro	:= 0
	nSubTotal	:= 0
	nValorTotal	:= 0
	nDscTotal   := 0

EndIf

Return(M->Z02_TIPO)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � RecalcularParcelas � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao � Valida o tipo de proposta selecionada                         滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function RecalcularParcelas()

Local aColsOld	  	:= {}
Local nI, nI2, nA
Local nValorParcela	:= Round( nValorTotal / nNumParcelas , 2 )
Local nMesAtual		:= 0
Local nAno			:= 0
Local nTotal	  	:= 0
Local lPostergar 	:= .F.
Local cDiaFixo		:= '05'

IF !(INCLUI .Or. ALTERA)
	Return(.T.)
EndIF

IF lServico // Servicos

	IF nNumParcelas <> Len(aColsZ04)
		
		aColsOld	:= aClone(aColsZ04)
		aColsZ04	:=	{}
		
		For nI := 1 To nNumParcelas
			
			nTotal	 += nValorParcela
			
			Aadd(aColsZ04,Array(Len(aHeaderZ04)+1))
			For nI2 := 1 to Len(aHeaderZ04)
				aColsZ04[Len(aColsZ04),nI2] := CriaVar(aHeaderZ04[nI2,2],.T.)
			Next nI2
			
			IF nI == 1		
				
				nMesAtual 	:= Month(dDataBase+5)
				nAno		:= Year(dDataBase+5)

				aColsZ04[Len(aColsZ04),aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_DATA"})] := dDataBase + 5

			Else
			
				nMesAtual++
				IF nMesAtual > 12
					nMesAtual := 1
					nAno += 1
				EndIF
				
				dVencimento := DataValida( Ctod( cDiaFixo + '/' + StrZero(nMesAtual,2) + '/' + StrZero(nAno,4) ) , lPostergar )
				
				aColsZ04[Len(aColsZ04),aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_DATA"})] := dVencimento

			EndIF
	
			aColsZ04[Len(aColsZ04),aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_PARCEL"})] := StrZero(nI,3)
			aColsZ04[Len(aColsZ04),aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_VALOR"})]  := nValorParcela
			aColsZ04[Len(aColsZ04),Len(aHeaderZ04)+1] := .F.
			
			IF nI <= Len(aColsOld) .And. !Empty(aColsOld[nI,aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_HIST"})])
				aColsZ04[Len(aColsZ04),aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_HIST"})]	:= aColsOld[nI,aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_HIST"})]
			EndIF
			
		Next nI
	
		//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
		//� Joga as diferencas de centavos para 1a parcela.    											 �
		//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁		
		aColsZ04[1,aScan(aHeaderZ04,{|x| Alltrim(x[2]) == "Z04_VALOR"})] += (nValorTotal - nTotal)

	EndIF

EndIF

IF oParcelas != Nil
	
	oParcelas:aCols:= aColsZ04
	oParcelas:oBrowse:Refresh()
	
EndIF

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � MontaZ03           � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function MontaZ03(aColsZ03,aHeaderZ03,nOpc,cTipo,cID,cModulo,cProposta,cAditivo)

Local aArea    := GetArea()
Local nPVend   := 0
Local nPID     := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
Local nPModulo := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
Local nPHorasa := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nX       := 0
Local nHorasDia:= GetNewPar("MV_AFHRDIA",10) //Horas por Dia
Local cProdGP  := GetNewPar("MV_AFGP","SAP-I001") //Produto do Gerente de Projeto SAP
Local cProdGPFS:= GetNewPar("MV_AFGPFS","SAP-I003") //Produto do Gerente de Desenvolvimento SAP

aColsZ03  := {}
aHeaderZ03:= {}

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Monta aHeaderZ03 a partir dos campos do SX3          �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('Z03')
While !Eof() .And. (SX3->X3_ARQUIVO == 'Z03' )

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		AADD(aHeaderZ03,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

//Verifica se ja existe o escopo no array aSavcols que sera usado para gravacao
nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
If (nPos > 0) .And. (Len(aSaveEscopo[nPos,5]) > 0)
	//Se ja existir o detalhe do escopo, resgata do aSaveEscopo 
	aColsZ03:= aSaveEscopo[nPos,5]
Else

	//Se ainda nao existe no vetor a Savacols, busca da base
	IF nOpc != 3 .And. nOpc != 7 .And. !lSobrepoe
		
		cQuery := " SELECT R_E_C_N_O_ AS RECNO "
		cQuery += " FROM " + RetSqlName("Z03") + " Z03 "
		cQuery += " WHERE Z03_FILIAL 	= '" 	+ xFilial("Z03") 	+ "'"
		cQuery += " AND Z03_PROPOS 		= '" 	+ cProposta  		+ "'"
		cQuery += " AND Z03_ADITIV 		= '" 	+ cAditivo  		+ "'"
		cQuery += " AND Z03_MODULO 		= '" 	+ cModulo  			+ "'"
		cQuery += " AND Z03_ID   		= '" 	+ cID   			+ "'"
		cQuery += " AND Z03.D_E_L_E_T_ 	= ' ' "
		cQuery += " ORDER BY Z03_ID,Z03_MODULO,Z03_ORDEM,Z03_SUBMEN,Z03_NITEM"
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ03",.T.,.T.)
		
		DbSelectArea("TMPZ03")
		DbGoTop()
		While !Eof()
			
			DbSelectarea("Z03")
			DbGoto( TMPZ03->RECNO )
			
			Aadd(aColsZ03,Array(Len(aHeaderZ03)+1))
			For nX	:= 1 To Len(aHeaderZ03)
				IF ( aHeaderZ03[nX][10] != "V" )
					aColsZ03[Len(aColsZ03)][nX] := FieldGet(FieldPos(aHeaderZ03[nX][2]))
				Else
					aColsZ03[Len(aColsZ03)][nX] := CriaVar(aHeaderZ03[nX][2])
				EndIF
			Next nX
			aColsZ03[Len(aColsZ03)][Len(aHeaderZ03)+1] := .F.
			
			DbSelectarea("TMPZ03")
			DbSkip()
			
		EndDo
		TMPZ03->(DbCloseArea())
	Else
		//Se for uma oferta busca o escopo do cadastro da oferta, caso contrario busca do cadastro do modulo
		If !Empty(M->Z02_OFERTA)

			//Se for inclusao busca o escopo no cadastro de modelos de escopo de projetos		
			cQuery := " SELECT R_E_C_N_O_ AS RECNO "
			cQuery += " FROM " + RetSqlName("Z18") + " Z18 "
			cQuery += " WHERE Z18_FILIAL 	= '" 	+ xFilial("Z18") 	+ "'"
			cQuery += " AND Z18_CODESC 		= '" 	+ M->Z02_OFERTA	+ "'"
			cQuery += " AND Z18_MODULO 		= '" 	+ cModulo	+ "'"
			cQuery += " AND Z18.D_E_L_E_T_ 	= ' ' "
			cQuery += " ORDER BY Z18_ORDEM,Z18_ETAPA"
			
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ03",.T.,.T.)
			
			DbSelectArea("TMPZ03")
			DbGoTop()
			While !Eof()
				
				DbSelectarea("Z18")
				DbGoto( TMPZ03->RECNO )
				
				Aadd(aColsZ03,Array(Len(aHeaderZ03)+1))
				For nX	:= 1 To Len(aHeaderZ03)
					IF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_ID" )
						aColsZ03[Len(aColsZ03)][nX] := cID
					ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_NITEM" )
						aColsZ03[Len(aColsZ03)][nX] := StrZero(Len(aColsZ03),6)
					ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_SUBMEN" )
						aColsZ03[Len(aColsZ03)][nX] := Capital(Z18->Z18_ETAPA)
					ElseIF ( aHeaderZ03[nX][10] != "V" )
						aColsZ03[Len(aColsZ03)][nX] := Z18->(FieldGet(FieldPos("Z18"+Substring(aHeaderZ03[nX][2],4,Len(aHeaderZ03[nX][2])))))
					Else
						aColsZ03[Len(aColsZ03)][nX] := CriaVar(aHeaderZ03[nX][2])
					EndIF
				Next nX
				aColsZ03[Len(aColsZ03)][Len(aHeaderZ03)+1] := .F.
				
				DbSelectarea("TMPZ03")
				DbSkip()
				
			EndDo
			TMPZ03->(DbCloseArea())
		EndIf
	EndIF
EndIf

//Se estiver em branco atualiza com o escopo padrao
IF Len(aColsZ03) == 0
	//Se for inclusao busca o escopo no cadastro de modelos de escopo de projetos		
	Z00->(dbSetOrder(1))
	Z00->(dbSeek(xFilial("Z00")+cModulo))
	
	cQuery := " SELECT R_E_C_N_O_ AS RECNO "
	cQuery += " FROM " + RetSqlName("Z01") + " Z01 "
	cQuery += " WHERE Z01_FILIAL 	= '" 	+ xFilial("Z01") 	+ "'"
	cQuery += " AND Z01_MODULO 		= '" 	+ cModulo	+ "'"
	cQuery += " AND Z01.D_E_L_E_T_ 	= ' ' "
	cQuery += " ORDER BY Z01_ORDEM,Z01_ETAPA,Z01_PROCES"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPZ03",.T.,.T.)
	
	DbSelectArea("TMPZ03")
	DbGoTop()
	While !Eof()
		
		DbSelectarea("Z01")
		DbGoto( TMPZ03->RECNO )
		
		Aadd(aColsZ03,Array(Len(aHeaderZ03)+1))
		For nX	:= 1 To Len(aHeaderZ03)
			IF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_ID" )
				aColsZ03[Len(aColsZ03)][nX] := cID
			ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_NITEM" )
				aColsZ03[Len(aColsZ03)][nX] := StrZero(Len(aColsZ03),6)
			ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_SUBMEN" )
				aColsZ03[Len(aColsZ03)][nX] := Capital(Z01->Z01_ETAPA)
			ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_MEMO" )
				aColsZ03[Len(aColsZ03)][nX] := MSMM(Z01->Z01_CODMEM)
			ElseIF ( aHeaderZ03[nX][10] != "V" )
				aColsZ03[Len(aColsZ03)][nX] := Z01->(FieldGet(FieldPos("Z01"+Substring(aHeaderZ03[nX][2],4,Len(aHeaderZ03[nX][2])))))
			Else
				aColsZ03[Len(aColsZ03)][nX] := CriaVar(aHeaderZ03[nX][2])
			EndIF
		Next nX
		aColsZ03[Len(aColsZ03)][Len(aHeaderZ03)+1] := .F.
		
		DbSelectarea("TMPZ03")
		DbSkip()
		
	EndDo
	TMPZ03->(DbCloseArea())

	//矬闡闡闡a闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cria aCols auxiliares vazios.                                 �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	If (Len(aColsZ03) == 0)
		Aadd(aColsZ03,Array(Len(aHeaderZ03)+1))
		For nX := 1 To Len(aHeaderZ03)
			IF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_ID" )
				aColsZ03[Len(aColsZ03)][nX] := cID
			ElseIF ( Alltrim(aHeaderZ03[nX][2])  == "Z03_NITEM" )
				aColsZ03[Len(aColsZ03)][nX] := StrZero(Len(aColsZ03),6)
			Else 
				aColsZ03[Len(aColsZ03),nX] := CriaVar(aHeaderZ03[nX,2])
			EndIf	
		Next nX
		aColsZ03[Len(aColsZ03),Len(aHeaderZ03)+1] := .F.
	EndIf
EndIF

//Atualiza o objeto com o vetor do escopo
If (Len(aColsZ03) > 0) .And. (nPos > 0)
	aSaveEscopo[nPos,5]:= aColsZ03
EndIf

If Type("oDetalhe") <> "U" .and. Type('oEscopo') <> 'U'

	nPHoras		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_HORAS"})
	nPDias		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_DIAS"})
	If (AllTrim(cModulo) $ (cProdGP + "/" + cProdGPFS))
		nPos:= aScan(oEscopo:aCols,{|x| AllTrim(x[nPID]) == cID})
		If (nPos > 0)
			aColsZ03[Len(aColsZ03),nPHoras]:= oEscopo:aCols[nPos,nPHorasa]
			aColsZ03[Len(aColsZ03),nPDias] := oEscopo:aCols[nPos,nPHorasa]/nHorasDia
		EndIf
	EndIf

	oDetalhe:aHeader:= aHeaderZ03
	oDetalhe:aCols  := aColsZ03
	oDetalhe:nAT    := 1
	oDetalhe:oBrowse:Refresh()
EndIf

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � Z05Change          � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function Z05Change(aColsZ03,aHeaderZ03,nOpc,cTipo,cProposta,cAditivo)

Local lRet		:= .T.
Local nPModulo  := 0
Local nPID      := 0
Local nPTpServ  := 0
Local nPos      := 0
Local nX        := 0
Local cModulo   := ""
Local cID       := ""
Local cTpServ   := ""
Local nLinha    := 0

If ValType(oEscopo) == "U"
	Return(.T.)
EndIf

//Codigo para compatibilizar problema relacionado a adicao de linhas via F8
/*If Len(oEscopo:aCols) <= Len(aColsZ05)
	oEscopo:aCols:= aClone(aColsZ05)
else
	aColsZ05:= aClone(oEscopo:aCols)	
EndIf	
*/
If Type("N") == "N"
	nLinha:= N
Else
	nLinha:= oEscopo:nAt
EndIf

//Ajusta o posicionamento das linha da get dos modulos
If (oEscopo:nAT <> nLinha)
	oEscopo:nAT:= nLinha
	oEscopo:oBrowse:nAT:= nLinha
EndIf
oEscopo:oBrowse:Refresh()

nPModulo:= aScan(oEscopo:aHeader,{|x| Alltrim(x[2]) == "Z05_MODULO" })
nPID    := aScan(oEscopo:aHeader,{|x| Alltrim(x[2]) == "Z05_ID" })
nPTpServ:= aScan(oEscopo:aHeader,{|x| Alltrim(x[2]) == "Z05_TPSERV" })

IF (lServico .OR. lSd) .And. (nPModulo > 0) // Valida somente quando o Escopo for Servicos
	If (ReadVar() == "M->Z05_MODULO")
		cModulo:= &(ReadVar())
	Else
		//oEscopo:nAT:= N
		cModulo:= oEscopo:aCols[nLinha,nPModulo] 
	EndIf
	cID    := oEscopo:aCols[nLinha,nPID] 
	cTpServ:= oEscopo:aCols[nLinha,nPTpServ] 

	IF Empty(cModulo)
		Return(.F.)
	EndIF	

	//Verifica se os itens do modulo estao salvos
	nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
	If (nPos == 0)
		MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,cTipo,cID,cModulo,cProposta,cAditivo)
		aAdd(aSaveEscopo,{cID,cModulo,oEscopo:aCols[oEscopo:nAT],oEscopo:nAT,aColsZ03,cTpServ,.F.})
	ElseIf (nPos > 0)
		MontaZ03(@aColsZ03,@aHeaderZ03,nOpc,cTipo,cID,cModulo,cProposta,cAditivo)
		aSaveEscopo[nPos,3]:= oEscopo:aCols[oEscopo:nAT]
		aSaveEscopo[nPos,5]:= aColsZ03
		aSaveEscopo[nPos,6]:= cTpServ
	EndIf
EndIF

Return(lRet)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � Z03FieldOk         � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function Z03FieldOk(nOpc,oEscopo)

Local aArea			:= GetArea()
Local nPID	  		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
Local nPModulo  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MODULO"})
Local nPHorasa		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nPTpServ		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TPSERV"})
Local nPTotal       := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes      := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPCusto   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTO"})
Local nPCusTot 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_CUSTOT"})
Local nPPrcTab   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nPMargem		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_MARGEM"})
Local nPPerDes 		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PERDES"})
Local nPQuant		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPPrcVen		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nPTotal   	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPHorasa		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nPVlHrDe		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local nPVlHora		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nPTotCIP		:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTCIP"})
Local nPEscopo		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_ESCOPO"})
Local nPHoras		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_HORAS"})
Local nPDias		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_DIAS"})
Local nPOrdem		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_ORDEM"})
Local nPSubMen		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_SUBMEN"})
Local nPProces		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_PROCES"})
Local nPNItem		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_NITEM"})
Local nPZ03ID		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_ID"})
Local nPFase		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_FASE"})
Local nPRevisa		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_REVISA"})
Local nPDelete      := Len(aHeaderZ03)+1
Local nX            := 0
Local nTotHoras     := 0
Local nTotDias      := 0
Local cEscopo       := ""
Local nHoras        := 0
Local nDias         := 0
Local aTemp         := {}
Local cOrdem		:= ""
Local cSubMen		:= ""
Local cProces		:= ""
Local cNItem        := ""
Local cID           := ""
Local cTpServ       := ""
Local cSubMenAnt	:= ""
Local cFaseAnt      := ""
Local cIDAnt        := ""
Local cRevisaAnt    := ""
Local nHorasDia     := GetNewPar("MV_AFHRDIA",10) //Horas por Dia
Local cProdGP       := GetNewPar("MV_AFGP","SAP-I001") //Produto do Gerente de Projeto SAP
Local cProdGPFS     := GetNewPar("MV_AFGPFS","SAP-I003") //Produto do Gerente de Desenvolvimento SAP

//Nao deixa editar horas se for coordenacao
If AllTrim(oEscopo:aCols[oEscopo:nAt,nPModulo]) $ (cProdGP+"/"+cProdGPFS)
	//Return(.F.)
EndIf	

//Salva a Ordem da Linha
cNItem := oDetalhe:aCols[oDetalhe:nAT,nPNItem]
cOrdem := oDetalhe:aCols[oDetalhe:nAT,nPOrdem]
cSubMen:= oDetalhe:aCols[oDetalhe:nAT,nPSubMen]
cProces:= oDetalhe:aCols[oDetalhe:nAT,nPProces]

//Pega o Submenu anterior para preencher na linha atual
If (oDetalhe:nAT > 1) .And. Empty(cSubMen)
	cSubMen   := oDetalhe:aCols[oDetalhe:nAT-1,nPSubMen]
	cFaseAnt  := oDetalhe:aCols[oDetalhe:nAT-1,nPFase]
	cIDAnt    := oDetalhe:aCols[oDetalhe:nAT-1,nPZ03ID]
	cRevisaAnt:= oDetalhe:aCols[oDetalhe:nAT-1,nPRevisa]
	oDetalhe:aCols[oDetalhe:nAT,nPSubMen]:= cSubMen
	oDetalhe:aCols[oDetalhe:nAT,nPFase]  := cFaseAnt
	oDetalhe:aCols[oDetalhe:nAT,nPZ03ID] := cIDAnt
	oDetalhe:aCols[oDetalhe:nAT,nPRevisa]:= cRevisaAnt
EndIf

If (ReadVar() == "M->Z03_ESCOPO")
	cEscopo:= M->Z03_ESCOPO

	oDetalhe:aCols[oDetalhe:nAT,nPEscopo]:= cEscopo
ElseIf (ReadVar() == "M->Z03_SUBMEN")
	cID    := oEscopo:aCols[oEscopo:nAt,nPID]
	oDetalhe:aCols[oDetalhe:nAT,nPZ03ID] := cID

ElseIf (ReadVar() == "M->Z03_HORAS")
	nHoras := M->Z03_HORAS
	oDetalhe:aCols[oDetalhe:nAT,nPHoras] := nHoras
ElseIf (ReadVar() == "M->Z03_DIAS")
	nDias := M->Z03_DIAS
	nHoras:= Round(nDias * nHorasDia,2)

	oDetalhe:aCols[oDetalhe:nAT,nPHoras] := nHoras
	oDetalhe:aCols[oDetalhe:nAT,nPDias]  := nDias
ElseIf (ReadVar() == "M->Z03_ORDEM")
	cOrdem := &(ReadVar())

	nPos:= aScan(oDetalhe:aCols,{|x| x[nPOrdem] == M->Z03_ORDEM})
	If (nPos > 0) .And. !(oDetalhe:aCols[nPos,Len(oDetalhe:aHeader)+1])
		Aviso("Atencao","A sequencia informada j� existe.Favor informar novo codigo de sequencia.",{"OK"})
		Return(.F.)
	EndIf

	oDetalhe:aCols[oDetalhe:nAT,nPOrdem] := cOrdem
	ReadVar():= Space(2)

EndIf

For nX:= 1 To Len(oDetalhe:aCols)
	If !(oDetalhe:aCols[nX,Len(oDetalhe:aHeader)+1])

		cEscopo:= oDetalhe:aCols[nX,nPEscopo]
		nHoras := oDetalhe:aCols[nX,nPHoras]
		nDias  := oDetalhe:aCols[nX,nPDias]

		If (cEscopo $ "1")
			nTotHoras+= nHoras				//nDias * nHorasDia
			nTotDias+= Round(nHoras/nHorasDia,2) 	//nDias
		EndIf
	EndIf
Next nX

//Atualiza o grid com o Resumo dos Modulos
oEscopo:aCols[oEscopo:nAT,nPHorasa]:= nTotHoras
M->Z05_HORASA:= nTotHoras
U_VLDFIELD("M->Z05_HORASA")

//Ajusta a ordem dos campos
aTemp:= oDetalhe:aCols 
aTemp:= aSort(aTemp,,,{|x,y| IIf(x[nPDelete],'a','z')+x[nPOrdem]+x[nPSubMen]+x[nPProces] < IIf(y[nPDelete],'a','z')+y[nPOrdem]+y[nPSubMen]+y[nPProces] })

nPos:= aScan(aTemp,{|x| x[nPNItem]+x[nPOrdem]+x[nPSubMen]+x[nPProces] == cNItem+cOrdem+cSubMen+cProces})
oDetalhe:aCols:= aTemp
oDetalhe:nAT  := nPos
oDetalhe:oBrowse:nAT  := nPos
oDetalhe:oBrowse:Refresh()
M->Z03_ORDEM:= oDetalhe:aCols[nPos,nPOrdem]

//Atualiza o Acols que sera utilizado para a gravacao
cModulo:= oEscopo:aCols[oEscopo:nAT,nPModulo]
cID    := oEscopo:aCols[oEscopo:nAT,nPID]
cTpServ:= oEscopo:aCols[oEscopo:nAT,nPTpServ]

nPos:= aScan(aSaveEscopo,{|x| x[1] == cID})
If (nPos > 0)
	aSaveEscopo[nPos,3]:= oEscopo:aCols[oEscopo:nAT]
	aSaveEscopo[nPos,5]:= oDetalhe:aCols
	aSaveEscopo[nPos,6]:= cTpServ
EndIf

//Atualizacao das horas de coordenacao para os projetos de Consultoria (exceto Service Desk)
If lServico .And. (INCLUI .OR. ALTERA) .And. !(AllTrim(oEscopo:aCols[oEscopo:nAt,nPModulo]) $ (cProdGP+"/"+cProdGPFS))
	CalculaHorasCoordenacao()
EndIf

RestArea(aArea)

Return(.T.)


/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � Z03LinhaOk         � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function Z03LinhaOk(nLinha)

Local aArea			:= GetArea()
Local nPEscopo		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_ESCOPO"})
Local nPHoras		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_HORAS"})
Local nPDias		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_DIAS"})
Local nPOrdem		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_ORDEM"})
Local nPSubMen		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_SUBMEN"})
Local nPProces		:= aScan(aHeaderZ03,{|x| AllTrim(x[2]) == "Z03_PROCES"})
Local nPDelete      := Len(aHeaderZ03)+1
Local nX            := 0
DEFAULT nLinha      := oDetalhe:oBrowse:nAT

//Se a linha nao estiver deletada e pertencer ao escopo do projeto entao valida o preenchimento dos campos.
If !(oDetalhe:aCols[nLinha,Len(oDetalhe:aHeader)+1]) .And. (oDetalhe:aCols[nLinha,nPEscopo] == "1")
	IF Empty(oDetalhe:aCols[nLinha,nPProces]) .Or.;
		Empty(oDetalhe:aCols[nLinha,nPSubMen]) .Or.;
		Empty(oDetalhe:aCols[nLinha,nPOrdem])	

		Aviso("Atencao","Linha [" + cValToChar(nLinha) + "] - Preencha corretamente a Ordem, Etapa ou Processo!",{"Ok"})
		Return(.F.)
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � VLDZ03             � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

User Function VLDZ03()

Local cVar:= .T.//&(ReadVar())

nOpc:= IIF(ALTERA,4,3)

Z03FieldOK(nOpc,oEscopo)

Return(cVar)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � LOADSU5            � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

User Function LOADSU5()

Local cVar:= &(ReadVar())

MontaSU5(@aColsSU5,@aHeaderSU5,M->Z02_TIPO)
oContatos:aCols:= aColsSU5
oContatos:Refresh()

//Seta o Contato Inicial
//M->Z02_CONTAT:= Padr(Alltrim(oContatos:aCols[1,2]) + " " + Alltrim(oContatos:aCols[1,3]),TamSx3("Z02_CONTATO")[1])

Return(cVar)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � AF02IMPRIMIR       � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

Static Function AF02IMPRIMIR()

Local aArea			:= GetArea()
Local nX     		:= 0
Local nMod   		:= 0
Local nSub   		:= 0
Local aEscopo		:= {}
Local aHeadRes		:= {}
Local aColsRes		:= {}
Local aVencimento	:= {}
Local aHeadRes 		:= {} 
Local aColsRes 		:= {}	
Local nI
Local lGCV          := .F.
Local cProdGCV      := SuperGetMv("MV_PRDGCV",.F.,"TOTVS-S008") //"TOTVS-S008" - Suporte de GCV
Local cAuxTxt := ''
Local cQuery := ''
Local cContato:= ''
Local aSuporte :={}

Local lMV_XPDFPROP :=  SuperGetMv("MV_XPDFPROP",.F.,.F.)
//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//� Carrega os m鏚ulos da proposta.                     �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("Z05")
While !EOF() .And. (X3_ARQUIVO == "Z05")
		
	IF X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL
			
		Aadd(aHeadRes,{TRIM(x3titulo()),;
		SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
		SX3->X3_F3,SX3->X3_CONTEXT,	SX3->X3_CBOX,SX3->X3_RELACAO,SX3->X3_WHEN})
		
	EndIF
		
	DbSelectArea("SX3")
	DbSkip()
End
	
DbSelectArea("Z05")
DbOrderNickName("Z05SEQ")
DbSeek(xFilial("Z05")+Z02->Z02_PROPOS+Z02->Z02_ADITIV,.T.)	
While !Eof() .And. (xFilial("Z05")+Z02->Z02_PROPOS+Z02->Z02_ADITIV == Z05->(Z05_FILIAL+Z05_PROPOS+Z05_ADITIV))

	Aadd(aColsRes,Array(Len(aHeadRes)+1))
		
	For nI := 1 to Len(aHeadRes)
		If AllTrim(aHeadRes[nI,2]) == "Z05_DESCRI" .AND. Z02->Z02_TIPO $ "348"
			cAuxTxt:= Alltrim(Posicione("Z00",1,xFilial("Z00")+Z05->Z05_MODULO,"Z00_MEMO2")) 
			If Empty(cAuxTxt)
				cAuxTxt:= Alltrim( FieldGet(FieldPos(aHeadRes[nI,2])) )
			EndIf
			aColsRes[Len(aColsRes),nI] := cAuxTxt
		ElseIF (FieldPos(aHeadRes[nI,2]) > 0)
			aColsRes[Len(aColsRes),nI] := FieldGet(FieldPos(aHeadRes[nI,2]))
		ElseIf AllTrim(aHeadRes[nI,2]) == "Z05_OBSERV"
			aColsRes[Len(aColsRes),nI] := MSMM(Z05->Z05_CODOBS)
		Else	
			aColsRes[Len(aColsRes),nI] := CriaVar(aHeadRes[nI,2],.T.)
		EndIF
		
	Next nI
	aColsRes[Len(aColsRes),Len(aHeadRes)+1] := .F.
	nMod := aScan(aEscopo,{|x| x[7] == Z05->Z05_ID })
	
	aSuporte:= {}	
	If (Z05->Z05_MOD == "5")
		Aadd(aSuporte,Array(Len(aHeadRes)+1))
			
		For nI := 1 to Len(aHeadRes)
			If AllTrim(aHeadRes[nI,2]) == "Z05_DESCRI" .AND. Z02->Z02_TIPO $ "348"
				cAuxTxt:= Alltrim(Posicione("Z00",1,xFilial("Z00")+Z05->Z05_MODULO,"Z00_MEMO2")) 
				If Empty(cAuxTxt)
					cAuxTxt:= Alltrim( FieldGet(FieldPos(aHeadRes[nI,2])) )
				EndIf
				aSuporte[Len(aSuporte),nI] := cAuxTxt
			ElseIF (FieldPos(aHeadRes[nI,2]) > 0)
				aSuporte[Len(aSuporte),nI] := FieldGet(FieldPos(aHeadRes[nI,2]))
			ElseIf AllTrim(aHeadRes[nI,2]) == "Z05_OBSERV"
				aSuporte[Len(aSuporte),nI] := MSMM(Z05->Z05_CODOBS)
			Else	
				aSuporte[Len(aSuporte),nI] := CriaVar(aHeadRes[nI,2],.T.)
			EndIF
			
		Next nI
		aSuporte[Len(aSuporte),Len(aHeadRes)+1] := .F.
	EndIf
	
	cAuxTxt:= Alltrim(Posicione("Z00",1,xFilial("Z00")+Z05->Z05_MODULO,"Z00_MEMO2")) 
	IF (nMod == 0)
		Aadd( aEscopo , { 	Z05->Z05_DESCRI,;		 	 		//Nome do Modulo
							Z05->Z05_HORASA,; 					//Horas
							alltrim(cAuxTxt),;//MSMM(Z05->Z05_CODOBS),; 			//Observacao Modulo
							{ },;								//Itens
							Z05->Z05_MODULO,;					//Modulo
							Posicione("Z00",1,xFilial("Z00")+Z05->Z05_MODULO,"Z00_IMPESC"),;
							Z05->Z05_ID }) //Imprime Escopo?

	EndIF

	//Verifica se o Produto � o GCV
	If (AllTrim(Z05->Z05_MODULO) $ cProdGCV)
		lGCV:= .T.
	EndIf

	DbSelectArea("Z05")
	DbSkip()
			
EndDo

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//彪arrega os itens dos modulos.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
DbSelectArea("Z03")
DbSetOrder(1) 
DbSeek(xFilial("Z03")+Z02->Z02_PROPOS+Z02->Z02_ADITIV,.T.)	
While !Eof() .And. (xFilial("Z03")+Z02->Z02_PROPOS+Z02->Z02_ADITIV == Z03->(Z03_FILIAL+Z03_PROPOS+Z03_ADITIV))
        
	IF Z03->Z03_ESCOPO == '2'
		DbSelectArea("Z03")
		DbSkip()
		Loop
	EndIF

	nMod:= aScan(aEscopo,{|x| x[7] == Z03->Z03_ID })
		
	IF (nMod > 0)
			
		nSub:= aScan(aEscopo[nMod,4],{|x| x[1] == Z03->Z03_SUBMEN})
						
		IF (nSub == 0)
			Aadd(aEscopo[nMod,4], {	Z03->Z03_SUBMEN,; 						//Item (SubMenu)
									Z03->Z03_NIVEL,;						//Nivel
									Z03->Z03_ESCOPO,;	              		//Escopo
									{{	Z03->Z03_PROCES,;					//Atividade
										Z03->Z03_NIVEL,;					//Nivel
										Z03->Z03_ESCOPO,;       	       	//Escopo
										MSMM(Z03->Z03_CODMEM) }}}) 			//Observa誽o do Item
		Else	
			Aadd(aEscopo[nMod,4,nSub,4], {	Z03->Z03_PROCES,; 				//Atividade
											Z03->Z03_NIVEL,;				//Nivel
											Z03->Z03_ESCOPO,;             	//Escopo
											MSMM(Z03->Z03_CODMEM)})			//Observacao do Item
		EndIF
	
	EndIF

	DbSelectArea("Z03")
	DbSkip()
EndDo	
	
//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//� Carrega as parcelas.                                                  �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
DbSelectArea("Z04")
DbOrderNickName("Z04PARCEL")
DbSeek(xFilial("Z04")+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
While !Eof() .And. (xFilial("Z04")+Z02->Z02_PROPOS+Z02->Z02_ADITIV == Z04->(Z04_FILIAL+Z04_PROPOS+Z04_ADITIV))

	Aadd( aVencimento , { Z04->Z04_VALOR , Z04->Z04_DATA , Z04->Z04_HIST , Z04->Z04_MOD , Z04->Z04_QTDPAR , Z04->Z04_TOTAL, Z04->Z04_DSCPAR } )
	cPrazoMes:= Alltrim(Str(Z04->Z04_QTDPAR))+' meses' 	
	DbSelectArea("Z04")
	DbSkip()
End	

cQuery := " SELECT RTRIM(U5_CONTAT) +' '+RTRIM(U5_SOBREN) CONTATO "
cQuery += " FROM " + RetSqlName("SU5") + " SU5, "
cQuery += RetSqlName("AC8") + " AC8 "
cQuery += " WHERE SU5.U5_FILIAL = '" 	+ xFilial("SU5") 	+ "'"
cQuery += " AND SU5.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.AC8_FILIAL  = SU5.U5_FILIAL "
cQuery += " AND SU5.U5_CODCONT	= AC8.AC8_CODCON "

If !Empty(Z02->Z02_CLIENT)
	cQuery += " AND  AC8.AC8_ENTIDA = 'SA1' AND AC8.AC8_CODENT = '" + Z02->Z02_CLIENT+Z02->Z02_LOJA + "'"
Else
	cQuery += " AND  AC8.AC8_ENTIDA = 'SUS' AND AC8.AC8_CODENT = '" + Z02->Z02_PROSPE+Z02->Z02_LOJAPR + "'"
EndIf
cQuery += " AND SU5.U5_XAPROV = 'S' " 
cQuery += " AND SU5.U5_MSBLQL <> '2'" 
cQuery += " ORDER BY U5_CONTAT"
//cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

DbSelectArea("TMP")
DbGoTop()
IF TMP->(!Eof())
	cContato:= Alltrim(TMP->CONTATO)
Else	
	cContato:= Alltrim(Z02->Z02_CONTAT)
EndIf
TMP->(DbCloseArea())

If lMV_XPDFPROP
	If lAdm
		lPdf := MSGYESNO( 'Imprimir proposta em PDF ?', 'Aten誽o' )
	Else
		lPdf := .t.
	End
Else
	lPdf := .f.
End
//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
//蛀xecuta a Integracao com Word para impressao da proposta.�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
U_SyImpProposta(	Z02->Z02_PROPOS,;
					Z02->Z02_ADITIV,;
					'01',;
					Z02->Z02_DESCRI,;
					IIF(!Empty(Z02->Z02_CLIENT),"C","P"),;
					IIF(!Empty(Z02->Z02_CLIENT),Z02->(Z02_CLIENT+Z02_LOJA),Z02->(Z02_PROSPE+Z02_LOJAPR)),;
					cContato,;
					Posicione("SA3",1,xFilial("SA3")+Z02->Z02_GERENT,"A3_NOME"),;
					Posicione("SA3",1,xFilial("SA3")+Z02->Z02_VEND2,"A3_NOME"),;
					dDatabase,;
					Z02->Z02_TIPO,;
					Z02->Z02_TPFAT,;						
					Z02->Z02_TRANSL,;
					aEscopo,;
					aVencimento,;
					Z02->Z02_CONDPG,;						
					aHeadRes,;
					aColsRes,;
					Z02->Z02_IMPOST,;		
					0,;
					Z02->Z02_DESCON,;
					Z02->Z02_DSCTOT,;
					ALLTRIM(Z02->Z02_TXTTIT),;//MSMM(Z02->Z02_TITCOD),;
					ALLTRIM(Z02->Z02_TXTPRE),;//MSMM(Z02->Z02_PRECOD),;
					ALLTRIM(Z02->Z02_TXTRES),;//MSMM(Z02->Z02_RESCOD),;
					ALLTRIM(Z02->Z02_TXTOBJ),;//MSMM(Z02->Z02_OBJCOD),;
					ALLTRIM(Z02->Z02_TXTGER),;//MSMM(Z02->Z02_GERCOD),;
					Z02->Z02_TPCONT,;
					lGCV,;
					cPrazoMes,;
					{ Z02->Z02_VLVR,Z02->Z02_VLVR2,Z02->Z02_VLESTA,Z02->Z02_VLKM },;
					Z02->Z02_SOCIO1,;
					Z02->Z02_VEND2,;
					aSuporte,;
					Z02->Z02_HRPROJ,;
					Z02->Z02_EMPFAT,lPdf)

RestArea(aArea)

Return(.T.)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � AF02APROV          � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao �                                                               滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

User Function AF02Aprov()

Local aArea 		:= GetArea()
Local aAreaAtu 		:= {}
Local aTitulo		:= {}
Local aParcelas		:= {}	
Local aParcAnt      := {}
Local lRet 			:= .T.
Local cProposta		:= Z02->Z02_PROPOS
Local cAditivo		:= Z02->Z02_ADITIV
Local cTipoPro 		:= Z02->Z02_TIPO
Local cPrefixo		:= 'PRO'
Local cTipo			:= 'DP'
Local cAprovado 	:= '5'
Local cDiaFixo		:= '05'
Local cNumTit   	:= ''
Local cCNPJ			:= ''
Local cMay			:= ''
Local cMsgNF		:= ''
Local nParAtu		:= 0
Local nPar			:= 0
Local nTit          := 0
Local nPos          := 0
Local lPostergar 	:= .F.
Local nP
Local cNaturez      := ''
Local cTpSrv        := ''   
Local cCodMun       := ''

Local lModLic1     := .f.
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .F.
Private lLicenca   := .F.
Private lServico   := .F.
Private lSD        := .F.
Private lSAP       := .F.
Private lTOTVS     := .F.


#Define CRLF	Chr(13) + Chr(10)

//Alimenta as variaveis Private de lLicenca e lServico
IF (Z02->Z02_TIPO $ "348") //Licencas
	lLicenca:= .T.
	lServico:= .F.
	lSD	    := .F.
	lSAP    := .T.
	lTOTVS  := .F.
ElseIF (Z02->Z02_TIPO $ "26") //SD
	lLicenca:= .F.
	lServico:= .F.
	lSD	    := .T.
	lSAP    := IIF(Z02->Z02_TIPO == "6",.T.,.F.)
	lTOTVS  := IIF(Z02->Z02_TIPO == "2",.T.,.F.)
Else //Servicos
	lLicenca:= .F.
	lServico:= .T.
	lSD	    := .F.
	lSAP    := IIF(Z02->Z02_TIPO $ "57",.T.,.F.)
	lTOTVS  := IIF(Z02->Z02_TIPO $ "01",.T.,.F.)
EndIf		

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Gera financeiro.                                                  	   �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF !( Z02->Z02_STATUS $ '3/4' )
	MsgAlert('Processo n緌 Permitido. Mude o status da Proposta para Em Negociacao ou Forecast.')
	Return(.F.)
EndIF

If Z02->Z02_TIPO == '3' .and. EMPTY(Z02->Z02_SAPORD)	
	Z05->( DBSETORDER(1) )
	Z05->( MSSEEK(xFilial("Z05")+Z02->Z02_PROPOS+Z02->Z02_ADITIV ) )
	While Z05->(!Eof()) .And. (xFilial("Z05")+Z02->Z02_PROPOS+Z02->Z02_ADITIV == Z05->(Z05_FILIAL+Z05_PROPOS+Z05_ADITIV))

		Z00->( dbSetOrder(1))
		Z00->( MSSEEK(xFilial("Z00")+Z05->Z05_MODULO ))
				
		If Z00->Z00_MODLIC == '1'//Z05->Z05_MODLIC == '1'
			lModLic1:= .t.
			EXIT
		End
		Z05->(DbSkip())
	End

	If lModLic1 
		MsgAlert('Obrigat鏎io o preenchimento do campo "SAP Order" na aba CONTRATO. Por favor, alterar sua proposta com o numero SAP Order')
		Return(.F.)
	End
End


IF Aviso("Atencao","O sistema ir� gerar as parcelas do projeto e de comissoes. Voc� j�  conferiu se as datas e valores da proposta est緌 corretos ?",{"Sim","N漃"}) != 1
	Return(.F.)
EndIF		

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Converte prospect em cliente.                              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF Z02->Z02_CLIENT == "000080" //Se for a ALFA so altera o status e nao gera nada
	Reclock("Z02",.F.)
	Replace Z02_STATUS With "5"
	MsUnLock()
	Return
EndIf

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Converte prospect em cliente.                              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF Empty(Z02->Z02_CLIENT)
	
	IF !SyConvPro( Z02->Z02_PROSPE , Z02->Z02_LOJAPR , Z02->Z02_EMPFAT , Z02->Z02_PROPOS, Z02->Z02_ADITIV )
		RestArea(aArea)
		Return(.F.)
	EndIF

EndIF

SA1->(DbSetOrder(1))
IF SA1->( DbSeek( xFilial('SA1') + Z02->Z02_CLIENT+Z02->Z02_LOJA ) )
	
	//Pega o codigo do Municipio do Cliente
	cCodMun:= SA1->A1_COD_MUN

	IF ( dDataBase - SA1->A1_DTCAD ) > 360
		DbSelectArea('Z02')
		RecLock('Z02',.F.)
		Z02_ORIGEM := 'B' // Base
		MsUnLock()
		
	Else 
		DbSelectArea('Z02')
		RecLock('Z02',.F.)
		Z02_ORIGEM := 'N' // Novos
		MsUnLock()

	EndIF

Else
	MsgAlert('Cliente Inexiste. N緌 ser� possivel aprovar esta proposta.')
	RestArea(aArea)
	Return(.F.)
EndIF

//VALIDAO DE CLIENTE NO SERASA
If !ALLTRIM(SA1->A1_XSERASA) $ "2/3" // 1=N鬃 REALIZADA;2=REALIZADA SEM RESTRIES;3=REALIZADA COM RESTRIES
	nopc := Aviso("Atencao","Obrigat鏎io realizar a consulta no SERASA para new name. N緌 ser� possivel aprovar esta proposta."+CRLF+'Deseja anexar agora ?',{"Sim","N緌"}) 	
	If nopc == 2
		RestArea(aArea)
		MsgAlert('Consulta no SERASA n緌 realizada! N緌 ser� possivel aprovar esta proposta.')
		Return(.F.)
	Else
		lRet:= AttSerasa(SA1->A1_COD,SA1->A1_LOJA)
		If !lRet
			RestArea(aArea)
			MsgAlert('Consulta no SERASA n緌 realizada! N緌 ser� possivel aprovar esta proposta.')
			Return(.F.)		
		End		
	End
End

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Cria numero do titulo.                                     �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
cNumTit := GetSxeNum("SE1","E1_NUM")

SE1->(DbSetOrder(1))
While .T.
	IF SE1->(DbSeek(xFilial('SE1') + cPrefixo + cNumTit))
		cNumTit := GetSxeNum("SE1","E1_NUM")
		ConfirmSx8()
	Else
		Exit
	EndIF
EndDo

Begin Transaction

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Grava status e data de aprovacao da proposta.              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
RecLock('Z02',.F.)
Z02_STATUS 	:= cAprovado
Z02_DTAPRO 	:= dDataBase
Z02_ATIVO   := '1''
Z02_DTINI   := dDataBase
Z02_DTFIM   :=  dDataBase + ((VAL(Z02_DURAC)/12) * 365)

//1=TOTVS-Servicos;2=TOTVS-Service Desk;3=SAP-Cloud;4=SAP-OnPremise;5=SAP-Servicos;6=SAP-Service Desk;7=MiniProposta;8=TOTVS(Licenciamento)
IF lLicenca
	//Atualiza a data de inicio do Reajuste
	Z02_VIGENC  := IIF(Empty(M->Z02_VIGENC),dDataBase,M->Z02_VIGENC)
ENDIF
MsUnLock()

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Gera contas a receber.                                     �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF (Z02->Z02_TPFAT == "1" )
	DbSelectArea('Z04')
	DbOrderNickName("Z04PARCEL")
	DbSeek(xFilial('Z04')+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
	
	While !Eof() .And. xFilial('Z04')+Z02->Z02_PROPOS+Z02->Z02_ADITIV == Z04->Z04_FILIAL+Z04->Z04_PROPOS+Z04->Z04_ADITIV

		nQtdPar		:= IIF( Z04->Z04_MOD == '1' , 1 , Z04->Z04_QTDPAR )

		IF Z04->Z04_VALOR <= 0
		
			DbSelectArea('Z04')	            
			DbSkip()
			Loop     
		
		EndIF
		
		//Verifica se a parcela do suporte vence junto com a mensalidade ou se � cobrado em data separada
		//Se for junto ir� somar o valor do suporte na mesma parcela da mensalidade do sistema.
		//28/11/22 - Decidido que sera sempre gerado o titulo separadamente
		/*
		IF (Z04->Z04_MOD == "5")
			//Pesquisa se existe a parcela da mensalidade
			nPos:= aScan(aParcelas,{|x| x[TITMOD] == "4"})
			If (nPos > 0)
				//Se vencer na mesma data soma os valores
				If (aParcelas[nPos,TITDATA]) == Z04->Z04_DATA
					aParcelas[nPos,TITVALOR] += Z04->Z04_VALOR

					DbSelectArea('Z04')	            
					DbSkip()
					Loop     
				EndIf
			EndIf
		EndIF
		*/

		aAdd(aParcelas,{Z04->Z04_MOD,Z04->Z04_DATA,Z04->Z04_VALOR,AllTrim(Z04->Z04_HIST),nQtdPar,Z04->Z04_PARCEL})	

		DbSelectArea('Z04')	            
		DbSkip()
	END

	For nTit:= 1 To Len(aParcelas)
		
		//Verifica o tipo da Parcela (Licenca, Cloud, Servi蔞..)
		Do Case
			Case aParcelas[nTit,TITMOD] == '1'	// 1=Servicos	

				//Verifica o municipio do prospect/cliente. Se for S緌 Caetano do Sul - 48807 deve-se reter o ISS
				If (cCodMun == "48807") //S緌 Caetano do Sul
					cNaturez:= GetMV("AL_NATPRJR","010103") // Faturamento Projetos COM Retencao de ISS
				Else	
					cNaturez:= GetMV("AL_NATPRJ","010102") // Faturamento Projetos SEM Retencao de ISS
				EndIf

			Case aParcelas[nTit,TITMOD] == '2'	// 2=Licenca OnPremise
				cNaturez:= GetMV("AL_NATMRR","010101") 

			Case aParcelas[nTit,TITMOD] == '3'	// 3=Setup Cloud
				cNaturez:= GetMV("AL_NATSETU","010107") 

			Case aParcelas[nTit,TITMOD] == '4'	// 4=Licenciamento
				cNaturez:= GetMV("AL_NATMRR","010101") 

			Case aParcelas[nTit,TITMOD] == '5'	// 5=Suporte
				cNaturez:= GetMV("AL_NATAMS","010104") 
		EndCase

		nParAtu		:= 1
		nPar		:= 0
		For nPar := nParAtu To aParcelas[nTit,TITQTDPAR]

			//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
			//� Ajusta Datas de Vencimento.                                �
			//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁		
			IF aParcelas[nTit,TITMOD] == '1'	// 1=Servicos

				dVencimento := aParcelas[nTit,TITDATA]
				nPar        := Val(aParcelas[nTit,TITPARCEL])
				cTpSrv      := '3' //1.07
			
			Else 					// 2=Produtos; 3=Setup; 4=Parcelas Mensais
				
				IF nPar == 1
					
					dVencimento := aParcelas[nTit,TITDATA]
					nMesAtual 	:= Month(dVencimento)		
					nAno		:= Year(dVencimento)
				
				Else
				
					nMesAtual++
					IF nMesAtual > 12
						nMesAtual := 1
						nAno += 1
					EndIF
					
					dVencimento := DataValida( Ctod( cDiaFixo + '/' + StrZero(nMesAtual,2) + '/' + StrZero(nAno,4) ) , lPostergar )
					
				EndIF
				
				If aParcelas[nTit,TITMOD] == '4'	// =Licenca
					cTpSrv      := '4' //1.05
				Else
					cTpSrv      := '3' //1.07
				EndIf

			EndIF


			aTitulo := {}

			Aadd( aTitulo ,	{"E1_FILIAL" 	,xFilial("SE1")									,Nil})
			Aadd( aTitulo ,	{"E1_PREFIXO" 	,cPrefixo 										,Nil})
			Aadd( aTitulo ,	{"E1_NUM"	   	,cNumTit					       				,Nil})
			Aadd( aTitulo ,	{"E1_PARCELA" 	,StrZero( nPar , TamSx3("E1_PARCELA")[1] )	  	,Nil})
			Aadd( aTitulo ,	{"E1_TIPO"		,cTipo											,Nil})
			Aadd( aTitulo ,	{"E1_EMPFAT" 	,IIF(lTOTVS,'2',IIf(Z02->Z02_TIPO $ '34','1',Z02->Z02_EMPFAT)),Nil})
			Aadd( aTitulo ,	{"E1_NATUREZ" 	,cNaturez		 								,Nil})
			Aadd( aTitulo ,	{"E1_CLIENTE" 	,SA1->A1_COD 	  								,Nil})
			Aadd( aTitulo ,	{"E1_LOJA"	   	,SA1->A1_LOJA   								,Nil})
			Aadd( aTitulo ,	{"E1_EMISSAO" 	,dDataBase     									,Nil})
			Aadd( aTitulo ,	{"E1_VENCTO"	,dVencimento  									,Nil})
			Aadd( aTitulo ,	{"E1_VENCREA" 	,DataValida(dVencimento,.T.)					,Nil}) 
			Aadd( aTitulo ,	{"E1_HIST" 		,'OP: ' + Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV + ' - ' + Alltrim(Z02->Z02_DESCRI) + '-' + aParcelas[nTit,TITHIST] ,Nil})
			Aadd( aTitulo ,	{"E1_PROPOS" 	,Z02->Z02_PROPOS								,Nil})
			Aadd( aTitulo ,	{"E1_ADITIV" 	,Z02->Z02_ADITIV								,Nil})
			Aadd( aTitulo ,	{"E1_XTIPO" 	,Z02->Z02_TIPO									,Nil})
			Aadd( aTitulo ,	{"E1_VALOR"		,aParcelas[nTit,TITVALOR]						,Nil})
			Aadd( aTitulo ,	{"E1_XTPSRV"	,cTpSrv						 					,Nil})
			Aadd( aTitulo ,	{"E1_XINDICE"	,Z02->Z02_INDICE			 					,Nil})
			Aadd( aTitulo ,	{"E1_ORIGEM"	,'FINA040'					 					,Nil})
			Aadd( aTitulo ,	{"E1_VEND1"		,Z02->Z02_VEND2									,Nil})
			Aadd( aTitulo ,	{"E1_VEND2"		,Z02->Z02_VEND2								 	,Nil})
			Aadd( aTitulo ,	{"E1_VEND3"		,Z02->Z02_VEND2								 	,Nil})
			Aadd( aTitulo ,	{"E1_VEND4"		,Z02->Z02_VEND2								 	,Nil})
			Aadd( aTitulo ,	{"E1_VEND5"		,Z02->Z02_VEND2								 	,Nil})
			Aadd( aTitulo ,	{"E1_COMIS1"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS2"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS3"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS4"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS5"	,0									 			,Nil})									
			Aadd( aTitulo ,	{"E1_BASCOM1"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM2"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM3"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM4"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM5"	,0								 				,Nil})
			//E1_PORCJUR
			//cMsgNF := "Contrato: " 	+ Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV + ' - ' + Alltrim(Z02->Z02_DESCRI) + CRLF
			//cMsgNF += "Parcelas: "	+ StrZero( nPar , TamSx3("E1_PARCELA")[1] ) + '/' + StrZero( aParcelas[nTit,TITQTDPAR] , TamSx3("E1_PARCELA")[1] ) + ' - ' + aParcelas[nTit,TITHIST] + CRLF
			
			//cMsgNF += "Numero do Pedido: " + CRLF
			//cMsgNF += "Autoriza誽o Entrega (AE): " + CRLF

			cMsgNF := "Contrato: " 	+ Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV + ' - ' + Alltrim(Z02->Z02_DESCRI) + CRLF
			cMsgNF += "Parcelas: "	+ StrZero( nPar , TamSx3("E1_PARCELA")[1] ) + '/' + StrZero( aParcelas[nTit,TITQTDPAR] , TamSx3("E1_PARCELA")[1] ) + ' - ' + aParcelas[nTit,TITHIST] + CRLF

			cMsgNF:= strtran( cMsgNF , '.', ' ' )
			cMsgNF:= strtran( cMsgNF , ':', ' ' )
			cMsgNF:= strtran( cMsgNF , '/', ' ' )
			cMsgNF:= strtran( cMsgNF , '&', ' ' )
			cMsgNF:= strtran( cMsgNF , '+', ' ' )
			cMsgNF:= strtran( cMsgNF , '-', ' ' )
			
			Aadd( aTitulo ,	{"E1_MSGNF"	,cMsgNF , Nil })

			IF lTOTVS // 2=MOOVE.
			
				Aadd( aTitulo ,	{"E1_SITUACA" 	,'1'										,Nil})
				Aadd( aTitulo ,	{"E1_PORTADO" 	,'341'			   							,Nil})
				Aadd( aTitulo ,	{"E1_AGEDEP" 	,Padr( '0018' 	, TamSx3("E1_AGEDEP")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_CONTA"	   	,Padr( '51567'	, TamSx3("E1_CONTA")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_XPROD" 	,IIf(lTOTVS,'1','2')				 						,Nil})


			ElseIf (Z02->Z02_TIPO $ '34') // 1 = ALFA (24))
				
				Aadd( aTitulo ,	{"E1_SITUACA" 	,'4'				 						,Nil})
				//Aadd( aTitulo ,	{"E1_PORTADO" 	,'001'			   							,Nil})
				//Aadd( aTitulo ,	{"E1_AGEDEP" 	,Padr( '0303' 	, TamSx3("E1_AGEDEP")[1] )	,Nil})
				//Aadd( aTitulo ,	{"E1_CONTA"	   	,Padr( '76400'	, TamSx3("E1_CONTA")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_PORTADO" 	,'341'			   							,Nil})
				Aadd( aTitulo ,	{"E1_AGEDEP" 	,Padr( '0018' 	, TamSx3("E1_AGEDEP")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_CONTA"	   	,Padr( '77729'	, TamSx3("E1_CONTA")[1] )	,Nil})

			Else // 1 = ALFA - 07.640
				
				Aadd( aTitulo ,	{"E1_SITUACA" 	,'1'				 						,Nil})
				//Aadd( aTitulo ,	{"E1_PORTADO" 	,'001'			   							,Nil})
				//Aadd( aTitulo ,	{"E1_AGEDEP" 	,Padr( '0303' 	, TamSx3("E1_AGEDEP")[1] )	,Nil})
				//Aadd( aTitulo ,	{"E1_CONTA"	   	,Padr( '76400'	, TamSx3("E1_CONTA")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_PORTADO" 	,'341'			   							,Nil})
				Aadd( aTitulo ,	{"E1_AGEDEP" 	,Padr( '0018' 	, TamSx3("E1_AGEDEP")[1] )	,Nil})
				Aadd( aTitulo ,	{"E1_CONTA"	   	,Padr( '77729'	, TamSx3("E1_CONTA")[1] )	,Nil})

			EndIF
			//1=Servicos;2=Produtos;3=Setup Cloud;4=Parcelas Mensais;5=Suporte Mensal;6=Reembolso/Acordos                                     
			//Ajusta o campo do tipo da parcela no E1 para utilizacao nas corre蔞es anuais dos titulos de manuten踥es e contratos de cloud e SD
			If lServico //Servicos

				Aadd( aTitulo ,	{"E1_XTPPARC" 	,'1'			 							,Nil})

			ElseIf lSD //2- Service Desk TOTVS / 6- Service Desk SAP - Parcelas Mensais

				Aadd( aTitulo ,	{"E1_XTPPARC" 	,'5'			 							,Nil})

			Else //3- Licenca SAP Cloud / 4-Licen蓷s SAP OnPremise
				
				If (aParcelas[nTit,TITMOD] == '1') //Servicos

					Aadd( aTitulo ,	{"E1_XTPPARC" 	,'1'			 							,Nil})
					
				ElseIf (aParcelas[nTit,TITMOD] == '2') //Produtos / Licenciamento OnPremise

					Aadd( aTitulo ,	{"E1_XTPPARC" 	,'2'			 							,Nil})

				ElseIf (aParcelas[nTit,TITMOD] == '3') // Setup

					Aadd( aTitulo ,	{"E1_XTPPARC" 	,'3'			 							,Nil})
				
				ElseIf (aParcelas[nTit,TITMOD] == '4') //Parcelas Mensais

					Aadd( aTitulo ,	{"E1_XTPPARC" 	,'4'			 							,Nil})

				ElseIf (aParcelas[nTit,TITMOD] == '5') //Suporte Mensal

					Aadd( aTitulo ,	{"E1_XTPPARC" 	,'5'			 							,Nil})
				EndIf
			EndIf

			IF !EMPTY(Z02->Z02_SAPORD)
				Aadd( aTitulo ,	{"E1_XSAPORD" 	,alltrim(Z02->Z02_SAPORD) ,Nil})
			END 
			IF !EMPTY(Z02->Z02_RENOVA)
				Aadd( aTitulo ,	{"E1_XRENOVA" 	,alltrim(Z02->Z02_RENOVA ),Nil})
			END


			Aadd( aParcAnt , {aParcelas[nTit,TITVALOR] , dVencimento , cPrefixo+'-'+cNumTit+'/'+StrZero( nPar , TamSx3("E1_PARCELA")[1] ) , aParcelas[nTit,TITHIST] } )									
						
			lMsErroAuto := .F.                                                                                    	
			lMsHelpAuto := .F.
			
			aAreaAtu 	:= GetArea()	
			
			SA3->(dbSetOrder(1))
			SA3->(dbSeek(xFilial("SA3")+Z02->Z02_GERENT ))//Z02->Z02_VEND1))

			//DbSelectArea("SE1")
			SE1->( DbSetOrder(1) ) //  Prefixo 	+  Numero	+  Parcela	+  Tipo +  cliente	+  Loja
			If SE1->(MsSeek( xFilial('SE1') + cPrefixo + cNumTit + StrZero( nPar , TamSx3("E1_PARCELA")[1] ) + cTipo + SA1->A1_COD +  SA1->A1_LOJA ))
				lRet := .F.
			End

			 			
			LjMsgRun("Cliente: "+Alltrim(SA1->A1_NREDUZ)+' - Titulo+Parcela [' +cNumTit+' - '+StrZero(nPar,3)+ ' / '+StrZero(aParcelas[nTit,TITQTDPAR],3)+ '] - Proposta ['+Z02->Z02_PROPOS+'/'+Z02->Z02_ADITIV+']', 'Gerando Contas a Receber' , {|| MSExecAuto({|x,y| FINA040(x,y)},aTitulo,3) })
		
			RestArea(aAreaAtu)
		
			IF lMsErroAuto
				lRet := .F.
				MostraErro()
				IF ( __lSX8)
					RollBackSX8()
				EndIF
				DisarmTransaction()
				Break
				Exit
			Else
				lRet := .T.
				DbSelectArea('Z04')
				DbSetOrder(1)
				If DbSeek(xFilial('Z04')+Z02->Z02_PROPOS+Z02->Z02_ADITIV+aParcelas[nTit,TITPARCEL])
					RecLock('Z04',.F.)
					Z04_EMISSA 	:= dDataBase
					Z04_PREFIX	:= cPrefixo
					Z04_NUM		:= cNumTit
					Z04_TIPO	:= cTipo
					MsUnLock()
				EndIf
			EndIF
	    
	    Next nPar
		
		IF aParcelas[nTit,TITMOD] <> '1' // 2=Produtos; 3=Setup; 4=Parcelas Mensais 5=Suporte Mensal
			cNumTit := GetSxeNum("SE1","E1_NUM")

			SE1->(DbSetOrder(1))
			While .T.
				IF SE1->(DbSeek(xFilial('SE1') + cPrefixo + cNumTit))
					cNumTit := GetSxeNum("SE1","E1_NUM")
					ConfirmSx8()
				Else
					Exit
				EndIF
			EndDo
	    EndIF
	
	Next nTit

EndIf

IF !lRet
	IF ( __lSX8)
		RollBackSX8()
	EndIF
	DisarmTransaction()
	Break
EndIF

End Transaction

IF lRet
	// Realiza rateio financeiro dos t癃ulos
	LjMsgRun('Realizando Rateio de Contas a Receber...', 'Realizando Rateio de Contas a Receber' , {|| U_PMS40RAT(cProposta,cAditivo) })
	
	// Realiza a previsao de faturamento
	LjMsgRun('Gerando Previsao de Faturamento por Modalidade...', 'Gerando Previsao de Faturamento por Modalidade' , {|| U_Z02PREVFAT(cProposta,cAditivo,"I") })

	MsgAlert('Proposta Aprovada com Sucesso.')
	U_EmailIncPro('APROVA',cProposta,cAditivo)
Else
	MsgAlert('Erro na Aprova誽o desta Proposta.')	
EndIF

RestArea(aArea)

//dDatabase:= Date()

Return(lRet)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋敊迋迋迋敊迋迋迋迋迋迋迋迕迋迋迋敊迋迋迋迋芼控
控摺rograma  � AF02CANC           � Autor �                � Data � 22/02/09 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋玵迋迋迋玵迋迋迋迋迋迋迋迍迋迋迋玵迋迋迋迋芧控
控慣escricao � Cancela Aprovacoes                                            滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋芞控
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔
/*/

User Function AF02Canc()

Local aArea 		:= GetArea()
Local aTitulo		:= {}
Local lRet 			:= .T.
Local cCliente		:= Z02->Z02_CLIENT+Z02->Z02_LOJA
Local cProposta		:= Z02->Z02_PROPOS
Local cAditivo		:= Z02->Z02_ADITIV
Local cPrefixo		:= 'PRO'
Local cAprovado 	:= '5'
Local cNumTit   	:= ''
Local cCNPJ			:= ''
Local cMay			:= ''
Local dDataOld		:= dDataBase

Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

IF !alltrim(Z02->Z02_STATUS) $ '5/9' 
	MsgAlert('Processo n緌 Permitido para o estagio atual da Proposta.')
	RestArea(aArea)
	Return(.F.)
EndIF


//Valida  se existe alguma nota fiscal emitida
If HasNotaFin(Z02->Z02_CLIENT,cProposta,cAditivo)
	MsgAlert('Existe notas fiscais emitidas para esta Proposta. Verificar com Administrativo Financeiro!!!.') 
	RestArea(aArea)
	Return(.F.)
End

IF (Aviso("Atencao","Confirma Estorno da proposta ?",{"Sim","Nao"}) == 2)
	RestArea(aArea)
	Return(.F.)
EndIF



Begin Transaction

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Exclui contas a receber.                                   �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF (Z02->Z02_TPFAT == "1")

	DbSelectArea('SE1')     
	DbOrderNickName("E1PROPOS")
	DbSeek( xFilial('SE1') + cCliente+cProposta+cAditivo )
	
	While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PROPOS+E1_ADITIV) == xFilial('SE1')+cCliente+cProposta+cAditivo
			
		aTitulo := {}
		Aadd( aTitulo ,	{"E1_PREFIXO" 	,SE1->E1_PREFIXO								,Nil})
		Aadd( aTitulo ,	{"E1_NUM"	   	,SE1->E1_NUM									,Nil})
		Aadd( aTitulo ,	{"E1_PARCELA" 	,SE1->E1_PARCELA								,Nil})
		Aadd( aTitulo ,	{"E1_TIPO"		,SE1->E1_TIPO									,Nil})
		Aadd( aTitulo ,	{"E1_CLIENTE" 	,SE1->E1_CLIENTE								,Nil})
		Aadd( aTitulo ,	{"E1_LOJA"	   	,SE1->E1_LOJA									,Nil})
		Aadd( aTitulo ,	{"E1_EMISSAO" 	,SE1->E1_EMISSAO								,Nil})
		Aadd( aTitulo ,	{"E1_VENCTO"	,SE1->E1_VENCTO									,Nil})
		Aadd( aTitulo ,	{"E1_VENCREA" 	,SE1->E1_VENCREA								,Nil})
		Aadd( aTitulo ,	{"E1_VALOR"		,SE1->E1_VALOR									,Nil})
			
		lMsErroAuto := .F.
		lMsHelpAuto := .F.
		dDataBase 	:= SE1->E1_EMISSAO		
			
		LjMsgRun("Cliente: "+Alltrim(SE1->E1_NOMCLI)+' - Titulo+Parcela [' +SE1->E1_NUM+' - '+SE1->E1_PARCELA+ '] - Proposta ['+cProposta+']', 'Excluindo Contas a Receber' , {|| MSExecAuto({|x,y| FINA040(x,y)},aTitulo,5) })
			
		IF lMsErroAuto
			
			lRet := .F.
			
			MostraErro()
			
			DisarmTransaction()
			Break
			
			Exit
        Else
		
			lRet := .T.
		
		EndIF
		
		DbSelectArea('SE1')
		DbSkip()
		
		DbSelectArea('SE1')     
		DbOrderNickName("E1PROPOS")
		DbSeek( xFilial('SE1') + cCliente+cProposta+cAditivo )

	EndDo

EndIF

IF lRet
	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//� Exclui contas a receber.                                   �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	DbSelectArea("Z04")
	DbOrderNickName("Z04PARCEL")
	DbSeek(xFilial("Z04")+cProposta+cAditivo,.T.)
	While !Eof() .And. xFilial("Z04") + cProposta + cAditivo == Z04->Z04_FILIAL + Z04->Z04_PROPOS + Z04->Z04_ADITIV
	
		DbSelectArea('Z04')
		RecLock('Z04',.F.)
		Z04_EMISSA 	:= Ctod('')
		Z04_PREFIX	:= ''
		Z04_NUM		:= ''
		Z04_TIPO	:= ''
		MsUnLock()
			
		DbSkip()
			
    EndDo

	DbSelectArea('Z02')
	DbOrderNickName("Z02PROPOS")
	IF DbSeek(xFilial('Z02')+cProposta+cAditivo)
		RecLock('Z02',.F.)
		Z02_STATUS := '3' // Em Negociacao
		MsUnLock()
	EndIF

	// Realiza a previsao de faturamento
	LjMsgRun('Estornando Previsao de Faturamento por Modalidade...', 'Estornando Previsao de Faturamento por Modalidade' , {|| U_Z02PREVFAT(cProposta,cAditivo,"E") })

EndIF

End Transaction

IF lRet
	MsgAlert('Estorno efetuado com Sucesso.')
Else
	MsgAlert('Erro durante o Estorno da Aprova誽o.')
EndIF	

dDataBase := dDataOld

RestArea(aArea)

Return(lRet)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡鐃闡闡闡鐃闡闡闡闡闡闡闡闡闡闡闡薩闡闡闡闡闡闡闡闡膨�
控蚶uncao	 � SyConvPro � Autor �  Alexandro Dias      � Data 12/12/06   陰�
控藥闡闡闡闡霰闡闡闡闡闡鐘闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡謐闡闡闡闡闡闡闡闡敢�
控蛇escricao 袞bjetivos:								              	  陰�
控�          彪onverte o Prospect em um novo Cliente					  陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function SyConvPro( cProspect , cLojaProspect , cEmpFat , cProposta )

Local aStructSUS	:= SUS->( DbStruct() )
Local cTudoOK		:= 'U_SyVldSus()'
Local cCliente
Local cLoja
Local nY

DbSelectarea("SUS")
DbSetorder(1)
IF !DbSeek(xFilial("SUS")+cProspect+cLojaProspect)
	Aviso("Atencao","Este Prospect n緌 esta cadastrado.",{"OK"})
	Return(.F.)
EndIF
	
Aviso("Atencao","Antes de aprovar esta proposta ser� necess嫫io atualizar o cadastro de Prospect ok?",{"OK"})	
		
nRet := AxAltera( 'SUS', SUS->(Recno()) , 4 , /*aCposExiber*/ , /*aCposAlterar*/ , , , cTudoOK , , , , , , .F. , .T. )		

IF nRet != 1
	Aviso("Atencao","N緌 ser� possivel aprovar a proposta por que voc� n緌 atualizou o cadastro de Prospect ok?",{"OK"})
	Return(.F.)		
EndIF

DbSelectarea("SA1")
DbSetorder(3)
IF DbSeek(xFilial("SA1")+SUS->US_CGC)
	
	cCliente := SA1->A1_COD
	cLoja 	 := SA1->A1_LOJA

Else

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Converte prospect em cliente.                           �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	cCliente := GetSxeNum("SA1","A1_COD")
	cLoja 	 := '01'
	
	ConfirmSX8()
	
	DbSelectArea("SA1")

	Reclock("SA1",.T.)
	
	A1_FILIAL 	:= xFilial("SA1")
	A1_COD 		:= cCliente
	A1_LOJA		:= cLoja
	
	For nY := 1 To Len(aStructSUS)
		IF !(aStructSUS[nY,1] $ "US_FILIAL /US_COD    /US_LOJA   ")
			cCampoSA1 := 'A1' + Substr(aStructSUS[nY,1],3,10)
			cCampoSUS := 'SUS->US' + Substr(aStructSUS[nY,1],3,10)
			IF FieldPos(cCampoSA1) > 0
				FieldPut( FieldPos(cCampoSA1) , &(cCampoSUS) )
			EndIF
		EndIF
	Next

	IF 'CAETANO' $ Upper(SUS->US_MUN) 
		A1_COD_MUN	:= '48807'
		A1_NATUREZ	:= '10103'  // Calcula ISS
		A1_RECISS 	:= '1'
	Else
		A1_COD_MUN	:= SUS->US_COD_MUN
		A1_NATUREZ	:= '10101'	// Nao Calcula ISS
		A1_RECISS 	:= '2'
	EndIF 

	A1_DTCAD	:= dDataBase
	A1_PRODUTO	:= IIF( Z02->Z02_TIPO $ '1/2' , '1' , '2' ) // 1=TOTVS 2=SAP 3=Parceiros
	A1_PESSOA	:= 'J'
	A1_EMPFAT  	:= IIf(lTOTVS,'2',Z02->Z02_EMPFAT) // ALFA 07.640 (ANTIGA SYMM)
	A1_MSBLQL 	:= '2'
	A1_CONTATO	:= SUS->US_CONTAT1
	A1_EMAIL	:= SUS->US_EMAIL
	A1_NOMENFS	:= SUS->US_CONTANF
	A1_EMAILNF	:= SUS->US_EMAILNF
	A1_INSCR 	:= 'ISENTO'
	A1_KM 		:= 0.01
	A1_TRANSLA	:= Z02->Z02_TRANSL
	A1_ALMOCO	:= '2'
	A1_GERENTE	:= Z02->Z02_GERENT//Z02->Z02_VEND1
	A1_VEND		:= Z02->Z02_VEND2
	A1_HORACON	:= Z02->Z02_VLHORA
	A1_HORACOR	:= Z02->Z02_VLCOOR
	A1_IMPOSTO	:= Z02->Z02_IMPOST
	A1_ABATIMP 	:= '1'
	A1_RECCOFI 	:= 'S'
	A1_RECPIS 	:= 'S'
	A1_RECCSLL	:= 'S'
	A1_RECIRRF	:= '1'
	FkCommit()
	MsUnlock()

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	//莧tualiza o STATUS do prospect  �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡�
	DbSelectArea("SUS")
	Reclock( "SUS" ,.F.)
	Replace US_STATUS  With "6" 			// 6 - Cliente
	Replace US_CODCLI  With cCliente
	Replace US_LOJACLI With cLoja
	MsUnlock()
	
EndIF

DbSelectArea('Z02')
DbOrderNickName("Z02PROPOS")
IF DbSeek(xFilial('Z02')+cProposta)
	RecLock('Z02',.F.)
	Z02_CLIENTE	:= cCliente
	Z02_LOJA 	:= cLoja
	Z02_PROSPE	:= ''
	Z02_LOJAPR  := ''
	MsUnLock()
EndIF

Return(.T.)

User Function SyVldSus()

Local aArea := GetArea()     
Local lRet  := Obrigatorio(aGets,aTela) 

RestArea(aArea)

Return(lRet)

User Function VldStatus()

Local lRet := .F.

IF ( M->Z02_STATUS $ '5/9' )
	MsgInfo('ERRO: CAMPO STATUS' +Chr(10)+ 'Os Status [APROVADO] e [GEROU PROJETO] nao podem ser informados manualmente.')
Else
	lRet := .T.
EndIF

Return(lRet)

User Function PreecheDescri()

IF M->Z02_TIPO == '0' // TOTVS MiniProposta
	M->Z02_DESCRI := "Aprovacao de Pre-Faturamento de Atendimento Sob Demanda (TOTVS)" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.5
	M->Z02_VLVR		:= 30
	M->Z02_VLESTA	:= 30


ElseIF M->Z02_TIPO == '1' // Servicos TOTVS
	M->Z02_DESCRI 	:= "Servicos de Consultoria para Implementacao do ERP TOTVS" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.95
	M->Z02_VLVR		:= 45
	M->Z02_VLESTA	:= 45
	M->Z02_VLVR2	:= 45

ElseIF M->Z02_TIPO == '2' // Service Desk
	M->Z02_DESCRI := "Service Desk - Servicos de Suporte para Manutencao do ERP TOTVS" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.95
	M->Z02_VLVR		:= 45
	M->Z02_VLESTA	:= 45
	M->Z02_VLVR2	:= 45

ElseIF M->Z02_TIPO == '3' // Cloud
	M->Z02_DESCRI := "Assinatura Cloud - ERP SAP Business One" + Space(50)
	M->Z02_TPDESP 	:= '3'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 0
	M->Z02_VLVR		:= 0
	M->Z02_VLESTA	:= 0

ElseIF M->Z02_TIPO == '4' // OnPremise
	M->Z02_DESCRI := "Aquisicao e Manutencao - ERP SAP Business One" + Space(50)
	M->Z02_TPDESP 	:= '3'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 0
	M->Z02_VLVR		:= 0
	M->Z02_VLESTA	:= 0

ElseIF M->Z02_TIPO == '5' // Servicos SAP
	M->Z02_DESCRI := "Servicos de Consultoria para Implementacao do ERP SAP Business One" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.95
	M->Z02_VLVR		:= 45
	M->Z02_VLESTA	:= 45
	M->Z02_VLVR2	:= 45

ElseIF M->Z02_TIPO == '6' // Servicos SAP
	M->Z02_DESCRI := "Service Desk - Servicos de Suporte para Manutencao do ERP SAP Business One" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.95
	M->Z02_VLVR		:= 45
	M->Z02_VLESTA	:= 45
	M->Z02_VLVR2	:= 45

ElseIF M->Z02_TIPO == '7' // SAP MiniProposta
	M->Z02_DESCRI := "Aprovacao de Pre-Faturamento de Atendimento Sob Demanda (SAP)" + Space(50)
	M->Z02_TPDESP 	:= '2'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 1.95
	M->Z02_VLVR		:= 45
	M->Z02_VLESTA	:= 45
	M->Z02_VLVR2	:= 45

ElseIF M->Z02_TIPO == '8' // TOTVS (Licenciamentos)
	M->Z02_DESCRI := "TOTVS - Licenciamento" + Space(50)
	M->Z02_TPDESP 	:= '3'
	M->Z02_TRANSL 	:= '00:00'
	M->Z02_VLKM		:= 0
	M->Z02_VLVR		:= 0
	M->Z02_VLESTA	:= 0

EndIF

Return(.T.)


/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  莧F02CorBrw� Autor � Fabio Rogerio      � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Cores da linha do browser do escopo.						  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function AF02CorBrw(oBrw,nTipo)

Local nPos:= 0

//Verifica se o Browse ainda existe
If Type("oBrw") = "U"
	RETURN
EndIf	

nPos	:= Ascan(oBrw:aHeader,{|x| "_ESCOPO" $ x[2] })

IF (nPos > 0) .And. (oBrw:aCols[oBrw:nAt,Len(oBrw:aHeader)+1])
	//矬闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Cinza quando Deletado.  �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡�
	IF nTipo == 1 					// Cor Linha
		Return(Rgb(181,181,181))
	Else                        
		Return(Rgb(230,230,250))
	EndIF		

ElseIF oBrw:aCols[oBrw:nAt,nPos] == '1'
	//矬闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Dentro do escopo.       �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡�
	IF nTipo == 1 					// Cor Linha
		Return(Rgb(240,255,255))
	Else
		Return(Rgb(0,0,0))	
	EndIF			

ElseIF oBrw:aCols[oBrw:nAt,nPos] == '2'
	//矬闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Fora do escopo.         �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡�
	IF nTipo == 1 					// Cor Linha - Vermelho
		Return(Rgb(255,0,0))	
	Else							// Cor da Fonte - Preto
		Return(Rgb(0,0,0))	
	EndIF

ElseIF oBrw:aCols[oBrw:nAt,nPos] == '3'
	//矬闡闡闡闡闡闡闡闡闡闡闡闡�
	//� Atividade do cliente.   �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡�
	IF nTipo == 1 					// Cor Linha - Laranja
		Return(Rgb(255,140,0))	
	Else							// Cor da Fonte - Preto
		Return(Rgb(255,255,255))	
	EndIF

EndIF

Return(Rgb(255,255,255))


/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  莧tuBaseNovos� Autor � Fabio Rogerio      � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Cores da linha do browser do escopo.						  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

//Atualiza o campo se o cliente � de base ou novos
User Function AtuBaseNovos()

LjMsgRun("Aguarde. Gravando Classificacao de Clientes Base/Novos na Proposta...","Grava誽o",{|| AtuBN() })

Return


/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  莧tuBN� Autor � Fabio Rogerio           � Data �  22/02/09   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Cores da linha do browser do escopo.						  滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

Static Function AtuBN()

DbSelectArea("Z02")
DbGoTop()

While !Eof()

	If Year(Z02->Z02_DTAPRO) == Year(dDatabase)
		SA3->(DBSetOrder(1))
		SA3->(DbSeek(xFilial("SA3")+Z02->Z02_VEND2))

		SA1->(DBSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+Z02->Z02_CLIENT))

		DbSelectArea('Z02')
		RecLock('Z02',.F.)
		Z02_ORIGEM := If(Year(SA1->A1_DTCAD) < Year(Z02->Z02_DTAPRO),'B',SA3->A3_BASENEW)
		MsUnLock()
	ENDIF

	DbSkip()

EndDo

Return

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋冞迋迋迕迋迋迋迋迋跼�
控摺rograma  � VldParcelas        � Autor � Fabio Rogerio � Data � 05/18/10 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋僚�
控慣esc.     �                                                              滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

User Function VldParcelas()

Local lRet := .T.             
Local nMod 			:= aScan(oParcelas:aHeader,{|x| AllTrim(x[2]) == "Z04_MOD"})
Local nQtParcelas	:= aScan(oParcelas:aHeader,{|x| AllTrim(x[2]) == "Z04_QTDPAR"})
Local nPVlParcela	:= aScan(oParcelas:aHeader,{|x| AllTrim(x[2]) == "Z04_VALOR"})
Local nTotal		:= aScan(oParcelas:aHeader,{|x| AllTrim(x[2]) == "Z04_TOTAL"})
Local nPData		:= aScan(oParcelas:aHeader,{|x| AllTrim(x[2]) == "Z04_DATA"})
Local nParc         := 0

IF ( 'M->Z04_VALOR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '2' 	// Produtos
	
	MsgAlert('N緌 � permitido alterar o Valor dos Produtos.')
	lRet := .F.

ElseIF ( 'M->Z04_VALOR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '4' 	// Mensal
	
	MsgAlert('N緌 � permitido alterar o Valor Mensal.')
	lRet := .F.

ElseIF ( 'M->Z04_QTDPAR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '2' 		// Produtos

	oParcelas:aCols[oParcelas:nAt,nPVlParcela] := Round(oParcelas:aCols[oParcelas:nAt,nTotal] / M->Z04_QTDPAR , 2 )

ElseIF ( 'M->Z04_QTDPAR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '3' 	// Setup ou Adesao

	oParcelas:aCols[oParcelas:nAt,nPVlParcela] := Round(oParcelas:aCols[oParcelas:nAt,nTotal] / M->Z04_QTDPAR , 2 )

ElseIF ( 'M->Z04_VALOR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '3' // Setup ou Adesao

	oParcelas:aCols[oParcelas:nAt,nQtParcelas]	:= 1
	oParcelas:aCols[oParcelas:nAt,nTotal] := Round(oParcelas:aCols[oParcelas:nAt,nQtParcelas] * M->Z04_VALOR,2)

ElseIF ( 'M->Z04_QTDPAR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '4' 	// Mensal
	
	oParcelas:aCols[oParcelas:nAt,nTotal] := Round(M->Z04_QTDPAR * oParcelas:aCols[oParcelas:nAt,nPVlParcela] , 2 )

ElseIF ( 'M->Z04_QTDPAR' == ReadVar() ) .And. oParcelas:aCols[oParcelas:nAt,nMod] == '5' 	// Suporte Mensal
	
	oParcelas:aCols[oParcelas:nAt,nTotal] := Round(M->Z04_QTDPAR * oParcelas:aCols[oParcelas:nAt,nPVlParcela] , 2 )
ElseIF ( 'M->Z04_DATA' == ReadVar() ) .And. lLicenca
	If Aviso("Atencao","Deseja replicar a data para os demais tipos de parcelas?",{"Sim","Nao"}) == 1
		For nParc:= 1 To Len(oParcelas:aCols)
			oParcelas:aCols[nParc,nPData]:= M->Z04_DATA
		Next nParc
	EndIf
EndIF

Return(lRet)


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋冞迋迋迕迋迋迋迋迋跼�
控摺rograma  � VldOferta � Autor � Fabio Rogerio � Data � 05/18/10 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋僚�
控慣esc.     �  Valida o campo da oferta                                    滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

User Function VldOferta()

Local lRet := .T.             


IF !INCLUI .And. !ALTERA
	nOpc:= 2
ElseIF INCLUI .And. !ALTERA
	nOpc:= 3
ElseIF ALTERA
	nOpc:= 4
EndIF

//Verifica se na alteracao preecheu ou trocou a oferta
If (nOpc == 4)
	If (M->Z02_OFERTA <> Z02->Z02_OFERTA)
		If Aviso("Atencao","Voce alterou a OFERTA, deseja carregar o escopo da nova oferta?",{"Sim","Nao"}) == 1
			aColsZ03   := {}
			aColsZ04   := {}
			aColsZ05   := {}
			aColsZ08   := {}
			aHeaderZ03 := {}
			aHeaderZ04 := {}
			aHeaderZ05 := {}
			aHeaderZ08 := {}
			aSaveEscopo:= {}
			If Type("oEscopo") <> "U"
				oEscopo:= Nil
				FreeObj(oEscopo)
			EndIf	

			If Type("oParcelas") <> "U"
				oParcelas:= Nil
				FreeObj(oParcelas)
			EndIf

			If Type("oComis") <> "U"
				oComis:= Nil
				FreeObj(oComis)
			EndIf

			If Type("oVlrEscopo") <> "U"
				oVlrEscopo:FreeChildren()
				FreeObj(oVlrEscopo)
			EndIf

			nNumParcelas:= 0
			nTotHrsProj	:= 0
			nTotTabela	:= 0
			nCustoTotal	:= 0
			nComissoes	:= 0
			nPercDesconto:= 0
			nPercDscTotal:= 0
			nPercLucro	:= 0
			nSubTotal	:= 0
			nValorTotal	:= 0
			nDscTotal   := 0

			//Atualiza a variavel Private de controle de recarregamento do acols de Escopo
			lSobrepoe:= .T.

		Else
			lRet:= .F.
			M->Z02_OFERTA:= CriaVar("Z02_OFERTA")
		EndIf
	EndIf
EndIf	

Return(lRet)



/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋冞迋迋迕迋迋迋迋迋跼�
控摺rograma  � Z05DelOk � Autor � Fabio Rogerio � Data � 05/18/10 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋僚�
控慣esc.     �  Valida o campo da oferta                                    滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function Z05DelOk(oBrw)
Local nPDelete := Len(aHeaderZ05)+1
Local nPDelZ03 := Len(aHeaderZ03)+1
Local nSavnAT  := oBrw:oBrowse:nAT
Local nX       := 0 
Local nPos     := 0
Local nPDelSav := Len(aSaveEscopo[1])
Local nPID     := aScan(oBrw:aHeader,{|x| Alltrim(x[2]) == "Z05_ID" })

For nX:= 1 To Len(oDetalhe:aCols)
	oDetalhe:aCols[nX,nPDelZ03]:= oBrw:aCols[nSavnAT,nPDelete]
Next nX
oDetalhe:oBrowse:Refresh()

nPos:= aScan(aSaveEscopo,{|x| x[1] == oBrw:aCols[nSavnAT,nPID]})
If (nPos > 0)
	aSaveEscopo[nPos,nPDelSav]:= oBrw:aCols[nSavnAT,nPDelete]
EndIf

Return

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋冞迋迋迕迋迋迋迋迋跼�
控摺rograma  � ProximoAditivo � Autor � Fabio Rogerio � Data � 28/04/21 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋僚�
控慣esc.     �  Retorna o codigo do proximo aditivo                         滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function ProximoAditivo(cProposta)
Local cAditivo:= "00"
Local cQuery  := ""

cQuery:= " SELECT MAX(Z02_ADITIV) Z02_ADITIV "
cQuery+= " FROM " + RetSqlName("Z02") + " Z02 "
cQuery+= " WHERE Z02.D_E_L_E_T_ = '' AND Z02.Z02_PROPOS = '" + cProposta + "'"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPADT",.T.,.T.)

DbSelectArea("TMPADT")
DbGoTop()
While !Eof()
	cAditivo:= Soma1(TMPADT->Z02_ADITIV)
	Exit
End
TMPADT->(DbCloseArea())

Return(cAditivo)


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋冞迋迋迕迋迋迋迋迋跼�
控摺rograma  � SetaContato � Autor � Fabio Rogerio � Data � 22/07/21        滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋庋迋迋迍迋迋迋迋迋僚�
控慣esc.     �  Atualiza o nome do contato na proposta                      滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function SetaContato(nOpc,oProposta)

If (nOpc == 3) .Or. (nOpc == 4) .Or. (nOpc == 7)
	//M->Z02_CONTAT:= Padr(Alltrim(oContatos:aCols[oContatos:nAt,2]) + " " + Alltrim(oContatos:aCols[oContatos:nAt,3]),TamSx3("Z02_CONTATO")[1])
	oProposta:oBox:Refresh()
	oProposta:Refresh()
EndIf

Return(.T.)


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡鐃闡闡闡鐃闡闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡膨�
控蚶un�o    �  BrwCor� Autor 莧lexandro Dias     � Data � 02/03/10 陰�
控藥闡闡闡闡霰闡闡闡闡闡鐘闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡敢�
控蛇escri�o � Cor das tarefas atrasadas.                                 陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function BrwCor(nOpcao,oBrw)    
Local nScan := 0

//Verifica se o Browse ainda existe
If ValType(oBrw) == "U"
	RETURN
EndIf	

//Se estiver deletado coloca como cinza
If nOpcao == 1	// bChange
	nScan := Ascan( oBrw:aCols , { |x| x[Len(oBrw:aHeader)] == 'X' } )
	IF nScan > 0                                  
		oBrw:aCols[nScan,Len(oBrw:aHeader)] := ''
	EndIF

	oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] := 'X'
	oBrw:oBrowse:Refresh()
ElseIF nOpcao == 2	// SetBlkBackColor (Cor Fundo)
	IF oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)+1]
		Return(Rgb(181,181,181))
	ElseIf oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] == 'X'
		Return(Rgb(0,0,255))	// Fundo - Azul
    Else
		Return(Rgb(248,248,255))
	EndIF

ElseIF nOpcao == 3 // SetBlkColor (Cor Fonte)
	IF 	oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)+1] .Or. oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] == 'X'
		Return(Rgb(255,255,255))	// Fonte - Branca	
	Else 
		Return(Rgb(0,0,0)) // Fonte - Preto
	EndIF

EndIF

Return(.T.)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡鐃闡闡闡鐃闡闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡膨�
控蚶un�o    �  ResBrwCor� Autor 莧lexandro Dias     � Data � 02/03/10 陰�
控藥闡闡闡闡霰闡闡闡闡闡鐘闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡敢�
控蛇escri�o � Cor das tarefas atrasadas.                                 陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function ResBrwCor(nOpcao,oBrw)    
Local nScan := 0

//Verifica se o Browse ainda existe
If ValType(oBrw) == "U"
	RETURN
EndIf	

//Se estiver deletado coloca como cinza
If nOpcao == 1	// bChange
	nScan := Ascan( oBrw:aCols , { |x| x[Len(oBrw:aHeader)] == 'X' } )
	IF nScan > 0                                  
		oBrw:aCols[nScan,Len(oBrw:aHeader)] := ''
	EndIF

	oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] := 'X'
	oBrw:oBrowse:Refresh()
	oBrw:Refresh()
ElseIF nOpcao == 2	// SetBlkBackColor (Cor Fundo)
	IF oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)+1]
		Return(Rgb(181,181,181))
	ElseIf oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] == 'X'
		Return(Rgb(0,0,255))	// Fundo - Azul
    Else
		Return(Rgb(248,248,255))
	EndIF

ElseIF nOpcao == 3 // SetBlkColor (Cor Fonte)
	IF 	oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)+1] .Or. oBrw:aCols[oBrw:nAT,Len(oBrw:aHeader)] == 'X'
		Return(Rgb(255,255,255))	// Fonte - Branca	
	Else 
		Return(Rgb(0,0,0)) // Fonte - Preto
	EndIF

EndIF

Return(.T.)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋跼�
控摺rograma  莧F02MOD態utor  蚶abio Rogerio       � Data �  26/07/21 滷�
控昅迋迋迋迋阹迋迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋僚�
控慣esc.     袒otina para filtrar os modulos para a proposta              滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋僚�
控摻so       � AP                                                         滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

User Function AFMODULOS()
Local oModulos
Local oDescMod
Local oFornece
Local oPanel1
Local oPanel2
Local oPanel3
Local oDlg
Local oPanDlg
Local oMemo
Local oMemo2
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local oOk      := LoadBitmap( GetResources(), "LBOK" )
Local xGetDados2 := nil
Local oCombo01 := nil
Local oBrw     := Nil
Local aArea    := GetArea()
Local aModulos := {}
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aTemp    := {}
Local aCposAlt2:= {} 
Local aPrdEst2 := {}
Local aRetMd   := {}
Local aCombo   := {}
Local aRetSx3  := {}
Local aHdPrd2  := { ;    
					{ "Qtd.Minima"		  , "Z24_QTDMIN" ,PesqPict("Z24","Z24_QTDMIN")   ,						,TAMSX3("Z24_QTDMIN")[2]    ,,"AllwaysTrue()"  ,"N",,},;
					{ "Qtd.Maxima"        , "Z24_QTDMAX" ,PesqPict("Z24","Z24_QTDMAX")   ,						,TAMSX3("Z24_QTDMAX")[2]   ,,"AllwaysTrue()"  ,"N",,},;
					{ "Pre蔞 Tabela"      , "Z24_PRCTAB" ,PesqPict("Z24","Z24_PRCTAB")   ,						,TAMSX3("Z24_PRCTAB")[2] ,,"AllwaysTrue()"  ,"N",,},;
					{ "Desconto (%)"      , "Z24_DESCON" ,PesqPict("Z24","Z24_DESCON")   ,						,TAMSX3("Z24_DESCON")[2] ,,"AllwaysTrue()"  ,"N",,},;
				    { "Pre蔞 de Venda"    , "Z24_PRCVEN" ,PesqPict("Z24","Z24_PRCVEN")   ,						,TAMSX3("Z24_PRCVEN")[2] ,,"AllwaysTrue()"  ,"N",,} }
Local nModulo  := 0
Local nX       := 0
Local nY       := 0
Local nBkpnAt  := 0
local ni       := 0
Local nTemp    := 0
Local nSavnAt  := 0
Local cMemo    := CriaVar("Z00_COMPLE")
Local cMemo2   := CriaVar("Z00_COMPLE")
Local cFornece := CriaVar("A2_NREDUZ",.F.)
Local cModulo  := CriaVar("Z00_DESCRI",.F.)
Local cQuery   := ""
Local cIniCpos := ""
Local cIdAux   := ""
Local cCombo01 := ""
Local cSeq     := "000"
Local lAdc     := .F.
Static lOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

SetKey(VK_F8 ,{|| })

//cOLOCAR OS FORNECEDORES DEFAULT
If lLicenca
	cFornece:= Padr("SAP",TamSx3("A2_NREDUZ")[1])
Else
	cFornece:= Padr("ALFA",TamSx3("A2_NREDUZ")[1])
EndIf	

aRetSx3 := RetSX3Box(GetSX3Cache("Z00_TPLICE", "X3_CBOX"),,,1)
For nI:=1 To Len(aRetSx3)
	If !Empty(AllTrim(aRetSx3[nI][1]))
		aAdd(aCombo,aRetSx3[nI][1])
	EndIf
Next nI 
cCombo01:= SUBSTR(aCombo[ Len(aCombo)],1,1)

aSize    := MsAdvSize(.T.,.T.,500)
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] , 0, 0 }

aSize[3]:= aSize[3]*1.5
aSize[4]:= aSize[4]*2

aAdd( aObjects, { 100, 095, .T., .T.} )
aAdd( aObjects, { 100, 005, .T., .T.} )
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 700,1200 TITLE "Modulos" Of oMainWnd PIXEL STYLE DS_MODALFRAME 

oDlg:lEscClose := .F.
oDlg:lMaximized := .T.

oPanDlg:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPanDlg:Align:= CONTROL_ALIGN_ALLCLIENT

oFwLayer := FwLayer():New()
oFwLayer:Init(oPanDlg,.F.)

oFWLayer:addLine("LINHA1",15, .F.)
oFWLayer:addCollumn("COL1"	,100, .T. , "LINHA1")
oFWLayer:addWindow( "COL1", "WIN1", "Dados para Filtro",100, .F., .T., , "LINHA1")
oPanel1	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA1")

oFWLayer:addLine("LINHA2",60, .F.)
oFWLayer:addCollumn("COL1"	,50, .T. , "LINHA2")
oFWLayer:addCollumn("COL2"	,50, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", "",100, .F., .T., , "LINHA2")
oFWLayer:addWindow( "COL2", "WIN2", "Tabela de Preco",100, .F., .T., , "LINHA2")
oPanel2	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA2")
oPanel99:= oFWLayer:GetWinPanel("COL2", "WIN2","LINHA2")

oFWLayer:addLine("LINHA3",25, .F.)
oFWLayer:addCollumn("COL1"	,50, .T. , "LINHA3")
oFWLayer:addCollumn("COL2"	,50, .T. , "LINHA3")
oFWLayer:addWindow( "COL1", "WIN1", "Premissa",100, .F., .T., , "LINHA3")//oFWLayer:addWindow( "COL1", "WIN1", "Observacoes do Modulo",100, .F., .T., , "LINHA3")
oFWLayer:addWindow( "COL2", "WIN1", "Descricao detalhada",100, .F., .T., , "LINHA3")
oPanel3	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA3")
oPanel98:= oFWLayer:GetWinPanel("COL2", "WIN1","LINHA3")

@ 001,001 GET oMemo VAR cMemo MEMO SIZE 200,145 OF oPanel3 PIXEL
oMemo:Align := CONTROL_ALIGN_ALLCLIENT

@ 001,001 GET oMemo2 VAR cMemo2 MEMO SIZE 200,145 OF oPanel98 PIXEL
oMemo2:Align := CONTROL_ALIGN_ALLCLIENT

@ 001,005 SAY "Fornecedor"							OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK 	
@ 010,005 MSGET oFornece VAR cFornece Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14 ON CHANGE FilModulo(lLicenca,cFornece,cModulo,@aModulos,@oModulos,aPrdEst2,@aRetMd,cCombo01)

@ 001,110 SAY "Modulo"								OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK
@ 010,110 MSGET oDescMod VAR cModulo  Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14  ON CHANGE FilModulo(lLicenca,cFornece,cModulo,@aModulos,@oModulos,aPrdEst2,@aRetMd,cCombo01)

@ 001,220 SAY "Tipo Licenciamento"								OF oPanel1 PIXEL SIZE 150,11 FONT oFntSay COLOR CLR_BLACK
oCombo01 := TComboBox():New(010, 220, {|u|if(PCount()>0,cCombo01:=u,cCombo01)}, aCombo, 100, 020, oPanel1,,{|| .t. },,,,.T.,,,,,,,,,cCombo01)

Aadd(aModulos,{.F.,"","",0,0,0,"","","",""})
oModulos:= TwBrowse():New(0,0,0,0,,{" ",Padr("Fornecedor",20),Padr("Modulo",120),"Preco Venda","Custo","Horas Modulo","Limite Minimo","Limite Maximo","Cod.Modulo","Sequencia"},,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oModulos:SetArray(aModulos)
oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,MOD_FLAG],oOk,oNo),;
				 		aModulos[oModulos:nAt,MOD_FORNEC],;
				 		aModulos[oModulos:nAt,MOD_DESCRI],;
				 		Transform(aModulos[oModulos:nAt,MOD_PRCVEN],PesqPict("Z00","Z00_PRCVEN")),;
				 		Transform(aModulos[oModulos:nAt,MOD_CUSTO],PesqPict("Z00","Z00_CUSTO")),;
				 		Transform(aModulos[oModulos:nAt,MOD_HORAS],PesqPict("Z00","Z00_HORAS")),;
				 		aModulos[oModulos:nAt,MOD_LIMMIN],;
						aModulos[oModulos:nAt,MOD_LIMMAX],;
						aModulos[oModulos:nAt,MOD_MODULO],;
						aModulos[oModulos:nAt,MOD_SEQ]}}
oModulos:BlDblClick	 := {|| AtuMarca(@oModulos,@aModulos,@aRetMd)}						
oModulos:bHeaderClick:= { |oObj,nCol| SyOrdena(nCol,@oModulos,@aModulos,@lOrdemCols) }
oModulos:bChange	 := {|| (nModulo:= oModulos:nAt, AtuObs(oModulos,@cMemo,@oMemo,@cMemo2,@oMemo2), AtuTabPrc( aModulos[oModulos:nAt,MOD_MODULO] ,@xGetDados2,@aPrdEst2) ) }
oModulos:Refresh()
oModulos:Align:= CONTROL_ALIGN_ALLCLIENT

xGetDados2:= MsNewGetDados():New(0,0,0,0, 0,"Allwaystrue","Allwaystrue"	,cIniCpos,aCposAlt2,000,9999,"Allwaystrue","Allwaystrue","Allwaystrue",oPanel99,@aHdPrd2,@aPrdEst2,)
xGetDados2:oBrowse:Refresh()
xGetDados2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 		
xGetDados2:Refresh()

DEFINE SBUTTON oBtnOk FROM 001,550 TYPE 1 ENABLE OF oPanel1;
       ACTION (nModulo := oModulos:nAt, oDlg:End())

DEFINE SBUTTON oBtnCancel FROM 016,550 TYPE 2 ENABLE OF oPanel1;
       ACTION  (nModulo := 0,oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oFornece:SetFocus(), Eval(oFornece:bChange))

If nModulo > 0
	//Atualiza o Vetor com os Retornos
	For nX:= 1 To Len(aModulos)	
		If aModulos[nX][MOD_FLAG] .and. AScan(aRetMd, aModulos[nX,MOD_MODULO] ) == 0
			aadd(aRetMd	, aModulos[nX,MOD_MODULO] )
			Z00->(dbSetOrder(1))
			Z00->(dbSeek(xFilial("Z00")+ aModulos[nX,MOD_MODULO] ))	
			If !empty(Z00->Z00_MODASS)
				aadd(aRetMd	, Z00->Z00_MODASS )
			End			
		EndIf	
	Next nX

	aHeader:= aClone(aHeaderZ05)
	If lLicenca
		aTemp:= aClone(oResumo:aCols)
		nSavnAt := oResumo:nAt
		oBrw:= oResumo
	Else
		aTemp:= aClone(oEscopo:aCols)
		nSavnAt := oEscopo:nAt
		oBrw:= oEscopo
	EndIf

	nPModulo:= aScan(aHeaderZ05,{|x| Alltrim(x[2]) == "Z05_MODULO" })
	nPID  	:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_ID"})
	nPDescri:= aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_DESCRI"})
	nPSeq   := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_SEQ"})
	nPDelete:= Len(aHeaderZ05)+1

	//Pega a ultima sequencia
	aTemp := aSort(aTemp,,,{|x,y| IIf(x[nPDelete],'a','z')+x[nPSeq] < IIf(y[nPDelete],'a','z')+y[nPSeq] })
	cSeq:= aTemp[Len(aTemp),nPSeq]

	//Pega o ultimo ID unico
	aTemp := aSort(aTemp,,,{|x,y| x[nPID] < y[nPID] })
	cMaxID:= aTemp[Len(aTemp),nPID]

	//Verifica quais foram os itens marcados
	For nX:= 1 To Len(aRetMd)
		nTemp:= aScan( oBrw:aCols,{ |x| Alltrim(x[nPModulo]) == Alltrim( aRetMd[nX] )  })
		//Se nao existir o modulo ou se a linha estiver deletada adiciona novamente
		If (nTemp == 0) .Or. (oBrw:aCols[nTemp,nPDelete])
			Z00->(dbSetOrder(1))
			Z00->(dbSeek(xFilial("Z00")+aRetMd[nX]))	

			//Verifica se existe alguma linha em branco.
			nTemp:= aScan( oBrw:aCols,{ |x| Empty(x[nPModulo])  })
			If (nTemp == 0)
				Eval(oBrw:oBrowse:bAdd)
				nTemp:= Len(oBrw:aCols)
				cMaxID:= Soma1(cMaxID)
			EndIf	
			cSeq  := Soma1(cSeq)
		
			For ny := 1 to Len(aHeaderZ05)
				If (AllTrim(aHeaderZ05[ny][2]) <> "XXX")
					oBrw:aCols[nTemp,ny] := CriaVar(aHeaderZ05[ny][2])
				EndIf	
			Next ny	
		EndIf
		
		oBrw:aCols[nTemp,nPSeq]    := cSeq
		oBrw:aCols[nTemp,nPId]     := cMaxID		
		oBrw:aCols[nTemp,nPModulo] := Z00->Z00_MODULO
		oBrw:aCols[nTemp,nPDescri] := Z00->Z00_DESCRI
		oBrw:aCols[nTemp,Len(aHeaderZ05)+1] := .F.		

		N:= nTemp
		oBrw:nAt  := nTemp
		oBrw:oBrowse:nAt  := nTemp
		
		__ReadVar := "M->Z05_MODULO"
		M->Z05_MODULO:= Z00->Z00_MODULO
		Eval(oBrw:bChange)


	Next nX

	//Atualizacao das horas de coordenacao para os projetos de Consultoria (exceto Service Desk)
	If  (INCLUI .OR. ALTERA)
		If lServico
			CalculaHorasCoordenacao()
		EndIf

		__ReadVar := "M->Z05_SEQ"
		M->Z05_SEQ:= oBrw:aCols[oBrw:nAt,nPSeq]
		Eval(oBrw:bChange)
		Eval(oBrw:oBrowse:bAdd)
	ENDIF
EndIf
RestArea(aArea)

SetKey(VK_F8 ,{||  U_AFMODULOS()    })

Return(.T.)

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  FilModulo   態utor  蚶abio Rogerio       � Data �  02/05/08   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣esc.     袒otina para filtrar os modulos                              滷�
控�          �                                                            滷�
控昅迋迋迋迋阹迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋僚�
控摻so       � AP                                                         滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function FilModulo(lLicenca,cFornece,cModulo,aModulos,oModulos,aPrdEst2,aRetMd,cCombo01)
Local cQuery  := ""
Local oNo     := LoadBitmap( GetResources(), "LBNO" )
Local oOk     := LoadBitmap( GetResources(), "LBOK" )
Local nX:= 0
Local lMark := .f.

For nX:= 1 To Len(aModulos)	
	If aModulos[nX][MOD_FLAG] .and. AScan(aRetMd, aModulos[nX,MOD_MODULO] ) == 0
		aadd(aRetMd	, aModulos[nX,MOD_MODULO] )
	EndIf	
Next nX

aModulos:= {}

cQuery+= " SELECT DISTINCT A2_NREDUZ,Z00_DESCRI,Z00_PRCVEN,Z00_CUSTO,Z00_HORAS,Z00_LIMMIN,Z00_LIMMAX,Z00_MODULO,Z00_SEQ "
cQuery+= " FROM " + RetSqlName("Z00") + " Z00 "
cQuery+= " INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND SA2.A2_COD = Z00.Z00_FORNEC "
cQuery+= " WHERE Z00.D_E_L_E_T_ = '' "
cQuery+= " AND Z00.Z00_LIBERA = '1' "
If cCombo01 <> '3'
	cQuery+= " AND Z00_TPLICE = '"+cCombo01+"' "
EndIf
If lLicenca
	cQuery+= " AND Z00.Z00_TPMOD IN ('1','3') "

	If (M->Z02_TIPO == "3")
		cQuery+= " AND Z00.Z00_TPPROD IN ('0','1','3') "
	ElseIf (M->Z02_TIPO == "4")
		cQuery+= " AND Z00.Z00_TPPROD IN ('2','3') "
	EndIf	
Else
	If !Empty(M->Z02_OFERTA)
		cQuery+= " AND Z00.Z00_TPMOD = '2' "
	Else
		cQuery+= " AND Z00.Z00_TPMOD = '1' "
	EndIf	

	//Service Desk SAP
	If lSD .And. lSAP
		cQuery+= " AND Z00.Z00_TIPO IN ('6')"
	//Service Desk TOTVS
	ElseIf lSD .And. lTOTVS
		cQuery+= " AND Z00.Z00_TIPO IN ('2')"
	//Servicos SAP
	ElseIf lSAP
		cQuery+= " AND Z00.Z00_TIPO IN ('5','7')"
	//Servicos TOTVS
	Else
		cQuery+= " AND Z00.Z00_TIPO = '" + M->Z02_TIPO + "'"
	EndIf	
EndIf

If !Empty(cFornece)
	cQuery+= " AND SA2.A2_NREDUZ LIKE '%" + AllTrim(cFornece) + "%' "
EndIf

If !Empty(cModulo)
	cQuery+= " AND Z00.Z00_DESCRI LIKE '%" + AllTrim(cModulo) + "%' "
EndIf

cQuery+= " ORDER BY SA2.A2_NREDUZ, Z00.Z00_SEQ, Z00.Z00_DESCRI "
cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ00",.T.,.T.)
dbSelectArea("TMPZ00")
dbGoTop()
  
While !Eof()
	lMark :=  aScan( aRetMd , TMPZ00->Z00_MODULO) > 0
	
	aAdd(aModulos,{ lMark ,TMPZ00->A2_NREDUZ,TMPZ00->Z00_DESCRI,TMPZ00->Z00_PRCVEN,TMPZ00->Z00_CUSTO,TMPZ00->Z00_HORAS,TMPZ00->Z00_LIMMIN,TMPZ00->Z00_LIMMAX,TMPZ00->Z00_MODULO,TMPZ00->Z00_SEQ})
	
	dbSelectArea("TMPZ00")
	dbSkip()
End
TMPZ00->(dbCloseArea())
    
If (Len(aModulos) == 0)
	aAdd(aModulos,{.F.,CriaVar("A2_NREDUZ",.F.),CriaVar("Z00_DESCRI",.F.),0,0,0,"","","",""})	
EndIf

AtuTabPrc( aModulos[1,MOD_MODULO] ,,@aPrdEst2)	

oModulos:SetArray(aModulos)
oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,MOD_FLAG],oOk,oNo),;
				 		aModulos[oModulos:nAt,MOD_FORNEC],;
				 		aModulos[oModulos:nAt,MOD_DESCRI],;
				 		Transform(aModulos[oModulos:nAt,MOD_PRCVEN],PesqPict("Z00","Z00_PRCVEN")),;
				 		Transform(aModulos[oModulos:nAt,MOD_CUSTO],PesqPict("Z00","Z00_CUSTO")),;
				 		Transform(aModulos[oModulos:nAt,MOD_HORAS],PesqPict("Z00","Z00_HORAS")),;
				 		aModulos[oModulos:nAt,MOD_LIMMIN],;
						aModulos[oModulos:nAt,MOD_LIMMAX],;
						aModulos[oModulos:nAt,MOD_MODULO],;
						aModulos[oModulos:nAt,MOD_SEQ]}}
oModulos:Refresh()

Return(aModulos)


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡薩闡闡闡薩闡闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡膨�
控蚶un�o    � SyOrdena � Autor �    			        � Data � 24/05/12 陰�
控藥闡闡闡闡霰闡闡闡闡闡謐闡闡闡謐闡闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡敢�
控蛇escri�o � Ordena ao clicar na coluna da GetDados.                    陰�
控藥闡闡闡闡霰闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡敢�
控� Uso      � SYPMSC100                                                  陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function SyOrdena(nCol,oModulos,aModulos,lOrdemCols)

Local nPos := nCol

IF !lJaExecutou
	
	lJaExecutou := .T.
	lOrdemCols := !lOrdemCols
	
	IF lOrdemCols 
    	aSort( oModulos:aArray ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
    	aSort( oModulos:aArray ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF
	
	aModulos := oModulos:aArray
	oModulos:nAt := 1
	oModulos:Refresh()
	oModulos:SetFocus()

Else

	lJaExecutou := .F.

EndIf


Return


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡薩闡闡闡薩闡闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡膨�
控蚶un�o    � AtuObs � Autor �    			            � Data � 27/07/21 陰�
控藥闡闡闡闡霰闡闡闡闡闡謐闡闡闡謐闡闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡敢�
控蛇escri�o � Atualiza a Observacao do Modulo                            陰�
控藥闡闡闡闡霰闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡敢�
控� Uso      �                                                  陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function AtuObs(oModulos,cMemo,oMemo,cMemo2,oMemo2)

Z00->(dbSetOrder(1))
Z00->(dbSeek(xFilial("Z00")+oModulos:aArray[oModulos:nAt,MOD_MODULO]))

cMemo:= Alltrim(Z00->Z00_MEMO0)//Alltrim(MSMM(Z00->Z00_CODM1 ))//Z00->Z00_MEMO1//Z00->Z00_COMPLE
oMemo:Refresh()

cMemo2:= Alltrim(Z00->Z00_MEMO2 )//Z00->Z00_MEMO1//Z00->Z00_COMPLE
oMemo2:Refresh()

Return


/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡薩闡闡闡薩闡闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡膨�
控蚶un�o    � AtuMarca � Autor �    			            � Data � 27/07/21 陰�
控藥闡闡闡闡霰闡闡闡闡闡謐闡闡闡謐闡闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡敢�
控蛇escri�o � Atualiza a Marca do Item Selecionado                            陰�
控藥闡闡闡闡霰闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡敢�
控� Uso      �                                                  陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/

Static Function AtuMarca(oModulos,aModulos,aRetMd)
Local nX  := 0
Local nPos:= oModulos:nAt
Local nScan :=  AScan(aRetMd, oModulos:aArray[nPos,MOD_MODULO] )

oModulos:aArray[nPos,MOD_FLAG]:= !oModulos:aArray[nPos,MOD_FLAG]

If !oModulos:aArray[nPos,MOD_FLAG] .and. nScan > 0	
	aDel(aRetMd,nScan)
	aSize(aRetMd,len(aRetMd)-1)	
EndIf	

aModulos:= oModulos:aArray
oModulos:Refresh()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTabPrc

Tabela de preco

@author Pedro Oliveira
@since 28/12/2021
@version P11
/*/ 
//-------------------------------------------------------------------
Static Function  AtuTabPrc( cModulo ,xGetDados2,aPrdEst2)

aPrdEst2:= {}

Z24->( DbSetOrder(1) )
If Z24->( DbSeek( xFilial('Z24')+cModulo )  )
	While Z24->( !Eof() ) .and. Z24->(Z24_FILIAL+Z24_MODULO) == xFilial('Z24')+cModulo
		AADD(aPrdEst2,{ Z24->Z24_QTDMIN,;
						Z24->Z24_QTDMAX,;
						Z24->Z24_PRCTAB,;
						Z24->Z24_DESCON,;
						Z24->Z24_PRCVEN,.F.})
		Z24->( DbSkip() )
	EndDo 
Else
	AADD(aPrdEst2,{0,0,0,0,0,.F.})
EndIf

If VALTYPE(xGetDados2) == 'O'
	xGetDados2:aCols:= aPrdEst2
	xGetDados2:Refresh()
EndIf

Return

Static Function GetTabPrc( cModulo,nQuant)

Local nRet:= 0
Local cQuery:= ""
Local cTmp:= GetNextAlias()
cQuery+=" SELECT R_E_C_N_O_ RECZ24 FROM "+RetSqlName('Z24')+" " +CRLF
cQuery+=" WHERE "+CRLF
cQuery+=" Z24_FILIAL='"+xFilial("Z24")+"' "+CRLF
cQuery+=" AND Z24_MODULO = '"+cModulo+"' "+CRLF
cQuery+=" AND "+ALLTRIM(STR(nQuant)) +" BETWEEN Z24_QTDMIN AND Z24_QTDMAX"+CRLF
cQuery+=" AND D_E_L_E_T_ = '' "+CRLF

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
If (cTmp)->(!Eof())
	nRet:= (cTmp)->RECZ24
EndIf

(cTmp)->(DbCloseArea())

Return nRet

/*
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控矬闡闡闡闡鐃闡闡闡闡闡薩闡闡闡薩闡闡闡闡闡闡闡闡闡闡薩闡闡鐃闡闡闡闡闡闡膨�
控袈rograma  � EnterCpo � Autor � Alexandro Dias-SYMM � Data � 03/01/2006 陰�
控藥闡闡闡闡霰闡闡闡闡闡謐闡闡闡謐闡闡闡闡闡闡闡闡闡闡謐闡闡鐘闡闡闡闡闡闡敢�
控蛇escricao � Dispara validacoes e gatilhos do campo.                    陰�
控斂闡闡闡闡鐘闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡棱�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
*/
Static Function EnterCpo(cCampo,ValorDoCampo,n)

	Local aArea	   := GetArea()
	Local cVarAtu  := ReadVar()
	Local lRet     := .T.
	Local cPrefixo := "M->"
	Local bValid

	//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
	//� A variavel __ReadVar e padrao do sistema, ela identifica o campo atualmente posicionado. �
	//� Mude o conteudo desta variavel para disparar as validacoes e gatilhos do novo campo.     �
	//� Nao esquecer de voltar o conteudo original no final desta funcao.                        �
	//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
	__ReadVar := cPrefixo+cCampo
	
	// --> Valoriza o campo atual "Simulado".
	&(cPrefixo+cCampo) := ValorDoCampo
	
	// --> Carrega validacoes do campo.
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek(cCampo) )
	cValid := Iif(!Empty(SX3->X3_VALID),Rtrim(SX3->X3_VALID)+Iif(!Empty(SX3->X3_VLDUSER),".And.",""),"")+Rtrim(SX3->X3_VLDUSER)

	bValid := "{|| "+IIf(!Empty(cValid),cValid,".T.")+" }"
	
	// --> Executa validacoes do campo.
	lRet := Eval( &(bValid) )
	
	If lRet
		// --> Executa gatilhos do campo.
		SX3->(dbSetOrder(2))
		SX3->(dbSeek(cCampo))
		If ExistTrigger(cCampo)
			RunTrigger(2,n)
		EndIf
	EndIf
	
	// --> Retorna __ReadVar com o valor original.
	__ReadVar := cVarAtu
	
	RestArea(aArea)

Return(lRet)



/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  蚶inalizaContrato� Autor � Fabio Rogerio� Data �  28/11/22   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Finaliza o Contrato e Deleta os Titulos em Aberto          滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function FinalizaContrato(cCliente,cLoja,cProposta,cAditivo,cTipo)
Local aArea 		:= GetArea()
Local lRet 			:= .T.
Local dDataOld		:= dDataBase

DEFAULT cCliente	:= Z02->Z02_CLIENT+Z02->Z02_LOJA
DEFAULT cProposta	:= Z02->Z02_PROPOS
DEFAULT cAditivo	:= Z02->Z02_ADITIV


Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

IF !Z02->Z02_STATUS $ ('59')
	MsgAlert('Processo n緌 Permitido para o estagio atual da Proposta.')
	RestArea(aArea)
	Return(.F.)
EndIF

If HasNotaFin( cCliente,cProposta,cAditivo )
	Aviso("Atencao","O contrato nao podera ser cancelado pois existem titulos em aberto.",{"Ok"})
	Return .F.
EndIf

Begin Transaction

dDatabase:= dDataOld
IF lRet
	DbSelectArea('Z02')
	DbOrderNickName("Z02PROPOS")
	IF DbSeek(xFilial('Z02')+cProposta+cAditivo)
		RecLock('Z02',.F.)
		Z02_STATUS := cTipo // Cancelado ou Encerrado
		
		If (cTipo == "C")
			Z02_DTCANC:= dDatabase
		ElseIf (cTipo == "E")
			Z02_DTENCE:= dDatabase
		EndIf

		Z02_VLRSAS:= Z02->Z02_MENSAS * Round((dDatabase-Z02->Z02_DTAPRO)/30,0) 

		MsUnLock()
	EndIF

EndIF

End Transaction

IF lRet
	MsgAlert(IIF(cTipo == "C",'Cancelamento','Encerramento') + ' efetuado com Sucesso.')
Else
	MsgAlert(IIF(cTipo == "C",'Cancelamento','Encerramento') + ' n緌 realizado.')
EndIF	

dDataBase := dDataOld

RestArea(aArea)

Return(lRet)

/*/
嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈嗈�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
控奼迋迋迋迋迕迋迋迋迋迋冞迋迋迋敊迋迋迋迋迋迋迋迋迋豖迋迋迋敊迋迋迋迋迋迋跼�
控摺rograma  蛄era Previsao� Autor � Fabio Rogerio� Data �  12/10/23   滷�
控昅迋迋迋迋阹迋迋迋迋迋庋迋迋迋玵迋迋迋迋迋迋迋迋迋虮迋迋迋玵迋迋迋迋迋迋僚�
控慣escricao � Gera a Previsao de Faturamento          滷�
控迋迋迋迋迍迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋迋摹�
控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控控�
葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔葔�
/*/

User Function Z02PREVFAT(cProposta,cAditivo,cTipo)



DEFAULT cTipo:= "I"

If (cTipo == "E")
	dbSelectArea("Z28")
	dbSetOrder(1)
	dbSeek(xFilial("Z28")+cProposta+cAditivo,.T.)
	While !Eof() .And. (Z28->Z28_FILIAL = xFilial("Z28")) .And. (Z28->Z28_PROPOS == cProposta) .And. (Z28->Z28_ADITIV == cAditivo)
		RecLock("Z28",.F.,.T.)
		DbDelete()
		MsUnLock()

		dbSkip()
	End

ElseIf (cTipo == "I")

	dbSelectArea("Z04")
	dbSetOrder(1)
	dbSeek(xFilial("Z04")+cProposta+cAditivo,.T.)
	While !Eof() .And. (Z04->Z04_FILIAL == xFilial("Z04")) .And. (Z04->Z04_PROPOS == cProposta) .And. (Z04->Z04_ADITIV == cAditivo)
		If (Z04->Z04_MOD == "1") //Servi蔞s
			cPrefixo := Z04->Z04_PREFIX
			cNum     := Z04->Z04_NUM
			cTipo    := Z04->Z04_TIPO
			cParcela := Z04->Z04_PARCEL

			dbSelectArea("SE1")
			dbSetOrder(1)
			dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela,.T.)
			While !Eof() .And. (SE1->E1_FILIAL == xFilial("SE1")) .And. (SE1->E1_PREFIXO == cPrefixo) .And. (SE1->E1_NUM = cNum) .And. (SE1->E1_PARCELA = cParcela)
				If (SE1->E1_TIPO == cTipo)
					RecLock("Z28",.T.)
					Replace Z28_FILIAL With xFilial("Z28")
					Replace Z28_PROPOS With Z04->Z04_PROPOS
					Replace Z28_ADITIV With Z04->Z04_ADITIV
					Replace Z28_CLIENT With Z02->Z02_CLIENT
					Replace Z28_LOJA   With Z02->Z02_LOJA
					Replace Z28_MODULO With Z05->Z05_MODULO
					Replace Z28_MODLIC With Z05->Z05_MODLIC
					Replace Z28_DTPRV  With SE1->E1_VENCREA
					Replace Z28_TITULO With SE1->E1_NUM
					Replace Z28_PARCEL With SE1->E1_PARCELA
					Replace Z28_QUANT  With 0
					Replace Z28_HORASA With Z02->Z02_HRPROJ
					Replace Z28_PRCVEN With Z02->Z02_VLHORA
					Replace Z28_TOTAL  With ROUND(SE1->E1_VALOR * Z02->Z02_IMPOST,2)
					Replace Z28_TOTCIP With SE1->E1_VALOR
					Replace Z28_ITEM   With ""
					Replace Z28_PAGO   With IIF(SE1->E1_SALDO > 0,"2","1") //1=Pago 2=Nao Pago
					MsUnLock()
				EndiF
				
				dbSelectArea("SE1")
				dbSkip()
			End
		Else

			dbSelectArea("Z05")
			dbSetOrder(1)
			dbSeek(xFilial("Z05")+Z04->Z04_PROPOS+Z04->Z04_ADITIV)

			While !Eof() .And. (Z05->Z05_FILIAL == xFilial("Z05")) .And. (Z05->Z05_PROPOS == Z04->Z04_PROPOS) .And. (Z05->Z05_ADITIV == Z04->Z04_ADITIV)
				If (Z05->Z05_MOD == Z04->Z04_MOD)
					nParcelas:= Z04->Z04_QTDPAR
					dVencIni := Z04->Z04_DATA
					cPrefixo := Z04->Z04_PREFIX
					cNum     := Z04->Z04_NUM
					cTipo    := Z04->Z04_TIPO

					dbSelectArea("SE1")
					dbSetOrder(1)
					dbSeek(xFilial("SE1")+cPrefixo+cNum,.T.)
					While !Eof() .And. (SE1->E1_FILIAL == xFilial("SE1")) .And. (SE1->E1_PREFIXO == cPrefixo) .And. (SE1->E1_NUM = cNum)
						If (SE1->E1_TIPO == cTipo)
							RecLock("Z28",.T.)
							Replace Z28_FILIAL With xFilial("Z28")
							Replace Z28_PROPOS With Z04->Z04_PROPOS
							Replace Z28_ADITIV With Z04->Z04_ADITIV
							Replace Z28_CLIENT With Z02->Z02_CLIENT
							Replace Z28_LOJA   With Z02->Z02_LOJA
							Replace Z28_MODULO With Z05->Z05_MODULO
							Replace Z28_MODLIC With Z05->Z05_MODLIC
							Replace Z28_DTPRV  With SE1->E1_VENCREA
							Replace Z28_TITULO With SE1->E1_NUM
							Replace Z28_PARCEL With SE1->E1_PARCELA
							Replace Z28_QUANT  With Z05->Z05_QUANT
							Replace Z28_HORASA With Z05->Z05_HORASA
							Replace Z28_PRCVEN With Z05->Z05_PRCVEN
							Replace Z28_TOTAL  With Z05->Z05_TOTAL
							Replace Z28_TOTCIP With Z05->Z05_TOTCIP
							Replace Z28_ITEM   With Z05->Z05_ID
							Replace Z28_PAGO   With IIF(SE1->E1_SALDO > 0,"2","1") //1=Pago 2=Nao Pago
							MsUnLock()
						EndIf				
	
						dbSelectArea("SE1")
						dbSkip()
					End	
				EndIf

				dbSelectArea("Z05")
				dbSkip()
			End
		EndIf

		dbSelectArea("Z04")
		dbSkip()
	End
ENDIF
Return


Static Function AttSerasa( cCli, cLoja)

local aParamBox := {}
local aret 		:= {}
local cArq 		:= ''
local lret 		:= .f.
local _cRoot 	:= GetSrvProfString("STARTPATH","")+"Serasa\"
Local aASelecao	 := {"Sim","N緌"} 

FwMakeDir(_cRoot)
//aAdd(aParamBox,{6,"Arquivo serasa",Space(150),"","","",50,.F.,"Todos os arquivos (*.*) |*.*"})
aAdd(aParamBox,{6,"Arquivo serasa",Space(150),"","","",90,.T.,"Todos os arquivos (*.PDF) |*.PDF"})
aAdd(aParamBox,{2,"Serasa sem Restri踥es?","Sim",aASelecao,90,"",.F.})

If ParamBox(aParamBox,"Selecione...",@aRet)
	cArq := alltrim(aRet[1])
	
	If !File(cArq)
		lret := .f.
		MsgStop("O arquivo " + cArq + " n緌 foi encontrado. A importa誽o ser� abortada!","ATENCAO")
		Return lret
	elseif !('.PDF' $ UPPER(cArq))
		lret := .f.
		MsgStop("O arquivo DEVE SER PDF.","ATENCAO")
		Return lret	
	EndIf	
	aSep		:= Separa(cArq,'\')
	nPos        := aScan(aSep, {|x|  "." $ x  }  )
	cImagem     := IIF( nPos > 0, aSep[nPos],cImagem)	
	lret:= CPYT2S( cArq ,_cRoot,.T.)
	nret:= FRename(_cRoot+cImagem,_cRoot+cCli+cLoja+'.pdf')
	IF lret .AND. nret == 0		
		SA1->( RecLock("SA1",.F.) )
			SA1->A1_XSERASA := IF('Sim'==aRet[2],'2','3') // 1=N鬃 REALIZADA;2=REALIZADA SEM RESTRIES;3=REALIZADA COM RESTRIES
			SA1->A1_XAQRSER := _cRoot+cCli+cLoja+'.pdf'
		SA1->(MsUnLock() )
	ELSE
		lret := .f.
		MsgStop("O arquivo " + cArq + " n緌 foi encontrado. A importa誽o ser� abortada!","ATENCAO")
		Return lret	
	END

End
// Tipo 6 -> File
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-String contendo a validacao When
//           [7]-Tamanho do MsGet
//           [8]-Flag .T./.F. Parametro Obrigatorio ?
//           [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
//           [10]-Diretorio inicial do cGetFile
//           [11]-Nero relativo a visualiza誽o, podendo ser por diret鏎io ou por arquivo (0,1,2,4,8,16,32,64,128)


Return lret

// VALIDA CLIENTE NA EDIO
User Function AFZ02CLI()

Local lRet:= (INCLUI .And. Empty(M->Z02_PROSPE))//.OR.(M->Z02_STATUS=='3' .And. Empty(M->Z02_PROSPE))

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Z8FieldOK

Valida誽o de field SZ8

@author Pedro H. Oliveira
@since 15/10/2022
@version P11
/*/
//-------------------------------------------------------------------
Static Function Z8FieldOK( cCpoVld , aHeaderZ08,aColsZ08 )

Local lRet          := .t.
Local xValor        := &(cCpoVld)
Local nZ08_BASE 	:= aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_BASE"})
Local nLinZ8        := oComis:oBrowse:nAt 
Local nx            := 0
Local nAuxZ8        := 0
Local nBaseComis	:= 0
Local ni			:= 0
Local nPTotal     := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_TOTAL"})
Local nPVlrMes    := aScan(aHeaderZ05,{|x| AllTrim(x[2]) == "Z05_VLRMES"})
Local nPQtParc    := aScan(aHeaderZ08,{|x| AllTrim(x[2]) == "Z08_QTPARC"})

aColsZ08 := oComis:aCOLS



For nI:=1 To Len(oResumo:aCols)
	If !oResumo:aCols[nI,Len(oResumo:aHeader)+1]
		IF lServico // Servicos
			nBaseComis	+= oResumo:aCols[nI,nPTotal]
		Else
			nBaseComis	+= oResumo:aCols[nI,nPVlrMes]
		EndIF
	EndIf
Next nI
nBaseComis-= nDscTotal
nBaseComis:= Round(nBaseComis * aColsZ08[1,nPQtParc],2)

If 'Z08_BASE' $ alltrim(cCpoVld) 

    nAuxZ8 := xValor
    for nx := 1 to len(aColsZ08)
        IF nLinZ8 <> nx .and. !aColsZ08[ nx ,Len(aHeaderZ08)+1]        
            nAuxZ8+= aColsZ08[nx][nZ08_BASE]
        EndIf
    next//GDFIELDGET

	If nAuxZ8 > nBaseComis//nSubTotal	 	
		lRet:= .f.
		Alert('Valor base distribuido maior que o permitido. ')
	Else
		oComis:aCols[nLinZ8][nZ08_BASE] := M->Z08_BASE
		U_AtuZ08()	
	End
EndIf

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} AF02HANDOVER

Realiza a aprova誽o do handover para liberar a aprova誽o da proposta

@author Pedro H. Oliveira
@since 15/10/2022
@version P11
/*/
//-------------------------------------------------------------------
User Function AF02HANDOVER()

Local lVisual  	:= .f.
Local lLicenca 	:= Z02->Z02_TIPO $ "348"
Local cProposta	:= Z02->Z02_PROPOS
Local cAditivo	:= Z02->Z02_ADITIV

If lLicenca
	MsgAlert('N緌 � possivel realizar o handover para Propostas de licen蓷s')
	Return
End

//術ao permite alterar proposta aprovada.�
 IF ( Z02->Z02_STATUS $ '5/9' )
	MsgAlert('N緌 � possivel realizar o handover para Propostas Aprovadas. Handover ser� exibido em modo de Visualiza誽o!')
	lVisual := .t.
EndIF

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//� Converte prospect em cliente.                              �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
IF Empty(Z02->Z02_CLIENT)
	If MSGYESNO('Para realizar o handover o prospect deve ser cadastrado comom cliente, deseja realizar isso agora ? ','Aten誽o')
		IF !SyConvPro( Z02->Z02_PROSPE , Z02->Z02_LOJAPR , Z02->Z02_EMPFAT , Z02->Z02_PROPOS, Z02->Z02_ADITIV )
			RestArea(aArea)
			Return(.F.)
		EndIF
	Else
		Return(.F.)
	End	
EndIF

U_AFHANDCAD(cProposta,cAditivo,lVisual)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HasNotaFin

Valida se existe nota fiscal emitida no financeiro

@author Pedro H. Oliveira
@since 15/10/2022
@version P11
/*/
//-------------------------------------------------------------------
Static Function HasNotaFin( cCliente,cProposta,cAditivo )

Local lRet:= .f.
Local cQuery:= ""
Local cTmp:= GetNextAlias()

cQuery+=" SELECT R_E_C_N_O_ SE1REC FROM "+RetSqlName('SE1')+" " +CRLF
cQuery+=" WHERE "+CRLF
cQuery+=" E1_FILIAL='"+xFilial("SE1")+"' "+CRLF
cQuery+=" AND E1_PROPOS = '"+cProposta+"' "+CRLF
cQuery+=" AND E1_ADITIV  = '"+cAditivo+"' "+CRLF
cQuery+=" AND E1_CLIENTE = '"+cCliente+"' "+CRLF
cQuery+=" AND E1_SALDO > 0  "+CRLF
cQuery+=" AND E1_TIPO NOT LIKE '%-'  "+CRLF
cQuery+=" AND D_E_L_E_T_ = '' "+CRLF
cQuery+=" AND E1_XNUMNFS <> '' "+CRLF

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
If (cTmp)->(!Eof())
	lRet:= .t.
EndIf

(cTmp)->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------                   
/*/{Protheus.doc} AfTxtProp
Pega o texto para os campos do contrato 

@author		Pedro H. Oliveira 
@since 		05/02/2020
@version 	P11
/*/
//-------------------------------------------------------------------
Static Function AfTxtProp( cTpTxt )

//Texto padr緌 caso n緌 encontre o arquivo
Local cRet := ""
Local cArqTxt := GetSrvProfString("StartPath","") + 'word\' //"\PROPOSTAS\"
Local nHdl  := 0

DEFAULT cTpTxt := 'CONTRATO'

cArqTxt+= cTpTxt+'.txt'

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//莧bre o arquivo  					 �
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
nHdl  := FT_FUse(cArqTxt) 

//術緌 consegui abrir o arquivo.�
If nHdl = -1	
	Return cRet
EndIf 

//矬闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡醴
//袈osiciona na Primeira linha do arquivo�
//斂闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡闡囁
FT_FGoTop()						
cRet:=''

//覓arre o arquivo adicionando todas as linhas�
While !FT_FEOF()

	// Faz a Leitura da Linha
	//cRet += Alltrim( FT_FReadLn() )+" "
	cRet += Alltrim( FT_FReadLn() )+CRLF
	//矬闡闡闡闡闡闡闡闡闡闡闡闡醴
	//袈assa para a Proxima Linha�
	//斂闡闡闡闡闡闡闡闡闡闡闡闡囁
	FT_FSKIP() 
	
EndDo

FT_FUSE()

Return cRet 
