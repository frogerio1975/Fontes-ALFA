#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"44.00"  //Altura da coluna do texto explicativo para Fluxo Mensal
#DEFINE HeightRowCab2 	"34.00"  //Altura da coluna do texto explicativo para Fluxo Semanal
#DEFINE HeightRowCab3 	"24.00"  //Altura da coluna do texto explicativo para Fluxo Diário

#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

// Mes Abreviado
Static aMesAbr := { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" }

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL06
Relatório de Demonstrativo de Resultado.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL06()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Demonstrativo de Resultado"
Local cNome 	:= "RelatorioDRE-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de Demonstrativo de Resultado."
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
Private aVisao   := { "1=Natureza", "2=Centro Custo" }
Private aTipoRel := { "1=Mensal", "2=Anual" }
Private aModelo  := { "1=Competencia", "2=Caixa" }
Private cEmpFat  := "1"
Private cVisao   := "1"
Private cTipoRel := "1"
Private cModelo  := "1"
Private dPerIni  := CriaVar("E1_EMISSAO",.F.)
Private dPerFim  := CriaVar("E1_EMISSAO",.F.)
Private aPeriodo := {}

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat , 50, ".F.", .T.} )
AADD( aBoxParam, {2,"Visão Por"       , cVisao    , aVisao  , 50, ".F.", .T.} )
AADD( aBoxParam, {2,"Tipo Relatório"  , cTipoRel  , aTipoRel, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Período DE"      , dPerIni   , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {1,"Período ATE"     , dPerFim   , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {2,"Modelo"          , cModelo  , aModelo, 80, ".F.", .T.} )

If ParamBox(aBoxParam,"Parametros - Demonstrativo de Resultado",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cVisao   := aRetParam[2]
    cTipoRel := aRetParam[3]
    dPerIni  := aRetParam[4]
    dPerFim  := aRetParam[5]
    cModelo  := aRetParam[6]

    RetPeriodo(cTipoRel, dPerIni, dPerFim, @aPeriodo)

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

oXml:AddRow(, {"Empresa"         , aEmpFat[Val(cEmpFat)]     }, aStl)
oXml:AddRow(, {"Visão Por"       , aVisao[Val(cVisao)]       }, aStl)
oXml:AddRow(, {"Tipo Relatório"  , aTipoRel[Val(cTipoRel)]   }, aStl)
oXml:AddRow(, {"Período DE"      , DToC(dPerIni)             }, aStl)
oXml:AddRow(, {"Período ATE"     , DToC(dPerFim)             }, aStl)
oXml:AddRow(, {"Modelo"          , aModelo[Val(cModelo)]     }, aStl)

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
Local cPicture  := IIF(cVisao=="1", PesqPict("SED", "ED_CODIGO"), PesqPict("CTT", "CTT_CUSTO"))
Local nX        := 0

//variaveis de estilo
Private oStlTit
Private oStlCab1

cTMP1 := LoadDados(aPeriodo)

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

oStlCab5 := CellStyle():New("StlCab5")
oStlCab5:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oStlCab5:setInterior("#FFFF00")
oStlCab5:setHAlign("LEFT")
oStlCab5:setVAlign("CENTER")
oStlCab5:setWrapText(.T.)

oStlCab6 := CellStyle():New("StlCab6")
oStlCab6:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oStlCab6:setInterior("#C6E0B4")
oStlCab6:setHAlign("LEFT")
oStlCab6:setVAlign("CENTER")
oStlCab6:setWrapText(.T.)

oStlCab7 := CellStyle():New("StlCab7")
oStlCab7:setFont("Arial", 9, "#FFFFFF", .T., .F., .F., .F.)
oStlCab7:setInterior("#0070C0")
oStlCab7:setHAlign("LEFT")
oStlCab7:setVAlign("CENTER")
oStlCab7:setWrapText(.T.)

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
oSN03Txt:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN03Txt:setInterior("#FFFFFF")
oSN03Txt:setHAlign("LEFT")
oSN03Txt:setVAlign("CENTER")

oSN04Txt := CellStyle():New("N04TXT")
oSN04Txt:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN04Txt:setInterior("#FFFFFF")
oSN04Txt:setHAlign("LEFT")
oSN04Txt:setVAlign("CENTER")

oSN05Txt := CellStyle():New("N05TXT")
oSN05Txt:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN05Txt:setInterior("#FFFFFF")
oSN05Txt:setHAlign("LEFT")
oSN05Txt:setVAlign("CENTER")
oSN05Txt:setIndent(1)

oSN06Txt := CellStyle():New("N06TXT")
oSN06Txt:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN06Txt:setInterior("#FFFFFF")
oSN06Txt:setHAlign("LEFT")
oSN06Txt:setVAlign("CENTER")
oSN06Txt:setIndent(2)

oSN05Num := CellStyle():New("N05NUM")
oSN05Num:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN05Num:setInterior("#FFFFFF")
oSN05Num:setHAlign("RIGHT")
oSN05Num:setVAlign("CENTER")
oSN05Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oSN06Num := CellStyle():New("N06NUM")
oSN06Num:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
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

oSN09Txt := CellStyle():New("N09TXT")
oSN09Txt:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN09Txt:setInterior("#FFFFFF")
oSN09Txt:setBorder("TOP"	, "Continuous", 1, .T., "#000000")
oSN09Txt:setBorder("BOTTOM"	, "Continuous", 1, .T., "#000000")
oSN09Txt:setHAlign("RIGHT")
oSN09Txt:setVAlign("CENTER")

oSN10Num := CellStyle():New("N10NUM")
oSN10Num:setFont("Arial", 8, "#000000", .T., .F., .F., .F.)
oSN10Num:setInterior("#FFFFFF")
oSN10Num:setBorder("TOP"	, "Continuous", 1, .T., "#000000")
oSN10Num:setBorder("BOTTOM"	, "Continuous", 1, .T., "#000000")
oSN10Num:setHAlign("RIGHT")
oSN10Num:setVAlign("CENTER")
oSN10Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oSN11Txt := CellStyle():New("N11TXT")
oSN11Txt:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN11Txt:setInterior("#FFFFFF")
oSN11Txt:setHAlign("RIGHT")
oSN11Txt:setVAlign("CENTER")

oSN12Num := CellStyle():New("N12NUM")
oSN12Num:setFont("Arial", 8, "#000000", .F., .F., .F., .F.)
oSN12Num:setInterior("#FFFFFF")
oSN12Num:setHAlign("RIGHT")
oSN12Num:setVAlign("CENTER")
oSN12Num:setNumberFormat("_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;&quot;\ \-\ &quot;&quot;_);_(@_)")

oXml:setFolder(nFolder)
nFolder++
oXml:setFolderName("Demonstrativo de Resultado")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "49.5" ) // Código
aAdd( aColSize, "200" ) // Descrição
aAdd( aColSize, "0" ) // Tipo

For nX := 1 To Len(aPeriodo)
    aAdd( aColSize, "60" )
Next nX

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Demonstrativo de Resultado" ) // Código
aAdd( aCabTit, "" ) // Descrição
aAdd( aCabTit, "" ) // Tipo

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Cliente
aAdd( aTitStl, oStlTit ) // Tipo

For nX := 1 To Len(aPeriodo)
    aAdd( aCabTit, "" )
    aAdd( aTitStl, oStlTit )
Next nX

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 2)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Código" ) // Código
aAdd( aCabDad, "Descrição" ) // Descrição
aAdd( aCabDad, "Tipo" ) // Tipo

aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Código
aAdd( aCabStl, oStlCab1 ) // Descrição
aAdd( aCabStl, oStlCab1 ) // Tipo

For nX := 1 To Len(aPeriodo)
    aAdd( aCabDad, aPeriodo[nX][2] )
    aAdd( aCabStl, oStlCab1 )
Next nX

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, Transform((cTMP1)->CODIGO, cPicture) ) // Código
    aAdd( aRowDad, AllTrim((cTMP1)->DESCRI) ) // Descrição
    aAdd( aRowDad, IIF((cTMP1)->FILHOS == 0, (cTMP1)->COND, "") ) // Tipo

    If cVisao == "1"
        DO CASE
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 2
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN03Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 5
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN05Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 7
                aAdd( aStl, oSN04Txt ) // Código
                aAdd( aStl, oSN06Txt ) // Descrição
                aAdd( aStl, oSN04Txt ) // Tipo
            OTHERWISE
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN03Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
        ENDCASE
    Else
        DO CASE
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 1
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN03Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 3
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN05Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
            CASE Len(AllTrim((cTMP1)->CODIGO)) == 5
                aAdd( aStl, oSN04Txt ) // Código
                aAdd( aStl, oSN06Txt ) // Descrição
                aAdd( aStl, oSN04Txt ) // Tipo
            OTHERWISE
                aAdd( aStl, oSN03Txt ) // Código
                aAdd( aStl, oSN03Txt ) // Descrição
                aAdd( aStl, oSN03Txt ) // Tipo
        ENDCASE
    EndIf
    
        
    If (cTMP1)->FILHOS > 0
        For nX := 1 To Len(aPeriodo)
            aAdd( aRowDad, "=SUBTOTAL(9,R[1]C:R["+cValToChar((cTMP1)->FILHOS)+"]C)" )
            aAdd( aStl, oSN05Num )
        Next nX
    Else
        For nX := 1 To Len(aPeriodo)
            cCampo := "CPO_" + StrZero(nX,4)
            aAdd( aRowDad, &(cTMP1+"->"+cCampo) )
            aAdd( aStl, oSN06Num )
        Next nX
    EndIf

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

