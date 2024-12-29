#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS03
Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS03()

Local cFilterDefault := ""

Private aRotina := MenuDef()

Private oBrowse
Private cCadastro := "Extrato de Comissões"

cFilterDefault := U_PMS03FIL()

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "Z16" FILTERDEFAULT cFilterDefault DESCRIPTION cCadastro

		// Adiciona legenda no Browse
		ADD LEGEND DATA {|| Z16->Z16_STATUS == "1" } COLOR "GREEN" 		TITLE "Comissão Pendente" 		OF oBrowse
		ADD LEGEND DATA {|| Z16->Z16_STATUS == "2" } COLOR "YELLOW" 	TITLE "Pagamento Agendado" 		OF oBrowse
		ADD LEGEND DATA {|| Z16->Z16_STATUS == "3" } COLOR "RED" 		TITLE "Pagamento Realizado"	    OF oBrowse
		ADD LEGEND DATA {|| Z16->Z16_STATUS == "4" } COLOR "BLACK" 		TITLE "Pago Manualmente"	    OF oBrowse

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

Local oStruZ16 := FwFormStruct( 1, "Z16")

Local nImposto  := GetNewPar("SY_IMPOSTO",0.8635) // Imposto padrão
Local nComissao := GetNewPar("SY_COMISSA",4) // Percentual de Comissão por Apontamento

// Inicializadores padrão
oStruZ16:SetProperty("Z16_TIPO"  , MODEL_FIELD_INIT, {|| "4" })
oStruZ16:SetProperty("Z16_STATUS", MODEL_FIELD_INIT, {|| "1" })
oStruZ16:SetProperty("Z16_IMPOST", MODEL_FIELD_INIT, {|| nImposto })
oStruZ16:SetProperty("Z16_COMISS", MODEL_FIELD_INIT, {|| nComissao })

// Gatilhos
oStruZ16:AddTrigger("Z16_VLRTIT", "Z16_VLRLIQ", {|| .T. }, {|| VlrComiss("Z16_VLRLIQ") } )
oStruZ16:AddTrigger("Z16_VLRTIT", "Z16_VLRCOM", {|| .T. }, {|| VlrComiss("Z16_VLRCOM") } )
oStruZ16:AddTrigger("Z16_IMPOST", "Z16_VLRLIQ", {|| .T. }, {|| VlrComiss("Z16_VLRLIQ") } )
oStruZ16:AddTrigger("Z16_IMPOST", "Z16_VLRCOM", {|| .T. }, {|| VlrComiss("Z16_VLRCOM") } )
oStruZ16:AddTrigger("Z16_COMISS", "Z16_VLRCOM", {|| .T. }, {|| VlrComiss("Z16_VLRCOM") } )

