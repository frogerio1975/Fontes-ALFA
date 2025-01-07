#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFREL02
Relatório de Contas a Pagar.

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFREL02()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Contas a Pagar"
Local cNome 	:= "ContasPagar-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
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
Private cNumFim  := Repl("Z",TamSX3("E2_NUM")[1]) //CriaVar("E2_NUM",.F.)
Private dEmisIni := CriaVar("E2_EMISSAO",.F.)
Private dEmisFim := Ctod("31/12/2049") //CriaVar("E2_EMISSAO",.F.)
Private dVencIni := CriaVar("E2_VENCREA",.F.)
Private dVencFim := Ctod("31/12/2049") //CriaVar("E2_VENCREA",.F.)
Private dBaixIni := CriaVar("E2_BAIXA",.F.)
Private dBaixFim := Ctod("31/12/2049") //CriaVar("E2_BAIXA",.F.)
Private cForIni  := CriaVar("E2_FORNECE",.F.)
Private cForFim  := Repl("Z",TamSX3("E2_FORNECE")[1]) //CriaVar("E2_FORNECE",.F.)
Private cNfsIni  := CriaVar("E2_NUMNOTA",.F.)
Private cNfsFim  := Repl("Z",TamSX3("E2_NUMNOTA")[1]) //CriaVar("E2_NUMNOTA",.F.)
Private dNfsIni  := CriaVar("E2_EMISSAO",.F.)
Private dNfsFim  := Ctod("31/12/2049") //CriaVar("E2_EMISSAO",.F.)
Private aTipoCP  := { "1=Em Aberto", "2=Baixados", "3=Todos"}
Private cTipoCP  := "3"


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
AADD( aBoxParam, {2,"Tipo CP"         , cTipoCP   , aTipoCP, 50, ".F.", .T.} )

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
    cTipoCP  := aRetParam[16]
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
oXml:AddRow(, {"Fornecedor DE"   , cForIni          }, aStl)
oXml:AddRow(, {"Fornecedor ATE"  , cForFim          }, aStl)
oXml:AddRow(, {"Num.NFS DE"      , cNfsIni          }, aStl)
oXml:AddRow(, {"Num.NFS ATE"     , cNfsFim          }, aStl)
// oXml:AddRow(, {"Dt.NFS DE"       , DToC(dNfsIni)    }, aStl)
// oXml:AddRow(, {"Dt.NFS ATE"      , DToC(dNfsFim)    }, aStl)
oXml:AddRow(, {"Tipo CP"         , aTipoCP[Val(cTipoCP)] }, aStl)

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

LOCAL:= aRetSx3 := RetSX3Box(GetSX3Cache("E2_XCCRED", "X3_CBOX"),,,1)

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

aAdd( aColSize, "65.25" ) // Dt.Emissao
aAdd( aColSize, "65.25" ) // Dt.Vencimento
aAdd( aColSize, "65.25" ) // Dt.Pagamento
aAdd( aColSize, "65.75" ) // Dias em atraso
aAdd( aColSize, "65.25" ) // Dt.Liberacao
aAdd( aColSize, "65.25" ) // Usuario Liberação
aAdd( aColSize, "120.25") // Fornecedor
aAdd( aColSize, "65.25" ) // CNPJ
aAdd( aColSize, "65.25" ) // Nota Fiscal
aAdd( aColSize, "65.25" ) // Prefixo
aAdd( aColSize, "65.25" ) // Titulo
aAdd( aColSize, "65.25" ) // Parcela
aAdd( aColSize, "65.25" ) // Valor Liquido
aAdd( aColSize, "65.25" ) // Valor Bruto
aAdd( aColSize, "65.25" ) // Imposto
aAdd( aColSize, "65.25" ) // Liquido a Pagar
aAdd( aColSize, "65.25" ) // Desconto
aAdd( aColSize, "65.25" ) // Multa
aAdd( aColSize, "65.25" ) // Juros
aAdd( aColSize, "65.25" ) // Total Pago
aAdd( aColSize, "120.25") // Histórico
aAdd( aColSize, "65.25" ) // Natureza
aAdd( aColSize, "120.25") // Descricao Natureza
aAdd( aColSize, "65.25" ) // Tipo Pagamento
aAdd( aColSize, "65.25" ) // Banco
aAdd( aColSize, "65.25" ) // Agencia
aAdd( aColSize, "65.25" ) // Conta
aAdd( aColSize, "65.25" ) // Pix

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Contas a Pagar" ) // Data emissão
aAdd( aCabTit, "" ) // Data vencimento
aAdd( aCabTit, "" ) // Data pagamento
aAdd( aCabTit, "" ) // Dias em atraso
aAdd( aCabTit, "" ) // Data liber
aAdd( aCabTit, "" ) // Data liber
aAdd( aCabTit, "" ) // Fornecedor
aAdd( aCabTit, "" ) // CPF/CNPJ
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
aAdd( aCabTit, "" ) // Parcela
aAdd( aCabTit, "" ) // Líquido a Pagar
aAdd( aCabTit, "" ) // Valor Recebido
aAdd( aCabTit, "Data emissão" ) // Impostos
aAdd( aCabTit, Dtoc(Date()) ) // Desconto
aAdd( aCabTit, "" ) // Multa
aAdd( aCabTit, "" ) // Juros
aAdd( aCabTit, "" ) // Total Recebido
aAdd( aCabTit, "" ) // historico
aAdd( aCabTit, "" ) // valor nota fiscal
aAdd( aCabTit, "" ) // Natureza
aAdd( aCabTit, "" ) // Descricao Natureza
aAdd( aCabTit, "" ) //TIPO DE PGTO
aAdd( aCabTit, "" ) //BANCO
aAdd( aCabTit, "" ) //AGENCIA
aAdd( aCabTit, "" ) //CONTA	
aAdd( aCabTit, "" ) //PIX


