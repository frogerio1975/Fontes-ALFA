#INCLUDE "PROTHEUS.CH"

/*
Z00 - Produtos
Z02 - Proposta
Z03 - Itens da Proposta
Z04 - Parcelas da Proposta
Z05 - Resumo da Proposta / Produtos contidos na Proposta
Z08 - Comissões de Venda na Proposta

Z02_STATUS:
1=Leads Qualificado;
2=Desqualificado;
3=Em Negociacao;
5=Aprovados;
6=Suspensos;
7=Perdidos;
9=Projeto Gerado;
C=Cancelado

Tipo de Venda (Z02_TIPO):
0 - TOTVS (MiniProposta)
1 - TOTVS (Servicos) Implantação ou Desenvolvimento
2 - TOTVS (SD) Service Desk
3 - SAP (Cloud)
4 - SAP (OnPremise)
5 - SAP (Servicos) Implantação ou Desenvolvimento
6 - SAP (SD) Service Desk
7 - SAP (MiniProposta)

M->Z02_TIPO $ '2/6'	    // Service Desk
M->Z02_TIPO $ '3/4/8' 	// Licencas
M->Z02_TIPO $ '0/1/5/7' // Servicos

Quando Serviço (Z00_TPSERV):
1=Consultoria
2=Desenvolvimento

Z00_TIPO:
1=TOTVS-Servicos;
2=TOTVS-Service Desk;
3=SAP-Cloud;
4=SAP-OnPremise;
5=SAP-Servicos;
6=SAP-Service Desk;
7=MiniProposta   

Tipo de Produto (Z00_TPPROD):
0=Hosted By SAP;
1=SaaS;
2=OnPremise;
3=Ambos;
4=SAP(Servicos);
5=TOTVS(Servicos)


M->Z02_TIPO == "3" 	//SAP Cloud
cFiltroZ00:= "Z00->Z00_TPPROD $ '013'"

M->Z02_TIPO == "4" //SAP OnPremise
cFiltroZ00:= "Z00->Z00_TPPROD $ '23'"

Z00_PRODUT = 1=TOTVS;2=SAP;3=POWER BI
Z00_MOD    = 1=Saas;2=On Premise;3=Adesao/Setup/Servico
Z00_TPMOD  = 1=Modulo;2=Escopo de Projeto;3=Licenca
Z00_TPSERV = 1=Consultoria;2=Desenvolvimento
Z00_TPPROD = 0=Hosted By SAP;1=SaaS;2=OnPremise;3=Ambos;4=SAP(Servicos);5=TOTVS(Servicos)
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS40
Rotina para rateio financeiro dos títulos gerados por proposta.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS40()

Local aBoxParam	:= {}
Local aRetParam	:= {}
Local lRetorno 	:= .T.
Local cPropIni  := CriaVar("Z02_PROPOS",.F.)
Local cAditivIni:= CriaVar("Z02_ADITIV",.F.)
Local cPropFim  := CriaVar("Z02_PROPOS",.F.)
Local cAditivFim:= CriaVar("Z02_ADITIV",.F.)
Local dDataIni  := CriaVar("Z02_DATAOP",.F.)
Local dDataFim  := CriaVar("Z02_DATAOP",.F.)
Local cMsgErro  := ""

AADD( aBoxParam, {1,"Proposta DE"     , cPropIni  , "@!", "","Z02","",50,.F.} )
AADD( aBoxParam, {1,"Aditivo DE"      , cAditivIni, "@!", "","","",50,.F.} )
AADD( aBoxParam, {1,"Proposta ATE"    , cPropFim  , "@!", "","Z02","",50,.F.} )
AADD( aBoxParam, {1,"Aditivo ATE"     , cAditivFim, "@!", "","","",50,.F.} )
AADD( aBoxParam, {1,"Data DE"         , dDataIni  , "@!", "",""   ,"",50,.F.} )
AADD( aBoxParam, {1,"Data ATE"        , dDataFim  , "@!", "",""   ,"",50,.F.} )

If ParamBox(aBoxParam,"Rateio Por Propostas",@aRetParam,,,,,,,,.F.)

    cPropIni  := aRetParam[1]
    cAditivIni:= aRetParam[2]
    cPropFim  := aRetParam[3]
    cAditivFim:= aRetParam[4]
    dDataIni  := aRetParam[5]
    dDataFim  := aRetParam[6]

    FwMsgRun( ,{|| lRetorno := ProcRat(cPropIni, cAditivIni,cPropFim, cAditivFim, dDataIni, dDataFim, @cMsgErro) }, , "Por favor, aguarde. Realizando o rateio..." )

    If lRetorno
        Help(Nil,Nil,ProcName(),,"Rateio concluido com sucesso.", 1, 5)
    Else
        Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS40
Rotina para rateio financeiro dos títulos gerados por proposta.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcRat(cPropIni, cAditivIni, cPropFim, cAditivFim, dDataIni, dDataFim, cMsgErro)

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT "+ CRLF
cQuery += "     Z02.R_E_C_N_O_ AS RECZ02 "+ CRLF
cQuery += " FROM "+RetSqlName("Z02")+" Z02 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	Z02.Z02_FILIAL = '"+xFilial("Z02")+"' "+ CRLF
If !Empty(cPropIni) .OR. !Empty(cPropFim)
    cQuery += " 	AND Z02.Z02_PROPOS BETWEEN '"+cPropIni+"' AND '"+cPropFim+"' "+ CRLF
    cQuery += " 	AND Z02.Z02_ADITIV BETWEEN '"+cAditivIni+"' AND '"+cAditivFim+"' "+ CRLF
EndIf
If !Empty(dDataIni) .OR. !Empty(dDataFim)
    cQuery += " 	AND Z02.Z02_DATAOP BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"' "+ CRLF
EndIf
cQuery += " 	AND Z02.Z02_STATUS IN ('5','9') "+ CRLF // Aprovados e Projeto Gerado
cQuery += " 	AND Z02.Z02_TPFAT = '1' "+ CRLF // Cobrança por Parcelas Fixa
cQuery += " 	AND Z02.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += "     Z02.Z02_PROPOS ,"+ CRLF
cQuery += "     Z02.Z02_ADITIV  "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    Z02->(dbSetOrder(1))
    Z02->(dbGoTo((cTMP1)->RECZ02))

    BEGIN TRANSACTION

        DO CASE
            CASE Z02->Z02_TIPO $ "2|6" // Service Desk
                CalcRatSD()
            CASE Z02->Z02_TIPO $ "3|4" // Licencas
                CalcRatLic()
            CASE Z02->Z02_TIPO $ "0|1|5|7" // Servicos
                CalcRatSrv()
        ENDCASE

    END TRANSACTION

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcRatSD
Rateio de Propostas do Tipo Service Desk.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcRatSD()

Local cTMP1   := ""
Local cQuery  := ""
Local cCodNat := ""
Local cCodCC  := ""
Local aRateio := {}

cCodNat := "0100104" // FATURAMENTO SUSTENTACAO

If Z02->Z02_TIPO == "2" // TOTVS
    cCodCC := "10203" // SUSTENTACAO TOVS
ElseIf Z02->Z02_TIPO == "6" // SAP
    cCodCC := "10103" // SUSTENTACAO SAP
EndIf

cQuery := " SELECT "+ CRLF
cQuery += "     SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SE1.E1_PREFIXO = 'PRO' "+ CRLF
cQuery += " 	AND SE1.E1_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND SE1.E1_ADITIV = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += "     SE1.E1_NUM "+ CRLF
cQuery += "     ,SE1.E1_PARCELA "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    SE1->(dbSetOrder(1))
    SE1->(dbGoTo((cTMP1)->RECSE1))

    aRateio := {}

    AADD( aRateio, Array(4) )
    
    aRateio[1][1] := cCodNat
    aRateio[1][2] := SE1->E1_VALOR
    aRateio[1][3] := 1
    aRateio[1][4] := {}

    aRatCC := Array(3)

    aRatCC[1] := cCodCC
    aRatCC[2] := SE1->E1_VALOR
    aRatCC[3] := 1

    AADD( aRateio[1][4], aRatCC )

    // Deleta rateio existente.
    DelRat()

    // Grava rateio
    GrvRat(aRateio)
    
    // Atualiza Natureza e Centro de Custo no Titulo
    //AtuaSE1(aRateio)

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcRatLic
Rateio de Propostas do Tipo Licenca.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcRatLic()

Local cTMP1    := ""
Local cQuery   := ""
Local cCodNat  := ""
Local cCodCC   := ""
Local aRateio  := {}
Local nPercSAP := 0
Local nPercADO := 0
Local nPercSD  := 0
Local nPercFAB := 0

cSapFor   := "FOPAJZ" // Códigos de Fornecedor da SAP
cAlfaFor  := "000100','FOPAOA" // Códigos de Fornecedor da ALFA (Produtos Proprio)
cCloudFor := "FOPAPV','FOPB2D','FOPB29" // Códigos de Fornecedor Cloud

cNatSAP := "0100101" // FATURAMENTO LICENCAS DE USO SAP
cNatADO := "0100102" // FATURAMENTO ADD-ONS
cNatSD  := "0100104" // FATURAMENTO SUSTENTACAO
cNatClo := "0100109" // FATURAMENTO CLOUD
cNatFab := "0100110" // FATURAMENTO LICENCAS FABRICA

cCCMAT := "10101" // MANUTENCAO SAP - ADD-NOS - CLOUD
cCCSD  := "10103" // SUSTENTACAO SAP
cCCFAB := "10302" // MANUTENCAO APLICACOES PROPRIAS 
                                         
/*
01.001.01	FATURAMENTO LICENCAS DE USO SAP
                - MANUTENCAO SAP - ADD-NOS - CLOUD	1.01.01

01.001.02	FATURAMENTO ADD-ONS
                - MANUTENCAO SAP - ADD-NOS - CLOUD	1.01.01

01.001.04	FATURAMENTO SUSTENTACAO
                - SUSTENTACAO SAP	1.01.03

01.001.09	FATURAMENTO CLOUD
                - MANUTENCAO SAP - ADD-NOS - CLOUD	1.01.01

01.001.10	FATURAMENTO LICENÇAS FABRICA
                - MANUTENCAO APLICACOES PROPRIAS	1.03.02
*/

