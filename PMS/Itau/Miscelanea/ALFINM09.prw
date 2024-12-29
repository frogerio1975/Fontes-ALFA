#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM09
JOB para impressao e envio por email do boleto.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM09(cEmpTrab, cFilTrab, nRecXTM)

Local lRetorno := .T.
Local nTent    := 20
Local nX

// Inicializa ambiente.
PREPARE ENVIRONMENT EMPRESA cEmpTrab FILIAL cFilTrab MODULO "FRT" FUNNAME "SIGAFRT"

DbSelectArea("XTM")
DbSetOrder(1)
DbGoTo(nRecXTM)

For nX := 1 To nTent
    
    lRetorno := U_ALFINM05()

    If lRetorno
        EXIT
    EndIf

    Sleep(10000) // Aguarda 10 Segundos para nova tentativa
Next nX

// Finaliza ambiente.
RESET ENVIRONMENT   

Return lRetorno
