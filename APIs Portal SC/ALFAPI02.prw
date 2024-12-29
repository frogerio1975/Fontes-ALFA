#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

Static cDirPai  := "\logPortal"
Static cDirPag  := "\contaspagar"

/*/{Protheus.doc} API - ALFAPI02
Inclusão de Fornecedor
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
WSRESTFUL ALFAPI02 DESCRIPTION "Servico Alfa - Contas a Pagar"

	WSMETHOD POST   DESCRIPTION "Efetua a Inclusão de um Título a Pagar"  PATH "/ALFAPI02"

END WSRESTFUL

/*/{Protheus.doc} API - POST
Realiza a inclusao de um Título a Pagar
@author Victor A. Barbosa
@since 16/02/2021
@version 1
/*/
WSMETHOD POST WSSERVICE ALFAPI02

Local cContent  := self:GetContent()
Local oRequest  := JSONObject():New()
Local oResponse := JSONObject():New()
Local aFina050  := {}
Local cErro     := ""
Local lRet      := .T.
Local nParcela  := 0
Local nValor    := 0
Local cIdSC     := ""
Local cNumSE2   := ""
Local cPrfSE2   := "MAN"

oRequest:FromJSON( DecodeUTF8( cContent ) )

u_ASOpenEnv("01", "01")

If !ExistDir(cDirPai); MakeDir(cDirPai); EndIf
If !ExistDir(cDirPai + cDirPag); MakeDir(cDirPai + cDirPag); EndIf

dbSelectArea("SA2")
SA2->( dbSetOrder(3) )
If SA2->( MsSeek( xFilial("SA2") + oRequest["providerRegNumber"] ) )

    cIdSC   := oRequest["id"]
    nValor  := Round(oRequest["price"] / oRequest["numberInstallments"], 2)

    BEGIN TRANSACTION
    dVcto := GetDate(oRequest["firstDate"])

    SE2->( dbSetOrder(1) )
    While SE2->( MsSeek( xFilial("SE2") + cPrfSE2 + cNumSE2 ) )
        cNumSE2 := GetSXENum("SE2","E2_NUM")
        ConfirmSX8()
    EndDo

    For nParcela:= 1 To oRequest["numberInstallments"]

        If nParcela > 1
            dVcto := DaySum(dVcto, 30)
        EndIf

        cNumSE2 := GetSXENum("SE2","E2_NUM")

        aAdd(aFina050, {"E2_FILIAL"	    , xFilial("SE2", "01")		                        , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_EMPFAT"		, oRequest["company"]		                        , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_PREFIXO"	, cPrfSE2						                    , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_NUM"		, cNumSE2	                                        , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_PARCELA"	, cValToChar(nParcela)                              , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_TIPO"		, "DP"	                                            , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_NUMNOTA"	, "PEDIDO"                                          , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_FORNECE"	, SA2->A2_COD                                       , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_LOJA"		, SA2->A2_LOJA                                      , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_NATUREZ"	, SA2->A2_NATUREZ	                                        , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_EMISSAO"	, GetDate(oRequest["createdDate"])                  , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_VENCTO"	    , dVcto	                                            , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_VENCREA"	, DataValida(dVcto)	                                , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_VALOR"		, nValor	                                        , "AllwaysTrue()"} )
        aAdd(aFina050, {"E2_HIST"	    , "Solicitação Portal: " + cValToChar(cIdSC)        , "AllwaysTrue()"} )
        
        
        aAdd(aFina050, {"E2_XVLRNF"		, nValor	                                        , "AllwaysTrue()"} )

        If oRequest["budgetId"] <> Nil
            aAdd(aFina050, {"E2_PROPOS" , oRequest["budgetId"]                              , "AllwaysTrue()"} )
        EndIf

        lMsErroAuto := .F.

        MSExecAuto({|x,y|Fina050(x,y)},aFina050,3)

        If lMsErroAuto
            lRet := .F.
            DisarmTransaction()
            cErro := MostraErro(cDirPai + cDirPag, cIdSC + "-" + cValToChar(nParcela) + "-" + DTOS( Date() ) + "-" + Time() + ".log")
            RollBackSX8()
        Else
            ConfirmSX8()
        Endif

    Next nX

    END TRANSACTION
EndIf

If !lRet
    SetRestFault(400, EncodeUTF8(cErro), .T.)
Else
    oResponse['success'] := .T.
    self:SetResponse( EncodeUTF8(oResponse:ToJSON() ) )
EndIf

Return(lRet)

/*/{Protheus.doc} API - POST
Formata a Data para tipo de data do Protheus
@author Victor A. Barbosa
@since 16/02/2021
@version 1
/*/
Static Function GetDate(cFirstDate)

Local cNewDate := StrTran(Left(cFirstDate, 10), "-", "")

Return STOD(cNewDate)