cQuery := " SELECT "+ CRLF
cQuery += " 	SUM(CASE WHEN Z00_TIPO IN ('3','4') AND Z00_FORNEC IN ('"+cSapFor+"') THEN Z05.Z05_VLRMES ELSE 0 END) AS VALOR_SAP "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_TIPO IN ('3','4') AND Z00_FORNEC IN ('"+cAlfaFor+"') THEN Z05.Z05_VLRMES ELSE 0 END) AS VALOR_ALFA "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_TIPO IN ('3','4') AND Z00_FORNEC IN ('"+cCloudFor+"') THEN Z05.Z05_VLRMES ELSE 0 END) AS VALOR_CLOUD "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_TIPO IN ('3','4') AND Z00_FORNEC NOT IN ('"+cSapFor+"','"+cAlfaFor+"','"+cCloudFor+"') THEN Z05.Z05_VLRMES ELSE 0 END) AS VALOR_ADDON "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_TIPO IN ('6') THEN Z05.Z05_VLRMES ELSE 0 END) AS VALOR_SD "+ CRLF
cQuery += " 	,SUM(Z05.Z05_VLRMES) VALOR_TOTAL "+ CRLF
cQuery += " FROM "+RetSqlName("Z05")+" Z05 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("Z00")+" Z00 (NOLOCK) "+ CRLF
cQuery += " 	ON Z00.Z00_FILIAL = '"+xFilial("Z00")+"' "+ CRLF
cQuery += " 	AND Z00.Z00_MODULO = Z05.Z05_MODULO "+ CRLF
cQuery += " 	AND Z00.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	Z05.Z05_FILIAL = '"+xFilial("Z05")+"' "+ CRLF
cQuery += " 	AND Z05.Z05_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND Z05.Z05_ADITIV = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND Z05.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF()) .And. (cTMP1)->VALOR_TOTAL > 0

    nPercSAP := (cTMP1)->VALOR_SAP / (cTMP1)->VALOR_TOTAL

    nPercADO := (cTMP1)->VALOR_ADDON / (cTMP1)->VALOR_TOTAL

    nPercSD := (cTMP1)->VALOR_SD / (cTMP1)->VALOR_TOTAL
    
    nPercClo := (cTMP1)->VALOR_CLOUD / (cTMP1)->VALOR_TOTAL
    
    nPercFab := (cTMP1)->VALOR_ALFA / (cTMP1)->VALOR_TOTAL

    (cTMP1)->(dbSkip())
