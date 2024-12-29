#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __f3_xRet := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS11
 
Descricao: FECHAMENTO PMS

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS11( cGrupo )

Local oBrowse
Private x_cGrupo := cGrupo
Private aRotina 	:= FwLoadMenuDef('ALFPMS11')
Private lPMO:= x_cGrupo == 'PMO'
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZH' )
oBrowse:SetDescription( 'FECHAMENTO PMS' )


//1=Fechamento em Aberto;2=Fechamento Finalizado
oBrowse:AddLegend( "ZH_STATUS=='1'", "GREEN"    , 'Em Aberto')
oBrowse:AddLegend( "ZH_STATUS=='2'", "RED"    , 'Finalizado')

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

If x_cGrupo <> 'PMO'
	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"  		    OPERATION 0 ACCESS 0 
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS11"     OPERATION 1 ACCESS 0 
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS11"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS11"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS11"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

	//CADASTRO DE COMPETENCIA
	ADD OPTION aRotina TITLE "Cad.Competencia"    ACTION "U_AF11GCOM"     OPERATION 3    ACCESS 0  

	if x_cGrupo <> "RH"
		ADD OPTION aRotina Title 'Gerar Financeiro' Action "U_AF11GFIN(.t.)"  OPERATION 9 ACCESS 0	
		ADD OPTION aRotina Title 'Estornar Financeiro' Action "U_AF11GFIN(.f.)"  OPERATION 9 ACCESS 0	
	end
	ADD OPTION aRotina Title 'Rel.Fechamento'  Action "U_ALFPMS12()"  OPERATION 9 ACCESS 0	
	ADD OPTION aRotina Title 'Rel.Colaborador' Action "U_ALFPMS13()"  		OPERATION 9 ACCESS 0	
	ADD OPTION aRotina Title 'Rel.Fechamento PMO' Action "U_ALFPMS14()"  OPERATION 9 ACCESS 0	

	ADD OPTION aRotina Title 'Gerar Arquivo Corporis' Action "U_ALFPMS15()"  OPERATION 9 ACCESS 0	

Else
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS11"     OPERATION 1 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS11"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
	ADD OPTION aRotina Title 'Rel.Fechamento PMO' Action "U_ALFPMS14()"  OPERATION 9 ACCESS 0	

End

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

Local oStructSZH := FWFormStruct(1,"SZH")
Local oStructIt  := FWFormStruct(1,"SZI")
Local oModel := Nil  // objeto modelo
Local bPost := { |oModel| VldPosValid(oModel) }
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFPMS11",/*Pre-Validacao*/,bPost/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oStructSZH:SetProperty( "ZH_COMPETE" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZH_COMPETE') } )