aTitStl := {}

aAdd( aTitStl, oStlTit ) // Data emissão
aAdd( aTitStl, oStlTit ) // Data vencimento
aAdd( aTitStl, oStlTit ) // Data pagamento
aAdd( aTitStl, oStlTit ) // Dias em atraso
aAdd( aTitStl, oStlTit ) // Data liber
aAdd( aTitStl, oStlTit ) // Data liber
aAdd( aTitStl, oStlTit ) // Fornecedor
aAdd( aTitStl, oStlTit ) // CPF/CNPJ
aAdd( aTitStl, oStlTit ) // No Nota Fiscal
aAdd( aTitStl, oStlTit ) // Prefixo
aAdd( aTitStl, oStlTit ) // No Título
aAdd( aTitStl, oStlTit ) // Parcela
aAdd( aTitStl, oStlTit ) // Líquido a Pagar
aAdd( aTitStl, oStlTit ) // Valor Recebido
aAdd( aTitStl, oStlTit ) // Impostos
aAdd( aTitStl, oStlTit2 ) // Desconto
aAdd( aTitStl, oStlTit ) // Multa
aAdd( aTitStl, oStlTit ) // Juros
aAdd( aTitStl, oStlTit ) // Total Recebido
aAdd( aTitStl, oStlTit ) // historico
aAdd( aTitStl, oStlTit ) // valor nota fiscal
aAdd( aTitStl, oStlTit ) // Natureza
aAdd( aTitStl, oStlTit ) // Descricao Natureza
aAdd( aTitStl, oStlTit ) //TIPO DE PGTO
aAdd( aTitStl, oStlTit ) //BANCO
aAdd( aTitStl, oStlTit ) //AGENCIA
aAdd( aTitStl, oStlTit ) //CONTA	
aAdd( aTitStl, oStlTit ) //PIX

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 4) // Contrato Atual

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Data emissão" ) // Data emissão
aAdd( aCabDad, "Data vencimento" ) // Data vencimento
aAdd( aCabDad, "Data pagamento" ) // Data pagamento
aAdd( aCabDad, "Dias em atraso" ) // Dias em atraso
aAdd( aCabDad, "Data Liberação" ) // Data liber
aAdd( aCabDad, "Usuario Liberação" ) // user lib
aAdd( aCabDad, "Fornecedor" ) // Fornecedor
aAdd( aCabDad, "CPF/CNPJ" ) // CNPJ
aAdd( aCabDad, "No Nota Fiscal" ) // No Nota Fiscal
aAdd( aCabDad, "Prefixo" ) // Prefixo
aAdd( aCabDad, "No Título" ) // No Título
aAdd( aCabDad, "Parcela" ) // Parcela
aAdd( aCabDad, "Valor Liquido" ) // Valor da Nota//aAdd( aCabDad, "Valor da Nota" ) // Valor da Nota
aAdd( aCabDad, "Valor Bruto" ) // Valor Nota Fiscal
aAdd( aCabDad, "Impostos" ) // Impostos
aAdd( aCabDad, "Líquido a Pagar" ) // Líquido a Pagar
aAdd( aCabDad, "Desconto" ) // Desconto
aAdd( aCabDad, "Multa" ) // Multa
aAdd( aCabDad, "Juros" ) // Juros
aAdd( aCabDad, "Total Pago" ) // Total Pago
aAdd( aCabDad, "Histórico" ) // Histórico
aAdd( aCabDad, "Natureza" ) // Natureza
aAdd( aCabDad, "Descricao" ) // Descricao
aAdd( aCabDad, "Tipo de Pgto")
aAdd( aCabDad, "Banco")
aAdd( aCabDad, "Agencia	")
aAdd( aCabDad, "Conta")
aAdd( aCabDad, "Pix")
//CODIGO DE BARRAS


aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Data vencimento
aAdd( aCabStl, oStlCab1 ) // Data pagamento
aAdd( aCabStl, oStlCab1 ) // Dias em atraso
aAdd( aCabStl, oStlCab1 ) // Data lib
aAdd( aCabStl, oStlCab1 ) // user lib
aAdd( aCabStl, oStlCab1 ) // Fornecedor
aAdd( aCabStl, oStlCab1 ) // CPF
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Valor da Nota
aAdd( aCabStl, oStlCab1 ) // Valor Nota Fiscals
aAdd( aCabStl, oStlCab1 ) // Impostos
aAdd( aCabStl, oStlCab1 ) // Líquido a Pagar
aAdd( aCabStl, oStlCab1 ) // Desconto
aAdd( aCabStl, oStlCab1 ) // Multa
aAdd( aCabStl, oStlCab1 ) // Juros
aAdd( aCabStl, oStlCab1 ) // Total Pago
aAdd( aCabStl, oStlCab1 ) // historico
aAdd( aCabStl, oStlCab1 ) // Natureza
aAdd( aCabStl, oStlCab1 ) // Descricao
aAdd( aCabStl, oStlCab1 ) //TIPO DE PGTO
aAdd( aCabStl, oStlCab1 ) //BANCO
aAdd( aCabStl, oStlCab1 ) //AGENCIA
aAdd( aCabStl, oStlCab1 ) //CONTA	
aAdd( aCabStl, oStlCab1 ) //PIX


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

    cCgc:= Transform((cTMP1)->A2_CGC,IIF((cTMP1)->A2_TIPO=="J","@R 99.999.999/9999-99","@R 999.999.999-99")) // CNPJ

    nScan := ASCAN(aRetSx3,{|X| X[2] ==  (cTMP1)->E2_XCCRED }) 
    cRet:=''
    IF nScan > 0
        cRet:= aRetSx3[nScan][3]
    END


    nVlrPIS  := (cTMP1)->E2_VRETPIS
    nVlrCOF  := (cTMP1)->E2_VRETCOF
    nVlrIRRF := (cTMP1)->E2_VRETIRF
    nVlrCSLL := (cTMP1)->E2_VRETCSL
    nVlrImp  := nVlrPIS + nVlrCOF + nVlrIRRF + nVlrCSLL
    nVlrLiq  := (cTMP1)->E2_VALOR//nVlrNF - nVlrImp // nVlrLiq  := (cTMP1)->E2_VALOR - SomaAbat((cTMP1)->E2_PREFIXO,(cTMP1)->E2_NUM,(cTMP1)->E2_PARCELA,'P',1,,(cTMP1)->E2_FORNECE,(cTMP1)->E2_LOJA)
    nVlrNF   := nVlrLiq + nVlrImp

    nVlrPag  := 0
    nVlrDesc := 0
    nMulta   := 0
    nJuros   := 0

    If !Empty((cTMP1)->E2_BAIXA)
        aRetPagtos := BuscaPagtos(;
            (cTMP1)->E2_PREFIXO,;
            (cTMP1)->E2_NUM,;
            (cTMP1)->E2_PARCELA,;
            (cTMP1)->E2_TIPO,;
            (cTMP1)->E2_FORNECE,;
            (cTMP1)->E2_LOJA;
        )

        nVlrPag  := aRetPagtos[1]
        nVlrDesc := aRetPagtos[2]
        nMulta   := aRetPagtos[3]
        nJuros   := aRetPagtos[4]
    EndIf

    aAdd( aRowDad, SToD((cTMP1)->E2_EMISSAO) ) // Data emissão
    aAdd( aRowDad, SToD((cTMP1)->E2_VENCREA) ) // Data vencimento
    aAdd( aRowDad, IIF(!Empty((cTMP1)->E2_BAIXA),SToD((cTMP1)->E2_BAIXA),"") ) // Data pagamento
    aAdd( aRowDad, IIF(Empty((cTMP1)->E2_BAIXA),dDatabase-SToD((cTMP1)->E2_VENCREA),SToD((cTMP1)->E2_BAIXA)-SToD((cTMP1)->E2_VENCREA)))  //IIf(Empty((cTMP1)->E1_XDTREC),"","=IFS(RC[-1]&lt;&gt;&quot;&quot;,0,RC[-2]&lt;=RC[-1],RC[-1]-RC[-2],RC[-1]&lt;RC[-2],0)" )) // Dias em atraso
  //aAdd( aRowDad, "=IFS(RC[-1]&lt;&gt;&quot;&quot;,0,RC[-2]&lt;=R1C16,R1C16-RC[-2],R1C16&lt;RC[-2],0)" ) // Dias em atraso

    aAdd( aRowDad, SToD((cTMP1)->E2_DATALIB) ) // Data liber
    aAdd( aRowDad, ALLTRIM( (cTMP1)->E2_USUALIB ) ) // Data liber

    aAdd( aRowDad, AllTrim((cTMP1)->A2_NREDUZ) ) // Fornecedor
    aAdd( aRowDad, AllTrim( cCgc ) ) // cpf

    aAdd( aRowDad, (cTMP1)->E2_NUMNOTA ) // No Nota Fiscal
    aAdd( aRowDad, (cTMP1)->E2_PREFIXO ) // Prefixo
    aAdd( aRowDad, (cTMP1)->E2_NUM) // No Título
    aAdd( aRowDad, (cTMP1)->E2_PARCELA) // Parcela
    aAdd( aRowDad, nVlrNF ) // Valor NF
    aAdd( aRowDad, (cTMP1)->E2_XVLRNF ) // historico

    aAdd( aRowDad, nVlrImp ) // Impostos
    aAdd( aRowDad, nVlrLiq ) // Líquido a Pagar
    aAdd( aRowDad, nVlrDesc ) // Descontos
    aAdd( aRowDad, nMulta ) // Multa
    aAdd( aRowDad, nJuros ) // Juros
    //aAdd( aRowDad, "=RC[-5]+RC[-2]+RC[-1]" ) // Total Pago
    aAdd( aRowDad, "=RC[-6]+RC[-2]+RC[-1]" ) // Total Pago

    aAdd( aRowDad, (cTMP1)->E2_HIST ) // historico
    aAdd( aRowDad, (cTMP1)->E2_NATUREZ ) // historico
    aAdd( aRowDad, Posicione("SED",1,xFilial("SED")+(cTMP1)->E2_NATUREZ,"ED_DESCRIC") ) // historico

    aAdd( aRowDad, cRet ) //TIPO DE PGTO
    aAdd( aRowDad, (cTMP1)->A2_BANCO ) //BANCO
    aAdd( aRowDad, (cTMP1)->A2_AGENCIA ) //AGENCIA
    aAdd( aRowDad, (cTMP1)->A2_NUMCON ) //CONTA	
    aAdd( aRowDad, (cTMP1)->A2_XPIX ) //PIX


    aAdd( aStl, oSN01Dat ) // Data emissão
    aAdd( aStl, oSN01Dat ) // Data vencimento
    aAdd( aStl, oSN01Dat ) // Data pagamento
    aAdd( aStl, oSN02Num ) // Dias em atraso

    aAdd( aStl, oSN01Dat ) // Data LIB
    aAdd( aStl, oSN03Txt ) // USER LIB

    aAdd( aStl, oSN03Txt ) // Fornecedor
    aAdd( aStl, oSN03Txt ) // cpf

    aAdd( aStl, oSN04Txt ) // No Nota Fiscal
    aAdd( aStl, oSN04Txt ) // Prefixo
    aAdd( aStl, oSN04Txt ) // No Título
    aAdd( aStl, oSN04Txt ) // Parcela
    aAdd( aStl, oSN05Num ) // Valor NF
    aAdd( aStl, oSN05Num ) // Valor bruto
    aAdd( aStl, oSN05Num ) // Impostos
    aAdd( aStl, oSN05Num ) // Líquido a Pagar
    aAdd( aStl, oSN05Num ) // Desconto
    aAdd( aStl, oSN05Num ) // Multa
    aAdd( aStl, oSN05Num ) // Juros
    aAdd( aStl, oSN06Num ) // Total Pago

    aAdd( aStl, oSN03Txt ) // hist
    aAdd( aStl, oSN03Txt ) // Natureza
    aAdd( aStl, oSN03Txt ) // Descricao

    aAdd( aStl, oSN03Txt ) //TIPO DE PGTO
    aAdd( aStl, oSN03Txt ) //BANCO
    aAdd( aStl, oSN03Txt ) //AGENCIA
    aAdd( aStl, oSN03Txt ) //CONTA	
    aAdd( aStl, oSN03Txt ) //PIX


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
    aAdd( aRowDad, "" ) // LIB
    aAdd( aRowDad, "" ) // LIB
    aAdd( aRowDad, "" ) // Fornecedor
    aAdd( aRowDad, "" ) // CPF
    aAdd( aRowDad, "" ) // No Nota Fiscal
    aAdd( aRowDad, "" ) // Prefixo
    aAdd( aRowDad, "" ) // No Título
    aAdd( aRowDad, "" ) // Parcela
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor bruto
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Impostos
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Líquido a Pagar
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Descontos
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Multa
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Juros
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Total Pago
    aAdd( aRowDad, "" ) // hist
    aAdd( aRowDad, "" ) // Natureza
    aAdd( aRowDad, "" ) // Descricao
    aAdd( aRowDad, "" ) //TIPO DE PGTO
    aAdd( aRowDad, "" ) //BANCO
    aAdd( aRowDad, "" ) //AGENCIA
    aAdd( aRowDad, "" ) //CONTA	
    aAdd( aRowDad, "" ) //PIX        

    aAdd( aStl, oSN07Txt ) // Data emissão
    aAdd( aStl, oSN07Txt ) // Data vencimento
    aAdd( aStl, oSN07Txt ) // Data pagamento
    aAdd( aStl, oSN07Txt ) // Dias em atraso
    aAdd( aStl, oSN07Txt ) // LIB
    aAdd( aStl, oSN07Txt ) // LIB
    aAdd( aStl, oSN07Txt ) // Fornecedor
    aAdd( aStl, oSN07Txt ) // CPF
    aAdd( aStl, oSN07Txt ) // No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // Prefixo
    aAdd( aStl, oSN07Txt ) // No Título
    aAdd( aStl, oSN07Txt ) // Parcela
    aAdd( aStl, oSN08Num ) // Valor NF
    aAdd( aStl, oSN08Num ) // Valor brto
    aAdd( aStl, oSN08Num ) // Impostos
    aAdd( aStl, oSN08Num ) // Líquido a Pagar
    aAdd( aStl, oSN08Num ) // Desconto
    aAdd( aStl, oSN08Num ) // Multa
    aAdd( aStl, oSN08Num ) // Juros
    aAdd( aStl, oSN08Num ) // Total Pago
    aAdd( aStl, oSN07Txt ) // hist
    aAdd( aStl, oSN07Txt ) // Natureza
    aAdd( aStl, oSN07Txt ) // Descricao
    aAdd( aStl, oSN07Txt ) //TIPO DE PGTO
    aAdd( aStl, oSN07Txt ) //BANCO
    aAdd( aStl, oSN07Txt ) //AGENCIA
    aAdd( aStl, oSN07Txt ) //CONTA	
    aAdd( aStl, oSN07Txt ) //PIX    
    
	oXML:AddRow( HeightRowTotal, aRowDad, aStl )

    nTotLin++
    oXML:SkipLine("12.75")

    nTotLin++
    oXML:AddRow( "15.00", {"Relatório de Aging list do Contas a Pagar"  , "", "", "" }, {oStlTit3, oStlTit3, oStlTit3, oStlTit3} )
    oXml:setMerge(, , , 3)

    nTotLin++
    oXML:AddRow( "15.00", {"Período"  , "", "", "A Pagar" }, {oStlCab1, oStlCab1, oStlCab1, oStlCab1} )
    oXml:setMerge(, , , 2)

        nTotLin++
    oXML:AddRow( "15.00", {"à Vencer"                    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-5]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-5]C,&quot;<=0&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-5]C[-1],&quot;&quot)"      }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 1 a 30 dias"     , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-6]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-6]C,&quot;&gt;0&quot,R[-"+cValToChar(nTotLin)+"]C:R[-6]C,&quot;&lt;31&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-6]C[-1],&quot;&quot)"     }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 31 a 60 dias"    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-7]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-7]C,&quot;&gt;30&quot,R[-"+cValToChar(nTotLin)+"]C:R[-7]C,&quot;&lt;61&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-7]C[-1],&quot;&quot)"    }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 61 a 90 dias"    , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-8]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-8]C,&quot;&gt;60&quot,R[-"+cValToChar(nTotLin)+"]C:R[-8]C,&quot;&lt;91&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-8]C[-1],&quot;&quot)"    }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos de 91 a 180 dias"   , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-9]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-9]C,&quot;&gt;90&quot,R[-"+cValToChar(nTotLin)+"]C:R[-9]C,&quot;&lt;181&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-9]C[-1],&quot;&quot)"   }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Vencidos acima de 180 dias"  , "", "", "=SUMIFS(R[-"+cValToChar(nTotLin)+"]C[12]:R[-10]C[12],R[-"+cValToChar(nTotLin)+"]C:R[-10]C,&quot;&gt;180&quot,R[-"+cValToChar(nTotLin)+"]C[-1]:R[-10]C[-1],&quot;&quot)"                                                        }, {oSN03Txt, oSN03Txt, oSN03Txt, oSN05Num} )
    oXml:setMerge(, , , 2)

    nTotLin++
    oXML:AddRow( "15.00", {"Total do Contas a Pagar"   , "", "", "=SUM(R[-6]C:R[-1]C)"}, {oSN07Txt, oSN07Txt, oSN07Txt, oSN08Num} )
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