EndIf

(cTMP1)->(dbCloseArea())

cQuery := " SELECT "+ CRLF
cQuery += "     SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = '"+xFilial("Z04")+"' "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += "     AND Z04.Z04_MOD = '4' "+ CRLF
cQuery += " 	AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SE1.E1_PREFIXO = 'PRO' "+ CRLF
cQuery += " 	AND SE1.E1_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND SE1.E1_ADITIV = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += "     SE1.E1_NUM "+ CRLF
cQuery += "     ,SE1.E1_PARCELA "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    SE1->(dbSetOrder(1))
    SE1->(dbGoTo((cTMP1)->RECSE1))

    aRateio := {}

    If nPercSAP > 0
        AADD( aRateio, Array(4) )
        nPos := Len(aRateio)
        
        aRateio[nPos][1] := cNatSAP
        aRateio[nPos][2] := ROUND(SE1->E1_VALOR * nPercSAP, TamSX3("E1_VALOR")[2])
        aRateio[nPos][3] := nPercSAP
        aRateio[nPos][4] := {}

        aRatCC := Array(3)

        aRatCC[1] := cCCMAT
        aRatCC[2] := aRateio[nPos][2]
        aRatCC[3] := 1

        AADD( aRateio[nPos][4], aRatCC )
    EndIf

    If nPercADO > 0
        AADD( aRateio, Array(4) )
        nPos := Len(aRateio)
        
        aRateio[nPos][1] := cNatADO
        aRateio[nPos][2] := ROUND(SE1->E1_VALOR * nPercADO, TamSX3("E1_VALOR")[2])
        aRateio[nPos][3] := nPercADO
        aRateio[nPos][4] := {}

        aRatCC := Array(3)

        aRatCC[1] := cCCMAT
        aRatCC[2] := aRateio[nPos][2]
        aRatCC[3] := 1

        AADD( aRateio[nPos][4], aRatCC )
    EndIf

    If nPercSD > 0
        AADD( aRateio, Array(4) )
        nPos := Len(aRateio)
        
        aRateio[nPos][1] := cNatSD
        aRateio[nPos][2] := ROUND(SE1->E1_VALOR * nPercSD, TamSX3("E1_VALOR")[2])
        aRateio[nPos][3] := nPercSD
        aRateio[nPos][4] := {}

        aRatCC := Array(3)

        aRatCC[1] := cCCSD
        aRatCC[2] := aRateio[nPos][2]
        aRatCC[3] := 1

        AADD( aRateio[nPos][4], aRatCC )
    EndIf

    If nPercClo > 0
        AADD( aRateio, Array(4) )
        nPos := Len(aRateio)
        
        aRateio[nPos][1] := cNatClo
        aRateio[nPos][2] := ROUND(SE1->E1_VALOR * nPercClo, TamSX3("E1_VALOR")[2])
        aRateio[nPos][3] := nPercClo
        aRateio[nPos][4] := {}

        aRatCC := Array(3)

        aRatCC[1] := cCCMAT
        aRatCC[2] := aRateio[nPos][2]
        aRatCC[3] := 1

        AADD( aRateio[nPos][4], aRatCC )
    EndIf

    If nPercFab > 0
        AADD( aRateio, Array(4) )
        nPos := Len(aRateio)
        
        aRateio[nPos][1] := cNatFab
        aRateio[nPos][2] := ROUND(SE1->E1_VALOR * nPercFab, TamSX3("E1_VALOR")[2])
        aRateio[nPos][3] := nPercFab
        aRateio[nPos][4] := {}

        aRatCC := Array(3)

        aRatCC[1] := cCCFAB
        aRatCC[2] := aRateio[nPos][2]
        aRatCC[3] := 1

        AADD( aRateio[nPos][4], aRatCC )
    EndIf

    // Deleta rateio existente.
    DelRat()

    // Grava rateio
    GrvRat(aRateio)
    
    // Atualiza Natureza e Centro de Custo no Titulo
    //AtuaSE1(aRateio)

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


