#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aListMeses := {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS56
Cadastro de Metas

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS56()

Private aRotina := MenuDef()

Private oBrowse
Private cCadastro := "Cadastro de Metas"

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "Z37" DESCRIPTION cCadastro


// Ativacao da Classe
ACTIVATE FWMBROWSE oBrowse

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu funcional.

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        	ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.ALFPMS56" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"       		ACTION "VIEWDEF.ALFPMS56" 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"       		ACTION "VIEWDEF.ALFPMS56" 	OPERATION 4 ACCESS 0
// ADD OPTION aRotina TITLE "Excluir"       		ACTION "VIEWDEF.ALFPMS56" 	OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados.

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MpFormMOdel():New( "PMS56MVC" ,  /*bPreValid*/ , {|oModel| fPostVld(oModel) } , {|oModel| fCommit(oModel)} ,/*bCancel*/ )

// Cabecalho - Ano
oModel:AddFields("HDMASTER", NIL, GetStrHead(1), NIL, NIL, {|oSubMod| {Z37->Z37_ANO}})
oModel:SetPrimaryKey({"ANOMETA"})
oModel:GetModel("HDMASTER"):SetDescription("Ano")

// Cadastro de Metas por Vendedor
oModel:AddGrid("DETAILS", "HDMASTER", GetStrDet(1), /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, {|oSubMod| fLoadZ37(oSubMod)})
oModel:SetRelation("DETAILS", {{"ANOMETA", "Z37ANO"}} , "ANOMETA")
oModel:GetModel("DETAILS"):SetDescription("Metas")
oModel:GetModel("DETAILS"):SetNoDeleteLine(.T.)

oModel:SetDescription("Cadastro de Metas")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface.

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFPMS56")
Local oView     := Nil

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VwMaster", GetStrHead(2) , "HDMASTER")
oView:AddGrid("VwDetails", GetStrDet(2)  , "DETAILS")

oView:CreateHorizontalBox("SUPERIOR", 20)
oView:CreateHorizontalBox("INFERIOR", 80)

oView:SetOwnerView("VwMaster", "SUPERIOR")
oView:SetOwnerView("VwDetails", "INFERIOR")

Return oView

//--------------------------------------------------------------------------------------
/*{Protheus.doc} GetStrHead
Retorna a Estrutura do Header

@author		Guilherme Santos
@since 		15/06/2018
@version 	12.1.17
@param		nOpcao, Integer, 1=Model ou 2=View
@return 	Object, Estrutura de Dados do Cabecalho
*/
//--------------------------------------------------------------------------------------
Static Function GetStrHead(nOpcao)

Local oStruct	:= NIL

Do Case
    Case nOpcao == 1	//Model
        oStruct := FWFormModelStruct():New()

        //AddTable(cAlias, aPK, cDescription)
        oStruct:AddTable("   ", {" "}, " ")

        //Campo Virtual para Relacionamento com a SE1
        //FWFormModelStruct:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
        oStruct:AddField("Meta Ano", "Meta Ano", "ANOMETA", "C", 4, 0, FWBuildFeature(STRUCT_FEATURE_VALID, 'ExistChav("Z37")'), {|| INCLUI}, NIL, .T., NIL, .F., .F., .T.)

        //FWFormModelStruct():AddIndex(<nOrdem >, <cOrdem >, <cKey >, <cDescription >, <cLookUp >, <cNickName >, <lShow >)
        oStruct:AddIndex(1, "PRINCIPAL", "ANOMETA", "Ano", "", "", .T.)

    Case nOpcao == 2		//2-View
        oStruct	:= FWFormViewStruct():New()        
        
        //FWFormViewStruct():AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine,  nWidth)
        oStruct:AddField("ANOMETA"  , "01", "Meta Ano"  , "Meta Ano", NIL, "C", "@R 9999", NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL)
EndCase

Return oStruct

//--------------------------------------------------------------------------------------
/*{Protheus.doc} GetStrZH1
Retorna a estrutura da Tabela ZH1 - Itens do Arquivo de Retorno

@author		Guilherme Santos
@since 		15/06/2018
@version 	12.1.17
@param		nOpcao, Integer, 1=Model ou 2=View
@param		nFolder, Integer, Numero da Folder para Exibicao
@return 	Object, Estrutura de Dados dos Itens do Arquivo de Retorno
*/
//--------------------------------------------------------------------------------------
Static Function GetStrDet(nOpcao)

Local oStruct 	:= Nil
Local nX

