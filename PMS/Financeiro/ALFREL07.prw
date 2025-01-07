#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"
//------------------------------------------------------------------- 
/*/{Protheus.doc} ALFREL07

Relatorio de rateio centro de custo

@author		Pedro H. Oliveira 
@since 		24/07/2020
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ALFREL07( )

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Contas a Pagar - Rateio Por empresa"
Local cNome 	:= "RateioPagar-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de contas a pagar."
Local cExt 		:= "XLS"
Local nOpc 		:= 1 // 1 = gerar arquivo e abrir / 2 = somente gerar aquivo em disco
Local cMsgProc 	:= "Aguarde... gerando relatório..."

U_XMLPerg(	Nil,;
			cDir,;
			{|lEnd, cArquivo| GeraExl(cArquivo)},;
			cTitulo,;
			cNome,;
			cDesc,;
			cExt,;
			nOpc,;
			cMsgProc )

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraExl
Cria Arquivo XLS (Excel) Com base nos dados enviados.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraExl(cArquivo)

Local aBoxParam	:= {}
Local aRetParam	:= {}
Local lRetorno 	:= .T.
Local oXML

Private nFolder  := 1 // Pasta onde o relatorio sera gerado

// Parametros
Private aEmpFat  := { "1=ALFA(07)", "2=Moove", "3=GNP", "4=ALFA(24)","5=Campinas","6=Colaboração" }
Private cEmpFat  := "1"
Private cPrefixo := CriaVar("E2_PREFIXO",.F.)
Private cTipoE1  := "DP"
Private cNumIni  := CriaVar("E2_NUM",.F.)
Private cNumFim  := CriaVar("E2_NUM",.F.)
Private dEmisIni := CriaVar("E2_EMISSAO",.F.)
Private dEmisFim := CriaVar("E2_EMISSAO",.F.)
Private dVencIni := CriaVar("E2_VENCREA",.F.)
Private dVencFim := CriaVar("E2_VENCREA",.F.)
Private dBaixIni := CriaVar("E2_BAIXA",.F.)
Private dBaixFim := CriaVar("E2_BAIXA",.F.)
Private cForIni  := CriaVar("E2_FORNECE",.F.)
Private cForFim  := CriaVar("E2_FORNECE",.F.)
Private cNfsIni  := CriaVar("E2_NUMNOTA",.F.)
Private cNfsFim  := CriaVar("E2_NUMNOTA",.F.)
Private dNfsIni  := CriaVar("E2_EMISSAO",.F.)
Private dNfsFim  := CriaVar("E2_EMISSAO",.F.)

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Prefixo"         , cPrefixo  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Tipo"            , cTipoE1   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero DE"       , cNumIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero ATE"      , cNumFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Emissão DE"      , dEmisIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Emissão ATE"     , dEmisFim  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Vencto. DE"      , dVencIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Vencto. ATE"     , dVencFim  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Pagto DE"        , dBaixIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Pagto ATE"       , dBaixFim  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Fornecedor DE"   , cForIni   , "@!", "", "SA2", "", 50, .F.} )
AADD( aBoxParam, {1,"Fornecedor ATE"  , cForFim   , "@!", "", "SA2", "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS DE"      , cNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS ATE"     , cNfsFim   , "@!", "", ""   , "", 50, .F.} )
// AADD( aBoxParam, {1,"Dt.NFS DE"       , dNfsIni   , "@!", "", ""   , "", 50, .F.} )
// AADD( aBoxParam, {1,"Dt.NFS ATE"      , dNfsFim   , "@!", "", ""   , "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Contas a Pagar",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cPrefixo := aRetParam[2]
    cTipoE1  := aRetParam[3]
    cNumIni  := aRetParam[4]
    cNumFim  := aRetParam[5]
    dEmisIni := aRetParam[6]
    dEmisFim := aRetParam[7]
    dVencIni := aRetParam[8]
    dVencFim := aRetParam[9]
    dBaixIni := aRetParam[10]
    dBaixFim := aRetParam[11]
    cForIni  := aRetParam[12]
    cForFim  := aRetParam[13]
    cNfsIni  := aRetParam[14]
    cNfsFim  := aRetParam[15]
    // dNfsIni  := aRetParam[16]
    // dNfsFim  := aRetParam[17]

    // If lRetorno .and. Empty(cContrato)
    //     Help(Nil,Nil,ProcName(),,"Por favor, necessário informar o número de contrato.", 1, 5)
    //     lRetorno := .F.
    // EndIf

    If lRetorno
        oXML := ExcelXML():New()
        FwMsgRun( ,{|oMsg| oXML := GeraRelatorio(oMsg,oXML) 	},, "Aguarde. Gerando relatório..." )
        FwMsgRun( ,{|oMsg| oXML	:= GeraFiltro(oMsg,oXML) 	},, "Aguarde. Gerando aba indicações de filtros..." )
            
        If oXML <> NIL
            oXml:setFolder(2)
            lRetorno := oXML:GetXML(cArquivo)
        EndIf
    EndIf

EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraFiltro
Cria aba descrevendo filtros no relatorio.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraFiltro(oMsg,oXml)

Local oStlTitFil
Local oStlTitPar
Local oStlPar
Local aStl

oXml:setFolder(nFolder)
nFolder++
oXml:setFolderName("Parametros")
oXml:showGridLine(.F.)

oStlTitFil := CellStyle():New("StlTitFil")
oStlTitFil:setFont("Calibri", 10, "#003366", .T., .F., .F., .F.)
oStlTitFil:setBorder("TOP", , 3, .T.)
oStlTitFil:setBorder("BOTTOM", , 2, .T.)
oStlTitFil:setBorder("LEFT", , 3, .T.)
oStlTitFil:setBorder("RIGHT", , 3, .T.)

oStlTitPar := CellStyle():New("StlTitPar")
oStlTitPar:setFont("Calibri", 10, "#003366", .T., .F., .F., .F.)
oStlTitPar:setBorder("BOTTOM", , 1, .T.)
oStlTitPar:setBorder("LEFT", , 3, .T.)
oStlTitPar:setHAlign("LEFT")

oStlPar := CellStyle():New("StlPar")
oStlPar:setFont("Calibri", 10, "#003366", .F., .F., .F., .F.)
oStlPar:setBorder("BOTTOM", , 1, .T.)
oStlPar:setBorder("LEFT", , 2, .T.)
oStlPar:setBorder("RIGHT", , 3, .T.)
oStlPar:setHAlign("LEFT")

aStl := {oStlTitPar, oStlPar}
oXml:AddRow(, {"PARAMETROS DE PESQUISA"}, oStlTitFil )

oXml:setMerge(, , , 1)

oXml:setColSize({"100", "100"})

oXml:AddRow(, {"Empresa"         , aEmpFat[Val(cEmpFat)] }, aStl)
oXml:AddRow(, {"Prefixo"         , cPrefixo         }, aStl)
oXml:AddRow(, {"Tipo"            , cTipoE1          }, aStl)
oXml:AddRow(, {"Numero DE"       , cNumIni          }, aStl)
oXml:AddRow(, {"Numero ATE"      , cNumFim          }, aStl)
oXml:AddRow(, {"Emissão DE"      , DToC(dEmisIni)   }, aStl)
oXml:AddRow(, {"Emissão ATE"     , DToC(dEmisFim)   }, aStl)
oXml:AddRow(, {"Vencto. DE"      , DToC(dVencIni)   }, aStl)
oXml:AddRow(, {"Vencto. ATE"     , DToC(dVencFim)   }, aStl)
oXml:AddRow(, {"Pagto DE"        , DToC(dBaixIni)   }, aStl)
oXml:AddRow(, {"Pagto ATE"       , DToC(dBaixFim)   }, aStl)
oXml:AddRow(, {"Fornecedor DE"      , cForIni          }, aStl)
oXml:AddRow(, {"Fornecedor ATE"     , cForFim          }, aStl)
// oXml:AddRow(, {"Num.NFS DE"      , cNfsIni          }, aStl)
// oXml:AddRow(, {"Num.NFS ATE"     , cNfsFim          }, aStl)
// oXml:AddRow(, {"Dt.NFS DE"       , DToC(dNfsIni)    }, aStl)
// oXml:AddRow(, {"Dt.NFS ATE"      , DToC(dNfsFim)    }, aStl)

oXml:SkipLine(1)

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraRelatorio
Gera relatorio do tipo categorias ou filiais.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraRelatorio(oMsg,oXml)

//variaveis auxiliares
Local aColSize	:= {}
Local aRowDad	:= {}
Local aStl		:= {}
Local nTotLin   := 0
Local nReg      := 0
Local nTotReg   := 0

//variaveis de estilo
Private oStlTit
Private oStlCab1

cTMP1 := LoadDados()

/*Style Titulo*/
oStlTit := CellStyle():New("StlTit")
oStlTit:setFont("Arial", 12, "#4A4A4A", .T., .F., .F., .F.)
oStlTit:setInterior("#FFFFFF")
oStlTit:setHAlign("LEFT")
oStlTit:setVAlign("CENTER")
oStlTit:setWrapText(.T.)

