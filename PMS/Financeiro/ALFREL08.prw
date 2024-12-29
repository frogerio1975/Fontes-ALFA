#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"
//------------------------------------------------------------------- 
/*/{Protheus.doc} ALFREL08

Relatório de Baixas

@author		Pedro H. Oliveira 
@since 		15/11/2023
@version 	P11
/*/
//-------------------------------------------------------------------
User Function ALFREL08( )

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Baixas"
Local cNome 	:= "RelBaixas-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
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
Private aEmpFat  := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
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

Private dPerIni  := CriaVar("E1_EMISSAO",.F.)
Private dPerFim  := CriaVar("E1_EMISSAO",.F.)

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Período DE"      , dPerIni   , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {1,"Período ATE"     , dPerFim   , "@!", "", "", "", 50, .T.} )
/*
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
*/
// AADD( aBoxParam, {1,"Dt.NFS DE"       , dNfsIni   , "@!", "", ""   , "", 50, .F.} )
// AADD( aBoxParam, {1,"Dt.NFS ATE"      , dNfsFim   , "@!", "", ""   , "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Contas a Pagar",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    dPerIni  := aRetParam[2]
    dPerFim  := aRetParam[3]
    /*
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
    */
    // dNfsIni  := aRetParam[16]
    // dNfsFim  := aRetParam[17]

    // If lRetorno .and. Empty(cContrato)
    //     Help(Nil,Nil,ProcName(),,"Por favor, necessário informar o número de contrato.", 1, 5)
    //     lRetorno := .F.
    // EndIf

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
oXml:AddRow(, {"Período DE"      , DToC(dPerIni)        }, aStl)
oXml:AddRow(, {"Período ATE"     , DToC(dPerFim)        }, aStl)
/*
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
*/
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
Static Function GeraRelatorio(oXml)

//variaveis auxiliares
Local aColSize	:= {}
Local aRowDad	:= {}
Local aStl		:= {}
Local nTotLin   := 0

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

aAdd( aColSize, "54.75" ) // Data 
aAdd( aColSize, "65.00" ) // tipo
aAdd( aColSize, "65.25" ) // forn
aAdd( aColSize, "65.25" ) // No Nota Fiscal
aAdd( aColSize, "65.25" ) // valor
aAdd( aColSize, "99.25" ) // forn
//aAdd( aColSize, "65.25" ) // Parcela
//aAdd( aColSize, "65.25" ) // Líquido a Pagar
//aAdd( aColSize, "65.25" ) // Valor Recebido
//aAdd( aColSize, "120.25" ) // historico

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Contas a Pagar - Rateio Por empresa : "+ aEmpFat[Val(cEmpFat)]  ) // Data  
aAdd( aCabTit, "" ) // tipo
aAdd( aCabTit, "" ) // forn
aAdd( aCabTit, "" ) // nro nota
aAdd( aCabTit, "" ) // vvalor
aAdd( aCabTit, "" ) //hist
//aAdd( aCabTit, "" ) // No Nota Fiscal
//aAdd( aCabTit, "" ) // Prefixo
//aAdd( aCabTit, "" ) // No Título
//aAdd( aCabTit, "" ) // Parcela

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data 
aAdd( aTitStl, oStlTit ) // tipo
aAdd( aTitStl, oStlTit ) // forn
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // valor
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
//aAdd( aTitStl, oStlTit ) // Parcela
//aAdd( aTitStl, oStlTit ) // Líquido a Pagar
//aAdd( aTitStl, oStlTit ) // Valor Recebido
//aAdd( aTitStl, oStlTit ) // Impostos

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , ,5) // Contrato Atual

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data" ) // Data 
aAdd( aCabDad, "Tipo" ) // tipo
aAdd( aCabDad, "Fornecedor/Cliente" ) // forn
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Valor" ) // valor
aAdd( aCabDad, "Dt Emis Nf" ) // No Nota Fiscal
aAdd( aCabDad, "Historico" ) // No Nota Fiscal
//aAdd( aCabDad, "Natureza" ) // No Nota Fiscal
//aAdd( aCabDad, "Valor da Nota" ) // Valor da Nota
//aAdd( aCabDad, "Valor Rateado" ) // Valor da Nota
//aAdd( aCabDad, "Histórico" ) // Histórico E1_XDTREC

aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Fornecedor
aAdd( aCabStl, oStlCab1 ) // CNPJ
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // No Título

//aAdd( aCabStl, oStlCab1 ) // Parcela
//aAdd( aCabStl, oStlCab1 ) // Valor da Nota
//aAdd( aCabStl, oStlCab1 ) // Valor da Nota
//aAdd( aCabStl, oStlCab1 ) // Valor da Nota

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)


