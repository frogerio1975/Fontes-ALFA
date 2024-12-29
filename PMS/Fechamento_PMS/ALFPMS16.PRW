#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS16

RECURSO X PRODUTOS

@author Pedro Oliveira
@since 01/10/2019
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS16()
Local oBrowse

Private  aRotina 	:= FwLoadMenuDef('ALFPMS16')

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZJ' )
oBrowse:SetDescription( 'RECURSO X PRODUTOS' )

//1=Fechamento em Aberto;2=Fechamento Finalizado
oBrowse:AddLegend( " EMPTY(ZJ_DTDEV)", "GREEN"  , 'Produto com o recurso')
oBrowse:AddLegend( "!EMPTY(ZJ_DTDEV)", "RED"    , 'Produto devolvido')

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
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS16"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS16"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS16"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS16"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

ADD OPTION aRotina Title 'Rel.Produtos x Recursos' Action "U_ALFPMS17()"  OPERATION 9 ACCESS 0	

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

Local oStructSZJ := FWFormStruct(1,"SZJ",{|cCampo| (AllTrim(cCampo) $  "ZJ_RECUR/ZJ_NOME")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"SZJ",{|cCampo| !(AllTrim(cCampo) $ "ZJ_RECUR/ZJ_NOME" )})// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo
Local bPost := { |oModel| VldPosValid(oModel) }
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFPMS16",/*Pre-Validacao*/,bPost/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oStructIt:SetProperty( "ZJ_PRODUTO" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZJ_PRODUTO') } )

oModel:AddFields("SZJMASTER", Nil/*cOwner*/, oStructSZJ ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "ZJ_FILIAL","ZJ_RECUR","ZJ_PRODUTO"})
oModel:AddGrid  ('SZJGRID' , 'SZJMASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )                       
oModel:SetRelation( "SZJGRID", { { "ZJ_FILIAL", "xFilial('SZJ')" }, { "ZJ_RECUR", "ZJ_RECUR" }  }, SZJ->( IndexKey( 1 ) ) )
oModel:GetModel( "SZJGRID" ):SetUniqueLine( { 'ZJ_PRODUTO' } )                                                                 
oModel:GetModel("SZJMASTER"):SetDescription('RECURSO')//"Linhas"
oModel:GetModel("SZJGRID"  ):SetDescription('PRODUTOS')//"Itens da Linhas"

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
Local oModel       := FWLoadModel("ALFPMS16")
Local oStructSZJ := FWFormStruct(2,"SZJ",{|cCampo| (AllTrim(cCampo) $  "ZJ_RECUR/ZJ_NOME" )}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"SZJ",{|cCampo| !(AllTrim(cCampo) $ "ZJ_RECUR/ZJ_NOME" )})// Informe que os campos do cabecalho nao devem aparecer nos itens
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWSZJ" , oStructSZJ, "SZJMASTER" )
oView:AddGrid (  "VIEWGSZJ", oStructIt,  "SZJGRID" )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWSZJ' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGSZJ', 'INFERIOR' )
                               
oView:EnableTitleView( 'VIEWSZJ' )
oView:EnableTitleView( 'VIEWGSZJ')
                                                       	
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

Local oField    	:= oModel:GetModel("SZJGRID")
Local cLinha  		:= oField:GetValue(  'ZJ_PRODUTO' )

If nOperation ==  MODEL_OPERATION_INSERT .OR. nOperation ==  MODEL_OPERATION_UPDATE
    If  cCampo == 'ZJ_PRODUTO'

        SB1->( DbSetOrder(1) ) //SZJ_FILIAL+SZJ_LINHA+SZJ_CODIGO
        If !SB1->( DbSeek(xFilial('SB1') + cLinha  ))
            lRet  := .F.
            Help(,, 'HELP',, "Produto nao cadastrado.", 1, 0)
        Else
            oField:LoadValue('ZJ_DTGAR' , SB1->B1_XDTGAR )
        EndIf		

    Endif    
EndIf

RestArea(aArea)



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPosValid 
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
Static Function VldPosValid(oModel)
	Local oModel    := FwModelActive()
	Local nOperation    := oModel:GetOperation()
	Local lRet          := .T.
	Local aArea 		:= GetArea()
	Local ni            := 0
	Local oGrid    	    := oModel:GetModel("SZJGRID")
    Local cProd         := '' 
    Local dDtDev        := '' 
	If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE		
		For ni:= 1 to oGrid:Length()
			oGrid:GoLine(ni)
			If !oGrid:IsDeleted()
                cProd  := oGrid:GetValue("ZJ_PRODUTO")
                dDtDev := oGrid:GetValue("ZJ_DTDEV") 
				SB1->( DBSETORDER(1) )
                if SB1->( MSSEEK( XFILIAL('SB1')+ cProd  ) )                
                    SB1->( RECLOCK('SB1',.F.) )
                        SB1->B1_MSBLQL:= IIF( EMPTY(dDtDev),'1','2' ) //1=SIM;2=NAO
                    SB1->( MSUNLOCK() )
                end

			end
		next

	EndIf

	RestArea(aArea)
Return(lRet)