oStructIt:SetProperty( "ZI_RECURSO"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_RECURSO') } )
oStructIt:SetProperty( "ZI_HRSREAL"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_HRSREAL') } )
oStructIt:SetProperty( "ZI_HRSEXTR"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_HRSEXTR') } )


oStructIt:SetProperty( "ZI_VLRREEM"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_VLRREEM') } )
oStructIt:SetProperty( "ZI_DESADIC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_DESADIC') } )
oStructIt:SetProperty( "ZI_HRSDESC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_HRSDESC') } )

oStructIt:SetProperty( "ZI_VLRADC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZI_VLRADC') } )


oModel:AddFields("SZHMASTER", Nil/*cOwner*/, oStructSZH ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "ZH_FILIAL","ZH_COMPETE","ZH_REVISAO"})
oModel:AddGrid  ('SZIGRID' , 'SZHMASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )                       

oModel:SetRelation( "SZIGRID", { { "ZI_FILIAL", "xFilial('SZI')"   },;  
							     { "ZI_COMPETE", "ZH_COMPETE" },;
								 { "ZI_REVISAO", "ZH_REVISAO" } }, SZI->( IndexKey( 1 ) ) )

oModel:GetModel( "SZIGRID" ):SetUniqueLine( { 'ZI_RECURSO' } )   

//oModel:GetModel( "SZIGRID" ):SetUniqueLine( { 'SZH_FILABA' } )   
//oModel:GetModel( "SZIGRID" ):SetUniqueLine( { 'SZH_PRIABA' } )
oModel:GetModel("SZHMASTER"):SetDescription('Fechamento PMS')//"Linhas"
oModel:GetModel("SZIGRID"  ):SetDescription('Recursos')//"Itens da Linhas"
 
If lPMO 
	oModel:AddCalc("TOTVLR", "SZHMASTER", "SZIGRID", "ZI_TOTHRS", "SUM_ZI_TOTHRS", "SUM"     , /*bCond*/, /*bInitValue*/, "Total Horas" , /*bFormula*/, 14, 2)
ELSE
	oModel:AddCalc("TOTVLR", "SZHMASTER", "SZIGRID", "ZI_VLRTOT", "SUM_ZI_VLRTOT", "SUM"     , /*bCond*/, /*bInitValue*/, "Valor Total" , /*bFormula*/, 14, 2)
END
//oModel:AddCalc("TOTPERC", "SZHMASTER", "SZIGRID", "ZH_PERC" , "SUM_ZRPERC" , "SUM"     , /*bCond*/, /*bInitValue*/, "% Total"     , /*bFormula*/, 14, 2)

// Validação de ativação do modelo
oModel:SetVldActivate( {|oModel| VLDACTMDL(oModel) } )

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
Local oModel       := FWLoadModel("ALFPMS11")
Local oStructSZH   := FWFormStruct(2,"SZH")
Local oStructIt    := FWFormStruct(2,"SZI")

If lPMO 
	oStructIt    := FWFormStruct(2,"SZI" ,{|cCampo| !(AllTrim(cCampo) $ "ZI_VLREAL|ZI_VLRHORA|ZI_VLRHREX/ZI_VLRDESC/ZI_DESADIC/ZI_VLRTOT/ZI_FIXO/ZI_VLRADC/ZI_OBSADC" )} )	
	
End
//oStructIt:RemoveField("ZZY_OPER")

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWSZH" , oStructSZH, "SZHMASTER" )
oView:AddGrid (  "VIEWGSZH", oStructIt,  "SZIGRID" )

oView:AddField("VIEW_TOTVLR", FWCalcStruct(oModel:GetModel("TOTVLR")), "TOTVLR")
//oView:AddField("VIEW_TOTPER" , FWCalcStruct(oModel:GetModel("TOTPERC")) , "TOTPERC")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

oView:CreateHorizontalBox( 'CALC', 10 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWSZH' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGSZH', 'INFERIOR' )

oView:SetOwnerView( 'VIEW_TOTVLR', 'CALC' )


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEWGSZH', 'ZI_ITEM' )

oView:EnableTitleView( 'VIEWSZH' )
oView:EnableTitleView( 'VIEWGSZH')

oView:EnableTitleView('VIEW_TOTVLR'  , 'Valor Total'  )

// Adicione botão de legenda.
oView:AddUserButton( 'Importar recursos', 'CLIPS', { |oView| ImpRecur() } )

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
Local oField  	    := oModel:GetModel("SZHMASTER")
Local oGrid    	    := oModel:GetModel("SZIGRID")

Local nDiasPrev  := 0
Local nHorasPrev := 0

If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE 
    If  cCampo == 'ZH_COMPETE'

		cAux := oField:GetValue(  'ZH_COMPETE' ) 
        SZG->( DbSetOrder(1) ) //ZYV_FILIAL+ZYV_LINHA+ZYV_CODIGO
        If !SZG->( DbSeek(xFilial('SZG') + cAux  ))
            lRet  := .F.
            Help(,, 'HELP',, "Competencia não cadastrada.", 1, 0)
        Else		
			cret:= GetMaxRev('SZH','ZH_REVISAO','ZH_FILIAL',  cAux )
			oField:LoadValue('ZH_REVISAO' , cret )
		End

	//ElseIf cCampo $ 'ZI_VLRREEM/ZI_DESADIC'				
		/*
		If !oGrid:GetValue(  'ZI_TIPO' )  $ '3/4'
			oGrid:LoadValue('ZI_VLRTOT' 	 , oGrid:GetValue(  'ZI_FIXO' )  + oGrid:GetValue(  'ZI_VLRREEM' )  - oGrid:GetValue(  'ZI_DESADIC' ) +oGrid:GetValue(  'ZI_VLRDESC' )  )
		else
			oGrid:LoadValue('ZI_VLRTOT' , oGrid:GetValue(  'ZI_TOTHRS' )  * oGrid:GetValue(  'ZI_VLRHORA' ) +  oGrid:GetValue(  'ZI_VLRREEM' ) - oGrid:GetValue(  'ZI_DESADIC' )  )
		end
*/
	ElseIf cCampo $ 'ZI_VLRREEM/ZI_DESADIC/ZI_HRSDESC/ZI_VLRADC'				 //== 'ZI_HRSDESC'
		oGrid:LoadValue('ZI_TOTHRS' , oGrid:GetValue(  'ZI_HRSREAL' ) +  oGrid:GetValue(  'ZI_HRSDESC' ) + oGrid:GetValue(  'ZI_HRSEXTR' ) )
		oGrid:LoadValue('ZI_VLRDESC', oGrid:GetValue(  'ZI_HRSDESC' ) *  oGrid:GetValue(  'ZI_VLRHORA' ) )
		If !oGrid:GetValue(  'ZI_TIPO' )  $ '3/4'
			nAux := oGrid:GetValue(  'ZI_FIXO' ) ; 
					+oGrid:GetValue(  'ZI_VLRREEM' );
					-oGrid:GetValue(  'ZI_DESADIC' );
					+oGrid:GetValue(  'ZI_VLRHREX' );
					+oGrid:GetValue(  'ZI_VLRADC' )  			
			/*
			nAux := oGrid:GetValue(  'ZI_FIXO' ) ; 
					+oGrid:GetValue(  'ZI_VLRREEM' );
					-oGrid:GetValue(  'ZI_DESADIC' );
					+oGrid:GetValue(  'ZI_VLRDESC' );
					+oGrid:GetValue(  'ZI_VLRHREX' );
					+oGrid:GetValue(  'ZI_VLRADC' )  
					*/ 
			oGrid:LoadValue('ZI_VLRTOT' ,  nAux ) 
		Else
			nAux:= (oGrid:GetValue(  'ZI_TOTHRS' ) * oGrid:GetValue(  'ZI_VLRHORA' ) ) ;
				   +oGrid:GetValue(  'ZI_VLRREEM' );
				   -oGrid:GetValue(  'ZI_DESADIC' );
				   +oGrid:GetValue(  'ZI_VLRADC' ) 
			oGrid:LoadValue('ZI_VLRTOT' ,  nAux )
		End
	ElseIf alltrim(cCampo) $ 'ZI_HRSREAL/ZI_HRSEXTR'
		
		oGrid:LoadValue('ZI_TOTHRS' , oGrid:GetValue(  'ZI_HRSREAL' ) +  oGrid:GetValue(  'ZI_HRSDESC' ) + oGrid:GetValue(  'ZI_HRSEXTR' ) )

		If !oGrid:GetValue(  'ZI_TIPO' )  $ '3/4'

			nHrReal := oGrid:GetValue(  'ZI_HRSREAL' ) 
			nHrPrev := oGrid:GetValue(  'ZI_HRSPREV' ) 
			
			nExtra :=  oGrid:GetValue(  'ZI_HRSEXTR' ) ///nHrReal - nHrPrev
			nVlExtra := nExtra * oGrid:GetValue(  'ZI_VLRHORA' ) 
			oGrid:LoadValue('ZI_HRSEXTR' 	 , nExtra )		
			oGrid:LoadValue('ZI_VLRHREX' 	 , nVlExtra )
			nAux := oGrid:GetValue(  'ZI_FIXO' ) ; 
					+oGrid:GetValue(  'ZI_VLRREEM' );
					-oGrid:GetValue(  'ZI_DESADIC' );
					+oGrid:GetValue(  'ZI_VLRHREX' );
					+oGrid:GetValue(  'ZI_VLRADC' )  				
			/*
			nAux := oGrid:GetValue(  'ZI_FIXO' ) ; 
					+oGrid:GetValue(  'ZI_VLRREEM' );
					-oGrid:GetValue(  'ZI_DESADIC' );
					+oGrid:GetValue(  'ZI_VLRDESC' );
					+oGrid:GetValue(  'ZI_VLRHREX' );
					+oGrid:GetValue(  'ZI_VLRADC' )   
					*/			
			oGrid:LoadValue('ZI_VLRTOT' 	 ,   nAux  )
			oGrid:LoadValue('ZI_VLREAL' ,   oGrid:GetValue(  'ZI_FIXO' ) )
		Else			
			nAux:= (oGrid:GetValue(  'ZI_TOTHRS' ) * oGrid:GetValue(  'ZI_VLRHORA' ) ) ;
					+oGrid:GetValue(  'ZI_VLRREEM' );
					-oGrid:GetValue(  'ZI_DESADIC' );
					+oGrid:GetValue(  'ZI_VLRADC' ) 
			oGrid:LoadValue('ZI_VLRTOT' ,  nAux  )
			oGrid:LoadValue('ZI_VLREAL' ,  (oGrid:GetValue(  'ZI_TOTHRS' ) * oGrid:GetValue(  'ZI_VLRHORA' ) )  )
		end
		
		//oGrid:LoadValue('ZI_TOTHRS' , oGrid:GetValue(  'ZI_HRSREAL' ) +  oGrid:GetValue(  'ZI_HRSDESC' ) )

		
		

	ElseIf cCampo == 'ZI_RECURSO'

		cAux := oField:GetValue(  'ZH_COMPETE' ) 
        SZG->( DbSetOrder(1) ) //ZYV_FILIAL+ZYV_LINHA+ZYV_CODIGO
        If SZG->( DbSeek(xFilial('SZG') + cAux  ))
			nDiasPrev  := SZG->ZG_DIASPRE
			nHorasPrev := SZG->ZG_HRSPREV
		end

		cAux := oGrid:GetValue(  'ZI_RECURSO' ) 

        AE8->( DbSetOrder(1) ) //ZYV_FILIAL+ZYV_LINHA+ZYV_CODIGO
        If !AE8->( DbSeek(xFilial('AE8') + cAux  ))
            lRet  := .F.
            Help(,, 'HELP',, "Recurso não cadastrado.", 1, 0)
        Elseif AE8->AE8_TPCONT == '1'
            lRet  := .F.
            Help(,, 'HELP',, "Fechamento não disponivel para recurso CLT.", 1, 0)
		Elseif EMPTY( AE8->AE8_CODFOR ) 
            lRet  := .F.
            Help(,, 'HELP',, "Fornecedor não vinculado ao Recurso.", 1, 0)		
		Else		

			//1=CLT;2=PJ;3=PJ Horista;4=Cooperado Horista;5=Cooperado Mensalista
			oGrid:LoadValue('ZI_FORNECE' , AE8->AE8_CODFOR )
			oGrid:LoadValue('ZI_LOJA' 	 , AE8->AE8_LJFOR )

			oGrid:LoadValue('ZI_NOME' 	 , AE8->AE8_NREDUZ )
			oGrid:LoadValue('ZI_TIPO' 	 , AE8->AE8_TPCONT )
			oGrid:LoadValue('ZI_DIASPRE' , nDiasPrev	   )
			oGrid:LoadValue('ZI_HRSPREV' , nHorasPrev      )
			oGrid:LoadValue('ZI_TOTHRS'  , nHorasPrev      )
			If alltrim(AE8->AE8_TPCONT) $ '3/4'// PJ E COOP HORISTA
				oGrid:LoadValue('ZI_VLRHORA' , AE8->AE8_CUSFIX )
				oGrid:LoadValue('ZI_FIXO'    , AE8->AE8_CUSFIX * nHorasPrev )				
			Else
				//oGrid:LoadValue('ZI_VLRHORA' , ROUND( AE8->AE8_CUSFIX / nHorasPrev,2) )
				nPrevHors := SuperGetMv("AF_PREVHR",.F. , 176 )
				oGrid:LoadValue('ZI_VLRHORA' , ROUND( AE8->AE8_CUSFIX / nPrevHors ,2) )
				oGrid:LoadValue('ZI_FIXO'    , AE8->AE8_CUSFIX  )
			End
			//oGrid:LoadValue('ZI_VLREAL'  , oGrid:GetValue(  'ZI_FIXO' ) )
			//oGrid:LoadValue('ZI_VLRTOT'  , oGrid:GetValue(  'ZI_FIXO' ) )
		End
		
    Endif    
EndIf

RestArea(aArea)
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} GetMaxRev
Descricao: RETORNA MAX REVISAO

@version 1.0
/*/
//-------------------------------------------------------------------
Static function GetMaxRev(cTabela, cCampo, cFiltab, cCompet)
    Local _cAreas   := getArea()
    Local cQuery    := ""
    Local cAliasTOP := GetNextAlias()    
    Local cRet      := ""

    cQuery := "SELECT MAX("+cCampo+") AS NUMERO "+CRLF
    cQuery += "FROM "+retSqlName(cTabela)+ " TAB "+CRLF
    cQuery += "WHERE TAB.D_E_L_E_T_ = ' ' AND TAB."+cFiltab+" = '"+cFilAnt+"' "+CRLF
	cQuery += " 	AND ZH_COMPETE = '"+cCompet+"' "+CRLF

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)    

    cRet := strZero(val((cAliasTop)->NUMERO)+1,TamSx3(cCampo)[1])

    (cAliasTop)->(DbCloseArea())

    RestArea(_cAreas)

return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpRecur
Descricao: TELA PARAMETRO

@version 1.0
/*/
//-------------------------------------------------------------------
Static function ImpRecur()

Local aParamBox	:= {}
Local aRet		:= {}

Local cCttFormat    := CriaVar("CTT_CUSTO",.F.)
Local cAreaFor    := CriaVar("AE8_AREA",.F.) 
Private aEmpFat  := { "1=ALFA(07)", "2=MOOVE", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
Private cEmpFat  := "1"

//1=CLT;2=PJ;3=PJ Horista;4=Cooperado Horista;5=Cooperado Mensalista
//Aadd( aParamBox,{3,"Produtos",1,{"Todos","SAP","TOTVS"},50,"",.T.})
aAdd(aParamBox,  {1,"Tipo contrato"	            ,Space( 10 ),"","","U_AFTPCONT()","",50,.T.}) 
aAdd( aParamBox, { 1, "Centro de custo De:"		, cCttFormat, , '.T.', "CTT", "", 50, .F.} )
aAdd( aParamBox, { 1, "Centro de custo Ate:"	, cCttFormat, , '.T.', "CTT", "", 50, .T.} )

aAdd( aParamBox, { 1, "Área De:"		, cAreaFor, , '.T.', "Z41", "", 50, .F.} )
aAdd( aParamBox, { 1, "Área Ate:"		, cAreaFor, , '.T.', "Z41", "", 50, .T.} )
AADD( aParamBox, { 2, "Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )

If ParamBox(aParamBox,"Filtros...",@aRet)
	ProcRecurs( aRet )
end

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AFTPCONT
Descricao: TELA PARAMETRO

@version 1.0
/*/
//-------------------------------------------------------------------
USER FUNCTION AFTPCONT()
Local aLayOut:={}// {{.t.,'01','02'},{.f.,'02','02'}}
Local ni:= 0

//1=CLT;2=PJ;3=PJ Horista;4=Cooperado Horista;5=Cooperado Mensalista
aadd(aLayOut, { .f.,'2','PJ' } )
aadd(aLayOut, { .f.,'3','PJ Horista' } )
aadd(aLayOut, { .f.,'4','Cooperado Horista' } )
aadd(aLayOut, { .f.,'5','Cooperado Mensalista' } )

MV_PAR01:= ''
If TMSABrowse( aLayOut, 'Escolha os tipos de contrato(s) ',,,,.F., { 'Tipo', 'Descrição'} )
    for ni:=1 to len(aLayOut)
        if aLayOut[ni][1] 
            MV_PAR01 +=  aLayOut[ni][2] + iif( ni <>  len(aLayOut), ',' ,'')
        EndIf
    Next ni
    //MV_PAR01:= substr(MV_PAR01,1,len(MV_PAR01)-1)
EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRecurs
Descricao: TELA PARA DADOS

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcRecurs( aRetParam,lF3 )

Local oModulos
Local oDescMod
Local oFornece
Local oPanel1
Local oPanel2
Local oPanel3
Local oDlg
Local oPanDlg
Local oMemo
Local oMemo2
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local oOk      := LoadBitmap( GetResources(), "LBOK" )
Local xGetDados2 := nil
Local oCombo01 := nil
Local aModulos := {}
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}
Local aPrdEst2 := {}
Local aRetMd   := {}
Local aCombo   := {}
Local aRetSx3  := {}
Local nModulo  := 0
local ni       := 0

Local cMemo    := CriaVar("Z00_COMPLE")
Local cMemo2   := CriaVar("Z00_COMPLE")
Local cFornece := CriaVar("A2_NREDUZ",.F.)
Local cModulo  := CriaVar("Z00_DESCRI",.F.)
local nx := 0
Local cCombo01 := ""

Local oModel    := FwModelActive()
Local oGrid    	:= oModel:GetModel("SZIGRID")

Local xRet := .t.
Private oFntP 			:= TFont():New( "Arial",,18,,.T.,,,,,.F.)
Private oFntSay 		:= TFont():New( "Arial",,14,,.T.,,,,,.F.)

Default lF3 := .f.

aRetSx3 := RetSX3Box(GetSX3Cache("Z00_TPLICE", "X3_CBOX"),,,1)
For nI:=1 To Len(aRetSx3)
	If !Empty(AllTrim(aRetSx3[nI][1]))
		aAdd(aCombo,aRetSx3[nI][1])
	EndIf
Next nI 
cCombo01:= SUBSTR(aCombo[ Len(aCombo)],1,1)

aSize    := MsAdvSize(.T.,.T.,500)
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ] , 0, 0 }

aSize[3]:= aSize[3]*1.5
aSize[4]:= aSize[4]*2

aAdd( aObjects, { 100, 095, .T., .T.} )
aAdd( aObjects, { 100, 005, .T., .T.} )
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 700,1200 TITLE "Recursos" Of oMainWnd PIXEL STYLE DS_MODALFRAME 

oDlg:lEscClose := .F.
oDlg:lMaximized := .T.

oPanDlg:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPanDlg:Align:= CONTROL_ALIGN_ALLCLIENT

oFwLayer := FwLayer():New()
oFwLayer:Init(oPanDlg,.F.)

oFWLayer:addLine("LINHA1",15, .F.)
oFWLayer:addCollumn("COL1"	,100, .T. , "LINHA1")
oFWLayer:addWindow( "COL1", "WIN1", "Dados para Filtro",100, .F., .T., , "LINHA1")
oPanel1	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA1")

oFWLayer:addLine("LINHA2",80, .F.)
oFWLayer:addCollumn("COL1"	,100, .T. , "LINHA2")
//oFWLayer:addCollumn("COL2"	,50, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", "",100, .F., .T., , "LINHA2")
//oFWLayer:addWindow( "COL2", "WIN2", "Tabela de Preco",100, .F., .T., , "LINHA2")
oPanel2	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA2")
//oPanel99:= oFWLayer:GetWinPanel("COL2", "WIN2","LINHA2")

/*
oFWLayer:addLine("LINHA3",25, .F.)
oFWLayer:addCollumn("COL1"	,50, .T. , "LINHA3")
oFWLayer:addCollumn("COL2"	,50, .T. , "LINHA3")
oFWLayer:addWindow( "COL1", "WIN1", "Premissa",100, .F., .T., , "LINHA3")
oFWLayer:addWindow( "COL2", "WIN1", "Descricao detalhada",100, .F., .T., , "LINHA3")
oPanel3	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA3")
oPanel98:= oFWLayer:GetWinPanel("COL2", "WIN1","LINHA3")

@ 001,001 GET oMemo VAR cMemo MEMO SIZE 200,145 OF oPanel3 PIXEL
oMemo:Align := CONTROL_ALIGN_ALLCLIENT

@ 001,001 GET oMemo2 VAR cMemo2 MEMO SIZE 200,145 OF oPanel98 PIXEL
oMemo2:Align := CONTROL_ALIGN_ALLCLIENT
*/

//@ 001,005 SAY "Recurso"							OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK 	
//@ 010,005 MSGET oFornece VAR cFornece Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14 ON CHANGE FilModulo(cFornece,cModulo,@aModulos,@oModulos,@aRetMd,cCombo01)

@ 001,005 SAY "Recurso"							OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK 	
@ 010,005 MSGET oFornece VAR cFornece Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14 ON CHANGE FilModulo(aRetParam,cFornece,cModulo,@aModulos,@oModulos,@aRetMd,cCombo01)

@ 001,110 SAY "Nome"								OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK
@ 010,110 MSGET oDescMod VAR cModulo  Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14  ON CHANGE FilModulo(aRetParam,cFornece,cModulo,@aModulos,@oModulos,@aRetMd,cCombo01)


Aadd(aModulos,{.F.,"","","","" })
oModulos:= TwBrowse():New(0,0,0,0,,{" ",Padr("Codigo",20),Padr("Nome",120),Padr("Tp.Contrato",15),Padr("C.Custo",30) },,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oModulos:SetArray(aModulos)
oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,1],oOk,oNo),;
				 		aModulos[oModulos:nAt,2],;
				 		aModulos[oModulos:nAt,3],;
						aModulos[oModulos:nAt,4],;
						aModulos[oModulos:nAt,5] }}

oModulos:BlDblClick	 := {|| AtuMarca(@oModulos,@aModulos,@aRetMd,lF3)}	
//oModulos:bHeaderClick:= { |oObj,nCol| SyOrdena(nCol,@oModulos,@aModulos,@lOrdemCols) }
//oModulos:bChange	 := {|| (nModulo:= oModulos:nAt, AtuObs(oModulos,@cMemo,@oMemo,@cMemo2,@oMemo2), AtuTabPrc( aModulos[oModulos:nAt,1] ,@xGetDados2,@aPrdEst2) ) }
oModulos:Refresh()
oModulos:Align:= CONTROL_ALIGN_ALLCLIENT

//xGetDados2:= MsNewGetDados():New(0,0,0,0, 0,"Allwaystrue","Allwaystrue"	,cIniCpos,aCposAlt2,000,9999,"Allwaystrue","Allwaystrue","Allwaystrue",oPanel99,@aHdPrd2,@aPrdEst2,)
//xGetDados2:oBrowse:Refresh()
//xGetDados2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 		
//xGetDados2:Refresh()
IF !lF3
	//DEFINE SBUTTON oBtnOk FROM 001,450 TYPE 1 ENABLE OF oPanel1;
	//       ACTION (nModulo := oModulos:nAt, oDlg:End())
	@ 001,450 BUTTON  "Marcar Todos"       SIZE 50,12 ACTION MarcaTodos(.T.,@oModulos,@aModulos,@aRetMd) PIXEL OF oPanel1
	@ 016,450 BUTTON  "Desmarcar Todos"    SIZE 50,12 ACTION MarcaTodos(.F.,@oModulos,@aModulos,@aRetMd) PIXEL OF oPanel1
END
DEFINE SBUTTON oBtnOk FROM 001,550 TYPE 1 ENABLE OF oPanel1;
       ACTION (nModulo := oModulos:nAt, oDlg:End())

DEFINE SBUTTON oBtnCancel FROM 016,550 TYPE 2 ENABLE OF oPanel1;
       ACTION  (nModulo := 0,oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oFornece:SetFocus(), Eval(oFornece:bChange))

If !lF3
		
	If nModulo
		
		nTotLin :=  oGrid:GetQtdLine()		
		//Verifica quais foram os itens marcados
		For nX:= 1 To Len(aModulos)
			if aModulos[nX][1]
				
				If !oGrid:SeekLine( { {"ZI_RECURSO", aModulos[nX][2] } } )
					nLinAtu:= oGrid:GetLine()
					oGrid:AddLine() //!= nLinAtu //SOMENTE SE NAO BATER O CONTADOR COM RETORNO DO ADDLINE = ERROR
					
					oGrid:SetValue('ZI_RECURSO'  ,  aModulos[nX][2]   )

					lOk := oGrid:VldLineData()
					If !lOk
						Help( ,, 'HELP',, 'Error insert line...Grid' + CRLF + oGrid:getErrorMessage()[6], 1, 0)
					End
				end
				
				/*
				nScan := 0
				If nscan == 0

				End
				*/
			end
			/*
			oModelAZY:GoLine(1)

			For nI := 1 To oModelAZY:Length()
				oModelAZY:GoLine( nI )
				If !oModelAZY:IsDeleted()
					oModelAZY:DeleteLine()
				EndIf
			Next nI
			*/
		next nx
	End
Else
	//xRet:= ''
	For nX:= 1 To Len(aModulos)
		if aModulos[nX][1]
			xRet	 := .t.//aModulos[nX][2]
			__f3_xRet:= aModulos[nX][2]
			exit
		End
	Next		
End
 
Return xRet
//-------------------------------------------------------------------
/*/{Protheus.doc} FilModulo
Descricao: FILTRA DADOS

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilModulo(aRetParam,cFornece,cModulo,aModulos,oModulos,aRetMd,cCombo01)
Local cQuery  := ""
Local oNo     := LoadBitmap( GetResources(), "LBNO" )
Local oOk     := LoadBitmap( GetResources(), "LBOK" )
Local nX:= 0
Local lMark := .f.

Local aTipo  := RetSX3Box(GetSX3Cache("AE8_TPCONT", "X3_CBOX"),,,1)
Local cTipos := FormatIn(  aRetParam[1] ,",") 

For nX:= 1 To Len(aModulos)	
	If aModulos[nX][1] .and. AScan(aRetMd, aModulos[nX,2] ) == 0
		aadd(aRetMd	, aModulos[nX,2] )
	EndIf	
Next nX

aModulos:= {}

cQuery+= " SELECT DISTINCT AE8_RECURS,AE8_DESCRI,AE8_TPCONT,A2_XCC "+CRLF
cQuery+= " FROM " + RetSqlName("AE8") + " AE8 "+CRLF
cQuery+= " INNER JOIN SA2010 SA2"+CRLF
cQuery+= " 	ON A2_FILIAL = ''"+CRLF
cQuery+= " AND A2_COD =  AE8_CODFOR"+CRLF
cQuery+= " AND A2_LOJA = AE8_LJFOR"+CRLF
cQuery+= " AND A2_XCC BETWEEN '"+aRetParam[2]+"' AND '"+aRetParam[3]+"' "+CRLF
cQuery+= " WHERE AE8.D_E_L_E_T_ = '' "+CRLF
cQuery+= " AND AE8.AE8_CODFOR <> '' "+CRLF
cQuery+= " AND AE8.AE8_ATIVO <> '2' "+CRLF
If !Empty(cFornece)
	cQuery+= " AND AE8.AE8_RECURS LIKE '%" + AllTrim(cFornece) + "%' "+CRLF
EndIf

If !Empty(cModulo)
	cQuery+= " AND AE8.AE8_DESCRI LIKE '%" + AllTrim(cModulo) + "%' "+CRLF
EndIf


cQuery+= " AND AE8_AREA BETWEEN '"+aRetParam[4]+"' AND '"+aRetParam[5]+"' "+CRLF
If !empty(aRetParam[6])	
	cQuery+= " AND AE8.AE8_EMPFAT = '"+aRetParam[6]+"' "+CRLF
End

cQuery+= " AND AE8.AE8_TPCONT IN "+cTipos+CRLF

cQuery+= " ORDER BY AE8_RECURS,AE8_DESCRI "+CRLF
cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ00",.T.,.T.)

//dbSelectArea("TMPZ00")
//dbGoTop()

While !Eof()
	lMark :=  aScan( aRetMd , TMPZ00->AE8_RECURS) > 0
	xaux:=''
	NSCAN := ASCAN(aTipo,{|X| X[2] == TMPZ00->AE8_TPCONT })
	IF NSCAN > 0
		xaux:= aTipo[NSCAN][3] 
	END

	aAdd(aModulos,{ lMark ,TMPZ00->AE8_RECURS,TMPZ00->AE8_DESCRI,xaux , TMPZ00->A2_XCC})
	
	
	TMPZ00->(dbSkip())
End
TMPZ00->(dbCloseArea())
    
If (Len(aModulos) == 0) 
	aAdd(aModulos,{.F.,CriaVar("AE8_RECURS",.F.),CriaVar("AE8_DESCRI",.F.),CriaVar("AE8_TPCONT",.F.),CriaVar("A2_XCC",.F.)  })	
EndIf

oModulos:SetArray(aModulos)
oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,1],oOk,oNo),;
				 		aModulos[oModulos:nAt,2],;
				 		aModulos[oModulos:nAt,3],;
						aModulos[oModulos:nAt,4],;
						aModulos[oModulos:nAt,5]  }}
oModulos:Refresh()

Return(aModulos)
//-------------------------------------------------------------------
/*/{Protheus.doc} AtuMarca
Descricao: MARCA REGISTRO TELA

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuMarca(oModulos,aModulos,aRetMd,lF3)
Local nX  := 0
Local nPos:= oModulos:nAt
Local nScan :=  AScan(aRetMd, oModulos:aArray[nPos,2] )
Local nI 	:= 0

oModulos:aArray[nPos,1]:= !oModulos:aArray[nPos,1]

IF !lF3
	If !oModulos:aArray[nPos,1] .and. nScan > 0	
		aDel(aRetMd,nScan)
		aSize(aRetMd,len(aRetMd)-1)	
	EndIf	
Else
	For nI:= 1 To Len( oModulos:aArray )

		if nPos <> ni
			oModulos:aArray[nI,1]:= .f.
		End	

	Next

END
aModulos:= oModulos:aArray
oModulos:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF11GFIN
Descricao: GERA FINANCEIRO DA FOLHA PMS

@version 1.0
/*/
//-------------------------------------------------------------------
User Function AF11GFIN( lGera )

Local lRet := .f.

If lGera
	If	SZH->ZH_STATUS == '2'
		Help(,, 'HELP',, "Folha ja finalizada!", 1, 0)
		Return
	End

	If !MSGYESNO( 'Deseja realmente fechar a folha da competencia selecionada ?', 'Atenção' )
		Return
	End

	LjMsgRun("Processando fechamento da folha...",,{ || lRet:= ProcFFol( lGera )    }) 

	If lRet
		SZH->( RECLOCK( 'SZH',.F.) )
			SZH->ZH_STATUS := '2'
		SZH->( MSUNLOCK() )
	End
Else

	If	SZH->ZH_STATUS == '1'
		Help(,, 'HELP',, "Folha nao finalizada!", 1, 0)
		Return
	End

	If !MSGYESNO( 'Deseja realmente estornar o fechamento da folha da competencia selecionada ?', 'Atenção' )
		Return
	End

	LjMsgRun("Processando estorno do fechamento da folha...",,{ || lRet:= ProcFFol( lGera )    }) 

	If lRet
		SZH->( RECLOCK( 'SZH',.F.) )
			SZH->ZH_STATUS := '1'
		SZH->( MSUNLOCK() )
	End

End

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFFol
Descricao: Processa fechamento

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcFFol( lGera )

Local cFornece := ''
Local cLjForn  := ''
Local cQuery   := ''

Local cEmpFat   := ''
Local cTipo     := 'DP '
Local cNatureza := ''
Local dDtVenc   := SZH->ZH_DTPAGTO
Local cHist     := ALLTRIM(SZH->ZH_DESCRI)
Local cPrefixo	:= "MAN"
Local cNumTit   := ""
Local cParcela  := StrZero(1, TamSx3("E2_PARCELA")[1])
Local lRetorno  := .F.
Local cMaySE2 	:= "SE2"+AllTrim(xFilial("SE2"))
Local nOpcExec := iif(lGera,3,5)
Local nSaveSX8 	:= GetSX8Len()
//1=ALFA CORPORIS;2=MOOVE CORPORIS;3=ALFA;4=MOOVE
If SZH->ZH_EMPRESA $ "1/2"
	cEmpFat := IIF(SZH->ZH_EMPRESA=='1','1','2') //"1=ALFA(07)", "2=MOOVE"
	cFornece := 'FOPAHN'
	cLjForn  := '01'
	cQuery   := " SELECT '"+cFornece+"' ZI_FORNECE "+CRLF
	cQuery   += " , '"+cLjForn+"' ZI_LOJA "+CRLF
	cQuery   += " , SUM(ZI_VLRTOT) ZI_VLRTOT "+CRLF
	cQuery   += " , MAX(ZI_REGE2) ZI_REGE2 "+CRLF
Else
	cEmpFat := IIF(SZH->ZH_EMPRESA=='3','1','2') //"1=ALFA(07)", "2=MOOVE"
	cQuery   := " SELECT ZI_FORNECE "+CRLF
	cQuery   += " , ZI_LOJA "+CRLF
	cQuery   += " , ZI_VLRTOT "+CRLF
	cQuery   += " , R_E_C_N_O_ RECSZI "+CRLF
	cQuery   += " , ZI_REGE2 "+CRLF
End
cQuery   += " FROM "+RetSqlName('SZI')+"  SZI "+CRLF
cQuery   += " WHERE "+CRLF
cQuery   += " ZI_FILIAL = '"+xFilial('SZI')+"' "+CRLF
cQuery   += " AND SZI.D_E_L_E_T_ = ''"+CRLF
cQuery   += " AND ZI_COMPETE = '"+SZH->ZH_COMPETE+"' "+CRLF
cQuery   += " AND ZI_REVISAO = '"+SZH->ZH_REVISAO+"' "+CRLF
cQuery   += " AND  ZI_VLRTOT > 0 "+CRLF
cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

		nSaveSX8 	:= GetSX8Len()
		cCodFor 	:= (cTMP1)->ZI_FORNECE
		cLojFor 	:= (cTMP1)->ZI_LOJA
		nVlrComis	:= (cTMP1)->ZI_VLRTOT
		cNatureza   := Posicione('SA2',1,xFilial('SA2')+ (cTMP1)->ZI_FORNECE + (cTMP1)->ZI_LOJA,'A2_NATUREZ')
		cParcela    := StrZero(1, TamSx3("E2_PARCELA")[1])
	If lGera
		// Verifica se o numero ja foi gravado
		cNumTit := GetSxeNum("SE2","E2_NUM")
		DbSelectArea("SE2")
		DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		While DbSeek(xFilial("SE2")+cPrefixo+cNumTit) .OR. !MayIUseCode(cMaySE2+cPrefixo+cNumTit)
			cNumTit := GetSxeNum("SE2","E2_NUM")
		EndDo
	Else
		SE2->( DBSETORDER( 1 ))	
		IF SE2->( MSSEEK( alltrim((cTMP1)->ZI_REGE2 ) ))
			cNumTit:= SE2->E2_NUM
		END 
	End

    FWMsgRun(, {|| lRetorno := GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis, cEmpFat,nOpcExec) }, "Aguarde", "Gerando pagamento...")

    If lRetorno

        EvalTrigger()

        While GetSX8Len() > nSaveSX8
            ConfirmSX8()
        EndDo
		if lGera
			cChaveE2:= xFilial("SE2") + cPrefixo + cNumTit + cParcela + cTipo + cCodFor +  cLojFor 
		else
			cChaveE2:= ''
		end
		//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA 2+3+9+3+3+6+2
		CUPD:= " UPDATE SZI010 SET ZI_REGE2 = '"+cChaveE2+"' "+CRLF		
		CUPD+= " WHERE ZI_FILIAL = '"+xFilial('SZI')+"' "+CRLF
		CUPD+= " AND ZI_COMPETE = '"+SZH->ZH_COMPETE+"' "+CRLF
		CUPD+= " AND ZI_REVISAO = '"+SZH->ZH_REVISAO+"' "+CRLF			
		If !(SZH->ZH_EMPRESA $ "1/2")
			CUPD+= " AND R_E_C_N_O_ = "+alltrim( str((cTMP1)->RECSZI )) +" "+CRLF			
		End
		TCSQLEXEC( CUPD)

    Else
        While GetSX8Len() > nSaveSX8
            RollBackSX8()
        EndDo
		EXIT
    EndIf

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraSE2
Gera titulo

@author  Pedro Oliveira
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis, cEmpFat,nOpcao)

Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aCposSE2	:= {}

Local lRetorno  := .T.

Private lMsErroAuto	    := .F.
Private lMsHelpAuto 	:= .T.
//Private lAutoErrNoFile 	:= .T.

DEFAULT nOpcao    := 3 // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

AADD( aCposSE2, {"E2_FILIAL" 	,xFilial("SE2")				,Nil})
AADD( aCposSE2, {"E2_PREFIXO" 	,cPrefixo 					,Nil})
AADD( aCposSE2, {"E2_NUM"	   	,cNumTit					,Nil})
AADD( aCposSE2, {"E2_PARCELA" 	,cParcela	  	            ,Nil})
AADD( aCposSE2, {"E2_TIPO"		,cTipo						,Nil})
AADD( aCposSE2, {"E2_NATUREZ" 	,cNatureza   		        ,Nil})
AADD( aCposSE2, {"E2_FORNECE" 	,cCodFor	  				,Nil})
AADD( aCposSE2, {"E2_LOJA"	   	,cLojFor   					,Nil})
AADD( aCposSE2, {"E2_EMISSAO" 	,dDataBase     				,Nil})
AADD( aCposSE2, {"E2_VENCTO"	,dDtVenc  					,Nil})
AADD( aCposSE2, {"E2_VENCREA" 	,DataValida(dDtVenc,.T.)	,Nil}) 
AADD( aCposSE2, {"E2_HIST" 		,cHist                      ,Nil})
AADD( aCposSE2, {"E2_VALOR"		,nVlrComis			 		,Nil})
AADD( aCposSE2, {"E2_ORIGEM"	,"FINA050"					,Nil})
AADD( aCposSE2, {"E2_EMPFAT"    ,cEmpFat			 		,Nil})

AADD( aCposSE2, {"E2_XVLRNF"    ,nVlrComis			 		,Nil})

BEGIN TRANSACTION

    //Gravacao do Titulo a Pagar
    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCposSE2,, nOpcao)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

    If lMsErroAuto
        DisarmTransaction()
        lRetorno := .F.

        MostraErro()
        /*
        aErro 	 := GetAutoGrLog()
        cMsgErro := ""

        For nX := 1 To Len(aErro)
            cMsgErro += aErro[nX] + CRLF
        Next nX
        */
    EndIf

END TRANSACTION

RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return lRetorno


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDACTMDL 
@type				: Funcao estatica
@Sample				: VLDACTMDL(oModel)
@description	    : Realiza a validação do modelo de dados para o mesmo ser ativado.						
@Param				: oModel - Model a ser validado
@return				: lRet - .T. = Sucesso = .F. Erro
@ ------------------|----------------
@author				: Pedro Henrique Oliveira
@since				: 11/04/2019
@version			: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Static Function VLDACTMDL(oModel)

Local nOperation    := oModel:GetOperation()
Local lRet          := .T.
 
If nOperation ==  MODEL_OPERATION_DELETE

	If SZH->ZH_STATUS $ "2" 
        HELP('',,"HELP" ,,"Fechamento da folha ja realizado, não será possivel exluir!",1,0,,,,,,)
        lRet := .F.
    EndIf

EndIf

Return(lRet)

Static Function MarcaTodos(lMark,oModulos,aModulos,aRetMd)

Local nI :=  0
Local nPos:= oModulos:nAt
Local nScan :=  AScan(aRetMd, oModulos:aArray[nPos,2] )

For nI:= 1 To Len( oModulos:aArray )
	nPos:= nI
	nScan :=  AScan(aRetMd, oModulos:aArray[nPos,2] )

	oModulos:aArray[nPos,1]:= lMark//!oModulos:aArray[nPos,1]

	If !oModulos:aArray[nPos,1] .and. nScan > 0	
		aDel(aRetMd,nScan)
		aSize(aRetMd,len(aRetMd)-1)	
	EndIf	

Next

aModulos:= oModulos:aArray
oModulos:Refresh()

Return


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
Local oGrid    	    := oModel:GetModel("SZIGRID")
Local oField  		:= oModel:GetModel( "SZHMASTER" )

If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE 
    
    nLin    := oGrid:GetLine()        
    For nI := 1 to oGrid:Length()            
        oGrid:GoLine(nI)
        If !oGrid:IsDeleted() 
            xValue  := oGrid:GetValue("ZI_VLRTOT")             
            If xValue <= 0
                lRet  := .f.
                //Help( ,, 'HELP',, "Informar todos os tratos realizados.", 1, 0)
                Exit
            EndIf
        EndIf
    Next nI


    If !lRet
        If MSGYESNO( 'Falta horas em pelo menos um RECURSO. Deseja incluir mesmo assim ? ', 'Atenção' )
            lRet  := .t.
        EndIf
    EndIf
    
EndIf

RestArea(aArea)
Return(lRet)

User  Function AF11GCOM()

Local aBkpRot := aRotina

u_ALFPMS10()

aRotina := aBkpRot 

Return

User Function AF11CF3( lRetF3 )

Local aRet := { '1,2,3,4,5' ,'', 'ZZZZZZ','','ZZZZZZ',''}
Local xRet := .t.

If FWIsInCallStack('U_ALFPMS16')
	aRet := { '1,2,3,4,5' ,'', 'ZZZZZZ','','ZZZZZZ',''}
End

If !lRetF3
	xRet := ProcRecurs( aRet,.T. )
Else
	xRet:= &(Readvar()) := __f3_xRet
End

Return xRet
