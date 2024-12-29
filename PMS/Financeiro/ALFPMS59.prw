#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CPO_FILIAL  01
#DEFINE CPO_NUMERO  02
#DEFINE CPO_TIPO    03
#DEFINE CPO_DTGERA  04
#DEFINE CPO_VEND    05
#DEFINE CPO_PROPOS  06
#DEFINE CPO_ADITIV  07
#DEFINE CPO_CODCLI  08
#DEFINE CPO_LOJCLI  09
#DEFINE CPO_MOD     10
#DEFINE CPO_E1PREF  11
#DEFINE CPO_E1NUM   12
#DEFINE CPO_E1PARC  13
#DEFINE CPO_E1TIPO  14
#DEFINE CPO_E1BAIX  15
#DEFINE CPO_E1HIST  16
#DEFINE CPO_VLRBRU  17
#DEFINE CPO_IMPOST  18
#DEFINE CPO_VLRLIQ  19
#DEFINE CPO_COMISS  20
#DEFINE CPO_VLRCOM  21
#DEFINE CPO_STATUS  22

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS59
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS59()

Local aAreaAtu  := GetArea()
Local aAreaZ39  := Z39->(GetArea())
Local aBoxParam := {}
Local aRetParam := {}

Private cNotVend := FormatIn(GetNewPar("SY_NOTVEND","000001,000002,000049,000146"),",") // Não calcula comissão Alex, Fábio, Tailan e Cristiano
Private dDtGera  := DATE()

Private dBaixIni := CriaVar("E1_BAIXA",.F.)
Private dBaixFim := CriaVar("E1_BAIXA",.F.)