oStlTit2 := CellStyle():New("StlTit2")
oStlTit2:setFont("Arial", 12, "#4A4A4A", .T., .F., .F., .F.)
oStlTit2:setInterior("#FFFFFF")
oStlTit2:setHAlign("CENTER")
oStlTit2:setVAlign("CENTER")
oStlTit2:setNumberFormat("Medium Date")

oStlTit3 := CellStyle():New("StlTit3")
oStlTit3:setFont("Arial", 10, "#4A4A4A", .T., .F., .F., .F.)
oStlTit3:setInterior("#FFFFFF")
oStlTit3:setHAlign("LEFT")
oStlTit3:setVAlign("CENTER")

oStlCab1 := CellStyle():New("StlCab1")
oStlCab1:setFont("Arial", 9, "#10B7AC", .T., .F., .F., .F.)
oStlCab1:setInterior("#F2F2F2")
oStlCab1:setHAlign("LEFT")
oStlCab1:setVAlign("CENTER")
oStlCab1:setWrapText(.T.)

oSN01Dat := CellStyle():New("N01DAT")
oSN01Dat:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN01Dat:setInterior("#FFFFFF")
oSN01Dat:setHAlign("LEFT")
oSN01Dat:setVAlign("CENTER")
oSN01Dat:setNumberFormat("Medium Date")

