#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS57
Cálculo de Vendas.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS57()

Local cFilterDefault := ""

Private aRotina := MenuDef()

Private oBrowse
Private cCadastro := "Cálculo de Vendas"

// cFilterDefault := U_PMS57FIL()

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "Z38" FILTERDEFAULT cFilterDefault DESCRIPTION cCadastro

// Ativacao da Classe
ACTIVATE FWMBROWSE oBrowse

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStruZ38 := FwFormStruct( 1, "Z38")

oModel:= MpFormMOdel():New( "PMS57MVC" ,  /*bPreValid*/ , /*bPosValid*/ , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription("Vendas")

oModel:AddFields("Z38MASTER", Nil, oStruZ38, /*prevalid*/, , /*bCarga*/)

oModel:GetModel( "Z38MASTER" ):SetDescription( "Vendas" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFPMS57")
Local oView     := Nil
Local oStruZ38  := FwFormStruct( 2, "Z38")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VwFieldZ38", oStruZ38 , "Z38MASTER")

oView:CreateHorizontalBox("SUPERIOR", 100)

oView:SetOwnerView("VwFieldZ38", "SUPERIOR")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu funcional.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        	ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.ALFPMS57" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Calcular Vendas"      ACTION "U_PMS57CAL" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Filtros" 		    	ACTION "U_PMS57FIL"			OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS57FIL
Tela de filtros do browse.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS57FIL()

Local aBoxParam := {}
Local aRetParam := {}
Local cFiltros  := " Z38_FILIAL = '"+xFilial("Z38")+"' "
Local cAnoMeta  := StrZero(YEAR(dDatabase),4)
Local cMesMeta  := StrZero(MONTH(dDatabase),2)
Local dAproIni  := CriaVar("Z02_DTAPRO",.F.)
Local dAproFim  := CriaVar("Z02_DTAPRO",.F.)
Local cVendIni 	:= CriaVar("Z38_VEND",.F.)
Local cVendFim 	:= CriaVar("Z38_VEND",.F.)

//Filtros para Query
AADD( aBoxParam, {1,"Meta Ano"	        ,cAnoMeta	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Meta Mês"	        ,cMesMeta	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Aprovação De"	,dAproIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Aprovação Ate"	,dAproFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Vendedor De"		,cVendIni	,"","","SA3","",050,.F.} )
AADD( aBoxParam, {1,"Vendedor Ate"		,cVendFim	,"","","SA3","",050,.F.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

    cAnoMeta := aRetParam[01]
    cMesMeta := aRetParam[02]
    dAproIni := aRetParam[03]
	dAproFim := aRetParam[04]
	cVendIni := aRetParam[05]
	cVendFim := aRetParam[06]

	// Meta Ano
	If !Empty(cAnoMeta)
		cFiltros += " .AND. Z38_ANO = '"+cAnoMeta+"' "
	EndIf

	// Meta Mês
	If !Empty(cMesMeta)
		cFiltros += " .AND. Z38_MES = '"+cMesMeta+"' "
	EndIf

	// Dt.Aprovação DE ATE
	If !Empty(dAproIni) .Or. !Empty(dAproFim)
		cFiltros += " .AND. Z38_DTAPRO >= SToD('"+DToS(dAproIni)+"') "
		cFiltros += " .AND. Z38_DTAPRO <= SToD('"+DToS(dAproFim)+"') "
	EndIf

	// Vendedor DE ATE
	If !Empty(cVendIni) .Or. !Empty(cVendFim)
		cFiltros += " .AND. Z38_VEND >= '"+cVendIni+"' "
		cFiltros += " .AND. Z38_VEND <= '"+cVendFim+"' "
	EndIf
EndIf

If TYPE("oBrowse") <> "U"
	oBrowse:SetFilterDefault(cFiltros)
	TcRefresh(RetSqlName("Z38"))	
	Z38->(dbGoTop())
	oBrowse:Refresh(.T.)
EndIf

Return cFiltros

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS57CAL
Calcula as vendas.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS57CAL()

Local aAreaAtu  := GetArea()
Local aAreaZ38  := Z38->(GetArea())
Local aBoxParam := {}
Local aRetParam := {}

// Private dDtGera  := DATE()

Private cAnoMeta := StrZero(YEAR(dDatabase),4)
Private cMesMeta := StrZero(MONTH(dDatabase),2)
Private dAproIni := CriaVar("Z02_DTAPRO",.F.)
Private dAproFim := CriaVar("Z02_DTAPRO",.F.)

//Filtros para Query
AADD( aBoxParam, {1,"Meta Ano"	        ,cAnoMeta	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Meta Mês"	        ,cMesMeta	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Aprovação De"	,dAproIni	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Aprovação Ate"	,dAproFim	,"","","","",050,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

    cAnoMeta := aRetParam[01]
    cMesMeta := aRetParam[02]
    dAproIni := aRetParam[03]
	dAproFim := aRetParam[04]

    FWMsgRun(, {|| CalcVend() }, "Aguarde", "Calculando Vendas...")

    FWMsgRun(, {|| CalcMetas() }, "Aguarde", "Calculando Metas x Vendas...")

EndIf

RestArea(aAreaZ38)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcVend
Calcula vendas com base nas propostas.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcVend()

Local aAreaAtu  := GetArea()
Local aAreaZ38  := Z38->(GetArea())
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	Z02.Z02_FILIAL "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
cQuery += " 	,Z02.Z02_ADITIV "+ CRLF
cQuery += " 	,Z02.Z02_CLIENT "+ CRLF
cQuery += " 	,Z02.Z02_LOJA "+ CRLF
cQuery += " 	,Z02.Z02_DTAPRO "+ CRLF
cQuery += " 	,Z02.Z02_VEND2 "+ CRLF
cQuery += " 	,Z02.Z02_IMPOST "+ CRLF
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04.Z04_VALOR) * Z02.Z02_IMPOST,2) ELSE SUM(Z04.Z04_VALOR) END AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('1') "+ CRLF // 1=Servicos
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS Z02_VLRSRV "+ CRLF
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04.Z04_TOTAL) * Z02.Z02_IMPOST,2) ELSE SUM(Z04.Z04_TOTAL) END AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('3') "+ CRLF // 3=Setup Cloud
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS Z02_VLRSET "+ CRLF
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04.Z04_VALOR) * Z02.Z02_IMPOST,2) * 12 ELSE SUM(Z04.Z04_VALOR) * 12 END AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('4') "+ CRLF // 4=Licenciamento
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS Z02_VLRSAS "+ CRLF
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             CASE WHEN Z02_IMPINC = '1' THEN ROUND(SUM(Z04.Z04_VALOR) * Z02.Z02_IMPOST,2) * 12 ELSE SUM(Z04.Z04_VALOR) * 12 END AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('5') "+ CRLF // 5=Suporte Mensal
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS Z02_VLRAMS "+ CRLF


