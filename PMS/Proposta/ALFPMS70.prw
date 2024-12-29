
#INCLUDE "FWEditPanel.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "TBIConn.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Set.CH'
Static __f3_xRet := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS70
Descricao: CADASTRO DE CONTRATOS

@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS70(cGrupo)

	Local oBrowse
	Local cFiltro := ''

	Private x_cGrupo := ''
	Private aRotina  := {}

	Default cGrupo := ''

	x_cGrupo := cGrupo

	If !'ADM' $  x_cGrupo
		cFiltro:= __cUserID
	End
	aRotina 	:= FwLoadMenuDef('ALFPMS70')

	aSeek := {}
	cCampoAux := "C7_NUM"
	aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )


	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'Z42' )
	oBrowse:SetDescription( 'CADASTRO DE CONTRATOS' )

//1=Fechamento em Aberto;2=Fechamento Finalizado
	oBrowse:AddLegend( "Z42_STATUS=='1'", "BR_CINZA", 'Esboço de Contrato'      )
	oBrowse:AddLegend( "Z42_STATUS=='2'", "YELLOW" , 'Aguardando Aprovação ' )
	oBrowse:AddLegend( "Z42_STATUS=='3'", "GREEN"  , 'Aprovado'              )
	oBrowse:AddLegend( "Z42_STATUS=='4'", "RED"    , 'Reprovado'             )

//oBrowse:lHeaderClick := .T.
//oBrowse:SetItemHeaderClick({"B1_COD", "B1_DESC"})

	If !Empty(cFiltro)
		oBrowse:SetFilterDefault(" Alltrim(Z42_USRLGI) $  '"+cFiltro+"' ")
	EndIf



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
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFPMS70"     OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFPMS70"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFPMS70"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFPMS70"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0

	ADD OPTION aRotina TITLE "Legenda" 		    	ACTION "U_ALF70LEG"	    	OPERATION 2 ACCESS 0

	If 'ADM' $  x_cGrupo
		ADD OPTION aRotina TITLE "Aprovar"    ACTION "U_AFPMS70A(1)"     OPERATION 9    ACCESS 0
		ADD OPTION aRotina TITLE "Reprovar"   ACTION "U_AFPMS70A(2)"     OPERATION 9    ACCESS 0

		ADD OPTION aRotina TITLE "Rel.Contratos"    ACTION "U_ALFPMS72()"     OPERATION 9    ACCESS 0
	End

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ALF70LEG
Legenda.

@author  Pedro Oliveira
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALF70LEG()

Local aLegenda := {}

AADD( aLegenda, {"BR_CINZA"		, "Esboço de Contrato" 	} )
AADD( aLegenda, {"BR_AMARELO"	, "Aguardando Aprovação"  } )
AADD( aLegenda, {"BR_VERDE"		, "Aprovado"  } )
AADD( aLegenda, {"BR_VERMELHO"	, "Reprovado" } )

BrwLegenda("CADASTRO DE CONTRATOS","Legenda",aLegenda)

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStructZ42 := FWFormStruct(1,"Z42")
	Local oStructIt  := FWFormStruct(1,"Z43")
	Local oModel := Nil  // objeto modelo
	Local bPost := { |oModel| VldPosValid(oModel) }


	Local bTotCusto  := {|oModel| CalcTotCt( oModel,1 ) }
	Local bTotPreco  := {|oModel| CalcTotCt( oModel,2 ) }
	Local bTotMkt    := {|oModel| CalcTotCt( oModel,3 ) }



