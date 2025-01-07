#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"
#DEFINE HRSubTitulo "80.00"


#DEFINE HeightRowCab1 	"44.00"  //Altura da coluna do texto explicativo para Fluxo Mensal
#DEFINE HeightRowCab2 	"34.00"  //Altura da coluna do texto explicativo para Fluxo Semanal
#DEFINE HeightRowCab3 	"24.00"  //Altura da coluna do texto explicativo para Fluxo Diário

#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

// Mes Abreviado
Static aMesAbr := { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" }

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL05
Relatório de Fluxo de Caixa.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL05()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Fluxo de Caixa"
Local cNome 	:= "RelFluxoDeCaixa-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de Fluxo de Caixa."
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
Private aEmpFat  := { "1=ALFA(07)", "2=MOOVE", "3=GNP", "4=ALFA(24)","5=Campinas","6=Colaboração","0-TODAS" }
Private aTipoRel := { "1=Diario", "2=Semanal", "3=Mensal" }
Private cEmpFat  := "1"
Private cTipoRel := "3"
Private dPerIni  := FirstDay(dDataBase)//CriaVar("E1_EMISSAO",.F.)
Private dPerFim  := LastDay(dDatabase)//CriaVar("E1_EMISSAO",.F.)
Private aPeriodo := {}
Private aModelo  := { "1=Competencia", "2=Caixa","3-Combinado"}
Private cModelo  := "1"

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat , 50, ".F.", .T.} )
AADD( aBoxParam, {2,"Tipo Relatório"  , cTipoRel  , aTipoRel, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Período DE"      , dPerIni   , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {1,"Período ATE"     , dPerFim   , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {2,"Modelo"          , cModelo   , aModelo, 80, ".F.", .T.} )

If ParamBox(aBoxParam,"Parametros - Fluxo de Caixa",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cTipoRel := aRetParam[2]
    dPerIni  := aRetParam[3]
    dPerFim  := aRetParam[4]
    cModelo  := aRetParam[5]

    RetPeriodo(cTipoRel, dPerIni, dPerFim, @aPeriodo)

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

oXml:AddRow(, {"Empresa"         , aEmpFat[Val(cEmpFat)]     }, aStl)
oXml:AddRow(, {"Tipo Relatório"  , aTipoRel[Val(cTipoRel)]   }, aStl)
oXml:AddRow(, {"Período DE"      , DToC(dPerIni)        }, aStl)
oXml:AddRow(, {"Período ATE"     , DToC(dPerFim)        }, aStl)
oXml:AddRow(, {"Modelo"          , aModelo[Val(cModelo)]   }, aStl)

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
Local nX        := 0
Local nAltLin   := 0
Local nPeriodos := 0
Local nTotal    := 0
Local nReg      := 0
Local nTotReg   :=0

//variaveis de estilo
Private oStlTit
Private oStlCab1

If (cModelo == "1") //Regime de Competencia
    cTMP1 := CompetenciaLoadDados(aPeriodo)
ElseIf(cModelo == "2") //Regime de Caixa
    cTMP1 := CaixaLoadDados(aPeriodo) 
Else //Combinado (Caixa+Competencia)
    cTMP1 := LoadDados(aPeriodo) 
EndIf


/*Style Titulo*/
oStlTit := CellStyle():New("StlTit")
oStlTit:setFont("Arial", 12, "#4A4A4A", .T., .F., .F., .F.)
oStlTit:setInterior("#FFA500")
oStlTit:setHAlign("CENTER")
oStlTit:setVAlign("CENTER")
oStlTit:setWrapText(.T.)

oStlTit2 := CellStyle():New("StlTit2")
oStlTit2:setFont("Arial", 8, "#4A4A4A", .T., .F., .F., .F.)
oStlTit2:setInterior("#FFFFFF")
oStlTit2:setHAlign("CENTER")
oStlTit2:setVAlign("CENTER")
oStlTit2:setNumberFormat("Medium Date")

oStlTit3 := CellStyle():New("StlTit3")
oStlTit3:setFont("Arial", 8, "#4A4A4A", .T., .T., .F., .F.)
oStlTit3:setInterior("#FFA500")
oStlTit3:setHAlign("LEFT")
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
oXml:setFolderName("Fluxo de Caixa")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "60" )  // Código
aAdd( aColSize, "200" ) // Descrição
aAdd( aColSize, "0" )   // "Espaco em Branco"

nPeriodos:= Len(aPeriodo)
For nX := 1 To nPeriodos
    aAdd( aColSize, "60" )
Next nX

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

//Ajusta o cabecalho de acordo com a quantidade de colunas
aCabTit := {}

cTexto:=  "Relatório de Fluxo de Caixa" + " ( por " + aModelo[Val(cModelo)] + " )" 
aAdd( aCabTit, cTexto) // Código
aAdd( aCabTit, "" ) // Descrição
aAdd( aCabTit, "" ) // Espaco

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Código
aAdd( aTitStl, oStlTit ) // Descricao
aAdd( aTitStl, oStlTit ) // Espaco

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)
//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 3+nPeriodos)

//Adiciona o subtitulo com a explicacao
cTexto     := "O Fluxo de Caixa por Competência é uma forma de apurar e controlar o fluxo financeiro de uma empresa com base no regime de competência, ou seja, registrando receitas e despesas no momento em que elas são geradas, independentemente de quando o dinheiro realmente entra ou sai do caixa."
aCabTit[1] := cTexto
aTitStl[1] := oStlTit3

If (nPeriodos == 1)
    nAltLin:= HeightRowCab1
ElseIf (nPeriodos <= 4)
    nAltLin:= HeightRowCab2
Else
    nAltLin:= HeightRowCab3
Endif


oXML:AddRow( nAltLin, aCabTit, aTitStl)
oXml:SetMerge( , , , 3+nPeriodos)
////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Código" ) // Código
aAdd( aCabDad, "Descrição" ) // Descrição
aAdd( aCabDad, "Tipo" ) // Tipo


aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Código
aAdd( aCabStl, oStlCab1 ) // Descrição
aAdd( aCabStl, oStlCab1 ) // Tipo

For nX := 1 To nPeriodos
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    lHistorico := SToD(cPerFim) < dDataBase
    If lHistorico
        aAdd( aCabDad, aPeriodo[nX][2] )
        aAdd( aCabStl, oStlCab1 )
    Else
        aAdd( aCabDad, aPeriodo[nX][2] )
        aAdd( aCabStl, oStlCab1 )
    EndIf
Next nX

aAdd( aCabDad, "TOTAL" ) // Tipo
aAdd( aCabStl, oStlCab7 ) // Total da Linha

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

    aAdd( aRowDad, Transform((cTMP1)->ED_CODIGO, cPictNat) ) // Código
    aAdd( aRowDad, AllTrim((cTMP1)->ED_DESCRIC) ) // Descrição
    aAdd( aRowDad, IIF((cTMP1)->FILHOS == 0, (cTMP1)->ED_COND, "") ) // Tipo

    DO CASE
        CASE Len(AllTrim((cTMP1)->ED_CODIGO)) == 2
            aAdd( aStl, oSN03Txt ) // Código
            aAdd( aStl, oSN03Txt ) // Descrição
            aAdd( aStl, oSN03Txt ) // Tipo
        CASE Len(AllTrim((cTMP1)->ED_CODIGO)) == 4
            aAdd( aStl, oSN03Txt ) // Código
            aAdd( aStl, oSN05Txt ) // Descrição
            aAdd( aStl, oSN03Txt ) // Tipo
        CASE Len(AllTrim((cTMP1)->ED_CODIGO)) == 6
            aAdd( aStl, oSN04Txt ) // Código
            aAdd( aStl, oSN06Txt ) // Descrição
            aAdd( aStl, oSN04Txt ) // Tipo
        OTHERWISE
            aAdd( aStl, oSN03Txt ) // Código
            aAdd( aStl, oSN03Txt ) // Descrição
            aAdd( aStl, oSN03Txt ) // Tipo
    ENDCASE
    
        
    If (cTMP1)->FILHOS > 0
        For nX := 1 To Len(aPeriodo)+1
            aAdd( aRowDad, "=SUBTOTAL(9,R[1]C:R["+cValToChar((cTMP1)->FILHOS)+"]C)" )
            aAdd( aStl, oSN05Num )
        Next nX
    Else
        nTotal:= 0
        For nX := 1 To Len(aPeriodo)
            cCampo := "CPO_" + StrZero(nX,4)
            aAdd( aRowDad, &(cTMP1+"->"+cCampo) )
            aAdd( aStl, oSN06Num )
            nTotal+= &(cTMP1+"->"+cCampo)
        Next nX

        aAdd( aRowDad, nTotal )
        aAdd( aStl, oSN05Num )
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
//	aRowDad	:= {}
//	aStl 	:= {}
//
//    aAdd( aRowDad, "Saldo Inicial" ) // Código
//    aAdd( aRowDad, "" ) // Descrição
//    aAdd( aRowDad, "" ) // Tipo
//    
//    aAdd( aStl, oSN09Txt ) // Código
//    aAdd( aStl, oSN09Txt ) // Descrição
//    aAdd( aStl, oSN09Txt ) // Tipo
//    
//    For nX := 1 To Len(aPeriodo)
//
//        If nX == 1 
//            aAdd( aRowDad, RetSldIni(SToD(aPeriodo[nX][1][1])) ) // Saldo Inicial
//        Else
//            aAdd( aRowDad, "=R[3]C[-1]" )
//        EndIf
//
//        aAdd( aStl, oSN10Num )
//    Next nX
//
//	oXML:AddRow( HeightRowItem1, aRowDad, aStl )
//
//    oXml:SetMerge( , , , 1)
//
//    nTotLin++

    ////////////////////////////////////////////////////////////////////////////////////////////

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "Receitas" ) // Código
    aAdd( aRowDad, "" ) // Descrição
    aAdd( aRowDad, "R" ) // Tipo

    aAdd( aStl, oSN11Txt ) // Código
    aAdd( aStl, oSN11Txt ) // Descrição
    aAdd( aStl, oSN11Txt ) // Tipo
    
    For nX := 1 To Len(aPeriodo)+1
        aAdd( aRowDad, "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C:R[-3]C,R[-"+cValToChar(nTotLin)+"]C[-"+cValToChar(nX)+"]:R[-3]C[-"+cValToChar(nX)+"],RC[-"+cValToChar(nX)+"])" )
        aAdd( aStl, oSN12Num )
    Next nX

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    oXml:SetMerge( , , , 1)

    nTotLin++

    ////////////////////////////////////////////////////////////////////////////////////////////

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "Custos e Depesas" ) // Código
    aAdd( aRowDad, "" ) // Descrição
    aAdd( aRowDad, "D" ) // Tipo

    aAdd( aStl, oSN11Txt ) // Código
    aAdd( aStl, oSN11Txt ) // Descrição
    aAdd( aStl, oSN11Txt ) // Tipo
    
    For nX := 1 To Len(aPeriodo)+1
        aAdd( aRowDad, "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C:R[-4]C,R[-"+cValToChar(nTotLin)+"]C[-"+cValToChar(nX)+"]:R[-4]C[-"+cValToChar(nX)+"],RC[-"+cValToChar(nX)+"])" )
        aAdd( aStl, oSN12Num )
    Next nX

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    oXml:SetMerge( , , , 1)

    nTotLin++

    ////////////////////////////////////////////////////////////////////////////////////////////

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "Saldo Final" ) // Código
    aAdd( aRowDad, "" ) // Descrição
    aAdd( aRowDad, "" ) // Tipo

    aAdd( aStl, oSN09Txt ) // Código
    aAdd( aStl, oSN09Txt ) // Descrição
    aAdd( aStl, oSN09Txt ) // Tipo
    
    For nX := 1 To Len(aPeriodo)+1
        aAdd( aRowDad, "=SUM(R[-3]C:R[-1]C)" )
        aAdd( aStl, oSN10Num )
    Next nX

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    oXml:SetMerge( , , , 1)

    nTotLin++

    ////////////////////////////////////////////////////////////////////////////////////////////

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