cQuery += " FROM "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF

// cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
// cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
// cQuery += " 	AND SA3.A3_COD = Z02.Z02_VEND2 "+ CRLF
// cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z02.Z02_FILIAL = '"+xFilial("Z02")+"' "+ CRLF
cQuery += "     AND Z02.Z02_DTAPRO BETWEEN '"+DToS(dAproIni)+"' AND '"+DToS(dAproFim)+"' "+ CRLF
cQuery += "     AND Z02.Z02_RENOVA IN ('','1') "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	Z02.Z02_FILIAL "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
cQuery += " 	,Z02.Z02_ADITIV "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z38")
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += (cTMP1)->Z02_CLIENT
    cChave += (cTMP1)->Z02_LOJA

    nVlrSrv := (cTMP1)->Z02_VLRSRV
    nVlrSet := IIF((cTMP1)->Z02_VLRSET >= 5000, (cTMP1)->Z02_VLRSET, 0)
    nVlrAMS := (cTMP1)->Z02_VLRAMS
    nVlrSAS := (cTMP1)->Z02_VLRSAS

    nVlrTotal := nVlrSrv + nVlrSet + nVlrAMS + nVlrSAS

    DbSelectArea("Z38")
    DbSetOrder(1) // Z38_FILIAL, Z38_PROPOS, Z38_ADITIV, Z38_CODCLI, Z38_LOJCLI
    Incluir := !DbSeek(cChave)
       
    RecLock("Z38",Incluir)
        REPLACE Z38_FILIAL WITH xFilial("Z38") // Filial
        REPLACE Z38_PROPOS WITH (cTMP1)->Z02_PROPOS // Proposta
        REPLACE Z38_ADITIV WITH (cTMP1)->Z02_ADITIV // Aditivo
        REPLACE Z38_CODCLI WITH (cTMP1)->Z02_CLIENT // Cod. Cliente
        REPLACE Z38_LOJCLI WITH (cTMP1)->Z02_LOJA   // Loja Cliente
        REPLACE Z38_DTAPRO WITH SToD((cTMP1)->Z02_DTAPRO) // Dt.Aprov
        REPLACE Z38_ANO    WITH cAnoMeta // Ano
        REPLACE Z38_MES    WITH cMesMeta // Mês
        REPLACE Z38_VEND   WITH (cTMP1)->Z02_VEND2 // Vendedor
        REPLACE Z38_VLRSRV WITH nVlrSrv // Vlr.Serviço
        REPLACE Z38_VLRSET WITH nVlrSet // Vlr.Setup
        REPLACE Z38_VLRAMS WITH nVlrAMS // Vlr.Suporte
        REPLACE Z38_VLRSAS WITH nVlrSAS // Vlr.SAAS
        REPLACE Z38_TOTAL  WITH nVlrTotal // Vlr.Total
    MsUnlock()

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaZ38)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcMetas
Calcula as metas x vendas dos vendedores.

