#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CPO_FILIAL  01
#DEFINE CPO_NUMERO  02
#DEFINE CPO_TIPO    03
#DEFINE CPO_PERIOD  04
#DEFINE CPO_DTGERA  05
#DEFINE CPO_VEND    06
#DEFINE CPO_PROPOS  07
#DEFINE CPO_ADITIV  08
#DEFINE CPO_CODCLI  09
#DEFINE CPO_LOJCLI  10
#DEFINE CPO_MOD     11
#DEFINE CPO_E1PREF  12
#DEFINE CPO_E1NUM   13
#DEFINE CPO_E1PARC  14
#DEFINE CPO_E1TIPO  15
#DEFINE CPO_E1BAIX  16
#DEFINE CPO_E1HIST  17
#DEFINE CPO_VLRBRU  18
#DEFINE CPO_IMPOST  19
#DEFINE CPO_VLRLIQ  20
#DEFINE CPO_COMISS  21
#DEFINE CPO_VLRCOM  22
#DEFINE CPO_META3   23
#DEFINE CPO_STATUS  24

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS53
Calcula comissão trimestral Vendedores (Executivos).

@author  Wilson A. Silva Jr.
@since   17/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS53()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aBoxParam := {}
Local aRetParam := {}

Local aMetaOpc   := { "1=Meta Q1", "2=Meta Q2", "3=Meta Q3", "4=Meta Q4"}

Private cNotVend := FormatIn(GetNewPar("SY_NOTVEND","000001,000002,000049,000146"),",") // Não calcula comissão Alex, Fábio, Tailan e Cristiano
Private dDtGera  := DATE()

Private cMetaTri := "1"
Private dBaixIni := CriaVar("E1_BAIXA",.F.)
Private dBaixFim := CriaVar("E1_BAIXA",.F.)

