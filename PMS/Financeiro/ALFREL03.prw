#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL03
Relatório de Faturamento.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL03()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Faturamento"
Local cNome 	:= "RelFaturamento-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de faturamento."
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
Private aEmpFat  := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
Private cEmpFat  := "1"
Private cPrefixo := CriaVar("E1_PREFIXO",.F.)
Private cNumIni  := CriaVar("E1_NUM",.F.)
Private cNumFim  := CriaVar("E1_NUM",.F.)
Private cNfsIni  := CriaVar("E1_XNUMNFS",.F.)
Private cNfsFim  := CriaVar("E1_XNUMNFS",.F.)
Private dNfsIni  := CriaVar("E1_EMISSAO",.F.)
Private dNfsFim  := CriaVar("E1_EMISSAO",.F.)
Private cCliIni  := CriaVar("E1_CLIENTE",.F.)
Private cCliFim  := CriaVar("E1_CLIENTE",.F.)

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Prefixo"         , cPrefixo  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero DE"       , cNumIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Numero ATE"      , cNumFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS DE"      , cNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS ATE"     , cNfsFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.NFS DE"       , dNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.NFS ATE"      , dNfsFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Cliente DE"      , cCliIni   , "@!", "", "SA1", "", 50, .F.} )
AADD( aBoxParam, {1,"Cliente ATE"     , cCliFim   , "@!", "", "SA1", "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Faturamento",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cPrefixo := aRetParam[2]
    cNumIni  := aRetParam[3]
    cNumFim  := aRetParam[4]
    cNfsIni  := aRetParam[5]
    cNfsFim  := aRetParam[6]
    dNfsIni  := aRetParam[7]
    dNfsFim  := aRetParam[8]
    cCliIni  := aRetParam[9]
    cCliFim  := aRetParam[10]

    If lRetorno
        oXML := ExcelXML():New()
        FwMsgRun( ,{|| oXML := GeraRelatorio(oXML) 	},, "Aguarde. Gerando relatório..." )
        FwMsgRun( ,{|| oXML	:= GeraFiltro(oXML) 	},, "Aguarde. Gerando aba indicações de filtros..." )
            
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
Static Function GeraFiltro(oXml)

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
oXml:AddRow(, {"Dt.NFS DE"       , DToC(dNfsIni)    }, aStl)
oXml:AddRow(, {"Dt.NFS ATE"      , DToC(dNfsFim)    }, aStl)
oXml:AddRow(, {"Cliente DE"      , cCliIni          }, aStl)
oXml:AddRow(, {"Cliente ATE"     , cCliFim          }, aStl)

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
Static Function GeraRelatorio(oXml)

//variaveis auxiliares
Local aColSize	:= {}
Local aRowDad	:= {}
Local aStl		:= {}
Local nTotLin   := 0
Local cPictNat  := PesqPict("SED", "ED_CODIGO")
Local cPictCC   := PesqPict("CTT", "CTT_CUSTO")

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
oXml:setFolderName("Faturamento")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "49.5" ) // Data emissão
aAdd( aColSize, "120" ) // Cliente
aAdd( aColSize, "80" ) // CNPJ
aAdd( aColSize, "65.25" ) // No Nota Fiscal
aAdd( aColSize, "65.25" ) // Prefixo
aAdd( aColSize, "65.25" ) // No Título
aAdd( aColSize, "65.25" ) // Parcela
aAdd( aColSize, "200" ) // Natureza Financeira
aAdd( aColSize, "200" ) // Centro de Custo
aAdd( aColSize, "65.25" ) // Valor NF
aAdd( aColSize, "65.25" ) // Tributo - ISS
aAdd( aColSize, "65.25" ) // Tributo - PIS
aAdd( aColSize, "65.25" ) // Tributo - Cofins
aAdd( aColSize, "7.5" ) // Vazio 1
aAdd( aColSize, "65.25" ) // Retenção - IRRF
aAdd( aColSize, "65.25" ) // Retenção - CSLL
aAdd( aColSize, "65.25" ) // Retenção - PIS
aAdd( aColSize, "65.25" ) // Retenção - Cofins
aAdd( aColSize, "7.5" ) // Vazio 2
aAdd( aColSize, "65.25" ) // Líquido
aAdd( aColSize, "65.25" ) // hist

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Faturamento" ) // Data emissão
aAdd( aCabTit, "" ) // Cliente
aAdd( aCabTit, "" ) // CNPJ
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
aAdd( aCabTit, "" ) // Parcela
aAdd( aCabTit, "" ) // Natureza Financeira
aAdd( aCabTit, "" ) // Centro de Custo
aAdd( aCabTit, "" ) // Valor NF
aAdd( aCabTit, "Tributos sobre faturamento" ) // Tributo - ISS
aAdd( aCabTit, "" ) // Tributo - PIS
aAdd( aCabTit, "" ) // Tributo - Cofins
aAdd( aCabTit, "" ) // Vazio 1
aAdd( aCabTit, "Retenções de tributos" ) // Retenção - IRRF
aAdd( aCabTit, "" ) // Retenção - CSLL
aAdd( aCabTit, "" ) // Retenção - PIS
aAdd( aCabTit, "" ) // Retenção - Cofins
aAdd( aCabTit, "" ) // Vazio 2
aAdd( aCabTit, Date() ) // Líquido

aAdd( aCabTit, "" ) // hist

aTitStl := {}


aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Cliente
aAdd( aTitStl, oStlTit ) // CNPJ
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // Prefixo
aAdd( aTitStl, oStlTit ) // No Título
aAdd( aTitStl, oStlTit ) // Parcela
aAdd( aTitStl, oStlTit ) // Natureza Financeira
aAdd( aTitStl, oStlTit ) // Centro de Custo
aAdd( aTitStl, oStlTit ) // Valor NF
aAdd( aTitStl, oStlTit3 ) // Tributo - ISS
aAdd( aTitStl, oStlTit3 ) // Tributo - PIS
aAdd( aTitStl, oStlTit3 ) // Tributo - Cofins
aAdd( aTitStl, oStlTit ) // Vazio 1
aAdd( aTitStl, oStlTit3 ) // Retenção - IRRF
aAdd( aTitStl, oStlTit3 ) // Retenção - CSLL
aAdd( aTitStl, oStlTit3 ) // Retenção - PIS
aAdd( aTitStl, oStlTit3 ) // Retenção - Cofins
aAdd( aTitStl, oStlTit ) // Vazio 2
aAdd( aTitStl, oStlTit2 ) // Líquido
aAdd( aTitStl, oStlTit ) // CNPJ

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 4)
oXml:SetMerge( , 11, , 2)
oXml:SetMerge( , 15, , 3)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data emissão" ) // Data emissão
aAdd( aCabDad, "Cliente" ) // Cliente
aAdd( aCabDad, "CNPJ" ) // CNPJ
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Prefixo" ) // Prefixo
aAdd( aCabDad, "No Título" ) // No Título
aAdd( aCabDad, "Parcela" ) // Parcela
aAdd( aCabDad, "Natureza Financeira" ) // Natureza Financeira
aAdd( aCabDad, "Centro de Custo" ) // Centro de Custo
aAdd( aCabDad, "Valor NF" ) // Valor NF
aAdd( aCabDad, "ISS" ) // Tributo - ISS
aAdd( aCabDad, "PIS" ) // Tributo - PIS
aAdd( aCabDad, "Cofins" ) // Tributo - Cofins
aAdd( aCabDad, "" ) // Vazio 1
aAdd( aCabDad, "IRRF" ) // Retenção - IRRF
aAdd( aCabDad, "CSLL" ) // Retenção - CSLL
aAdd( aCabDad, "PIS" ) // Retenção - PIS
aAdd( aCabDad, "Cofins" ) // Retenção - Cofins
aAdd( aCabDad, "" ) // Vazio 2
aAdd( aCabDad, "Líquido" ) // Líquido
aAdd( aCabDad, "Historico" ) // Historico
aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Cliente
aAdd( aCabStl, oStlCab1 ) // CNPJ
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Natureza Financeira
aAdd( aCabStl, oStlCab1 ) // Centro de Custo
aAdd( aCabStl, oStlCab4 ) // Valor NF
aAdd( aCabStl, oStlCab4 ) // Tributo - ISS
aAdd( aCabStl, oStlCab4 ) // Tributo - PIS
aAdd( aCabStl, oStlCab4 ) // Tributo - Cofins
aAdd( aCabStl, oStlCab2 ) // Vazio 1
aAdd( aCabStl, oStlCab3 ) // Retenção - IRRF
aAdd( aCabStl, oStlCab3 ) // Retenção - CSLL
aAdd( aCabStl, oStlCab3 ) // Retenção - PIS
aAdd( aCabStl, oStlCab3 ) // Retenção - Cofins
aAdd( aCabStl, oStlCab2 ) // Vazio 2
aAdd( aCabStl, oStlCab4 ) // Líquido
aAdd( aCabStl, oStlCab1 ) // CNPJ
oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    //nVlrLiq  := (cTMP1)->E1_VALOR - SomaAbat((cTMP1)->E1_PREFIXO,(cTMP1)->E1_NUM,(cTMP1)->E1_PARCELA,'R',1,,(cTMP1)->E1_CLIENTE,(cTMP1)->E1_LOJA)

    If !Empty((cTMP1)->EZ_CCUSTO)
        nVlrNF   := (cTMP1)->EZ_VALOR
        nVlrISS  := (cTMP1)->E1_ISS * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrPIS  := (cTMP1)->E1_PIS * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrCOF  := (cTMP1)->E1_COFINS * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrIRRF := (cTMP1)->E1_VRETIRF * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
        nVlrCSLL := (cTMP1)->E1_CSLL * (cTMP1)->EV_PERC * (cTMP1)->EZ_PERC
    Else
        If !Empty((cTMP1)->EV_NATUREZ)
            nVlrNF   := (cTMP1)->EV_VALOR
            nVlrISS  := (cTMP1)->E1_ISS * (cTMP1)->EV_PERC
            nVlrPIS  := (cTMP1)->E1_PIS * (cTMP1)->EV_PERC
            nVlrCOF  := (cTMP1)->E1_COFINS * (cTMP1)->EV_PERC
            nVlrIRRF := (cTMP1)->E1_VRETIRF * (cTMP1)->EV_PERC
            nVlrCSLL := (cTMP1)->E1_CSLL * (cTMP1)->EV_PERC
        Else
            nVlrNF   := (cTMP1)->E1_VALOR
            nVlrISS  := (cTMP1)->E1_ISS
            nVlrPIS  := (cTMP1)->E1_PIS
            nVlrCOF  := (cTMP1)->E1_COFINS
            nVlrIRRF := (cTMP1)->E1_VRETIRF
            nVlrCSLL := (cTMP1)->E1_CSLL
        EndIf
    EndIf

    aAdd( aRowDad, SToD(StrTran(SubStr((cTMP1)->E1_XDTREC,1,10),"-")) ) // Data emissão
    aAdd( aRowDad, AllTrim((cTMP1)->A1_NREDUZ) ) // Cliente
    aAdd( aRowDad, Transform((cTMP1)->A1_CGC,IIF((cTMP1)->A1_PESSOA=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) ) // CNPJ
    aAdd( aRowDad, (cTMP1)->E1_XNUMNFS ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->E1_PREFIXO ) // Prefixo
    aAdd( aRowDad, (cTMP1)->E1_NUM ) // No Título
    aAdd( aRowDad, (cTMP1)->E1_PARCELA ) // Parcela
    aAdd( aRowDad, Transform(AllTrim((cTMP1)->EV_NATUREZ),cPictNat) + " - " + AllTrim((cTMP1)->ED_DESCRIC) ) // Natureza Financeira
    aAdd( aRowDad, Transform(AllTrim((cTMP1)->EZ_CCUSTO),cPictCC) + " - " + AllTrim((cTMP1)->CTT_DESC01) ) // Centro de Custo
    aAdd( aRowDad, nVlrNF ) // Valor NF
    aAdd( aRowDad, nVlrISS ) // Tributo - ISS
    aAdd( aRowDad, nVlrPIS ) // Tributo - PIS
    aAdd( aRowDad, nVlrCOF ) // Tributo - Cofins
    aAdd( aRowDad, "" ) // Vazio 1
    aAdd( aRowDad, nVlrIRRF ) // Retenção - IRRF
    aAdd( aRowDad, nVlrCSLL ) // Retenção - CSLL
    aAdd( aRowDad, nVlrPIS ) // Retenção - PIS
    aAdd( aRowDad, nVlrCOF ) // Retenção - Cofins
    aAdd( aRowDad, "" ) // Vazio 2    
    aAdd( aRowDad, "=RC[-10]-RC[-5]-RC[-4]-RC[-3]-RC[-2]" ) // Líquido
    
    aAdd( aRowDad, (cTMP1)->E1_HIST ) // historico

    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Cliente
    aAdd( aStl, oSN03Txt ) // CNPJ
    aAdd( aStl, oSN04Txt ) // No Nota Fiscal
    aAdd( aStl, oSN04Txt ) // Prefixo
    aAdd( aStl, oSN04Txt ) // No Título
    aAdd( aStl, oSN04Txt ) // Parcela
    aAdd( aStl, oSN03Txt ) // Natureza Financeira
    aAdd( aStl, oSN03Txt ) // Centro de Custo
    aAdd( aStl, oSN05Num ) // Valor NF
    aAdd( aStl, oSN05Num ) // Tributo - ISS
    aAdd( aStl, oSN05Num ) // Tributo - PIS
    aAdd( aStl, oSN05Num ) // Tributo - Cofins
    aAdd( aStl, oSN05Num ) // Vazio 1
    aAdd( aStl, oSN05Num ) // Retenção - IRRF
    aAdd( aStl, oSN05Num ) // Retenção - CSLL
    aAdd( aStl, oSN05Num ) // Retenção - PIS
    aAdd( aStl, oSN05Num ) // Retenção - Cofins
    aAdd( aStl, oSN05Num ) // Vazio 2
    aAdd( aStl, oSN06Num ) // Líquido
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
    aAdd( aRowDad, "" ) // Cliente
    aAdd( aRowDad, "" ) // CNPJ
    aAdd( aRowDad, "" ) // No Nota Fiscal
    aAdd( aRowDad, "" ) // Prefixo
    aAdd( aRowDad, "" ) // No Título
    aAdd( aRowDad, "" ) // Parcela
    aAdd( aRowDad, "" ) // Natureza Financeira
    aAdd( aRowDad, "" ) // Centro de Custo
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Tributo - ISS
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Tributo - PIS
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Tributo - Cofins
    aAdd( aRowDad, "" ) // Vazio 1
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - IRRF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - CSLL
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - PIS
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Retenção - Cofins
    aAdd( aRowDad, "" ) // Vazio 2
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido

    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Cliente
    aAdd( aStl, oSN07Txt ) // CNPJ
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // Prefixo
    aAdd( aStl, oSN07Txt ) // No Título
    aAdd( aStl, oSN07Txt ) // Parcela
    aAdd( aStl, oSN07Txt ) // Natureza Financeira
    aAdd( aStl, oSN07Txt ) // Centro de Custo
    aAdd( aStl, oSN08Num ) // Valor NF
    aAdd( aStl, oSN08Num ) // Tributo - ISS
    aAdd( aStl, oSN08Num ) // Tributo - PIS
    aAdd( aStl, oSN08Num ) // Tributo - Cofins
    aAdd( aStl, oSN07Txt ) // Vazio 1
    aAdd( aStl, oSN08Num ) // Retenção - IRRF
    aAdd( aStl, oSN08Num ) // Retenção - CSLL
    aAdd( aStl, oSN08Num ) // Retenção - PIS
    aAdd( aStl, oSN08Num ) // Retenção - Cofins
    aAdd( aStl, oSN07Txt ) // Vazio 2
    aAdd( aStl, oSN08Num ) // Líquido

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
cQuery += " 	E1_FILIAL "+ CRLF
cQuery += " 	,E1_EMPFAT "+ CRLF
cQuery += " 	,E1_PREFIXO "+ CRLF
cQuery += " 	,E1_NUM "+ CRLF
cQuery += " 	,E1_PARCELA "+ CRLF
cQuery += " 	,E1_TIPO "+ CRLF
cQuery += " 	,E1_CLIENTE "+ CRLF
cQuery += " 	,E1_LOJA "+ CRLF
cQuery += " 	,A1_NOME "+ CRLF
cQuery += " 	,A1_NREDUZ "+ CRLF
cQuery += " 	,A1_PESSOA "+ CRLF
cQuery += " 	,A1_CGC "+ CRLF
cQuery += " 	,E1_NATUREZ "+ CRLF
cQuery += " 	,E1_VALOR "+ CRLF
cQuery += " 	,E1_EMISSAO "+ CRLF
cQuery += " 	,E1_VENCTO "+ CRLF
cQuery += " 	,E1_VENCREA "+ CRLF
cQuery += " 	,E1_HIST "+ CRLF
cQuery += " 	,E1_BAIXA "+ CRLF
cQuery += " 	,E1_IRRF "+ CRLF
cQuery += " 	,E1_ISS "+ CRLF
cQuery += " 	,E1_CSLL "+ CRLF
cQuery += " 	,E1_COFINS "+ CRLF
cQuery += " 	,E1_PIS "+ CRLF
cQuery += " 	,E1_SALDO "+ CRLF
cQuery += " 	,E1_INSS "+ CRLF
cQuery += " 	,E1_VRETIRF "+ CRLF
cQuery += " 	,E1_PROPOS "+ CRLF
cQuery += " 	,E1_VALJUR "+ CRLF
cQuery += " 	,E1_PORCJUR "+ CRLF
cQuery += " 	,E1_DESCONT "+ CRLF
cQuery += " 	,E1_MULTA "+ CRLF
cQuery += " 	,E1_JUROS "+ CRLF
cQuery += " 	,E1_VALLIQ "+ CRLF
cQuery += " 	,E1_VENCORI "+ CRLF
cQuery += " 	,E1_DESCFIN "+ CRLF
cQuery += " 	,E1_ACRESC "+ CRLF
cQuery += " 	,E1_SDACRES "+ CRLF
cQuery += " 	,E1_VRETISS "+ CRLF
cQuery += " 	,E1_RATFIN "+ CRLF
cQuery += " 	,E1_CCUSTO "+ CRLF
cQuery += " 	,E1_XDTREC "+ CRLF
cQuery += " 	,E1_XNUMNFS "+ CRLF
cQuery += " 	,EV_NATUREZ "+ CRLF
cQuery += "     ,ED_DESCRIC "+ CRLF
cQuery += " 	,EV_VALOR "+ CRLF
cQuery += " 	,EV_PERC "+ CRLF
cQuery += " 	,EZ_CCUSTO "+ CRLF
cQuery += " 	,CTT_DESC01 "+ CRLF
cQuery += "     ,ED_DESCRIC "+ CRLF
cQuery += " 	,EZ_VALOR "+ CRLF
cQuery += " 	,EZ_PERC,E1_HIST "+ CRLF
    
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
cQuery += " 	ON SEV.EV_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND SEV.EV_PREFIXO = SE1.E1_PREFIXO "+ CRLF
cQuery += " 	AND SEV.EV_NUM = SE1.E1_NUM "+ CRLF
cQuery += " 	AND SEV.EV_PARCELA = SE1.E1_PARCELA "+ CRLF
cQuery += " 	AND SEV.EV_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += " 	AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SEZ")+" SEZ (NOLOCK) "+ CRLF
cQuery += " 	ON SEZ.EZ_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND SEZ.EZ_PREFIXO = SE1.E1_PREFIXO "+ CRLF
cQuery += " 	AND SEZ.EZ_NUM = SE1.E1_NUM "+ CRLF
cQuery += " 	AND SEZ.EZ_PARCELA = SE1.E1_PARCELA "+ CRLF
cQuery += " 	AND SEZ.EZ_TIPO = SE1.E1_TIPO "+ CRLF
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
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_XNUMNFS <> ' ' "+ CRLF

If !Empty(cPrefixo)
    cQuery += " 	AND SE1.E1_PREFIXO = '"+cPrefixo+"' "+ CRLF
EndIf

If !Empty(cNumIni) .Or. !Empty(cNumFim) 
    cQuery += " 	AND SE1.E1_NUM BETWEEN '"+cNumIni+"' AND '"+cNumFim+"' "+ CRLF
EndIf

If !Empty(cNfsIni) .Or. !Empty(cNfsFim) 
    cQuery += " 	AND SE1.E1_XNUMNFS BETWEEN '"+cNfsIni+"' AND '"+cNfsFim+"' "+ CRLF
EndIf

If !Empty(dNfsIni) .Or. !Empty(dNfsFim) 
    cAuxIni := Transform(DToS(dNfsIni), "@R 9999-99-99") + "T00:00:00"
    cAuxFim := Transform(DToS(dNfsFim), "@R 9999-99-99") + "T99:99:99"
    cQuery += " 	AND SE1.E1_XDTREC BETWEEN '"+cAuxIni+"' AND '"+cAuxFim+"' "+ CRLF
EndIf

If !Empty(cCliIni) .Or. !Empty(cCliFim) 
    cQuery += " 	AND SE1.E1_CLIENTE BETWEEN '"+cCliIni+"' AND '"+cCliFim+"' "+ CRLF
EndIf

cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	E1_XNUMNFS "+ CRLF
cQuery += " 	,EV_NATUREZ "+ CRLF
cQuery += " 	,EZ_CCUSTO "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL03.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
