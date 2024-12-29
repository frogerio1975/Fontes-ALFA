#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//------------------------------------------------------------------- 
/*/{Protheus.doc} A280GERF

Relatório de Baixas

@author		Pedro H. Oliveira 
@since 		15/11/2023
@version 	P11
/*/
//-------------------------------------------------------------------
User Function A280GERF( )

Local aArea 	:= GetArea()


aadd(aTit,{'E1_XTPSRV'  ,SE1->E1_XTPSRV     ,NIL})
aadd(aTit,{'E1_XTIPO'   ,SE1->E1_XTIPO      ,NIL})
aadd(aTit,{'E1_XTPPARC' ,SE1->E1_XTPPARC    ,NIL})

RestArea(aArea)

return aTit