cQuery += " 	,E2_DATALIB"+CRLF
cQuery += " 	,E2_USUALIB"+CRLF
cQuery += " 	,E2_XVLRNF"+CRLF

cQuery += " 	,E2_XCCRED"+CRLF
cQuery += " 	,A2_BANCO"+CRLF
cQuery += " 	,A2_AGENCIA"+CRLF
cQuery += " 	,A2_NUMCON"+CRLF
cQuery += " 	,A2_XFPGTO"+CRLF
cQuery += " 	,A2_XPIX"+CRLF
cQuery += " 	,A2_TIPO"+CRLF
cQuery += " 	,A2_CGC"+CRLF

cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 (NOLOCK) "+ CRLF
cQuery += " 	ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' "+ CRLF
cQuery += " 	AND SA2.A2_COD = SE2.E2_FORNECE "+ CRLF
cQuery += " 	AND SA2.A2_LOJA = SE2.E2_LOJA "+ CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "+ CRLF

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
If (cTipoCP == "1") //Em aberto
    cQuery += " 	AND SE2.E2_BAIXA = '' "+ CRLF
    cQuery += " 	AND SE2.E2_SALDO > 0 "+ CRLF
ElseIf (cTipoCP == "2") //Baixado
    cQuery += " 	AND SE2.E2_BAIXA <> '' "+ CRLF
    cQuery += " 	AND SE2.E2_SALDO < SE2.E2_VALOR "+ CRLF