//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
	oModel:= MPFormModel():New("M_ALFPMS70",/*Pre-Validacao*/,bPost/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

//oStructZ42:SetProperty( "Z42_COMPETE" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z42_COMPETE') } )
//oStructIt:SetProperty( "Z43_RECURSO"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_RECURSO') } )
//oStructIt:SetProperty( "Z43_HRSREAL"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_HRSREAL') } )
//oStructIt:SetProperty( "Z43_HRSEXTR"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_HRSEXTR') } )
//oStructIt:SetProperty( "Z43_VLRREEM"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_VLRREEM') } )
//oStructIt:SetProperty( "Z43_DESADIC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_DESADIC') } )
//oStructIt:SetProperty( "Z43_HRSDESC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_HRSDESC') } )

	oStructIt:SetProperty( "Z43_QUANT"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_QUANT') } )
	oStructIt:SetProperty( "Z43_CUNIT"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_CUNIT') } )
	oStructIt:SetProperty( "Z43_PUNIT"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_PUNIT') } )

	oStructIt:SetProperty( "Z43_PRODUT"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_PRODUT') } )
	oStructIt:SetProperty( "Z43_ADITIV"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z43_ADITIV') } )


	oStructZ42:SetProperty( "Z42_MESREF" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z42_MESREF') } )
	oStructZ42:SetProperty( "Z42_MESCON" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z42_MESCON') } )
	oStructZ42:SetProperty( "Z42_INICOB" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z42_INICOB') } )

	oStructZ42:SetProperty( "Z42_NUMERO" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z42_NUMERO') } )



	oStructZ42:SetProperty("Z42_NUMERO" , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )

//oStructZ42:SetProperty("Z42_FORNEC" , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
//oStructZ42:SetProperty("Z42_LJFOR" , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
//oStructZ42:SetProperty("Z42_CLIENT" , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )
//oStructZ42:SetProperty("Z42_LJCLI" , MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT } )

	oModel:AddFields("Z42MASTER", Nil/*cOwner*/, oStructZ42 ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
	oModel:SetPrimaryKey( { "Z42_FILIAL","Z42_COMPETE","Z42_REVISAO"})
	oModel:AddGrid  ('Z43GRID' , 'Z42MASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:SetRelation( "Z43GRID", { { "Z43_FILIAL", "xFilial('Z43')"   },;
		{ "Z43_NUMERO", "Z42_NUMERO" },;
		{ "Z43_FORNEC", "Z42_FORNEC" },;
		{ "Z43_LJFOR" , "Z42_LJFOR" } }, Z43->( IndexKey( 1 ) ) )

//oModel:GetModel( "Z43GRID" ):SetUniqueLine( { 'Z43_PRODUT' } )   

//oModel:GetModel( "Z43GRID" ):SetUniqueLine( { 'Z42_FILABA' } )   
//oModel:GetModel( "Z43GRID" ):SetUniqueLine( { 'Z42_PRIABA' } )
	oModel:GetModel("Z42MASTER"):SetDescription('Detalhes do Contrato')//"Linhas"
	oModel:GetModel("Z43GRID"  ):SetDescription('Itens do Contrato')//"Itens da Linhas"

	If !INCLUI  .AND. Z42->Z42_STATUS <> '1' .AND. !('ADM' $  x_cGrupo)
		//Deixando o cabeçalho como não editável
		oModel:GetModel("Z42MASTER"):SetOnlyView(.T.)
		oModel:GetModel("Z43GRID"):SetOnlyView(.T.)
	End
// Totalizadores
	oModel:AddCalc("TOTVLR", "Z42MASTER", "Z43GRID", "Z43_CTOTAL", "SUM_Z43_CTOTAL", "FORMULA" , /*bCond*/, bTotCusto , "Total Custo" , bTotCusto , 14, 2)
	oModel:AddCalc("TOTVLR", "Z42MASTER", "Z43GRID", "Z43_PTOTAL", "SUM_Z43_PTOTAL", "FORMULA" , /*bCond*/, bTotPreco , "Total Preço" , bTotPreco , 14, 2)
	oModel:AddCalc("TOTVLR", "Z42MASTER", "Z43GRID", "Z43_MARKUP", "SLD_EZVALOR"   , "FORMULA" , /*bCond*/, bTotMkt   , "% Markup"    , bTotMkt   , 14, 2)

	oModel:AddCalc("TOTVLR", "Z42MASTER", "Z43GRID", "Z43_QUANT", "SUM_Z43_QUANT"   , "SUM" , /*bCond*/,    , "Total Quantidade"    ,    , 14, 2)


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
	Local oModel       := FWLoadModel("ALFPMS70")
	Local oStructZ42   := FWFormStruct(2,"Z42")
	Local oStructIt    := FWFormStruct(2,"Z43")

//If lPMO 
//	oStructIt    := FWFormStruct(2,"Z43" ,{|cCampo| !(AllTrim(cCampo) $ "Z43_VLREAL|Z43_VLRHORA|Z43_VLRHREX/Z43_VLRDESC/Z43_DESADIC/Z43_VLRTOT/Z43_FIXO/Z43_VLRADC/Z43_OBSADC" )} )		
//End

//oStructIt:RemoveField("ZZY_OPER")

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEWZ42" , oStructZ42, "Z42MASTER" )
	oView:AddGrid (  "VIEWGZ42", oStructIt,  "Z43GRID" )

	oView:AddField("VIEW_TOTVLR", FWCalcStruct(oModel:GetModel("TOTVLR")), "TOTVLR")

//oView:AddField("VIEW_TOTPER" , FWCalcStruct(oModel:GetModel("TOTPERC")) , "TOTPERC")

// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )

	//oView:CreateVerticalBox( 'ESQ',70)
	//oView:CreateVerticalBox( 'DIR',30)
	//oView:CreateHorizontalBox( 'INFERIOR1', 40,'ESQ' )
	//oView:CreateHorizontalBox( 'INFERIOR2', 40,'ESQ' )

	oView:CreateHorizontalBox( 'CALC', 20 )


// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEWZ42' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEWGZ42', 'INFERIOR' )

	oView:SetOwnerView( 'VIEW_TOTVLR', 'CALC' )


// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEWGZ42', 'Z43_ITEM' )

	oView:EnableTitleView( 'VIEWZ42' )
	oView:EnableTitleView( 'VIEWGZ42')

	oView:EnableTitleView('VIEW_TOTVLR'  , 'Valor Total'  )

// Adicione botão de legenda.
//oView:AddUserButton( 'Importar recursos', 'CLIPS', { |oView| ImpRecur() } )

Return oView



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
	Local oGrid    	    := oModel:GetModel("Z43GRID")
	Local oField  		:= oModel:GetModel( "Z42MASTER" )
	local nCusto := 0
	local nPreco:=0
	local xAux      := ALLTRIM(oField:GetValue(  'Z42_INICOB' ))
	Local dIniCob   := ctod('01/'+substr(xAux,1,2)+'/'+substr(xAux,3,4))
	Local dIniCob2   := ctod('01/'+substr(xAux,1,2)+'/'+substr(xAux,3,4))
	Local dFimCob   := oField:GetValue("Z42_FIMCON")
	Local cParcela  := '001'
	Local nQuant := 0
	Local cChave    := oField:GetValue(  'Z42_NUMERO' )+;
		oField:GetValue(  'Z42_FORNEC' )+;
		oField:GetValue(  'Z42_LJFOR' ) //oGrid:GetValue(  'Z43_ITEM' )+;
		Local cChave2:=''
	If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE
		nCusto:= 0
		For ni:= 1 to oGrid:Length()
			oGrid:GoLine(ni)
			If !oGrid:IsDeleted()
				nCusto+= oGrid:GetValue("Z43_CTOTAL")
				nPreco+= oGrid:GetValue("Z43_PTOTAL")
				nQuant+= oGrid:GetValue("Z43_QUANT") 
			end
		next

		while val(cParcela) <= oField:GetValue(  'Z42_MESCON' )  //dIniCob <= dFimCob
			cChave2:= cChave+cParcela

			xAux := DTOS(dIniCob)
			xAux := substr(xAux,1,6)+strzero( oField:GetValue(  'Z42_DIAVEN' ) , 2  )
			//substr(xAux,1,2)+'/'+substr(xAux,3,4)
			xAux := stod(xAux)

			Z44->( DbSetOrder(1) )//Z44_FILIAL+Z44_NUMERO+Z44_FORNEC+Z44_LJFOR+Z44_PARCEL
			lz44 := !Z44->( MsSeek( xFilial('Z44') + cChave2) )

			Z44->( RecLock('Z44', lz44 ) )
			Z44->Z44_FILIAL := xFilial('Z44')
			Z44->Z44_NUMERO := oField:GetValue(  'Z42_NUMERO' )
			Z44->Z44_FORNEC := oField:GetValue(  'Z42_FORNEC' )
			Z44->Z44_LJFOR  := oField:GetValue(  'Z42_LJFOR' )
			Z44->Z44_NFOR   := oField:GetValue(  'Z42_NFOR' )
			Z44->Z44_PARCEL := cParcela
			Z44->Z44_VALOR  := nCusto
			Z44->Z44_VENCTO := xAux
			Z44->Z44_DIAVEN := oField:GetValue(  'Z42_DIAVEN' )
			Z44->Z44_VENCRE := datavalida(xAux)
			Z44->Z44_MESREF := oField:GetValue(  'Z42_MESREF' )
			Z44->Z44_INICOB := dIniCob2//oField:GetValue(  'Z42_INICOB' )
			Z44->Z44_MESCON := oField:GetValue(  'Z42_MESCON' )
			Z44->Z44_DTFIM  := oField:GetValue(  'Z42_FIMCON' )
			Z44->Z44_MULTA  := oField:GetValue(  'Z42_MULTA' )
			Z44->Z44_NFFOR  := ''
			Z44->Z44_CLIENT := oField:GetValue(  'Z42_CLIENT' )
			Z44->Z44_LJCLI  := oField:GetValue(  'Z42_LJCLI' )
			//Z44->Z44_NUMTIT := ''
			//Z44->Z44_DTBX   := ''
			Z44->Z44_STATUS := '0'
			Z44->( MsUnlock() )
			cParcela:= soma1(cParcela)
			dIniCob:= MonthSum(dIniCob,1)

		end
		Z44->( DbSetOrder(1) )


		oField:LoadValue('Z42_CTOTAL',  nCusto )
		oField:LoadValue('Z42_PTOTAL',  nPreco ) 
		oField:LoadValue('Z42_MARKUP',  IIF( nCusto > 0 , round(nPreco/nCusto,2) , 0)  )
		oField:LoadValue('Z42_QTOTAL',   nQuant )
		
		If oField:GetValue("Z42_STATUS") == '1' .and. MSGYESNO( 'Deseja enviar para a aprovação  ? ', 'Atenção' )
			oField:LoadValue('Z42_STATUS', '2'  )
			lRet  := .t.
			EnvMailAprov()
		EndIf

	EndIf

	RestArea(aArea)
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} CalcTotCt
Calcula totais

@author  Pedro Oliveira
@since   05/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcTotCt(oModel,nTot)

	Local oModelPai     := oModel:GetModel()	// Carrega Model Master
	Local oModelGrid    := oModelPai:GetModel('Z43GRID')	// Carrega Model Master
	Local ni            := 0
	Local nVlrTitulo    := 0//oModelPai:GetModel('SEVDETAIL'):GetValue("EV_VALOR")
	Local nCusto        := 0
	Local nPreco        := 0
	Local nLin    := oModelGrid:GetLine()

	For ni:= 1 to oModelGrid:Length()
		oModelGrid:GoLine(ni)
		If !oModelGrid:IsDeleted()
			nCusto+= oModelGrid:GetValue("Z43_CTOTAL")
			nPreco+= oModelGrid:GetValue("Z43_PTOTAL")
		end
	next

	oModelGrid:GoLine(nLin)

	If nTot ==1
		nVlrTitulo:= nCusto
	ElseIf nTot==2
		nVlrTitulo:= nPreco
	else
		If nCusto > 0
			nVlrTitulo  := round(nPreco/nCusto,2)
		End
	End
Return nVlrTitulo

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

		If Z42->Z42_STATUS $ "3/4"
			HELP('',,"HELP" ,,"Cadastro de contratos aprovado, não será possivel exluir!",1,0,,,,,,)
			lRet := .F.
		EndIf
	ElseIf nOperation ==  MODEL_OPERATION_UPDATE

		If Z42->Z42_STATUS $ "2/3/4"
			HELP('',,"HELP" ,,"Cadastro de contratos em aprovação/aprovado/reprovado, não será possivel alteração!",1,0,,,,,,)
			//lRet := .F.
		EndIf

	EndIf

Return(lRet)


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
	Local oField  	    := oModel:GetModel("Z42MASTER")
	Local oGrid    	    := oModel:GetModel("Z43GRID")
	Local cPropo        := oGrid:GetValue("Z43_PROPOS")
	Local cAdt          := oGrid:GetValue("Z43_ADITIV")
	Local cFornece      := oField:GetValue("Z42_FORNEC")
	local cTmp          :=''
	If nOperation ==  MODEL_OPERATION_INSERT  .OR.  nOperation ==  MODEL_OPERATION_UPDATE
		If cCampo $ 'Z42_NUMERO'

			Z42->(DBSETORDER(1))
			If Z42->( MSSEEK( xFilial('Z02') + oField:GetValue(  'Z42_NUMERO' )   ) )
				//if !Z02->Z02_STATUS $ '9/5'
				HELP('',,"HELP" ,,"Contrato ja cadastrado!",1,0,,,,,,)
				lRet:= .F.
				//endif
			END

		ElseIf cCampo $ 'Z42_MESCON'

			oField:LoadValue('Z42_FIMCON',   lastday(MonthSum( oField:GetValue(  'Z42_MESREF' ) ,oField:GetValue(  'Z42_MESCON' ) )  )  )

		ElseIf cCampo $ 'Z42_MESREF'

			oField:LoadValue('Z42_MESREF',   firstday(  oField:GetValue(  'Z42_MESREF')  ) )
			If !empty( oField:GetValue(  'Z42_MESCON')  )
				//oField:SetValue('Z42_MESCON',   oField:GetValue(  'Z42_MESCON')+1  )
				oField:LoadValue('Z42_FIMCON',   lastday(MonthSum( oField:GetValue(  'Z42_MESREF' ) ,oField:GetValue(  'Z42_MESCON' ) )  )  )
				oField:LoadValue('Z42_INICOB',   '' )
			End
			//xaux:= DTOS(MonthSum(oField:GetValue(  'Z42_MESREF') , 1 ) )
			//oField:SetValue('Z42_INICOB',   SUBSTR(xaux,5,2) + SUBSTR(xaux,1,4) )

		ELSEIF cCampo $ 'Z42_INICOB'
			xAux:= ALLTRIM(oField:GetValue(  'Z42_INICOB' ))
			If len(xAux) >= 6
				xAux:= '01/'+substr(xAux,1,2)+'/'+substr(xAux,3,4)
				IF CTOD( xAux ) <  oField:GetValue(  'Z42_MESREF' )
					HELP('',,"HELP" ,,"Inicio da cobrança deve ser maior que Mes Referencia !",1,0,,,,,,)
					lRet:= .F.
				ElseIf lastday(CTOD( xAux )) >  oField:GetValue(  'Z42_FIMCON' )
					HELP('',,"HELP" ,,"Inicio da cobrança deve ser menor que Fim Contrato !",1,0,,,,,,)
					lRet:= .F.
				END
			Else
				HELP('',,"HELP" ,,"Formato invalidao! INFORMA 'MMAAAA' ",1,0,,,,,,)
				lRet:= .F.
			End
		ElseIf  cCampo $ 'Z43_QUANT/Z43_CUNIT/Z43_PUNIT'

			If  cCampo $ 'Z43_QUANT'
				cQuery:= " SELECT SUM(Z05_QUANT) Z05_QUANT "+CRLF
				cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "+CRLF
				cQuery+= " WHERE Z05.D_E_L_E_T_ = '' "+CRLF
				cQuery+= " AND Z05_PROPOS = '"+cPropo+"' "+CRLF
				cQuery+= " AND Z05_ADITIV = '"+cAdt+"' "+CRLF
				cQuery+= " AND  Z05_MODULO = '" + AllTrim( oGrid:GetValue(  'Z43_PRODUT' ) ) + "'    "+CRLF
				cQuery+= " AND Z05_MODLIC <> '5' "+CRLF
				cTmp := MPSysOpenQuery(cQuery)

				//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ00",.T.,.T.)

				IF (cTmp)->(Eof())
					lRet:= .F.
					HELP('',,"HELP" ,,"Modulo não vinculado a prosposta!",1,0,,,,,,)
				Else

					xAux:= ALLTRIM(oField:GetValue(  'Z42_INICOB' ))
					xAux:= '01/'+substr(xAux,1,2)+'/'+substr(xAux,3,4)					
															
					cChave:= oField:GetValue(  'Z42_NUMERO' )+;
						oField:GetValue(  'Z42_FORNEC' )+;
						oField:GetValue(  'Z42_LJFOR' )+; //oGrid:GetValue(  'Z43_ITEM' )+;
						oGrid:GetValue(  'Z43_PRODUT' )
					nsaldo:= getsaldolic(cChave,cPropo,cAdt,oGrid , ctod(xAux) , oField:GetValue(  'Z42_FIMCON' ))

					//If oGrid:GetValue(  'Z43_QUANT' ) + nsaldo > (cTmp)->Z05_QUANT
					//	lRet:= .F.
					//	HELP('',,"HELP" ,,"Quantidade informada maior que a quantidade cadastrada na prosposta!",1,0,,,,,,)
					//End
				End
				(cTmp)->(dbCloseArea())
			end

			if lRet
				oGrid:LoadValue('Z43_PTOTAL', oGrid:GetValue(  'Z43_QUANT' ) *  oGrid:GetValue(  'Z43_PUNIT' )  )
				oGrid:LoadValue('Z43_CTOTAL', oGrid:GetValue(  'Z43_QUANT' ) *  oGrid:GetValue(  'Z43_CUNIT' )  )
				IF oGrid:GetValue(  'Z43_CTOTAL' ) > 0
					oGrid:LoadValue('Z43_MARKUP', oGrid:GetValue(  'Z43_PTOTAL' ) /  oGrid:GetValue(  'Z43_CTOTAL' )  )
				END
			end

		ElseIf cCampo $ 'Z43_ADITIV'
			Z02->(DBSETORDER(1))
			If Z02->( MSSEEK( xFilial('Z02') +cPropo+cAdt ) )
				if !Z02->Z02_STATUS $ '9/5'
					HELP('',,"HELP" ,,"Prosposta NAO APROVADA!",1,0,,,,,,)
					lRet:= .F.
				endif
			END
		ElseIf cCampo $ 'Z43_PRODUT'
			cQuery:= " SELECT DISTINCT Z05_MODULO,Z05_DESCRI,Z05_QUANT,Z05_CUSTO,Z05_PRCVEN "+CRLF
			cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "+CRLF
			cQuery+= " WHERE Z05.D_E_L_E_T_ = '' "+CRLF
			cQuery+= " AND Z05_PROPOS = '"+cPropo+"' "+CRLF
			cQuery+= " AND Z05_ADITIV = '"+cAdt+"' "+CRLF
			cQuery+= " AND  Z05_MODULO = '" + AllTrim( oGrid:GetValue(  'Z43_PRODUT' ) ) + "'    "+CRLF
			cQuery+= " AND Z05_MODLIC <> '5' "+CRLF
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ00",.T.,.T.)

			IF TMPZ00->(Eof())
				lRet:= .F.
				HELP('',,"HELP" ,,"Modulo não vinculado a prosposta!",1,0,,,,,,)
			Else
				cChave:= oField:GetValue(  'Z42_NUMERO' )+;
					oField:GetValue(  'Z42_FORNEC' )+;
					oField:GetValue(  'Z42_LJFOR' )+;//oGrid:GetValue(  'Z43_ITEM' )+;
					oGrid:GetValue(  'Z43_PRODUT' )
				nsaldo:= getsaldolic(cChave,cPropo,cAdt,oGrid)
				if TMPZ00->Z05_QUANT - nsaldo > 0
					oGrid:SetValue('Z43_QUANT', TMPZ00->Z05_QUANT - nsaldo )
					oGrid:SetValue('Z43_PUNIT', TMPZ00->Z05_PRCVEN  )
				else
					//lRet:= .F.
					//HELP('',,"HELP" ,,"Não há saldo de licença!",1,0,,,,,,)
				end
			End
			TMPZ00->(dbCloseArea())

		Endif
	EndIf

	RestArea(aArea)
Return(lRet)


USER FUNCTION AFPMS70A(nTipo)

	Local cMsg      := iif(ntipo==1,'Aprovar','Reprovar')
	Local cStatus   :=  iif(ntipo==1,'3','4')
	Local lRet      := .t.
	If Z42->Z42_STATUS == '2'
		If MSGYESNO( 'Deseja realmente '+cMsg+' o contrato '+alltrim(Z42->Z42_NUMERO)+'?')
			//Begin Transaction			
				Z42->(RecLock("Z42",.F.))
					Z42->Z42_STATUS := cStatus
					Z42->Z42_APROV  := __cUserID
					Z42->Z42_NAPROV := cUserName
				Z42->(MsUnlock())

				cChave:= Z42->Z42_NUMERO+Z42->Z42_FORNEC+Z42->Z42_LJFOR

				Z44->( DbSetOrder(1) )//Z44_FILIAL+Z44_NUMERO+Z44_FORNEC+Z44_LJFOR+Z44_PARCEL
				If Z44->( MsSeek( xFilial('Z44') + cChave) )
					While Z44->( !eof() ) .and. xFilial('Z44') + cChave == Z42->Z42_FILIAL+Z42->Z42_NUMERO+Z42->Z42_FORNEC+Z42->Z42_LJFOR
						Z44->(RecLock("Z44",.F.))
							Z44->Z44_STATUS := IIf(ntipo==1,'1','4')
						Z44->(MsUnlock())

						Z44->( dbSkip() )
					End
					
				End
			//End Transaction
		End
	Else
		HELP('',,"HELP" ,,"Cadastro de contratos em Esboço de Contrato/Aprovado/Reprovado, não será possivel alteração!",1,0,,,,,,)
	END

RETURN

User Function Z05FILTRO()

	Local cFiltroZ00 := ''
	Local oModel    := FwModelActive()
	Local oField  	    := oModel:GetModel("Z42MASTER")
	Local oGrid    	    := oModel:GetModel("Z43GRID")

	Local cPropo   := oGrid:GetValue("Z43_PROPOS")
	Local cAdt     := oGrid:GetValue("Z43_ADITIV")
	Local cFornece := oField:GetValue("Z42_FORNEC")

//If !Empty(cFiltroZ00)
//	cFiltroZ00+= " .AND. "
//EndIf

// == FWFLDGET("Z43_PROPOS") .AND. Z05->Z05_ADITIV == FWFLDGET("") .AND. M->

	cFiltroZ00 += "Z05->Z05_PROPOS  == '"+cPropo+"' "
	cFiltroZ00 += " .AND. Z05->Z05_ADITIV  == '"+cAdt+"' "
	cFiltroZ00 += " .AND. SUBSTR(Z05->Z05_MODULO,1,6)  == '"+cFornece+"' "


Return ( &(cFiltroZ00) )


User Function AFPMS70C( lRetF3 )

	Local xRet := .t.

	If !lRetF3
		xRet := ProcProd(  )
	Else
		xRet:= &(Readvar()) := __f3_xRet
	End

Return xRet

Static Function ProcProd(  lF3 )

	Local oModulos
	Local oDescMod
	Local oFornece
	Local oPanel1
	Local oPanel2
	Local oDlg
	Local oPanDlg
	Local oNo      := LoadBitmap( GetResources(), "LBNO" )
	Local oOk      := LoadBitmap( GetResources(), "LBOK" )

	Local aModulos := {}
	Local aSize    := {}
	Local aInfo    := {}
	Local aObjects := {}
	Local aPosObj  := {}

	Local aRetMd   := {}
	Local aCombo   := {}
	Local aRetSx3  := {}
	Local nModulo  := 0
	local ni       := 0
	Local cFornece := CriaVar("A2_NREDUZ",.F.)
	Local cModulo  := CriaVar("Z00_DESCRI",.F.)
	local nx := 0
	Local cCombo01 := ""

	Local oModel    := FwModelActive()
	Local oGrid    	:= oModel:GetModel("Z43GRID")

	Local xRet := .t.
	Private oFntP 			:= TFont():New( "Arial",,18,,.T.,,,,,.F.)
	Private oFntSay 		:= TFont():New( "Arial",,14,,.T.,,,,,.F.)

	Default lF3 := .T.

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

	DEFINE MSDIALOG oDlg FROM 0,0 TO 700,1200 TITLE "Modulos" Of oMainWnd PIXEL STYLE DS_MODALFRAME

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
	oFWLayer:addWindow( "COL1", "WIN1", "",100, .F., .T., , "LINHA2")
	oPanel2	:= oFWLayer:GetWinPanel("COL1", "WIN1","LINHA2")

	@ 001,005 SAY "Modulo"							OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK
	@ 010,005 MSGET oFornece VAR cFornece Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14 ON CHANGE FilModulo(cFornece,cModulo,@aModulos,@oModulos,@aRetMd,cCombo01)

	@ 001,110 SAY "Nome"								OF oPanel1 PIXEL SIZE 050,11 FONT oFntSay COLOR CLR_BLACK
	@ 010,110 MSGET oDescMod VAR cModulo  Picture "@!" 	OF oPanel1 PIXEL SIZE 100 ,14  ON CHANGE FilModulo(cFornece,cModulo,@aModulos,@oModulos,@aRetMd,cCombo01)
//Z42_CLIENT/Z42_LJCLI
//Z02_CLIENT/Z02_LOJA
	Aadd(aModulos,{.F.,"","","","","" })
	oModulos:= TwBrowse():New(0,0,0,0,,{" ",Padr("Codigo",20),Padr("Descrição",80),Padr("Quant",15),Padr("Custo",15),Padr("Preço",15) },,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//Z05_MODULO,Z05_DESCRI,Z05_QUANT,Z05_CUSTO,Z05_PRCVEN
	oModulos:SetArray(aModulos)
	oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,1],oOk,oNo),;
		aModulos[oModulos:nAt,2],;
		aModulos[oModulos:nAt,3],;
		aModulos[oModulos:nAt,4],;
		aModulos[oModulos:nAt,5],;
		aModulos[oModulos:nAt,6] }}

	oModulos:BlDblClick	 := {|| AtuMarca(@oModulos,@aModulos,@aRetMd,lF3)}
//oModulos:bHeaderClick:= { |oObj,nCol| SyOrdena(nCol,@oModulos,@aModulos,@lOrdemCols) }
//oModulos:bChange	 := {|| (nModulo:= oModulos:nAt, AtuObs(oModulos,@cMemo,@oMemo,@cMemo2,@oMemo2), AtuTabPrc( aModulos[oModulos:nAt,1] ,@xGetDados2,@aPrdEst2) ) }
	oModulos:Refresh()
	oModulos:Align:= CONTROL_ALIGN_ALLCLIENT


	DEFINE SBUTTON oBtnOk FROM 001,550 TYPE 1 ENABLE OF oPanel1;
		ACTION (nModulo := oModulos:nAt, oDlg:End())

	DEFINE SBUTTON oBtnCancel FROM 016,550 TYPE 2 ENABLE OF oPanel1;
		ACTION  (nModulo := 0,oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oFornece:SetFocus(), Eval(oFornece:bChange))

	//xRet:= ''
	For nX:= 1 To Len(aModulos)
		if aModulos[nX][1]
			xRet	 := .t.//aModulos[nX][2]
			__f3_xRet:= aModulos[nX][2]
			exit
		End
	Next


Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FilModulo
Descricao: FILTRA DADOS

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilModulo(cFornece,cModulo,aModulos,oModulos,aRetMd,cCombo01)
	Local cQuery  := ""
	Local oNo     := LoadBitmap( GetResources(), "LBNO" )
	Local oOk     := LoadBitmap( GetResources(), "LBOK" )
	Local nX:= 0
	Local lMark := .f.

	Local oModel    := FwModelActive()
	Local oField  	    := oModel:GetModel("Z42MASTER")
	Local oGrid    	    := oModel:GetModel("Z43GRID")

	Local cPropo   := oGrid:GetValue("Z43_PROPOS")
	Local cAdt     := oGrid:GetValue("Z43_ADITIV")
	Local cFornece := oField:GetValue("Z42_FORNEC")

	For nX:= 1 To Len(aModulos)
		If aModulos[nX][1] .and. AScan(aRetMd, aModulos[nX,2] ) == 0
			aadd(aRetMd	, aModulos[nX,2] )
		EndIf
	Next nX

	aModulos:= {}

	cQuery+= " SELECT DISTINCT Z05_MODULO,Z05_DESCRI,Z05_QUANT,Z05_CUSTO,Z05_PRCVEN "+CRLF
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "+CRLF
	cQuery+= " WHERE Z05.D_E_L_E_T_ = '' "+CRLF
	cQuery+= " AND Z05_PROPOS = '"+cPropo+"' "+CRLF
	cQuery+= " AND Z05_ADITIV = '"+cAdt+"' "+CRLF

	cQuery+= " AND ( SUBSTRING(Z05_MODULO,1,6) = '" + AllTrim(cFornece) + "' OR SUBSTRING(Z05_MODULO,1,3) = 'SAP' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'CRM' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,4) = 'ATOS' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'ACR' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'GET' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'ICL' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'LIB' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'LOC' "+CRLF
	cQuery+= " OR SUBSTRING(Z05_MODULO,1,3) = 'OBJ' "+CRLF	
	cQuery+= " ) "+CRLF

	cQuery+= " AND Z05_MODLIC <> '5' "+CRLF
//If !Empty(cFornece)
//	cQuery+= " AND Z05_MODULO LIKE '%" + AllTrim(cFornece) + "%' "+CRLF
//EndIf

	If !Empty(cModulo)
		cQuery+= " AND Z05_DESCRI LIKE '%" + AllTrim(cModulo) + "%' "+CRLF
	EndIf
//cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ00",.T.,.T.)

//dbSelectArea("TMPZ00")
//dbGoTop()

	While TMPZ00->(!Eof())
		lMark :=  aScan( aRetMd , TMPZ00->Z05_MODULO) > 0

		aAdd(aModulos,{ lMark ,;
			TMPZ00->Z05_MODULO,;
			TMPZ00->Z05_DESCRI,;
			TMPZ00->Z05_QUANT,;
			TMPZ00->Z05_CUSTO,;
			TMPZ00->Z05_PRCVEN })


		TMPZ00->(dbSkip())
	End
	TMPZ00->(dbCloseArea())



	If (Len(aModulos) == 0)
		aAdd(aModulos,{.F.,CriaVar("Z05_MODULO",.F.),CriaVar("Z05_DESCRI",.F.),CriaVar("Z05_QUANT",.F.),CriaVar("Z05_CUSTO",.F.),CriaVar("Z05_PRCVEN",.F.)  })
	EndIf

	oModulos:SetArray(aModulos)
	oModulos:bLine:={||{	IIF(aModulos[oModulos:nAt,1],oOk,oNo),;
		aModulos[oModulos:nAt,2],;
		aModulos[oModulos:nAt,3],;
		aModulos[oModulos:nAt,4],;
		aModulos[oModulos:nAt,5],;
		aModulos[oModulos:nAt,6]  }}
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


Static Function EnvMailAprov()

	Local oModel    := FwModelActive()
	Local oField  	    := oModel:GetModel("Z42MASTER")
	Local oGrid    	    := oModel:GetModel("Z43GRID")

	Local cNum      := oField:GetValue("Z42_NUMERO")
	Local cFornece  := oField:GetValue("Z42_FORNEC")
	Local cLjForn   := oField:GetValue("Z42_LJFOR")

	Local ccLI  := oField:GetValue("Z42_CLIENT")
	Local cLjcLI   := oField:GetValue("Z42_LJCLI")

	Local dDtInc   := dtoc(oField:GetValue("Z42_EMISSA") )


	Local cContat   := oField:GetValue("Z42_CONTAT")
	Local nMeses   := oField:GetValue("Z42_MESCON")

	Local nDiasC   := oField:GetValue("Z42_DIASCA")
	Local nMulta   := oField:GetValue("Z42_MULTA")

	Local nMEMO1   := oField:GetValue("Z42_DETAL")
	Local nMEMO2   := oField:GetValue("Z42_OBSG")
	Local nMEMO3   := oField:GetValue("Z42_REGRAR")




	local xAux      := ALLTRIM(oField:GetValue(  'Z42_INICOB' ))
	Local dIniCob   := '01/'+substr(xAux,1,2)+'/'+substr(xAux,3,4)
	Local dFimCob   := dtoc(oField:GetValue("Z42_FIMCON") )


	Local cPropo   := oGrid:GetValue("Z43_PROPOS")
	Local cAdt     := oGrid:GetValue("Z43_ADITIV")



	Local cHtml := ''
	Local nx := 0
	Local aPara:= {}
	Local cParEmail := 'alexandro.dias@alfaerp.com.br;tailan.oliveira@alfaerp.com.br'
	Local cAssunto := 'CONTRATO INCLUIDO :'+Alltrim(cNum)
	Aadd( aPara     , cParEmail  )
	cHtml := '<HTML>'
	cHtml += '<HEAD>'
	cHtml += '<TITLE>ALFA Sistemas de Gestão</TITLE>'
	cHtml += '<STYLE>'
	cHtml += 'BODY	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
	cHtml += 'DIV 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
	cHtml += 'TABLE	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
	cHtml += 'TD 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
	cHtml += '.Mini	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
	cHtml += 'FORM	{MARGIN: 0pt}'
	cHtml += '.S_A 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #FFFFFF; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #0000FF; TEXT-ALIGN: left}  '
	cHtml += '.S_A2	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #FFFFFF; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFA500; TEXT-ALIGN: left}  '
	cHtml += '.S_B 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFFFF; TEXT-ALIGN: left}  '
	cHtml += '.S_C 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFFFF; TEXT-ALIGN: Right} '
	cHtml += '</STYLE>'
	cHtml += '</HEAD>'
	cHtml += '<BODY>'

	cHtml += '<P><B>CONTRATO INCLUIDO  POR : '+UsrRetName( oField:GetValue("Z42_USRLGI")  )+'</B></P>'

	cHtml += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">DATA INCLUSÃO</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + dDtInc +  '</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">CONTRATO</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + Alltrim(cNum) +  '</TD> '
	cHtml += '</TR>'

	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">FORNECEDOR</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' +  Alltrim(Posicione('SA2',1,xFilial('SA2')+cFornece+cLjForn,'A2_NREDUZ')) +  '</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">CONTATO</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + Alltrim(cContat) +  '</TD> '
	cHtml += '</TR>'


	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">CLIENTE</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' +  Alltrim(Posicione('SA1',1,xFilial('SA1')+ccLI+cLjcLI,'A1_NREDUZ')) +  '</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">MESES DE CONTRATO</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + Alltrim(str(nMeses)) +  '</TD> '
	cHtml += '</TR>'


	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">INÍCIO COBRANÇA</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' +  dIniCob +  '</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">DIAS DE CARÊNCIA</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + Alltrim(str(nDiasC)) +  '</TD> '
	cHtml += '</TR>'

	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">FIM COBRANÇA</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' +  dFimCob +  '</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">% MULTA</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 35%">' + Alltrim(str(nMulta)) +  ' %</TD> '
	cHtml += '</TR>'

	cHtml += '</TABLE>'

	cHtml += '<br> '
	cHtml += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtml += '<TR>'
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 33%">DETALHES DA NEGOCIAÇÃO</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 33%">OBSERVAÇÕES GERAIS</TD> '
	cHtml += '	<TD Class=S_A2	Style="WIDTH: 34%">REGRAS DE RESCISÃO</TD> '
	cHtml += '</TR>'

	cHtml += '<TR>'
	cHtml += '	<TD Class=S_B	Style="WIDTH: 33%">'+nMEMO1+'</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 33%">'+nMEMO2+'</TD> '
	cHtml += '	<TD Class=S_B	Style="WIDTH: 34%">'+nMEMO3+'</TD> '
	cHtml += '</TR>'

	cHtml += '</TABLE>'



	cHtmlParcelas := '<P><B>Propostas vinculas:<B></P>'

	cHtmlParcelas += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtmlParcelas += '<TR>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Proposta</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Aditivo</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Modulo</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 20%">Descrição</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Quantidade</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Custo</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Total</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Preço</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Total</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">% Markup</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Vendedor</TD>'
	cHtmlParcelas += '</TR>'
	nPreco:= 0
	nCusto:= 0

	For nx:= 1 to oGrid:Length()
		oGrid:GoLine(nx)
		If !oGrid:IsDeleted()
			cHtmlParcelas += '<TR>'
			cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + Alltrim(oGrid:GetValue("Z43_PROPOS") ) + '</TD>'
			cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + Alltrim(oGrid:GetValue("Z43_ADITIV") ) + '</TD>'
			cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + Alltrim(oGrid:GetValue("Z43_PRODUT") ) + '</TD>'
			cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 20%">' + Alltrim(POSICIONE("Z00",1,XFILIAL("Z00")+oGrid:GetValue("Z43_PRODUT") ,"Z00_DESCRI")) + '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_QUANT") , PesqPict('Z43','Z43_QUANT') )) 		+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_CUNIT") , PesqPict('Z43','Z43_CUNIT') )) 	+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_CTOTAL") , PesqPict('Z43','Z43_CTOTAL') )) 	+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_PUNIT") , PesqPict('Z43','Z43_PUNIT') )) 	+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_PTOTAL") , PesqPict('Z43','Z43_PTOTAL') )) 	+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform( oGrid:GetValue("Z43_MARKUP") , PesqPict('Z43','Z43_MARKUP') )) 	+ '</TD>'
			cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + Alltrim(Posicione('SA3',1, XFILIAL("SA3")+ oGrid:GetValue("Z43_EXECUT") ,'A3_NOME')) + '</TD>'

			cHtmlParcelas += '</TR>'
			nCusto+= oGrid:GetValue("Z43_CTOTAL")
			nPreco+= oGrid:GetValue("Z43_PTOTAL")
		end
	next

	nvlrtitulo  := round(nPreco/nCusto,2)

	cHtmlParcelas += '<TR>'
	cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + 'TOTAL' + '</TD>'
	cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + '' + '</TD>'
	cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 10%">' + '' + '</TD>'
	cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 20%">' + '' + '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + '' + '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + '' 	+ '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(nCusto, PesqPict('Z43','Z43_CTOTAL') )) 	+ '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + '' 	+ '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(nPreco, PesqPict('Z43','Z43_PTOTAL') )) 	+ '</TD>'
	cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(nvlrtitulo, PesqPict('Z43','Z43_MARKUP') )) 	+ '</TD>'
	cHtmlParcelas += '</TR>'

	cHtmlParcelas += '</TABLE>'

	cHtml += cHtmlParcelas//cHtmlProdutos + cHtmlParcelas + cHtmlComissao
	cHtml += '</BODY>'
	cHtml += '</HTML>'

	MemoWrite('C:\Propostas\Exemplo-Contrato.html',cHtml)

	LjMsgRun("Aguarde, enviando informações para Diretoria...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cHtml,.F.,'') } )


Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AfCpContratos
Descricao: Gera as parcelas referenteas ao contrato

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AfCpContratos()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getsaldolic
Descricao: retorna saldo nas propostas

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getsaldolic( cChave,cPropo,cAdt,oGrid )

	local nret:= 0
	Local nItem:=0
	Local cProd:= oGrid:GetValue(  'Z43_PRODUT' )
	Local nLinha:= oGrid:GetLine()
	Local cTmpSld := GetNextAlias()
	cQuery:= " SELECT SUM(Z43_QUANT) Z43_QUANT "+CRLF
	cQuery+= " FROM " + RetSqlName("Z43") + " Z43 "+CRLF
	cQuery+= " WHERE Z43.D_E_L_E_T_ = '' "+CRLF
	cQuery+= " AND Z43_PROPOS = '"+cPropo+"' "+CRLF
	cQuery+= " AND Z43_ADITIV = '"+cAdt+"' "+CRLF
	cQuery+= " AND Z43_PRODUT = '" + AllTrim( cProd ) + "'    "+CRLF
	cQuery+= " AND Z43_NUMERO+Z43_FORNEC+Z43_LJFOR+Z43_PRODUT <>  '"+cChave+"' "+CRLF
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cTmpSld ,.T.,.T.)
	IF (cTmpSld)->(!Eof())
		nret:= (cTmpSld)->Z43_QUANT
	end

	For nItem:= 1 To oGrid:Length()
		oGrid:GoLine(nItem)
		if nLinha <> nitem .and.  cPropo+cAdt+cProd == oGrid:GetValue(  'Z43_PROPOS' )+oGrid:GetValue(  'Z43_ADITIV' )+oGrid:GetValue(  'Z43_PRODUT' )
			nret+= oGrid:GetValue("Z43_QUANT",nItem)
		end
	Next nItem

	oGrid:GoLine(nLinha)

	(cTmpSld)->(dbCloseArea())

return nret