cQuery := " SELECT DISTINCT "+ CRLF
cQuery += "     SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = '"+xFilial("Z04")+"' "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += "     AND Z04.Z04_MOD = '3' "+ CRLF
cQuery += " 	AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SE1.E1_PREFIXO = 'PRO' "+ CRLF
cQuery += " 	AND SE1.E1_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND SE1.E1_ADITIV = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    SE1->(dbSetOrder(1))
    SE1->(dbGoTo((cTMP1)->RECSE1))

    aRateio := {}

    AADD( aRateio, Array(4) )
    nPos := Len(aRateio)
    
    aRateio[nPos][1] := cNatClo
    aRateio[nPos][2] := SE1->E1_VALOR
    aRateio[nPos][3] := 1
    aRateio[nPos][4] := {}

    aRatCC := Array(3)

    aRatCC[1] := cCCMAT
    aRatCC[2] := aRateio[nPos][2]
    aRatCC[3] := 1

    AADD( aRateio[nPos][4], aRatCC )

    // Deleta rateio existente.
    DelRat()

    // Grava rateio
    GrvRat(aRateio)
    
    // Atualiza Natureza e Centro de Custo no Titulo
    //AtuaSE1(aRateio)

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcRatSrv
Rateio de Propostas do Tipo Serviço.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcRatSrv()

