#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
/*
SZG CADASTRO DE COMPETENCIA
SZH FECHAMENTO PMS CABECALHO
SZI FECHAMENTO PMS ITENS

CAD.COMPETENCIA
	ZG_CODIGO 		- 202309	
	ZG_DESCRICAO	- COMPETENCIA 09/2023
	ZG_HRSPREVISTA- 168
	ZG_DIASPREVISTOS - 21
	

FECHAMENTO PMS cabecalho
	ZH_COMPETENCIA - 202309 
	ZH_REVISAO		- 50	
	ZH_DESCRICAO   - HORAS PJ, HORAS CLT, HORAS COOP
	ZH_DTINI
	ZH_DTFIM
	ZH_DTPAGTO	
FECHAMENTO PMS itens
	ZI_COMPETENCIA - 202309 
	ZI_REVISAO		- 50	
	ZI_ITEM
	ZI_RECURSO
	ZI_NOME
	ZI_TIPO CONTRATO	

    ZI_VLRHORA 
	ZI_DIASPREVISTOS - 20
	ZI_HRSPREVISTA- 168	
	ZI_HRSREALIZADAS- 190
	ZI_HRSEXTRAS - (HRS REALIZADAS - HRS PREVISTA)
    ZI_VLRHREXTRA
    ZI_HRSDESCANSO 
    ZI_VLRDESCANSO
	ZI_VLRREEMBOLSO		
	ZI_TOTHRS = HORAS DESCANSO + HRS REALIZADAS
	ZI_DESADICIONAL
	ZI_VLRTOT = (VALOR DESCANSO+VALOR HORA/FIXO-DESCONTO ADICIONAL)
*/
#INCLUDE "Protheus.CH"       
#INCLUDE "TopConn.CH"   
#INCLUDE "TBIConn.CH"   
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS10
Descricao: CADASTRO DE COMPETENCIA

@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS10()

Local oBrowse
Private aRotina 	:= FwLoadMenuDef('ALFPMS10')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZG' )
oBrowse:SetDescription( 'CADASTRO DE COMPETENCIA' )

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
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS10"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS10"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS10"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS10"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

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

Local oStructSZG := FWFormStruct(1,"SZG",{|cCampo| !(AllTrim(cCampo) $  "ZG_FILIAL|")}) // Informe os campos que eu quero no cabecalho
Local oModel := Nil  // objeto modelo
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFPMS10",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("SZGMASTER", Nil/*cOwner*/, oStructSZG ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "ZG_FILIAL","ZG_CODIGO"})
oModel:GetModel("SZGMASTER"):SetDescription('CADASTRO DE COMPETENCIA')//"Linhas"


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
Local oModel       := FWLoadModel("ALFPMS10")
Local oStructSZG   := FWFormStruct(2,"SZG",{|cCampo| !(AllTrim(cCampo) $  "ZG_FILIAL|" )}) // Informe os campos que eu quero no cabecalho

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
//oView:AddField( "VIEWSZG" , oStructSZG, "SZGMASTER" )
oView:AddField( "VIEWSZG" , oStructSZG, "SZGMASTER" )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWSZG' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWSZG' )

Return oView