oModel:= MpFormMOdel():New( "PMS03MVC" ,  /*bPreValid*/ , {|oModel| PostVld(oModel) } , /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription("Comissao")

oModel:AddFields("Z16MASTER", Nil, oStruZ16, /*prevalid*/, , /*bCarga*/)

oModel:GetModel( "Z16MASTER" ):SetDescription( "Comissao" )

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

Local oModel 	:= FwLoadModel("ALFPMS03")
Local oView     := Nil
Local oStruZ16  := FwFormStruct( 2, "Z16")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField("VwFieldZ16", oStruZ16 , "Z16MASTER")

oView:CreateHorizontalBox("SUPERIOR", 100)

oView:SetOwnerView("VwFieldZ16", "SUPERIOR")

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
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.ALFPMS03" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"       		ACTION "VIEWDEF.ALFPMS03" 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"       		ACTION "VIEWDEF.ALFPMS03" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"       		ACTION "VIEWDEF.ALFPMS03" 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Calcular Comissoes"   ACTION "U_ALFPMS04" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Agendar Pagamentos"  	ACTION "U_ALFPMS05" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Pago Manualmente"  	ACTION "U_PMS03MAN" 	    OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Legenda" 		    	ACTION "U_PMS03LEG"	    	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Filtros" 		    	ACTION "U_PMS03FIL"			OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS03LEG
Legenda.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS03LEG()

Local aLegenda := {}

AADD( aLegenda, {"BR_VERDE"		, "Comissão Pendente" 	} )
AADD( aLegenda, {"BR_AMARELO"	, "Pagamento Agendado"  } )
AADD( aLegenda, {"BR_VERMELHO"	, "Pagamento Realizado" } )
AADD( aLegenda, {"BR_PRETO"		, "Pago Manualmente"  	} )
	
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

If Z16->Z16_STATUS <> "1"
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
Local oSubZ16	:= oModel:GetModel("Z16MASTER")
Local lRetorno	:= .T.

If nOper == 4

	lRetorno := .F.
	nVlrCom  := oSubZ16:GetValue("Z16_VLRCOM")

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

@author  Guilherme Santos
@since   23/09/2020
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VlrComiss(cCpoDest)

Local aAreaAtu	:= GetArea()
Local oModel	:= FWModelActive()
Local oSubZ16	:= oModel:GetModel("Z16MASTER")
Local nRetorno 	:= 0
Local nVlrTit   := 0
Local nImposto  := 0
Local nVlqLiq   := 0
Local nComissa  := 0
Local nVlrCom   := 0

nVlrTit  := oSubZ16:GetValue("Z16_VLRTIT")
nImposto := oSubZ16:GetValue("Z16_IMPOST")
nComissa := oSubZ16:GetValue("Z16_COMISS")

nVlqLiq := nVlrTit * nImposto
nVlrCom := nVlqLiq * (nComissa / 100)

DO CASE
	CASE cCpoDest == "Z16_VLRLIQ"
		nRetorno := nVlqLiq
	CASE cCpoDest == "Z16_VLRCOM"
		nRetorno := nVlrCom
ENDCASE

RestArea(aAreaAtu)

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS03FIL
Tela de filtros do browse.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS03MAN()

Local oModel := Nil

If !MSGYESNO('Deseja mudar o status da comissão para "Pago Manualmente"?',"Aviso")
	Return .T.
EndIf

oModel := FwLoadModel("ALFPMS03")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

oModel:Activate()

oModel:SetValue("Z16MASTER", "Z16_STATUS", "4" ) // 4=Pago Manualmente

If oModel:VldData()
	oModel:CommitData()
Else
	MsgInfo("Não foi possivel atualizar status da comissão", "Atenção")
EndIf

oModel:DeActivate()
oModel:Destroy()

oModel := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS03FIL
Tela de filtros do browse.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS03FIL()

Local aBoxParam := {}
Local aRetParam := {}
Local cFiltros  := " Z16_FILIAL = '"+xFilial("Z16")+"' "
Local dGerIni 	:= CriaVar("Z16_DTGERA",.F.)
Local dGerFim	:= CriaVar("Z16_DTGERA",.F.)
Local dBaiIni 	:= CriaVar("Z16_E1BAIX",.F.)
Local dBaiFim	:= CriaVar("Z16_E1BAIX",.F.)
Local cProIni 	:= CriaVar("Z16_PROPOS",.F.)
Local cProFim 	:= CriaVar("Z16_PROPOS",.F.)
Local cCliIni 	:= CriaVar("Z16_CODCLI",.F.)
Local cCliFim 	:= CriaVar("Z16_CODCLI",.F.)
Local cForIni 	:= CriaVar("Z16_CODFOR",.F.)
Local cForFim 	:= CriaVar("Z16_CODFOR",.F.)
Local nStatus	:= 1

//Filtros para Query
AADD( aBoxParam, {1,"Dt.Inclusao De"	,dGerIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Inclusao Ate"	,dGerFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Baixa De"		,dBaiIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"		,dBaiFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Proposta De"		,cProIni	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Proposta Ate"		,cProFim	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Cliente De"		,cCliIni	,"","","SA1","",050,.F.} )
AADD( aBoxParam, {1,"Cliente Ate"		,cCliFim	,"","","SA1","",050,.F.} )
AADD( aBoxParam, {1,"Fornecedor De"		,cForIni	,"","","SA2","",050,.F.} )
AADD( aBoxParam, {1,"Fornecedor Ate"	,cForFim	,"","","SA2","",050,.F.} )
AADD( aBoxParam, {3,"Status"			,nStatus	,{"Todos","Comissão Pendente","Pagamento Agendado","Pagamento Realizado","Pago Manualmente"},100,,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	dGerIni := aRetParam[01]
	dGerFim	:= aRetParam[02]
	dBaiIni	:= aRetParam[03]
	dBaiFim	:= aRetParam[04]
	cProIni	:= aRetParam[05]
	cProFim	:= aRetParam[06]
	cCliIni	:= aRetParam[07]
	cCliFim	:= aRetParam[08]
	cForIni	:= aRetParam[09]
	cForFim	:= aRetParam[10]
	nStatus	:= aRetParam[11]

	// Dt.Geracao DE ATE
	If !Empty(dGerIni) .Or. !Empty(dGerFim)
		cFiltros += " .AND. Z16_DTGERA >= SToD('"+DToS(dGerIni)+"') "
		cFiltros += " .AND. Z16_DTGERA <= SToD('"+DToS(dGerFim)+"') "
	EndIf

	// Dt.Baixa DE ATE
	If !Empty(dBaiIni) .Or. !Empty(dBaiFim)
		cFiltros += " .AND. Z16_E1BAIX >= SToD('"+DToS(dBaiIni)+"') "
		cFiltros += " .AND. Z16_E1BAIX <= SToD('"+DToS(dBaiFim)+"') "
	EndIf

	// Proposta DE ATE
	If !Empty(cProIni) .Or. !Empty(cProFim)
		cFiltros += " .AND. Z16_PROPOS >= '"+cProIni+"' "
		cFiltros += " .AND. Z16_PROPOS <= '"+cProFim+"' "
	EndIf

	// Cliente DE ATE
	If !Empty(cCliIni) .Or. !Empty(cCliFim)
		cFiltros += " .AND. Z16_CODCLI >= '"+cCliIni+"' "
		cFiltros += " .AND. Z16_CODCLI <= '"+cCliFim+"' "
	EndIf

	// Fornecedor DE ATE
	If !Empty(cForIni) .Or. !Empty(cForFim)
		cFiltros += " .AND. Z16_CODFOR >= '"+cForIni+"' "
		cFiltros += " .AND. Z16_CODFOR <= '"+cForFim+"' "
	EndIf
	
	// Status
	DO CASE
		CASE nStatus == 2 // Comissão Pendente
			cFiltros += " .AND. Z16_STATUS == '1' "
		CASE nStatus == 3 // Pagamento Agendado
			cFiltros += " .AND. Z16_STATUS == '2' "
		CASE nStatus == 4 // Pagamento Realizado
			cFiltros += " .AND. Z16_STATUS == '3' "
		CASE nStatus == 5 // Pago Manualmente
			cFiltros += " .AND. Z16_STATUS == '4' "
	ENDCASE
EndIf

If TYPE("oBrowse") <> "U"
	oBrowse:SetFilterDefault(cFiltros)
	TcRefresh(RetSqlName("Z16"))	
	Z16->(dbGoTop())
	oBrowse:Refresh(.T.)
EndIf

Return cFiltros
