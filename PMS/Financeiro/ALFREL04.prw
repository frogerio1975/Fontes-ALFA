#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL04
Relatório de Despesas.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL04()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Despesas"
Local cNome 	:= "RelDespesas-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de despesas."
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
Private cNumIni  := CriaVar("E2_NUM",.F.)
Private cNumFim  := CriaVar("E2_NUM",.F.)
Private cNfsIni  := CriaVar("E1_XNUMNFS",.F.)
Private cNfsFim  := CriaVar("E1_XNUMNFS",.F.)
Private dEmisIni := CriaVar("E2_EMISSAO",.F.)
Private dEmisFim := CriaVar("E2_EMISSAO",.F.)
Private cForIni  := CriaVar("E2_FORNECE",.F.)
Private cForFim  := CriaVar("E2_FORNECE",.F.)

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Prefixo"         , cPrefixo  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero DE"       , cNumIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero ATE"      , cNumFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS DE"      , cNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS ATE"     , cNfsFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.Emissão DE"   , dEmisIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.Emissão ATE"  , dEmisFim  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Fornecedor DE"   , cForIni   , "@!", "", "SA2", "", 50, .F.} )
AADD( aBoxParam, {1,"Fornecedor ATE"  , cForFim   , "@!", "", "SA2", "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Despesas",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cPrefixo := aRetParam[2]
    cNumIni  := aRetParam[3]
    cNumFim  := aRetParam[4]
    cNfsIni  := aRetParam[5]
    cNfsFim  := aRetParam[6]
    dEmisIni := aRetParam[7]
    dEmisFim := aRetParam[8]
    cForIni  := aRetParam[9]
    cForFim  := aRetParam[10]

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
oXml:AddRow(, {"Numero DE"       , cNumIni          }, aStl)
oXml:AddRow(, {"Numero ATE"      , cNumFim          }, aStl)
oXml:AddRow(, {"Num.NFS DE"      , cNfsIni          }, aStl)
oXml:AddRow(, {"Num.NFS ATE"     , cNfsFim          }, aStl)
oXml:AddRow(, {"Dt.Emissão DE"   , DToC(dEmisIni)   }, aStl)
oXml:AddRow(, {"Dt.Emissão ATE"  , DToC(dEmisFim)   }, aStl)
oXml:AddRow(, {"Fornecedor DE"   , cForIni          }, aStl)
oXml:AddRow(, {"Fornecedor ATE"  , cForFim          }, aStl)

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
Local cPictNat  := PesqPict("SED", "ED_CODIGO")
Local cPictCC   := PesqPict("CTT", "CTT_CUSTO")
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
oStlTit2:setFont("Arial", 8, "#4A4A4A", .T., .F., .F., .F.)
oStlTit2:setInterior("#FFFFFF")
oStlTit2:setHAlign("CENTER")
oStlTit2:setVAlign("CENTER")
oStlTit2:setNumberFormat("Medium Date")

oStlTit3 := CellStyle():New("StlTit3")
oStlTit3:setFont("Arial", 8, "#4A4A4A", .T., .F., .F., .F.)
oStlTit3:setInterior("#FFFF00")
oStlTit3:setHAlign("CENTER")
oStlTit3:setVAlign("CENTER")
oStlTit3:setWrapText(.T.)

oStlCab1 := CellStyle():New("StlCab1")
oStlCab1:setFont("Arial", 9, "#10B7AC", .T., .F., .F., .F.)
oStlCab1:setInterior("#F2F2F2")
oStlCab1:setHAlign("LEFT")
oStlCab1:setVAlign("CENTER")
oStlCab1:setWrapText(.T.)

oStlCab2 := CellStyle():New("StlCab2")
oStlCab2:setFont("Arial", 9, "#10B7AC", .T., .F., .F., .F.)
// oStlCab2:setInterior("#F2F2F2")
// oStlCab2:setHAlign("LEFT")
// oStlCab2:setVAlign("CENTER")
// oStlCab2:setWrapText(.T.)

oStlCab3 := CellStyle():New("StlCab3")
oStlCab3:setFont("Arial", 9, "#FFFFFF", .T., .F., .F., .F.)
oStlCab3:setInterior("#0070C0")
oStlCab3:setHAlign("CENTER")
oStlCab3:setVAlign("CENTER")
oStlCab3:setWrapText(.T.)

oStlCab4 := CellStyle():New("StlCab4")
oStlCab4:setFont("Arial", 9, "#10B7AC", .T., .F., .F., .F.)
oStlCab4:setInterior("#F2F2F2")
oStlCab4:setHAlign("CENTER")
oStlCab4:setVAlign("CENTER")
oStlCab4:setWrapText(.T.)

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
oXml:setFolderName("Despesas")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "49.5" ) // Data emissão
aAdd( aColSize, "120" ) // Fornecedor
aAdd( aColSize, "80" ) // CNPJ
aAdd( aColSize, "65.25" ) // No Nota Fiscal
aAdd( aColSize, "65.25" ) // link
aAdd( aColSize, "65.25" ) // Prefixo
aAdd( aColSize, "65.25" ) // No Título
aAdd( aColSize, "65.25" ) // Parcela
aAdd( aColSize, "200" ) // Natureza Financeira
aAdd( aColSize, "200" ) // Centro de Custo
aAdd( aColSize, "65.25" ) // Valor NF
aAdd( aColSize, "7.5" ) // Vazio 1
aAdd( aColSize, "65.25" ) // Retenção - IRRF
aAdd( aColSize, "65.25" ) // Retenção - CSLL
aAdd( aColSize, "65.25" ) // Retenção - PIS
aAdd( aColSize, "65.25" ) // Retenção - Cofins
aAdd( aColSize, "7.5" ) // Vazio 2
aAdd( aColSize, "65.25" ) // Líquido

aAdd( aColSize, "120.00" ) // hist

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Despesas" ) // Data emissão
aAdd( aCabTit, "" ) // Fornecedor
aAdd( aCabTit, "" ) // CNPJ
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // link
//aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
//aAdd( aCabTit, "" ) // Parcela
aAdd( aCabTit, "" ) // Natureza Financeira
aAdd( aCabTit, "" ) // Centro de Custo
//aAdd( aCabTit, "" ) // Valor NF
//aAdd( aCabTit, "" ) // Vazio 1
//aAdd( aCabTit, "Retenções de tributos" ) // Retenção - IRRF
//aAdd( aCabTit, "" ) // Retenção - CSLL
//aAdd( aCabTit, "" ) // Retenção - PIS
//aAdd( aCabTit, "" ) // Retenção - Cofins
//aAdd( aCabTit, "" ) // Vazio 2
//aAdd( aCabTit, Date() ) // Líquido

aAdd( aCabTit, "" ) // hist
aAdd( aCabTit, "" ) // Valor Nota Fiscal

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Fornecedor
aAdd( aTitStl, oStlTit ) // CNPJ
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // link
//aAdd( aTitStl, oStlTit ) // Prefixo
aAdd( aTitStl, oStlTit ) // No Título
//aAdd( aTitStl, oStlTit ) // Parcela
aAdd( aTitStl, oStlTit ) // Natureza Financeira
aAdd( aTitStl, oStlTit ) // Centro de Custo
//aAdd( aTitStl, oStlTit ) // Valor NF
//aAdd( aTitStl, oStlTit ) // Vazio 1
//aAdd( aTitStl, oStlTit3 ) // Retenção - IRRF
//aAdd( aTitStl, oStlTit3 ) // Retenção - CSLL
//aAdd( aTitStl, oStlTit3 ) // Retenção - PIS
//aAdd( aTitStl, oStlTit3 ) // Retenção - Cofins
//aAdd( aTitStl, oStlTit ) // Vazio 2
//aAdd( aTitStl, oStlTit2 ) // Líquido

aAdd( aTitStl, oStlTit ) // hist
aAdd( aTitStl, oStlTit ) // Valor Nota Fiscal

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 10)

