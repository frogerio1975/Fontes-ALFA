#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL01
Relatório de Contas a Receber.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL01()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Contas a Receber"
Local cNome 	:= "ContasReceber-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de contas a receber."
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
Private cTipoE1  := "DP"
Private cNumIni  := CriaVar("E1_NUM",.F.)
Private cNumFim  := CriaVar("E1_NUM",.F.)
Private dEmisIni := CriaVar("E1_EMISSAO",.F.)
Private dEmisFim := CriaVar("E1_EMISSAO",.F.)
Private dVencIni := CriaVar("E1_VENCREA",.F.)
Private dVencFim := CriaVar("E1_VENCREA",.F.)
Private dBaixIni := CriaVar("E1_BAIXA",.F.)
Private dBaixFim := CriaVar("E1_BAIXA",.F.)
Private cCliIni  := CriaVar("E1_CLIENTE",.F.)
Private cCliFim  := CriaVar("E1_CLIENTE",.F.)
Private cNfsIni  := CriaVar("E1_XNUMNFS",.F.)
Private cNfsFim  := CriaVar("E1_XNUMNFS",.F.)
Private dNfsIni  := CriaVar("E1_EMISSAO",.F.)
Private dNfsFim  := CriaVar("E1_EMISSAO",.F.)

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
AADD( aBoxParam, {1,"Cliente DE"      , cCliIni   , "@!", "", "SA1", "", 50, .F.} )
AADD( aBoxParam, {1,"Cliente ATE"     , cCliFim   , "@!", "", "SA1", "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS DE"      , cNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Num.NFS ATE"     , cNfsFim   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.NFS DE"       , dNfsIni   , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Dt.NFS ATE"      , dNfsFim   , "@!", "", ""   , "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Contas a Receber",@aRetParam,,,,,,,,.F.)

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
    cCliIni  := aRetParam[12]
    cCliFim  := aRetParam[13]
    cNfsIni  := aRetParam[14]
    cNfsFim  := aRetParam[15]
    dNfsIni  := aRetParam[16]
    dNfsFim  := aRetParam[17]

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
oXml:AddRow(, {"Cliente DE"      , cCliIni          }, aStl)
oXml:AddRow(, {"Cliente ATE"     , cCliFim          }, aStl)
oXml:AddRow(, {"Num.NFS DE"      , cNfsIni          }, aStl)
oXml:AddRow(, {"Num.NFS ATE"     , cNfsFim          }, aStl)
oXml:AddRow(, {"Dt.NFS DE"       , DToC(dNfsIni)    }, aStl)
oXml:AddRow(, {"Dt.NFS ATE"      , DToC(dNfsFim)    }, aStl)

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

local aTpSrvSx3 := RetSX3Box(GetSX3Cache("E1_XTPSRV", "X3_CBOX"),,,1)
local aTpParSx3 := RetSX3Box(GetSX3Cache("E1_XTPPARC", "X3_CBOX"),,,1)
local aTpEntSx3 := RetSX3Box(GetSX3Cache("E1_XENTREG", "X3_CBOX"),,,1)

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
oXml:setFolderName("Contas a Receber")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "54.75" ) // Data emissão
aAdd( aColSize, "54.75" ) // Data vencimento
aAdd( aColSize, "54.75" ) // Data pagamento
aAdd( aColSize, "65.75" ) // Dias em atraso
aAdd( aColSize, "120.00" ) // Cliente
aAdd( aColSize, "65.25" ) // No Nota Fiscal
aAdd( aColSize, "65.25" ) // Prefixo
aAdd( aColSize, "65.25" ) // No Título
aAdd( aColSize, "65.25" ) // Parcela

aAdd( aColSize, "65.25" ) // VALOR
aAdd( aColSize, "65.25" ) // IMPOSTOS
aAdd( aColSize, "65.25" ) // IMPOSTOS
aAdd( aColSize, "65.25" ) // IMPOSTOS
aAdd( aColSize, "65.25" ) // IMPOSTOS
aAdd( aColSize, "65.25" ) // IMPOSTOS

aAdd( aColSize, "65.25" ) // Líquido a Receber
aAdd( aColSize, "65.25" ) // Valor Recebido
aAdd( aColSize, "65.25" ) // Impostos
aAdd( aColSize, "65.25" ) // Desconto
aAdd( aColSize, "65.25" ) // Multa
aAdd( aColSize, "65.25" ) // Juros
aAdd( aColSize, "65.25" ) // Total Recebido

aAdd( aColSize, "65.25" ) //hist
aAdd( aColSize, "65.25" ) //Tipo Servico
aAdd( aColSize, "65.25" ) //Tipo Parcela
aAdd( aColSize, "65.25" ) //Pagamento Atrelado Entreg
aAdd( aColSize, "65.25" ) //E1_NATUREZ

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Contas a Receber" ) // Data emissão
aAdd( aCabTit, "" ) // Data vencimento
aAdd( aCabTit, "" ) // Data pagamento
aAdd( aCabTit, "" ) // Dias em atraso
aAdd( aCabTit, "" ) // Cliente
aAdd( aCabTit, "" ) // cgc
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
aAdd( aCabTit, "" ) // Parcela
aAdd( aCabTit, "" ) // Líquido a Receber
aAdd( aCabTit, "" ) // Valor Recebido
aAdd( aCabTit, "Data emissão" ) // Impostos
aAdd( aCabTit, Date() ) // Desconto
aAdd( aCabTit, "" ) // Multa
aAdd( aCabTit, "" ) // Juros
aAdd( aCabTit, "" ) // Total Recebido
aAdd( aCabTit, "" ) // hist

aAdd( aCabTit, '' ) //Tipo Servico
aAdd( aCabTit, '' ) //Tipo Parcela
aAdd( aCabTit, '' ) //Pagamento Atrelado Entreg
aAdd( aCabTit, '' ) //E1_NATUREZ

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Data vencimento
aAdd( aTitStl, oStlTit ) // Data pagamento
aAdd( aTitStl, oStlTit ) // Dias em atraso
aAdd( aTitStl, oStlTit ) // Cliente
aAdd( aTitStl, oStlTit ) // cgc
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // Prefixo
aAdd( aTitStl, oStlTit ) // No Título
aAdd( aTitStl, oStlTit ) // Parcela

aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Líquido a Receber

aAdd( aTitStl, oStlTit ) // Líquido a Receber
aAdd( aTitStl, oStlTit ) // Valor Recebido
aAdd( aTitStl, oStlTit ) // Impostos
aAdd( aTitStl, oStlTit2 ) // Desconto
aAdd( aTitStl, oStlTit ) // Multa
aAdd( aTitStl, oStlTit ) // Juros
aAdd( aTitStl, oStlTit ) // Total Recebido
aAdd( aTitStl, oStlTit ) // hist

aAdd( aTitStl, oStlTit ) //Tipo Servico
aAdd( aTitStl, oStlTit ) //Tipo Parcela
aAdd( aTitStl, oStlTit ) //Pagamento Atrelado Entreg
aAdd( aTitStl, oStlTit ) //NATUREZ
oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 4) // Contrato Atual

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data emissão" ) // Data emissão
aAdd( aCabDad, "Data vencimento" ) // Data vencimento
aAdd( aCabDad, "Data pagamento" ) // Data pagamento
aAdd( aCabDad, "Dias em atraso" ) // Dias em atraso
aAdd( aCabDad, "Cliente" ) // Cliente
aAdd( aCabDad, "CGC" ) // CGC
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Link Nota Fiscal" ) // LINK
aAdd( aCabDad, "Prefixo" ) // Prefixo
aAdd( aCabDad, "No Título" ) // No Título
aAdd( aCabDad, "Parcela" ) // Parcela

