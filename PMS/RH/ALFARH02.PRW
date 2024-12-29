#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFARH02

Cadastro de Area

@author Pedro Oliveira
@since 01/10/2019
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFARH02()
Local oBrowse
Private aRotina := MenuDef()
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'Z41' )
oBrowse:SetDescription( 'Cadastro de Area' )

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

Local aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"  		    OPERATION 0 ACCESS 0 
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFARH02"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFARH02"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFARH02"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFARH02"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

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

Local oStructZ41 := FWFormStruct(1,"Z41",{|cCampo| !(AllTrim(cCampo) $  "Z41_FILIAL|")}) // Informe os campos que eu quero no cabecalho
Local oModel := Nil  // objeto modelo
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFARH02",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("Z41MASTER", Nil/*cOwner*/, oStructZ41 ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "Z41_FILIAL","Z41_CODIGO"})
oModel:GetModel("Z41MASTER"):SetDescription('Cadastro de Area')//"Linhas"


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
Local oModel       := FWLoadModel("ALFARH02")
Local oStructZ41   := FWFormStruct(2,"Z41",{|cCampo| !(AllTrim(cCampo) $  "Z41_FILIAL|" )}) // Informe os campos que eu quero no cabecalho

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
//oView:AddField( "VIEWZ41" , oStructZ41, "Z41MASTER" )
oView:AddField( "VIEWZ41" , oStructZ41, "Z41MASTER" )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWZ41' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWZ41' )

Return oView
