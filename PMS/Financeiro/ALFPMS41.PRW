#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS41
 
Descricao: Cadastro de Rateio x fornecedores

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS41()

Local oBrowse

Private aRotina 	:= FwLoadMenuDef('ALFPMS41')

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZ0' )
oBrowse:SetDescription( 'Cadastro de Rateio x fornecedores' )
oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()     

Private aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"  		    OPERATION 0 ACCESS 0 
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS41"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS41"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS41"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS41"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructSZR := FWFormStruct(1,"SZ0",{|cCampo| (AllTrim(cCampo) $  "Z0_FORNECE/Z0_LOJA/Z0_NOME/")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"SZ0",{|cCampo| !(AllTrim(cCampo) $ "Z0_FORNECE/Z0_LOJA/Z0_NOME" )})// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_CADSZR",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
//oStructSZR:SetProperty( "Z2_LINHA" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z2_LINHA') } )

oStructIt:SetProperty( "Z0_PERC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z0_PERC') } )


oModel:AddFields("SZ0MASTER", Nil/*cOwner*/, oStructSZR ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "Z0_FILIAL","Z0_FORNECE","Z0_LOJA","Z0_EMPRESA"})
oModel:AddGrid  ('SZ0GRID' , 'SZ0MASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )                       
oModel:SetRelation( "SZ0GRID", { { "Z0_FILIAL", "xFilial('SZ0')" }, { "Z0_FORNECE", "Z0_FORNECE" },{ "Z0_LOJA", "Z0_LOJA" }  }, SZ0->( IndexKey( 1 ) ) )

oModel:GetModel( "SZ0GRID" ):SetUniqueLine( { 'Z0_EMPRESA' } )   

//oModel:GetModel( "SZ0GRID" ):SetUniqueLine( { 'SZR_FILABA' } )   
//oModel:GetModel( "SZ0GRID" ):SetUniqueLine( { 'SZR_PRIABA' } )
oModel:GetModel("SZ0MASTER"):SetDescription('Cadastro de tratos')//"Linhas"
oModel:GetModel("SZ0GRID"  ):SetDescription('Tratos')//"Itens da Linhas"

oModel:AddCalc("TOTPERC", "SZ0MASTER", "SZ0GRID", "Z0_PERC" , "SUM_ZRPERC" , "SUM"     , /*bCond*/, /*bInitValue*/, "% Total"     , /*bFormula*/, 14, 2)

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/ 
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("ALFPMS41")
Local oStructSZR := FWFormStruct(2,"SZ0",{|cCampo| (AllTrim(cCampo) $  "Z0_FORNECE/Z0_LOJA/Z0_NOME" )}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"SZ0",{|cCampo| !(AllTrim(cCampo) $ "Z0_FORNECE/Z0_LOJA/Z0_NOME" )})// Informe que os campos do cabecalho nao devem aparecer nos itens
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWSZR" , oStructSZR, "SZ0MASTER" )
oView:AddGrid (  "VIEWGSZR", oStructIt,  "SZ0GRID" )

oView:AddField("VIEW_TOTPER" , FWCalcStruct(oModel:GetModel("TOTPERC")) , "TOTPERC")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )
oView:CreateHorizontalBox( 'TOTAL'   , 10 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWSZR' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGSZR', 'INFERIOR' )

oView:SetOwnerView("VIEW_TOTPER" , "TOTAL")

// Define campos que terao Auto Incremento

oView:EnableTitleView( 'VIEWSZR' )
oView:EnableTitleView( 'VIEWGSZR')
oView:EnableTitleView('VIEW_TOTPER'  , '% Total'  )                                     	

Return oView
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldTdOk 
@type				: Funcao estatica
@Sample				: VldTdOk(oModel)
@description	    : Realiza a validação do modelo de dados para o mesmo ser ativado.						
@Param				: oModel - Model a ser validado
@return				: lRet - .T. = Sucesso = .F. Erro
@ ------------------|----------------
@author				: Pedro Henrique Oliveira
@since				: 11/04/2019
@version			: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Static Function VldTdOk(oModel,cCampo)
Local oModel    := FwModelActive()
Local nOperation    := oModel:GetOperation()
Local lRet          := .T.
Local aArea 		:= GetArea()   
Local ni            := 0
Local oGrid    	    := oModel:GetModel("SZ0GRID")
//Local cLinha  		:= oField:GetValue(  'Z2_LINHA' )
Local nTotal := 0
If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE 
    If  cCampo == 'Z0_PERC'
        nLin    := oGrid:GetLine()
        xValue  := oGrid:GetValue("Z0_PERC")
        For nI := 1 to oGrid:Length()
            oGrid:GoLine(nI)
            If !oGrid:IsDeleted() //.and. ni <> nLin
                nTotal+= oGrid:GetValue("Z0_PERC")
            EndIf
        Next nI
        oGrid:GoLine(nLin)
        
        If nTotal > 100
            Help( ,, 'HELP',, "A somatoria do percentual não pode passar de 100 %.", 1, 0)
            lRet := .F.
        EndIf
    Endif    
EndIf

RestArea(aArea)
Return(lRet)