aAdd( aCabDad, "Valor Total" ) // Valor Recebido
aAdd( aCabDad, "Valor IRFF" ) // Valor Recebido
aAdd( aCabDad, "Valor CSLL" ) // Valor Recebido
aAdd( aCabDad, "Valor ISS" ) // Valor Recebido
aAdd( aCabDad, "Valor COFINS" ) // Valor Recebido
aAdd( aCabDad, "Valor PIS" ) // Valor Recebido

aAdd( aCabDad, "Líquido a Receber" ) // Líquido a Receber
aAdd( aCabDad, "Valor Recebido" ) // Valor Recebido
aAdd( aCabDad, "Impostos" ) // Impostos
aAdd( aCabDad, "Desconto" ) // Desconto
aAdd( aCabDad, "Multa" ) // Multa
aAdd( aCabDad, "Juros" ) // Juros
aAdd( aCabDad, "Total Recebido" ) // Total Recebido
aAdd( aCabDad, "Historico" ) // Total Recebido

aAdd( aCabDad, 'Tipo Servico' ) //Tipo Servico
aAdd( aCabDad, 'Tipo Parcela' ) //Tipo Parcela
aAdd( aCabDad, 'Pagamento Atrelado Entreg' ) //Pagamento Atrelado Entreg
aAdd( aCabDad, 'Natureza' ) //Pagamento Atrelado Entreg
aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Data vencimento
aAdd( aCabStl, oStlCab1 ) // Data pagamento
aAdd( aCabStl, oStlCab1 ) // Dias em atraso
aAdd( aCabStl, oStlCab1 ) // Cliente
aAdd( aCabStl, oStlCab1 ) // CGC
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // link
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Líquido a Receber

aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Valor Recebido

aAdd( aCabStl, oStlCab1 ) // Valor Recebido
aAdd( aCabStl, oStlCab1 ) // Impostos
aAdd( aCabStl, oStlCab1 ) // Desconto
aAdd( aCabStl, oStlCab1 ) // Multa
aAdd( aCabStl, oStlCab1 ) // Juros
aAdd( aCabStl, oStlCab1 ) // Total Recebido
aAdd( aCabStl, oStlCab1 ) // hist

aAdd( aCabStl, oStlCab1 ) //Tipo Servico
aAdd( aCabStl, oStlCab1 ) //Tipo Parcela
aAdd( aCabStl, oStlCab1 ) //Pagamento Atrelado Entreg
aAdd( aCabStl, oStlCab1 ) //naturez

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    nVlrNF   := (cTMP1)->E1_VALOR
    nVlrISS  := (cTMP1)->E1_ISS
    nVlrPIS  := (cTMP1)->E1_PIS
    nVlrCOF  := (cTMP1)->E1_COFINS
    nVlrIRRF := (cTMP1)->E1_IRRF//(cTMP1)->E1_VRETIRF
    nVlrCSLL := (cTMP1)->E1_CSLL
    nVlrImp  := nVlrISS + nVlrPIS + nVlrCOF + nVlrIRRF + nVlrCSLL
    nVlrLiq  := nVlrNF - nVlrImp // nVlrLiq  := (cTMP1)->E1_VALOR - SomaAbat((cTMP1)->E1_PREFIXO,(cTMP1)->E1_NUM,(cTMP1)->E1_PARCELA,'R',1,,(cTMP1)->E1_CLIENTE,(cTMP1)->E1_LOJA)
    nVlrRec  := 0
    nVlrDesc := 0
    nMulta   := 0
    nJuros   := 0

    If !Empty((cTMP1)->E1_BAIXA)
        aRetPagtos := BuscaPagtos(;
            (cTMP1)->E1_PREFIXO,;
            (cTMP1)->E1_NUM,;
            (cTMP1)->E1_PARCELA,;
            (cTMP1)->E1_TIPO,;
            (cTMP1)->E1_CLIENTE,;
            (cTMP1)->E1_LOJA;
        )

        nVlrRec  := aRetPagtos[1]
        nVlrDesc := aRetPagtos[2]
        nMulta   := aRetPagtos[3]
        nJuros   := aRetPagtos[4]
    EndIf

    //aAdd( aRowDad, SToD((cTMP1)->E1_EMISSAO) ) // Data emissão
    aAdd( aRowDad, SToD(StrTran(SubStr((cTMP1)->E1_XDTREC,1,10),"-")) ) // Data emissão
    
    aAdd( aRowDad, SToD((cTMP1)->E1_VENCREA) ) // Data vencimento
    aAdd( aRowDad, IIF(!Empty((cTMP1)->E1_BAIXA),SToD((cTMP1)->E1_BAIXA),"") ) // Data pagamento
    aAdd( aRowDad, "=IFS(RC[-1]&lt;&gt;&quot;&quot;,0,RC[-2]&lt;=R1C13,R1C13-RC[-2],R1C13&lt;RC[-2],0)" ) // Dias em atraso
    aAdd( aRowDad, AllTrim((cTMP1)->A1_NREDUZ) ) // Cliente

    //aAdd( aRowDad, AllTrim((cTMP1)->A1_CGC) ) // Cliente
    aAdd( aRowDad, Transform((cTMP1)->A1_CGC,IIF((cTMP1)->A1_TIPO=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) ) // CNPJ

    aAdd( aRowDad, (cTMP1)->E1_XNUMNFS ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->E1_XLINKNF ) // link
    aAdd( aRowDad, (cTMP1)->E1_PREFIXO ) // Prefixo
    aAdd( aRowDad, (cTMP1)->E1_NUM) // No Título
    aAdd( aRowDad, (cTMP1)->E1_PARCELA) // Parcela

    aAdd( aRowDad, nVlrNF ) // Líquido a Receber    
    aAdd( aRowDad, nVlrIRRF ) // Líquido a Receber
    aAdd( aRowDad, nVlrCSLL ) // Líquido a Receber
    aAdd( aRowDad, nVlrISS ) // Líquido a Receber    
    aAdd( aRowDad, nVlrCOF ) // Líquido a Receber
    aAdd( aRowDad, nVlrPIS ) // Líquido a Receber
    
    aAdd( aRowDad, nVlrLiq ) // Líquido a Receber
    aAdd( aRowDad, nVlrRec ) // Valor Recebido
    aAdd( aRowDad, nVlrImp ) // Impostos
    aAdd( aRowDad, nVlrDesc ) // Descontos
    aAdd( aRowDad, nMulta ) // Multa
    aAdd( aRowDad, nJuros ) // Juros
    aAdd( aRowDad, "=RC[-5]+RC[-2]+RC[-1]" ) // Total Recebido

    aAdd( aRowDad, (cTMP1)->E1_HIST ) // Juros

    nScan := ASCAN(aTpSrvSx3,{|X| X[2] ==  alltrim((cTMP1)->E1_XTPSRV) }) 
    cRet1:=''
    IF nScan > 0
        cRet1:= aTpSrvSx3[nScan][3]
    END

    nScan := ASCAN(aTpParSx3,{|X| X[2] ==  alltrim((cTMP1)->E1_XTPPARC) })  
    cRet2:=''
    IF nScan > 0
        cRet2:= aTpParSx3[nScan][3]
    END

    nScan := ASCAN(aTpEntSx3,{|X| X[2] ==  alltrim((cTMP1)->E1_XENTREG)}) 
    cRet3:=''
    IF nScan > 0
        cRet3:= aTpEntSx3[nScan][3]
    END

    aAdd( aRowDad, cRet1 ) //Tipo Servico
    aAdd( aRowDad, cRet2 ) //Tipo Parcela
    aAdd( aRowDad, cRet3 ) //Pagamento Atrelado Entreg
    aAdd( aRowDad, (cTMP1)->E1_NATUREZ ) //nature\z

    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN01Dat ) // Data vencimento
    aAdd( aStl, oSN01Dat ) // Data pagamento
    aAdd( aStl, oSN02Num ) // Dias em atraso
    aAdd( aStl, oSN03Txt ) // Cliente
    aAdd( aStl, oSN03Txt ) // CGC
    aAdd( aStl, oSN04Txt ) // No Nota Fiscal
    aAdd( aStl, oSN04Txt ) // LINK
    
    aAdd( aStl, oSN04Txt ) // Prefixo
    aAdd( aStl, oSN04Txt ) // No Título
    aAdd( aStl, oSN04Txt ) // Parcela
    
    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Líquido a Receber

    aAdd( aStl, oSN05Num ) // Líquido a Receber
    aAdd( aStl, oSN05Num ) // Valor Recebido
    aAdd( aStl, oSN05Num ) // Impostos
    aAdd( aStl, oSN05Num ) // Desconto
    aAdd( aStl, oSN05Num ) // Multa
    aAdd( aStl, oSN05Num ) // Juros
    aAdd( aStl, oSN06Num ) // Total Recebido
    
    aAdd( aStl, oSN03Txt ) // hist

    aAdd( aStl, oSN03Txt ) // hist
    aAdd( aStl, oSN03Txt ) // hist
    aAdd( aStl, oSN03Txt ) // hist
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
    aAdd( aRowDad, "" ) // Cliente
    aAdd( aRowDad, "" ) // CGC
    aAdd( aRowDad, "" ) // No Nota Fiscal
    aAdd( aRowDad, "" ) // LINK
    
    aAdd( aRowDad, "" ) // Prefixo
    aAdd( aRowDad, "" ) // No Título
    aAdd( aRowDad, "" ) // Parcela

    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber

    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Receber
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor Recebido
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Impostos
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Descontos
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Multa
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Juros
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Total Recebido

    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Data vencimento
    aAdd( aStl, oSN07Txt ) // Data pagamento
    aAdd( aStl, oSN07Txt ) // Dias em atraso
    aAdd( aStl, oSN07Txt ) // Cliente
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // LINK
    
    aAdd( aStl, oSN07Txt ) // Prefixo
    aAdd( aStl, oSN07Txt ) // No Título
    aAdd( aStl, oSN07Txt ) // Parcela

    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Líquido a Receber

    aAdd( aStl, oSN08Num ) // Líquido a Receber
    aAdd( aStl, oSN08Num ) // Valor Recebido
    aAdd( aStl, oSN08Num ) // Impostos
    aAdd( aStl, oSN08Num ) // Desconto
    aAdd( aStl, oSN08Num ) // Multa
    aAdd( aStl, oSN08Num ) // Juros
    aAdd( aStl, oSN08Num ) // Total Recebido

	oXML:AddRow( HeightRowTotal, aRowDad, aStl )

    nTotLin++
    oXML:SkipLine("12.75")

    nTotLin++
    oXML:AddRow( "15.00", {"Relatório de Aging list do Contas a Receber"  , "", "", "" }, {oStlTit3, oStlTit3, oStlTit3, oStlTit3} )
    oXml:setMerge(, , , 3)

    nTotLin++
    oXML:AddRow( "15.00", {"Período"  , "", "", "A Receber" }, {oStlCab1, oStlCab1, oStlCab1, oStlCab1} )
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
    oXML:AddRow( "15.00", {"Total do Contas a Receber"   , "", "", "=SUM(R[-6]C:R[-1]C)"}, {oSN07Txt, oSN07Txt, oSN07Txt, oSN08Num} )
    oXml:setMerge(, , , 2)
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
cQuery += " 	,A1_CGC , A1_TIPO "+ CRLF 
cQuery += " 	,E1_NATUREZ "+ CRLF
cQuery += " 	,E1_VALOR "+ CRLF
cQuery += " 	,E1_EMISSAO,E1_XDTREC "+ CRLF
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
cQuery += " 	,E1_XNUMNFS,E1_HIST "+ CRLF
cQuery += " 	,E1_XTPSRV,E1_XTPPARC,E1_XENTREG,E1_XLINKNF"+ CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
//cQuery += " 	AND SE1.E1_FATURA = ' ' "+ CRLF
cQuery += " 	AND (SE1.E1_FATURA = ' ' OR E1_FATURA = 'NOTFAT')"+ CRLF

