#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS30
Tela de Rateio do Contas a Pagar.

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS30()

Private aRotina    := MenuDef()
Private __lAtuaRat := .F.
Private cCadastro  := "Tela de Rateio do Contas a Pagar"

mBrowse( 6, 1,22,75,"SE2",,,,,,Fa040Legenda("SE2"),,,,,,,,)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   11/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local aSEVxSE2 := {}
Local aSEZxSEV := {}

AADD( aSEVxSE2, { "EV_FILIAL"  , "xFilial('SEV')" } )
AADD( aSEVxSE2, { "EV_PREFIXO" , "E2_PREFIXO"     } )
AADD( aSEVxSE2, { "EV_NUM"     , "E2_NUM"         } )
AADD( aSEVxSE2, { "EV_PARCELA" , "E2_PARCELA"     } )
AADD( aSEVxSE2, { "EV_TIPO"    , "E2_TIPO"        } )
AADD( aSEVxSE2, { "EV_CLIFOR"  , "E2_FORNECE"     } )
AADD( aSEVxSE2, { "EV_LOJA"    , "E2_LOJA"        } )

AADD( aSEZxSEV, { "EZ_FILIAL"  , "xFilial('SEZ')" } )
AADD( aSEZxSEV, { "EZ_PREFIXO" , "E2_PREFIXO"     } )
AADD( aSEZxSEV, { "EZ_NUM"     , "E2_NUM"         } )
AADD( aSEZxSEV, { "EZ_PARCELA" , "E2_PARCELA"     } )
AADD( aSEZxSEV, { "EZ_TIPO"    , "E2_TIPO"        } )
AADD( aSEZxSEV, { "EZ_CLIFOR"  , "E2_FORNECE"     } )
AADD( aSEZxSEV, { "EZ_LOJA"    , "E2_LOJA"        } )
AADD( aSEZxSEV, { "EZ_NATUREZ" , "SEVDETAIL.EV_NATUREZ"     } )

bPosValid := {|oModel| VldModel(oModel)}
oModel:= MpFormModel():New( "PMS30MVC" ,  /*bPreValid*/ , bPosValid, {|oModel| fCommit(oModel)},/*bCancel*/ )
oModel:SetDescription("Rateio Contas a Pagar")

bLoadSE2 := {|oModel| LoadSE2(oModel)}
oModel:AddFields("SE2MASTER", /*cOwner*/, GetStrSE2(1), /*bPre*/, /*bPost*/, bLoadSE2)
oModel:SetPrimaryKey({"E2_FILIAL", "E2_PREFIXO", "E2_NUM", "E2_PARCELA", "E2_TIPO", "E2_FORNECE", "E2_LOJA"})
oModel:GetModel("SE2MASTER"):SetDescription("Título Contas a Pagar")
oModel:GetModel("SE2MASTER"):SetOnlyQuery(.T.)

bLoadSEV := {|oModel| LoadSEV(oModel)}
oModel:AddGrid("SEVDETAIL", "SE2MASTER", GetStrSEV(1), /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadSEV)
oModel:SetRelation("SEVDETAIL", aSEVxSE2, "EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ" )
oModel:GetModel("SEVDETAIL"):SetDescription("Rateio por Natureza")
// oModel:GetModel("SEVDETAIL"):SetOptional(.T.)
oModel:GetModel("SEVDETAIL"):SetOnlyQuery(.T.)

bLoadSEZ := {|oModel| LoadSEZ(oModel)}
oModel:AddGrid("SEZDETAIL", "SEVDETAIL", GetStrSEZ(1), /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadSEZ)
oModel:SetRelation("SEZDETAIL", aSEZxSEV, "EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO" )
oModel:GetModel("SEZDETAIL"):SetDescription("Rateio por Centro de Custo")
// oModel:GetModel("SEZDETAIL"):SetOptional(.T.)
oModel:GetModel("SEZDETAIL"):SetOnlyQuery(.T.)

// Totalizadores
bInitSldNat := {|oModel| InitSldNat(oModel) }
bForSldNat  := {|oModel, nTotalAtual, xValor, lSomando| ForSldNat( oModel, nTotalAtual, xValor, lSomando ) }
oModel:AddCalc("TOTNAT", "SE2MASTER", "SEVDETAIL", "EV_VALOR", "SLD_EVVALOR", "FORMULA" , /*bCond*/, bInitSldNat   , "Saldo a Distribuir", bForSldNat  , 14, 2)
oModel:AddCalc("TOTNAT", "SE2MASTER", "SEVDETAIL", "EV_VALOR", "SUM_EVVALOR", "SUM"     , /*bCond*/, /*bInitValue*/, "Valor Distribuido" , /*bFormula*/, 14, 2)
oModel:AddCalc("TOTNAT", "SE2MASTER", "SEVDETAIL", "EV_PERC" , "SUM_EVPERC" , "SUM"     , /*bCond*/, /*bInitValue*/, "% Distribuido"     , /*bFormula*/, 14, 2)

// Totalizadores
bInitSldCC := {|oModel| InitSldCC(oModel) }
bForSldCC  := {|oModel, nTotalAtual, xValor, lSomando| ForSldCC( oModel, nTotalAtual, xValor, lSomando ) }
oModel:AddCalc("TOTCC", "SEVDETAIL", "SEZDETAIL", "EZ_VALOR", "SLD_EZVALOR" , "FORMULA" , /*bCond*/, bInitSldCC    , "Saldo a Distribuir", bForSldCC   , 14, 2)
oModel:AddCalc("TOTCC", "SEVDETAIL", "SEZDETAIL", "EZ_VALOR", "SUM_EZVALOR" , "SUM"     , /*bCond*/, /*bInitValue*/, "Valor Distribuido" , /*bFormula*/, 14, 2)
oModel:AddCalc("TOTCC", "SEVDETAIL", "SEZDETAIL", "EZ_PERC" , "SUM_ZEPERC"  , "SUM"     , /*bCond*/, /*bInitValue*/, "% Distribuido"     , /*bFormula*/, 14, 2)

