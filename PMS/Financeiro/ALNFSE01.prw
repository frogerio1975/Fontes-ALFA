#Include 'fileio.ch'
#Include 'protheus.ch'

#Define CRLF Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} ALNFSE01
Nota Fiscal de Serviços do Munícipio de São Caetano do Sul.
Desenvolvido esse específico, pois no processo atual da empresa não há a possibilidade de usar o TSS.
@author  Victor Andrade
@since   02/01/2018
@version 1
/*/
//-------------------------------------------------------------------

User Function ALNFSE01()

Local lRet		:= .F.

Private cDirEnv := ""
Private cDirRet := ""
Private cCnpj   := ""

// --> E1_XSTNFS = "" -> Nota não transmitida
// --> E1_XSTNFS = 1  -> Nota transmitida, porém sem retorno
// --> E1_XSTNFS = 2  -> Nota transmitida, porém retorno com inconsistência
// --> E1_XSTNFS = 3  -> Nota transmitida, porém pendente autorização

If AllTrim( DTOS( SE1->E1_BAIXA ) ) <> ""
	MsgAlert( "Título já sofreu movimentação.", "Atenção" )
ElseIf Empty( SE1->E1_EMPFAT )
	MsgAlert( "Empresa de faturamento não informada.", "Atenção" )
ElseIf !( SE1->E1_XSTNFS $ " |1|2" )
	MsgAlert( "Não há dados à serem enviados. Veja o campo: E1_XSTNFS", "Atenção" )
Else
	
	cDirEnv := GetMV( "FS_DIRENV" + SE1->E1_EMPFAT )
	cDirRet := GetMV( "FS_DIRRET" + SE1->E1_EMPFAT )
	cCnpj   := GetMV( "FS_CNPJ"   + SE1->E1_EMPFAT )

	If MsgYesNo( "Deseja efetuar a transmissão desta NFS-e para: " +Alltrim(SE1->E1_NOMCLI)+ "?" )
        FWMsgRun( , {|| lRet := AL01Proc( SE1->( Recno() ) ) }, "Aguarde", "Realizando Transmissão da NSF-e: " + Alltrim(SE1->E1_NOMCLI) )
    EndIf

	IF lRet 
		U_ALNFSE02()
	EndIF

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Proc
Encapsula as chamadas das funções de geração do XML e Transmissão
@author  Victor Andrade
@since   02/01/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL01Proc( nRecnoSE1 )

Local aArea 	:= GetArea()
Local cXML  	:= ""
Local cLoteRps	:= ""
Local lRet		:= .F.

// Garante que esteja posicionado no registro
SE1->( DbGoTo( nRecnoSE1 ) )

// Gera o XML de acordo com o SE1 posicionado
cXML := AL01Xml( @cLoteRps )

If !Empty( cXML )
			
	// --> Efetua a cópia para o diretório do Uninfes
	If AL01Copy( cXML, cLoteRps )

		// Incrementa o lote
		PutMV( "FS_LOTERPS", Soma1( cLoteRps ) )

		// --> Atualiza para o status de transmitida
		RecLock("SE1", .F.)
		SE1->E1_XSTNFS  := "1"
        SE1->E1_XPRTNFS := ""
        SE1->E1_XDTREC  := ""
        SE1->E1_XMSGNFS := ""
        SE1->E1_XLTNFS  := ""
		SE1->( MsUnlock() )

		// Pega o retorno do processamento do Uninfe
		lRet := AL01Ret( cLoteRps )

	Else
		MsgAlert( "Erro ao gerar arquivo XML para integração.", "Atenção" )
	EndIf

EndIf

RestArea( aArea )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Xml
Efetua a geração do XML e retorna em uma string os dados
@author  Victor Andrade
@since   02/01/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL01Xml( cLoteRps )

Local lRet      := .F. 
Local aArea     := GetArea()
Local cIdentRPS := StrZero(Val(Right(SE1->E1_NUM,6)),6) + AL01Parc( AllTrim(SE1->E1_PARCELA) ) + StrTran(Left(Time(),5),':','')
Local cString   := ""
Local cInscM    := GetMV( "FS_INSCM" + SE1->E1_EMPFAT )
Local aContCb	:= Separa( ';;'+GetSX3Cache( "E1_XTPSRV", "X3_CBOX" ), ";" ) 
Local cCodSrv	:= ""
Local cCodTrb	:= ""
Local cMensagem	:= ""

cLoteRps := GetMV("FS_LOTERPS")

If !Empty( SE1->E1_XTPSRV )
	cCodSrv := AllTrim( SubStr( aContCB[ Val( SE1->E1_XTPSRV ) ], 3, 4 ) )
	cCodTrb	:= AllTrim( SubStr( aContCB[ Val( SE1->E1_XTPSRV ) ], 8 ) )
Else
	cCodSrv := "1.01"
	cCodTrb	:= "3360300"
EndIf

SA1->( DbSetOrder(1) )
If SA1->( DbSeek( xFilial("SA1") + SE1->( E1_CLIENTE + E1_LOJA ) ) )

    cString += '<EnviarLoteRpsEnvio xmlns="http://www.ginfes.com.br/servico_enviar_lote_rps_envio_v03.xsd">'
    cString += '<LoteRps Id="_' + cLoteRps + '" xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd" >'
	cString += '<tipos:NumeroLote>' + cLoteRps + '</tipos:NumeroLote>'
    cString += '<tipos:Cnpj>' + AllTrim( cCnpj ) + '</tipos:Cnpj>'
    cString += '<tipos:InscricaoMunicipal>' + AllTrim( cInscM ) + '</tipos:InscricaoMunicipal>'
    cString += '<tipos:QuantidadeRps>1</tipos:QuantidadeRps>'
    cString += '<tipos:ListaRps>'
    cString += '<tipos:Rps>'
    cString += '<tipos:InfRps>'
    cString += '<tipos:IdentificacaoRps>'
    cString += '<tipos:Numero>' + cIdentRPS + '</tipos:Numero>'
    cString += '<tipos:Serie>' + SE1->E1_PREFIXO + '</tipos:Serie>'
    cString += '<tipos:Tipo>1</tipos:Tipo>'
    cString += '</tipos:IdentificacaoRps>'
    cString += '<tipos:DataEmissao>' + FWTimeStamp( 3, dDataBase, )  + '</tipos:DataEmissao>'
    cString += '<tipos:NaturezaOperacao>1</tipos:NaturezaOperacao>'
    cString += '<tipos:OptanteSimplesNacional>2</tipos:OptanteSimplesNacional>'
    cString += '<tipos:IncentivadorCultural>2</tipos:IncentivadorCultural>'
    cString += '<tipos:Status>1</tipos:Status>'
    cString += '<tipos:Servico>'
    cString += '<tipos:Valores>
    cString += '<tipos:ValorServicos>' 	+ AllTrim( Str( SE1->E1_VALOR,, 2 ) ) + '</tipos:ValorServicos>'
    cString += '<tipos:ValorDeducoes>0.00</tipos:ValorDeducoes>'
    cString += '<tipos:ValorPis>' 		+ AllTrim( Str( SE1->E1_PIS,, 2 ) ) 	+ '</tipos:ValorPis>'
    cString += '<tipos:ValorCofins>' 	+ AllTrim( Str( SE1->E1_COFINS,, 2 ) ) 	+ '</tipos:ValorCofins>'
    cString += '<tipos:ValorInss>' 		+ AllTrim( Str( SE1->E1_INSS,, 2 ) ) 	+ '</tipos:ValorInss>'
    cString += '<tipos:ValorIr>' 		+ AllTrim( Str( SE1->E1_IRRF,, 2 ) ) 	+ '</tipos:ValorIr>'
    cString += '<tipos:ValorCsll>' 		+ AllTrim( Str( SE1->E1_CSLL,, 2 ) ) 	+ '</tipos:ValorCsll>'

    If SE1->E1_EMPFAT == "2"
        cString += '<tipos:IssRetido>2</tipos:IssRetido>'
        cString += '<tipos:Aliquota>0.0200</tipos:Aliquota>'
        cString += '<tipos:ValorLiquidoNfse>' + AllTrim(Str( SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA),,2 ) ) + '</tipos:ValorLiquidoNfse>'
    Else
        If SA1->A1_RECISS == "1"
            cString += '<tipos:IssRetido>1</tipos:IssRetido>'
            cString += '<tipos:ValorIssRetido>' + AllTrim( Str( SE1->E1_ISS,, 2 ) ) + '</tipos:ValorIssRetido>'
            cString += '<tipos:ValorLiquidoNfse>' + AllTrim(Str( SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA),,2 ) ) + '</tipos:ValorLiquidoNfse>'
        Else
            cString += '<tipos:IssRetido>2</tipos:IssRetido>'
            cString += '<tipos:ValorIssRetido>0.00</tipos:ValorIssRetido>'
            cString += '<tipos:ValorLiquidoNfse>' + AllTrim(Str( SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA),,2 ) ) + '</tipos:ValorLiquidoNfse>'
        EndIf
    EndIf

//<<<<<<< .mine
//=======
//    cString += '<tipos:ValorIssRetido>0.00</tipos:ValorIssRetido>'
//    cString += '<tipos:ValorLiquidoNfse>' + AllTrim( Str( SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA) ),,2 ) + '</tipos:ValorLiquidoNfse>'
//>>>>>>> .r297
    cString += '</tipos:Valores>'
    cString += '<tipos:ItemListaServico>' + cCodSrv + '</tipos:ItemListaServico>'
  	//cString += '<tipos:CodigoCnae>0000000</tipos:CodigoCnae>'
    cString += '<tipos:CodigoTributacaoMunicipio>' + cCodTrb + '</tipos:CodigoTributacaoMunicipio>'

	IF !Empty(SE1->E1_MSGNF)
		cMensagem := Alltrim(SE1->E1_MSGNF)
	EndIF

    cString += '<tipos:Discriminacao>' + AllTrim( cMensagem ) + '</tipos:Discriminacao>'
    cString += '<tipos:CodigoMunicipio>' + AL01CodUF( SA1->A1_EST ) + AllTrim(SA1->A1_COD_MUN) + '</tipos:CodigoMunicipio>'
    cString += '</tipos:Servico>'
    cString += '<tipos:Prestador>'
    cString += '<tipos:Cnpj>' + AllTrim( cCnpj ) + '</tipos:Cnpj>'
	cString += '<tipos:InscricaoMunicipal>' + AllTrim( cInscM ) + '</tipos:InscricaoMunicipal>'
    cString += '</tipos:Prestador>'
    cString += '<tipos:Tomador>'
    cString += '<tipos:IdentificacaoTomador>'
    cString += '<tipos:CpfCnpj>'
    cString += '<tipos:Cnpj>' + AllTrim( SA1->A1_CGC ) + '</tipos:Cnpj>'
    cString += '</tipos:CpfCnpj>'
    cString += '<tipos:InscricaoMunicipal>' + IIf(Empty(SA1->A1_INSCRM),"0",AllTrim( SA1->A1_INSCRM )) + '</tipos:InscricaoMunicipal>'
    cString += '</tipos:IdentificacaoTomador>'
    cString += '<tipos:RazaoSocial>' + AllTrim( SA1->A1_NOME ) + '</tipos:RazaoSocial>'
    cString += '<tipos:Endereco>'
    cString += '<tipos:Endereco>' + AllTrim( SA1->A1_END ) + '</tipos:Endereco>'
    cString += '<tipos:Numero>' + "999" + '</tipos:Numero>'
    cString += '<tipos:Bairro>' + AllTrim( SA1->A1_BAIRRO ) + '</tipos:Bairro>'
    cString += '<tipos:CodigoMunicipio>' + AL01CodUF( SA1->A1_EST ) + AllTrim(SA1->A1_COD_MUN) + '</tipos:CodigoMunicipio>'
    cString += '<tipos:Uf>' + AllTrim(SA1->A1_EST) + '</tipos:Uf>'
	cString += '<tipos:Cep>' + AllTrim(SA1->A1_CEP) + '</tipos:Cep>'
    cString += '</tipos:Endereco>'
    cString += '</tipos:Tomador>'
    cString += '</tipos:InfRps>'
    cString += '</tipos:Rps>'
    cString += '</tipos:ListaRps>'
    cString += '</LoteRps>'
    cString += '</EnviarLoteRpsEnvio>'

EndIf

RestArea( aArea )

Return( cString )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Copy
Disponibiliza o XML na pasta do Uninfe para que o mesmo possa ser transmitido para a prefeitura
@author  Victor Andrade
@since   24/01/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL01Copy( cXML, cNumLote )

Local lRet		 := .F.
Local cFile		 := AllTrim( cCnpj ) + cNumLote + "-env-loterps.xml"

lRet := MemoWrite( cDirEnv + cFile, cXML )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Ret
Aguarda por alguns segundos o processamento do Uninfes e pega o retorno.
Se passar 10 segundos e não tiver retorno, é sinal que o Uninfes está fora do ar.
@author  Victor Andrade
@since   22/03/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL01Ret( cNumLote, cDataRcto, cProtocolo )

Local cFileEnv		:= AllTrim( cCnpj ) + cNumLote + "-env-loterps.xml"
Local cFileRet		:= AllTrim( cCnpj ) + cNumLote + "-ret-loterps.xml"
Local cFileErr		:= AllTrim( cCnpj ) + cNumLote + "-env-loterps.err"
Local nRepet 		:= 0
Local nTentativas 	:= 0
Local lRet			:= .F.
Local cErrRet   	:= ""

While File( cDirEnv + cFileEnv ) .And. nRepet <= 10
	nRepet ++
	Sleep(1000) //Milissegundos (1 segundo)
End

// Se em 10 segundos, o arquivo ainda está na pasta de "Envio"
// Então o Uninfes está fora do Ar
If File( cDirEnv + cFileEnv )

	MsgAlert( "Erro ao comunicar-se com a plataforma Uninfes." + Chr(10) + Chr(13) + ; 
			  "Verifica se a mesma está no ar." )

Else
    
    // Aguarda até que os arquivos de retorno sejam gerados!!!
    While ( !File( cDirRet + cFileRet ) .Or. !File( cDirRet + cFileErr ) ) .And. nTentativas <= 5

		nTentativas++

        // Aguarda 5 segundos e verifica novamente
        Sleep(5000)

        If File( cDirRet + cFileRet )
            
            If AL01Parse( cFileRet, @cDataRcto, @cProtocolo, @cErrRet )
                
                RecLock("SE1", .F. )
                SE1->E1_XSTNFS  := "3"
                SE1->E1_XPRTNFS := cProtocolo
                SE1->E1_XDTREC	:= cDataRcto
                SE1->E1_XMSGNFS := cErrRet
                SE1->E1_XLTNFS  := cNumLote
                SE1->( MsUnlock() )
				
				lRet := .T.

                Exit

            EndIf
            
        ElseIf File( cDirRet + cFileErr )
            
            cErrRet := Al01ReadErr( cDirRet + cFileErr )
			
			MsgAlert( "Erro na estrutura do arquivo de envio: " + cErrRet )

            RecLock("SE1", .F. )
            SE1->E1_XSTNFS  := ""
            SE1->E1_XMSGNFS := cErrRet
            SE1->( MsUnlock() )

            Exit
            
        EndIf

    EndDo

EndIf

IF nTentativas >= 5
	MsgAlert( "Não foi possivel obter retorno apos " + StrZero(nTentativas,2) + "Tentativas." )
EndIF

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Parse
Faz o parse do XML de retorno para pegar informações de protocolo e data de recebimento
@author  Victor Andrade
@since   22/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL01Parse( cFileXML, cDataRcto, cProtocolo, cMsgErr )

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
		cDataRcto	:= oXmlParse:_NS3_ENVIARLOTERPSRESPOSTA:_NS3_DATARECEBIMENTO:Text
		cProtocolo	:= oXmlParse:_NS3_ENVIARLOTERPSRESPOSTA:_NS3_PROTOCOLO:Text
	Else
		MsgAlert( "Erro ao pegar arquivo de retorno de transmissão" )
		lRet := .F.
	EndIf

Else
	MsgAlert( "Erro ao copiar arquivo de retorno para o Server." )
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01CodUF
Retorna o código da Unidade Federativa
@author  Victor Andrade
@since   28/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL01CodUF( cUF )

Local aUF := {}

aAdd( aUf, {"11", "RO" } )
aAdd( aUf, {"12", "AC" } )
aAdd( aUf, {"13", "AM" } )
aAdd( aUf, {"14", "RR" } )
aAdd( aUf, {"15", "PA" } )
aAdd( aUf, {"16", "AP" } )
aAdd( aUf, {"17", "TO" } )
aAdd( aUf, {"21", "MA" } )
aAdd( aUf, {"22", "PI" } )
aAdd( aUf, {"23", "CE" } )
aAdd( aUf, {"24", "RN" } )
aAdd( aUf, {"25", "PB" } )
aAdd( aUf, {"26", "PE" } )
aAdd( aUf, {"27", "AL" } )
aAdd( aUf, {"28", "SE" } )
aAdd( aUf, {"29", "BA" } )
aAdd( aUf, {"31", "MG" } )
aAdd( aUf, {"32", "ES" } )
aAdd( aUf, {"33", "RJ" } )
aAdd( aUf, {"35", "SP" } )
aAdd( aUf, {"41", "PR" } )
aAdd( aUf, {"42", "SC" } )
aAdd( aUf, {"43", "RS" } )
aAdd( aUf, {"50", "MS" } )
aAdd( aUf, {"51", "MT" } )
aAdd( aUf, {"52", "GO" } )
aAdd( aUf, {"53", "DF" } )

Return( aUf[ aScan( aUf, {|x| x[2] == cUf  } )][1] )

//-------------------------------------------------------------------
/*/{Protheus.doc} AL01Parc
Retorna a parcela tratada caso tenha letras
@author  Victor Andrade
@since   28/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function AL01Parc( cParcela )