cQuery := " SELECT "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF
cQuery += " 	,MAX(TAB.FILHOS) AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo := "CPO_" + StrZero(nX,4)
    cQuery += " 	,SUM(TAB."+cCampo+") AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM ( "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
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
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    lHistorico := SToD(cPerFim) < dDataBase
    If lHistorico
        cQuery += " 	,SUM(CASE WHEN SE5.E5_DATA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN SE5.E5_VALOR * 1 ELSE 0 END) AS "+cCampo+" "+ CRLF
    Else
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    EndIf
Next nX

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " 	ON SE5.E5_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = SE1.E1_NUM "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = SE1.E1_PARCELA "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SE5.E5_RECPAG = 'R' "+ CRLF
cQuery += " 	AND SE5.E5_DATA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF 
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND SE1.E1_FATURA IN ('','NOTFAT') "+ CRLF
cQuery += " 	AND SE1.E1_PORTADO <> '999' "+ CRLF
cQuery += " 	AND SE1.E1_CLIENTE NOT IN ('000080','022441') "+ CRLF
cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    lHistorico := SToD(cPerFim) < dDataBase
    If lHistorico
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    Else
        cQuery += " 	,SUM(CASE WHEN SE1.E1_VENCREA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN (SE1.E1_VALOR - (SE1.E1_ISS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_IRRF + SE1.E1_CSLL)) * 1 ELSE 0 END) AS "+cCampo+" "+ CRLF
    EndIf