oModel:SetVldActivate( { |oModel| PMS30ACT( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface.

@author  Wilson A. Silva Jr
@since   11/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFPMS30")
Local oView 	:= Nil

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEWSE2", GetStrSE2(2) , "SE2MASTER")

oView:AddGrid("VIEWSEV", GetStrSEV(2), "SEVDETAIL") 
oView:AddGrid("VIEWSEZ", GetStrSEZ(2), "SEZDETAIL") 

oView:AddField("VIEW_TOTNAT", FWCalcStruct(oModel:GetModel("TOTNAT")), "TOTNAT")
oView:AddField("VIEW_TOTCC" , FWCalcStruct(oModel:GetModel("TOTCC")) , "TOTCC")

oView:CreateHorizontalBox("CABEC"   , 30)
oView:CreateHorizontalBox("NATUREZA", 35)
oView:CreateHorizontalBox("CCUSTO"  , 35)

oView:CreateVerticalBox( 'RATEIO_NAT', 80, 'NATUREZA')
oView:CreateVerticalBox( 'SALDO_NAT' , 20, 'NATUREZA')

oView:CreateVerticalBox( 'RATEIO_CC', 80, 'CCUSTO')
oView:CreateVerticalBox( 'SALDO_CC' , 20, 'CCUSTO')

oView:SetOwnerView("VIEWSE2", "CABEC")
oView:SetOwnerView("VIEWSEV", "RATEIO_NAT")
oView:SetOwnerView("VIEWSEZ", "RATEIO_CC")

oView:SetOwnerView("VIEW_TOTNAT", "SALDO_NAT")
oView:SetOwnerView("VIEW_TOTCC" , "SALDO_CC")

oView:SetViewProperty( "TOTNAT", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 5 } )
oView:SetViewProperty( "TOTCC" , "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 5 } )

oView:EnableTitleView('VIEWSE2' , 'Contas a Pagar'  )
oView:EnableTitleView('VIEWSEV' , 'Rateio por Naturezas' )
oView:EnableTitleView('VIEWSEZ' , 'Rateio por Centros de Custo'  )
oView:EnableTitleView('VIEW_TOTNAT' , 'Saldo Rateio'  )
oView:EnableTitleView('VIEW_TOTCC'  , 'Saldo Rateio'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStrSE2
Retorna a Estrutura do Header

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetStrSE2(nOpcao)

Local oStruct := NIL

If nOpcao == 1	//Model
    oStruct := FWFormModelStruct():New()

    //AddTable(cAlias, aPK, cDescription)
    oStruct:AddTable("SE2", {" "}, "Titulo Contas a Pagar")

    //Campo Virtual para Relacionamento com a SE2
    //FWFormModelStruct:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
    oStruct:AddField("Filial"       , "Filial"      , "E2_FILIAL"  , "C", TamSX3("E2_FILIAL")[1] , TamSX3("E2_FILIAL")[2] , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Prefixo"      , "Prefixo"     , "E2_PREFIXO" , "C", TamSX3("E2_PREFIXO")[1], TamSX3("E2_PREFIXO")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("No.Titulo"    , "No.Titulo"   , "E2_NUM"     , "C", TamSX3("E2_NUM")[1]    , TamSX3("E2_NUM")[2]    , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Parcela"      , "Parcela"     , "E2_PARCELA" , "C", TamSX3("E2_PARCELA")[1], TamSX3("E2_PARCELA")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Tipo"         , "Tipo"        , "E2_TIPO"    , "C", TamSX3("E2_TIPO")[1]   , TamSX3("E2_TIPO")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Vlr.Titulo"   , "Vlr.Titulo"  , "E2_VALOR"   , "N", TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2]  , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Fornecedor"   , "Fornecedor"  , "E2_FORNECE" , "C", TamSX3("E2_FORNECE")[1], TamSX3("E2_FORNECE")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Loja"         , "Loja"        , "E2_LOJA"    , "C", TamSX3("E2_LOJA")[1]   , TamSX3("E2_LOJA")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Fantasia"     , "Fantasia"    , "E2_NOMFOR"  , "C", TamSX3("E2_NOMFOR")[1] , TamSX3("E2_NOMFOR")[2] , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)

    oStruct:AddField("Emissão"      , "Emissão"     , "E2_EMISSAO" , "D", TamSX3("E2_EMISSAO")[1], TamSX3("E2_EMISSAO")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Vencto.Orig"  , "Vencto.Orig" , "E2_VENCORI" , "D", TamSX3("E2_VENCORI")[1], TamSX3("E2_VENCORI")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Vencimento"   , "Vencimento"  , "E2_VENCTO"  , "D", TamSX3("E2_VENCTO")[1] , TamSX3("E2_VENCTO")[2] , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Vencto.Real"  , "Vencto.Real" , "E2_VENCREA" , "D", TamSX3("E2_VENCREA")[1], TamSX3("E2_VENCREA")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Proposta"     , "Proposta"    , "E2_PROPOS"  , "C", TamSX3("E2_PROPOS")[1] , TamSX3("E2_PROPOS")[2] , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Histórico"    , "Histórico"   , "E2_HIST"    , "C", TamSX3("E2_HIST")[1]   , TamSX3("E2_HIST")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("Numero NF"    , "Numero NF"   , "E2_NUMNOTA" , "C", TamSX3("E2_NUMNOTA")[1], TamSX3("E2_NUMNOTA")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("PIS"          , "PIS"         , "E2_PIS"     , "N", TamSX3("E2_PIS")[1]    , TamSX3("E2_PIS")[2]    , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("COFINS"       , "COFINS"      , "E2_COFINS"  , "N", TamSX3("E2_COFINS")[1] , TamSX3("E2_COFINS")[2] , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("CSLL"         , "CSLL"        , "E2_CSLL"    , "N", TamSX3("E2_CSLL")[1]   , TamSX3("E2_CSLL")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("IRRF"         , "IRRF"        , "E2_IRRF"    , "N", TamSX3("E2_IRRF")[1]   , TamSX3("E2_IRRF")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("ISS"          , "ISS"         , "E2_ISS"     , "N", TamSX3("E2_ISS")[1]    , TamSX3("E2_ISS")[2]    , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)
    oStruct:AddField("INSS"         , "INSS"        , "E2_INSS"    , "N", TamSX3("E2_INSS")[1]   , TamSX3("E2_INSS")[2]   , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)

    oStruct:SetProperty("E2_NOMFOR", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SA2',1,xFilial('SA2')+SE2->E2_FORNECE+SE2->E2_LOJA,'A2_NREDUZ')"))

ElseIf nOpcao == 2	//View
    oStruct := FWFormViewStruct():New()

    //Campo Virtual para Relacionamento com a SE2
    //FWFormViewStruct:AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine, nWidth)
    oStruct:AddField("E2_PREFIXO"  , "01", "Prefixo"   , "Prefixo"   , NIL, "C", PesqPict("SE2", "E2_PREFIXO") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_NUM"      , "02", "No.Titulo" , "No.Titulo" , NIL, "C", PesqPict("SE2", "E2_NUM")     , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_PARCELA"  , "03", "Parcela"   , "Parcela"   , NIL, "C", PesqPict("SE2", "E2_PARCELA") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_TIPO"     , "04", "Tipo"      , "Tipo"      , NIL, "C", PesqPict("SE2", "E2_TIPO")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_VALOR"    , "05", "Vlr.Titulo", "Vlr.Titulo", NIL, "N", PesqPict("SE2", "E2_VALOR")   , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_FORNECE"  , "06", "Fornecedor", "Fornecedor", NIL, "C", PesqPict("SE2", "E2_FORNECE") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_LOJA"     , "07", "Loja"      , "Loja"      , NIL, "C", PesqPict("SE2", "E2_LOJA")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_NOMFOR"   , "08", "Fantasia"  , "Fantasia"  , NIL, "C", PesqPict("SE2", "E2_NOMFOR")  , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)

    oStruct:AddField("E2_EMISSAO"  , "09", "Emissão"    , "Emissão"    , NIL, "D", PesqPict("SE2", "E2_EMISSAO") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_VENCORI"  , "10", "Vencto.Orig", "Vencto.Orig", NIL, "D", PesqPict("SE2", "E2_VENCORI") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_VENCTO"   , "11", "Vencimento" , "Vencimento" , NIL, "D", PesqPict("SE2", "E2_VENCTO")  , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_VENCREA"  , "12", "Vencto.Real", "Vencto.Real", NIL, "D", PesqPict("SE2", "E2_VENCREA") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_PROPOS"   , "13", "Proposta"   , "Proposta"   , NIL, "C", PesqPict("SE2", "E2_PROPOS")  , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_HIST"     , "14", "Histórico"  , "Histórico"  , NIL, "C", PesqPict("SE2", "E2_HIST")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_NUMNOTA"  , "15", "Numero NF"  , "Numero NF"  , NIL, "C", PesqPict("SE2", "E2_NUMNOTA") , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_PIS"      , "17", "PIS"        , "PIS"        , NIL, "N", PesqPict("SE2", "E2_PIS")     , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_COFINS"   , "18", "COFINS"     , "COFINS"     , NIL, "N", PesqPict("SE2", "E2_COFINS")  , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_CSLL"     , "19", "CSLL"       , "CSLL"       , NIL, "N", PesqPict("SE2", "E2_CSLL")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_IRRF"     , "20", "IRRF"       , "IRRF"       , NIL, "N", PesqPict("SE2", "E2_IRRF")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_ISS"      , "21", "ISS"        , "ISS"        , NIL, "N", PesqPict("SE2", "E2_ISS")     , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("E2_INSS"     , "22", "INSS"       , "INSS"       , NIL, "N", PesqPict("SE2", "E2_INSS")    , NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStrSEV
Retorna a Estrutura do Header

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetStrSEV(nOpcao)

Local oStruct := NIL

If nOpcao == 1	//Model
    oStruct := FWFormModelStruct():New()

    //AddTable(cAlias, aPK, cDescription)
    oStruct:AddTable("SEV", {" "}, "Rateio por Natureza")

    //Campo Virtual para Relacionamento com a SE2
    //FWFormModelStruct:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
    oStruct:AddField("Filial"       , "Filial"      , "EV_FILIAL"  , "C", TamSX3("EV_FILIAL")[1] , TamSX3("EV_FILIAL")[2] , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Prefixo"      , "Prefixo"     , "EV_PREFIXO" , "C", TamSX3("EV_PREFIXO")[1], TamSX3("EV_PREFIXO")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("No.Titulo"    , "No.Titulo"   , "EV_NUM"     , "C", TamSX3("EV_NUM")[1]    , TamSX3("EV_NUM")[2]    , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Parcela"      , "Parcela"     , "EV_PARCELA" , "C", TamSX3("EV_PARCELA")[1], TamSX3("EV_PARCELA")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Cliente"      , "Cliente"     , "EV_CLIFOR"  , "C", TamSX3("EV_CLIFOR")[1] , TamSX3("EV_CLIFOR")[2] , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Loja"         , "Loja"        , "EV_LOJA"    , "C", TamSX3("EV_LOJA")[1]   , TamSX3("EV_LOJA")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Tipo"         , "Tipo"        , "EV_TIPO"    , "C", TamSX3("EV_TIPO")[1]   , TamSX3("EV_TIPO")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Natureza"     , "Natureza"    , "EV_NATUREZ" , "C", TamSX3("EV_NATUREZ")[1], TamSX3("EV_NATUREZ")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField("Descrição"    , "Descrição"   , "EV_DESCNAT" , "C", TamSX3("ED_DESCRIC")[1], TamSX3("ED_DESCRIC")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .F., .T., NIL)
    oStruct:AddField("Valor"        , "Valor"       , "EV_VALOR"   , "N", TamSX3("EV_VALOR")[1]  , TamSX3("EV_VALOR")[2]  , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField("Percentual"   , "Percentual"  , "EV_PERC"    , "N", TamSX3("EV_PERC")[1]   , TamSX3("EV_PERC")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField(" "            , " "           , "EMPTY"      , "C", 1                      , 0                      , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)

    oStruct:SetProperty("EV_NATUREZ", MODEL_FIELD_VALID, {|| U_PMS30NAT(1) })
    oStruct:SetProperty("EV_VALOR"  , MODEL_FIELD_VALID, {|| U_PMS30NAT(2) })
    oStruct:SetProperty("EV_PERC"   , MODEL_FIELD_VALID, {|| U_PMS30NAT(3) })

    aAux1 := FwStruTrigger(;
    'EV_NATUREZ',;
    'EV_DESCNAT',;
    'SED->ED_DESCRIC',;
    .T.,;
    'SED',;
    1,;
    'xFilial("SED")+M->EV_NATUREZ')

    oStruct:AddTrigger(aAux1[1], aAux1[2], aAux1[3], aAux1[4])

ElseIf nOpcao == 2	//View
    oStruct := FWFormViewStruct():New()

    //Campo Virtual para Relacionamento com a SE2
    //FWFormViewStruct:AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine, nWidth)
    oStruct:AddField("EV_NATUREZ" , "01", "Natureza"   , "Natureza"   , NIL, "C", "@R 99.999.99"                , NIL, "SED", NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EV_DESCNAT" , "02", "Descrição"  , "Descrição"  , NIL, "G", "@!"                          , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("EV_VALOR"   , "03", "Valor"      , "Valor"      , NIL, "N", "@E 999,999,999.99"           , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EV_PERC"    , "04", "Percentual" , "Percentual" , NIL, "N", "@E 999.99"                   , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EMPTY"      , "05", " "          , " "          , NIL, "G", "@!"                          , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStrSEZ
Retorna a Estrutura do Header

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetStrSEZ(nOpcao)

Local oStruct := NIL

If nOpcao == 1	//Model
    oStruct := FWFormModelStruct():New()

    //AddTable(cAlias, aPK, cDescription)
    oStruct:AddTable("SEZ", {" "}, "Rateio por Centro de Custo")

    //Campo Virtual para Relacionamento com a SE2
    //FWFormModelStruct:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
    oStruct:AddField("Filial"       , "Filial"      , "EZ_FILIAL"  , "C", TamSX3("EZ_FILIAL")[1] , TamSX3("EZ_FILIAL")[2] , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Prefixo"      , "Prefixo"     , "EZ_PREFIXO" , "C", TamSX3("EZ_PREFIXO")[1], TamSX3("EZ_PREFIXO")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("No.Titulo"    , "No.Titulo"   , "EZ_NUM"     , "C", TamSX3("EZ_NUM")[1]    , TamSX3("EZ_NUM")[2]    , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Parcela"      , "Parcela"     , "EZ_PARCELA" , "C", TamSX3("EZ_PARCELA")[1], TamSX3("EZ_PARCELA")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Cliente"      , "Cliente"     , "EZ_CLIFOR"  , "C", TamSX3("EZ_CLIFOR")[1] , TamSX3("EZ_CLIFOR")[2] , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Loja"         , "Loja"        , "EZ_LOJA"    , "C", TamSX3("EZ_LOJA")[1]   , TamSX3("EZ_LOJA")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Tipo"         , "Tipo"        , "EZ_TIPO"    , "C", TamSX3("EZ_TIPO")[1]   , TamSX3("EZ_TIPO")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Natureza"     , "Natureza"    , "EZ_NATUREZ" , "C", TamSX3("EZ_NATUREZ")[1], TamSX3("EZ_NATUREZ")[2], {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .T., .F., NIL)
    oStruct:AddField("Centro Custo" , "Centro Custo", "EZ_CCUSTO"  , "C", TamSX3("EZ_CCUSTO")[1] , TamSX3("EZ_CCUSTO")[2] , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField("Descrição"    , "Descrição"   , "EZ_DESCCC"  , "C", TamSX3("CTT_DESC01")[1], TamSX3("CTT_DESC01")[2], {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .F., .T., NIL)
    oStruct:AddField("Valor"        , "Valor"       , "EZ_VALOR"   , "N", TamSX3("EZ_VALOR")[1]  , TamSX3("EZ_VALOR")[2]  , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField("Percentual"   , "Percentual"  , "EZ_PERC"    , "N", TamSX3("EZ_PERC")[1]   , TamSX3("EZ_PERC")[2]   , {|| .T.}, {|| .T.}, NIL, .F., NIL, .F., .F., .F., NIL)
    oStruct:AddField(" "            , " "           , "EMPTY"      , "C", 1                      , 0                      , {|| .T.}, {|| .F.}, NIL, .F., NIL, .F., .T., .T., NIL)

    oStruct:SetProperty("EZ_CCUSTO" , MODEL_FIELD_VALID, {|| U_PMS30CC(1) })
    oStruct:SetProperty("EZ_VALOR"  , MODEL_FIELD_VALID, {|| U_PMS30CC(2) })
    oStruct:SetProperty("EZ_PERC"   , MODEL_FIELD_VALID, {|| U_PMS30CC(3) })

    aAux1 := FwStruTrigger(;
    'EZ_CCUSTO',;
    'EZ_DESCCC',;
    'CTT->CTT_DESC01',;
    .T.,;
    'CTT',;
    1,;
    'xFilial("CTT")+M->EZ_CCUSTO')

    oStruct:AddTrigger(aAux1[1], aAux1[2], aAux1[3], aAux1[4])

ElseIf nOpcao == 2	//View
    oStruct := FWFormViewStruct():New()

    //Campo Virtual para Relacionamento com a SE2
    //FWFormViewStruct:AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine, nWidth)
    oStruct:AddField("EZ_CCUSTO"  , "01", "Centro Custo", "Centro Custo", NIL, "C", "@R 9.99.99"                 , NIL, "CTT", NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EZ_DESCCC"  , "02", "Descrição"   , "Descrição"   , NIL, "G", "@!"                         , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
    oStruct:AddField("EZ_VALOR"   , "03", "Valor"       , "Valor"       , NIL, "N", "@E 999,999,999.99"          , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EZ_PERC"    , "04", "Percentual"  , "Percentual"  , NIL, "N", "@E 999.99"                  , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .F., NIL, NIL, NIL)
    oStruct:AddField("EMPTY"      , "05", " "           , " "           , NIL, "G", "@!"                         , NIL, ""   , NIL, NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL, NIL)
EndIf

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu funcional.

@author  Wilson A. Silva Jr
@since   11/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       ACTION "VIEWDEF.ALFPMS30" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Rateio"           ACTION "VIEWDEF.ALFPMS30" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"          ACTION "VIEWDEF.ALFPMS30" 	OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS30ACT
Validacoes no carregamento do model.

@author  Wilson A. Silva Jr
@since   11/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PMS30ACT(oModel)

Local cTMP1  := ""
Local cQuery := ""

__lAtuaRat := .F.

cQuery := " SELECT "+ CRLF
cQuery += "     SUM(SEV.EV_VALOR) AS TOTNAT "+ CRLF
cQuery += "     ,COUNT(1) AS RATEIO "+ CRLF
cQuery += " FROM "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SEV.EV_FILIAL = '"+xFilial("SEV")+"' "+ CRLF
cQuery += "     AND SEV.EV_PREFIXO = '"+SE2->E2_PREFIXO+"' "+ CRLF
cQuery += "     AND SEV.EV_NUM = '"+SE2->E2_NUM+"' "+ CRLF
cQuery += "     AND SEV.EV_PARCELA = '"+SE2->E2_PARCELA+"' "+ CRLF
cQuery += "     AND SEV.EV_TIPO = '"+SE2->E2_TIPO+"' "+ CRLF
cQuery += "     AND SEV.EV_CLIFOR = '"+SE2->E2_FORNECE+"' "+ CRLF
cQuery += "     AND SEV.EV_LOJA = '"+SE2->E2_LOJA+"' "+ CRLF
cQuery += "     AND SEV.EV_RECPAG = 'P' "+ CRLF
cQuery += "     AND SEV.EV_IDENT = '1' "+ CRLF
cQuery += "     AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF()) .And. (cTMP1)->RATEIO > 0
    If (cTMP1)->TOTNAT <> SE2->E2_VALOR
        __lAtuaRat := MsgYesNo("O valor do título está diferente do rateio. Deseja atualizar o rateio?","Aviso")
    EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Carrega Grade para Alteração.

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadSE2(oFieldModel)

Local oStruct := oFieldModel:GetStruct()
Local aCampos := oStruct:GetFields()
Local aDados  := {}
Local cCampo  := ""
Local cTipo   := ""
Local nTamanho:= 0
Local nPos    := 0
Local nX

For nX := 1 To Len(aCampos)
    
    cCampo   := aCampos[nX][3]
    cTipo    := aCampos[nX][4]
    nTamanho := aCampos[nX][5]

    nPos := SE2->(FieldPos(cCampo))

    If nPos > 0
        AADD( aDados, SE2->(FieldGet(nPos)) )
    Else
        DO CASE
            CASE cTipo == "N"
                AADD( aDados, 0 )
            CASE cTipo == "L"
                AADD( aDados, .F. )
            OTHERWISE
                AADD( aDados, Space(nTamanho) )
        ENDCASE
    EndIf

Next nX

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Carrega Grade para Alteração.

@author  Wilson A. Silva Jr
@since   21/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadSEV(oGridModel)

Local aFields := oGridModel:GetStruct():GetFields()
Local nVlrTit := SE2->E2_VALOR
Local cQuery  := ""
Local cTMP1   := ""
Local aRetorno:= {}
Local nField  := 0

cQuery := " SELECT "+ CRLF
cQuery += "     SEV.R_E_C_N_O_ AS REGSEV "+ CRLF
cQuery += "     ,ISNULL(SED.ED_DESCRIC,' ') AS EV_DESCNAT "+ CRLF

For nField := 1 to Len(aFields)
    If !AllTrim(aFields[nField][3])+"|" $ "|EV_DESCNAT|EMPTY|"
        cQuery += "     ," + AllTrim(aFields[nField][3]) + CRLF
    EndIf
Next nField

cQuery += " FROM "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += "     ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += "     AND SED.ED_CODIGO = SEV.EV_NATUREZ "+ CRLF
cQuery += "     AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += "     SEV.EV_FILIAL = '"+xFilial("SEV")+"' "+ CRLF
cQuery += "     AND SEV.EV_PREFIXO = '"+SE2->E2_PREFIXO+"' "+ CRLF
cQuery += "     AND SEV.EV_NUM = '"+SE2->E2_NUM+"' "+ CRLF
cQuery += "     AND SEV.EV_PARCELA = '"+SE2->E2_PARCELA+"' "+ CRLF
cQuery += "     AND SEV.EV_TIPO = '"+SE2->E2_TIPO+"' "+ CRLF
cQuery += "     AND SEV.EV_CLIFOR = '"+SE2->E2_FORNECE+"' "+ CRLF
cQuery += "     AND SEV.EV_LOJA = '"+SE2->E2_LOJA+"' "+ CRLF
cQuery += "     AND SEV.EV_RECPAG = 'P' "+ CRLF
cQuery += "     AND SEV.EV_IDENT = '1' "+ CRLF
cQuery += "     AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += "     SEV.EV_NATUREZ "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(EOF())
    //Se não houver dados retorna um Array vazio
    aAux := Array(Len(aFields))

    For nField := 1 to Len(aFields)
        DO CASE
            CASE aFields[nField][04] == "C"
                aAux[nField] := Space(aFields[nField][05])
            CASE aFields[nField][04] == "N"
                aAux[nField] := 0
            CASE aFields[nField][04] == "L"
                aAux[nField] := .F.
            CASE aFields[nField][04] == "D"
                aAux[nField] := CtoD("")
        ENDCASE
    Next nField

    Aadd(aRetorno, {0 , aAux})
    aAux := {}
Else
    While (cTMP1)->(!EOF())

        SEV->(dbGoTo((cTMP1)->REGSEV))

        aAux := Array(Len(aFields))

        For nField := 1 to Len(aFields)
            DO CASE
                CASE AllTrim(aFields[nField][3]) == "EMPTY"
                    aAux[nField] := " "
                CASE AllTrim(aFields[nField][3]) == "EV_PERC"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3]) * 100
                CASE AllTrim(aFields[nField][3]) == "EV_VALOR" .And. __lAtuaRat
                    aAux[nField] := Round(( nVlrTit * (cTMP1)->EV_PERC ), TamSX3("EV_VALOR")[2])
                CASE aFields[nField][04] == "C"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3])
                CASE aFields[nField][04] == "N"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3])
                CASE aFields[nField][04] == "L"
                    aAux[nField] := .F.
                CASE aFields[nField][04] == "D"
                    aAux[nField] := StoD(&(cTMP1 + "->" + aFields[nField][3]))
            ENDCASE
        Next nField

        Aadd(aRetorno, {(cTMP1)->REGSEV, aAux})
        aAux := {}

        (cTMP1)->(dbSkip())
    EndDo
EndIf

(cTMP1)->(dbCloseArea())

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Carrega Grade para Alteração.

@author  Wilson A. Silva Jr
@since   21/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadSEZ(oGridModel)

Local aFields  := oGridModel:GetStruct():GetFields()
Local oModelPai:= oGridModel:GetModel()	// Carrega Model Master
Local cNaturez := oModelPai:GetModel('SEVDETAIL'):GetValue("EV_NATUREZ")
Local nVlrNat  := oModelPai:GetModel('SEVDETAIL'):GetValue("EV_VALOR")
Local cQuery   := ""
Local cTMP1    := ""
Local aRetorno := {}
Local nField   := 0

cQuery := " SELECT "+ CRLF
cQuery += "     SEZ.R_E_C_N_O_ AS REGSEZ "+ CRLF
cQuery += "     ,ISNULL(CTT.CTT_DESC01,' ') AS EZ_DESCCC "+ CRLF

For nField := 1 to Len(aFields)
    If !AllTrim(aFields[nField][3])+"|" $ "|EZ_DESCCC|EMPTY|"
        cQuery += "     ," + AllTrim(aFields[nField][3]) + CRLF
    EndIf
Next nField

cQuery += " FROM "+RetSqlName("SEZ")+" SEZ (NOLOCK) "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("CTT")+" CTT (NOLOCK) "+ CRLF
cQuery += "     ON CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
cQuery += "     AND CTT.CTT_CUSTO = SEZ.EZ_CCUSTO "+ CRLF
cQuery += "     AND CTT.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += "     SEZ.EZ_FILIAL = '"+xFilial("SEZ")+"' "+ CRLF
cQuery += "     AND SEZ.EZ_PREFIXO = '"+SE2->E2_PREFIXO+"' "+ CRLF
cQuery += "     AND SEZ.EZ_NUM = '"+SE2->E2_NUM+"' "+ CRLF
cQuery += "     AND SEZ.EZ_PARCELA = '"+SE2->E2_PARCELA+"' "+ CRLF
cQuery += "     AND SEZ.EZ_TIPO = '"+SE2->E2_TIPO+"' "+ CRLF
cQuery += "     AND SEZ.EZ_CLIFOR = '"+SE2->E2_FORNECE+"' "+ CRLF
cQuery += "     AND SEZ.EZ_LOJA = '"+SE2->E2_LOJA+"' "+ CRLF
cQuery += "     AND SEZ.EZ_NATUREZ = '"+cNaturez+"' "+ CRLF
cQuery += "     AND SEZ.EZ_RECPAG = 'P' "+ CRLF
cQuery += "     AND SEZ.EZ_IDENT = '1' "+ CRLF
cQuery += "     AND SEZ.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += "     SEZ.EZ_NATUREZ "+ CRLF
cQuery += "     ,SEZ.EZ_CCUSTO "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(EOF())
    //Se não houver dados retorna um Array vazio
    aAux := Array(Len(aFields))

    For nField := 1 to Len(aFields)
        DO CASE
            CASE aFields[nField][04] == "C"
                aAux[nField] := Space(aFields[nField][05])
            CASE aFields[nField][04] == "N"
                aAux[nField] := 0
            CASE aFields[nField][04] == "L"
                aAux[nField] := .F.
            CASE aFields[nField][04] == "D"
                aAux[nField] := CtoD("")
        ENDCASE
    Next nField

    Aadd(aRetorno, {0 , aAux})
    aAux := {}
Else
    While (cTMP1)->(!EOF())
        aAux := Array(Len(aFields))

        For nField := 1 to Len(aFields)
            DO CASE
                CASE AllTrim(aFields[nField][3]) == "EMPTY"
                    aAux[nField] := " "
                CASE AllTrim(aFields[nField][3]) == "EZ_PERC"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3]) * 100
                CASE AllTrim(aFields[nField][3]) == "EZ_VALOR" .And. __lAtuaRat
                    aAux[nField] := Round(( nVlrNat * (cTMP1)->EZ_PERC ), TamSX3("EZ_VALOR")[2])
                CASE aFields[nField][04] == "C"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3])
                CASE aFields[nField][04] == "N"
                    aAux[nField] := &(cTMP1 + "->" + aFields[nField][3])
                CASE aFields[nField][04] == "L"
                    aAux[nField] := .F.
                CASE aFields[nField][04] == "D"
                    aAux[nField] := StoD(&(cTMP1 + "->" + aFields[nField][3]))
            ENDCASE
        Next nField

        Aadd(aRetorno, {(cTMP1)->REGSEZ, aAux})
        aAux := {}

        (cTMP1)->(dbSkip())
    EndDo
EndIf

(cTMP1)->(dbCloseArea())

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS30ALT
Acionamento da View para rateio do título.

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS30ALT()

Local nOpc    := MODEL_OPERATION_UPDATE
Local cTela   := "Rateio"

Private __lAtuaRat := .F.

oModel := FWLoadModel("ALFPMS30")

FWExecView(cTela, "ALFPMS30", nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aBtnView*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel)

oModel:Destroy()

aRotina	:= MenuDef()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fCommit
Gravacao dos Dados do Modelo

@author  Wilson A. Silva Jr
@since   16/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fCommit(oModel)

Local lRetorno 	:= .T.
Local cMsgErro	:= ""

Begin Transaction
    //Gravacao do Rateio
    lRetorno := lRetorno .AND. GravaRateio(oModel, @cMsgErro)

    //Gravacao dos modelos
    //lRetorno := lRetorno .AND. FWFormCommit(oModel)

    If !lRetorno
        DisarmTransaction()
    EndIf

End Transaction

//Exibicao das Mensagens de Erro
// If lRetorno
//     Aviso("fCommit", "Pedido de Venda foi com sucesso: " + cNumPV, {"Fechar"})
// Else
//     Help(" ", 1, "Help", "fCommit", cMsgErro, 3, 0)
// EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaRateio
Gravacao do Rateio.

@author  Wilson A. Silva Jr
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaRateio(oModel, cMsgErro)

Local oModSE2	:= oModel:GetModel("SE2MASTER")
Local oModSEV	:= oModel:GetModel("SEVDETAIL")
Local oModSEZ	:= oModel:GetModel("SEZDETAIL")
Local nCampo    := 0
Local lRetorno	:= .T.
Local cChave    := ""
Local nX
Local nY

cChave := oModSE2:GetValue("E2_PREFIXO")
cChave += oModSE2:GetValue("E2_NUM")
cChave += oModSE2:GetValue("E2_PARCELA")
cChave += oModSE2:GetValue("E2_TIPO")
cChave += oModSE2:GetValue("E2_FORNECE")
cChave += oModSE2:GetValue("E2_LOJA")

dbSelectArea("SEV")
dbSetOrder(1) // EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ
If dbSeek(xFilial("SEV")+cChave)
    While SEV->(!EOF()) .And. SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) == xFilial("SEV")+cChave

        RecLock("SEV",.F.)
            dbDelete()
        MsUnlock()

        SEV->(dbSkip())
    EndDo
EndIf

dbSelectArea("SEZ")
dbSetOrder(1) // EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO
If dbSeek(xFilial("SEZ")+cChave)
    While SEZ->(!EOF()) .And. SEZ->(EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA) == xFilial("SEZ")+cChave

        RecLock("SEZ",.F.)
            dbDelete()
        MsUnlock()

        SEZ->(dbSkip())
    EndDo
EndIf

// Obtemos a estrutura de dados do item
aCposSEV  := oModSEV:GetStruct():GetFields()
aCposSEZ  := oModSEZ:GetStruct():GetFields()

For nX := 1 to oModSEV:Length()
    
    oModSEV:GoLine(nX)

    cNaturez := oModSEV:GetValue("EV_NATUREZ")
    nValor   := oModSEV:GetValue("EV_VALOR")

    If oModSEV:IsDeleted() .Or. Empty(cNaturez) .Or. nValor == 0
        LOOP
    EndIf

    RecLock("SEV",.T.)

        For nCampo := 1 To Len(aCposSEV)

            cCpoSEV := AllTrim(aCposSEV[nCampo][3])

            If (cCpoSEV+"|") $ "|EV_FILIAL|EV_PREFIXO|EV_NUM|EV_PARCELA|EV_TIPO|EV_CLIFOR|EV_LOJA|EV_DESCNAT|EV_PERC|EMPTY|"
                LOOP
            EndIf

            nPos := SEV->(FieldPos(cCpoSEV))
            
            If nPos > 0
                SEV->(FieldPut(nPos, oModSEV:GetValue(cCpoSEV)))
            EndIf

        Next nCampo

        REPLACE EV_FILIAL   WITH xFilial("SEV")
        REPLACE EV_PREFIXO  WITH oModSE2:GetValue("E2_PREFIXO")
        REPLACE EV_NUM      WITH oModSE2:GetValue("E2_NUM")
        REPLACE EV_PARCELA  WITH oModSE2:GetValue("E2_PARCELA")
        REPLACE EV_TIPO     WITH oModSE2:GetValue("E2_TIPO")
        REPLACE EV_CLIFOR   WITH oModSE2:GetValue("E2_FORNECE")
        REPLACE EV_LOJA     WITH oModSE2:GetValue("E2_LOJA")
        REPLACE EV_PERC     WITH (oModSEV:GetValue("EV_PERC") / 100)
        REPLACE EV_RATEICC  WITH "1"
        REPLACE EV_RECPAG   WITH "P"
        REPLACE EV_IDENT    WITH "1"

    MsUnlock()

    For nY := 1 to oModSEZ:Length()
    
        oModSEZ:GoLine(nY)

        cCusto := oModSEZ:GetValue("EZ_CCUSTO")
        nValor := oModSEZ:GetValue("EZ_VALOR")

        If oModSEZ:IsDeleted() .Or. Empty(cCusto) .Or. nValor == 0
            LOOP
        EndIf

        RecLock("SEZ",.T.)

            For nCampo := 1 To Len(aCposSEZ)

                cCpoSEZ := AllTrim(aCposSEZ[nCampo][3])

                If (cCpoSEZ+"|") $ "|EV_FILIAL|EV_PREFIXO|EV_NUM|EV_PARCELA|EV_TIPO|EV_CLIFOR|EV_LOJA|EV_NATUREZ|EZ_DESCCC|EMPTY|"
                    LOOP
                EndIf

                nPos := SEZ->(FieldPos(cCpoSEZ))
                
                If nPos > 0
                    SEZ->(FieldPut(nPos, oModSEZ:GetValue(cCpoSEZ)))
                EndIf

            Next nCampo

            REPLACE EZ_FILIAL   WITH xFilial("SEZ")
            REPLACE EZ_PREFIXO  WITH oModSE2:GetValue("E2_PREFIXO")
            REPLACE EZ_NUM      WITH oModSE2:GetValue("E2_NUM")
            REPLACE EZ_PARCELA  WITH oModSE2:GetValue("E2_PARCELA")
            REPLACE EZ_TIPO     WITH oModSE2:GetValue("E2_TIPO")
            REPLACE EZ_CLIFOR   WITH oModSE2:GetValue("E2_FORNECE")
            REPLACE EZ_LOJA     WITH oModSE2:GetValue("E2_LOJA")
            REPLACE EZ_NATUREZ  WITH oModSEV:GetValue("EV_NATUREZ")
            REPLACE EZ_PERC     WITH (oModSEZ:GetValue("EZ_PERC") / 100)
            REPLACE EZ_RECPAG   WITH "P"
            REPLACE EZ_IDENT    WITH "1"

        MsUnlock()

    Next nY

Next nX

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS30NAT
Calcula preços e desconto no item.

@author  Wilson A. Silva Jr
@since   21/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS30NAT(nTipo)

Local oView    := FWViewActive()
Local oModel   := FWModelActive()
Local oSE2     := oModel:GetModel('SE2MASTER')
Local oSEV     := oModel:GetModel('SEVDETAIL')
Local oSEZ     := oModel:GetModel('SEZDETAIL')
Local nVlrTit  := oSE2:GetValue("E2_VALOR")
Local cCodNat  := oSEV:GetValue("EV_NATUREZ")
Local nVlrNat  := oSEV:GetValue("EV_VALOR")
Local nPerc    := oSEV:GetValue("EV_PERC")
Local nLinAtu  := oSEV:nLine
Local lRetorno := .T.
Local nX       := 0
Local nTotCC   := 0

DO CASE
    CASE nTipo == 1
        
        dbSelectArea("SED")
        dbSetOrder(1) // ED_FILIAL+ED_CODIGO

        lRetorno := .F.
        
        DO CASE
            CASE Empty(cCodNat)
                Help(Nil,Nil,ProcName(),,"Por favor, informe a natureza.", 1, 5)
            CASE !SED->(dbSeek(xFilial("SED")+cCodNat))
                Help(Nil,Nil,ProcName(),,"Natureza informada inválida.", 1, 5)
            CASE !(SED->ED_TIPO == "2") 
                Help(Nil,Nil,ProcName(),,"Natureza infomada deve ser do tipo analitica.", 1, 5)
            CASE !(SED->ED_USO $ "0,2")
                Help(Nil,Nil,ProcName(),,"Natureza infomada não está disponivel para utilização no Contas a Pagar.", 1, 5)
            CASE SED->ED_MSBLQL == "1"
                Help(Nil,Nil,ProcName(),,"Natureza bloqueada para utilização.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno
            aSaveLines := FWSaveRows()
            
            For nX := 1 To oSEV:Length()
    
                oSEV:GoLine(nX)

                If cCodNat == oSEV:GetValue("EV_NATUREZ") .And. nLinAtu <> nX
                    Help(Nil,Nil,ProcName(),,"Natureza já informada na linha ("+cValToChar(nX)+").", 1, 5)
                    lRetorno := .F.
                EndIf
            Next nX
            
            FWRestRows(aSaveLines)
        EndIf

    CASE nTipo == 2
        
        lRetorno := .F.
        
        DO CASE
            CASE nVlrNat < 0
                Help(Nil,Nil,ProcName(),,"Por favor, informe um valor positivo.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno
            
            If nVlrTit > 0
                nPerc := Round(( nVlrNat / nVlrTit ) * 100,TamSX3("EV_PERC")[2])
            EndIf

            oSEV:SetValue("EV_PERC", nPerc)
            
            aSaveLines := FWSaveRows()
            
            For nX := 1 To oSEZ:Length()
    
                oSEZ:GoLine(nX)

                nVlrCC := Round((nVlrNat * oSEZ:GetValue("EZ_PERC")) / 100, TamSX3("EZ_VALOR")[2])

                nTotCC += nVlrCC

                oSEZ:SetValue("EZ_VALOR", nVlrCC)

            Next nX
            
            FWRestRows(aSaveLines)
        EndIf

    CASE nTipo == 3
        
        lRetorno := .F.
        
        DO CASE
            CASE nPerc < 0
                Help(Nil,Nil,ProcName(),,"Por favor, informe um percentual positivo.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno
        
            nVlrNat := Round(( nVlrTit * nPerc ) / 100, TamSX3("EV_VALOR")[2])

            oSEV:SetValue("EV_VALOR", nVlrNat)

            aSaveLines := FWSaveRows()
            
            For nX := 1 To oSEZ:Length()
    
                oSEZ:GoLine(nX)

                nVlrCC := Round((nVlrNat * oSEZ:GetValue("EZ_PERC")) / 100, TamSX3("EZ_VALOR")[2])

                nTotCC += nVlrCC

                oSEZ:SetValue("EZ_VALOR", nVlrCC)

            Next nX
            
            FWRestRows(aSaveLines)
        EndIf

    OTHERWISE
        lRetorno := .T.
ENDCASE

If lRetorno .And. nTipo > 1
    nDiff := (nVlrNat - nTotCC)
    oModel:GetModel('TOTCC'):SetValue("SLD_EZVALOR", If(nDiff > 0, nDiff * (-1), -99999999) )
EndIf

oView:Refresh("VIEWSEZ")
oView:Refresh("VIEW_TOTCC")

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS30CC
Calcula preços e desconto no item.

@author  Wilson A. Silva Jr
@since   21/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS30CC(nTipo)

Local oModel   := FWModelActive()
Local oSEV     := oModel:GetModel('SEVDETAIL')
Local oSEZ     := oModel:GetModel('SEZDETAIL')
Local nVlrNat  := oSEV:GetValue("EV_VALOR")
Local cCodCC   := oSEZ:GetValue("EZ_CCUSTO")
Local nVlrCC   := oSEZ:GetValue("EZ_VALOR")
Local nPerc    := oSEZ:GetValue("EZ_PERC")
Local nLinAtu  := oSEZ:nLine
Local lRetorno := .T.
Local nX       := 0

DO CASE
    CASE nTipo == 1
        
        dbSelectArea("CTT")
        dbSetOrder(1) // CTT_FILIAL+CTT_CUSTO

        lRetorno := .F.
        
        DO CASE
            CASE Empty(cCodCC)
                Help(Nil,Nil,ProcName(),,"Por favor, informe o centro de custo.", 1, 5)
            CASE !CTT->(dbSeek(xFilial("CTT")+cCodCC))
                Help(Nil,Nil,ProcName(),,"Centro de Custo informado inválido.", 1, 5)
            CASE !(CTT->CTT_CLASSE == "2") 
                Help(Nil,Nil,ProcName(),,"Centro de Custo infomado deve ser do tipo analitico.", 1, 5)
            CASE CTT->CTT_BLOQ == "1"
                Help(Nil,Nil,ProcName(),,"Centro de Custo bloqueado para utilização.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno
            aSaveLines := FWSaveRows()
            
            For nX := 1 To oSEZ:Length()
    
                oSEZ:GoLine(nX)

                If cCodCC == oSEZ:GetValue("EZ_CCUSTO") .And. nLinAtu <> nX
                    Help(Nil,Nil,ProcName(),,"Centro de Custo já informado na linha ("+cValToChar(nX)+").", 1, 5)
                    lRetorno := .F.
                EndIf
            Next nX
            
            FWRestRows(aSaveLines)
        EndIf

    CASE nTipo == 2
        
        lRetorno := .F.
        
        DO CASE
            CASE nVlrCC < 0
                Help(Nil,Nil,ProcName(),,"Por favor, informe um valor positivo.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno            
            If nVlrNat > 0
                nPerc := Round(( nVlrCC / nVlrNat ) * 100, TamSX3("EZ_PERC")[2])
            EndIf

            oSEZ:SetValue("EZ_PERC", nPerc)
        EndIf

    CASE nTipo == 3
        
        lRetorno := .F.
        
        DO CASE
            CASE nPerc < 0
                Help(Nil,Nil,ProcName(),,"Por favor, informe um percentual positivo.", 1, 5)
            OTHERWISE
                lRetorno := .T.
        ENDCASE

        If lRetorno
            nVlrCC := Round(( nVlrNat * nPerc ) / 100, TamSX3("EZ_VALOR")[2])

            oSEZ:SetValue("EZ_VALOR", nVlrCC)
        EndIf

    OTHERWISE
        lRetorno := .T.
ENDCASE

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} InitSldNat
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InitSldNat(oModel)

Local oModelPai  := oModel:GetModel()	// Carrega Model Master
Local nVlrTitulo := oModelPai:GetModel('SE2MASTER'):GetValue("E2_VALOR")

Return nVlrTitulo

//-------------------------------------------------------------------
/*/{Protheus.doc} ForSldNat
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ForSldNat(oModel, nTotalAtual, xValor, lSomando)

Local nRetorno := nTotalAtual

If lSomando
    nRetorno -= xValor
Else
    nRetorno += xValor
EndIf

nRetorno := Round(nRetorno, TamSX3("E2_VALOR")[2])

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} InitSldCC
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InitSldCC(oModel)

Local oModelPai  := oModel:GetModel()	// Carrega Model Master
Local nVlrTitulo := oModelPai:GetModel('SEVDETAIL'):GetValue("EV_VALOR")

Return nVlrTitulo

//-------------------------------------------------------------------
/*/{Protheus.doc} ForSldCC
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ForSldCC(oModel, nTotalAtual, xValor, lSomando)

Local nRetorno := nTotalAtual
Local nY

If xValor == -99999999
    nRetorno := 0
ElseIf xValor < 0
    nRetorno := ABS(xValor)
Else
    If lSomando
        nRetorno -= xValor
    Else
        nRetorno += xValor
    EndIf
EndIf

nRetorno := Round(nRetorno, TamSX3("E2_VALOR")[2])

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldModel
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldModel(oModel)

Local oModSE2	:= oModel:GetModel("SE2MASTER")
Local oModSEV	:= oModel:GetModel("SEVDETAIL")
Local oModSEZ	:= oModel:GetModel("SEZDETAIL")
Local nVlrTit   := oModSE2:GetValue("E2_VALOR")
Local cCodNat   := ""
Local cNaturez  := ""
Local cCodCC    := ""
Local nTotNat   := 0
Local nVlrNat   := 0
Local nTotCC    := 0
Local nVlrCC    := 0
Local nDiffNat  := 0
Local nDiffCC   := 0
Local lRetorno	:= .T.
Local nX
Local nY

For nX := 1 to oModSEV:Length()
    
    oModSEV:GoLine(nX)

    cCodNat  := oModSEV:GetValue("EV_NATUREZ")
    cNaturez := AllTrim(oModSEV:GetValue("EV_DESCNAT"))
    nVlrNat  := oModSEV:GetValue("EV_VALOR")

    If oModSEV:IsDeleted() .Or. Empty(cCodNat) .Or. nVlrNat == 0
        LOOP
    EndIf
    
    nTotNat += nVlrNat

    nTotCC := 0

    For nY := 1 to oModSEZ:Length()
    
        oModSEZ:GoLine(nY)

        cCodCC := oModSEZ:GetValue("EZ_CCUSTO")
        nVlrCC := oModSEZ:GetValue("EZ_VALOR")

        If oModSEZ:IsDeleted() .Or. Empty(cCodCC) .Or. nVlrCC == 0
            LOOP
        EndIf

        nTotCC += nVlrCC
    Next nY

    nDiffCC := Round(nVlrNat - nTotCC, 2)
    If nDiffCC <> 0
        Help(Nil,Nil,ProcName(),,"Valor da Natureza ("+cNaturez+") não foi totalmente rateado por Centro de Custo: " + Transform(nDiffCC, "@E 999,999,999.99"), 1, 5)
        lRetorno := .F.
        EXIT
    EndIf
Next nX

If lRetorno
    nDiffNat := Round(nVlrTit - nTotNat, 2)
    If nDiffNat <> 0
        Help(Nil,Nil,ProcName(),,"Valor do Título não foi totalmente rateado por Natureza: " + Transform(nDiffNat, "@E 999,999,999.99"), 1, 5)
        lRetorno := .F.
    EndIf
EndIf

Return lRetorno
