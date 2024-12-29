#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS58
Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS58( c_Vend )

Local cFilterDefault := ""

Private aRotina := MenuDef()

Private oBrowse
Private cCadastro := "Extrato de Comissões"

Default c_Vend := ''

// cFilterDefault := U_PMS58FIL()

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "Z39" FILTERDEFAULT cFilterDefault DESCRIPTION cCadastro

	// Adiciona legenda no Browse
	ADD LEGEND DATA {|| Z39->Z39_STATUS == "1" } COLOR "GREEN" 		TITLE "Comissão Pendente" 		OF oBrowse
	ADD LEGEND DATA {|| Z39->Z39_STATUS == "2" } COLOR "YELLOW" 	TITLE "Pagamento Agendado" 		OF oBrowse
	ADD LEGEND DATA {|| Z39->Z39_STATUS == "3" } COLOR "RED" 		TITLE "Pagamento Realizado"	    OF oBrowse

// Ativacao da Classe
ACTIVATE FWMBROWSE oBrowse

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

Local oStruZ39 := FwFormStruct( 1, "Z39")

Local nImposto  := GetNewPar("SY_IMPOSTO",0.8635) // Imposto padrão
Local nComissao := GetNewPar("SY_COMISSA",2) // Percentual de Comissão por Apontamento

// Inicializadores padrão
oStruZ39:SetProperty("Z39_STATUS", MODEL_FIELD_INIT, {|| "1" })
oStruZ39:SetProperty("Z39_IMPOST", MODEL_FIELD_INIT, {|| nImposto })
oStruZ39:SetProperty("Z39_COMISS", MODEL_FIELD_INIT, {|| nComissao })

// Gatilhos
oStruZ39:AddTrigger("Z39_VLRBRU", "Z39_VLRLIQ", {|| .T. }, {|| VlrComiss("Z39_VLRLIQ") } )
oStruZ39:AddTrigger("Z39_VLRBRU", "Z39_VLRCOM", {|| .T. }, {|| VlrComiss("Z39_VLRCOM") } )
oStruZ39:AddTrigger("Z39_IMPOST", "Z39_VLRLIQ", {|| .T. }, {|| VlrComiss("Z39_VLRLIQ") } )
oStruZ39:AddTrigger("Z39_IMPOST", "Z39_VLRCOM", {|| .T. }, {|| VlrComiss("Z39_VLRCOM") } )
oStruZ39:AddTrigger("Z39_COMISS", "Z39_VLRCOM", {|| .T. }, {|| VlrComiss("Z39_VLRCOM") } )

