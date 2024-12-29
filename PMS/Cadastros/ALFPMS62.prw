#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch' 
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS62

comissao

@author Pedro Oliveira
@since 25/11/2024
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS62()

Local oBrowse

Private  aRotina 	:= FwLoadMenuDef('ALFPMS62')

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "Z46" )
oBrowse:SetDescription( "Cadastro de Metas x Percentual" )
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
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS62"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS62"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS62"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS62"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  
ADD OPTION aRotina Title "Copiar" 	  Action 'VIEWDEF.ALFPMS62' 	OPERATION 9 ACCESS 0

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

Local oStructZ46 := FWFormStruct(1,"Z46" ) // Informe os campos que eu quero no cabecalho

Local oModel := Nil  // objeto modelo
Local bLinePost := { |oModel| .t. }
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFPMS62",/*Pre-Validacao*/,/*Pos-Validacao*/ ,/*Commit*/,/*Cancel*/)

oModel:AddFields("Z46MASTER", Nil/*cOwner*/, oStructZ46 ,/*Pre-Validacao*/,bLinePost/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "Z46_FILIAL","Z46_NUM"  })

oModel:GetModel("Z46MASTER"):SetDescription('Cadastro de Metas x Percentual')//"Linhas"


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
Local oModel       := FWLoadModel("ALFPMS62")
Local oStructZ46 := FWFormStruct(2,"Z46") // Informe os campos que eu quero no cabecalho

//oStructZ46:RemoveField( 'Z46_DRCDES' )

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWZ46" , oStructZ46, "Z46MASTER" )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWZ46' , 'SUPERIOR' )
// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEWGZ37', 'Z37_ITEM' )
oView:EnableTitleView( 'VIEWZ46' )

                                                       	
Return oView