nSaldo := RetSldIni( dDataBase )
aAdd( aRowDad, '' ) // Data 
aAdd( aRowDad, '' ) // TIPO    
aAdd( aRowDad, '' ) // FORN/CLI
aAdd( aRowDad, 'Saldo Inicial' ) // No Nota Fiscal    
aAdd( aRowDad, nSaldo ) // Valor NF
aAdd( aRowDad, '' ) // FORN/CLI
aAdd( aRowDad, '' ) // FORN/CLI

aAdd( aStl, oSN01Dat ) // Data emissão
aAdd( aStl, oSN03Txt ) // TIPO
aAdd( aStl, oSN03Txt ) // FORN
aAdd( aStl, oSN04Txt ) // No Nota Fiscal        
aAdd( aStl, oSN05Num ) // Valor NF
aAdd( aStl, oSN04Txt ) // HIST
aAdd( aStl, oSN04Txt ) // HIST

oXML:AddRow( HeightRowItem1, aRowDad, aStl )
////////////////////////////////////////////////////////////////////////////////////////////
nTotLin++
//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())
	
	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, SToD((cTMP1)->E5_DATA) ) // Data 
    aAdd( aRowDad, AllTrim((cTMP1)->TIPO) ) // TIPO    
    aAdd( aRowDad, (cTMP1)->E1_NOMCLI ) // FORN/CLI
    aAdd( aRowDad, (cTMP1)->E1_XNUMNFS ) // No Nota Fiscal    
    aAdd( aRowDad, (cTMP1)->E5_VALOR ) // Valor NF

    XDATA:= SUBSTR( (cTMP1)->E1_XDTREC ,1,10)
    XDATA:= STRTRAN(XDATA,'-','')
    aAdd( aRowDad, SToD( XDATA ) ) // emis nf
    

    aAdd( aRowDad, (cTMP1)->E5_HISTOR ) // Valor NF
    

    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN03Txt ) // TIPO
    aAdd( aStl, oSN03Txt ) // FORN
    aAdd( aStl, oSN04Txt ) // No Nota Fiscal        
    aAdd( aStl, oSN05Num ) // Valor NF
    aAdd( aStl, oSN01Dat ) // DATA
    aAdd( aStl, oSN04Txt ) // HIST

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


If nTotLin > 0

	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "TOTAL" ) // Data 
    aAdd( aRowDad, "" ) // TIPO
    aAdd( aRowDad, "" ) // FORN
    aAdd( aRowDad, "" ) // NOTA
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF    
    aAdd( aRowDad, "" ) // NOTA
    aAdd( aRowDad, "" ) // NOTA

    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Fornecedor
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // Prefixo    
    aAdd( aStl, oSN08Num ) // Valor NF
    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Data emissão

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

cQuery += " SELECT "+CRLF
cQuery += " E1_FILIAL"+CRLF
cQuery += " ,'RECEBER' TIPO"+CRLF
cQuery += " ,E1_EMPFAT"+CRLF
cQuery += " ,E1_NOMCLI"+CRLF
cQuery += " ,E5_DATA"+CRLF
cQuery += " ,CASE WHEN E5_RECPAG <>'R' THEN E5_VALOR*-1 ELSE E5_VALOR END  E5_VALOR"+CRLF
cQuery += " ,E1_XNUMNFS"+CRLF
cQuery += " ,SE5.R_E_C_N_O_"+CRLF
cQuery += " ,E1_HIST E5_HISTOR "+CRLF 
cQuery += " ,E1_XDTREC "+CRLF
cQuery += " FROM SE1010 SE1(NOLOCK)"+CRLF
cQuery += " INNER JOIN SE5010 SE5 (NOLOCK) "+CRLF
cQuery += "  	ON SE5.E5_FILIAL = SE1.E1_FILIAL "+CRLF
cQuery += "  	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "+CRLF
cQuery += "  	AND SE5.E5_NUMERO = SE1.E1_NUM "+CRLF
cQuery += "  	AND SE5.E5_PARCELA = SE1.E1_PARCELA "+CRLF
cQuery += "  	AND SE5.E5_TIPO = SE1.E1_TIPO "+CRLF
cQuery += "  	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "+CRLF
cQuery += "  	AND SE5.E5_LOJA = SE1.E1_LOJA "+CRLF
//cQuery += "  	AND SE5.E5_RECPAG = 'R' "+CRLF
cQuery += "  	AND SE5.E5_DATA BETWEEN '"+DToS(dPerIni)+"' AND '"+DToS(dPerFim)+"' "+ CRLF
cQuery += "  	AND SE5.D_E_L_E_T_ = ' '"+CRLF

cQuery += "  	AND SE5.E5_MOTBX NOT IN ( 'DAC','FAT') "+CRLF
cQuery += "     AND E5_SITUACA    <> 'C'  "+CRLF
//cQuery += "     AND E5_SITUACA    <> 'X'  "+CRLF

