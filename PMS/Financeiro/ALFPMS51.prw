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
#DEFINE CPO_STATUS  23

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS51
Alimenta Extrato de Comiss�es.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS51()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aBoxParam := {}
Local aRetParam := {}

Private cNotVend := FormatIn(GetNewPar("SY_NOTVEND","000001,000002,000049,000146"),",") // N�o calcula comiss�o Alex, F�bio, Tailan e Cristiano
Private dDtGera  := DATE()

Private dBaixIni := CriaVar("E1_BAIXA",.F.)
Private dBaixFim := CriaVar("E1_BAIXA",.F.)

//Filtros para Query
AADD( aBoxParam, {1,"Dt.Baixa De"	,dBaixIni	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"	,dBaixFim	,"","","","",050,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	dBaixIni := aRetParam[01]
	dBaixFim := aRetParam[02]

    FWMsgRun(, {|| PropSrv() }, "Aguarde", "Calculando Comiss�es por Propostas de Servi�o...")

    FWMsgRun(, {|| PropSrv2() }, "Aguarde", "Calculando Comiss�es por Propostas de Servi�o...")

    FWMsgRun(, {|| PropMens() }, "Aguarde", "Calculando Comiss�es por Propostas...")

    FWMsgRun(, {|| Apontamento() }, "Aguarde", "Calculando Comiss�es por Apontamento...")

EndIf

RestArea(aAreaZ36)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PropSrv
Calcula comissoes por titulos de propostas de servi�o.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropSrv()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	Z02.Z02_VEND2 "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
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
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             SUM(Z04.Z04_VALOR) AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('1') "+ CRLF // 1=Servicos
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS TOTAL_PARCELAS "+ CRLF
cQuery += " 	,SA3.A3_COMIS "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.Z02_VEND2 NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND SA3.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND SA3.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
cQuery += " 	AND SE1.E1_PARCELA = '001' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z36")
    cChave += "P"
    cChave += "M"
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += "1"

    DbSelectArea("Z36")
    DbSetOrder(3) // Z36_FILIAL, Z36_TIPO, Z36_PERIOD, Z36_VEND, Z36_PROPOS, Z36_ADITIV, Z36_MOD
    If !DbSeek(cChave)

        nValor   := (cTMP1)->TOTAL_PARCELAS
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := (cTMP1)->A3_COMIS
        nVlrCom  := nVlrLiq * (nPercCom / 100)
       
        aComissao[CPO_FILIAL] := xFilial("Z36")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "P" // P=Proposta ou A=Apotamento ou B=Bonus
        aComissao[CPO_PERIOD] := "M" // M=Mensal ou T=Trimestral
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->Z02_VEND2
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := "1" // 1=Servicos
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := ""
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRBRU] := nValor
        aComissao[CPO_IMPOST] := nImposto
        aComissao[CPO_VLRLIQ] := nVlrLiq
        aComissao[CPO_COMISS] := nPercCom
        aComissao[CPO_VLRCOM] := nVlrCom
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
/*/{Protheus.doc} PropMens
Calcula comissoes por titulos de propostas de 
mensalidades (licen�a e suporte).

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropMens()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	Z02.Z02_VEND2 "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
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
cQuery += " 	,Z04.Z04_MOD "+ CRLF
cQuery += " 	,Z04.Z04_VALOR "+ CRLF
cQuery += " 	,SA3.A3_COMIS "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('2','3','4','6','8') "+ CRLF // 2=TOTVS(SD);3=SAP(Cloud);4=SAP(OnPremise);6=SAP(SD);8=TOTVS(L)
cQuery += " 	AND Z02.Z02_VEND2 NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += " 	AND Z04.Z04_MOD IN ('2','4','5') "+ CRLF // 2=Produtos;4=Parcelas Mensais;5=Suporte Mensal
cQuery += " 	AND Z04.Z04_VALOR > 0 "+ CRLF 
cQuery += " 	AND Z04.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND SA3.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND SA3.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
cQuery += " 	AND SE1.E1_PARCELA = '001' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z36")
    cChave += "P"
    cChave += "M"
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += (cTMP1)->Z04_MOD

    DbSelectArea("Z36")
    DbSetOrder(3) // Z36_FILIAL, Z36_TIPO, Z36_PERIOD, Z36_VEND, Z36_PROPOS, Z36_ADITIV, Z36_MOD
    If !DbSeek(cChave)

        nValor   := ((cTMP1)->Z04_VALOR * 12) // Apenas as 12 primeiras mensalidades
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := (cTMP1)->A3_COMIS
        nVlrCom  := nVlrLiq * (nPercCom / 100)
       
        aComissao[CPO_FILIAL] := xFilial("Z36")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "P" // P=Proposta ou A=Apotamento ou B=Bonus
        aComissao[CPO_PERIOD] := "M" // M=Mensal ou T=Trimestral
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->Z02_VEND2
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := (cTMP1)->Z04_MOD
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := ""
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRBRU] := nValor
        aComissao[CPO_IMPOST] := nImposto
        aComissao[CPO_VLRLIQ] := nVlrLiq
        aComissao[CPO_COMISS] := nPercCom
        aComissao[CPO_VLRCOM] := nVlrCom
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
/*/{Protheus.doc} Apontamento
Calcula comissoes por titulos de apontamento.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Apontamento()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	Z02.Z02_VEND2 "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
cQuery += " 	,Z02.Z02_ADITIV "+ CRLF
cQuery += " 	,SE1.E1_FILIAL "+ CRLF
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
cQuery += " 	,SA3.A3_COMIS "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.Z02_VEND2 NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND SA3.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND SA3.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('MAN') "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z36")
    cChave += "A"
    cChave += "M"
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO

    DbSelectArea("Z36")
    DbSetOrder(2) // Z36_FILIAL, Z36_TIPO, Z36_PERIOD, Z36_VEND, Z36_E1PREF, Z36_E1NUM, Z36_E1PARC, Z36_E1TIPO
    If !DbSeek(cChave)

        nValor   := (cTMP1)->E1_VALOR
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := (cTMP1)->A3_COMIS
        nVlrCom  := nVlrLiq * (nPercCom / 100)
        
        aComissao[CPO_FILIAL] := xFilial("Z36")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "A" // P=Proposta ou A=Apotamento ou B=Bonus
        aComissao[CPO_PERIOD] := "M" // M=Mensal ou T=Trimestral
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->Z02_VEND2
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := "1" // 1=Servico
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := (cTMP1)->E1_PARCELA
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRBRU] := nValor
        aComissao[CPO_IMPOST] := nImposto
        aComissao[CPO_VLRLIQ] := nVlrLiq
        aComissao[CPO_COMISS] := nPercCom
        aComissao[CPO_VLRCOM] := nVlrCom
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
/*/{Protheus.doc} PropSrv2
Calcula comissoes por titulos de propostas de servi�o pra GP e Arquiteto.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropSrv2()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT DISTINCT "+ CRLF
cQuery += " 	SA3.A3_COD "+ CRLF
cQuery += " 	,SA3.A3_NOME "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
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
cQuery += "     ,( SELECT "+ CRLF
cQuery += "             SUM(Z04.Z04_VALOR) AS TOTAL "+ CRLF
cQuery += "         FROM "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "         WHERE "+ CRLF
cQuery += " 	        Z04.Z04_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	        AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	        AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += " 	        AND Z04.Z04_MOD IN ('1') "+ CRLF // 1=Servicos
cQuery += " 	        AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	  ) AS TOTAL_PARCELAS "+ CRLF
cQuery += " 	,SA3.A3_COMIS "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z08")+" Z08 (NOLOCK) "+ CRLF
cQuery += "     ON Z08.Z08_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += "     AND Z08.Z08_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z08.Z08_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z08.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " 	ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SA3.A3_FORNECE = Z08.Z08_FORNEC "+ CRLF
cQuery += " 	AND SA3.A3_LOJA = Z08.Z08_LOJA "+ CRLF
cQuery += " 	AND SA3.A3_FUNCAO IN ('2','6') "+ CRLF // 2=GP/Arquiteto e 6=Gerente
cQuery += " 	AND SA3.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
cQuery += " 	AND SE1.E1_PARCELA = '001' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z36")
    cChave += "P"
    cChave += "M"
    cChave += (cTMP1)->A3_COD
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += "1"

    DbSelectArea("Z36")
    DbSetOrder(3) // Z36_FILIAL, Z36_TIPO, Z36_PERIOD, Z36_VEND, Z36_PROPOS, Z36_ADITIV, Z36_MOD
    If !DbSeek(cChave)

        nValor   := (cTMP1)->TOTAL_PARCELAS
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := (cTMP1)->A3_COMIS
        nVlrCom  := nVlrLiq * (nPercCom / 100)
       
        aComissao[CPO_FILIAL] := xFilial("Z36")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "P" // P=Proposta ou A=Apotamento ou B=Bonus
        aComissao[CPO_PERIOD] := "M" // M=Mensal ou T=Trimestral
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->A3_COD
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := "1" // 1=Servicos
        aComissao[CPO_E1PREF] := (cTMP1)->E1_PREFIXO
        aComissao[CPO_E1NUM]  := (cTMP1)->E1_NUM
        aComissao[CPO_E1PARC] := ""
        aComissao[CPO_E1TIPO] := (cTMP1)->E1_TIPO
        aComissao[CPO_E1BAIX] := SToD((cTMP1)->E1_BAIXA)
        aComissao[CPO_E1HIST] := (cTMP1)->E1_HIST
        aComissao[CPO_VLRBRU] := nValor
        aComissao[CPO_IMPOST] := nImposto
        aComissao[CPO_VLRLIQ] := nVlrLiq
        aComissao[CPO_COMISS] := nPercCom
        aComissao[CPO_VLRCOM] := nVlrCom
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