//Filtros para Query
AADD( aBoxParam, {1,"Dt.Baixa De"	,dBaixIni	,"","","","",050,.T.} )
AADD( aBoxParam, {1,"Dt.Baixa Ate"	,dBaixFim	,"","","","",050,.T.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	dBaixIni := aRetParam[01]
	dBaixFim := aRetParam[02]

    FWMsgRun(, {|| PropSrv() }, "Aguarde", "Calculando Comissões por Propostas de Serviço...")

    FWMsgRun(, {|| PropSrv2() }, "Aguarde", "Calculando Comissões por Propostas de Serviço...")

    FWMsgRun(, {|| PropMens(.T.) }, "Aguarde", "Calculando Comissões por Propostas...")
    FWMsgRun(, {|| PropMens(.F.) }, "Aguarde", "Calculando Comissões por Propostas...")


    FWMsgRun(, {|| Apontamento() }, "Aguarde", "Calculando Comissões por Apontamento...")

EndIf

RestArea(aAreaZ39)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PropSrv
Calcula comissoes por titulos de propostas de serviço.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropSrv()

Local aAreaAtu  := GetArea()
Local aAreaZ39  := Z39->(GetArea())
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
cQuery += " 	,(CASE WHEN Z02.Z02_IMPINC = '1' THEN Z02.Z02_IMPOST ELSE 1 END) AS Z02_IMPOST "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,VND.A3_COMIS "+ CRLF
cQuery += " 	,ISNULL(Z37.Z37_COMISS,0) AS Z37_COMISS "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COD,' ') AS A3_SUPER "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COMIS,0) AS SUP_COMIS "+ CRLF
cQuery += "     ,Z04.Z04_VALOR "+ CRLF
cQuery += "     ,Z02.Z02_RENOVA "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.Z02_VEND2 NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_PARCEL = SE1.E1_PARCELA "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z04.Z04_MOD IN ('1') "+ CRLF // 1=Servicos
cQuery += "     AND Z04.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" VND (NOLOCK) "+ CRLF
cQuery += " 	ON VND.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND VND.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND VND.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND VND.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND VND.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SUP (NOLOCK) "+ CRLF
cQuery += " 	ON SUP.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SUP.A3_COD = VND.A3_SUPER "+ CRLF
cQuery += " 	AND SUP.A3_FUNCAO = '6' "+ CRLF // 6=Gerente
cQuery += " 	AND SUP.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SUP.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z38")+" Z38 (NOLOCK) "+ CRLF
cQuery += " 	ON Z38.Z38_FILIAL = '"+xFilial("Z38")+"' "+ CRLF
cQuery += " 	AND Z38.Z38_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	AND Z38.Z38_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	AND Z38.Z38_CODCLI = Z02.Z02_CLIENT "+ CRLF
cQuery += " 	AND Z38.Z38_LOJCLI = Z02.Z02_LOJA "+ CRLF
cQuery += " 	AND Z38.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z37")+" Z37 (NOLOCK) "+ CRLF
cQuery += " 	ON Z37.Z37_FILIAL = '"+xFilial("Z37")+"' "+ CRLF
cQuery += " 	AND Z37.Z37_VEND = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND Z37.Z37_ANO = Z38.Z38_ANO "+ CRLF
cQuery += " 	AND Z37.Z37_MES = Z38.Z38_MES "+ CRLF
cQuery += " 	AND Z37.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += " AND SE1.E1_NUM = '000043162' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())
    /*
    cChave := xFilial("Z39")
    cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += "1"
    DbSelectArea("Z39")
    DbSetOrder(3) // Z39_FILIAL, Z39_TIPO, Z39_VEND, Z39_PROPOS, Z39_ADITIV, Z39_MOD
    */
    cChave := xFilial("Z39")
    cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO

    DbSelectArea("Z39")
    DbSetOrder(2) // Z39_FILIAL+Z39_TIPO+Z39_VEND+Z39_E1PREF+Z39_E1NUM+Z39_E1PARC+Z39_E1TIPO
    If !DbSeek(cChave)

        nValor   := (cTMP1)->Z04_VALOR
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := IF((cTMP1)->Z02_RENOVA=="2",1,IF((cTMP1)->Z37_COMISS > 0, (cTMP1)->Z37_COMISS, (cTMP1)->A3_COMIS))
        nVlrCom  := nVlrLiq * (nPercCom / 100)
       
        aComissao[CPO_FILIAL] := xFilial("Z39")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "1" // 1=Proposta;2=Apontamento;3=Avulso
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->Z02_VEND2
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := "1" // 1=Servicos
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

        // Comissão Gerente
        If !Empty((cTMP1)->A3_SUPER) .And. (cTMP1)->SUP_COMIS > 0 .And. (cTMP1)->Z02_RENOVA <> "2"
            
            nVlrCom  := nVlrLiq * ((cTMP1)->SUP_COMIS / 100)
        
            aComissao[CPO_VEND]   := (cTMP1)->A3_SUPER
            aComissao[CPO_COMISS] := (cTMP1)->SUP_COMIS
            aComissao[CPO_VLRCOM] := nVlrCom

            IncComis(aComissao)

        EndIf
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaZ39)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PropMens
Calcula comissoes por titulos de propostas de 
mensalidades (licença e suporte).

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropMens( lSetup)

Local aAreaAtu  := GetArea()
Local aAreaZ39  := Z39->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""
Local nX


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
cQuery += " 	,(CASE WHEN Z02.Z02_IMPINC = '1' THEN Z02.Z02_IMPOST ELSE 1 END) AS Z02_IMPOST "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,Z04.Z04_MOD "+ CRLF
cQuery += " 	,VND.A3_COMIS "+ CRLF
cQuery += " 	,ISNULL(Z37.Z37_COMISS,0) AS Z37_COMISS "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COD,' ') AS A3_SUPER "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COMIS,0) AS SUP_COMIS "+ CRLF
cQuery += "     ,Z04.Z04_VALOR "+ CRLF
cQuery += "     ,Z02.Z02_RENOVA "+ CRLF

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
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
If lSetup
    cQuery += " 	AND Z04.Z04_MOD IN ('3') "+ CRLF // 2=Produtos;3=Setup;4=Parcelas Mensais;5=Suporte Mensal