Local cTMP1    := ""
Local cQuery   := ""
Local cCodNat  := ""
Local cCodCC   := ""
Local aRateio  := {}
Local nPercTOT := 0
Local nPercSAP := 0
Local nPercFAB := 0
Local nPercBI  := 0

cNatPrj := "0100103" // FATURAMENTO PROJETOS

cCCTotvs := "10202" // PROJETOS TOTVS
cCCSap   := "10102" // PROJETOS SAP
cCCFabri := "10301" // PROJETOS FABRICA
cCCBI    := "10401" // PROJETOS BI

/*
Z00_PRODUT = 1=TOTVS;2=SAP;3=POWER BI
Z00_TPSERV = 1=Consultoria;2=Desenvolvimento
*/
cQuery := " SELECT "+ CRLF
cQuery += " 	SUM(CASE WHEN Z00_PRODUT = '1' AND Z00_TPSERV = '1' THEN Z05_TOTAL ELSE 0 END) AS VALOR_TOTVS "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_PRODUT = '2' AND Z00_TPSERV = '1' THEN Z05_TOTAL ELSE 0 END) AS VALOR_SAP "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_PRODUT IN ('1','2') AND Z00_TPSERV = '2' THEN Z05_TOTAL ELSE 0 END) AS VALOR_FABRICA "+ CRLF
cQuery += " 	,SUM(CASE WHEN Z00_PRODUT = '3' THEN Z05_TOTAL ELSE 0 END) AS VALOR_BI "+ CRLF
cQuery += " 	,SUM(Z05_TOTAL) AS VALOR_TOTAL "+ CRLF
cQuery += " FROM "+RetSqlName("Z05")+" Z05 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("Z00")+" Z00 (NOLOCK) "+ CRLF
cQuery += " 	ON Z00.Z00_FILIAL = '"+xFilial("Z00")+"' "+ CRLF
cQuery += " 	AND Z00.Z00_MODULO = Z05.Z05_MODULO "+ CRLF
cQuery += " 	AND Z00.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	Z05.Z05_FILIAL = '"+xFilial("Z05")+"' "+ CRLF
cQuery += " 	AND Z05.Z05_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND Z05.Z05_ADITIV = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND Z05.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF()) .And. (cTMP1)->VALOR_TOTAL > 0

    nPercTOT := (cTMP1)->VALOR_TOTVS / (cTMP1)->VALOR_TOTAL
    nPercSAP := (cTMP1)->VALOR_SAP / (cTMP1)->VALOR_TOTAL
    nPercFAB := (cTMP1)->VALOR_FABRICA / (cTMP1)->VALOR_TOTAL
    nPercBI  := (cTMP1)->VALOR_BI / (cTMP1)->VALOR_TOTAL

    (cTMP1)->(dbSkip())
