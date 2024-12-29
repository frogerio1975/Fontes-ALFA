#INCLUDE "TOTVS.CH"

/****************************************************************************************/
/*/{Protheus.doc} ITAU
    @description Classe - realiza o registro e alterações dos boletos 
    @author    Wilson A. Silva Jr
    @since     28/06/2022
/*/
/****************************************************************************************/
Class ITAU

    Data cClientID      As String 
    Data cSecret        As String 
    Data cUrlToken      As String 
    Data cUrlApi        As String 
    Data cUrlGet        As String
    Data cToken         As String
    Data cJSon          As String 
    Data cJSonRet       As String
    Data cIdBol         As String 
    Data cPassCert	    As String
	Data cCertPath	    As String
	Data cKeyPath	    As String
	Data cCACertPath	As String
    Data cError         As String
    Data cEmpFat        As String

    Data nSSL2		    As Integer
	Data nSSL3		    As Integer
	Data nTLS1		    As Integer
	Data nHSM		    As Integer
	Data nVerbose	    As Integer
	Data nBugs		    As Integer
	Data nState	        As Integer

    Method New() Constructor 
    Method GetSSLCache()
    Method SetEmpresa()
    Method Token()
    Method Boleto()
    Method GetBoleto()
    Method Baixa()
    Method ValorNominal()
    Method Juros()
    Method Vencimento()
    Method Desconto()
    Method Abatimento()
    Method Multa()
    Method Protesto()
    Method SeuNumero()
    Method DTLimitePagamento()
    Method Negativacao()
    Method Pagador()
    Method RecebDivergente()

EndClass

/****************************************************************************************/
/*/{Protheus.doc} New
    @description Classe construtor
    @author    Wilson A. Silva Jr
    @since     28/06/2022
/*/
/****************************************************************************************/
Method New() Class ITAU

    ::cClientID     := ""
    ::cSecret       := ""
    ::cUrlToken     := "http://localhost:4000"//"https://sts.itau.com.br"
    ::cUrlApi       := "http://localhost:4000"//"https://api.itau.com.br"
    ::cUrlGet       := "http://localhost:4000"//"https://secure.api.cloud.itau.com.br"
    ::cToken        := ""
    ::cJSon         := ""
    ::cJSonRet      := ""
    ::cIdBol        := ""
    ::cPassCert	    := ""
	::cCertPath	    := ""
	::cKeyPath		:= ""
	::cCACertPath	:= ""
    ::cError        := ""

    ::nSSL2		    := 0
	::nSSL3		    := 0
	::nTLS1		    := 3
	::nHSM			:= 0
	::nVerbose		:= 1
	::nBugs		    := 1
	::nState	    := 1

Return Nil 