//oXml:SetMerge( , 12, , 3)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data emissão" ) // Data emissão
aAdd( aCabDad, "Fornecedor" ) // Fornecedor
aAdd( aCabDad, "CNPJ" ) // CNPJ
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Link da Nota Fiscal" ) // Link da Nota Fiscal
//aAdd( aCabDad, "Prefixo" ) // Prefixo
aAdd( aCabDad, "No Título" ) // No Título
//aAdd( aCabDad, "Parcela" ) // Parcela
aAdd( aCabDad, "Natureza Financeira" ) // Natureza Financeira
aAdd( aCabDad, "Centro de Custo" ) // Centro de Custo
//aAdd( aCabDad, "Valor NF" ) // Valor NF
//aAdd( aCabDad, "" ) // Vazio 1
//aAdd( aCabDad, "IRRF" ) // Retenção - IRRF
//aAdd( aCabDad, "CSLL" ) // Retenção - CSLL
//aAdd( aCabDad, "PIS" ) // Retenção - PIS
//aAdd( aCabDad, "Cofins" ) // Retenção - Cofins
//aAdd( aCabDad, "" ) // Vazio 2
//aAdd( aCabDad, "Líquido" ) // Líquido

aAdd( aCabDad, "Histórico" ) // historico
aAdd( aCabDad, "Valor NF" ) // Valor NF
aAdd( aCabDad, "Valor Nota Fiscal" ) // Valor Nota Fiscal
aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Fornecedor
aAdd( aCabStl, oStlCab1 ) // CNPJ
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // Link da Nota Fiscal
//aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
//aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Natureza Financeira
aAdd( aCabStl, oStlCab1 ) // Centro de Custo
//aAdd( aCabStl, oStlCab4 ) // Valor NF
//aAdd( aCabStl, oStlCab2 ) // Vazio 1
//aAdd( aCabStl, oStlCab3 ) // Retenção - IRRF
//aAdd( aCabStl, oStlCab3 ) // Retenção - CSLL
//aAdd( aCabStl, oStlCab3 ) // Retenção - PIS
//aAdd( aCabStl, oStlCab3 ) // Retenção - Cofins
//aAdd( aCabStl, oStlCab2 ) // Vazio 2
//aAdd( aCabStl, oStlCab4 ) // Líquido
aAdd( aCabStl, oStlCab1 ) // historico
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // Valor Nota Fiscal

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

    //nVlrLiq  := (cTMP1)->E2_VALOR - SomaAbat((cTMP1)->E2_PREFIXO,(cTMP1)->E2_NUM,(cTMP1)->E2_PARCELA,'R',1,,(cTMP1)->E2_FORNECE,(cTMP1)->E2_LOJA)

    If !Empty((cTMP1)->EZ_CCUSTO)
        nVlrPIS  := (cTMP1)->E2_VRETPIS * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrCOF  := (cTMP1)->E2_VRETCOF * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrIRRF := (cTMP1)->E2_VRETIRF * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrCSLL := (cTMP1)->E2_VRETCSL * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrNF   := (cTMP1)->EZ_VALOR + nVlrPIS + nVlrCOF + nVlrIRRF + nVlrCSLL
    Else
        If !Empty((cTMP1)->EV_NATUREZ)
            nVlrPIS  := (cTMP1)->E2_VRETPIS * (cTMP1)->EV_PERC
            nVlrCOF  := (cTMP1)->E2_VRETCOF * (cTMP1)->EV_PERC
            nVlrIRRF := (cTMP1)->E2_VRETIRF * (cTMP1)->EV_PERC
            nVlrCSLL := (cTMP1)->E2_VRETCSL * (cTMP1)->EV_PERC
            nVlrNF   := (cTMP1)->EV_VALOR + nVlrPIS +  nVlrCOF + nVlrIRRF + nVlrCSLL
        Else
            nVlrPIS  := (cTMP1)->E2_VRETPIS
            nVlrCOF  := (cTMP1)->E2_VRETCOF
            nVlrIRRF := (cTMP1)->E2_VRETIRF
            nVlrCSLL := (cTMP1)->E2_VRETCSL
            nVlrNF   := (cTMP1)->E2_VALOR + nVlrPIS + nVlrCOF + nVlrIRRF + nVlrCSLL
        EndIf
    EndIf

    aAdd( aRowDad, SToD((cTMP1)->E2_EMISSAO) ) // Data emissão
    aAdd( aRowDad, AllTrim((cTMP1)->A2_NREDUZ) ) // Fornecedor
    aAdd( aRowDad, Transform((cTMP1)->A2_CGC,IIF((cTMP1)->A2_TIPO=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) ) // CNPJ
    aAdd( aRowDad, (cTMP1)->E2_NUMNOTA ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->E2_XLINKNF ) // No Nota Fiscal 
    //aAdd( aRowDad, (cTMP1)->E2_PREFIXO ) // Prefixo
    aAdd( aRowDad, (cTMP1)->E2_NUM ) // No Título
    //aAdd( aRowDad, (cTMP1)->E2_PARCELA ) // Parcela
    aAdd( aRowDad, Transform(AllTrim((cTMP1)->EV_NATUREZ),cPictNat) + " - " + AllTrim((cTMP1)->ED_DESCRIC) ) // Natureza Financeira
    aAdd( aRowDad, Transform(AllTrim((cTMP1)->EZ_CCUSTO),cPictCC) + " - " + AllTrim((cTMP1)->CTT_DESC01) ) // Centro de Custo
    //aAdd( aRowDad, nVlrNF ) // Valor NF
    //aAdd( aRowDad, "" ) // Vazio 1
    //aAdd( aRowDad, nVlrIRRF ) // Retenção - IRRF
    //aAdd( aRowDad, nVlrCSLL ) // Retenção - CSLL
    //aAdd( aRowDad, nVlrPIS ) // Retenção - PIS
    //aAdd( aRowDad, nVlrCOF ) // Retenção - Cofins
    //aAdd( aRowDad, "" ) // Vazio 2
    //aAdd( aRowDad, "=RC[-7]-RC[-5]-RC[-4]-RC[-3]-RC[-2]" ) // Líquido
    
    aAdd( aRowDad, (cTMP1)->E2_HIST ) // hist
    aAdd( aRowDad, nVlrNF ) // Valor NF
    aAdd( aRowDad, (cTMP1)->E2_XVLRNF ) // valor noa fiscal

    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Fornecedor
    aAdd( aStl, oSN03Txt ) // CNPJ
    aAdd( aStl, oSN04Txt ) // No Nota Fiscal
    aAdd( aStl, oSN04Txt ) // LINK NF
    //aAdd( aStl, oSN04Txt ) // Prefixo
    aAdd( aStl, oSN04Txt ) // No Título
    //aAdd( aStl, oSN04Txt ) // Parcela
    aAdd( aStl, oSN03Txt ) // Natureza Financeira
    aAdd( aStl, oSN03Txt ) // Centro de Custo
    //aAdd( aStl, oSN05Num ) // Valor NF
    //aAdd( aStl, oSN05Num ) // Vazio 1
    //aAdd( aStl, oSN05Num ) // Retenção - IRRF
    //aAdd( aStl, oSN05Num ) // Retenção - CSLL
    //aAdd( aStl, oSN05Num ) // Retenção - PIS
    //aAdd( aStl, oSN05Num ) // Retenção - Cofins
    //aAdd( aStl, oSN05Num ) // Vazio 2
    //aAdd( aStl, oSN06Num ) // Líquido
    
    aAdd( aStl, oSN03Txt ) // hist
    aAdd( aStl, oSN05Num ) // Valor NF
    aAdd( aStl, oSN05Num ) // hist

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


If nTotLin > 0

	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "TOTAL" ) // Data emissão
    aAdd( aRowDad, "" ) // Fornecedor
    aAdd( aRowDad, "" ) // CNPJ
    aAdd( aRowDad, "" ) // No Nota Fiscal
    aAdd( aRowDad, "" ) // LINKL Nota Fiscal
    //aAdd( aRowDad, "" ) // Prefixo
    aAdd( aRowDad, "" ) // No Título
    //aAdd( aRowDad, "" ) // Parcela
    aAdd( aRowDad, "" ) // Natureza Financeira
    aAdd( aRowDad, "" ) // Centro de Custo
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    //aAdd( aRowDad, "" ) // Vazio 1
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - IRRF
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - CSLL
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - PIS
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - Cofins
    //aAdd( aRowDad, "" ) // Vazio 2
    //aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido

    aAdd( aRowDad, "" ) // hist 
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF   
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido
    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Fornecedor
    aAdd( aStl, oSN07Txt ) // CNPJ
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // LINK NF
    //aAdd( aStl, oSN07Txt ) // Prefixo
    aAdd( aStl, oSN07Txt ) // No Título
    //aAdd( aStl, oSN07Txt ) // Parcela
    aAdd( aStl, oSN07Txt ) // Natureza Financeira
    aAdd( aStl, oSN07Txt ) // Centro de Custo
    //aAdd( aStl, oSN08Num ) // Valor NF
    //aAdd( aStl, oSN07Txt ) // Vazio 1
    //aAdd( aStl, oSN08Num ) // Retenção - IRRF
    //aAdd( aStl, oSN08Num ) // Retenção - CSLL
    //aAdd( aStl, oSN08Num ) // Retenção - PIS
    //aAdd( aStl, oSN08Num ) // Retenção - Cofins
    //aAdd( aStl, oSN07Txt ) // Vazio 2
    //aAdd( aStl, oSN08Num ) // Líquido
    
    aAdd( aStl, oSN07Txt ) // hist
    aAdd( aStl, oSN08Num ) // hist
    aAdd( aStl, oSN08Num ) // hist

	oXML:AddRow( HeightRowTotal, aRowDad, aStl )
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
cQuery += " 	,E2_EMPFAT "+ CRLF
cQuery += " 	,E2_PREFIXO "+ CRLF
cQuery += " 	,E2_NUM "+ CRLF
cQuery += " 	,E2_PARCELA "+ CRLF
cQuery += " 	,E2_TIPO "+ CRLF
cQuery += " 	,E2_FORNECE "+ CRLF
cQuery += " 	,E2_LOJA "+ CRLF
cQuery += " 	,A2_NOME "+ CRLF
cQuery += " 	,A2_NREDUZ "+ CRLF
cQuery += " 	,A2_TIPO "+ CRLF
cQuery += " 	,A2_CGC "+ CRLF
cQuery += " 	,E2_NATUREZ "+ CRLF
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
cQuery += " 	,EV_NATUREZ "+ CRLF
cQuery += "     ,ED_DESCRIC "+ CRLF
cQuery += " 	,EV_VALOR "+ CRLF
cQuery += " 	,EV_PERC "+ CRLF
cQuery += " 	,EZ_CCUSTO "+ CRLF
cQuery += " 	,CTT_DESC01 "+ CRLF
cQuery += "     ,ED_DESCRIC "+ CRLF
cQuery += " 	,EZ_VALOR "+ CRLF
cQuery += " 	,EZ_PERC "+ CRLF