If !Empty(cPrefixo)
    cQuery += " 	AND SE1.E1_PREFIXO = '"+cPrefixo+"' "+ CRLF
EndIf

If !Empty(cTipoE1)
    cQuery += " 	AND SE1.E1_TIPO = '"+cTipoE1+"' "+ CRLF
EndIf

If !Empty(cNumIni) .Or. !Empty(cNumFim) 
    cQuery += " 	AND SE1.E1_NUM BETWEEN '"+cNumIni+"' AND '"+cNumFim+"' "+ CRLF
EndIf

If !Empty(dEmisIni) .Or. !Empty(dEmisFim) 
    cQuery += " 	AND SE1.E1_EMISSAO BETWEEN '"+DToS(dEmisIni)+"' AND '"+DToS(dEmisFim)+"' "+ CRLF
EndIf

If !Empty(dVencIni) .Or. !Empty(dVencFim) 
    cQuery += " 	AND SE1.E1_VENCREA BETWEEN '"+DToS(dVencIni)+"' AND '"+DToS(dVencFim)+"' "+ CRLF
EndIf

If !Empty(dBaixIni) .Or. !Empty(dBaixFim) 
    cQuery += " 	AND SE1.E1_BAIXA BETWEEN '"+DToS(dBaixIni)+"' AND '"+DToS(dBaixFim)+"' "+ CRLF