/****************************************************************************************/
/*/{Protheus.doc} GetSSLCache
    @description Define o uso em memoria da configuração SSL para integrações web
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method GetSSLCache() Class ITAU
Local _lRet 	:= .F.

//-------------------------------------+
// Utiliza configurações SSL via Cache |
//-------------------------------------+
If HTTPSSLClient( ::nSSL2, ::nSSL3, ::nTLS1, ::cPassCert, ::cCertPath, ::cKeyPath, ::nHSM, .F. , ::nVerbose, ::nBugs, ::nState)
	CoNout("<< GETSSLCACHE >> - INICIADO COM SUCESSO.")
	_lRet := .T.
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} SetEmpresa
    @description Realiza a consulta de boletos.
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method SetEmpresa() Class ITAU 

Local _lRet         := .T.
Local cTMP1         := ""
Local cQuery        := ""

cQuery := " SELECT "+ CRLF
cQuery += "     SEE.EE_XIDCLI "+ CRLF
cQuery += "     ,SEE.EE_XSECRET "+ CRLF
cQuery += "     ,SEE.EE_XDIRCER "+ CRLF
cQuery += "     ,SEE.EE_XDIRKEY "+ CRLF
cQuery += " FROM "+RetSqlName("SEE")+" SEE (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SEE.EE_FILIAL = '"+xFilial("SEE")+"' "+ CRLF
cQuery += "     AND SEE.EE_CODIGO = '341' "+ CRLF
cQuery += "     AND SEE.EE_XEMPFAT = '"+::cEmpFat+"' "+ CRLF
cQuery += "     AND SEE.EE_XEMPFAT <> ' ' "+ CRLF
cQuery += "     AND SEE.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    ::cClientID     := (cTMP1)->EE_XIDCLI
    ::cSecret       := (cTMP1)->EE_XSECRET
    ::cCertPath	    := AllTrim((cTMP1)->EE_XDIRCER)
    ::cKeyPath		:= AllTrim((cTMP1)->EE_XDIRKEY)
Else
    ::cError    := "Configuraçao (SEE) da empresa de faturamento não localizada. Empresa: " + ::cEmpFat
    _lRet       := .F.
EndIf

Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GetSSLCache
    @description Método retorna token de acesso as API's 
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method Token() Class ITAU 

Local _aHeadOut     := {}
Local _cParms       := ""
Local _lRet         := .T.
Local _oJSonRet     := Nil 
Local _cPostRet     := ""
Local _cHeadRet     := ""

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
_aHeadOut  := {}
aAdd(_aHeadOut,"x-itau-flowID: 1" )
aAdd(_aHeadOut,"x-itau-correlationID: 2" )
aAdd(_aHeadOut,"codigo-empresa: " + ::cEmpFat)
aAdd(_aHeadOut,"Content-Type: application/x-www-form-urlencoded" )

_cParms += 'grant_type=client_credentials'
_cParms += '&client_id=' + ::cClientID
_cParms += '&client_secret=' + ::cSecret

// _cPostRet := HTTPSPost(::cUrlToken+"/api/oauth/token", ::cCertPath, ::cKeyPath, "", "", _cParms, 600, _aHeadOut, @_cHeadRet)

_cPostRet := HttpPost(::cUrlToken+"/itau/token", "", _cParms, 600, _aHeadOut, @_cHeadRet)

//---------------------+
// Utiliza metodo POST |
//---------------------+
If !Empty(_cPostRet)

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cJSonRet	:= AllTrim(_cPostRet)
    _oJSonRet   := JsonObject():New() 
    _oJSonRet:fromJson(::cJSonRet)
    ::cToken	:= _oJSonRet["access_token"]
  
Else

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cError    := "Erro ao validar token. Error " + _cHeadRet
    _lRet       := .F.
    
EndIf
    
Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Boleto
    @description Realiza o envio do boleto bancario  
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method Boleto() Class ITAU 

Local _aHeadOut     := {}
Local _lRet         := .T.
Local _cPostRet     := ""
Local _cHeadRet     := ""

//---------------+
// Retorna token |
//---------------+
::Token()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
_aHeadOut  := {}
aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"x-itau-apikey: " + ::cClientID)
aAdd(_aHeadOut,"x-itau-correlationID: 1")
aAdd(_aHeadOut,"x-itau-flowID: 2")
aAdd(_aHeadOut,"codigo-empresa: " + ::cEmpFat)
aAdd(_aHeadOut,"Authorization: Bearer " +  ::cToken)

// _cPostRet := HTTPSPost(::cUrlApi+"/cash_management/v2/boletos", ::cCertPath, ::cKeyPath, "", "", ::cJSon, 600, _aHeadOut, @_cHeadRet)

_cPostRet := HttpPost(::cUrlApi+"/itau/registro-boleto", "", ::cJSon, 600, _aHeadOut, @_cHeadRet)

If !Empty(_cPostRet)

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cJSonRet	:= AllTrim(_cPostRet)

Else

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cError    := "Erro ao validar token. Error " + _cHeadRet
    _lRet       := .F.
    
EndIf

Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} GetBoleto
    @description Realiza a consulta de boletos.
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method GetBoleto(cGetParam) Class ITAU 

Local _aHeadOut     := {}
Local _lRet         := .T.
Local _cGetRet      := ""
Local _cHeadRet     := ""

Default cGetParam   := ""

//---------------+
// Retorna token |
//---------------+
::Token()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
_aHeadOut  := {}
aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"x-itau-apikey: " + ::cClientID)
aAdd(_aHeadOut,"x-itau-correlationID: 1")
aAdd(_aHeadOut,"x-itau-flowID: 2")
aAdd(_aHeadOut,"codigo-empresa: " + ::cEmpFat)
aAdd(_aHeadOut,"Authorization: Bearer " +  ::cToken)

// _cGetRet := HTTPSGet(::cUrlGet+"/boletoscash/v2/boletos", ::cCertPath, ::cKeyPath, "", cGetParam, 600, _aHeadOut, @_cHeadRet, .F.)

 _cGetRet := HttpGet(::cUrlGet+"/itau/consulta-boleto", cGetParam, 600, _aHeadOut, @_cHeadRet )

If !Empty(_cGetRet)

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cJSonRet	:= AllTrim(_cGetRet)

Else

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cError    := "Erro ao validar token. Error " + _cHeadRet
    _lRet       := .F.
    
EndIf

Return _lRet

/****************************************************************************************/
/*/{Protheus.doc} Baixa
    @description Realiza a baixa do titulo no banco (cancelamento)
    @author Wilson A. Silva Jr
    @since 28/06/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method Baixa() Class ITAU 

Local _aHeadOut     := {}
Local _lRet         := .T.
Local _cPostRet     := ""
Local _cHeadRet     := ""
Local _oJSon        := JsonObject():New()
Local _cJSon        := ""

// Local _cResponse    := ""
// Local _cHeaderRet   := ""
// Local _cHttpMsg     := ""

// Local _nStatus      := 0

//---------------+
// Retorna token |
//---------------+
::Token()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
_aHeadOut  := {}
aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"x-itau-apikey: " + ::cClientID)
aAdd(_aHeadOut,"x-itau-correlationID: 1")
aAdd(_aHeadOut,"x-itau-flowID: 2")
aAdd(_aHeadOut,"codigo-empresa: " + ::cEmpFat)
aAdd(_aHeadOut,"Authorization: Bearer " +  ::cToken)

// _cResponse := HTTPQuote( ::cUrlApi + "/cash_management/v2/boletos/" + ::cIdBol + "/baixa", "PATCH", Nil, "{}", 600, _aHeadOut, @_cHeaderRet )

// _nStatus := HTTPGetStatus(@_cHttpMsg) 

// If _nStatus == 200 .Or. _nStatus == admin204
//     _lRet := .T.
// Else 
//     _lRet   := .F.
//     ::cError:= _cHttpMsg
// EndIf

_oJSon["idBoleto"] := ::cIdBol

_cJSon := _oJSon:toJSON()

_cPostRet := HttpPost(::cUrlApi+"/itau/baixa-boleto", "", _cJSon, 600, _aHeadOut, @_cHeadRet)

If !Empty(_cPostRet)

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cJSonRet	:= AllTrim(_cPostRet)

Else

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cError    := "Erro ao validar token. Error " + _cHeadRet
    _lRet       := .F.
    
EndIf

Return _lRet 

/****************************************************************************************/
/*/{Protheus.doc} Vencimento
    @description Realiza a alteração da data de vencimento do boleto. (Prorrogação)
    @author Wilson A. Silva Jr
    @since 09/09/2022
    @version 1.0
    @type function
/*/
/****************************************************************************************/
Method Vencimento(_dNewVencto) Class ITAU 

