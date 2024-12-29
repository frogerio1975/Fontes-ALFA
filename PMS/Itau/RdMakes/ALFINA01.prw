#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BSFINA11
Fila de Integração de Boletos Banco Itaú.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function BSFINA11()

Local oBrowse

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "XTM" DESCRIPTION "Fila Integração de Boletos Itau"		

    // Adiciona legenda no Browse
    ADD LEGEND DATA {|| XTM->XTM_STATUS == '1' } COLOR "GREEN" 	TITLE "Pendente" 	    OF oBrowse
    ADD LEGEND DATA {|| XTM->XTM_STATUS == '2' } COLOR "RED" 	TITLE "Processado"	    OF oBrowse
    ADD LEGEND DATA {|| XTM->XTM_STATUS == '3' } COLOR "BLACK"  TITLE "Erro" 		    OF oBrowse

// Ativacao da Classe
ACTIVATE FWMBROWSE oBrowse

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MpFormMOdel():New( "ALF01MVC" ,  /*bPreValid*/ , /* bPosValid */ , /*bComValid*/ ,/*bCancel*/ )
Local oStruXTM  := FwFormStruct( 1, "XTM")

oModel:SetDescription("Fila Integração de Boletos Itau")

oModel:AddFields("XTMMASTER", Nil, oStruXTM, /*prevalid*/, , /*bCarga*/)

oModel:GetModel( "XTMMASTER" ):SetDescription( "Parametros" )

oModel:SetPrimaryKey({"XTM_FILIAL", "XTM_PREFIX", "XTM_NUMTIT", "XTM_PARCEL", "XTM_TIPO", "XTM_CLIENT", "XTM_LOJA", "XTM_SEQUEN"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= FwLoadModel("BSFINA11")
Local oView 	:= FwFormView():New()
Local oStruXTM  := FwFormStruct( 2, "XTM")

oView:SetModel(oModel)

oView:AddField("VwFieldXTM", oStruXTM , "XTMMASTER")

oView:CreateHorizontalBox("TELA", 100)

oView:SetOwnerView("VwFieldXTM", "TELA")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.BSFINA11" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Processar"    ACTION "U_ALF01PRO" 	    OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Legenda"      ACTION "U_ALF01LEG" 	    OPERATION 2 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ALF01LEG
Legenda.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALF01LEG()

Local aLegenda := {}

AADD( aLegenda, {"BR_VERDE"		, "Pendente"        } )
AADD( aLegenda, {"BR_VERMELHO"	, "Processado"      } )
AADD( aLegenda, {"BR_PRETO"	    , "Erro"            } )
    
BrwLegenda("Monitor","Legenda",aLegenda)

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} ALF01PRO
Rotina de processamento.

@author  Wilson A. Silva Jr
@since   06/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALF01PRO()

Local aAreaAtu := GetArea()
Local lRetorno := .F.
Local cMsgErro := ""

If MsgYesNo("Deseja processar a solicitação?","Aviso")
    DO CASE
        CASE XTM->XTM_STATUS $ "2"
            MsgInfo("Esta solicitação já foi processada.","Atenção")
        OTHERWISE
            lRetorno := .T.
    ENDCASE
EndIf

If lRetorno
    DO CASE
        CASE XTM->XTM_ACAO == "1" // Registro Boleto
            FWMsgRun(, {|| lRetorno := U_ALFINM02(@cMsgErro) }, "Aguarde", "Processando solicitação...")
        CASE XTM->XTM_ACAO == "2" // Cancelamento/Baixa Boleto
            FWMsgRun(, {|| lRetorno := U_ALFINM03(@cMsgErro) }, "Aguarde", "Processando solicitação...")
        CASE XTM->XTM_ACAO == "3" // Alteração Vencimento
            FWMsgRun(, {|| lRetorno := U_ALFINM04(@cMsgErro) }, "Aguarde", "Processando solicitação...")
        CASE XTM->XTM_ACAO == "4" // Envio de Boleto Por E-mail
            FWMsgRun(, {|| lRetorno := U_ALFINM05(@cMsgErro) }, "Aguarde", "Processando solicitação...")
        OTHERWISE
            MsgInfo("Tipo de ação não identificada: " + XTM->XTM_ACAO,"Atenção")
            lRetorno := .F.
    ENDCASE

    If lRetorno
        MsgInfo("Solicitação processada com sucesso.","Atenção")
    Else
        MsgInfo("Ocorreu erro no processamento, o mesmo foi encerrado.","Atenção")
    EndIf
EndIf

RestArea(aAreaAtu)

Return .T.
