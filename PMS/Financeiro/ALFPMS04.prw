#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CPO_FILIAL  01
#DEFINE CPO_NUMERO  02
#DEFINE CPO_TIPO    03
#DEFINE CPO_DTGERA  04
#DEFINE CPO_PROPOS  05
#DEFINE CPO_CODCLI  06
#DEFINE CPO_LOJCLI  07
#DEFINE CPO_CODFOR  08
#DEFINE CPO_LOJFOR  09
#DEFINE CPO_E1PREF  10
#DEFINE CPO_E1NUM   11
#DEFINE CPO_E1PARC  12
#DEFINE CPO_E1TIPO  13
#DEFINE CPO_E1BAIX  14
#DEFINE CPO_E1HIST  15
#DEFINE CPO_VLRTIT  16
#DEFINE CPO_IMPOST  17
#DEFINE CPO_VLRLIQ  18
#DEFINE CPO_COMISS  19
#DEFINE CPO_VLRCOM  20
#DEFINE CPO_STATUS  21
#DEFINE CPO_ADITIV  22

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS04
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS04()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local aBoxParam := {}
Local aRetParam := {}

Private dBaixIni := CriaVar("E1_BAIXA",.F.)
Private dBaixFim := CriaVar("E1_BAIXA",.F.)

//Filtros para Query
AADD( aBoxParam, {1,"Dt.Baixa De"	,dBaixIni	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"	,dBaixFim	,"","","","",050,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	dBaixIni := aRetParam[01]
	dBaixFim := aRetParam[02]

    FWMsgRun(, {|| ComisPropos() }, "Aguarde", "Calculando Comissões por Propostas...")

    FWMsgRun(, {|| ComisApontam() }, "Aguarde", "Calculando Comissões por Apontamento...")

    FWMsgRun(, {|| ComisLicenca() }, "Aguarde", "Calculando Comissões de Licenças SAP...")

EndIf

RestArea(aAreaZ16)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ComisPropos
Calcula comissoes por titulos de propostas.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ComisPropos()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""
Local dDtGera   := DATE()

cQuery := " SELECT "+ CRLF
cQuery += " 	Z02.Z02_PROPOS "+ CRLF
cQuery += " 	,Z02.Z02_ADITIV "+ CRLF
cQuery += " 	,SE1.E1_PREFIXO "+ CRLF
cQuery += " 	,SE1.E1_NUM "+ CRLF
cQuery += " 	,SE1.E1_PARCELA "+ CRLF
cQuery += " 	,SE1.E1_TIPO "+ CRLF
cQuery += " 	,SE1.E1_CLIENTE "+ CRLF
cQuery += " 	,SE1.E1_LOJA "+ CRLF
cQuery += " 	,SE1.E1_VALOR "+ CRLF
cQuery += " 	,Z02.Z02_IMPOST "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,Z08.Z08_FORNEC "+ CRLF
cQuery += " 	,Z08.Z08_LOJA "+ CRLF
cQuery += " 	,Z08.Z08_PERC "+ CRLF
cQuery += " 	,Z08.Z08_VALOR "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += " 	AND Z02.Z02_TIPO NOT IN ('3') "+ CRLF // Filtra SAP CLoud - Licenças
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z08")+" Z08 (NOLOCK) "+ CRLF
cQuery += " 	ON Z08.Z08_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z08.Z08_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z08.Z08_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += " 	AND Z08.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z16")
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO
    cChave += (cTMP1)->E1_CLIENTE
    cChave += (cTMP1)->E1_LOJA
    cChave += (cTMP1)->Z08_FORNEC
    cChave += (cTMP1)->Z08_LOJA

    DbSelectArea("Z16")
    DbSetOrder(2) // Z16_FILIAL, Z16_E1PREF, Z16_E1NUM, Z16_E1PARC, Z16_E1TIPO, Z16_CODCLI, Z16_LOJCLI, Z16_CODFOR, Z16_LOJFOR
    If !DbSeek(cChave)
       
        aComissao[CPO_FILIAL] := xFilial("Z16")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "1" // 1=Proposta, 2=Apotamento, 3=Licença
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_CODFOR] := (cTMP1)->Z08_FORNEC
        aComissao[CPO_LOJFOR] := (cTMP1)->Z08_LOJA
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := (cTMP1)->E1_PARCELA
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRTIT] := (cTMP1)->E1_VALOR
        aComissao[CPO_IMPOST] := (cTMP1)->Z02_IMPOST
        aComissao[CPO_VLRLIQ] := (cTMP1)->E1_VALOR * (cTMP1)->Z02_IMPOST
        aComissao[CPO_COMISS] := (cTMP1)->Z08_PERC
        aComissao[CPO_VLRCOM] := (cTMP1)->E1_VALOR * (cTMP1)->Z02_IMPOST * (cTMP1)->Z08_PERC / 100
        aComissao[CPO_STATUS] := "1"
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV

        IncComis(aComissao)
        
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ComisApontam
Calcula comissoes por titulos de apontamento.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ComisApontam()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""
Local nImposto  := GetNewPar("SY_IMPOSTO",0.8635) // Imposto padrão
Local nComissao := GetNewPar("SY_COMISSA",4) // Percentual de Comissão por Apontamento
Local cNotVend  := FormatIn(GetNewPar("SY_NOTVEND","000001,000002"),",") // Não calcula comissão Alex e Fábio
Local dDtGera   := DATE()