EndIf

If !Empty(cCliIni) .Or. !Empty(cCliFim) 
    cQuery += " 	AND SE1.E1_CLIENTE BETWEEN '"+cCliIni+"' AND '"+cCliFim+"' "+ CRLF
EndIf

If !Empty(cNfsIni) .Or. !Empty(cNfsFim) 
    cQuery += " 	AND SE1.E1_XNUMNFS BETWEEN '"+cNfsIni+"' AND '"+cNfsFim+"' "+ CRLF
EndIf

If !Empty(dNfsIni) .Or. !Empty(dNfsFim) 
    cAuxIni := Transform(DToS(dNfsIni), "@R 9999-99-99") + "T00:00:00"
    cAuxFim := Transform(DToS(dNfsFim), "@R 9999-99-99") + "T99:99:99"
    cQuery += " 	AND SE1.E1_XDTREC BETWEEN '"+cAuxIni+"' AND '"+cAuxFim+"' "+ CRLF
EndIf

cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE1.E1_VENCREA "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL01.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaPagtos
Converte para o formato data em EXCEL.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaPagtos(cPrefixo, cNumTit, cParcela, cTipo, cCodCli, cLoja)

Local aAreaAtu := GetArea()
Local cTMP1    := ""
Local cQuery   := ""
Local aRetorno := { 0, 0, 0, 0 }

