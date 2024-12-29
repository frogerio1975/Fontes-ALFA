#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} F050INC
 
Descricao: APOS INCLUSÃO CONTAS A PAGAR

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function F050INC()

Local cPrefixo  := SE2->E2_PREFIXO
Local cNumTit   := SE2->E2_NUM
Local cParcela  := SE2->E2_PARCELA
Local cTipo     := SE2->E2_TIPO
Local cCliFor   := SE2->E2_FORNECE
Local cLoja     := SE2->E2_LOJA
Local cRecPag   := "P"
Local aArea := getarea()

SZ0->(DBSETORDER( 1 ))
IF SZ0->( MSSEEK( XFILIAL('SZ0')+ SE2->E2_FORNECE + SE2->E2_LOJA ))	
   WHILE SZ0->( !EOF() ) .AND. SZ0->( Z0_FILIAL+Z0_FORNECE+Z0_LOJA ) == XFILIAL('SZ0')+ SE2->E2_FORNECE + SE2->E2_LOJA

      RecLock("ZZD", .T.)
            ZZD->ZZD_FILIAL  :=  xFilial("ZZD")
            ZZD->ZZD_PREFIX  :=  cPrefixo
            ZZD->ZZD_NUM     :=  cNumTit
            ZZD->ZZD_PARCEL  :=  cParcela
            ZZD->ZZD_TIPO    :=  cTipo
            ZZD->ZZD_CLIFOR  :=  cCliFor
            ZZD->ZZD_LOJA    :=  cLoja
            ZZD->ZZD_EMPFAT  :=  SZ0->Z0_EMPRESA
            ZZD->ZZD_CCUSTO  :=  SZ0->Z0_CCUSTO
            ZZD->ZZD_NATURE  :=  SZ0->Z0_NATURE
            ZZD->ZZD_VALOR   :=  (SZ0->Z0_PERC/100) * SE2->E2_VALOR
            ZZD->ZZD_PERC    :=  SZ0->Z0_PERC
            ZZD->ZZD_HIST    :=  SE2->E2_HIST
            ZZD->ZZD_RECPAG  :=  cRecPag
      MsUnlock()

      SZ0->(DBSKIP())
   END
END 

restArea( aArea )

Return Nil