cQuery := " SELECT "+ CRLF
cQuery += " 	SE1.E1_FILIAL "+ CRLF
cQuery += " 	,SE1.E1_PREFIXO "+ CRLF
cQuery += " 	,SE1.E1_NUM "+ CRLF
cQuery += " 	,SE1.E1_PARCELA "+ CRLF
cQuery += " 	,SE1.E1_TIPO "+ CRLF
cQuery += " 	,SE1.E1_CLIENTE "+ CRLF
cQuery += " 	,SE1.E1_LOJA "+ CRLF
cQuery += " 	,SE1.E1_VALOR "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,SA3.A3_FORNECE "+ CRLF
cQuery += " 	,SA3.A3_LOJA "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SA1.A1_VEND NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = SA1.A1_VEND "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 (NOLOCK) "+ CRLF
cQuery += " 	ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' "+ CRLF
cQuery += " 	AND SA2.A2_COD = SA3.A3_FORNECE "+ CRLF
cQuery += " 	AND SA2.A2_LOJA = SA3.A3_LOJA "+ CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('HRS','MAN') "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z16")
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO
    cChave += (cTMP1)->E1_CLIENTE
    cChave += (cTMP1)->E1_LOJA
    cChave += (cTMP1)->A3_FORNECE
    cChave += (cTMP1)->A3_LOJA

    DbSelectArea("Z16")
    DbSetOrder(2) // Z16_FILIAL, Z16_E1PREF, Z16_E1NUM, Z16_E1PARC, Z16_E1TIPO, Z16_CODCLI, Z16_LOJCLI, Z16_CODFOR, Z16_LOJFOR
    If !DbSeek(cChave)
        
        aComissao[CPO_FILIAL] := xFilial("Z16")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "2" // 1=Proposta, 2=Apotamento, 3=Licença
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_PROPOS] := ""
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_CODFOR] := (cTMP1)->A3_FORNECE
        aComissao[CPO_LOJFOR] := (cTMP1)->A3_LOJA
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := (cTMP1)->E1_PARCELA
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRTIT] := (cTMP1)->E1_VALOR
        aComissao[CPO_IMPOST] := nImposto
        aComissao[CPO_VLRLIQ] := (cTMP1)->E1_VALOR * nImposto
        aComissao[CPO_COMISS] := nComissao
        aComissao[CPO_VLRCOM] := (cTMP1)->E1_VALOR * nImposto * nComissao / 100
        aComissao[CPO_STATUS] := "1"
        aComissao[CPO_ADITIV] := "00"

        IncComis(aComissao)
        
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ComisLicenca
Calcula comissoes de Licenças SAP.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ComisLicenca()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""
Local dDtGera   := DATE()
Local nParc     := 1

cQuery := " SELECT "+ CRLF
cQuery += "     Z02.Z02_PROPOS "+ CRLF
cQuery += "     ,Z02.Z02_ADITIV "+ CRLF
cQuery += "     ,Z02.Z02_CLIENT "+ CRLF
cQuery += "     ,Z02.Z02_LOJA "+ CRLF
cQuery += "     ,Z08.Z08_FORNEC "+ CRLF
cQuery += "     ,Z08.Z08_LOJA "+ CRLF
cQuery += "     ,Z08.Z08_HISTOR "+ CRLF
cQuery += "     ,Z02.Z02_IMPOST "+ CRLF
cQuery += "     ,Z08.Z08_PARC "+ CRLF
cQuery += "     ,Z08.Z08_PERC "+ CRLF
cQuery += "     ,Z08.Z08_VLRPAR "+ CRLF

