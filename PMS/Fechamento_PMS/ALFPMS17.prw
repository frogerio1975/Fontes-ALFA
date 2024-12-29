#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS17
 
Descricao: RELATORIO PRODUTOS X RECURSOS

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS17( cGrupo )


Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório PRODUTOS X RECURSOS -"+SZH->ZH_COMPETE+'-'+SZH->ZH_REVISAO
Local cNome 	:= "RelFechamento-"+SZH->ZH_COMPETE+'-'+SZH->ZH_REVISAO+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de Fechamento."
Local cExt 		:= "XLS"
Local nOpc 		:= 1 // 1 = gerar arquivo e abrir / 2 = somente gerar aquivo em disco
Local cMsgProc 	:= "Aguarde... gerando relatório..."
Private aEmpFat  := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
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

@author  Pedro Oliveira
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


If lRetorno
    oXML := ExcelXML():New()
    FwMsgRun( ,{|| oXML := GeraRelatorio(oXML) 	},, "Aguarde. Gerando relatório..." )
    //FwMsgRun( ,{|| oXML	:= GeraFiltro(oXML) 	},, "Aguarde. Gerando aba indicações de filtros..." )
        
    If oXML <> NIL
        //oXml:setFolder(2)
        oXml:setFolder(1)
        lRetorno := oXML:GetXML(cArquivo)
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraFiltro
Cria aba descrevendo filtros no relatorio.

@author  Pedro Oliveira
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

aRetSx3 := RetSX3Box(GetSX3Cache("ZH_EMPRESA", "X3_CBOX"),,,1)
nScan := ASCAN(aRetSx3,{|X| X[2] ==  SZH->ZH_EMPRESA }) 
cRet:=''
IF nScan > 0
    cRet:= aRetSx3[nScan][3]
END
oXml:AddRow(, {"Competencia"     , SZH->ZH_COMPETE }, aStl)
oXml:AddRow(, {"Revisao"         , SZH->ZH_REVISAO }, aStl)
oXml:AddRow(, {"Descrição"       , SZH->ZH_DESCRI  }, aStl)
oXml:AddRow(, {"Empresa"         , cRet            }, aStl)
oXml:AddRow(, {"Dt.Inicial"      , DTOC(SZH->ZH_DTINI  ) }, aStl)
oXml:AddRow(, {"Dt.Final"        , DTOC(SZH->ZH_DTFIM  ) }, aStl)
oXml:AddRow(, {"Dt.Pagto"        , DTOC(SZH->ZH_DTPAGTO) }, aStl)
    
oXml:SkipLine(1)

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraRelatorio
Gera relatorio do tipo categorias ou filiais.

@author  Pedro Oliveira
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
oXml:setFolderName("Fechamento_PMO")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "150" )//Código do produto
aAdd( aColSize, "150" )//Descrição
aAdd( aColSize, "150" )//Número de serie
aAdd( aColSize, "150" )//Garantia
aAdd( aColSize, "150" )//Recurso
aAdd( aColSize, "150" )//Status = disponível ou alocado
aAdd( aColSize, "150" )//Empresa

 

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Produtos x Recusrsos " ) // Código do produto
aAdd( aCabTit, "" ) // Descrição
aAdd( aCabTit, "" ) // Número de serie
aAdd( aCabTit, "" ) // Garantia
aAdd( aCabTit, "" ) // Recurso
aAdd( aCabTit, "" ) // Status = disponível ou alocado
aAdd( aCabTit, "" ) // Empresa


aTitStl := {}
aAdd( aTitStl, oStlTit ) // Código do produto
aAdd( aTitStl, oStlTit ) // Descrição
aAdd( aTitStl, oStlTit ) // Número de serie
aAdd( aTitStl, oStlTit ) // Garantia
aAdd( aTitStl, oStlTit ) // Recurso
aAdd( aTitStl, oStlTit ) // Status = disponível ou alocado
aAdd( aTitStl, oStlTit ) // Empresa

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 6)
//oXml:SetMerge( , 11, , 2)
//oXml:SetMerge( , 15, , 3)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

AADD( aCabDad ,"Código do produto")
AADD( aCabDad ,"Descrição")
AADD( aCabDad ,"Número de serie")
AADD( aCabDad ,"Garantia")
AADD( aCabDad ,"Recurso")
AADD( aCabDad ,"Status")
AADD( aCabDad ,"Empresa")