@author  Wilson A. Silva Jr.
@since   17/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcMetas()

Local aAreaAtu  := GetArea()
Local aAreaZ37  := Z37->(GetArea())
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

Local nFaixa1   := 75
Local nFaixa2   := 100
Local nFaixa3   := 125

local afaixas   := {}
local ncount := 0

Z46->(DbSetOrder(1))
Z46->(dbgotop())
while Z46->(!eof())
    aadd(afaixas,{ Z46->Z46_META,Z46->Z46_PERC})
    Z46->( DbSkip() )
end

cQuery := " SELECT "+ CRLF
cQuery += " 	Z38.Z38_FILIAL "+ CRLF
cQuery += " 	,Z38.Z38_ANO "+ CRLF
cQuery += " 	,Z38.Z38_MES "+ CRLF
cQuery += " 	,Z38.Z38_VEND "+ CRLF
cQuery += "     ,SA3.A3_COMIS "+ CRLF
cQuery += " 	,SUM(Z38.Z38_TOTAL) AS Z38_TOTAL "+ CRLF

cQuery += " FROM "+RetSqlName("Z38")+" Z38 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = Z38.Z38_VEND "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z38.Z38_FILIAL = '"+xFilial("Z38")+"' "+ CRLF
cQuery += "     AND Z38.Z38_ANO = '"+cAnoMeta+"' "+ CRLF
cQuery += "     AND Z38.Z38_MES = '"+cMesMeta+"' "+ CRLF
cQuery += " 	AND Z38.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	Z38.Z38_FILIAL "+ CRLF
cQuery += " 	,Z38.Z38_ANO "+ CRLF
cQuery += " 	,Z38.Z38_MES "+ CRLF
cQuery += " 	,Z38.Z38_VEND "+ CRLF
cQuery += "     ,SA3.A3_COMIS "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	Z38.Z38_ANO "+ CRLF
cQuery += " 	,Z38.Z38_MES "+ CRLF
cQuery += " 	,Z38.Z38_VEND "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z37")
    cChave += (cTMP1)->Z38_ANO
    cChave += (cTMP1)->Z38_MES
    cChave += (cTMP1)->Z38_VEND

    DbSelectArea("Z37")
    DbSetOrder(1) // Z37_FILIAL, Z37_ANO, Z37_MES, Z37_VEND
    If DbSeek(cChave)

        nVlrMeta  := Z37->Z37_META
        nVlrVenda := (cTMP1)->Z38_TOTAL
        nComissao := (cTMP1)->A3_COMIS
        nRealizad := 0

        nComissao:= afaixas[1][2]
        If nVlrMeta > 0 //.And. nVlrVenda > 0
            nRealizad := (nVlrVenda / nVlrMeta) * 100
            for  ncount := 1 to  len(afaixas)
                If nRealizad >= afaixas[ncount][1]    
                    nComissao:= afaixas[ncount][2]
                end
            next 
            /*
            If nRealizad >= nFaixa3
                nComissao += 3
            ElseIf nRealizad >= nFaixa2
                nComissao += 2
            ElseIf nRealizad >= nFaixa1
                nComissao += 1
            EndIf
            */
        EndIf

        RecLock("Z37",.F.)
            REPLACE Z37_VENDA  WITH nVlrVenda // Venda (R$)
            REPLACE Z37_REALIZ WITH nRealizad // % Realizado
            REPLACE Z37_COMISS WITH nComissao // % Comissão
        MsUnlock()
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaZ37)
RestArea(aAreaAtu)

Return .T.
