#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDELFA
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDALFA(cEmpAmb, cFilAmb)
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .and. cFilAmb <> NIL .and. !Empty(cFilAmb) .and. !Empty(cEmpAmb) )  

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDFST" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDFST" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDFST" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDFST" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX5
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de tabelas sistema" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX5()

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SX1
			//------------------------------------
			//oProcess:IncRegua1( "Dicionário de perguntas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX1()
			
			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSXB()
			
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela XT1
//
aAdd( aSX2, { ;
	'XT1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'XT1'+cEmpr																, ; //X2_ARQUIVO
	'Monitor Pedido/Cliente da LINX'										, ; //X2_NOME
	'Monitor Pedido/Cliente da LINX'										, ; //X2_NOMESPA
	'Monitor Pedido/Cliente da LINX'										, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO


//
// Tabela XT2
//
aAdd( aSX2, { ;
	'XT2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'XT2'+cEmpr																, ; //X2_ARQUIVO
	'Log Monitoramento LINX'												, ; //X2_NOME
	'Log Monitoramento LINX'												, ; //X2_NOMESPA
	'Log Monitoramento LINX'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO


//
// Tabela WS0
//
aAdd( aSX2, { ;
	'WS0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'WS0'+cEmpr																, ; //X2_ARQUIVO
	'LOGS ECOMMERCE'														, ; //X2_NOME
	'LOGS ECOMMERCE'														, ; //X2_NOMESPA
	'LOGS ECOMMERCE'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela WS1
//
aAdd( aSX2, { ;
	'WS1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'WS1'+cEmpr																, ; //X2_ARQUIVO
	'STATUS ECOMMERCE'														, ; //X2_NOME
	'STATUS ECOMMERCE'														, ; //X2_NOMESPA
	'STATUS ECOMMERCE'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela WS2
//
aAdd( aSX2, { ;
	'WS2'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'WS2'+cEmpr																, ; //X2_ARQUIVO
	'STATUS PEDIDOS ECOMMERCE'												, ; //X2_NOME
	'STATUS PEDIDOS ECOMMERCE'												, ; //X2_NOMESPA
	'STATUS PEDIDOS ECOMMERCE'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela WS3
//
aAdd( aSX2, { ;
	'WS3'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'WS3'+cEmpr																, ; //X2_ARQUIVO
	'FORMAS DE PAGAMENTO ECOMMERCE'											, ; //X2_NOME
	'FORMAS DE PAGAMENTO ECOMMERCE'											, ; //X2_NOMESPA
	'FORMAS DE PAGAMENTO ECOMMERCE'											, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela WS4
//
aAdd( aSX2, { ;
	'WS4'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'WS4'+cEmpr																, ; //X2_ARQUIVO
	'OPERADORAS PGTO ECOMMERCE'												, ; //X2_NOME
	'OPERADORAS PGTO ECOMMERCE'												, ; //X2_NOMESPA
	'OPERADORAS PGTO ECOMMERCE'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'E'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_IDXFLD" , 0 }, { "X3_AGRUP"  , 0 }, ;
             { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'A1_XLEMBRE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Env.Lembrete'															, ; //X3_TITULO
	'Env.Lembrete'															, ; //X3_TITSPA
	'Env.Lembrete'															, ; //X3_TITENG
	'Envia Lembrete Financeiro'												, ; //X3_DESCRIC
	'Envia Lembrete Financeiro'												, ; //X3_DESCSPA
	'Envia Lembrete Financeiro'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	'1=Sim;2=Nao'															, ; //X3_CBOXSPA
	'1=Sim;2=Nao'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'E1_XLINKNF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Link NF '																, ; //X3_TITULO
	'Link NF '																, ; //X3_TITSPA
	'Link NF '																, ; //X3_TITENG
	'Link NF '																, ; //X3_DESCRIC
	'Link NF '																, ; //X3_DESCSPA
	'Link NF '																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SE1'																	, ; //X3_ARQUIVO
	''																		, ; //X3_ORDEM
	'E1_XDTENVI'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt. Env Lemb'															, ; //X3_TITULO
	'Dt. Env Lemb'															, ; //X3_TITSPA
	'Dt. Env Lemb'															, ; //X3_TITENG
	'Dt. Env Lemb'															, ; //X3_DESCRIC
	'Dt. Env Lemb'															, ; //X3_DESCSPA
	'Dt. Env Lemb'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'"N"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		} ) //X3_PYME



//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela XT1
//
aAdd( aSIX, { ;
	'XT1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'XT1_FILIAL+XT1_ITFILA'													, ; //CHAVE
	'Id Item Fila'															, ; //DESCRICAO
	'Id Item Fila'															, ; //DESCSPA
	'Id Item Fila'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'XT1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'XT1_FILIAL+XT1_ITFILA+XT1_STATUS+XT1_ENTITY'							, ; //CHAVE
	'Id Item Fila+Status Integ+Entidade'									, ; //DESCRICAO
	'Id Item Fila+Status Integ+Entidade'									, ; //DESCSPA
	'Id Item Fila+Status Integ+Entidade'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'XT1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'XT1_FILIAL+XT1_STATUS+XT1_ENTITY'										, ; //CHAVE
	'Id Item Fila+Entidade'													, ; //DESCRICAO
	'Id Item Fila+Entidade'													, ; //DESCSPA
	'Id Item Fila+Entidade'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'XT2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'XT2_FILIAL+XT2_INTEGR+XT2_CODIGO'										, ; //CHAVE
	'Filial + Integracao + Codigo'											, ; //DESCRICAO
	'Filial + Integracao + Codigo'											, ; //DESCSPA
	'Filial + Integracao + Codigo'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SC5
//
aAdd( aSIX, { ;
	'SC5'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'C5_FILIAL+C5_NUMECO'													, ; //CHAVE
	'Cod. Pv eCom'															, ; //DESCRICAO
	'Cod. Pv eCom'															, ; //DESCSPA
	'Cod. Pv eCom'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PEDIDOECO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SC5'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'C5_FILIAL+C5_NUMECLI'													, ; //CHAVE
	'Num Pv Cli'															, ; //DESCRICAO
	'Num Pv Cli'															, ; //DESCSPA
	'Num Pv Cli'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SE1
//
aAdd( aSIX, { ;
	'SE1'																	, ; //INDICE
	'S'																		, ; //ORDEM
	'E1_FILIAL+E1_NUMECO'													, ; //CHAVE
	'Num Pv eComm'															, ; //DESCRICAO
	'Num Pv eComm'															, ; //DESCSPA
	'Num Pv eComm'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'TITECO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SL1
//
aAdd( aSIX, { ;
	'SL1'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'L1_FILIAL+L1_XNUMECO'													, ; //CHAVE
	'Cod. Pv eCom'															, ; //DESCRICAO
	'Cod. Pv eCom'															, ; //DESCSPA
	'Cod. Pv eCom'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PEDIDOECO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SL1'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'L1_FILIAL+L1_XNUMECL'													, ; //CHAVE
	'Num Pv Cli'															, ; //DESCRICAO
	'Num Pv Cli'															, ; //DESCSPA
	'Num Pv Cli'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PEDECOCLI'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela WS0
//
aAdd( aSIX, { ;
	'WS0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'WS0_FILIAL+WS0_COD+WS0_THREAD'											, ; //CHAVE
	'Interface+Trhead Id+Thread'											, ; //DESCRICAO
	'Interface+Trhead Id+Thread'											, ; //DESCSPA
	'Interface+Trhead Id+Thread'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS0'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'WS0_FILIAL+WS0_DESCIN'													, ; //CHAVE
	'Desc Interf'															, ; //DESCRICAO
	'Desc Interf'															, ; //DESCSPA
	'Desc Interf'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS0'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'WS0_FILIAL+WS0_DATA'													, ; //CHAVE
	'Data'																	, ; //DESCRICAO
	'Data'																	, ; //DESCSPA
	'Data'																	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela WS1
//
aAdd( aSIX, { ;
	'WS1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'WS1_FILIAL+WS1_CODIGO'													, ; //CHAVE
	'Codigo'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Codigo'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela WS2
//
aAdd( aSIX, { ;
	'WS2'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'WS2_FILIAL+WS2_NUMECO'													, ; //CHAVE
	'Num Ped Eco'															, ; //DESCRICAO
	'Num Ped Eco'															, ; //DESCSPA
	'Num Ped Eco'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'WS2'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'WS2_FILIAL+WS2_NUMSL1'													, ; //CHAVE
	'Codigo SL1'															, ; //DESCRICAO
	'Codigo SL1'															, ; //DESCSPA
	'Codigo SL1'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela WS3
//
aAdd( aSIX, { ;
	'WS3'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'WS3_FILIAL+WS3_CODIGO'													, ; //CHAVE
	'Codigo Forma'															, ; //DESCRICAO
	'Codigo Forma'															, ; //DESCSPA
	'Codigo Forma'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela WS4
//
aAdd( aSIX, { ;
	'WS4'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'WS4_FILIAL+WS4_CODIGO+WS4_TIPO'										, ; //CHAVE
	'Codigo Oper+Tipo de Oper'												, ; //DESCRICAO
	'Codigo Oper+Tipo de Oper'												, ; //DESCSPA
	'Codigo Oper+Tipo de Oper'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ


//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XBANCO'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DESCRIC
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DESC1
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA1
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG1
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DESC2
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA2
	'Banco p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG2
	'341'																	, ; //X6_CONTEUD
	'341'																	, ; //X6_CONTSPA
	'341'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XAGENCI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DESCRIC
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DESC1
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA1
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG1
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DESC2
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA2
	'Agencia p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG2
	'0018'																	, ; //X6_CONTEUD
	'0018'																	, ; //X6_CONTSPA
	'0018'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCONTA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DESCRIC
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DESC1
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA1
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG1
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DESC2
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCSPA2
	'Conta p/ pagamento do WF do Financeiro'								, ; //X6_DSCENG2
	'77729-2'																, ; //X6_CONTEUD
	'77729-2'																, ; //X6_CONTSPA
	'77729-2'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XFAVORE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DESCRIC
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCSPA
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCENG
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DESC1
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCSPA1
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCENG1
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DESC2
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCSPA2
	'Favorecido do pagamento do WF Financeiro'								, ; //X6_DSCENG2
	'ALFA SISTEMAS DE GESTAO LTDA'											, ; //X6_CONTEUD
	'ALFA SISTEMAS DE GESTAO LTDA'											, ; //X6_CONTSPA
	'ALFA SISTEMAS DE GESTAO LTDA'											, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCNPJFA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DESCRIC
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCSPA
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCENG
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DESC1
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCSPA1
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCENG1
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DESC2
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCSPA2
	'CNPJ favorecido do pagamento do WF Financeiro'							, ; //X6_DSCENG2
	'07.640.028/0001-32'													, ; //X6_CONTEUD
	'07.640.028/0001-32'													, ; //X6_CONTSPA
	'07.640.028/0001-32'													, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XOPWFFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DESCRIC
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCSPA
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCENG
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DESC1
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCSPA1
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCENG1
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DESC2
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCSPA2
	'Opção do WF Financeiro: 1=;Ativo;2=Homol;3=Inativo'					, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME



aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XEMATST'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DESCRIC
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCSPA
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCENG
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DESC1
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCSPA1
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCENG1
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DESC2
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCSPA2
	'Email para teste, em branco envia p/ Cliente'							, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XDAPOS'																, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DESCRIC
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCSPA
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCENG
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DESC1
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCSPA1
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCENG1
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DESC2
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCSPA2
	'Qtd. de dias após o vencimento para envio do WF Fi'					, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XDANTES'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DESCRIC
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCSPA
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCENG
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DESC1
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCSPA1
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCENG1
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DESC2
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCSPA2
	'Qtd. de dias antes do vencimento p/ envio do WF Fi'					, ; //X6_DSCENG2
	'5'																		, ; //X6_CONTEUD
	'5'																		, ; //X6_CONTSPA
	'5'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XTITEMA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DESCRIC
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCSPA
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCENG
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DESC1
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCSPA1
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCENG1
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DESC2
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCSPA2
	'Título do e-mail de Workflow Financeiro'								, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELTLS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Informe se o servidor de SMTP possui conexão do   '					, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'tipo segura ( SSL/TLS ).                          '					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELAUTH'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESCRIC
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCSPA
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCENG
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESC1
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCSPA1
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCENG1
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESC2
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCSPA2
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME


aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELSSL'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se o envio e recebimento de e-mails na'							, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'rotina SPED utilizará conexão segura (SSL).       '					, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELTIME'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Timeout no Envio de EMAIL.'											, ; //X6_DESCRIC
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCSPA
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCENG
	'Timeout no Envio de EMAIL.'											, ; //X6_DESC1
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCSPA1
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCENG1
	'Timeout no Envio de EMAIL.'											, ; //X6_DESC2
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCSPA2
	'Timeout no Envio de EMAIL.'											, ; //X6_DSCENG2
	'120'																	, ; //X6_CONTEUD
	'120'																	, ; //X6_CONTSPA
	'120'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XRELPOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DESCRIC
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCSPA
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCENG
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DESC1
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCSPA1
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCENG1
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DESC2
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCSPA2
	'Porta utilizada no envio de email do WF Financeiro'					, ; //X6_DSCENG2
	'587'																	, ; //X6_CONTEUD
	'587'																	, ; //X6_CONTSPA
	'587'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_XCOPFAT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DESCRIC
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCSPA
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCENG
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DESC1
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCSPA1
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCENG1
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DESC2
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCSPA2
	'Copia do email do WorkFlow Financeiro'									, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME



aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELSERV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DESCRIC
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCSPA
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCENG
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DESC1
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCSPA1
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCENG1
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DESC2
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCSPA2
	'Nome do Servidor de Envio de E-mail '									, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELAUSR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DESCRIC
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCSPA
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCENG
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DESC1
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCSPA1
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCENG1
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DESC2
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCSPA2
	'Usuario para Autenticacao no Servidor de Email    '					, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELAPSW'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DESCRIC
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCSPA
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCENG
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DESC1
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCSPA1
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCENG1
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DESC2
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCSPA2
	'Senha para autenticacäo no servidor de e-mail     '					, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELFROM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-mail utilizado no campo FROM'										, ; //X6_DESCRIC
	'E-mail utilizado no campo FROM'										, ; //X6_DSCSPA
	'E-mail utilizado no campo FROM'										, ; //X6_DSCENG
	'E-mail utilizado no campo FROM'										, ; //X6_DESC1
	'E-mail utilizado no campo FROM'										, ; //X6_DSCSPA1
	'E-mail utilizado no campo FROM'										, ; //X6_DSCENG1
	'E-mail utilizado no campo FROM'										, ; //X6_DESC2
	'E-mail utilizado no campo FROM'										, ; //X6_DSCSPA2
	'E-mail utilizado no campo FROM'										, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SC5
//
aAdd( aSXA, { ;
	'SC5'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Drastosa'																, ; //XA_DESCRIC
	'Drastosa'																, ; //XA_DESCSPA
	'Drastosa'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SC5'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'e-Commerce'															, ; //XA_DESCRIC
	'e-Commerce'															, ; //XA_DESCSPA
	'e-Commerce'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SC5'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Destinatario'															, ; //XA_DESCRIC
	'Destinatario'															, ; //XA_DESCSPA
	'Destinatario'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SC5'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Forma de Pagamento'													, ; //XA_DESCRIC
	'Forma de Pagamento'													, ; //XA_DESCSPA
	'Forma de Pagamento'													, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SC5'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Dados do Cartao'														, ; //XA_DESCRIC
	'Dados do Cartao'														, ; //XA_DESCSPA
	'Dados do Cartao'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX1
Função de processamento da gravação do SX1 - Perguntas

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX1()
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

AutoGrLog( "Ínicio da Atualização " + cAlias + CRLF )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Perguntas AECOLOG
//

aAdd( aSX1, { ;
	'AECOLOG'																, ; //X1_GRUPO
	'01'																	, ; //X1_ORDEM
	'Filtrar ?'																, ; //X1_PERGUNT
	'Filtrar ?'																, ; //X1_PERSPA
	'Filtrar ?'																, ; //X1_PERENG
	'mv_ch1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	3																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'mv_par01'																, ; //X1_VAR01
	'Por Dia'																, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Por Semana'															, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	'Todos'																	, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL


//
// Atualizando dicionário
//

nPosPerg:= aScan( aEstrut, "X1_GRUPO"   )
nPosOrd := aScan( aEstrut, "X1_ORDEM"   )
nPosTam := aScan( aEstrut, "X1_TAMANHO" )
nPosSXG := aScan( aEstrut, "X1_GRPSXG"  )

oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX1[nI][nPosSXG]  )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX1[nI][nPosSXG] ) )
			If aSX1[nI][nPosTam] <> SXG->XG_SIZE
				aSX1[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho da pergunta " + aSX1[nI][nPosPerg] + " / " + aSX1[nI][nPosOrd] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				"   por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	oProcess:IncRegua2( "Atualizando perguntas..." )

	If !SX1->( dbSeek( PadR( aSX1[nI][nPosPerg], nTam1 ) + PadR( aSX1[nI][nPosOrd], nTam2 ) ) )
		AutoGrLog( "Pergunta Criada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .T. )
	Else
		AutoGrLog( "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .F. )
	EndIf

	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ

	MsUnLock()

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  01/03/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }

/*
//
// Consulta AY0
//
aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'CATEGORIA'																, ; //XB_DESCRI
	'CATEGORIA'																, ; //XB_DESCSPA
	'CATEGORIA'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

//
// Consulta AY01
//
aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria 1'															, ; //XB_DESCRI
	'Categoria 1'															, ; //XB_DESCSPA
	'Categoria 1'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY01'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "1"'													} ) //XB_CONTEM

//
// Consulta AY02
//
aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria 1'															, ; //XB_DESCRI
	'Categoria 1'															, ; //XB_DESCSPA
	'Categoria 1'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY02'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "2"'													} ) //XB_CONTEM

//
// Consulta AY03
//
aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria 1'															, ; //XB_DESCRI
	'Categoria 1'															, ; //XB_DESCSPA
	'Categoria 1'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY03'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "3"'													} ) //XB_CONTEM

//
// Consulta AY04
//
aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria 1'															, ; //XB_DESCRI
	'Categoria 1'															, ; //XB_DESCSPA
	'Categoria 1'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY04'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "4"'													} ) //XB_CONTEM

//
// Consulta AY05
//
aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria 1'															, ; //XB_DESCRI
	'Categoria 1'															, ; //XB_DESCSPA
	'Categoria 1'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY05'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "5"'													} ) //XB_CONTEM

//
// Consulta AY0CA3
//
aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Secao'																	, ; //XB_DESCRI
	'Secao'																	, ; //XB_DESCSPA
	'Secao'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA3'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="3"'													} ) //XB_CONTEM

//
// Consulta AY0CA4
//
aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Especie'																, ; //XB_DESCRI
	'Especie'																, ; //XB_DESCSPA
	'Especie'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0CA4'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(MV_PAR03)'							} ) //XB_CONTEM

//
// Consulta AY0DEP
//
aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Depto'														, ; //XB_DESCRI
	'Consulta Depto'														, ; //XB_DESCSPA
	'Consulta Depto'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0DEP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="1"'													} ) //XB_CONTEM

//
// Consulta AY0NV1
//
aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categorias Nivel 1'													, ; //XB_DESCRI
	'Categorias Nivel 1'													, ; //XB_DESCSPA
	'Categorias Nivel 1'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV1'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "1"'													} ) //XB_CONTEM

//
// Consulta AY0NV2
//
aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categorias Nivel 2'													, ; //XB_DESCRI
	'Categorias Nivel 2'													, ; //XB_DESCSPA
	'Categorias Nivel 2'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV2'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "2"'													} ) //XB_CONTEM

//
// Consulta AY0NV3
//
aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categorias Nivel 3'													, ; //XB_DESCRI
	'Categorias Nivel 3'													, ; //XB_DESCSPA
	'Categorias Nivel 3'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV3'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "3"'													} ) //XB_CONTEM

//
// Consulta AY0NV4
//
aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categorias Nivel 4'													, ; //XB_DESCRI
	'Categorias Nivel 4'													, ; //XB_DESCSPA
	'Categorias Nivel 4'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV4'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "4"'													} ) //XB_CONTEM

//
// Consulta AY0NV5
//
aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categorias Nivel 5'													, ; //XB_DESCRI
	'Categorias Nivel 5'													, ; //XB_DESCSPA
	'Categorias Nivel 5'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY0NV5'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO == "5"'													} ) //XB_CONTEM

//
// Consulta AY1
//
aAdd( aSXB, { ;
	'AY1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Consulta Categorias'													, ; //XB_DESCRI
	'Consulta Categorias'													, ; //XB_DESCSPA
	'Consulta Categorias'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SYVC008()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SYVC008A()'															} ) //XB_CONTEM

//
// Consulta AY1ESP
//
aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Espécie'														, ; //XB_DESCRI
	'Consulta Espécie'														, ; //XB_DESCSPA
	'Consulta Espécie'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1ESP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B4_01CAT3)'						} ) //XB_CONTEM

//
// Consulta AY1GRP
//
aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Grupos'														, ; //XB_DESCRI
	'Consulta Grupos'														, ; //XB_DESCSPA
	'Consulta Grupos'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1GRP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT1)'						} ) //XB_CONTEM

//
// Consulta AY1LIN
//
aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Linha'														, ; //XB_DESCRI
	'Consulta Linha'														, ; //XB_DESCSPA
	'Consulta Linha'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1LIN'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B4_01CAT1)'						} ) //XB_CONTEM

//
// Consulta AY1SEC
//
aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Seção'														, ; //XB_DESCRI
	'Consulta Seção'														, ; //XB_DESCSPA
	'Consulta Seção'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SEC'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->B4_01CAT2)'						} ) //XB_CONTEM

//
// Consulta AY1SUB
//
aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta SubTipo'														, ; //XB_DESCRI
	'Consulta SubTipo'														, ; //XB_DESCSPA
	'Consulta SubTipo'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1SUB'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT3)'						} ) //XB_CONTEM

//
// Consulta AY1TIP
//
aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Tipo'															, ; //XB_DESCRI
	'Consulta Tipo'															, ; //XB_DESCSPA
	'Consulta Tipo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("AY0",1,xFilial("AY0")+AY1->AY1_SUBCAT,"AY0_DESC")'			} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY1TIP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT2)'						} ) //XB_CONTEM

//
// Consulta AY2
//
aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro de Marcas'													, ; //XB_DESCRI
	'Cadastro de Marcas'													, ; //XB_DESCSPA
	'Cadastro de Marcas'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2_DESCR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2_DESCR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2->AY2_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY2->AY2_DESCR'														} ) //XB_CONTEM

//
// Consulta AY3
//
aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'CARACTERISTICAS'														, ; //XB_DESCRI
	'CARACTERISTICAS'														, ; //XB_DESCSPA
	'CARACTERISTICAS'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY3'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Caract.'															, ; //XB_DESCRI
	'Cod. Caract.'															, ; //XB_DESCSPA
	'Cod. Caract.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Cadastra Novo'															, ; //XB_DESCSPA
	'Cadastra Novo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Caract.'															, ; //XB_DESCRI
	'Cod. Caract.'															, ; //XB_DESCSPA
	'Cod. Caract.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY3_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descric. Erp'															, ; //XB_DESCRI
	'Descric. Erp'															, ; //XB_DESCSPA
	'Descric. Erp'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY3_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY3->AY3_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY3->AY3_DESCRI'														} ) //XB_CONTEM

//
// Consulta AY3DEP
//
aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Depto AY3'													, ; //XB_DESCRI
	'Consulta Depto AY3'													, ; //XB_DESCSPA
	'Consulta Depto AY3'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3DEP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_TIPO=="4"'													} ) //XB_CONTEM

//
// Consulta AY3GRP
//
aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Grupos AY3'													, ; //XB_DESCRI
	'Consulta Grupos AY3'													, ; //XB_DESCSPA
	'Consulta Grupos AY3'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3GRP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_CAT1)'						} ) //XB_CONTEM

//
// Consulta AY3SUB
//
aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta SubTipo AY3'													, ; //XB_DESCRI
	'Consulta SubTipo AY3'													, ; //XB_DESCSPA
	'Consulta SubTipo AY3'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3SUB'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_01CAT3)'						} ) //XB_CONTEM

//
// Consulta AY3TIP
//
aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Tipo AY3'														, ; //XB_DESCRI
	'Consulta Tipo AY3'														, ; //XB_DESCSPA
	'Consulta Tipo AY3'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY3TIP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AY3_CAT2)'						} ) //XB_CONTEM

//
// Consulta AY4
//
aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'VALOR CARACTERISTICA'													, ; //XB_DESCRI
	'VALOR CARACTERISTICA'													, ; //XB_DESCSPA
	'VALOR CARACTERISTICA'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Caract.+sequenc'													, ; //XB_DESCRI
	'Cod. Caract.+sequenc'													, ; //XB_DESCSPA
	'Cod. Caract.+sequenc'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sequencia'																, ; //XB_DESCRI
	'Sequencia'																, ; //XB_DESCSPA
	'Sequencia'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_SEQ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Valor Caract'															, ; //XB_DESCRI
	'Valor Caract'															, ; //XB_DESCSPA
	'Valor Caract'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_VALOR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4->AY4_SEQ'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4->AY4_CODCAR==GdFieldGet("AY5_CODIGO")'								} ) //XB_CONTEM

//
// Consulta AY4_2
//
aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Valor Caracteristica'													, ; //XB_DESCRI
	'Valor Caracteristica'													, ; //XB_DESCSPA
	'Valor Caracteristica'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Valor Caract+sequenc'													, ; //XB_DESCRI
	'Valor Caract+sequenc'													, ; //XB_DESCSPA
	'Valor Caract+sequenc'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Sequencia + Valor Ca'													, ; //XB_DESCRI
	'Sequencia + Valor Ca'													, ; //XB_DESCSPA
	'Sequencia + Valor Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"01# T_SSVLRCAR('AY4',AY4->(Recno()),4)"								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Valor Caract'															, ; //XB_DESCRI
	'Valor Caract'															, ; //XB_DESCSPA
	'Valor Caract'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_VALOR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sequencia'																, ; //XB_DESCRI
	'Sequencia'																, ; //XB_DESCSPA
	'Sequencia'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_SEQ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sequencia'																, ; //XB_DESCRI
	'Sequencia'																, ; //XB_DESCSPA
	'Sequencia'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_SEQ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Valor Caract'															, ; //XB_DESCRI
	'Valor Caract'															, ; //XB_DESCSPA
	'Valor Caract'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4_VALOR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4->AY4_SEQ'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AY4_2'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY4->AY4_CODCAR == T_RETCARAC()'										} ) //XB_CONTEM

//
// Consulta AYVDEP
//
aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Grupo'														, ; //XB_DESCRI
	'Consulta Grupo'														, ; //XB_DESCSPA
	'Consulta Grupo'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Tipo'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY0->AY0_DESC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVDEP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"AY0->AY0_TIPO=='1'"													} ) //XB_CONTEM

//
// Consulta AYVGRP
//
aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Linha'														, ; //XB_DESCRI
	'Consulta Linha'														, ; //XB_DESCSPA
	'Consulta Linha'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVGRP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT1)'						} ) //XB_CONTEM

//
// Consulta AYVSUB
//
aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Especie'														, ; //XB_DESCRI
	'Consulta Especie'														, ; //XB_DESCSPA
	'Consulta Especie'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVSUB'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT3)'						} ) //XB_CONTEM

//
// Consulta AYVTIP
//
aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Secao'														, ; //XB_DESCRI
	'Consulta Secao'														, ; //XB_DESCSPA
	'Consulta Secao'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao+sub.catego'													, ; //XB_DESCRI
	'Descricao+sub.catego'													, ; //XB_DESCSPA
	'Descricao+sub.catego'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCRI
	'Sub.categor.+cod. Ca'													, ; //XB_DESCSPA
	'Sub.categor.+cod. Ca'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_002'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCRI
	'Cod. Categ.+sub.cate'													, ; //XB_DESCSPA
	'Cod. Categ.+sub.cate'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Categ.'															, ; //XB_DESCRI
	'Cod. Categ.'															, ; //XB_DESCSPA
	'Cod. Categ.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Sub.Categor.'															, ; //XB_DESCRI
	'Sub.Categor.'															, ; //XB_DESCSPA
	'Sub.Categor.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_SUBCAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Desc.Sub.Cat'															, ; //XB_DESCRI
	'Desc.Sub.Cat'															, ; //XB_DESCSPA
	'Desc.Sub.Cat'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1_DESCSU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_SUBCAT'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'AY1->AY1_DESCSU'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AYVTIP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ALLTRIM(AY1->AY1_CODIGO)==ALLTRIM(M->AYV_CAT2)'						} ) //XB_CONTEM

//
// Consulta SB1
//
aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1FA093SB1();Config;SBP->BP_BASE'										} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao + Codigo'													, ; //XB_DESCRI
	'Descripcion + Codigo'													, ; //XB_DESCSPA
	'Description + Produc'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Referencia'															, ; //XB_DESCRI
	'Referencia'															, ; //XB_DESCSPA
	'Referencia'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Referencia'															, ; //XB_DESCRI
	'Referencia'															, ; //XB_DESCSPA
	'Referencia'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_XREFFOR'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Referencia'															, ; //XB_DESCRI
	'Referencia'															, ; //XB_DESCSPA
	'Referencia'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_XREFFOR'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Referencia'															, ; //XB_DESCRI
	'Referencia'															, ; //XB_DESCSPA
	'Referencia'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_XREFFOR'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1->B1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta BVCOR3
//
aAdd( aSXB, { ;
	'BVCOR3'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Grade de Produtos'														, ; //XB_DESCRI
	'Grade de Produtos'														, ; //XB_DESCSPA
	'Grade de Produtos'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BVCOR3'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SySxbCor()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BVCOR3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SyRetCor()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BVCOR3'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SyRetDes()'															} ) //XB_CONTEM

//
// Consulta SB4REF
//
aAdd( aSXB, { ;
	'SB4REF'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Grade de Produtos'														, ; //XB_DESCRI
	'Grade de Produtos'														, ; //XB_DESCSPA
	'Grade de Produtos'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB4REF'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SySxbRef()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB4REF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SyRetRef()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB4REF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SyRetDRef()'															} ) //XB_CONTEM

//
// Consulta SBV
//
aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Grade de Produtos'														, ; //XB_DESCRI
	'Cuadricula Productos'													, ; //XB_DESCSPA
	'Product Grid'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TABELA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_DESCTAB'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TABELA'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBV'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'! Empty(BV_DESCTAB)'													} ) //XB_CONTEM

//
// Consulta SBVCOL
//
aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'GRADE DE PRODUTOS CL'													, ; //XB_DESCRI
	'GRADE DE PRODUTOS CL'													, ; //XB_DESCSPA
	'GRADE DE PRODUTOS CL'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TABELA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_DESCTAB'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TABELA'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOL'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TIPO=="2" .AND. ! Empty(BV_DESCTAB)'							} ) //XB_CONTEM

//
// Consulta SBVCOR
//
aAdd( aSXB, { ;
	'SBVCOR'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'GRADE DE COR'															, ; //XB_DESCRI
	'GRADE DE COR'															, ; //XB_DESCSPA
	'GRADE DE COR'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SYVC010()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SYVC010A()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVCOR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T_SYVC010B()'															} ) //XB_CONTEM

//
// Consulta SBVGRP
//
aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Grupo de Cores'														, ; //XB_DESCRI
	'Grupo de Cores'														, ; //XB_DESCSPA
	'Grupo de Cores'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SYMMSBV01'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Chave+descricao'														, ; //XB_DESCRI
	'Clave+descripcion'														, ; //XB_DESCSPA
	'Key+descripcion'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SYMMSBV02'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_CHAVE'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_CHAVE'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_CHAVE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_DESCRI'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVGRP'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TABELA=="00"'													} ) //XB_CONTEM

//
// Consulta SBVLIN
//
aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'GRADE DE PRODUTOS LN'													, ; //XB_DESCRI
	'GRADE DE PRODUTOS LN'													, ; //XB_DESCSPA
	'GRADE DE PRODUTOS LN'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabla'																	, ; //XB_DESCSPA
	'Table'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TABELA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_DESCTAB'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'BV_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TABELA'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SBVLIN'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SBV->BV_TIPO=="1" .AND. ! Empty(BV_DESCTAB)'							} ) //XB_CONTEM	
*/
//
// Consulta BMPRET
//
aAdd( aSXB, { ;
	'BMPRET'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Retorna Imagem Statu'													, ; //XB_DESCRI
	'Retorna Imagem Statu'													, ; //XB_DESCSPA
	'Retorna Imagem Statu'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'WS1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BMPRET'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_AECOBIT()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'BMPRET'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_ABitRet()'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20

	OpenSM0("01",.T.)
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return(lOpen)


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  29/02/2016
@obs    Gerado por EXPORDIC - V.4.22.10.8 EFS / Upd. V.4.19.13 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX5
Função de processamento da gravação do SX5 - Indices

@author TOTVS Protheus
@since  08/07/2017
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX5()
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX5->X5_FILIAL )

AutoGrLog( "Ínicio da Atualização SX5" + CRLF )

aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

//
// Tabela SX5
//
aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'98'																	, ; //X5_TABELA
	'ECO_R'																	, ; //X5_CHAVE
	'1406'																	, ; //X5_DESCRI
	'1406'																	, ; //X5_DESCSPA
	'1406'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'98'																	, ; //X5_TABELA
	'ECO_S'																	, ; //X5_CHAVE
	'1407'																	, ; //X5_DESCRI
	'1407'																	, ; //X5_DESCSPA
	'1407'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'98'																	, ; //X5_TABELA
	'ECO_G'																	, ; //X5_CHAVE
	'1411'																	, ; //X5_DESCRI
	'1411'																	, ; //X5_DESCSPA
	'1411'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'98'																	, ; //X5_TABELA
	'ECO_M'																	, ; //X5_CHAVE
	'1446'																	, ; //X5_DESCRI
	'1446'																	, ; //X5_DESCSPA
	'1446'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'98'																	, ; //X5_TABELA
	'ECO_O'																	, ; //X5_CHAVE
	'1445'																	, ; //X5_DESCRI
	'1445'																	, ; //X5_DESCSPA
	'1445'																	} ) //X5_DESCENG
//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	oProcess:IncRegua2( "Atualizando tabelas..." )

	If !SX5->( dbSeek( PadR( aSX5[nI][1], nTamFil ) + aSX5[nI][2] + aSX5[nI][3] ) )
		AutoGrLog( "Item da tabela criado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .T. )
	Else
		AutoGrLog( "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .F. )
	EndIf

	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ

	MsUnLock()

	aAdd( aArqUpd, aSX5[nI][1] )

	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

/////////////////////////////////////////////////////////////////////////////