oModel:= MpFormMOdel():New( "PMS58MVC" ,  /*bPreValid*/ , {|oModel| PostVld(oModel) } , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription("Comissao")

oModel:AddFields("Z39MASTER", Nil, oStruZ39, /*prevalid*/, , /*bCarga*/)

oModel:GetModel( "Z39MASTER" ):SetDescription( "Comissao" )

oModel:SetVldActivate( { |oModel| VldActivate(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFPMS58")
Local oView     := Nil
Local oStruZ39  := FwFormStruct( 2, "Z39")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VwFieldZ39", oStruZ39 , "Z39MASTER")

oView:CreateHorizontalBox("SUPERIOR", 100)

oView:SetOwnerView("VwFieldZ39", "SUPERIOR")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu funcional.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        	ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.ALFPMS58" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"       		ACTION "VIEWDEF.ALFPMS58" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"       		ACTION "VIEWDEF.ALFPMS58" 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Calcular Comissoes"   ACTION "U_ALFPMS59" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Agendar Pagamentos"  	ACTION "U_ALFPMS60" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Legenda" 		    	ACTION "U_PMS58LEG"	    	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Filtros" 		    	ACTION "U_PMS58FIL"			OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS58LEG
Legenda.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS58LEG()

Local aLegenda := {}

AADD( aLegenda, {"BR_VERDE"		, "Comissão Pendente" 	} )
AADD( aLegenda, {"BR_AMARELO"	, "Pagamento Agendado"  } )
AADD( aLegenda, {"BR_VERMELHO"	, "Pagamento Realizado" } )
	
BrwLegenda(cCadastro,"Legenda",aLegenda)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PostVld
Validacoes no carregamento do model.

@author  Wilson A. Silva Jr.
@since   31/01/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function VldActivate(oModel)

Local aAreaAtu	 := GetArea()
Local nOperation := oModel:GetOperation()
Local lRet 		 := .T.

If Z39->Z39_STATUS <> "1"
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

//-------------------------------------------------------------------
/*/{Protheus.doc} PostVld
Bloco de código de pós-validação do modelo, equilave ao "TUDOOK".

@author  Wilson A. Silva Jr.
@since   31/01/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function PostVld(oModel)

Local nOper		:= oModel:GetOperation()		//3-Inclusao | 4-Alteracao | 5-Exclusao
Local oSubZ39	:= oModel:GetModel("Z39MASTER")
Local lRetorno	:= .T.

If nOper == 4

	lRetorno := .F.
	nVlrCom  := oSubZ39:GetValue("Z39_VLRCOM")

	DO CASE
		CASE nVlrCom == 0
			Help(" ", 1, "Help", "FORMPOS", "Valor de comissão não pode estar zerado.", 3, 0)
		OTHERWISE
			lRetorno := .T.
	ENDCASE
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VlrComiss
Gatilho para alimentacao do Preco

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VlrComiss(cCpoDest)

Local aAreaAtu	:= GetArea()
Local oModel	:= FWModelActive()
Local oSubZ39	:= oModel:GetModel("Z39MASTER")
Local nRetorno 	:= 0
Local nValor    := 0
Local nImposto  := 0
Local nVlqLiq   := 0
Local nComissa  := 0
Local nVlrCom   := 0

nValor   := oSubZ39:GetValue("Z39_VLRBRU")
nImposto := oSubZ39:GetValue("Z39_IMPOST")
nComissa := oSubZ39:GetValue("Z39_COMISS")

nVlqLiq := nValor * nImposto
nVlrCom := nVlqLiq * (nComissa / 100)

DO CASE
	CASE cCpoDest == "Z39_VLRLIQ"
		nRetorno := nVlqLiq
	CASE cCpoDest == "Z39_VLRCOM"
		nRetorno := nVlrCom
ENDCASE

RestArea(aAreaAtu)

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS58FIL
Tela de filtros do browse.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS58FIL()

Local aBoxParam := {}
Local aRetParam := {}
Local cFiltros  := " Z39_FILIAL = '"+xFilial("Z39")+"' "
Local dGerIni 	:= CriaVar("Z39_DTGERA",.F.)
Local dGerFim	:= CriaVar("Z39_DTGERA",.F.)
Local dBaiIni 	:= CriaVar("Z39_E1BAIX",.F.)
Local dBaiFim	:= CriaVar("Z39_E1BAIX",.F.)
Local cProIni 	:= CriaVar("Z39_PROPOS",.F.)
Local cProFim 	:= CriaVar("Z39_PROPOS",.F.)
Local cCliIni 	:= CriaVar("Z39_CODCLI",.F.)
Local cCliFim 	:= CriaVar("Z39_CODCLI",.F.)
Local cVendIni 	:= CriaVar("Z39_VEND",.F.)
Local cVendFim 	:= CriaVar("Z39_VEND",.F.)
Local nStatus	:= 1

//Filtros para Query
AADD( aBoxParam, {1,"Dt.Calculo De"		,dGerIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Calculo Ate"	,dGerFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Baixa De"		,dBaiIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"		,dBaiFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Proposta De"		,cProIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Proposta Ate"		,cProFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Cliente De"		,cCliIni	,"","","SA1","",050,.F.} )
AADD( aBoxParam, {1,"Cliente Ate"		,cCliFim	,"","","SA1","",050,.F.} )
AADD( aBoxParam, {1,"Vendedor De"		,cVendIni	,"","","SA3","",050,.F.} )
AADD( aBoxParam, {1,"Vendedor Ate"		,cVendFim	,"","","SA3","",050,.F.} )
AADD( aBoxParam, {3,"Status"			,nStatus	,{"Todos","Comissão Pendente","Pagamento Agendado","Pagamento Realizado"},100,,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	dGerIni := aRetParam[01]
	dGerFim	:= aRetParam[02]
	dBaiIni	:= aRetParam[03]
	dBaiFim	:= aRetParam[04]
	cProIni	:= aRetParam[05]
	cProFim	:= aRetParam[06]
	cCliIni	:= aRetParam[07]
	cCliFim	:= aRetParam[08]
	cVendIni:= aRetParam[09]
	cVendFim:= aRetParam[10]
	nStatus	:= aRetParam[11]

	// Dt.Geracao DE ATE
	If !Empty(dGerIni) .Or. !Empty(dGerFim)
		cFiltros += " .AND. Z39_DTGERA >= SToD('"+DToS(dGerIni)+"') "
		cFiltros += " .AND. Z39_DTGERA <= SToD('"+DToS(dGerFim)+"') "
	EndIf

	// Dt.Baixa DE ATE
	If !Empty(dBaiIni) .Or. !Empty(dBaiFim)
		cFiltros += " .AND. Z39_E1BAIX >= SToD('"+DToS(dBaiIni)+"') "
		cFiltros += " .AND. Z39_E1BAIX <= SToD('"+DToS(dBaiFim)+"') "
	EndIf

	// Proposta DE ATE
	If !Empty(cProIni) .Or. !Empty(cProFim)
		cFiltros += " .AND. Z39_PROPOS >= '"+cProIni+"' "
		cFiltros += " .AND. Z39_PROPOS <= '"+cProFim+"' "
	EndIf

	// Cliente DE ATE
	If !Empty(cCliIni) .Or. !Empty(cCliFim)
		cFiltros += " .AND. Z39_CODCLI >= '"+cCliIni+"' "
		cFiltros += " .AND. Z39_CODCLI <= '"+cCliFim+"' "
	EndIf

	// Vendedor DE ATE
	If !Empty(cVendIni) .Or. !Empty(cVendFim)
		cFiltros += " .AND. Z39_VEND >= '"+cVendIni+"' "
		cFiltros += " .AND. Z39_VEND <= '"+cVendFim+"' "
	EndIf
	
	// Status
	DO CASE
		CASE nStatus == 2 // Comissão Pendente
			cFiltros += " .AND. Z39_STATUS == '1' "
		CASE nStatus == 3 // Pagamento Agendado
			cFiltros += " .AND. Z39_STATUS == '2' "
		CASE nStatus == 4 // Pagamento Realizado
			cFiltros += " .AND. Z39_STATUS == '3' "
	ENDCASE
EndIf

If TYPE("oBrowse") <> "U"
	oBrowse:SetFilterDefault(cFiltros)
	TcRefresh(RetSqlName("Z39"))	
	Z39->(dbGoTop())
	oBrowse:Refresh(.T.)
EndIf

Return cFiltros