//Filtros para Query
AADD( aBoxParam, {2,"Trimestre"     ,cMetaTri   ,aMetaOpc,050,".F.",.T.} )
AADD( aBoxParam, {1,"Dt.Baixa De"	,dBaixIni	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"	,dBaixFim	,"","","","",050,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

    cMetaTri := aRetParam[01]
	dBaixIni := aRetParam[02]
	dBaixFim := aRetParam[03]

    FWMsgRun(, {|| CalcComis() }, "Aguarde", "Calculando Bonus Trimestral Executivos...")

EndIf

RestArea(aAreaZ36)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcComis
Calcula comissao trimestral vendedores.

@author  Wilson A. Silva Jr.
@since   17/07/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcComis()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""

Local nFaixa1   := 75
Local nFaixa2   := 100
Local nFaixa3   := 125

cQuery := " SELECT "+ CRLF
cQuery += " 	SA3.A3_COD "+ CRLF
cQuery += " 	,SA3.A3_NOME "+ CRLF
cQuery += " 	,SA3.A3_XMETAQ"+cMetaTri+" "+ CRLF
cQuery += " 	,SUM(Z36_VLRLIQ) AS Z36_VLRLIQ "+ CRLF

cQuery += " FROM "+RetSqlName("Z36")+" Z36 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = Z36.Z36_VEND "+ CRLF
cQuery += " 	AND SA3.A3_FUNCAO = '1' "+ CRLF
cQuery += " 	AND SA3.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SA3.A3_XMETAQ"+cMetaTri+" > 0 "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z36.Z36_FILIAL = '"+xFilial("Z36")+"' "+ CRLF
cQuery += " 	AND Z36.Z36_E1BAIX BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND Z36.Z36_PERIOD = 'M' "+ CRLF
cQuery += " 	AND Z36.Z36_VEND NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z36.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND NOT EXISTS(	"+ CRLF
cQuery += " 		SELECT SE1.E1_VENCREA "+ CRLF
cQuery += " 		FROM "+RetSqlName("SE1")+" SE1 "+ CRLF
cQuery += " 		WHERE "+ CRLF
cQuery += " 			SE1.E1_FILIAL = Z36.Z36_FILIAL "+ CRLF
cQuery += " 			AND SE1.E1_PREFIXO = Z36.Z36_E1PREF "+ CRLF
cQuery += " 			AND SE1.E1_NUM = Z36.Z36_E1NUM "+ CRLF
cQuery += " 			AND SE1.E1_TIPO = Z36.Z36_E1TIPO "+ CRLF
cQuery += " 			AND SE1.E1_PROPOS = Z36.Z36_PROPOS "+ CRLF
cQuery += " 			AND SE1.E1_BAIXA = ' ' "+ CRLF
cQuery += " 			AND DATEDIFF(DAY,SE1.E1_VENCREA,GETDATE()) >= 15 "+ CRLF
cQuery += " 			AND SE1.D_E_L_E_T_ = ' ') "+ CRLF

cQuery += " GROUP BY"+ CRLF
cQuery += " 	SA3.A3_COD"+ CRLF
cQuery += " 	,SA3.A3_NOME"+ CRLF
cQuery += " 	,SA3.A3_XMETAQ"+cMetaTri+" "+ CRLF

cQuery += " ORDER BY"+ CRLF
cQuery += " 	SA3.A3_COD"+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    nVlrLiq  := (cTMP1)->Z36_VLRLIQ
    nVlrMeta := &(cTMP1+"->A3_XMETAQ"+cMetaTri)
    
    nIndice  := (nVlrLiq / nVlrMeta) * 100
    
    If nIndice >= nFaixa3
        nPercCom := 3
    ElseIf nIndice >= nFaixa2
        nPercCom := 2
    ElseIf nIndice >= nFaixa1
        nPercCom := 1
    Else
        nPercCom := 0
    EndIf

    If nPercCom > 0
        nVlrCom  := nVlrLiq * (nPercCom / 100)
    
        aComissao[CPO_FILIAL] := xFilial("Z36")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "B" // P=Proposta ou A=Apotamento ou B=Bonus
        aComissao[CPO_PERIOD] := "T" // M=Mensal ou T=Trimestral
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->A3_COD
        aComissao[CPO_PROPOS] := ""
        aComissao[CPO_ADITIV] := ""
        aComissao[CPO_CODCLI] := ""
        aComissao[CPO_LOJCLI] := ""
        aComissao[CPO_MOD]    := "" // 1=Servicos
        aComissao[CPO_E1PREF] := ""
        aComissao[CPO_E1NUM]  := ""
        aComissao[CPO_E1PARC] := ""
        aComissao[CPO_E1TIPO] := ""
        aComissao[CPO_E1BAIX] := dDtGera
        aComissao[CPO_E1HIST] := "Bonus Trimestral. Periodo: "+DToC(dBaixIni)+" ate "+DToC(dBaixFim)+" "
        aComissao[CPO_VLRBRU] := 0
        aComissao[CPO_IMPOST] := 0
        aComissao[CPO_VLRLIQ] := nVlrLiq
        aComissao[CPO_COMISS] := nPercCom
        aComissao[CPO_VLRCOM] := nVlrCom
        aComissao[CPO_META3]  := nVlrMeta
        aComissao[CPO_STATUS] := "1"

        IncComis(aComissao)
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaZ36)
RestArea(aAreaAtu)

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

Local oModel    := Nil
Local nSaveSX8 	:= GetSX8Len()
Local cMayZ36 	:= "Z36"+AllTrim(xFilial("Z36"))

Private lMsErroAuto := .F.

DEFAULT lMVC := .F.

If lMVC
    oModel := FwLoadModel("ALFPMS50")
    oModel:SetOperation(MODEL_OPERATION_INSERT)

    oModel:Activate()
    
    oModel:SetValue("Z36MASTER", "Z36_TIPO"  , aComissao[CPO_TIPO]   )
    oModel:SetValue("Z36MASTER", "Z36_PROPOS", aComissao[CPO_PROPOS] )
    oModel:SetValue("Z36MASTER", "Z36_ADITIV", aComissao[CPO_ADITIV] )
    oModel:SetValue("Z36MASTER", "Z36_CODCLI", aComissao[CPO_CODCLI] )
    oModel:SetValue("Z36MASTER", "Z36_LOJCLI", aComissao[CPO_LOJCLI] )
    oModel:SetValue("Z36MASTER", "Z36_VEND"  , aComissao[CPO_VEND]   )
    oModel:SetValue("Z36MASTER", "Z36_E1PREF", aComissao[CPO_E1PREF] )
    oModel:SetValue("Z36MASTER", "Z36_E1NUM" , aComissao[CPO_E1NUM]  )
    oModel:SetValue("Z36MASTER", "Z36_E1PARC", aComissao[CPO_E1PARC] )
    oModel:SetValue("Z36MASTER", "Z36_E1TIPO", aComissao[CPO_E1TIPO] )
    oModel:SetValue("Z36MASTER", "Z36_E1BAIX", aComissao[CPO_E1BAIX] )
    oModel:SetValue("Z36MASTER", "Z36_E1HIST", AllTrim(aComissao[CPO_E1HIST]) )
    oModel:SetValue("Z36MASTER", "Z36_VLRBRU", aComissao[CPO_VLRBRU] )
    oModel:SetValue("Z36MASTER", "Z36_IMPOST", aComissao[CPO_IMPOST] )
    oModel:SetValue("Z36MASTER", "Z36_VLRLIQ", aComissao[CPO_VLRLIQ] )
    oModel:SetValue("Z36MASTER", "Z36_COMISS", aComissao[CPO_COMISS] )
    oModel:SetValue("Z36MASTER", "Z36_VLRCOM", aComissao[CPO_VLRCOM] )
    oModel:SetValue("Z36MASTER", "Z36_META3" , aComissao[CPO_META3] )
    oModel:SetValue("Z36MASTER", "Z36_STATUS", aComissao[CPO_STATUS] )

    If oModel:VldData()
        oModel:CommitData()
    Else
        VarInfo("",oModel:GetErrorMessage())
    EndIf

    oModel:DeActivate()
    oModel:Destroy()
    
    oModel := NIL

Else
    // Verifica se o numero ja foi gravado
    cNumCom := GetSxeNum("Z36","Z36_NUMERO",1)
    DbSelectArea("Z36")
    DbSetOrder(1) // Z36_FILIAL+Z36_NUMERO
    While DbSeek(xFilial("Z36")+cNumCom) .OR. !MayIUseCode(cMayZ36+cNumCom)
        cNumCom := GetSxeNum("Z36","Z36_NUMERO",1)
    EndDo

    RecLock("Z36",.T.)
        REPLACE Z36_FILIAL WITH aComissao[CPO_FILIAL]
        REPLACE Z36_NUMERO WITH cNumCom
        REPLACE Z36_TIPO   WITH aComissao[CPO_TIPO]
        REPLACE Z36_PERIOD WITH aComissao[CPO_PERIOD]
        REPLACE Z36_DTGERA WITH aComissao[CPO_DTGERA]
        REPLACE Z36_VEND   WITH aComissao[CPO_VEND]
        REPLACE Z36_PROPOS WITH aComissao[CPO_PROPOS]
        REPLACE Z36_ADITIV WITH aComissao[CPO_ADITIV]
        REPLACE Z36_CODCLI WITH aComissao[CPO_CODCLI]
        REPLACE Z36_LOJCLI WITH aComissao[CPO_LOJCLI]
        REPLACE Z36_MOD    WITH aComissao[CPO_MOD]
        REPLACE Z36_E1PREF WITH aComissao[CPO_E1PREF]
        REPLACE Z36_E1NUM  WITH aComissao[CPO_E1NUM]
        REPLACE Z36_E1PARC WITH aComissao[CPO_E1PARC]
        REPLACE Z36_E1TIPO WITH aComissao[CPO_E1TIPO]
        REPLACE Z36_E1BAIX WITH aComissao[CPO_E1BAIX]
        REPLACE Z36_E1HIST WITH aComissao[CPO_E1HIST]
        REPLACE Z36_VLRBRU WITH aComissao[CPO_VLRBRU]
        REPLACE Z36_IMPOST WITH aComissao[CPO_IMPOST]
        REPLACE Z36_VLRLIQ WITH aComissao[CPO_VLRLIQ]
        REPLACE Z36_COMISS WITH aComissao[CPO_COMISS]
        REPLACE Z36_VLRCOM WITH aComissao[CPO_VLRCOM]
        REPLACE Z36_META3  WITH aComissao[CPO_META3]
        REPLACE Z36_STATUS WITH aComissao[CPO_STATUS]
    MsUnlock()

    EvalTrigger()

    While GetSX8Len() > nSaveSX8
        ConfirmSX8()
    EndDo
    
    // Libera numeros reservados (MayIUseCode)
    FreeUsedCode()
EndIf

Return .T.