Else
    cQuery += " 	AND Z04.Z04_MOD IN ('2','4','5') "+ CRLF // 2=Produtos;3=Setup;4=Parcelas Mensais;5=Suporte Mensal
End
cQuery += " 	AND Z04.Z04_VALOR > 0 "+ CRLF 
cQuery += "     AND Z04.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" VND (NOLOCK) "+ CRLF
cQuery += " 	ON VND.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND VND.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND VND.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND VND.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND VND.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SUP (NOLOCK) "+ CRLF
cQuery += " 	ON SUP.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SUP.A3_COD = VND.A3_SUPER "+ CRLF
cQuery += " 	AND SUP.A3_FUNCAO = '6' "+ CRLF // 6=Gerente
cQuery += " 	AND SUP.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SUP.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z38")+" Z38 (NOLOCK) "+ CRLF
cQuery += " 	ON Z38.Z38_FILIAL = '"+xFilial("Z38")+"' "+ CRLF
cQuery += " 	AND Z38.Z38_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	AND Z38.Z38_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	AND Z38.Z38_CODCLI = Z02.Z02_CLIENT "+ CRLF
cQuery += " 	AND Z38.Z38_LOJCLI = Z02.Z02_LOJA "+ CRLF
cQuery += " 	AND Z38.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z37")+" Z37 (NOLOCK) "+ CRLF
cQuery += " 	ON Z37.Z37_FILIAL = '"+xFilial("Z37")+"' "+ CRLF
cQuery += " 	AND Z37.Z37_VEND = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND Z37.Z37_ANO = Z38.Z38_ANO "+ CRLF
cQuery += " 	AND Z37.Z37_MES = Z38.Z38_MES "+ CRLF
cQuery += " 	AND Z37.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
If lSetup
    cQuery += " 	AND SE1.E1_PARCELA = '001' "+ CRLF
Else
    cQuery += " 	AND SE1.E1_PARCELA <= '004' "+ CRLF
End
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += " AND SE1.E1_NUM = '000043162' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())


    cChave := xFilial("Z39")
    If lSetup
        cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
        cChave += (cTMP1)->Z02_VEND2
        cChave += (cTMP1)->Z02_PROPOS
        cChave += (cTMP1)->Z02_ADITIV
        cChave += (cTMP1)->Z04_MOD

        DbSelectArea("Z39")
        DbSetOrder(3) // Z39_FILIAL, Z39_TIPO, Z39_VEND, Z39_PROPOS, Z39_ADITIV, Z39_MOD
    Else
        cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
        cChave += (cTMP1)->Z02_VEND2
        cChave += (cTMP1)->E1_PREFIXO
        cChave += (cTMP1)->E1_NUM
        cChave += (cTMP1)->E1_PARCELA
        cChave += (cTMP1)->E1_TIPO

        DbSelectArea("Z39")
        DbSetOrder(2) // Z39_FILIAL+Z39_TIPO+Z39_VEND+Z39_E1PREF+Z39_E1NUM+Z39_E1PARC+Z39_E1TIPO
    End
    If !DbSeek(cChave)

        If (cTMP1)->Z04_MOD == "3" // Setup
            nParcelas  := 1 
            nVezes     := 1
        Else // (SAAS e AMS)
            nParcelas  := 4  // Paga a comissao em 4 vezes
            nVezes     := 12 // Apenas as 12 primeiras mensalidades (SAAS e AMS)
        EndIf

        nValor   := ((cTMP1)->Z04_VALOR * nVezes)

        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto

        // Para Setup, só gera comissao se >= 5 mil
        If (cTMP1)->Z04_MOD == "3" .And. nVlrLiq < 5000  
            (cTMP1)->(DbSkip())
            LOOP
        EndIf
        
        nPercCom := IF((cTMP1)->Z02_RENOVA=="2",1,IF((cTMP1)->Z37_COMISS > 0, (cTMP1)->Z37_COMISS, (cTMP1)->A3_COMIS))
        nVlrCom  := (nVlrLiq * (nPercCom / 100)) / nParcelas
       
        aComissao[CPO_FILIAL] := xFilial("Z39")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "1" // 1=Proposta;2=Apontamento;3=Avulso
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
    
        aComissao[CPO_E1PARC] := (cTMP1)->E1_PARCELA
        IncComis(aComissao)
        /*
        For nX := 1 To nParcelas

            aComissao[CPO_E1PARC] := StrZero(nX, TAMSX3("E1_PARCELA")[1])

            IncComis(aComissao)
        Next nX
        */
        // Comissão Gerente
        If !Empty((cTMP1)->A3_SUPER) .And. (cTMP1)->SUP_COMIS > 0 .And. (cTMP1)->Z02_RENOVA <> "2"
            
            nPercCom := (cTMP1)->SUP_COMIS
            nVlrCom  := (nVlrLiq * (nPercCom / 100)) / nParcelas
        
            aComissao[CPO_VEND]   := (cTMP1)->A3_SUPER
            aComissao[CPO_COMISS] := nPercCom
            aComissao[CPO_VLRCOM] := nVlrCom
            
            aComissao[CPO_E1PARC] := (cTMP1)->E1_PARCELA
            IncComis(aComissao)
            /*
            For nX := 1 To nParcelas

                aComissao[CPO_E1PARC] := StrZero(nX, TAMSX3("E1_PARCELA")[1])

                IncComis(aComissao)
            Next nX
            */
        EndIf
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())