////////////////////////////////////////////////////////////////////////////////////////////

oXML:SkipLine(HeightRowItem1)
nTotLin++

////////////////////////////////////////////////////////////////////////////////////////////

If nTotLin > 0

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "Resultado" ) // Código
    aAdd( aRowDad, "" ) // Descrição
    aAdd( aRowDad, "" ) // Tipo
    
    aAdd( aStl, oSN09Txt ) // Código
    aAdd( aStl, oSN09Txt ) // Descrição
    aAdd( aStl, oSN09Txt ) // Tipo
    
    For nX := 1 To Len(aPeriodo)    
        aAdd( aRowDad, "=SUBTOTAL(9,R[-"+cValToChar(nTotLin)+"]C:R[-2]C)" )
        aAdd( aStl, oSN10Num )
    Next nX

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    oXml:SetMerge( , , , 1)

    nTotLin++

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
Static Function LoadDados(aPeriodo)

Local cTMP1    := ""
Local cQuery   := ""
Local nX

Local cAuxIni := Transform(aPeriodo[1][1][1], "@R 9999-99-99") + "T00:00:00"
Local cAuxFim := Transform(ATail(aPeriodo)[1][2], "@R 9999-99-99") + "T99:99:99"

If cVisao == "1"
    ////////////////////////////////////////////////////////////////
    // Por Natureza
    ////////////////////////////////////////////////////////////////
    cQuery := " SELECT "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF
    cQuery += " 	,TAB.DESCRI "+ CRLF
    cQuery += " 	,TAB.COND "+ CRLF
    cQuery += " 	,MAX(TAB.FILHOS) AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo := "CPO_" + StrZero(nX,4)
        cQuery += " 	,SUM(TAB."+cCampo+") AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM ( "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	SED.ED_CODIGO   AS CODIGO "+ CRLF
    cQuery += " 	,SED.ED_DESCRIC AS DESCRI "+ CRLF
    cQuery += " 	,SED.ED_COND    AS COND "+ CRLF
    cQuery += " 	,(  SELECT COUNT(1) "+ CRLF
    cQuery += " 		FROM "+RetSqlName("SED")+" TOT (NOLOCK) "+ CRLF
    cQuery += " 		WHERE "+ CRLF
    cQuery += " 			TOT.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
    cQuery += " 			AND LEFT(TOT.ED_PAI,LEN(SED.ED_CODIGO)) = SED.ED_CODIGO "+ CRLF
    cQuery += " 			AND TOT.ED_XMOSREL = 'S' "+ CRLF
    cQuery += " 			AND TOT.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery += "  		) AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo := "CPO_" + StrZero(nX,4)
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
    cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
    cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " UNION ALL "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	SED.ED_CODIGO "+ CRLF
    cQuery += " 	,SED.ED_DESCRIC "+ CRLF
    cQuery += " 	,SED.ED_COND "+ CRLF
    cQuery += " 	,0 AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo  := "CPO_" + StrZero(nX,4)
        cPerIni := Transform(aPeriodo[nX][1][1], "@R 9999-99-99") + "T00:00:00"
        cPerFim := Transform(aPeriodo[nX][1][2], "@R 9999-99-99") + "T99:99:99"
        cQuery += " 	,SUM(CASE WHEN SE1.E1_XDTREC BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN E1_VALOR ELSE 0 END) AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

    cQuery += " LEFT JOIN "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
    cQuery += " 	ON SEV.EV_FILIAL = SE1.E1_FILIAL "+ CRLF
    cQuery += " 	AND SEV.EV_PREFIXO = SE1.E1_PREFIXO "+ CRLF
    cQuery += " 	AND SEV.EV_NUM = SE1.E1_NUM "+ CRLF
    cQuery += " 	AND SEV.EV_PARCELA = SE1.E1_PARCELA "+ CRLF
    cQuery += " 	AND SEV.EV_TIPO = SE1.E1_TIPO "+ CRLF
    cQuery += " 	AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
    cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
    cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF
    cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
    cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
    cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE1.E1_XDTREC BETWEEN '"+cAuxIni+"' AND '"+cAuxFim+"' "+ CRLF
    cQuery += " 	AND SE1.E1_XNUMNFS <> ' ' "+ CRLF
    cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	SED.ED_CODIGO "+ CRLF
    cQuery += " 	,SED.ED_DESCRIC "+ CRLF
    cQuery += " 	,SED.ED_COND "+ CRLF

    cQuery += " UNION ALL "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	SED.ED_CODIGO "+ CRLF
    cQuery += " 	,SED.ED_DESCRIC "+ CRLF
    cQuery += " 	,SED.ED_COND "+ CRLF
    cQuery += " 	,0 AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo  := "CPO_" + StrZero(nX,4)
        cPerIni := aPeriodo[nX][1][1]
        cPerFim := aPeriodo[nX][1][2]
        cQuery += " 	,SUM(CASE WHEN SE2.E2_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN E2_VALOR ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

    cQuery += " LEFT JOIN "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
    cQuery += " 	ON SEV.EV_FILIAL = SE2.E2_FILIAL "+ CRLF
    cQuery += " 	AND SEV.EV_PREFIXO = SE2.E2_PREFIXO "+ CRLF
    cQuery += " 	AND SEV.EV_NUM = SE2.E2_NUM "+ CRLF
    cQuery += " 	AND SEV.EV_PARCELA = SE2.E2_PARCELA "+ CRLF
    cQuery += " 	AND SEV.EV_TIPO = SE2.E2_TIPO "+ CRLF
    cQuery += " 	AND SEV.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
    cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
    cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
    cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
    cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
    cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE2.E2_EMISSAO BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
    cQuery += " 	AND SE2.E2_NUMNOTA <> ' ' "+ CRLF
    cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	SED.ED_CODIGO "+ CRLF
    cQuery += " 	,SED.ED_DESCRIC "+ CRLF
    cQuery += " 	,SED.ED_COND "+ CRLF

    cQuery += " ) TAB "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF
    cQuery += " 	,TAB.DESCRI "+ CRLF
    cQuery += " 	,TAB.COND "+ CRLF

    cQuery += " ORDER BY "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF

