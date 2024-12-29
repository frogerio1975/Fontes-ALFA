#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

Static cDirPai  := "\logPortal"
Static cDirFor  := "\fornecedor"

/*/{Protheus.doc} API - ALFAPI01
Inclusão de Fornecedor
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSRESTFUL ALFAPI01 DESCRIPTION "Servico Alfa - Fornecedores"

	WSMETHOD POST   DESCRIPTION "Efetua a inclusão de um Fornecedor"  PATH "/ALFAPI01"

END WSRESTFUL

/*/{Protheus.doc} API - POST
Realiza a inclusao de um novo fornecedor
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSMETHOD POST WSSERVICE ALFAPI01

Local cContent  := self:GetContent()
Local oRequest  := JSONObject():New()
Local oResponse := JSONObject():New()
Local aMata020  := {}
Local cErro     := ""
Local cCGC      := ""
Local cCodForn  := ""
Local lRet      := .T.

oRequest:FromJSON( DecodeUTF8( cContent ) )

u_ASOpenEnv("01", "01")

If !ExistDir(cDirPai); MakeDir(cDirPai); EndIf
If !ExistDir(cDirPai + cDirFor); MakeDir(cDirPai + cDirFor); EndIf

DbSelectArea("SA2")
SA2->( DbSetOrder(3) )

cCGC := PadR(oRequest["registrationNumber"], TamSX3("A2_CGC")[1])

If SA2->( !MsSeek( xFilial("SA2") + cCGC ) )
    aAdd(aMata020, {"A2_FILIAL"	    , xFilial("SA1", "01")			    , "AllwaysTrue()"} )				 
    //aAdd(aMata020, {"A2_COD"		, cCodSA1			                , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_LOJA"		, "01"						        , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_TIPO"		, oRequest["type"]	                , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_CGC"		, oRequest["registrationNumber"]    , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_NOME"		, Upper(oRequest["socialName"])	    , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_NREDUZ"	    , Upper(oRequest["tradeName"])      , "AllwaysTrue()"} )	
    aAdd(aMata020, {"A2_CEP"		, oRequest["zipCode"]               , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_END"		, Upper(oRequest["street"])	        , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_BAIRRO"	    , Upper(oRequest["neighborhood"])	, "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_PESSOA"	    , Upper(oRequest["person"])	        , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_EST"		, Upper(oRequest["state"])	        , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_MUN"		, Upper(oRequest["city"])	        , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_CONTATO"	, oRequest["contact"]               , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_TEL"		, oRequest["phone"]	                , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_EMAIL"		, oRequest["mail"]	                , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_SOFTWAR"	, oRequest["software"]              , "AllwaysTrue()"} )
    aAdd(aMata020, {"A2_LICSRV"	    , oRequest["providertype"]          , "AllwaysTrue()"} )

    lMsErroAuto:=.F.

    MSExecAuto({|x,y|Mata020(x,y)},aMata020,3)

    If lMsErroAuto
        cErro := MostraErro(cDirPai + cDirFor, cCGC + " - " + DTOS( Date() ) + " - " + Time() + ".log")
        lRet := .F.
        SetRestFault(400, EncodeUTF8(cErro), .T.)
        Return .F.
    Else
        cCodForn := SA2->A2_COD
        ConfirmSx8()
    Endif
Else
    cCodForn := SA2->A2_COD
EndIf

oResponse['success'] := .T.
oResponse['providerId'] := cCodForn
self:SetResponse( EncodeUTF8(oResponse:ToJSON() ) )

Return(lRet)