Local _aHeadOut     := {}
Local _lRet         := .T.
Local _cPostRet     := ""
Local _cHeadRet     := ""
Local _oJSon        := JsonObject():New()
Local _cJSon        := ""

// Local _cResponse    := ""
// Local _cHeaderRet   := ""
// Local _cHttpMsg     := ""
// Local _cJSon        := ""

// Local _nStatus      := 0

//---------------+
// Retorna token |
//---------------+
::Token()

//----------------------------------------+
// Array contendo parametros de cabeçalho |
//----------------------------------------+
_aHeadOut  := {}
aAdd(_aHeadOut,"Content-Type: application/json" )
aAdd(_aHeadOut,"x-itau-apikey: " + ::cClientID)
aAdd(_aHeadOut,"x-itau-correlationID: 1")
aAdd(_aHeadOut,"x-itau-flowID: 2")
aAdd(_aHeadOut,"codigo-empresa: " + ::cEmpFat)
aAdd(_aHeadOut,"Authorization: Bearer " +  ::cToken)

// _oJSon := JsonObject():New()
// _oJSon["data_vencimento"] := SubStr(FwTimeStamp(3,_dNewVencto),1,10)

// _cJSon := _oJSon:toJSON()

// _cResponse := HTTPQuote( ::cUrlApi + "/cash_management/v2/boletos/" + ::cIdBol + "/data_vencimento", "PATCH", Nil, _cJSon, 600, _aHeadOut, @_cHeaderRet )

// _nStatus := HTTPGetStatus(@_cHttpMsg) 

// If _nStatus == 200 .Or. _nStatus == 204
//     _lRet := .T.
// Else 
//     _lRet   := .F.
//     ::cError:= _cHttpMsg
// EndIf 

_oJSon["idBoleto"] := ::cIdBol
_oJSon["dataVencimento"] := SubStr(FwTimeStamp(3,_dNewVencto),1,10)

_cJSon := _oJSon:toJSON()

_cPostRet := HttpPost(::cUrlApi+"/itau/vencimento-boleto", "", _cJSon, 600, _aHeadOut, @_cHeadRet)

If !Empty(_cPostRet)

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cJSonRet	:= AllTrim(_cPostRet)

Else

    //---------------------+
    // Desesserializa JSON |
    //---------------------+
    ::cError    := "Erro ao validar token. Error " + _cHeadRet
    _lRet       := .F.
    
EndIf

Return _lRet 