cQuery += " FROM "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z08")+" Z08 (NOLOCK) "+ CRLF
cQuery += " 	ON Z08.Z08_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += " 	AND Z08.Z08_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	AND Z08.Z08_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	AND Z08.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z02.Z02_FILIAL = '"+xFilial("Z02")+"' "+ CRLF
cQuery += " 	AND Z02.Z02_TIPO = '3' "+ CRLF // Filtra SAP CLoud - Licenças
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND NOT EXISTS( "+ CRLF
cQuery += "             SELECT "+ CRLF
cQuery += "                 Z16.Z16_PROPOS, "+ CRLF
cQuery += "                 Z16.Z16_ADITIV "+ CRLF
cQuery += "             FROM "+RetSqlName("Z16")+" Z16 (NOLOCK) "+ CRLF
cQuery += "             WHERE "+ CRLF
cQuery += "                 Z16.Z16_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += "                 AND Z16.Z16_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += "                 AND Z16.Z16_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += "                 AND Z16.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "     ) "+ CRLF
cQuery += " 	AND EXISTS( "+ CRLF
cQuery += "             SELECT "+ CRLF
cQuery += "                 SE1.E1_PROPOS, "+ CRLF
cQuery += "                 SE1.E1_ADITIV "+ CRLF
cQuery += "             FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
cQuery += "             WHERE "+ CRLF
cQuery += "                 SE1.E1_FILIAL = Z02.Z02_FILIAL "+ CRLF
cQuery += "                 AND SE1.E1_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += "                 AND SE1.E1_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	            AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	            AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += "                 AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "     ) "+ CRLF

cQuery += " ORDER BY Z02.Z02_PROPOS,Z02.Z02_ADITIV "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())
       
    aComissao[CPO_FILIAL] := xFilial("Z16")
    aComissao[CPO_NUMERO] := ""
    aComissao[CPO_TIPO]   := "3" // 1=Proposta, 2=Apotamento, 3=Licença
    aComissao[CPO_DTGERA] := dDtGera
    aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
    aComissao[CPO_CODCLI] := (cTMP1)->Z02_CLIENT
    aComissao[CPO_LOJCLI] := (cTMP1)->Z02_LOJA
    aComissao[CPO_CODFOR] := (cTMP1)->Z08_FORNEC
    aComissao[CPO_LOJFOR] := (cTMP1)->Z08_LOJA
    aComissao[CPO_E1PREF] := ""
    aComissao[CPO_E1NUM]  := ""
    aComissao[CPO_E1TIPO] := ""
    aComissao[CPO_VLRTIT] := (cTMP1)->Z08_VLRPAR
    aComissao[CPO_IMPOST] := 1
    aComissao[CPO_VLRLIQ] := (cTMP1)->Z08_VLRPAR
    aComissao[CPO_COMISS] := 100
    aComissao[CPO_VLRCOM] := (cTMP1)->Z08_VLRPAR
    aComissao[CPO_STATUS] := "1"

    For nParc := 1 To (cTMP1)->Z08_PARC

        aComissao[CPO_E1BAIX] := dDtGera
        aComissao[CPO_E1PARC] := StrZero(nParc, TAMSX3("E1_PARCELA")[1])
        aComissao[CPO_E1HIST] := "PARCELA " + aComissao[CPO_E1PARC] + " - Hist.: " + (cTMP1)->Z08_HISTOR

        IncComis(aComissao)

    Next nParc

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ComisApontam
Calcula comissoes por titulos de apontamento.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IncComis(aComissao, lMVC)

Local oModel := Nil

Private lMsErroAuto := .F.

DEFAULT lMVC := .T.