EndIf

cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE2.E2_VENCREA ASC, SE2.E2_NUMNOTA "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFREL02.SQL", cQuery)
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
cQuery += " 	SUM(SE5.E5_VALOR) AS E5_VALOR "+ CRLF
cQuery += " 	,SUM(SE5.E5_VLDESCO) AS E5_VLDESCO "+ CRLF
cQuery += " 	,SUM(SE5.E5_VLMULTA) AS E5_VLMULTA "+ CRLF
cQuery += " 	,SUM(SE5.E5_VLJUROS) AS E5_VLJUROS "+ CRLF
cQuery += " FROM "+RetSqlName("SE5")+" SE5 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	SE5.E5_FILIAL = '"+xFilial("SE5")+"' "+ CRLF
cQuery += " 	AND SE5.E5_PREFIXO = '"+cPrefixo+"' "+ CRLF
cQuery += " 	AND SE5.E5_NUMERO = '"+cNumTit+"' "+ CRLF
cQuery += " 	AND SE5.E5_PARCELA = '"+cParcela+"' "+ CRLF
cQuery += " 	AND SE5.E5_TIPO = '"+cTipo+"' "+ CRLF
cQuery += " 	AND SE5.E5_CLIFOR = '"+cCodCli+"' "+ CRLF
cQuery += " 	AND SE5.E5_LOJA = '"+cLoja+"' "+ CRLF
cQuery += " 	AND SE5.E5_RECPAG = 'P' "+ CRLF
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