Next nX

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_VENCREA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA = ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND SE1.E1_FATURA IN ('','NOTFAT') "+ CRLF
cQuery += " 	AND SE1.E1_PORTADO <> '999' "+ CRLF
cQuery += " 	AND SE1.E1_CLIENTE NOT IN ('000080','022441') "+ CRLF
cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    lHistorico := SToD(cPerFim) < dDataBase
    If lHistorico
        cQuery += " 	,SUM(CASE WHEN SE5.E5_DATA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN SE5.E5_VALOR * 1 ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
    Else
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    EndIf
Next nX

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " 	ON SE5.E5_FILIAL = SE2.E2_FILIAL "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = SE2.E2_NUM "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = SE2.E2_PARCELA "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = SE2.E2_TIPO "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND SE5.E5_RECPAG = 'P' "+ CRLF
cQuery += " 	AND SE5.E5_DATA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE2.E2_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    lHistorico := SToD(cPerFim) < dDataBase
    If lHistorico
        cQuery += " 	,0 AS "+cCampo+" "+ CRLF
    Else
        cQuery += " 	,SUM(CASE WHEN SE2.E2_VENCREA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN (SE2.E2_VALOR - (SE2.E2_VRETPIS + SE2.E2_VRETCOF + SE2.E2_VRETIRF + SE2.E2_VRETCSL)) * 1 ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
    EndIf