cQuery := " SELECT "+ CRLF
//cQuery += " 	SUM(SE5.E5_VALOR) AS E5_VALOR "+ CRLF
//cQuery += " 	,SUM(SE5.E5_VLDESCO) AS E5_VLDESCO "+ CRLF
//cQuery += " 	,SUM(SE5.E5_VLMULTA) AS E5_VLMULTA "+ CRLF
//cQuery += " 	,SUM(SE5.E5_VLJUROS) AS E5_VLJUROS "+ CRLF
cQuery += " SUM(CASE WHEN E5_RECPAG <> 'R' THEN E5_VALOR * - 1 ELSE E5_VALOR END) AS E5_VALOR "+ CRLF

cQuery += " ,SUM(CASE WHEN E5_RECPAG <> 'R' THEN E5_VLDESCO * - 1 ELSE E5_VLDESCO END) AS E5_VLDESCO "+ CRLF
cQuery += " ,SUM(CASE WHEN E5_RECPAG <> 'R' THEN E5_VLMULTA * - 1 ELSE E5_VLMULTA END) AS E5_VLMULTA "+ CRLF
cQuery += " ,SUM(CASE WHEN E5_RECPAG <> 'R' THEN E5_VLJUROS * - 1 ELSE E5_VLJUROS END) AS E5_VLJUROS "+ CRLF

cQuery += " FROM "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	SE5.E5_FILIAL = '"+xFilial("SE5")+"' "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = '"+cPrefixo+"' "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = '"+cNumTit+"' "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = '"+cParcela+"' "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = '"+cTipo+"' "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = '"+cCodCli+"' "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = '"+cLoja+"' "+ CRLF
//cQuery += " 	AND SE5.E5_RECPAG = 'R' "+ CRLF
cQuery += " 	AND SE5.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    aRetorno[1] := (cTMP1)->E5_VALOR
    aRetorno[2] := (cTMP1)->E5_VLDESCO
    aRetorno[3] := (cTMP1)->E5_VLMULTA
    aRetorno[4] := (cTMP1)->E5_VLJUROS
EndIf

(cTMP1)->(dbCloseArea())

RestArea(aAreaAtu)

Return aRetorno
