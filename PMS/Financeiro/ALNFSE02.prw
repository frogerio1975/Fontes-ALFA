//-------------------------------------------------------------------
/*/{Protheus.doc} ALNFSE02
Consulta status da nota fiscal
@author  Victor Andrade
@since   22/03/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function ALNFSE02()

Private cDirEnv := ""
Private cDirRet := ""
Private cCnpj   := ""

If AllTrim( DTOS( SE1->E1_BAIXA ) ) <> ""
	MsgAlert( "Título já sofreu movimentação.", "Atenção" )
ElseIf Empty( SE1->E1_EMPFAT )
	MsgAlert( "Empresa de faturamento não informada.", "Atenção" )
ElseIf !( SE1->E1_XSTNFS $ "1|2|3|4" )
	MsgAlert( "Não há dados à serem consultados.", "Atenção" )
ElseIf Empty( SE1->E1_XLTNFS )
	MsgAlert( "Lote não transmitido.", "Atenção" )
Else
	cDirEnv := GetMV( "FS_DIRENV" + SE1->E1_EMPFAT )
	cDirRet := GetMV( "FS_DIRRET" + SE1->E1_EMPFAT )
	cCnpj   := GetMV( "FS_CNPJ"   + SE1->E1_EMPFAT )

	FWMsgRun( , {|| AL02Proc( SE1->( Recno() ) ) }, "Aguarde", "Consultando NFS-e" )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AL02Proc
Encapsula as funções de processamento
@author  Victor Andrade
@since   23/03/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL02Proc( nRecnoSE1 )

Local cXML := ""

// Garante que esteja posicionado no registro
SE1->( DbGoTo( nRecnoSE1 ) )

cXML := AL02Xml()

If AL02Copy( cXML, SE1->E1_XLTNFS )
    // Pega o retorno do processamento do Uninfe
	AL02Ret( SE1->E1_XLTNFS )
Else
    MsgAlert( "Erro ao gerar arquivo XML para integração.", "Atenção" )
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AL02Xml
Gera o XML para consultar
@author  Victor Andrade
@since   23/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL02Xml()

Local cXML      := ""
Local cInscM    := GetMV( "FS_INSCM" + SE1->E1_EMPFAT )

cXml += '<ConsultarLoteRpsEnvio xmlns="http://www.ginfes.com.br/servico_consultar_lote_rps_envio_v03.xsd" xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd">'
cXml += '<Prestador>'
cXml += '<tipos:Cnpj>' + cCnpj + '</tipos:Cnpj>'
cXml += '<tipos:InscricaoMunicipal>' + AllTrim( cInscM ) + '</tipos:InscricaoMunicipal>'
cXml += '</Prestador>'
cXml += '<Protocolo>' + AllTrim( SE1->E1_XPRTNFS ) + '</Protocolo>'
cXml += '</ConsultarLoteRpsEnvio>'

Return( cXML )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL02Copy
Disponibiliza o XML na pasta do Uninfe para que o mesmo possa ser transmitido para a prefeitura
@author  Victor Andrade
@since   24/01/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL02Copy( cXML, cNumLote )

Local lRet		 := .F.
Local cFile		 := AllTrim( cCnpj ) + cNumLote + "-ped-loterps.xml"

lRet := MemoWrite( cDirEnv + cFile, cXML )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL02Ret
Aguarda por alguns segundos o processamento do Uninfes e pega o retorno.
Se passar 10 segundos e não tiver retorno, é sinal que o Uninfes está fora do ar.
@author  Victor Andrade
@since   23/03/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL02Ret( cNumLote )

Local cFileEnv		:= AllTrim( cCnpj ) + cNumLote + "-ped-loterps.xml"
Local cFileRet		:= AllTrim( cCnpj ) + cNumLote + "-loterps.xml"
Local cFileErr		:= AllTrim( cCnpj ) + cNumLote + "-loterps.err"
Local nRepet 		:= 0
Local nTentativas 	:= 0
Local lRet			:= .T.
Local cMsgErr   	:= ""
Local cNumNFS		:= ""
Local cCodAut		:= ""
Local cDataRcto		:= ""

While File( cDirEnv + cFileEnv ) .And. nRepet <= 5
	nRepet ++
	Sleep(2000)
End

// Se em 10 segundos, o arquivo ainda está na pasta de "Envio"
// Então o Uninfes está fora do Ar
If File( cDirEnv + cFileEnv )
	MsgAlert( "Erro ao comunicar-se com a plataforma Uninfes." + Chr(10) + Chr(13) + ; 
			  "Verifica se a mesma está no ar.", "Atenção" )
	lRet := .F.
Else
	
	// Aguarda 5 segundos antes de verificar se já teve retorno, pois as vezes oscila a conexão
	While (!File( cDirRet + cFileRet ) .Or. !File( cDirRet + cFileErr )) .And. nTentativas <= 5

		nTentativas++

		Sleep(5000)

		If File( cDirRet + cFileRet )
			If AL02Parse( cFileRet, @cMsgErr, @cNumNFS, @cCodAut, @cDataRcto )

				If Empty( cMsgErr )
					MsgAlert( "RPS autorizado com sucesso!" )
				Else
					EECView( "Erro em validação do RPS" + Chr(13) + Chr(10) + cMsgErr )
				EndIf

				RecLock("SE1", .F. )
				SE1->E1_XSTNFS  := Iif( Empty( cMsgErr ), "4", "2" )
				SE1->E1_XMSGNFS := cMsgErr
				SE1->E1_XNUMNFS	:= cNumNFS
				SE1->E1_XCODNFS	:= cCodAut
				SE1->E1_XDTREC	:= cDataRcto
				SE1->E1_XLINKNF	:= Iif( Empty( cMsgErr ), "http://visualizar.ginfes.com.br/report/consultarNota?__report=nfs_ver15&cdVerificacao=" + Upper(cCodAut) + "&numNota=" + cNumNfs + "&cnpjPrestador=null", "" )
				SE1->( MsUnlock() )

				Exit

			EndIf
		ElseIf File( cDirRet + cFileErr )
			MsgAlert( "Erro na estrutura do arquivo de envio." + Chr(10) + Chr(13) + ;
					" Para maiores detalhes, verifique o arquivo " + cDirRet + cFileErr + ".", "Atenção" )
			lRet := .F.
			Exit
		EndIf
	EndDo
EndIf

IF nTentativas >= 5
	MsgAlert( "Não foi possivel obter retorno apos " + StrZero(nTentativas,2) + "Tentativas." )
EndIF

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL02Parse
Faz o parse do XML de retorno para pegar informações de protocolo e data de recebimento
@author  Victor Andrade
@since   23/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL02Parse( cFileXML, cMsgErr, cNumNFS, cCodAut, cDataRcto )

Local oXmlParse := Nil
Local cError	:= ""
Local cWarning	:= ""
Local lRet		:= .T.
Local cArqXML	:= "\retNFSE\" + cFileXML

If !ExistDir( "\retNFSE" )
	MakeDir( "\retNFSE" )
EndIf

// Copia o arquivo para o server, pois a funcão XMLParserFile só roda no server.
If __CopyFile( cDirRet + cFileXML, "\retNFSE\" + cFileXML ) //CpyT2S( cDirRet + cFileXML, "\retNFSE", .F.)
	
	oXmlParse := XmlParserFile( cArqXML, "_", @cError, @cWarning )
	
	If Empty(cError) .And. Empty(cWarning)
		
		//Valida se tem mensagem de inconsistência de transmissão
		If XMLChildEX( oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA, "_LISTAMENSAGEMRETORNO" ) != Nil
			cMsgErr := "Código: " 	+ oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_LISTAMENSAGEMRETORNO:_NS4_MENSAGEMRETORNO:_NS4_CODIGO:TEXT + Chr(10) + Chr(13)
			cMsgErr += "Mensagem: " + oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_LISTAMENSAGEMRETORNO:_NS4_MENSAGEMRETORNO:_NS4_MENSAGEM:TEXT + Chr(10) + Chr(13)
			cMsgErr += "Correção: " + oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_LISTAMENSAGEMRETORNO:_NS4_MENSAGEMRETORNO:_NS4_CORRECAO:TEXT
		Else
			cNumNFS		:= oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_ListaNFSE:_NS3_COMPNFSE:_NS4_NFSE:_NS4_INFNFSE:_NS4_NUMERO:TEXT
			cCodAut		:= oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_ListaNFSE:_NS3_COMPNFSE:_NS4_NFSE:_NS4_INFNFSE:_NS4_CODIGOVERIFICACAO:TEXT
			cDataRcto	:= oXmlParse:_NS3_CONSULTARLOTERPSRESPOSTA:_NS3_ListaNFSE:_NS3_COMPNFSE:_NS4_NFSE:_NS4_INFNFSE:_NS4_DATAEMISSAO:TEXT
		EndIf
	Else
		MsgAlert( "Erro ao pegar arquivo de retorno de transmissão", "Atenção" )
		lRet := .F.
	EndIf

Else
	MsgAlert( "Erro ao copiar arquivo de retorno para o Server.", "Atenção" )
	lRet := .F.
EndIf

Return( lRet )