cQuery += " 	,E2_XVLRNF"+CRLF
cQuery += " 	,E2_XLINKNF"+CRLF

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 (NOLOCK) "+ CRLF
cQuery += " 	ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' "+ CRLF
cQuery += " 	AND SA2.A2_COD = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND SA2.A2_LOJA = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
cQuery += " 	ON SEV.EV_FILIAL = SE2.E2_FILIAL "+ CRLF
cQuery += " 	AND SEV.EV_PREFIXO = SE2.E2_PREFIXO "+ CRLF
cQuery += " 	AND SEV.EV_NUM = SE2.E2_NUM "+ CRLF
cQuery += " 	AND SEV.EV_PARCELA = SE2.E2_PARCELA "+ CRLF
cQuery += " 	AND SEV.EV_TIPO = SE2.E2_TIPO "+ CRLF
cQuery += " 	AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SEZ")+" SEZ (NOLOCK) "+ CRLF
cQuery += " 	ON SEZ.EZ_FILIAL = SE2.E2_FILIAL "+ CRLF
cQuery += " 	AND SEZ.EZ_PREFIXO = SE2.E2_PREFIXO "+ CRLF
cQuery += " 	AND SEZ.EZ_NUM = SE2.E2_NUM "+ CRLF
cQuery += " 	AND SEZ.EZ_PARCELA = SE2.E2_PARCELA "+ CRLF
cQuery += " 	AND SEZ.EZ_TIPO = SE2.E2_TIPO "+ CRLF
cQuery += " 	AND SEZ.EZ_NATUREZ = SEV.EV_NATUREZ "+ CRLF
cQuery += " 	AND SEZ.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = SEV.EV_NATUREZ "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("CTT")+" CTT (NOLOCK) "+ CRLF
cQuery += " 	ON CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
cQuery += " 	AND CTT.CTT_CUSTO = SEZ.EZ_CCUSTO "+ CRLF
cQuery += " 	AND CTT.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE2.E2_NUMNOTA <> ' ' "+ CRLF