EndIf

(cTMP1)->(dbCloseArea())

cQuery := " SELECT "+ CRLF
cQuery += "     SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("Z04")+" Z04 (NOLOCK) "+ CRLF
cQuery += "     ON Z04.Z04_FILIAL = '"+xFilial("Z04")+"' "+ CRLF
cQuery += "     AND Z04.Z04_PROPOS = SE1.E1_PROPOS "+ CRLF
cQuery += "     AND Z04.Z04_ADITIV = SE1.E1_ADITIV "+ CRLF
cQuery += "     AND Z04.Z04_PREFIX = SE1.E1_PREFIXO "+ CRLF
cQuery += "     AND Z04.Z04_NUM = SE1.E1_NUM "+ CRLF
cQuery += "     AND Z04.Z04_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += " 	AND Z04.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SE1.E1_PREFIXO = 'PRO' "+ CRLF
cQuery += " 	AND SE1.E1_PROPOS = '"+Z02->Z02_PROPOS+"' "+ CRLF
cQuery += " 	AND SE1.E1_PROPOS = '"+Z02->Z02_ADITIV+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += "     SE1.E1_NUM "+ CRLF
cQuery += "     ,SE1.E1_PARCELA "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    SE1->(dbSetOrder(1))
    SE1->(dbGoTo((cTMP1)->RECSE1))

    aRateio := {}

    AADD( aRateio, Array(4) )
    
    aRateio[1][1] := cNatPrj
    aRateio[1][2] := SE1->E1_VALOR
    aRateio[1][3] := 1
    aRateio[1][4] := {}

    If nPercTOT > 0
        aRatCC := Array(3)

        aRatCC[1] := cCCTotvs
        aRatCC[2] := ROUND(aRateio[1][2] * nPercTOT, TamSX3("EZ_VALOR")[2])
        aRatCC[3] := nPercTOT

        AADD( aRateio[1][4], aRatCC )
    EndIf

    If nPercSAP > 0
        aRatCC := Array(3)

        aRatCC[1] := cCCSap
        aRatCC[2] := ROUND(aRateio[1][2] * nPercSAP, TamSX3("EZ_VALOR")[2])
        aRatCC[3] := nPercSAP

        AADD( aRateio[1][4], aRatCC )
    EndIf

    If nPercFAB > 0
        aRatCC := Array(3)

        aRatCC[1] := cCCFabri
        aRatCC[2] := ROUND(aRateio[1][2] * nPercFAB, TamSX3("EZ_VALOR")[2])
        aRatCC[3] := nPercFAB

        AADD( aRateio[1][4], aRatCC )
    EndIf

    If nPercBI > 0
        aRatCC := Array(3)

        aRatCC[1] := cCCBI
        aRatCC[2] := ROUND(aRateio[1][2] * nPercBI, TamSX3("EZ_VALOR")[2])
        aRatCC[3] := nPercBI

        AADD( aRateio[1][4], aRatCC )
    EndIf

    // Deleta rateio existente.
    DelRat()

    // Grava rateio
    GrvRat(aRateio)
    
    // Atualiza Natureza e Centro de Custo no Titulo
    //AtuaSE1(aRateio)

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} DelRat
Deleta rateio existente.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelRat()

Local aAreaAtu := GetArea()
Local cChave   := ""