Next nX

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE2.E2_VENCREA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE2.E2_BAIXA = ' ' "+ CRLF
cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " ) TAB "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL05-COMBINADO.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1

//-------------------------------------------------------------------
/*/{Protheus.doc} CompetenciaLoadDados
Rotina para carregar os dados do relatorio via query. Regime de Competencia

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CompetenciaLoadDados(aPeriodo)

Local cTMP1    := ""
Local cQuery   := ""
Local nX

cQuery := " SELECT "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF
cQuery += " 	,MAX(TAB.FILHOS) AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo := "CPO_" + StrZero(nX,4)
    cQuery += " 	,SUM(TAB."+cCampo+") AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM ( "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
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
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    cQuery += " 	,SUM(CASE WHEN SE1.E1_VENCREA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN (SE1.E1_VALOR - (SE1.E1_ISS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_IRRF + SE1.E1_CSLL)) * 1 ELSE 0 END) AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_VENCREA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND SE1.E1_FATURA IN ('','NOTFAT') "+ CRLF
cQuery += " 	AND SE1.E1_PORTADO <> '999' "+ CRLF
cQuery += " 	AND SE1.E1_CLIENTE NOT IN ('000080','022441') "+ CRLF
cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    cQuery += " 	,SUM(CASE WHEN SE2.E2_VENCREA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN (SE2.E2_VALOR - (SE2.E2_VRETPIS + SE2.E2_VRETCOF + SE2.E2_VRETIRF + SE2.E2_VRETCSL)) * 1 ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE2.E2_VENCREA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " ) TAB "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL05-COMPETENCIA.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1


//-------------------------------------------------------------------
/*/{Protheus.doc} CaixaLoadDados
Rotina para carregar os dados do relatorio via query. Regime de Caixa

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CaixaLoadDados(aPeriodo)

Local cTMP1    := ""
Local cQuery   := ""
Local nX

cQuery := " SELECT "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF
cQuery += " 	,MAX(TAB.FILHOS) AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo := "CPO_" + StrZero(nX,4)
    cQuery += " 	,SUM(TAB."+cCampo+") AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM ( "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
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
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    cQuery += " 	,SUM(CASE WHEN SE5.E5_DATA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN SE5.E5_VALOR * 1 ELSE 0 END) AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " 	ON SE5.E5_FILIAL = SE1.E1_FILIAL "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = SE1.E1_NUM "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = SE1.E1_PARCELA "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = SE1.E1_TIPO "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SE5.E5_RECPAG = 'R' "+ CRLF
cQuery += " 	AND SE5.E5_DATA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF 
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	AND SE1.E1_FATURA IN ('','NOTFAT') "+ CRLF
cQuery += " 	AND SE1.E1_PORTADO <> '999' "+ CRLF
cQuery += " 	AND SE1.E1_CLIENTE NOT IN ('000080','022441') "+ CRLF
cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 	 SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF
cQuery += " 	,0 AS FILHOS "+ CRLF

