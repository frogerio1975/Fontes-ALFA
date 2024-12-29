#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} AFGFIN01
retorna data de faturamento 
E1_XLINKNF para E1_XDTREC

@author  pedro
@since   03/12/2024
@version 1.0
/*/
//-------------------------------------------------------------------
User Function AFGFIN01()

local cRet      := ''
Local aBoxParam	:= {}
Local aRetParam	:= {}
local aArea     := GetArea()

local dNfsIni  := CriaVar("E1_EMISSAO",.F.)
IF !lF040Auto
    AADD( aBoxParam, {1,"Dt.NFS"       , dNfsIni   , "@!", "", ""   , "", 50, .t.} )
    while .t.
        If ParamBox(aBoxParam,"Parametros - Faturamento",@aRetParam,,,,,,,,.F.)     
            dNfsIni  := aRetParam[1]
            exit
        end    
    end

    cRet:= Transform(DToS(dNfsIni), "@R 9999-99-99") + "T00:00:00"
END
RestArea(aArea)

Return cRet
