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
/*/{Protheus.doc} ALFPMS12
 
Descricao: RELATORIO FECHAMENTO PMS

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS12( cGrupo )


Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Fechamento PMS -"+SZH->ZH_COMPETE+'-'+SZH->ZH_REVISAO
Local cNome 	:= "RelFechamento-"+SZH->ZH_COMPETE+'-'+SZH->ZH_REVISAO+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de Fechamento."
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

@author  Pedro Oliveira
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraExl(cArquivo)


Local lRetorno 	:= .T.
Local oXML
private aParamBox := {}
private aRetParam := {}
Private nFolder  := 1 // Pasta onde o relatorio sera gerado

// Parametros
//Private cRecurso  := CriaVar("ZI_RECURSO",.F.)
Private cCompIni  := CriaVar("ZH_COMPETE",.F.)
Private cCompFim  := CriaVar("ZH_COMPETE",.F.)
Private cRevIni   := CriaVar("ZH_REVISAO",.F.) 
Private cRevFim   := CriaVar("ZH_REVISAO",.F.) 
Private cEmpFat  := "1"
Private dEmisIni := CriaVar("E2_EMISSAO",.F.)
Private dEmisFim := CriaVar("E2_EMISSAO",.F.)
Private dPgtIni := CriaVar("E2_EMISSAO",.F.)
Private dPgtFim := CriaVar("E2_EMISSAO",.F.)

Private aEmpFat  := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }

//aAdd( aParamBox, { 1, "Recurso:"	 , cRecurso,  , '.T.', "AE8"   , "", 50, .T.} )
aAdd( aParamBox, { 1, "Competencia Inicio:" , cCompIni , , '.T.', "SZG"   , "", 50, .f.} )
aAdd( aParamBox, { 1, "Competencia Final:"  , cCompFim , , '.T.', "SZG"   , "", 50, .T.} )
aAdd( aParamBox, { 1, "Revisao Inicio:" , cRevIni , , '.T.', ""   , "", 50, .f.} )
aAdd( aParamBox, { 1, "Revisao Final:"  , cRevFim , , '.T.', ""   , "", 50, .T.} )
AADD( aParamBox, { 1, "Emissão DE"      , dEmisIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aParamBox, { 1, "Emissão ATE"     , dEmisFim  , "@!", "", ""   , "", 50, .F.} )
AADD( aParamBox, { 1, "Pagamento DE"      , dPgtIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aParamBox, { 1, "Pagamento ATE"     , dPgtFim  , "@!", "", ""   , "", 50, .F.} )

//AADD( aParamBox, { 2, "Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )

IF ParamBox(aParamBox,"Informe o recurso para Filtro",@aRetParam)

    cCompIni := aRetParam[1]
    cCompFim := aRetParam[2]
    cRevIni  := aRetParam[3]
    cRevFim  := aRetParam[4]
    dEmisIni := aRetParam[5]
    dEmisFim := aRetParam[6]
    dPgtIni  := aRetParam[7]
    dPgtFim  := aRetParam[8]

    oXML := ExcelXML():New()
    FwMsgRun( ,{|| oXML := GeraRelatorio(oXML) 	},, "Aguarde. Gerando relatório..." )
    FwMsgRun( ,{|| oXML	:= GeraFiltro(oXML) 	},, "Aguarde. Gerando aba indicações de filtros..." )
        
    If oXML <> NIL
        oXml:setFolder(2)
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
oXml:setFolderName("Fechamento")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "50" )//'Competência	')
aAdd( aColSize, "50" )//'Revisão')
aAdd( aColSize, "100" )//'Descrição')
aAdd( aColSize, "50" )//'Codigo')

aAdd( aColSize, "150" )//"Recurso"
aAdd( aColSize, "100" ) //"Valor Fixo"
aAdd( aColSize, "50" ) //"Horas Extras"
aAdd( aColSize, "50" ) //"Valor Extras"
aAdd( aColSize, "50" ) //"Horas de Descanso"
aAdd( aColSize, "50" ) //"Valor de Descanso"
aAdd( aColSize, "50" ) //"Reembolso"
aAdd( aColSize, "50" ) //"Total de Horas"
aAdd( aColSize, "50" ) //"Desontos"
aAdd( aColSize, "50" ) //"Adicionais"
aAdd( aColSize, "150" )//"OBS"
aAdd( aColSize, "150" ) //"Valor Total"

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório de Fechamento PMS" ) // Data emissão
aAdd( aCabTit, "" ) //'Competência	')
aAdd( aCabTit, "" ) //'Revisão')
aAdd( aCabTit, "" ) //'Descrição')
aAdd( aCabTit, "" ) //'Codigo')
aAdd( aCabTit, "" ) // Cliente
aAdd( aCabTit, "" ) // CNPJ
aAdd( aCabTit, "" ) // No Nota Fiscal
aAdd( aCabTit, "" ) // Prefixo
aAdd( aCabTit, "" ) // No Título
aAdd( aCabTit, "" ) // Parcela
aAdd( aCabTit, "" ) // Natureza Financeira
aAdd( aCabTit, "" ) // Centro de Custo
aAdd( aCabTit, "" ) // Valor NF
aAdd( aCabTit, "" ) // Tributo - ISS
aAdd( aCabTit, "" ) // Tributo - ISS

aTitStl := {}

aAdd( aTitStl, oStlTit ) // Competência
aAdd( aTitStl, oStlTit ) // revisao
aAdd( aTitStl, oStlTit ) // descr
aAdd( aTitStl, oStlTit ) // codigo

aAdd( aTitStl, oStlTit ) // Data emissão
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

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 11)
//oXml:SetMerge( , 11, , 2)
//oXml:SetMerge( , 15, , 3)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

AADD( aCabDad ,'Competência	')
AADD( aCabDad ,'Revisão')
AADD( aCabDad ,'Descrição')
AADD( aCabDad ,'Codigo')

AADD( aCabDad ,"Recurso")
AADD( aCabDad ,"Valor Fixo")
AADD( aCabDad ,"Horas Extras")
AADD( aCabDad ,"Valor de Extras")
AADD( aCabDad ,"Horas de Descanso")
AADD( aCabDad ,"Valor de Descanso")
AADD( aCabDad ,"Reembolso")
AADD( aCabDad ,"Total de Horas")
AADD( aCabDad ,"Desontos")
AADD( aCabDad ,"Adicionais")
AADD( aCabDad ,"OBS")
AADD( aCabDad ,"Valor Total")
aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // Competência
aAdd( aCabStl, oStlCab1 ) // revisao
aAdd( aCabStl, oStlCab1 ) // descr
aAdd( aCabStl, oStlCab1 ) // codigo

aAdd( aCabStl, oStlCab1 ) // Data emissão
aAdd( aCabStl, oStlCab1 ) // Cliente
aAdd( aCabStl, oStlCab1 ) // CNPJ
aAdd( aCabStl, oStlCab1 ) // No Nota Fiscal
aAdd( aCabStl, oStlCab1 ) // Prefixo
aAdd( aCabStl, oStlCab1 ) // No Título
aAdd( aCabStl, oStlCab1 ) // Parcela
aAdd( aCabStl, oStlCab1 ) // Natureza Financeira
aAdd( aCabStl, oStlCab1 ) // Centro de Custo
aAdd( aCabStl, oStlCab1 ) // Valor NF
aAdd( aCabStl, oStlCab1 ) // Tributo - ISS
aAdd( aCabStl, oStlCab1 ) // Tributo - ISS

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())

	// Meta
	aRowDad	:= {}
	aStl 	:= {}
    
    aAdd( aRowDad, (cTMP1)->ZH_COMPETE)
    aAdd( aRowDad, (cTMP1)->ZH_REVISAO)
    aAdd( aRowDad, (cTMP1)->ZH_DESCRI)
    aAdd( aRowDad, (cTMP1)->ZI_RECURSO)

    aAdd( aRowDad, (cTMP1)->ZI_NOME ) 

    If alltrim( (cTMP1)->ZI_TIPO) $ '3/4'
        aAdd( aRowDad, (cTMP1)->ZI_VLRHORA ) 			
    Else
        aAdd( aRowDad, (cTMP1)->ZI_FIXO ) 
    End    
    
    aAdd( aRowDad, (cTMP1)->ZI_HRSEXTR ) 
    aAdd( aRowDad, (cTMP1)->ZI_VLRHREX ) 

    aAdd( aRowDad, (cTMP1)->ZI_HRSDESC ) 
    aAdd( aRowDad, (cTMP1)->ZI_VLRDESC ) 

    aAdd( aRowDad, (cTMP1)->ZI_VLRREEM ) 
    aAdd( aRowDad, (cTMP1)->ZI_TOTHRS ) 

    aAdd( aRowDad, (cTMP1)->ZI_DESADIC ) 
    aAdd( aRowDad, (cTMP1)->ZI_VLRADC ) 

    aAdd( aRowDad, (cTMP1)->ZI_OBSADC ) 
    aAdd( aRowDad, (cTMP1)->ZI_VLRTOT ) 




    //aAdd( aRowDad, "=RC[-10]-RC[-5]-RC[-4]-RC[-3]-RC[-2]" ) // Líquido
    aAdd( aStl, oSN03Txt ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Data emissão
    aAdd( aStl, oSN03Txt ) // Data emissão

    aAdd( aStl, oSN03Txt ) // Data emissão
    aAdd( aStl, oSN05Num ) // Cliente
    aAdd( aStl, oSN05Num ) // CNPJ
    aAdd( aStl, oSN05Num ) // CNPJ
    aAdd( aStl, oSN05Num ) // No Nota Fiscal
    aAdd( aStl, oSN05Num ) // Prefixo
    aAdd( aStl, oSN05Num ) // No Título
    aAdd( aStl, oSN05Num ) // Parcela
    aAdd( aStl, oSN05Num ) // Natureza Financeira
    aAdd( aStl, oSN05Num ) // Centro de Custo
    aAdd( aStl, oSN03Txt ) // Valor NF
    aAdd( aStl, oSN05Num ) // Tributo - ISS
    
	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())


If nTotLin > 0

	aRowDad	:= {}
	aStl 	:= {}

    aAdd( aRowDad, "" ) // comp
    aAdd( aRowDad, "" ) // comp
    aAdd( aRowDad, "" ) // comp
    aAdd( aRowDad, "" ) // comp

    aAdd( aRowDad, "" ) // 1Data emissão
    aAdd( aRowDad, "" ) // 2Cliente
    aAdd( aRowDad, "" ) // 3CNPJ
    aAdd( aRowDad, "" ) // 4No Nota Fiscal
    aAdd( aRowDad, "" ) // 5Prefixo
    aAdd( aRowDad, "" ) // 6No Título
    aAdd( aRowDad, "" ) // 7Parcela
    aAdd( aRowDad, "" ) // 8Natureza Financeira
    aAdd( aRowDad, "" ) // 9Centro de Custo
    aAdd( aRowDad, "" ) // 0Centro de Custo
    aAdd( aRowDad, "TOTAL" ) // 1Centro de Custo    
    aAdd( aRowDad, "=SUM(R[-"+cValToChar(nTotLin)+"]C:R[-1]C)" ) // Valor NF
    
    aAdd( aStl, oSN07Txt ) //comp
    aAdd( aStl, oSN07Txt ) //comp
    aAdd( aStl, oSN07Txt ) //comp
    aAdd( aStl, oSN07Txt ) //comp

    aAdd( aStl, oSN07Txt ) // 1Data emissão
    aAdd( aStl, oSN07Txt ) // 2Cliente
    aAdd( aStl, oSN07Txt ) // 3CNPJ
    aAdd( aStl, oSN07Txt ) // 4No Nota Fiscal
    aAdd( aStl, oSN07Txt ) // 5Prefixo
    aAdd( aStl, oSN07Txt ) // 6No Título
    aAdd( aStl, oSN07Txt ) // 7Parcela
    aAdd( aStl, oSN07Txt ) // 8Natureza Financeira
    aAdd( aStl, oSN07Txt ) // 9Centro de Custo
    aAdd( aStl, oSN07Txt ) // 0Centro de Custo
    aAdd( aStl, oSN07Txt ) // 1Centro de Custo
    aAdd( aStl, oSN08Num ) // 2Valor NF
    
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

cQuery := " SELECT * "+ CRLF
cQuery += " FROM "+RetSqlName("SZI")+" SZI (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SZH")+" SZH (NOLOCK) "+ CRLF
cQuery += " 	ON SZH.ZH_FILIAL = '"+xFilial("SZH")+"' "+ CRLF
cQuery += " 	AND ZH_COMPETE =  ZI_COMPETE "+ CRLF
cQuery += " 	AND ZH_REVISAO = ZI_REVISAO "+ CRLF 
cQuery += " 	AND SZH.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	ZI_FILIAL = '"+xFilial("SZI")+"' "+ CRLF
cQuery += " 	AND ZI_COMPETE BETWEEN '"+cCompIni+"' AND '"+cCompFim+"' "+ CRLF
cQuery += " 	AND ZI_REVISAO BETWEEN '"+cRevIni+"' AND '"+cRevFim+"' "+ CRLF

cQuery += " 	AND ZH_DTINI >= '"+dtos(dEmisIni)+"'   "+ CRLF
cQuery += " 	AND ZH_DTFIM <= '"+dtos(dEmisFim)+"'   "+ CRLF

//cQuery += " 	AND ZH_DTINI BETWEEN '"+dtos(dEmisIni)+"' AND '"+dtos(dEmisIni)+"' "+ CRLF
//cQuery += " 	AND ZH_DTFIM BETWEEN '"+dtos(dEmisFim)+"' AND '"+dtos(dEmisFim)+"' "+ CRLF
cQuery += " 	AND ZH_DTPAGTO BETWEEN '"+dtos(dPgtIni)+"' AND '"+dtos(dPgtFim)+"' "+ CRLF

//ZH_EMPRESA
//1=ALFA CORPORIS;2=MOOVE CORPORIS;3=ALFA;4=MOOVE
//cEmpFat

cQuery += " 	AND SZI.D_E_L_E_T_ = ' ' "+ CRLF



// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFPMS12.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