RestArea(aAreaZ39)
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
Local aAreaZ39  := Z39->(GetArea())
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
cQuery += " 	,(CASE WHEN Z02.Z02_IMPINC = '1' THEN Z02.Z02_IMPOST ELSE 1 END) AS Z02_IMPOST "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,VND.A3_COMIS "+ CRLF
cQuery += " 	,ISNULL(Z37.Z37_COMISS,0) AS Z37_COMISS "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COD,' ') AS A3_SUPER "+ CRLF
cQuery += " 	,ISNULL(SUP.A3_COMIS,0) AS SUP_COMIS "+ CRLF
cQuery += "     ,Z02.Z02_RENOVA "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.Z02_VEND2 NOT IN "+cNotVend+" "+ CRLF
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" VND (NOLOCK) "+ CRLF
cQuery += " 	ON VND.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND VND.A3_COD = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND VND.A3_FUNCAO = '1' "+ CRLF // 1=Vendedor
cQuery += " 	AND VND.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND VND.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SA3")+" SUP (NOLOCK) "+ CRLF
cQuery += " 	ON SUP.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND SUP.A3_COD = VND.A3_SUPER "+ CRLF
cQuery += " 	AND SUP.A3_FUNCAO = '6' "+ CRLF // 6=Gerente
cQuery += " 	AND SUP.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND SUP.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z38")+" Z38 (NOLOCK) "+ CRLF
cQuery += " 	ON Z38.Z38_FILIAL = '"+xFilial("Z38")+"' "+ CRLF
cQuery += " 	AND Z38.Z38_PROPOS = Z02.Z02_PROPOS "+ CRLF
cQuery += " 	AND Z38.Z38_ADITIV = Z02.Z02_ADITIV "+ CRLF
cQuery += " 	AND Z38.Z38_CODCLI = Z02.Z02_CLIENT "+ CRLF
cQuery += " 	AND Z38.Z38_LOJCLI = Z02.Z02_LOJA "+ CRLF
cQuery += " 	AND Z38.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("Z37")+" Z37 (NOLOCK) "+ CRLF
cQuery += " 	ON Z37.Z37_FILIAL = '"+xFilial("Z37")+"' "+ CRLF
cQuery += " 	AND Z37.Z37_VEND = Z02.Z02_VEND2 "+ CRLF
cQuery += " 	AND Z37.Z37_ANO = Z38.Z38_ANO "+ CRLF
cQuery += " 	AND Z37.Z37_MES = Z38.Z38_MES "+ CRLF
cQuery += " 	AND Z37.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('MAN') "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += " AND SE1.E1_NUM = '000043162' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cChave := xFilial("Z39")
    cChave += "2" // 1=Proposta;2=Apontamento;3=Avulso
    cChave += (cTMP1)->Z02_VEND2
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO

    DbSelectArea("Z39")
    DbSetOrder(2) // Z39_FILIAL, Z39_TIPO, Z39_VEND, Z39_E1PREF, Z39_E1NUM, Z39_E1PARC, Z39_E1TIPO
    If !DbSeek(cChave)

        nValor   := (cTMP1)->E1_VALOR
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := IF((cTMP1)->Z02_RENOVA=="2", 1, (cTMP1)->A3_COMIS)
        nVlrCom  := nVlrLiq * (nPercCom / 100)
        
        aComissao[CPO_FILIAL] := xFilial("Z39")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "2" // 1=Proposta;2=Apontamento;3=Avulso
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

        // Comissão Gerente
        If !Empty((cTMP1)->A3_SUPER) .And. (cTMP1)->SUP_COMIS > 0 .And. (cTMP1)->Z02_RENOVA <> "2"
            
            nVlrCom  := nVlrLiq * ((cTMP1)->SUP_COMIS / 100)
        
            aComissao[CPO_VEND]   := (cTMP1)->A3_SUPER
            aComissao[CPO_COMISS] := (cTMP1)->SUP_COMIS
            aComissao[CPO_VLRCOM] := nVlrCom

            IncComis(aComissao)

        EndIf       
    EndIf

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

