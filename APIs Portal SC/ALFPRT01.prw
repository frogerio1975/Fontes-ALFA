#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ALFPRT01
Envia Clientes para o Portal
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
User Function ALFPRT01(cCNPJ)

Local cURL          := "http://127.0.0.1:5000"
Local cPath         := "/api/v1/provider/createByErp"
Local oRequest      := Nil
Local oRestClient   := Nil
Local cNextAlias    := ""
Local lRet          := .T.
Local aHeader       := {}
Local cToken        := ""
Local cLike         := ""

Default cCNPJ       := ""

//u_ASOpenEnv("01", "01")

cToken      := GetToken()
oRequest    := JSONObject():New()
oRestClient := FWRest():New(cUrl)
cNextAlias  := GetNextAlias()

aAdd(aHeader, "Content-Type: application/json")
aAdd(aHeader, "Authorization: Bearer " + cToken)

If !Empty(cCNPJ)
    cLike := "% A2_CGC = '" + cCNPJ + "' %"
Else
    cLike := "% A2_CGC <> '' %"
EndIf

BeginSQL Alias cNextAlias
    SELECT * FROM %table:SA2%
    WHERE A2_MSBLQL = '2'
    AND %exp:cLike%
    AND %notdel%
EndSQL

While (cNextAlias)->( !Eof() )
    oRequest := JSONObject():New()    

    oRequest["person"] := AllTrim( (cNextAlias)->A2_TIPO)
    oRequest["type"] := AllTrim( (cNextAlias)->A2_TIPO)
    oRequest["fiscalCodeProvider"] := AllTrim( (cNextAlias)->A2_CGC)
    oRequest["providerName"] := AllTrim( (cNextAlias)->A2_NOME)
    oRequest["fantasyName"] := AllTrim( (cNextAlias)->A2_NREDUZ)
    oRequest["zipCode"] := AllTrim( (cNextAlias)->A2_CEP)
    oRequest["addressProvider"] := AllTrim( (cNextAlias)->A2_END)
    oRequest["neighborhood"] := AllTrim( (cNextAlias)->A2_BAIRRO)
    oRequest["state"] := AllTrim( (cNextAlias)->A2_EST)
    oRequest["city"] := AllTrim( (cNextAlias)->A2_MUN)
    oRequest["contact"] := AllTrim( (cNextAlias)->A2_CONTATO)
    oRequest["phoneProvider"] := AllTrim( (cNextAlias)->A2_TEL)
    oRequest["mailProvider"] := AllTrim( (cNextAlias)->A2_EMAIL)
    oRequest["software"] := AllTrim( (cNextAlias)->A2_SOFTWAR)
    oRequest["providertype"] := AllTrim( (cNextAlias)->A2_LICSRV)

    oRestClient:SetPath(cPath)
    oRestClient:SetPostParams( EncodeUTF8(oRequest:ToJSON() ) )

    If oRestClient:Post(aHeader)
        ConOut("Deu certo")
    Else
        ConOut("Deu ruim: " + oRestClient:GetLastError())
    EndIf

    oRequest := Nil

    (cNextAlias)->( dbSkip() )
EndDo

Return(lRet)


Static Function GetToken()

Local cURL      := "http://127.0.0.1:8006"
Local cPath     := "/api/v1/auth/login"
Local cNewToken := ""
Local cResult   := ""
Local oReqAuth  := JSONObject():New()
Local oRespAuth := JSONObject():New()
Local oRestAuth := FWRest():New(cUrl)
Local aHeader   := {}

aAdd(aHeader, "Content-Type: application/json")

oReqAuth["login"]    := "integracao@alfaerp.com.br"
oReqAuth["password"] := "alfa@erp2022"

oRestAuth:SetPath(cPath)
oRestAuth:SetPostParams( EncodeUTF8(oReqAuth:ToJSON() ) )

If oRestAuth:Post(aHeader)
    cResult     := oRestAuth:GetResult()
    
    If oRespAuth:FromJSON(DecodeUTF8(cResult) ) == Nil
        cNewToken   := oRespAuth["data"]["token"]
    EndIF
Else
    ConOut("Deu ruim: " + oRestAuth:GetLastError())
EndIf

Return cNewToken