Local cNewParc := cParcela

If IsAlpha( cParcela )
    Do Case
        Case cParcela == "A"
            cNewParc := "001"
        Case cParcela == "B"
            cNewParc := "002"
        Case cParcela == "C"
            cNewParc := "003"
        Case cParcela == "D"
            cNewParc := "004"
        Case cParcela == "E"
            cNewParc := "005"
        Case cParcela == "F"
            cNewParc := "006"
        Case cParcela == "G"
            cNewParc := "007"
        Case cParcela == "H"
            cNewParc := "008"
        Case cParcela == "I"
            cNewParc := "009"
        Case cParcela == "J"
            cNewParc := "010"
        Case cParcela == "L"
            cNewParc := "011"
        Case cParcela == "M"
            cNewParc := "012"
        Case cParcela == "N"
            cNewParc := "013"
        Case cParcela == "O"
            cNewParc := "014"
    EndCase
EndIf

Return( cNewParc )

//-------------------------------------------------------------------
/*/{Protheus.doc} Al01ReadErr
Efetua a leitura do arquivo de erro e armazena em um string
@author  Victor Andrade
@since   28/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function Al01ReadErr( cFileErr )

Local nHandle   := FT_FUse( cFileErr )
Local cLineRet  := ""
Local cLineRead := ""

If nHandle <> - 1

    FT_FGOTop()

    While !FT_FEof()
        
        cLineRead := AllTrim( FT_FReadLn() )

        If !Empty( cLineRead )
            
            If ( ( "FINAL DA VALIDAÇÃO" $ Upper(cLineRead) ) )
                Exit    
            EndIf

            cLineRet += cLineRead + Chr(10) + Chr(13)
        EndIf

        FT_FSkip()

    EndDo
    
    FT_FUse()

EndIf

Return( cLineRet )