Else
    ////////////////////////////////////////////////////////////////
    // Por Centro de Custo
    ////////////////////////////////////////////////////////////////
    cQuery := " SELECT "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF
    cQuery += " 	,TAB.DESCRI "+ CRLF
    cQuery += " 	,' ' AS COND "+ CRLF
    cQuery += " 	,MAX(TAB.FILHOS) AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo := "CPO_" + StrZero(nX,4)
        cQuery += " 	,SUM(TAB."+cCampo+") AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM ( "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	CTT.CTT_CUSTO   AS CODIGO "+ CRLF
    cQuery += " 	,CTT.CTT_DESC01 AS DESCRI "+ CRLF
    cQuery += " 	,(  SELECT COUNT(1) "+ CRLF
    cQuery += " 		FROM "+RetSqlName("CTT")+" TOT (NOLOCK) "+ CRLF
    cQuery += " 		WHERE "+ CRLF
    cQuery += " 			TOT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
    cQuery += " 			AND LEFT(TOT.CTT_CCSUP,LEN(CTT.CTT_CUSTO)) = CTT.CTT_CUSTO "+ CRLF
    cQuery += " 			AND TOT.CTT_XMOSRE = 'S' "+ CRLF
    cQuery += " 			AND TOT.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery += "  		) AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo := "CPO_" + StrZero(nX,4)
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("CTT")+" CTT (NOLOCK) "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
    cQuery += " 	AND CTT.CTT_XMOSRE = 'S' "+ CRLF
    cQuery += " 	AND CTT.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " UNION ALL "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	CTT.CTT_CUSTO "+ CRLF
    cQuery += " 	,CTT.CTT_DESC01 "+ CRLF
    cQuery += " 	,0 AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo  := "CPO_" + StrZero(nX,4)
        cPerIni := Transform(aPeriodo[nX][1][1], "@R 9999-99-99") + "T00:00:00"
        cPerFim := Transform(aPeriodo[nX][1][2], "@R 9999-99-99") + "T99:99:99"
        cQuery += " 	,SUM(CASE WHEN SE1.E1_XDTREC BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN E1_VALOR ELSE 0 END) AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

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

    cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT (NOLOCK) "+ CRLF
    cQuery += " 	ON CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
    cQuery += " 	AND CTT.CTT_CUSTO = SEZ.EZ_CCUSTO "+ CRLF
    cQuery += " 	AND CTT.CTT_XMOSRE = 'S' "+ CRLF
    cQuery += " 	AND CTT.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
    cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE1.E1_XDTREC BETWEEN '"+cAuxIni+"' AND '"+cAuxFim+"' "+ CRLF
    cQuery += " 	AND SE1.E1_XNUMNFS <> ' ' "+ CRLF
    cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	CTT.CTT_CUSTO "+ CRLF
    cQuery += " 	,CTT.CTT_DESC01 "+ CRLF
	
    cQuery += " UNION ALL "+ CRLF

    cQuery += " SELECT "+ CRLF
    cQuery += " 	CTT.CTT_CUSTO "+ CRLF
    cQuery += " 	,CTT.CTT_DESC01 "+ CRLF
    cQuery += " 	,0 AS FILHOS "+ CRLF

    For nX := 1 To Len(aPeriodo)
        cCampo  := "CPO_" + StrZero(nX,4)
        cPerIni := aPeriodo[nX][1][1]
        cPerFim := aPeriodo[nX][1][2]
        cQuery += " 	,SUM(CASE WHEN SE2.E2_EMISSAO BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN SEZ.EZ_VALOR ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
    Next nX

    cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

    cQuery += " INNER JOIN "+RetSqlName("SEV")+" SEV (NOLOCK) "+ CRLF
    cQuery += " 	ON SEV.EV_FILIAL = SE2.E2_FILIAL "+ CRLF
    cQuery += " 	AND SEV.EV_PREFIXO = SE2.E2_PREFIXO "+ CRLF
    cQuery += " 	AND SEV.EV_NUM = SE2.E2_NUM "+ CRLF
    cQuery += " 	AND SEV.EV_PARCELA = SE2.E2_PARCELA "+ CRLF
    cQuery += " 	AND SEV.EV_TIPO = SE2.E2_TIPO "+ CRLF
    cQuery += " 	AND SEV.D_E_L_E_T_ = ' ' "+ CRLF
	
	cQuery += " INNER JOIN "+RetSqlName("SEZ")+" SEZ (NOLOCK) "+ CRLF
	cQuery += " 	ON SEZ.EZ_FILIAL = SE2.E2_FILIAL "+ CRLF
	cQuery += " 	AND SEZ.EZ_PREFIXO = SE2.E2_PREFIXO "+ CRLF
	cQuery += " 	AND SEZ.EZ_NUM = SE2.E2_NUM "+ CRLF
	cQuery += " 	AND SEZ.EZ_PARCELA = SE2.E2_PARCELA "+ CRLF
	cQuery += " 	AND SEZ.EZ_TIPO = SE2.E2_TIPO "+ CRLF
	cQuery += " 	AND SEZ.EZ_NATUREZ = SEV.EV_NATUREZ "+ CRLF
	cQuery += " 	AND SEZ.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT (NOLOCK) "+ CRLF
    cQuery += " 	ON CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+ CRLF
    cQuery += " 	AND CTT.CTT_CUSTO = SEZ.EZ_CCUSTO "+ CRLF
    cQuery += " 	AND CTT.CTT_XMOSRE = 'S' "+ CRLF
    cQuery += " 	AND CTT.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " WHERE "+ CRLF
    cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
    cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE2.E2_EMISSAO BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
    cQuery += " 	AND SE2.E2_NUMNOTA <> ' ' "+ CRLF
    cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	CTT.CTT_CUSTO "+ CRLF
    cQuery += " 	,CTT.CTT_DESC01 "+ CRLF

    cQuery += " ) TAB "+ CRLF

    cQuery += " GROUP BY "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF
    cQuery += " 	,TAB.DESCRI "+ CRLF

    cQuery += " ORDER BY "+ CRLF
    cQuery += " 	TAB.CODIGO "+ CRLF
