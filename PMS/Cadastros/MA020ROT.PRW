#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MA020ROT
 
Descricao: FORNECEDOR

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function MA020ROT()

Local aRotUser := {}//Define Array contendo as Rotinas a executar do programa    

AAdd( aRotUser, { 'Cadastro de Rateio x fornecedores', "U_SZ0CAD()", 0, 4 } )


Return (aRotUser)

//-------------------------------------------------------------------
/*/{Protheus.doc} SZ0CAD
Acionamento da View para rateio .

@author  Pedro
@since   15/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SZ0CAD()

Local nOpc    := MODEL_OPERATION_UPDATE
Local cTela   := "Rateio"

oModel := FWLoadModel("ALFPMS41")

SZ0->(DBSETORDER( 1 ))
IF SZ0->( MSSEEK( XFILIAL('SZ0')+SA2->A2_COD + SA2->A2_LOJA ))	
	FWExecView(cTela, "ALFPMS41", nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aBtnView*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel)
ELSE
	nOpc    := MODEL_OPERATION_INSERT
	oModel:SetOperation( nOpc )
	oModel:Activate()	
	oStrCabc := oModel:GetModel( 'SZ0MASTER' )  
	oStrCabc:SetValue('Z0_FORNECE'  , SA2->A2_COD )
	oStrCabc:SetValue('Z0_LOJA'  	, SA2->A2_LOJA )
	oStrCabc:SetValue('Z0_NOME'  	, SA2->A2_NOME )

	FWExecView(cTela, "ALFPMS41", nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aBtnView*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel)
END


oModel:Destroy()



Return .T.