If lMVC
    oModel := FwLoadModel("ALFPMS03")
    oModel:SetOperation(MODEL_OPERATION_INSERT)

    oModel:Activate()
    
    oModel:SetValue("Z16MASTER", "Z16_TIPO"  , aComissao[CPO_TIPO]   )
    oModel:SetValue("Z16MASTER", "Z16_PROPOS", aComissao[CPO_PROPOS] )
    oModel:SetValue("Z16MASTER", "Z16_ADITIV", aComissao[CPO_ADITIV] )
    oModel:SetValue("Z16MASTER", "Z16_CODCLI", aComissao[CPO_CODCLI] )
    oModel:SetValue("Z16MASTER", "Z16_LOJCLI", aComissao[CPO_LOJCLI] )
    oModel:SetValue("Z16MASTER", "Z16_CODFOR", aComissao[CPO_CODFOR] )
    oModel:SetValue("Z16MASTER", "Z16_LOJFOR", aComissao[CPO_LOJFOR] )
    oModel:SetValue("Z16MASTER", "Z16_E1PREF", aComissao[CPO_E1PREF] )
    oModel:SetValue("Z16MASTER", "Z16_E1NUM" , aComissao[CPO_E1NUM]  )
    oModel:SetValue("Z16MASTER", "Z16_E1PARC", aComissao[CPO_E1PARC] )
    oModel:SetValue("Z16MASTER", "Z16_E1TIPO", aComissao[CPO_E1TIPO] )
    oModel:SetValue("Z16MASTER", "Z16_E1BAIX", aComissao[CPO_E1BAIX] )
    oModel:SetValue("Z16MASTER", "Z16_E1HIST", AllTrim(aComissao[CPO_E1HIST]) )
    oModel:SetValue("Z16MASTER", "Z16_VLRTIT", aComissao[CPO_VLRTIT] )
    oModel:SetValue("Z16MASTER", "Z16_IMPOST", aComissao[CPO_IMPOST] )
    oModel:SetValue("Z16MASTER", "Z16_VLRLIQ", aComissao[CPO_VLRLIQ] )
    oModel:SetValue("Z16MASTER", "Z16_COMISS", aComissao[CPO_COMISS] )
    oModel:SetValue("Z16MASTER", "Z16_VLRCOM", aComissao[CPO_VLRCOM] )
    oModel:SetValue("Z16MASTER", "Z16_STATUS", aComissao[CPO_STATUS] )

    If oModel:VldData()
        oModel:CommitData()
    Else
        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    
    oModel := NIL

Else
    RecLock("Z16",.T.)
        REPLACE Z16_FILIAL WITH aComissao[CPO_FILIAL]
        REPLACE Z16_NUMERO WITH aComissao[CPO_NUMERO]
        REPLACE Z16_TIPO   WITH aComissao[CPO_TIPO]
        REPLACE Z16_DTGERA WITH aComissao[CPO_DTGERA]
        REPLACE Z16_PROPOS WITH aComissao[CPO_PROPOS]
        REPLACE Z16_ADITIV WITH aComissao[CPO_ADITIV]
        REPLACE Z16_CODCLI WITH aComissao[CPO_CODCLI]
        REPLACE Z16_LOJCLI WITH aComissao[CPO_LOJCLI]
        REPLACE Z16_CODFOR WITH aComissao[CPO_CODFOR]
        REPLACE Z16_LOJFOR WITH aComissao[CPO_LOJFOR]
        REPLACE Z16_E1PREF WITH aComissao[CPO_E1PREF]
        REPLACE Z16_E1NUM  WITH aComissao[CPO_E1NUM]
        REPLACE Z16_E1PARC WITH aComissao[CPO_E1PARC]
        REPLACE Z16_E1TIPO WITH aComissao[CPO_E1TIPO]
        REPLACE Z16_E1BAIX WITH aComissao[CPO_E1BAIX]
        REPLACE Z16_E1HIST WITH aComissao[CPO_E1HIST]
        REPLACE Z16_VLRTIT WITH aComissao[CPO_VLRTIT]
        REPLACE Z16_IMPOST WITH aComissao[CPO_IMPOST]
        REPLACE Z16_VLRLIQ WITH aComissao[CPO_VLRLIQ]
        REPLACE Z16_COMISS WITH aComissao[CPO_COMISS]
        REPLACE Z16_VLRCOM WITH aComissao[CPO_VLRCOM]
        REPLACE Z16_STATUS WITH aComissao[CPO_STATUS]
    MsUnlock()
EndIf

Return .T.