EndIf
    
// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL06.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL06
Relatório de Demonstrativo de Resultado.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPeriodo(cTipoRel, dPerIni, dPerFim, aPeriodo)

DO CASE
    CASE cTipoRel == "1" // Mensal

        nMes := Month(dPerIni)
        nAno := Year(dPerIni)
        cPerFim := SubStr(DToS(dPerFim),1,6)
        While StrZero(nAno,4) + StrZero(nMes,2) <= cPerFim
            dMesIni := SToD(StrZero(nAno,4) + StrZero(nMes,2) + "01")
            dMesFim := LastDay(dMesIni)
            AADD( aPeriodo, { {DToS(dMesIni), DToS(dMesFim)}, aMesAbr[nMes] + "/" + StrZero(nAno,4) } )
            nMes++
            If nMes > 12
                nMes := 1
                nAno++
            EndIf
        EndDo

    CASE cTipoRel == "2" // Anual

        nAnoIni := Year(dPerIni)
        nAnoFim := Year(dPerFim)
        While nAnoIni <= nAnoFim
            cAnoIni := StrZero(nAnoIni,4) + "0101"
            cAnoFim := StrZero(nAnoIni,4) + "1231"
            AADD( aPeriodo, { {cAnoIni, cAnoFim}, StrZero(nAnoIni,4) } )
            nAnoIni++
        EndDo

ENDCASE

Return .T.
