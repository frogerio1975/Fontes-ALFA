#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

// DEFINICAO DE TAMANHO DAS LINHAS DO RELATORIO
#DEFINE HeightRowTitulo "38.25"

#DEFINE HeightRowCab1 	"24.00"
#DEFINE HeightRowItem1 	"11.25"
#DEFINE HeightRowTotal  "12.00"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFART02
Relatório de validação apontamentos ARTIA.

@author  Wilson A. Silva Jr
@since   19/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFART02()

Local aArea 	:= GetArea()
Local cDir 		:= AllTrim(GetTempPath())
Local cArquivo 	:= "relatorio"
Local cTitulo 	:= "Relatório de Validação de Apontamentos ARTIA"
Local cNome 	:= "RelArtiaApont-"+DtoS(Date())+"-"+STRTRAN(TIME(),":","")
Local cDesc 	:= "Esta rotina tem como objetivo criar um arquivo no formato XML Excel contendo relatório de validação de apontamentos ARTIA."
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
@since   19/07/2021
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
Private dPerIni  := FirstDay(dDatabase)
Private dPerFim  := LastDay(dDatabase)

AADD( aBoxParam, {1,"Período DE"   , dPerIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Período ATE"  , dPerFim  , "@!", "", ""   , "", 50, .F.} )

If ParamBox(aBoxParam,"Parametros - Relatório ARTIA",@aRetParam,,,,,,,,.F.)

    dPerIni := aRetParam[1]
    dPerFim := aRetParam[2]

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
@since   19/07/2021
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

oXml:AddRow(, {"Período DE"   , DToC(dPerIni)   }, aStl)
oXml:AddRow(, {"Período ATE"  , DToC(dPerFim)   }, aStl)

oXml:SkipLine(1)

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraRelatorio
Gera relatorio do tipo categorias ou filiais.

@author  Wilson A. Silva Jr
@since   19/07/2021
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
oXml:setFolderName("Apontamentos")
oXml:showGridLine(.F.)
oXml:SetZoom(100)

aAdd( aColSize, "0" ) // apontamentoId
aAdd( aColSize, "0" ) // status
aAdd( aColSize, "50" ) // projetoId
aAdd( aColSize, "55" ) // projetoNumero
aAdd( aColSize, "200" ) // projetoNome
aAdd( aColSize, "200" ) // breadcrumb
aAdd( aColSize, "150" ) // usuarioRecurso
aAdd( aColSize, "50" ) // dataApontamento
aAdd( aColSize, "50" ) // horaInicio
aAdd( aColSize, "50" ) // horaFim
aAdd( aColSize, "50" ) // duracao
aAdd( aColSize, "0" ) // dataCriacao
aAdd( aColSize, "0" ) // dataAlteracao
aAdd( aColSize, "0" ) // atividadeId
aAdd( aColSize, "200" ) // atividadeTitulo
aAdd( aColSize, "0" ) // observacao
aAdd( aColSize, "60" ) // tipoAtendimento
aAdd( aColSize, "60" ) // AF8_PROJET
aAdd( aColSize, "50" ) // AF8_PROPOS
aAdd( aColSize, "200" ) // AF8_DESCRI
aAdd( aColSize, "0" ) // AF8_CLIENT
aAdd( aColSize, "0" ) // A1_NOME
aAdd( aColSize, "150" ) // A1_NREDUZ
aAdd( aColSize, "0" ) // A1_CGC
aAdd( aColSize, "50" ) // Validacao
aAdd( aColSize, "100" ) // Msg Erro

// Ajusta o tamanho das colunas da planilha.
oXML:SetColSize(aColSize)

aCabTit := {}

aAdd( aCabTit, "Relatório Validação de Apontamentos ARTIA" ) // apontamentoId
aAdd( aCabTit, "" ) // status
aAdd( aCabTit, "" ) // projetoId
aAdd( aCabTit, "" ) // projetoNumero
aAdd( aCabTit, "" ) // projetoNome
aAdd( aCabTit, "" ) // diretorio
aAdd( aCabTit, "" ) // usuarioRecurso
aAdd( aCabTit, "" ) // dataApontamento
aAdd( aCabTit, "" ) // horaInicio
aAdd( aCabTit, "" ) // horaFim
aAdd( aCabTit, "" ) // duracao
aAdd( aCabTit, "" ) // dataCriacao
aAdd( aCabTit, "" ) // dataAlteracao
aAdd( aCabTit, "" ) // atividadeId
aAdd( aCabTit, "" ) // atividadeTitulo
aAdd( aCabTit, "" ) // observacao
aAdd( aCabTit, "" ) // tipoAtendimento
aAdd( aCabTit, "" ) // AF8_PROJET
aAdd( aCabTit, "" ) // AF8_PROPOS
aAdd( aCabTit, "" ) // AF8_DESCRI
aAdd( aCabTit, "" ) // AF8_CLIENT
aAdd( aCabTit, "" ) // A1_NOME
aAdd( aCabTit, "" ) // A1_NREDUZ
aAdd( aCabTit, "" ) // A1_CGC
aAdd( aCabTit, "" ) // Validacao
aAdd( aCabTit, "" ) // Msg Erro

aTitStl := {}

aAdd( aTitStl, oStlTit ) // apontamentoId
aAdd( aTitStl, oStlTit ) // status
aAdd( aTitStl, oStlTit ) // projetoId
aAdd( aTitStl, oStlTit ) // projetoNumero
aAdd( aTitStl, oStlTit ) // projetoNome
aAdd( aTitStl, oStlTit ) // diretorio
aAdd( aTitStl, oStlTit ) // usuarioRecurso
aAdd( aTitStl, oStlTit ) // dataApontamento
aAdd( aTitStl, oStlTit ) // horaInicio
aAdd( aTitStl, oStlTit ) // horaFim
aAdd( aTitStl, oStlTit ) // duracao
aAdd( aTitStl, oStlTit ) // dataCriacao
aAdd( aTitStl, oStlTit ) // dataAlteracao
aAdd( aTitStl, oStlTit ) // atividadeId
aAdd( aTitStl, oStlTit ) // atividadeTitulo
aAdd( aTitStl, oStlTit ) // observacao
aAdd( aTitStl, oStlTit ) // tipoAtendimento
aAdd( aTitStl, oStlTit ) // AF8_PROJET
aAdd( aTitStl, oStlTit ) // AF8_PROPOS
aAdd( aTitStl, oStlTit ) // AF8_DESCRI
aAdd( aTitStl, oStlTit ) // AF8_CLIENT
aAdd( aTitStl, oStlTit ) // A1_NOME
aAdd( aTitStl, oStlTit ) // A1_NREDUZ
aAdd( aTitStl, oStlTit ) // A1_CGC
aAdd( aTitStl, oStlTit ) // Validacao
aAdd( aTitStl, oStlTit ) // Msg Erro

oXML:AddRow( HeightRowTitulo, aCabTit, aTitStl)

//oXml:SetMerge(nRow, nCol, nRowSize, nColSize)
oXml:SetMerge( , , , 6)

////////////////////////////////////////////////////////////////////////////////////////////

aCabDad := {}

aAdd( aCabDad, "Id Apontamento" ) // apontamentoId
aAdd( aCabDad, "Status" ) // status
aAdd( aCabDad, "Id Projeto" ) // projetoId
aAdd( aCabDad, "Numero do Projeto" ) // projetoNumero
aAdd( aCabDad, "Nome do Projeto" ) // projetoNome
aAdd( aCabDad, "Diretório" ) // diretorio
aAdd( aCabDad, "Recurso" ) // usuarioRecurso
aAdd( aCabDad, "Data Apontamento" ) // dataApontamento
aAdd( aCabDad, "Hora Inicio" ) // horaInicio
aAdd( aCabDad, "Hora Final" ) // horaFim
aAdd( aCabDad, "Duração (h)" ) // duracao
aAdd( aCabDad, "Data Criação" ) // dataCriacao
aAdd( aCabDad, "Data Alteração" ) // dataAlteracao
aAdd( aCabDad, "Id Atividade" ) // atividadeId
aAdd( aCabDad, "Título" ) // atividadeTitulo
aAdd( aCabDad, "Observação" ) // observacao
aAdd( aCabDad, "Tipo Atendimento" ) // tipoAtendimento
aAdd( aCabDad, "Projeto PMS" ) // AF8_PROJET
aAdd( aCabDad, "Proposta" ) // AF8_PROPOS
aAdd( aCabDad, "Nome Projeto PMS" ) // AF8_DESCRI
aAdd( aCabDad, "Cliente PMS" ) // AF8_CLIENT
aAdd( aCabDad, "Razão Social" ) // A1_NOME
aAdd( aCabDad, "Nome Fantasia" ) // A1_NREDUZ
aAdd( aCabDad, "CNPJ" ) // A1_CGC
aAdd( aCabDad, "Validação" ) // Validacao
aAdd( aCabDad, "Mensagem" ) // Msg Erro

aCabStl := {}

aAdd( aCabStl, oStlCab1 ) // apontamentoId
aAdd( aCabStl, oStlCab1 ) // status
aAdd( aCabStl, oStlCab1 ) // projetoId
aAdd( aCabStl, oStlCab1 ) // projetoNumero
aAdd( aCabStl, oStlCab1 ) // projetoNome
aAdd( aCabStl, oStlCab1 ) // diretorio
aAdd( aCabStl, oStlCab1 ) // usuarioRecurso
aAdd( aCabStl, oStlCab1 ) // dataApontamento
aAdd( aCabStl, oStlCab1 ) // horaInicio
aAdd( aCabStl, oStlCab1 ) // horaFim
aAdd( aCabStl, oStlCab1 ) // duracao
aAdd( aCabStl, oStlCab1 ) // dataCriacao
aAdd( aCabStl, oStlCab1 ) // dataAlteracao
aAdd( aCabStl, oStlCab1 ) // atividadeId
aAdd( aCabStl, oStlCab1 ) // atividadeTitulo
aAdd( aCabStl, oStlCab1 ) // observacao
aAdd( aCabStl, oStlCab1 ) // tipoAtendimento
aAdd( aCabStl, oStlCab1 ) // AF8_PROJET
aAdd( aCabStl, oStlCab1 ) // AF8_PROPOS
aAdd( aCabStl, oStlCab1 ) // AF8_DESCRI
aAdd( aCabStl, oStlCab1 ) // AF8_CLIENT
aAdd( aCabStl, oStlCab1 ) // A1_NOME
aAdd( aCabStl, oStlCab1 ) // A1_NREDUZ
aAdd( aCabStl, oStlCab1 ) // A1_CGC
aAdd( aCabStl, oStlCab1 ) // Validacao
aAdd( aCabStl, oStlCab1 ) // Msg Erro

oXML:AddRow(HeightRowCab1, aCabDad, aCabStl)

////////////////////////////////////////////////////////////////////////////////////////////

//oXML:SkipLine("12.75",oSSkipLine)

////////////////////////////////////////////////////////////////////////////////////////////

While (cTMP1)->(!EOF())

	// Meta
	aRowDad	:= {}
	aStl 	:= {}

    cValidacao := "OK"
    cMsgErro   := ""

    If Empty((cTMP1)->AF8_PROJET)
        cValidacao := "ERRO"
        cMsgErro   := "Numero de Projeto não localizado"
    EndIf

    If Empty((cTMP1)->AE8_RECURS)
        cValidacao := "ERRO"
        cMsgErro   += IIF(Empty(cMsgErro),"","; ") + "E-mail de Recurso não cadastrado"
    EndIf

    aAdd( aRowDad, (cTMP1)->apontamentoId )
    aAdd( aRowDad, (cTMP1)->status )
    aAdd( aRowDad, (cTMP1)->projetoId )
    aAdd( aRowDad, AllTrim((cTMP1)->projetoNumero) )
    aAdd( aRowDad, AllTrim((cTMP1)->projetoNome) )
    aAdd( aRowDad, AllTrim((cTMP1)->diretorio) )
    aAdd( aRowDad, AllTrim((cTMP1)->usuarioRecurso) )
    aAdd( aRowDad, (cTMP1)->dataApontamento )
    aAdd( aRowDad, StrTran(SubStr((cTMP1)->horaInicio,12,5),':','H') )
    aAdd( aRowDad, StrTran(SubStr((cTMP1)->horaFim,12,5),':','H') )
    aAdd( aRowDad, (cTMP1)->duracao )
    aAdd( aRowDad, (cTMP1)->dataCriacao )
    aAdd( aRowDad, (cTMP1)->dataAlteracao )
    aAdd( aRowDad, (cTMP1)->atividadeId )
    aAdd( aRowDad, AllTrim((cTMP1)->atividadeTitulo) )
    aAdd( aRowDad, AllTrim((cTMP1)->apontObs) )
    aAdd( aRowDad, AllTrim((cTMP1)->tipoAtendimento) )
    aAdd( aRowDad, (cTMP1)->AF8_PROJET )
    aAdd( aRowDad, (cTMP1)->AF8_PROPOS )
    aAdd( aRowDad, AllTrim((cTMP1)->AF8_DESCRI) )
    aAdd( aRowDad, (cTMP1)->AF8_CLIENT )
    aAdd( aRowDad, AllTrim((cTMP1)->A1_NOME) )
    aAdd( aRowDad, AllTrim((cTMP1)->A1_NREDUZ) )
    aAdd( aRowDad, Transform((cTMP1)->A1_CGC,"@R 99.999.999/9999-99") )
    aAdd( aRowDad, cValidacao ) // Validacao
    aAdd( aRowDad, cMsgErro ) // Msg Erro
    
    aAdd( aStl, oSN04Txt ) // apontamentoId
    aAdd( aStl, oSN04Txt ) // status
    aAdd( aStl, oSN04Txt ) // projetoId
    aAdd( aStl, oSN04Txt ) // projetoNumero
    aAdd( aStl, oSN03Txt ) // projetoNome
    aAdd( aStl, oSN03Txt ) // diretorio
    aAdd( aStl, oSN03Txt ) // usuarioRecurso
    aAdd( aStl, oSN01Dat ) // dataApontamento
    aAdd( aStl, oSN04Txt ) // horaInicio
    aAdd( aStl, oSN04Txt ) // horaFim
    aAdd( aStl, oSN04Txt ) // duracao
    aAdd( aStl, oSN04Txt ) // dataCriacao
    aAdd( aStl, oSN04Txt ) // dataAlteracao
    aAdd( aStl, oSN04Txt ) // atividadeId
    aAdd( aStl, oSN03Txt ) // atividadeTitulo
    aAdd( aStl, oSN03Txt ) // observacao
    aAdd( aStl, oSN03Txt ) // tipoAtendimento
    aAdd( aStl, oSN04Txt ) // AF8_PROJET
    aAdd( aStl, oSN04Txt ) // AF8_PROPOS
    aAdd( aStl, oSN03Txt ) // AF8_DESCRI
    aAdd( aStl, oSN04Txt ) // AF8_CLIENT
    aAdd( aStl, oSN03Txt ) // A1_NOME
    aAdd( aStl, oSN03Txt ) // A1_NREDUZ
    aAdd( aStl, oSN04Txt ) // A1_CGC
    aAdd( aStl, oSN03Txt ) // Validacao
    aAdd( aStl, oSN03Txt ) // Msg Erro

	oXML:AddRow( HeightRowItem1, aRowDad, aStl )

    nTotLin++

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return oXml

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Rotina para carregar os dados do relatorio via query.

@author  Wilson A. Silva Jr
@since   19/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados()

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT "+ CRLF
cQuery += "     artia.apontamentoId "+ CRLF
cQuery += "     ,artia.status "+ CRLF
cQuery += "     ,artia.projetoId "+ CRLF
cQuery += "     ,artia.projetoNumero "+ CRLF
cQuery += "     ,artia.projetoNome "+ CRLF
cQuery += " 	,CONVERT(varchar(255), artia.breadcrumb) as diretorio "+ CRLF
cQuery += "     ,artia.usuarioRecurso "+ CRLF
cQuery += "     ,artia.dataApontamento "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.horaInicio) as horaInicio "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.horaFim) as horaFim "+ CRLF
cQuery += "     ,artia.duracao "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.dataCriacao) as dataCriacao "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.dataAlteracao) as dataAlteracao "+ CRLF
cQuery += "     ,artia.atividadeId "+ CRLF
cQuery += "     ,CONVERT(varchar(255), artia.atividadeTitulo) as atividadeTitulo "+ CRLF
cQuery += " 	,artia.inicioEstimado as inicioEstimado "+ CRLF
cQuery += " 	,artia.finalEstimado as finalEstimado "+ CRLF
cQuery += " 	,artia.esforcoEstimado as esforcoEstimado "+ CRLF
cQuery += " 	,' ' as apontObs "+ CRLF //cQuery += " 	,CONVERT(varchar(255), artia.observacao) as apontObs "+ CRLF
cQuery += " 	,ISNULL(CONVERT(varchar(20), artia.tipoAtendimento),' ') as tipoAtendimento "+ CRLF
cQuery += "     ,AF8.AF8_PROJET "+ CRLF
cQuery += "     ,AF8.AF8_PROPOS "+ CRLF
cQuery += "     ,AF8.AF8_DESCRI "+ CRLF
cQuery += "     ,AF8.AF8_CLIENT "+ CRLF
cQuery += "     ,AF8.AF8_LOJA "+ CRLF
cQuery += "     ,SA1.A1_NOME "+ CRLF
cQuery += "     ,SA1.A1_NREDUZ "+ CRLF
cQuery += "     ,SA1.A1_CGC "+ CRLF
cQuery += "     ,AF8.AF8_DATA "+ CRLF
cQuery += "     ,AF8.AF8_HORAS "+ CRLF
cQuery += "     ,AF8.AF8_APORTE "+ CRLF
cQuery += "     ,AF8.AF8_CUSTO "+ CRLF
cQuery += "     ,AF8.AF8_REVISA "+ CRLF
cQuery += "     ,AF8.AF8_TPHORA "+ CRLF
cQuery += "     ,AF8.AF8_COORD "+ CRLF
cQuery += "     ,AF8.AF8_APROVA "+ CRLF
cQuery += "     ,AF8.AF8_TPSERV "+ CRLF
cQuery += "     ,AE8.AE8_RECURS "+ CRLF
cQuery += " FROM OPENQUERY( [ARTIA-ALFA], "+ CRLF
cQuery += "     'SELECT "+ CRLF
cQuery += "         apo.id as apontamentoId "+ CRLF
cQuery += "         ,apo.status as status "+ CRLF
cQuery += "         ,apo.folder_last_project_id as projetoId "+ CRLF
cQuery += "         ,prj.project_number as projetoNumero "+ CRLF
cQuery += "         ,prj.project_name as projetoNome "+ CRLF
cQuery += "         ,prj.breadcrumb as breadcrumb "+ CRLF
cQuery += "         ,apo.member_email as usuarioRecurso "+ CRLF
cQuery += "         ,apo.date_at as dataApontamento "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.start_time,''+00:00'',''-03:00'') as horaInicio "+ CRLF
cQuery += "         ,CONVERT_TZ(DATE_ADD(apo.start_time, INTERVAL (3600*apo.duration_hour) SECOND),''+00:00'',''-03:00'') as horaFim "+ CRLF
cQuery += "         ,apo.duration_hour as duracao "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.created_at,''+00:00'',''-03:00'') as dataCriacao "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.updated_at,''+00:00'',''-03:00'') as dataAlteracao "+ CRLF
cQuery += "         ,apo.activity_id as atividadeId "+ CRLF
cQuery += "         ,apo.activity_title as atividadeTitulo "+ CRLF
cQuery += " 	    ,act.estimated_start as inicioEstimado "+ CRLF
cQuery += " 	    ,act.estimated_end as finalEstimado "+ CRLF
cQuery += " 	    ,act.estimated_effort as esforcoEstimado "+ CRLF
cQuery += "         ,apo.observation as observacao "+ CRLF
cQuery += " 	    ,apo.atendimento as tipoAtendimento "+ CRLF
cQuery += "     FROM organization_103444_time_entries apo "+ CRLF
cQuery += "     LEFT JOIN organization_103444_projects prj "+ CRLF
cQuery += "         ON prj.id = apo.folder_last_project_id "+ CRLF
cQuery += "         AND prj.account_id = apo.account_id "+ CRLF
cQuery += "     LEFT JOIN organization_103444_activities act "+ CRLF
cQuery += "         ON act.id = apo.activity_id "+ CRLF
cQuery += "         AND act.account_id = apo.account_id "+ CRLF
cQuery += "     WHERE "+ CRLF
cQuery += "         apo.date_at BETWEEN ''"+Transform(DToS(dPerIni),"@R 9999-99-99")+"'' AND ''"+Transform(DToS(dPerFim),"@R 9999-99-99")+"'' "+ CRLF
cQuery += " ') artia "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("AF8")+" AF8 (NOLOCK) "+ CRLF
cQuery += " 	ON AF8.AF8_FILIAL = '"+xFilial("AF8")+"' "+ CRLF
cQuery += " 	AND AF8.AF8_PROJET = FORMAT(CONVERT(INT, artia.projetoNumero), '0000000000') "+ CRLF
cQuery += " 	AND AF8.AF8_PROJET <> '0000000000' "+ CRLF
cQuery += " 	AND AF8.AF8_DATA >= '20180101' "+ CRLF
cQuery += " 	AND AF8.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = AF8.AF8_CLIENT "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = AF8.AF8_LOJA "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("AE8")+" AE8 (NOLOCK) "+ CRLF
cQuery += "     ON AE8.AE8_FILIAL = '"+xFilial("AE8")+"' "+ CRLF
cQuery += "     AND AE8.AE8_EMAIL = artia.usuarioRecurso "+ CRLF
// cQuery += "     AND AE8.AE8_ATIVO = '1' "+ CRLF
cQuery += "     AND AE8.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	artia.apontamentoId "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFART02.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
