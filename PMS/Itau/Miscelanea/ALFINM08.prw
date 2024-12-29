#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM08
Efetua cancelamento do boleto no Itau.

@author  Wilson A. Silva Jr
@since   07/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM08()

Local aAreaAtu := GetArea()
Local lRetorno := .T.
Local cMsgErro := ""

If MsgYesNo("Deseja cancelar o boleto no Itau?","Aviso")

    If lRetorno .And. Empty(SE1->E1_EMPFAT)
        cMsgErro := "Empresa de faturamento não informada."
        lRetorno := .F.
    EndIf

    If lRetorno .And. SE1->E1_XBOLETO <> "1"
        cMsgErro := "Apenas boleto Emitido pode ser cancelado."
        lRetorno := .F.
    EndIf

    If lRetorno .And. Empty(SE1->E1_XIDBOL)
        cMsgErro := "Boleto sem Id de registro no banco."
        lRetorno := .F.
    EndIf

    If lRetorno
        // Inclui ação de baixa de boleto
        lRetorno := U_ALFINM01("2")

        // Integra ação com o banco Itau
        If lRetorno
            LjMsgRun("Cancelando boleto no banco...",,{|| lRetorno := U_ALFINM03(@cMsgErro) } )
        EndIf
    EndIf

    If lRetorno
        Help(Nil,Nil,ProcName(),,"Boleto cancelado com sucesso!",1,5)
    Else
        Help(Nil,Nil,ProcName(),,cMsgErro,1,5)
    EndIf
EndIf

RestArea(aAreaAtu)

Return lRetorno