oSN02Num := CellStyle():New("N02NUM")
oSN02Num:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN02Num:setInterior("#FFFFFF")
oSN02Num:setHAlign("CENTER")
oSN02Num:setVAlign("CENTER")

oSN03Txt := CellStyle():New("N03TXT")
oSN03Txt:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN03Txt:setInterior("#FFFFFF")
oSN03Txt:setHAlign("LEFT")
oSN03Txt:setVAlign("CENTER")

oSN04Txt := CellStyle():New("N04TXT")
oSN04Txt:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN04Txt:setInterior("#FFFFFF")
oSN04Txt:setHAlign("CENTER")
oSN04Txt:setVAlign("CENTER")

oSN05Num := CellStyle():New("N05NUM")
oSN05Num:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN05Num:setInterior("#FFFFFF")
oSN05Num:setHAlign("RIGHT")
oSN05Num:setVAlign("CENTER")
oSN05Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oSN06Num := CellStyle():New("N06NUM")
oSN06Num:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN06Num:setInterior("#FFFFFF")
oSN06Num:setHAlign("RIGHT")
oSN06Num:setVAlign("CENTER")
oSN06Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oSN07Txt := CellStyle():New("N07TXT")
oSN07Txt:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN07Txt:setInterior("#FFFFFF")
oSN07Txt:setBorder("TOP"	, "Continuous", 1, .T., "#000000")
oSN07Txt:setBorder("BOTTOM"	, "Double"    , 3, .T., "#000000")
oSN07Txt:setHAlign("LEFT")
oSN07Txt:setVAlign("CENTER")