For nX := 1 To Len(aPeriodo)
    cCampo  := "CPO_" + StrZero(nX,4)
    cPerIni := aPeriodo[nX][1][1]
    cPerFim := aPeriodo[nX][1][2]
    cQuery += " 	,SUM(CASE WHEN SE5.E5_DATA BETWEEN '"+cPerIni+"' AND '"+cPerFim+"' THEN SE5.E5_VALOR * 1 ELSE 0 END * (-1)) AS "+cCampo+" "+ CRLF
Next nX

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " 	ON SE5.E5_FILIAL = SE2.E2_FILIAL "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = SE2.E2_NUM "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = SE2.E2_PARCELA "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = SE2.E2_TIPO "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND SE5.E5_RECPAG = 'P' "+ CRLF
cQuery += " 	AND SE5.E5_DATA BETWEEN '"+aPeriodo[1][1][1]+"' AND '"+ATail(aPeriodo)[1][2]+"' "+ CRLF
cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF
cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
cQuery += " 	AND SED.ED_XMOSREL = 'S' "+ CRLF
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
cQuery += " 	AND SE2.E2_BAIXA <> ' ' "+ CRLF
cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	SED.ED_CODIGO "+ CRLF
cQuery += " 	,SED.ED_DESCRIC "+ CRLF
cQuery += " 	,SED.ED_COND "+ CRLF

cQuery += " ) TAB "+ CRLF

cQuery += " GROUP BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF
cQuery += " 	,TAB.ED_DESCRIC "+ CRLF
cQuery += " 	,TAB.ED_COND "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	TAB.ED_CODIGO "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL05-CAIXA.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
//-------------------------------------------------------------------
/*/{Protheus.doc} RetSldIni
Retorna ultimo saldo a partir da data informada.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSldIni(dDtRef)

Local cTMP1   := ""
Local cQuery  := ""
Local nSldIni := 0

cQuery := " SELECT TOP 1 "+ CRLF
cQuery += " 	TAB.E8_DTSALAT "+ CRLF
cQuery += " 	,TAB.E8_SALATUA "+ CRLF
cQuery += " FROM ( "+ CRLF
cQuery += " 	SELECT "+ CRLF
cQuery += " 		SE8.E8_DTSALAT "+ CRLF
cQuery += " 		,SUM(SE8.E8_SALATUA) AS E8_SALATUA "+ CRLF
cQuery += " 	FROM "+RetSqlName("SE8")+" SE8 (NOLOCK) "+ CRLF
cQuery += " 	WHERE "+ CRLF
cQuery += " 		SE8.E8_FILIAL = '"+xFilial("SE8")+"' "+ CRLF
cQuery += " 		AND SE8.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " 	GROUP BY "+ CRLF
cQuery += " 		SE8.E8_DTSALAT "+ CRLF
cQuery += " ) AS TAB "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	TAB.E8_DTSALAT < '"+DToS(dDtRef)+"' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	TAB.E8_DTSALAT DESC "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    nSldIni := (cTMP1)->E8_SALATUA
EndIf

(cTMP1)->(dbCloseArea())

Return nSldIni

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL05
Relatório de Fluxo de Caixa.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPeriodo(cTipoRel, dPerIni, dPerFim, aPeriodo)

DO CASE
    CASE cTipoRel == "1" // Diário

        dDatAux := dPerIni
        While dDatAux <= dPerFim
            AADD( aPeriodo, { {DToS(dDatAux), DToS(dDatAux)}, DToC(dDatAux) } )
            dDatAux++
        EndDo

    CASE cTipoRel == "2" // Semanal

        dDatAux := dPerIni
        While dDatAux <= dPerFim
            dSemIni := dDatAux
            dSemFim := dDatAux + 6
            AADD( aPeriodo, { {DToS(dSemIni), DToS(dSemFim)}, DToC(dSemIni) + " - " + DToC(dSemFim) } )
            dDatAux += 7
        EndDo

    CASE cTipoRel == "3" // Mensal

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

ENDCASE

Return .T.
