#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} API - ALFAPI05
Consulta de Addons
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSRESTFUL ALFAPI05 DESCRIPTION "Servico Alfa - Clientes"
    WSDATA FILTER 

	WSMETHOD GET   DESCRIPTION "Pesquisa de Clientes"  PATH "/ALFAPI05"

END WSRESTFUL

/*/{Protheus.doc} API - GET
Consulta de Produtos
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSMETHOD GET WSRECEIVE FILTER WSSERVICE ALFAPI05

Local oResponse := JSONObject():New()
Local cNextAlias:= GetNextAlias()
Local lRet      := .T.
Local nPos      := 0
Local cFilter   := self:FILTER
Local cLike     := ""

If cFilter <> Nil .And. !Empty(cFilter)
    cLike := " UPPER(Z00_DESCRI) LIKE '%" + Upper(cFilter) + "%' "
Else
    cLike := " Z00_DESCRI <> '' "
EndIf

cLike := "%" + cLike + "%"

u_ASOpenEnv("01", "01")

BeginSQL Alias cNextAlias
    SELECT Z00_DESCRI FROM %table:Z00%
    WHERE %exp:cLike%
    AND %notdel%
EndSQL

oResponse['items'] := {}

While (cNextAlias)->( !Eof() )
    nPos++
    aAdd( oResponse['items'], JSONObject():New() )

    oResponse['items'][nPos]["label"] := LEFT( AllTrim((cNextAlias)->Z00_DESCRI), 250)
    oResponse['items'][nPos]["value"] := LEFT( AllTrim((cNextAlias)->Z00_DESCRI), 250)

    (cNextAlias)->( dbSkip() )
EndDo

self:SetResponse( EncodeUTF8(oResponse:ToJSON() ) )

Return(lRet)