oSN08Num := CellStyle():New("N08NUM")
oSN08Num:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN08Num:setInterior("#FFFFFF")
oSN08Num:setBorder("TOP"	, "Continuous", 1, .T., "#000000")
oSN08Num:setBorder("BOTTOM"	, "Double"    , 3, .T., "#000000")
oSN08Num:setHAlign("RIGHT")
oSN08Num:setVAlign("CENTER")
oSN08Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oXml:setFolder(nFolder)
nFolder++
oXml:setFolderName("Contas a Pagar")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "54.75" ) // Data emissão
aAdd( aColSize, "120.00" ) // Fornecedor
aAdd( aColSize, "65.25" ) // No Nota Fiscal
aAdd( aColSize, "65.25" ) // Prefixo
aAdd( aColSize, "65.25" ) // No Título
aAdd( aColSize, "65.25" ) // Parcela
aAdd( aColSize, "65.25" ) // Líquido a Pagar
aAdd( aColSize, "65.25" ) // Valor Recebido
aAdd( aColSize, "120.25" ) // historico

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Contas a Pagar - Rateio Por empresa : "+ aEmpFat[Val(cEmpFat)]  ) // Data emissão 
aAdd( aCabTit, "" ) // Data vencimento
aAdd( aCabTit, "" ) // Data pagamento
aAdd( aCabTit, "" ) // Dias em atraso
aAdd( aCabTit, "" ) // Fornecedor
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
aAdd( aCabTit, "" ) // Parcela

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Fornecedor
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // Prefixo
aAdd( aTitStl, oStlTit ) // No Título
aAdd( aTitStl, oStlTit ) // Parcela
aAdd( aTitStl, oStlTit ) // Líquido a Pagar
aAdd( aTitStl, oStlTit ) // Valor Recebido
aAdd( aTitStl, oStlTit ) // Impostos

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , ,8) // Contrato Atual

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data emissão" ) // Data emissão
aAdd( aCabDad, "Fornecedor" ) // Fornecedor
aAdd( aCabDad, "CNPJ" ) // CNPJ
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Centro de Custo" ) // No Nota Fiscal
aAdd( aCabDad, "Natureza" ) // No Nota Fiscal
aAdd( aCabDad, "Valor da Nota" ) // Valor da Nota
aAdd( aCabDad, "Valor Rateado" ) // Valor da Nota
aAdd( aCabDad, "Histórico" ) // Histórico

aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Fornecedor
aAdd( aCabStl, oStlCab1 ) // CNPJ
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Valor da Nota
aAdd( aCabStl, oStlCab1 ) // Valor da Nota
aAdd( aCabStl, oStlCab1 ) // Valor da Nota

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