RestArea(aAreaZ39)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PropSrv2
Calcula comissoes por titulos de propostas de serviço pra GP e Arquiteto.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PropSrv2()

Local aAreaAtu  := GetArea()
Local aAreaZ39  := Z39->(GetArea())
Local aComissao := Array(CPO_STATUS)
Local cTMP1     := ""
Local cQuery    := ""
Local cChave    := ""

cQuery := " SELECT DISTINCT "+ CRLF
cQuery += " 	VND.A3_COD "+ CRLF
cQuery += " 	,VND.A3_NOME "+ CRLF
cQuery += " 	,Z02.Z02_PROPOS "+ CRLF
cQuery += " 	,Z02.Z02_ADITIV "+ CRLF
cQuery += " 	,SE1.E1_PREFIXO "+ CRLF
cQuery += " 	,SE1.E1_NUM "+ CRLF
cQuery += " 	,SE1.E1_PARCELA "+ CRLF
cQuery += " 	,SE1.E1_TIPO "+ CRLF
cQuery += " 	,SE1.E1_CLIENTE "+ CRLF
cQuery += " 	,SE1.E1_LOJA "+ CRLF
cQuery += " 	,SE1.E1_VALOR "+ CRLF
cQuery += " 	,(CASE WHEN Z02.Z02_IMPINC = '1' THEN Z02.Z02_IMPOST ELSE 1 END) AS Z02_IMPOST "+ CRLF
cQuery += " 	,SE1.E1_BAIXA "+ CRLF
cQuery += " 	,SE1.E1_HIST "+ CRLF
cQuery += " 	,VND.A3_COMIS "+ CRLF
cQuery += "     ,Z04.Z04_VALOR "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " 	ON Z02.Z02_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND Z02.Z02_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += " 	AND Z02.Z02_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z02.Z02_TIPO IN ('0','1','5','7') "+ CRLF // 0=TOTVS(MiniProposta);1=TOTVS(Srv);5=SAP(Srv);7=SAP(MiniProposta)
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_PARCEL = SE1.E1_PARCELA "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z04.Z04_MOD IN ('1') "+ CRLF // 1=Servicos
cQuery += "     AND Z04.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("Z08")+" Z08 (NOLOCK) "+ CRLF
cQuery += "     ON Z08.Z08_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += "     AND Z08.Z08_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z08.Z08_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z08.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" VND (NOLOCK) "+ CRLF
cQuery += " 	ON VND.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += " 	AND VND.A3_FORNECE = Z08.Z08_FORNEC "+ CRLF
cQuery += " 	AND VND.A3_LOJA = Z08.Z08_LOJA "+ CRLF
cQuery += " 	AND VND.A3_FUNCAO IN ('2','6') "+ CRLF // 2=GP/Arquiteto e 6=Gerente
cQuery += " 	AND VND.A3_MSBLQL = '2' "+ CRLF
cQuery += " 	AND VND.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_PREFIXO IN ('PRO') "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += " AND SE1.E1_NUM = '000043162' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())
    /*
    cChave := xFilial("Z39")
    cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
    cChave += (cTMP1)->A3_COD
    cChave += (cTMP1)->Z02_PROPOS
    cChave += (cTMP1)->Z02_ADITIV
    cChave += "1"

    DbSelectArea("Z39")
    DbSetOrder(3) // Z39_FILIAL, Z39_TIPO, Z39_VEND, Z39_PROPOS, Z39_ADITIV, Z39_MOD
    */
    cChave := xFilial("Z39")
    cChave += "1" // 1=Proposta;2=Apontamento;3=Avulso
    cChave += (cTMP1)->A3_COD
    cChave += (cTMP1)->E1_PREFIXO
    cChave += (cTMP1)->E1_NUM
    cChave += (cTMP1)->E1_PARCELA
    cChave += (cTMP1)->E1_TIPO

    DbSelectArea("Z39")
    DbSetOrder(2) // Z39_FILIAL+Z39_TIPO+Z39_VEND+Z39_E1PREF+Z39_E1NUM+Z39_E1PARC+Z39_E1TIPO    
    If !DbSeek(cChave)

        nValor   := (cTMP1)->Z04_VALOR
        nImposto := (cTMP1)->Z02_IMPOST
        nVlrLiq  := nValor * nImposto
        
        nPercCom := (cTMP1)->A3_COMIS
        nVlrCom  := nVlrLiq * (nPercCom / 100)
       
        aComissao[CPO_FILIAL] := xFilial("Z39")
        aComissao[CPO_NUMERO] := ""
        aComissao[CPO_TIPO]   := "1" // 1=Proposta;2=Apontamento;3=Avulso
        aComissao[CPO_DTGERA] := dDtGera
        aComissao[CPO_VEND]   := (cTMP1)->A3_COD
        aComissao[CPO_PROPOS] := (cTMP1)->Z02_PROPOS
    	aComissao[CPO_ADITIV] := (cTMP1)->Z02_ADITIV
        aComissao[CPO_CODCLI] := (cTMP1)->E1_CLIENTE
        aComissao[CPO_LOJCLI] := (cTMP1)->E1_LOJA
        aComissao[CPO_MOD]    := "1" // 1=Servicos
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