aCabStl := {}
aAdd( aCabStl, oStlCab1 ) // Código do produto
aAdd( aCabStl, oStlCab1 ) // Descrição
aAdd( aCabStl, oStlCab1 ) // Número de serie
aAdd( aCabStl, oStlCab1 ) // Garantia
aAdd( aCabStl, oStlCab1 ) // Recurso
aAdd( aCabStl, oStlCab1 ) // Status = disponível ou alocado
aAdd( aCabStl, oStlCab1 ) // Empresa


oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())


	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    cTMP2 := VldDisp((cTMP1)->B1_COD)

    aAdd( aRowDad, (cTMP1)->B1_COD ) 
    aAdd( aRowDad, (cTMP1)->B1_DESC ) 
    aAdd( aRowDad, (cTMP1)->B1_XNUMSER ) 
    aAdd( aRowDad, STOD((cTMP1)->B1_XDTGAR) ) 
    If !(cTMP2)->(Eof())
        aAdd( aRowDad, (cTMP2)->ZJ_NOME ) 
        aAdd( aRowDad, 'Alocado' ) 
    Else
        aAdd( aRowDad, '' ) 
        aAdd( aRowDad, 'Disponível' ) 
    End
    aAdd( aRowDad, aEmpFat[Val( (cTMP1)->B1_EMPFAT )] ) 
        
    aAdd( aStl, oSN03Txt ) // Código do produto
    aAdd( aStl, oSN03Txt ) // Descrição
    aAdd( aStl, oSN03Txt ) // Número de serie
    aAdd( aStl, oSN01Dat ) // Garantia
    aAdd( aStl, oSN03Txt ) // Recurso
    aAdd( aStl, oSN03Txt ) // Status = disponível ou alocado
    aAdd( aStl, oSN03Txt ) // Empresa
   
    
	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


nTotLin:= 0
If nTotLin > 0

	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "TOTAL" ) // 1Data emissão
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    
    aAdd( aStl, oSN07Txt ) // 1Data emissão
    aAdd( aStl, oSN08Num ) // 2Cliente
    aAdd( aStl, oSN08Num ) // 3CNPJ
    aAdd( aStl, oSN08Num ) // 4No Nota Fiscal
    aAdd( aStl, oSN08Num ) // 5Prefixo
    aAdd( aStl, oSN08Num ) // 6No Título
    aAdd( aStl, oSN08Num ) // 6No Título
    
    
	oXML:AddRow( HeightRowTotal, aRowDad, aStl )
EndIf

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Rotina para carregar os dados do relatorio via query.

@author  Pedro Oliveira
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados()

Local cTMP1  := ""
Local cQuery := ""

//cQuery := " SELECT ZJ_NOME,ZJ_PRODUTO,ZJ_DESC,ZJ_DTENT ,ZJ_DTDEV,ZJ_DTGAR ,B1_EMPFAT,B1_XDTGAR ,B1_XNUMSER "+ CRLF
cQuery := " SELECT B1_COD,B1_DESC,B1_EMPFAT,B1_XDTGAR ,B1_XNUMSER "+ CRLF
cQuery += " FROM "+RetSqlName("SB1")+" SB1 (NOLOCK) "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	B1_FILIAL = '"+xFilial("SB1")+"' "+ CRLF
cQuery += " 	AND B1_GRUPO = 'ESC' "+ CRLF
cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFPMS17.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Rotina para carregar os dados do relatorio via query.

@author  Pedro Oliveira
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldDisp( cProd )

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT ZJ_NOME,ZJ_PRODUTO,ZJ_DESC,ZJ_DTENT ,ZJ_DTDEV,ZJ_DTGAR  "+ CRLF
cQuery += " FROM "+RetSqlName("SB1")+" SB1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SZJ")+" SZJ (NOLOCK) "+ CRLF
cQuery += " 	ON  ZJ_FILIAL = '"+xFilial("SZJ")+"' "+ CRLF
cQuery += " 	AND ZJ_PRODUTO = B1_COD "+ CRLF
cQuery += " 	AND ZJ_DTDEV = ''  "+ CRLF
cQuery += " 	AND SZJ.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	B1_FILIAL = '"+xFilial("SB1")+"' "+ CRLF
cQuery += " 	AND B1_GRUPO = 'ESC' "+ CRLF
cQuery += " 	AND B1_COD = '"+cProd+"' "+ CRLF
cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "+ CRLF


cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