cQuery += " WHERE"+CRLF
cQuery += "  	SE1.E1_FILIAL = '01' "+CRLF
cQuery += "  	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+CRLF
//cQuery += "  	AND SE1.E1_TIPO = 'DP' "+CRLF
//cQuery += "  	AND SE1.E1_FATURA = ' ' "+CRLF
cQuery += "  	AND SE1.E1_XNUMNFS <> '' "+CRLF

cQuery += "  	AND SE1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " "+CRLF
cQuery += " UNION ALL"+CRLF
cQuery += " "+CRLF
cQuery += " SELECT "+CRLF
cQuery += " "+CRLF
cQuery += " E2_FILIAL"+CRLF
cQuery += " ,'PAGAR' TIPO"+CRLF
cQuery += " ,E2_EMPFAT"+CRLF
cQuery += " ,E2_NOMFOR"+CRLF
cQuery += " ,E5_DATA"+CRLF
cQuery += " ,CASE WHEN E5_RECPAG <>'R' AND E5_TIPODOC <> 'DC' THEN E5_VALOR*-1 ELSE E5_VALOR END  E5_VALOR "+CRLF
cQuery += " ,E2_NUMNOTA"+CRLF
cQuery += " ,SE5.R_E_C_N_O_"+CRLF
cQuery += " ,E2_HIST E5_HISTOR "+CRLF
cQuery += " ,E2_EMISSAO "+CRLF
cQuery += " FROM SE2010 SE2 (NOLOCK) "+CRLF
cQuery += "  INNER JOIN SE5010 SE5 (NOLOCK) "+CRLF
cQuery += "  	ON SE5.E5_FILIAL = SE2.E2_FILIAL "+CRLF
cQuery += "  	AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "+CRLF
cQuery += "  	AND SE5.E5_NUMERO = SE2.E2_NUM "+CRLF
cQuery += "  	AND SE5.E5_PARCELA = SE2.E2_PARCELA "+CRLF
cQuery += "  	AND SE5.E5_TIPO = SE2.E2_TIPO "+CRLF
cQuery += "  	AND SE5.E5_CLIFOR = SE2.E2_FORNECE "+CRLF
cQuery += "  	AND SE5.E5_LOJA = SE2.E2_LOJA "+CRLF
//cQuery += "  	AND SE5.E5_RECPAG = 'P' "+CRLF
cQuery += "  	AND SE5.E5_DATA BETWEEN '"+DToS(dPerIni)+"' AND '"+DToS(dPerFim)+"' "+ CRLF
cQuery += "  	AND SE5.D_E_L_E_T_ = ' ' "+CRLF

//cQuery += "  	AND E5_TIPODOC "+CRLF

cQuery += "  	AND SE5.E5_MOTBX NOT IN ( 'DAC','FAT') "+CRLF 
cQuery += "     AND E5_SITUACA    <> 'C'  "+CRLF
cQuery += "     AND E5_TIPODOC <> 'DC'  "+CRLF

cQuery += "  WHERE "+CRLF
cQuery += "  	SE2.E2_FILIAL = '01' "+CRLF
cQuery += "  	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+CRLF
//cQuery += "  	AND SE2.E2_TIPO = 'DP' "+CRLF
cQuery += "  	AND SE2.D_E_L_E_T_ = ' '	"+CRLF
cQuery += " ORDER BY E5_DATA,SE5.R_E_C_N_O_ "+CRLF

// Salva query em disco para debug.
If .T.
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL08.SQL", cQuery)
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
//cEmpFat
cQuery := " SELECT TOP 1 "+ CRLF
cQuery += " 	TAB.E8_DTSALAT "+ CRLF
cQuery += " 	,TAB.E8_SALATUA "+ CRLF
cQuery += " FROM ( "+ CRLF
cQuery += " 	SELECT "+ CRLF
cQuery += " 		SE8.E8_DTSALAT "+ CRLF
cQuery += " 		,SUM(SE8.E8_SALATUA) AS E8_SALATUA "+ CRLF
cQuery += " 	FROM "+RetSqlName("SE8")+" SE8 (NOLOCK) "+ CRLF
	
cQuery += "INNER JOIN "+RetSqlName("SA6")+" SA6 ON A6_FILIAL='"+XFILIAL('SA6')+"' "+CRLF
cQuery += "    AND A6_COD=E8_BANCO "+CRLF
cQuery += "    AND A6_AGENCIA=E8_AGENCIA "+CRLF
cQuery += "    AND A6_NUMCON=E8_CONTA"+CRLF
cQuery += "    AND A6_EMPFAT='"+cEmpFat+"' "+CRLF
cQuery += "    AND SA6.D_E_L_E_T_=''"+CRLF

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
