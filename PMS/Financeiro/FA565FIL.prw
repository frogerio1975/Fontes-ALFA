#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS16

manipula o filtro na rotina de liquidacao a pagar

@author Pedro Oliveira
@since 01/10/2019
@version P12
/*/
//-------------------------------------------------------------------
user function FA565FIL()
    local cRet := ""

    if MsgYesNo("Deseja filtrar apenas cartão de credito ? ","Filtra Cartão")

        cRet := " .AND. E2_XCCRED == 'C' "

    endif

return(cRet)

