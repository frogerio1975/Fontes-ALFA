#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch' 
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS56

comissao

@author Pedro Oliveira
@since 25/11/2024
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS56()

Local oBrowse

Private  aRotina 	:= FwLoadMenuDef('ALFPMS56')

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "Z45" )
oBrowse:SetDescription( "Cadastro de Metas" )
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
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS56"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS56"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS56"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS56"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  
ADD OPTION aRotina Title "Copiar" 	  Action 'VIEWDEF.ALFPMS56' 	OPERATION 9 ACCESS 0

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

Local oStructZ45 := FWFormStruct(1,"Z45" ) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"Z37" )// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo
Local bLinePost := { |oModel| .t. }
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFPMS56",/*Pre-Validacao*/,/*Pos-Validacao*/ ,/*Commit*/,/*Cancel*/)

oModel:AddFields("Z45MASTER", Nil/*cOwner*/, oStructZ45 ,/*Pre-Validacao*/,bLinePost/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "Z45_FILIAL","Z45_ANO","Z45_MES" })
oModel:AddGrid('Z37GRID' , 'Z45MASTER',     oStructIt, /*bLinePre*/, bLinePost/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )                       
oModel:SetRelation( "Z37GRID", { { "Z37_FILIAL", 'xFilial( "Z37" )' },;
                                 { "Z37_ANO", "Z45_ANO" }       ,;
                                 { "Z37_MES", "Z45_MES" } }, Z37->( IndexKey( 1 ) ) )

oModel:GetModel( "Z37GRID" ):SetUniqueLine( { 'Z37_VEND' } )

oModel:GetModel("Z45MASTER"):SetDescription('Cadastro de Metas')//"Linhas"
oModel:GetModel("Z37GRID"  ):SetDescription('vendedores')//"Itens da Linhas"

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12 SUBSTR(X2_CHAVE,1,1)=='Z'
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("ALFPMS56")
Local oStructZ45 := FWFormStruct(2,"Z45") // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"Z37")// Informe que os campos do cabecalho nao devem aparecer nos itens

//oStructZ45:RemoveField( 'Z45_DRCDES' )

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWZ45" , oStructZ45, "Z45MASTER" )
oView:AddGrid (  "VIEWGZ37", oStructIt,  "Z37GRID" )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWZ45' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGZ37', 'INFERIOR' )

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEWGZ37', 'Z37_ITEM' )

oView:EnableTitleView( 'VIEWZ45' )
oView:EnableTitleView( 'VIEWGZ37')
                                                       	
Return oView

