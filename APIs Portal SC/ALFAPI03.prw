#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} API - ALFAPI03
Consulta de Vendedores
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSRESTFUL ALFAPI03 DESCRIPTION "Servico Alfa - Vendedores"
    WSDATA FILTER

	WSMETHOD GET   DESCRIPTION "Pesquisa de Produtos"  PATH "/ALFAPI03"

END WSRESTFUL

/*/{Protheus.doc} API - GET
Consulta de Produtos
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSMETHOD GET WSRECEIVE FILTER WSSERVICE ALFAPI03

Local oResponse := JSONObject():New()
Local cNextAlias:= GetNextAlias()
Local lRet      := .T.
Local nPos      := 0
Local cFilter   := self:FILTER
Local cLike     := ""

If cFilter <> Nil .And. !Empty(cFilter)
    cLike := " A3_NOME LIKE '%" + Upper(cFilter) + "%' "
Else
    cLike := " A3_NOME <> '' "
EndIf

cLike := "%" + cLike + "%"

u_ASOpenEnv("01", "01")

BeginSQL Alias cNextAlias
    SELECT A3_NOME FROM %table:SA3%
    WHERE A3_MSBLQL = '2'
    AND %exp:cLike%
    AND %notdel%
EndSQL

oResponse['items'] := {}

While (cNextAlias)->( !Eof() )
    nPos++
    aAdd( oResponse['items'], JSONObject():New() )

    oResponse['items'][nPos]["label"] := AllTrim((cNextAlias)->A3_NOME)
    oResponse['items'][nPos]["value"] := AllTrim((cNextAlias)->A3_NOME)

    (cNextAlias)->( dbSkip() )
EndDo

self:SetResponse( EncodeUTF8(oResponse:ToJSON() ) )

Return(lRet)