Do Case
    Case nOpcao == 1		//1-Model
        oStruct := FWFormModelStruct():New()

        //AddTable(cAlias, aPK, cDescription)
        oStruct:AddTable("Z37DET", {"Z37ANO", "Z37VEND"}, "Detalhes")
        
        //FWFormModelStruct():AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
        oStruct:AddField("Meta Ano" , "Meta Ano", "Z37ANO" , "C", 4                         , 0                         , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .F., .F.)
        oStruct:AddField("Vendedor" , "Vendedor", "Z37VEND", "C", TamSX3("Z37_VEND")[01]    , TamSX3("Z37_VEND")[02]    , FWBuildFeature(STRUCT_FEATURE_VALID, 'ExistCpo("SA3")'), {|| .T.}, NIL, .T., NIL, .F., .T., .F.)
        oStruct:AddField("Nome"     , "Nome"    , "Z37NOME", "C", TamSX3("Z37_NOMVEN")[01]  , TamSX3("Z37_NOMVEN")[02]  , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .F., .T.)
        
        For nX := 1 to Len(aListMeses)
            cTitle   := aListMeses[nX]
            cTooltip := "Meta de " + aListMeses[nX]
            cIdField := "META" + StrZero(nX,2)
            oStruct:AddField(cTitle, cTooltip, cIdField, "N", TamSX3("Z37_META")[01], TamSX3("Z37_META")[02], FWBuildFeature(STRUCT_FEATURE_VALID, 'Positivo()'), {|| .T.}, NIL, .F., NIL, .F., .F., .F.)
        Next nX
        
        oStruct:AddTrigger("Z37VEND", "Z37NOME", {|| .T. }, {|| RetNomeVend() } )

        //FWFormModelStruct():AddIndex(<nOrdem >, <cOrdem >, <cKey >, <cDescription >, <cLookUp >, <cNickName >, <lShow >)
        oStruct:AddIndex(1, "PRINCIPAL", "Z37ANO+Z37VEND", "Ano+Vendedor", "", "", .T.)

    Case nOpcao == 2		//2-View
        oStruct	:= FWFormViewStruct():New()        
        
        //FWFormViewStruct():AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine,  nWidth)
        oStruct:AddField("Z37VEND"  , "02", "Vendedor"  , "Vendedor", NIL, "C", NIL      , NIL, "SA3", NIL, NIL, NIL, ,NIL, NIL, NIL, NIL, .F.)
        oStruct:AddField("Z37NOME"  , "03", "Nome"      , "Nome"    , NIL, "C", NIL      , NIL, NIL, NIL, NIL, NIL, ,NIL, NIL, NIL, NIL, .F.)

        For nX := 1 to Len(aListMeses)
            cTitle   := aListMeses[nX]
            cTooltip := "Meta de " + aListMeses[nX]
            cIdField := "META" + StrZero(nX,2)
            cOrdem   := StrZero((nX+3),2)
            oStruct:AddField(cIdField, cOrdem, cTitle, cTooltip, NIL, "N", PesqPict("Z37", "Z37_META"), NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL)
        Next nX
EndCase

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} PostVld
Validacoes no carregamento do model.

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function VldActivate(oModel)

Local aAreaAtu	 := GetArea()
Local nOperation := oModel:GetOperation()
Local lRet 		 := .T.

If Z36->Z36_STATUS <> "1"
	If nOperation == MODEL_OPERATION_UPDATE
		Help(Nil,Nil,ProcName(),,'Apenas "Comissão Pendente" pode ser alterada.', 1, 5)
		lRet := .F.
	EndIf

	If nOperation == MODEL_OPERATION_DELETE 
		Help(Nil,Nil,ProcName(),,'Apenas "Comissão Pendente" pode ser excluida.', 1, 5)
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaAtu)

Return lRet

Static Function RetNomeVend()

Local aAreaAtu	:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local oModel	:= FWModelActive()
Local oSubZ36	:= oModel:GetModel("DETAILS")
Local cVendedor := oSubZ36:GetValue("Z37VEND")
Local cNome 	:= ""

cNome := POSICIONE("SA3",1,xFilial("SA3")+cVendedor,"A3_NOME")

RestArea(aAreaSA3)
RestArea(aAreaAtu)

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} fCommit
Gravacao dos Dados do Modelo

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fCommit(oModel)

Local oMaster	:= oModel:GetModel("HDMASTER")
Local oDetails	:= oModel:GetModel("DETAILS")
Local cAnoMeta  := oMaster:GetValue("ANOMETA")
Local nLinha	:= 0
Local aRows     := {}

Local lRetorno := .T.

BEGIN TRANSACTION

    aRows := FWSaveRows()

    For nLinha := 1 to oDetails:Length()

        oDetails:GoLine(nLinha)

        //Grava o Registro de Meta
        If oDetails:IsInserted() .Or. oDetails:IsUpdated()
            GravaZ37(cAnoMeta, oDetails, oModel:GetOperation())
        EndIf

    Next nLinha

    FWRestRows(aRows)

END TRANSACTION

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaZ37
Gravacao do Registro na Z37

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaZ37(cAnoMeta, oModZ37, nOpcao)