nTotReg:= RecCount()//(cTMP1)->(RECCOUNT())
nReg   := 0
While (cTMP1)->(!EOF())

    nReg++
    oMsg:cCaption:= "Processando Registro " + cValToChar(nReg) + " de " + cValToChar(nTotReg) 
    oMsg:Refresh()
	
    // Meta
	aRowDad	:= {}
	aStl 	:= {}
    
    nVlrRat  := (cTMP1)->E2_VALOR * ((cTMP1)->Z0_PERC/100)
    nVlrNF   := (cTMP1)->E2_VALOR

    nVlrPag  := 0
    nVlrDesc := 0
    nMulta   := 0
    nJuros   := 0

    aAdd( aRowDad, SToD((cTMP1)->E2_EMISSAO) ) // Data emissão
    aAdd( aRowDad, AllTrim((cTMP1)->A2_NREDUZ) ) // Fornecedor    
    aAdd( aRowDad, Transform((cTMP1)->A2_CGC,IIF((cTMP1)->A2_TIPO=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) ) // CNPJ
    aAdd( aRowDad, (cTMP1)->E2_NUMNOTA ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->Z0_CCUSTO ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->Z0_NATURE ) // No Nota Fiscal
    aAdd( aRowDad, nVlrNF ) // Valor NF
    aAdd( aRowDad, nVlrRat ) // Impostos    
    aAdd( aRowDad, (cTMP1)->E2_HIST ) // historico


    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Fornecedor
    aAdd( aStl, oSN03Txt ) // cnpj
    aAdd( aStl, oSN04Txt ) // No Nota Fiscal
    aAdd( aStl, oSN04Txt ) // Z0_CCUSTO
    aAdd( aStl, oSN04Txt ) // Z0_NATURE
    aAdd( aStl, oSN05Num ) // Valor NF
    aAdd( aStl, oSN05Num ) // nVlrRat
    aAdd( aStl, oSN03Txt ) // hist

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


If nTotLin > 0

	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "TOTAL" ) // Data emissão
    aAdd( aRowDad, "" ) // Data vencimento
    aAdd( aRowDad, "" ) // Data pagamento
    aAdd( aRowDad, "" ) // Dias em atraso
    aAdd( aRowDad, "" ) // Fornecedor
    aAdd( aRowDad, "" ) // No Nota Fiscal
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Impostos
/*
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Pagar
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Descontos
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Multa
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Juros
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Total Pago
*/
    aAdd( aRowDad, "" ) // hist

    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Fornecedor
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // Prefixo
    aAdd( aStl, oSN07Txt ) // No Título
    aAdd( aStl, oSN07Txt ) // Parcela
    aAdd( aStl, oSN08Num ) // Valor NF
    aAdd( aStl, oSN08Num ) // Impostos
    aAdd( aStl, oSN07Txt ) // hist
    
	oXML:AddRow( HeightRowTotal, aRowDad, aStl )

    /*
    nTotLin++
    oXML:SkipLine("12.75")

    nTotLin++
    oXML:AddRow( "15.00", {"Relatório de Aging list do Contas a Pagar"  , "", "", "" }, {oStlTit3, oStlTit3, oStlTit3, oStlTit3} )
    oXml:setMerge(, , , 3)

    nTotLin++
    oXML:AddRow( "15.00", {"Período"  , "", "", "A Pagar" }, {oStlCab1, oStlCab1, oStlCab1, oStlCab1} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"à Vencer"                    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-5]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-5]C,&quot;=0&quot;,R[-"+cValToChar(nTotLin)+"]C[7]:R[-5]C[7],&quot;=0&quot;)"      }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 1 a 30 dias"     , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-6]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-6]C,&quot;&gt;0&quot;,R[-"+cValToChar(nTotLin)+"]C:R[-6]C,&quot;&lt;31&quot;)"     }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 31 a 60 dias"    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-7]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-7]C,&quot;&gt;30&quot;,R[-"+cValToChar(nTotLin)+"]C:R[-7]C,&quot;&lt;61&quot;)"    }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 61 a 90 dias"    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-8]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-8]C,&quot;&gt;60&quot;,R[-"+cValToChar(nTotLin)+"]C:R[-8]C,&quot;&lt;91&quot;)"    }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 91 a 180 dias"   , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-9]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-9]C,&quot;&gt;90&quot;,R[-"+cValToChar(nTotLin)+"]C:R[-9]C,&quot;&lt;181&quot;)"   }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos acima de 180 dias"  , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[6]:R[-10]C[6],R[-"+cValToChar(nTotLin)+"]C:R[-10]C,&quot;&gt;180&quot;)"                                                        }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Total do Contas a Pagar"   , "", "", "=SUM(R[-6]C:R[-1]C)"}, {oSN07Txt, oSN07Txt, oSN07Txt, oSN08Num} )
    oXml:setMerge(, , , 2)
    */
EndIf

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Rotina para carregar os dados do relatorio via query.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados()

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	E2_FILIAL "+ CRLF
cQuery += " 	,E2_PREFIXO "+ CRLF
cQuery += " 	,E2_NUM "+ CRLF
cQuery += " 	,E2_PARCELA "+ CRLF
cQuery += " 	,E2_TIPO "+ CRLF
cQuery += " 	,E2_NATUREZ "+ CRLF
cQuery += " 	,E2_FORNECE "+ CRLF
cQuery += " 	,E2_LOJA "+ CRLF
cQuery += " 	,A2_NOME "+ CRLF
cQuery += " 	,A2_NREDUZ "+ CRLF
cQuery += " 	,A2_CGC "+ CRLF 
cQuery += " 	,A2_TIPO "+ CRLF 