cChave := SE1->E1_PREFIXO
cChave += SE1->E1_NUM
cChave += SE1->E1_PARCELA
cChave += SE1->E1_TIPO
cChave += SE1->E1_CLIENTE
cChave += SE1->E1_LOJA

dbSelectArea("SEV")
dbSetOrder(1) // EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ
If dbSeek(xFilial("SEV")+cChave)
    While SEV->(!EOF()) .And. SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) == xFilial("SEV")+cChave

        RecLock("SEV",.F.)
            dbDelete()
        MsUnlock()

        SEV->(dbSkip())
    EndDo
EndIf

dbSelectArea("SEZ")
dbSetOrder(1) // EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_CCUSTO
If dbSeek(xFilial("SEZ")+cChave)
    While SEZ->(!EOF()) .And. SEZ->(EZ_FILIAL+EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA) == xFilial("SEZ")+cChave

        RecLock("SEZ",.F.)
            dbDelete()
        MsUnlock()

        SEZ->(dbSkip())
    EndDo
EndIf

RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRat
Grava rateio do título.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrvRat(aRateio)

Local aAreaAtu := GetArea()
Local cCodNat  := ""
Local nVlrNat  := 0
Local nPercNat := 0
Local aRatCC   := {}
Local cCodCC   := ""
Local nVlrCC   := 0
Local nPercCC  := 0
Local nX       := 0
Local nY       := 0

DEFAULT aRateio := {}

For nX := 1 to Len(aRateio)
    
    cCodNat  := aRateio[nX][1]
    nVlrNat  := aRateio[nX][2]
    nPercNat := aRateio[nX][3]
    aRatCC   := aRateio[nX][4]

    RecLock("SEV",.T.)
        REPLACE EV_FILIAL   WITH xFilial("SEV")
        REPLACE EV_PREFIXO  WITH SE1->E1_PREFIXO
        REPLACE EV_NUM      WITH SE1->E1_NUM
        REPLACE EV_PARCELA  WITH SE1->E1_PARCELA
        REPLACE EV_TIPO     WITH SE1->E1_TIPO
        REPLACE EV_CLIFOR   WITH SE1->E1_CLIENTE
        REPLACE EV_LOJA     WITH SE1->E1_LOJA
        REPLACE EV_NATUREZ  WITH cCodNat
        REPLACE EV_VALOR    WITH nVlrNat
        REPLACE EV_PERC     WITH nPercNat
        REPLACE EV_RATEICC  WITH "1"
        REPLACE EV_RECPAG   WITH "R"
        REPLACE EV_IDENT    WITH "1"
    MsUnlock()

    For nY := 1 to Len(aRatCC)
    
        cCodCC  := aRatCC[nY][1]
        nVlrCC  := aRatCC[nY][2]
        nPercCC := aRatCC[nY][3]

        RecLock("SEZ",.T.)
            REPLACE EZ_FILIAL   WITH xFilial("SEZ")
            REPLACE EZ_PREFIXO  WITH SE1->E1_PREFIXO
            REPLACE EZ_NUM      WITH SE1->E1_NUM
            REPLACE EZ_PARCELA  WITH SE1->E1_PARCELA
            REPLACE EZ_TIPO     WITH SE1->E1_TIPO
            REPLACE EZ_CLIFOR   WITH SE1->E1_CLIENTE
            REPLACE EZ_LOJA     WITH SE1->E1_LOJA
            REPLACE EZ_NATUREZ  WITH cCodNat
            REPLACE EZ_CCUSTO   WITH cCodCC
            REPLACE EZ_VALOR    WITH nVlrCC
            REPLACE EZ_PERC     WITH nPercCC
            REPLACE EZ_RECPAG   WITH "R"
            REPLACE EZ_IDENT    WITH "1"
        MsUnlock()

    Next nY
Next nX

RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PMS40RAT
Chamada para rateio da proposta.

@author  Wilson A. Silva Jr
@since   12/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS40RAT(cProposta,cAditivo)

Local lRetorno 	:= .T.
Local cMsgErro  := ""

lRetorno := ProcRat(cProposta, cAditivo, cProposta, cAditivo,Nil, Nil, @cMsgErro)

Return lRetorno