Local aAreaAtu := GetArea()
Local aAreaZ37 := Z37->(GetArea())
Local nX

DbSelectArea("Z37")
DbSetOrder(1) // Z37_FILIAL, Z37_ANO, Z37_MES, Z37_VEND

If (nOpcao == MODEL_OPERATION_INSERT) ;
    .Or. (nOpcao == MODEL_OPERATION_UPDATE)

    For nX := 1 To Len(aListMeses)
        cMesMeta := StrZero(nX,2)
        cCpoMeta := "META" + cMesMeta
        cCodVend := oModZ37:GetValue("Z37VEND")

        lInclui := !Z37->(DbSeek(xFilial("Z37")+cAnoMeta+cMesMeta+cCodVend))

        RecLock("Z37", lInclui)
            REPLACE Z37_FILIAL WITH xFilial("Z37") // Filial
            REPLACE Z37_ANO	   WITH cAnoMeta // Ano
            REPLACE Z37_MES    WITH cMesMeta // Mês
            REPLACE Z37_VEND   WITH cCodVend // Vendedor
            REPLACE Z37_META   WITH oModZ37:GetValue(cCpoMeta) // Meta (R$)
        MsUnlock()
    Next nX
EndIf

RestArea(aAreaZ37)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fPostVld
Valida os Dados do Modelo antes de acionar a gravacao

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fPostVld(oModel)

// Local aSaveLines	:= FWSaveRows()
// Local nSubMod		:= 0
// Local oSubMod		:= NIL
// Local nLinha		:= ""
Local lRetorno		:= .T.

// For nSubMod := 1 to 5
// 	oSubMod := oModel:GetModel("SE2FLD" + AllTrim(Str(nSubMod)))

// 	For nLinha := 1 to oSubMod:Length()
// 		oSubMod:GoLine(nLinha)

// 		If !Empty(oSubMod:GetValue("E2BCOORI")) .AND. !Empty(oSubMod:GetValue("E2AGEORI")) .AND. !Empty(oSubMod:GetValue("E2CTAORI"))
// 			lRetorno := .T.
// 		EndIf
// 	Next nLinha

// Next nSubMod

// If !lRetorno
// 	Help(" ", 1, "Help", "fPostVld", "Nenhum registro selecionado para geração do Bordero e do CNAB.", 3, 0)
// EndIf

// FWRestRows(aSaveLines)

Return lRetorno

//--------------------------------------------------------------------------------------
/*{Protheus.doc} fLoadZ37
Carregamento dos Dados da Grid da Tabela Z37

@author  Wilson A. Silva Jr.
@since   16/11/2023
@version 12.1.17
*/
//--------------------------------------------------------------------------------------
Static Function fLoadZ37(oSubMod)

Local aAreaAtu  := GetArea()
Local cTMP1	    := ""
Local cQuery	:= ""
Local aAux		:= {}
Local aRetorno 	:= {}
Local nX

cQuery := " SELECT "+ CRLF
cQuery += "     MAX(Z37.R_E_C_N_O_) AS REGZ37 "+ CRLF
cQuery += "     ,Z37.Z37_ANO AS Z37ANO "+ CRLF
cQuery += "     ,Z37.Z37_VEND AS Z37VEND "+ CRLF
cQuery += "     ,SA3.A3_NOME AS Z37NOME "+ CRLF

For nX := 1 To Len(aListMeses)
    cMesMeta := StrZero(nX,2)
    cCpoMeta := "META" + cMesMeta
    cQuery += "     ,SUM(CASE WHEN Z37.Z37_MES = '"+cMesMeta+"' THEN Z37.Z37_META ELSE 0 END) AS "+cCpoMeta+" "+ CRLF
Next nX

cQuery += " FROM "+RetSqlName("Z37")+" Z37 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += "     ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += "     AND SA3.A3_COD = Z37.Z37_VEND "+ CRLF
cQuery += "     AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += "     Z37.Z37_FILIAL = '"+xFilial("Z37")+"' "+ CRLF
cQuery += "     AND Z37.Z37_ANO = '"+Z37->Z37_ANO+"' "+ CRLF
cQuery += "     AND Z37.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += "     Z37.Z37_ANO "+ CRLF
cQuery += "     ,Z37.Z37_VEND "+ CRLF
cQuery += "     ,SA3.A3_NOME "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += "     SA3.A3_NOME "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    AADD( aAux, (cTMP1)->Z37ANO )
    AADD( aAux, (cTMP1)->Z37VEND )
    AADD( aAux, (cTMP1)->Z37NOME )

    For nX := 1 To Len(aListMeses)
        cCpoMeta := "META" + StrZero(nX,2)
        AADD( aAux, &(cTMP1+"->"+cCpoMeta) )
    Next nX

    Aadd(aRetorno, {(cTMP1)->REGZ37, aAux})
    aAux := {}

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaAtu)

Return aRetorno