cQuery += " 	,E2_EMISSAO "+ CRLF
cQuery += " 	,E2_VENCTO "+ CRLF
cQuery += " 	,E2_VENCREA "+ CRLF
cQuery += " 	,E2_VALOR "+ CRLF
cQuery += " 	,E2_ISS "+ CRLF
cQuery += " 	,E2_IRRF "+ CRLF
cQuery += " 	,E2_BAIXA "+ CRLF
cQuery += " 	,E2_HIST "+ CRLF
cQuery += " 	,E2_SALDO "+ CRLF
cQuery += " 	,E2_DESCONT "+ CRLF
cQuery += " 	,E2_MULTA "+ CRLF
cQuery += " 	,E2_JUROS "+ CRLF
cQuery += " 	,E2_CORREC "+ CRLF
cQuery += " 	,E2_VALLIQ "+ CRLF
cQuery += " 	,E2_VENCORI "+ CRLF
cQuery += " 	,E2_VALJUR "+ CRLF
cQuery += " 	,E2_PORCJUR "+ CRLF
cQuery += " 	,E2_RATEIO "+ CRLF
cQuery += " 	,E2_VLCRUZ "+ CRLF
cQuery += " 	,E2_INSS "+ CRLF
cQuery += " 	,E2_SDACRES "+ CRLF
cQuery += " 	,E2_DECRESC "+ CRLF
cQuery += " 	,E2_SDDECRE "+ CRLF
cQuery += " 	,E2_RETENC "+ CRLF
cQuery += " 	,E2_COFINS "+ CRLF
cQuery += " 	,E2_PIS "+ CRLF
cQuery += " 	,E2_CSLL "+ CRLF
cQuery += " 	,E2_VRETPIS "+ CRLF
cQuery += " 	,E2_VRETCOF "+ CRLF
cQuery += " 	,E2_VRETCSL "+ CRLF
cQuery += " 	,E2_VRETISS "+ CRLF
cQuery += " 	,E2_VRETIRF "+ CRLF
cQuery += " 	,E2_INSSRET "+ CRLF
cQuery += " 	,E2_EMPFAT "+ CRLF
cQuery += " 	,E2_DATAAGE "+ CRLF
cQuery += " 	,E2_CCUSTO "+ CRLF
cQuery += " 	,E2_NUMNOTA "+ CRLF
cQuery += " 	,Z0_PERC "+ CRLF
cQuery += " 	,Z0_NATURE"+CRLF
cQuery += " 	,Z0_CCUSTO"+CRLF

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 (NOLOCK) "+ CRLF
cQuery += " 	ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' "+ CRLF
cQuery += " 	AND SA2.A2_COD = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND SA2.A2_LOJA = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SZ0")+" SZ0 (NOLOCK) "+ CRLF
cQuery += " 	ON SZ0.Z0_FILIAL = '"+xFilial("SZ0")+"' "+ CRLF
cQuery += " 	AND Z0_FORNECE = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND Z0_LOJA    = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND Z0_EMPRESA = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SZ0.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
 
If !Empty(cPrefixo)
    cQuery += " 	AND SE2.E2_PREFIXO = '"+cPrefixo+"' "+ CRLF
EndIf

If !Empty(cTipoE1)
    cQuery += " 	AND SE2.E2_TIPO = '"+cTipoE1+"' "+ CRLF
EndIf

If !Empty(cNumIni) .Or. !Empty(cNumFim) 
    cQuery += " 	AND SE2.E2_NUM BETWEEN '"+cNumIni+"' AND '"+cNumFim+"' "+ CRLF
EndIf

If !Empty(dEmisIni) .Or. !Empty(dEmisFim) 
    cQuery += " 	AND SE2.E2_EMISSAO BETWEEN '"+DToS(dEmisIni)+"' AND '"+DToS(dEmisFim)+"' "+ CRLF
EndIf

If !Empty(dVencIni) .Or. !Empty(dVencFim) 
    cQuery += " 	AND SE2.E2_VENCREA BETWEEN '"+DToS(dVencIni)+"' AND '"+DToS(dVencFim)+"' "+ CRLF
EndIf

If !Empty(dBaixIni) .Or. !Empty(dBaixFim) 
    cQuery += " 	AND SE2.E2_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
EndIf

If !Empty(cForIni) .Or. !Empty(cForFim) 
    cQuery += " 	AND SE2.E2_FORNECE BETWEEN '"+cForIni+"' AND '"+cForFim+"' "+ CRLF
EndIf

If !Empty(cNfsIni) .Or. !Empty(cNfsFim) 
    cQuery += " 	AND SE2.E2_NUMNOTA BETWEEN '"+cNfsIni+"' AND '"+cNfsFim+"' "+ CRLF
EndIf

// If !Empty(dNfsIni) .Or. !Empty(dNfsFim) 
//     cAuxIni := Transform(DToS(dNfsIni), "@R 9999-99-99") + "T00:00:00"
//     cAuxFim := Transform(DToS(dNfsFim), "@R 9999-99-99") + "T99:99:99"
//     cQuery += " 	AND SE2.E2_XDTREC BETWEEN '"+cAuxIni+"' AND '"+cAuxFim+"' "+ CRLF
// EndIf

cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE2.E2_VENCREA "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL07.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