RestArea(aAreaZ39)
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
Local cMayZ39 	:= "Z39"+AllTrim(xFilial("Z39"))

Private lMsErroAuto := .F.

DEFAULT lMVC := .F.

If lMVC
    oModel := FwLoadModel("ALFPMS50")
    oModel:SetOperation(MODEL_OPERATION_INSERT)

    oModel:Activate()
    
    oModel:SetValue("Z39MASTER", "Z39_TIPO"  , aComissao[CPO_TIPO]   )
    oModel:SetValue("Z39MASTER", "Z39_PROPOS", aComissao[CPO_PROPOS] )
    oModel:SetValue("Z39MASTER", "Z39_ADITIV", aComissao[CPO_ADITIV] )
    oModel:SetValue("Z39MASTER", "Z39_CODCLI", aComissao[CPO_CODCLI] )
    oModel:SetValue("Z39MASTER", "Z39_LOJCLI", aComissao[CPO_LOJCLI] )
    oModel:SetValue("Z39MASTER", "Z39_VEND"  , aComissao[CPO_VEND]   )
    oModel:SetValue("Z39MASTER", "Z39_E1PREF", aComissao[CPO_E1PREF] )
    oModel:SetValue("Z39MASTER", "Z39_E1NUM" , aComissao[CPO_E1NUM]  )
    oModel:SetValue("Z39MASTER", "Z39_E1PARC", aComissao[CPO_E1PARC] )
    oModel:SetValue("Z39MASTER", "Z39_E1TIPO", aComissao[CPO_E1TIPO] )
    oModel:SetValue("Z39MASTER", "Z39_E1BAIX", aComissao[CPO_E1BAIX] )
    oModel:SetValue("Z39MASTER", "Z39_E1HIST", AllTrim(aComissao[CPO_E1HIST]) )
    oModel:SetValue("Z39MASTER", "Z39_VLRBRU", aComissao[CPO_VLRBRU] )
    oModel:SetValue("Z39MASTER", "Z39_IMPOST", aComissao[CPO_IMPOST] )
    oModel:SetValue("Z39MASTER", "Z39_VLRLIQ", aComissao[CPO_VLRLIQ] )
    oModel:SetValue("Z39MASTER", "Z39_COMISS", aComissao[CPO_COMISS] )
    oModel:SetValue("Z39MASTER", "Z39_VLRCOM", aComissao[CPO_VLRCOM] )
    oModel:SetValue("Z39MASTER", "Z39_STATUS", aComissao[CPO_STATUS] )

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
    cNumCom := GetSxeNum("Z39","Z39_NUMERO",1)
    DbSelectArea("Z39")
    DbSetOrder(1) // Z39_FILIAL+Z39_NUMERO
    While DbSeek(xFilial("Z39")+cNumCom) .OR. !MayIUseCode(cMayZ39+cNumCom)
        cNumCom := GetSxeNum("Z39","Z39_NUMERO",1)
    EndDo

    RecLock("Z39",.T.)
        REPLACE Z39_FILIAL WITH aComissao[CPO_FILIAL]
        REPLACE Z39_NUMERO WITH cNumCom
        REPLACE Z39_TIPO   WITH aComissao[CPO_TIPO]
        REPLACE Z39_DTGERA WITH aComissao[CPO_DTGERA]
        REPLACE Z39_VEND   WITH aComissao[CPO_VEND]
        REPLACE Z39_PROPOS WITH aComissao[CPO_PROPOS]
        REPLACE Z39_ADITIV WITH aComissao[CPO_ADITIV]
        REPLACE Z39_CODCLI WITH aComissao[CPO_CODCLI]
        REPLACE Z39_LOJCLI WITH aComissao[CPO_LOJCLI]
        REPLACE Z39_MOD    WITH aComissao[CPO_MOD]
        REPLACE Z39_E1PREF WITH aComissao[CPO_E1PREF]
        REPLACE Z39_E1NUM  WITH aComissao[CPO_E1NUM]
        REPLACE Z39_E1PARC WITH aComissao[CPO_E1PARC]
        REPLACE Z39_E1TIPO WITH aComissao[CPO_E1TIPO]
        REPLACE Z39_E1BAIX WITH aComissao[CPO_E1BAIX]
        REPLACE Z39_E1HIST WITH aComissao[CPO_E1HIST]
        REPLACE Z39_VLRBRU WITH aComissao[CPO_VLRBRU]
        REPLACE Z39_IMPOST WITH aComissao[CPO_IMPOST]
        REPLACE Z39_VLRLIQ WITH aComissao[CPO_VLRLIQ]
        REPLACE Z39_COMISS WITH aComissao[CPO_COMISS]
        REPLACE Z39_VLRCOM WITH aComissao[CPO_VLRCOM]
        REPLACE Z39_STATUS WITH aComissao[CPO_STATUS]
    MsUnlock()

    EvalTrigger()

    While GetSX8Len() > nSaveSX8
        ConfirmSX8()
    EndDo
    
    // Libera numeros reservados (MayIUseCode)
    FreeUsedCode()
EndIf

Return .T.