If !Empty(cPrefixo)
    cQuery += " 	AND SE2.E2_PREFIXO = '"+cPrefixo+"' "+ CRLF
EndIf

If !Empty(cNumIni) .Or. !Empty(cNumFim) 
    cQuery += " 	AND SE2.E2_NUM BETWEEN '"+cNumIni+"' AND '"+cNumFim+"' "+ CRLF
EndIf

If !Empty(cNfsIni) .Or. !Empty(cNfsFim) 
    cQuery += " 	AND SE2.E2_NUMNOTA BETWEEN '"+cNfsIni+"' AND '"+cNfsFim+"' "+ CRLF
EndIf

If !Empty(dEmisIni) .Or. !Empty(dEmisFim) 
    cQuery += " 	AND SE2.E2_EMISSAO BETWEEN '"+DToS(dEmisIni)+"' AND '"+DToS(dEmisFim)+"' "+ CRLF
EndIf

If !Empty(cForIni) .Or. !Empty(cForFim) 
    cQuery += " 	AND SE2.E2_FORNECE BETWEEN '"+cForIni+"' AND '"+cForFim+"' "+ CRLF
EndIf

cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	E2_EMISSAO "+ CRLF
cQuery += " 	,EV_NATUREZ "+ CRLF
cQuery += " 	,EZ_CCUSTO "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL04.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
