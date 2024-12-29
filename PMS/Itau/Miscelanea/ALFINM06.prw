#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM06
Inclui a��es na fila de integra��o com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM06()

Local aAreaAtu := GetArea()
Local lRetorno := .T.
Local cMsgErro := ""

If lRetorno .And. Empty(SE1->E1_EMPFAT)
    cMsgErro := "Empresa de faturamento n�o informada."
    lRetorno := .F.
EndIf

If lRetorno .And. Empty(SE1->E1_XNUMNFS)
    cMsgErro := "Numero da nota n�o foi preenchido."
    lRetorno := .F.
EndIf

// If lRetorno .And. SE1->E1_XSTNFS <> "4"
//     cMsgErro := "Nota precisar estar autorizada antes de envio ao banco."
//     lRetorno := .F.
// EndIf

If lRetorno
    // Checa se boleto j� foi registrado no banco, caso n�o, realiza o registro.
    If Empty(SE1->E1_XIDBOL)
        // Inclui a��o de registro de boleto na fila de integra��o com o Itau
        lRetorno := U_ALFINM01("1")

        // Processa registro de integra��o.
        lRetorno := lRetorno .And. U_ALFINM02(@cMsgErro)

        // Inclui a��o de envio de boleto por e-mail ao cliente
        lRetorno := lRetorno .And. U_ALFINM01("4") 
        
        // Processa envio de boleto por e-mail
        lRetorno := lRetorno .And. U_ALFINM05(@cMsgErro)

    Else
        // Inclui a��o de envio de boleto por e-mail ao cliente
        lRetorno := U_ALFINM01("4")

        // Processa envio de boleto por e-mail
        // lRetorno := lRetorno .And. U_ALFINM05(@cMsgErro)
    EndIf
EndIf

If lRetorno
    // Inclui a��o de envio de boleto por e-mail ao cliente
    // lRetorno := U_ALFINM01("4")

    // Processa envio de boleto por e-mail
    // lRetorno := lRetorno .And. U_ALFINM05(@cMsgErro)

    // StartJob("U_ALFINM09",GetEnvServer(),.F.,cEmpAnt,cFilAnt,XTM->(RECNO()))
EndIf

If lRetorno
    Help(Nil,Nil,ProcName(),,"Boleto registrado com sucesso! Em minutos, ser� enviado ao cliente.",1,5)
Else
    Help(Nil,Nil,ProcName(),,cMsgErro,1,5)
EndIf

RestArea(aAreaAtu)

Return lRetorno
