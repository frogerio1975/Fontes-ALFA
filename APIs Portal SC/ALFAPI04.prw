#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} API - ALFAPI04
Consulta de Clientes
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSRESTFUL ALFAPI04 DESCRIPTION "Servico Alfa - Clientes"
    WSDATA FILTER 

	WSMETHOD GET   DESCRIPTION "Pesquisa de Clientes"  PATH "/ALFAPI04"

END WSRESTFUL

/*/{Protheus.doc} API - GET
Consulta de Produtos
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSMETHOD GET WSRECEIVE FILTER WSSERVICE ALFAPI04

Local oResponse := JSONObject():New()
Local cNextAlias:= GetNextAlias()
Local lRet      := .T.
Local nPos      := 0
Local cFilter   := self:FILTER
Local cLike     := ""

If cFilter <> Nil .And. !Empty(cFilter)
    cLike := " A1_NREDUZ LIKE '%" + Upper(cFilter) + "%' "
Else
    cLike := "A1_NREDUZ <> '' "
EndIf

cLike := "%" + cLike + "%"

u_ASOpenEnv("01", "01")

BeginSQL Alias cNextAlias
    SELECT A1_NREDUZ FROM %table:SA1%
    WHERE A1_MSBLQL = '2'
    AND %exp:cLike%
    AND %notdel%
EndSQL

oResponse['items'] := {}

While (cNextAlias)->( !Eof() )
    nPos++
    aAdd( oResponse['items'], JSONObject():New() )

    oResponse['items'][nPos]["label"] := AllTrim((cNextAlias)->A1_NREDUZ)
    oResponse['items'][nPos]["value"] := AllTrim((cNextAlias)->A1_NREDUZ)

    (cNextAlias)->( dbSkip() )
EndDo

self:SetResponse( EncodeUTF8(oResponse:ToJSON() ) )

Return(lRet)
