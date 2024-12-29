#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE C1_CODFOR   02
#DEFINE C1_LOJFOR   03
#DEFINE C1_NOMFOR   04
#DEFINE C1_VLRCOM   05
#DEFINE C1_EMPTY    06

#DEFINE C2_MARK     01
#DEFINE C2_PROPOS   02
#DEFINE C2_CODCLI   03
#DEFINE C2_LOJCLI   04
#DEFINE C2_NOMCLI   05
#DEFINE C2_E1PREF   06
#DEFINE C2_E1NUM    07
#DEFINE C2_E1PARC   08
#DEFINE C2_E1TIPO   09
#DEFINE C2_E1BAIX   10
#DEFINE C2_VLRTIT   11
#DEFINE C2_IMPOST   12
#DEFINE C2_VLRLIQ   13
#DEFINE C2_COMISS   14
#DEFINE C2_VLRCOM   15
#DEFINE C2_HISTOR   16
#DEFINE C2_RECZ16   17
#DEFINE C2_EMPTY    18
#DEFINE C2_ADITIV   19

STATIC lMark := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS05
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS05()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local aSize	    := MsAdvSize()

Private oBaixaDe
Private oBaixaAte
Private oMemo

Private dBaixaDe 	:= SToD("")
Private dBaixaAte 	:= SToD("")
Private cMemo       := ""

Private aVendedor := {}
Private aComissao := {}
Private aTitulo   := {}

AADD( aVendedor, Array(C1_EMPTY) )

aVendedor[1][C1_CODFOR] := ""
aVendedor[1][C1_LOJFOR] := ""
aVendedor[1][C1_NOMFOR] := ""
aVendedor[1][C1_VLRCOM] := 0
aVendedor[1][C1_EMPTY]  := ""

AADD( aTitulo, Array(C2_EMPTY) )

aTitulo[1][C2_MARK]   := "LBNO"
aTitulo[1][C2_PROPOS] := ""
aTitulo[1][C2_ADITIV] := "00"
aTitulo[1][C2_CODCLI] := ""
aTitulo[1][C2_LOJCLI] := ""
aTitulo[1][C2_NOMCLI] := ""
aTitulo[1][C2_E1PREF] := ""
aTitulo[1][C2_E1NUM ] := ""
aTitulo[1][C2_E1PARC] := ""
aTitulo[1][C2_E1TIPO] := ""
aTitulo[1][C2_E1BAIX] := SToD("")
aTitulo[1][C2_VLRTIT] := 0
aTitulo[1][C2_IMPOST] := 0
aTitulo[1][C2_VLRLIQ] := 0
aTitulo[1][C2_COMISS] := 0
aTitulo[1][C2_VLRCOM] := 0
aTitulo[1][C2_HISTOR] := ""
aTitulo[1][C2_EMPTY]  := ""

AADD( aComissao, aTitulo )

DEFINE FONT oFont20N 	NAME "Arial"	SIZE 0,-20 BOLD
DEFINE FONT oFont12N 	NAME "Arial"	SIZE 0,-12 BOLD

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	oLayer1:= FWLayer():new()
	oLayer1:init(oDlg,.F.)
	
    oLayer1:addLine("LIN1",018,.F.)
    oLayer1:addLine("LIN2",082,.F.)

	oLayer1:addCollumn("L1_COL1",100,.T.,"LIN1")	
	oLayer1:addWindow("L1_COL1","L1_WIN1","Filtros",100,.F.,.F.,,"LIN1")

	oLayer1:addCollumn("L2_COL1",35,.T.,"LIN2")
	oLayer1:addCollumn("L2_COL2",65,.T.,"LIN2")
	
	oLayer1:addWindow("L2_COL1","L2_WIN1","Vendedor"	,100,.F.,.F.,,"LIN2")	
	
	oLayer1:addWindow("L2_COL2","L2_WIN2","Comissões"   ,070,.F.,.F.,,"LIN2")
	oLayer1:addWindow("L2_COL2","L2_WIN3","Histórico"	,030,.F.,.F.,,"LIN2")
		
	oPanelAux := oLayer1:GetWinPanel("L1_COL1","L1_WIN1","LIN1")
	
	@ 001,020 SAY "Dt.Baixa DE" OF oPanelAux FONT oFont12N PIXEL SIZE 050,010
	@ 010,020 MSGET oBaixaDe VAR dBaixaDe PICTURE "@E 999,999,999.99" WHEN .T. OF oPanelAux FONT oFont12N PIXEL SIZE 060,010 HASBUTTON
	
	@ 001,100 SAY "Dt.Baixa ATE" OF oPanelAux FONT oFont12N PIXEL SIZE 050,010
	@ 010,100 MSGET oBaixaAte VAR dBaixaAte PICTURE "@E 999,999,999.99" WHEN .T. OF oPanelAux FONT oFont12N PIXEL SIZE 060,010 HASBUTTON
	
	@ 002,180  BUTTON "Carregar" SIZE 060,020 FONT oFont20N PIXEL ACTION {|| FwMsgRun( ,{|| LoadDados() }, , "Por favor, aguarde. Carregando Dados..." ) } WHEN .T. OF oPanelAux

    @ 002,260  BUTTON "Pagar" SIZE 060,020 FONT oFont20N PIXEL ACTION {|| GeraPgto() } WHEN .T. OF oPanelAux
		
    oPanelAux := oLayer1:GetWinPanel("L2_COL1","L2_WIN1","LIN2")

	DEFINE FWBROWSE oBrowse1 DATA ARRAY ARRAY aVendedor /*LINE HEIGHT nLineHeight*/ OF oPanelAux
		
		//ADD LEGEND DATA {|| Empty(aVendedor[oBrowse1:nAt][PS_CHVINT]) }  COLOR "GREEN" 	TITLE "Documento Pendente" 	OF oBrowse1
		//ADD LEGEND DATA {|| !Empty(aVendedor[oBrowse1:nAt][PS_CHVINT]) } COLOR "RED" 	TITLE "Documento Integrado" OF oBrowse1
		
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_CODFOR] } TITLE "Codigo" 	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1
        ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_LOJFOR] } TITLE "Loja" 		    SIZE 02	TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_NOMFOR] } TITLE "Nome" 		    SIZE 20	TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_VLRCOM] } TITLE "Comissão ($)"   SIZE 10	TYPE "N" PICTURE "@E 9,999,999.99" ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse1
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_EMPTY]  } TITLE " " 		        SIZE 01 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1

        oBrowse1:SetChange( {|| AtuaTitulos() } )
		
		oBrowse1:DisableConfig()
		oBrowse1:DisableSeek()
		oBrowse1:DisableFilter()
		oBrowse1:DisableLocate()
		oBrowse1:DisableReport()		
		oBrowse1:Refresh()

	ACTIVATE FWBROWSE oBrowse1

    	
	oPanelAux := oLayer1:GetWinPanel("L2_COL2","L2_WIN3","LIN2")

    @ 5,5 GET oMemo VAR cMemo MEMO SIZE 200,145 OF oPanelAux PIXEL
	oMemo:Align := CONTROL_ALIGN_ALLCLIENT
	oMemo:bRClicked := {|| AllwaysTrue() }
	oMemo:oFont := oFont12N

		
    oPanelAux := oLayer1:GetWinPanel("L2_COL2","L2_WIN2","LIN2")
	
    DEFINE FWBROWSE oBrowse2 DATA ARRAY ARRAY aTitulo /*LINE HEIGHT nLineHeight*/ OF oPanelAux
		
		ADD MARKCOLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_MARK] } DOUBLECLICK {|| MarkReg(C2_MARK, oBrowse2, @aTitulo), AtuaTotal() } HEADERCLICK {|| MarkAll(C2_MARK, oBrowse2, @aTitulo), AtuaTotal() } OF oBrowse2
				
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_CODCLI] } TITLE "Cliente" 	        SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_LOJCLI] } TITLE "Loja" 	        SIZE 02 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_NOMCLI] } TITLE "Razão" 	        SIZE 20 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRTIT] } TITLE "Vlr.Titulo" 	    SIZE 10 TYPE "N" PICTURE "@E 9,999,999.99"  ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_IMPOST] } TITLE "Imposto" 	        SIZE 07 TYPE "N" PICTURE "@E 99.9999"       ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRLIQ] } TITLE "Vlr.Liquido" 	    SIZE 09 TYPE "N" PICTURE "@E 999,999.99"    ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_COMISS] } TITLE "(%)"              SIZE 05 TYPE "N" PICTURE "@E 99.99"         ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRCOM] } TITLE "Comissão ($)"     SIZE 09 TYPE "N" PICTURE "@E 999,999.99"    ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1BAIX] } TITLE "Dt.Baixa" 	    SIZE 08 TYPE "D" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_PROPOS] } TITLE "Proposta" 	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_ADITIV] } TITLE "Proposta" 	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1PREF] } TITLE "Prefixo" 	        SIZE 03 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1NUM]  } TITLE "Numero" 	        SIZE 09 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1PARC] } TITLE "Parcela" 	        SIZE 02 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1TIPO] } TITLE "Tipo" 	        SIZE 02 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_EMPTY]  } TITLE " " 	            SIZE 01 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        
        oBrowse2:SetChange( {|| cMemo := aTitulo[oBrowse2:nAt][C2_HISTOR], oMemo:Refresh() } )

		oBrowse2:DisableConfig()
		oBrowse2:DisableSeek()
		oBrowse2:DisableFilter()
		oBrowse2:DisableLocate()
		oBrowse2:DisableReport()		
		oBrowse2:Refresh()

	ACTIVATE FWBROWSE oBrowse2
			
ACTIVATE MSDIALOG oDlg

RestArea(aAreaZ16)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados()

Local aAreaAtu  := GetArea()
Local aAreaZ16  := Z16->(GetArea())
Local cTMP1     := ""
Local cQuery    := ""
Local nPosVnd   := 0
Local aSetField := {}
Local aTitAux   := {}

aVendedor := {}
aComissao := {}
aTitulo   := {}

cQuery := " SELECT "+ CRLF
cQuery += "     Z16.Z16_FILIAL "+ CRLF
cQuery += "     ,Z16.Z16_DTGERA "+ CRLF
cQuery += "     ,Z16.Z16_PROPOS "+ CRLF
cQuery += "     ,Z16.Z16_ADITIV "+ CRLF
cQuery += "     ,Z16.Z16_CODCLI "+ CRLF
cQuery += "     ,Z16.Z16_LOJCLI "+ CRLF
cQuery += "     ,Z16.Z16_CODFOR "+ CRLF
cQuery += "     ,Z16.Z16_LOJFOR "+ CRLF
cQuery += "     ,Z16.Z16_E1PREF "+ CRLF
cQuery += "     ,Z16.Z16_E1NUM "+ CRLF
cQuery += "     ,Z16.Z16_E1PARC "+ CRLF
cQuery += "     ,Z16.Z16_E1TIPO "+ CRLF
cQuery += "     ,Z16.Z16_E1BAIX "+ CRLF
cQuery += "     ,Z16.Z16_VLRTIT "+ CRLF
cQuery += "     ,Z16.Z16_IMPOST "+ CRLF
cQuery += "     ,Z16.Z16_VLRLIQ "+ CRLF
cQuery += "     ,Z16.Z16_COMISS "+ CRLF
cQuery += "     ,Z16.Z16_VLRCOM "+ CRLF
cQuery += "     ,Z16.Z16_STATUS "+ CRLF
cQuery += "     ,Z16.Z16_E1HIST "+ CRLF
cQuery += "     ,SA2.A2_NOME "+ CRLF
cQuery += "     ,SA1.A1_NOME "+ CRLF
cQuery += "     ,Z16.R_E_C_N_O_ AS RECZ16 "+ CRLF

cQuery += " FROM "+RetSqlName("Z16")+" Z16 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 (NOLOCK) "+ CRLF
cQuery += "     ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' "+ CRLF
cQuery += "     AND SA2.A2_COD = Z16.Z16_CODFOR "+ CRLF
cQuery += "     AND SA2.A2_LOJA = Z16.Z16_LOJFOR "+ CRLF
cQuery += "     AND SA2.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += "     ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += "     AND SA1.A1_COD = Z16.Z16_CODCLI "+ CRLF
cQuery += "     AND SA1.A1_LOJA = Z16.Z16_LOJCLI "+ CRLF
cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z16.Z16_FILIAL = '"+xFilial("Z16")+"' "+ CRLF
cQuery += " 	AND Z16.Z16_E1BAIX BETWEEN '"+DToS(dBaixaDe)+"' AND '"+DToS(dBaixaAte)+"' "+ CRLF
cQuery += "     AND Z16.Z16_STATUS IN ('1') "+ CRLF
cQuery += " 	AND Z16.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += "     Z16.Z16_CODFOR "+ CRLF
cQuery += "     ,Z16.Z16_LOJFOR "+ CRLF
cQuery += "     ,Z16.Z16_CODCLI "+ CRLF
cQuery += "     ,Z16.Z16_LOJCLI "+ CRLF
cQuery += "     ,Z16.Z16_E1BAIX "+ CRLF

AADD( aSetField, { "Z16_DTGERA", "D", 08, 0 } )
AADD( aSetField, { "Z16_E1BAIX", "D", 08, 0 } )
AADD( aSetField, { "Z16_VLRTIT", "N", 12, 2 } )
AADD( aSetField, { "Z16_IMPOST", "N", 12, 4 } )
AADD( aSetField, { "Z16_VLRLIQ", "N", 12, 2 } )
AADD( aSetField, { "Z16_COMISS", "N", 12, 2 } )
AADD( aSetField, { "Z16_VLRCOM", "N", 12, 2 } )

cTMP1 := MPSysOpenQuery(cQuery,,aSetField)

While (cTMP1)->(!EOF())

    cChave := (cTMP1)->(Z16_CODFOR+Z16_LOJFOR)
    
    nVlrTotal := 0

    AADD( aVendedor, Array(C1_EMPTY) )
    nPosVnd++

    aVendedor[nPosVnd][C1_CODFOR] := (cTMP1)->Z16_CODFOR
    aVendedor[nPosVnd][C1_LOJFOR] := (cTMP1)->Z16_LOJFOR
    aVendedor[nPosVnd][C1_NOMFOR] := (cTMP1)->A2_NOME
    aVendedor[nPosVnd][C1_VLRCOM] := 0
    aVendedor[nPosVnd][C1_EMPTY]  := ""

    AADD( aComissao, {} )

    While (cTMP1)->(!EOF()) .And. cChave == (cTMP1)->(Z16_CODFOR+Z16_LOJFOR)

        aTitAux := Array(C2_EMPTY)

        aTitAux[C2_MARK]   := "LBOK"
        aTitAux[C2_PROPOS] := (cTMP1)->Z16_PROPOS
        aTitAux[C2_ADITIV] := (cTMP1)->Z16_ADITIV
        aTitAux[C2_CODCLI] := (cTMP1)->Z16_CODCLI
        aTitAux[C2_LOJCLI] := (cTMP1)->Z16_LOJCLI
        aTitAux[C2_NOMCLI] := (cTMP1)->A1_NOME
        aTitAux[C2_E1PREF] := (cTMP1)->Z16_E1PREF
        aTitAux[C2_E1NUM ] := (cTMP1)->Z16_E1NUM
        aTitAux[C2_E1PARC] := (cTMP1)->Z16_E1PARC
        aTitAux[C2_E1TIPO] := (cTMP1)->Z16_E1TIPO
        aTitAux[C2_E1BAIX] := (cTMP1)->Z16_E1BAIX
        aTitAux[C2_VLRTIT] := (cTMP1)->Z16_VLRTIT
        aTitAux[C2_IMPOST] := (cTMP1)->Z16_IMPOST
        aTitAux[C2_VLRLIQ] := (cTMP1)->Z16_VLRLIQ
        aTitAux[C2_COMISS] := (cTMP1)->Z16_COMISS
        aTitAux[C2_VLRCOM] := (cTMP1)->Z16_VLRCOM
        aTitAux[C2_HISTOR] := (cTMP1)->Z16_E1HIST
        aTitAux[C2_RECZ16] := (cTMP1)->RECZ16
        aTitAux[C2_EMPTY]  := ""

        AADD( aComissao[nPosVnd], aTitAux )

        nVlrTotal += (cTMP1)->Z16_VLRCOM

        (cTMP1)->(DbSkip())
    EndDo

    aVendedor[nPosVnd][C1_VLRCOM] := nVlrTotal
EndDo

(cTMP1)->(DbCloseArea())

If Len(aVendedor) > 0
    aTitulo := aComissao[1]

    oBrowse1:SetArray(aVendedor)
    oBrowse1:Refresh(.T.)

    oBrowse2:SetArray(aTitulo)
    oBrowse2:Refresh(.T.)

    cMemo := aTitulo[1][C2_HISTOR]
    oMemo:Refresh()
EndIf

RestArea(aAreaZ16)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuaTitulos()

If Type("oBrowse2") == "O"
    aTitulo := aComissao[oBrowse1:nAt]
    oBrowse2:SetArray(aTitulo)
    oBrowse2:Refresh(.T.)

    cMemo := aTitulo[oBrowse2:nAt][C2_HISTOR]
    oMemo:Refresh()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkReg
Rotina de marcar e desmarcar da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MarkReg(nPos, oBrowse, aDados)

Local cFlag := aDados[oBrowse:nAt][nPos]

If cFlag == "LBNO"
	cFlag := "LBOK"
Else
	cFlag := "LBNO"
EndIf

aDados[oBrowse:nAt][nPos] := cFlag

oBrowse:SetArray(aDados)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MarkAll(nPos, oBrowse, aDados)

Local cFlag := IIF( lMark, "LBOK", "LBNO" )
Local nItem

For nItem := 1 To Len(aDados)
	aDados[nItem][nPos] := cFlag
Next nItem

oBrowse:SetArray(aDados)
oBrowse:Refresh(.T.)

lMark := !lMark

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuaTotal()

Local nTotal := 0
Local nItem  := 0

For nItem := 1 To Len(aTitulo)
    If aTitulo[nItem][C2_MARK] == "LBOK"
        nTotal += aTitulo[nItem][C2_VLRCOM]
    EndIf
Next nItem

aVendedor[oBrowse1:nAt][C1_VLRCOM] := nTotal

oBrowse1:SetArray(aVendedor)
oBrowse1:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GeraPgto()

Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local lRetorno  := .F.
Local nSaveSX8 	:= GetSX8Len()
Local cMaySE2 	:= "SE2"+AllTrim(xFilial("SE2"))
Local aBoxParam := {}
Local aRetParam := {}
Local cPrefixo	:= "COM"
Local cNumTit   := ""
Local cParcela  := StrZero(1, TamSx3("E2_PARCELA")[1])
Local cTipo		:= "DP "
Local cNatureza := Padr(GetMV("AL_NATCOMI","020103"),TamSx3("E2_NATUREZ")[1])
Local cCodFor   := aVendedor[oBrowse1:nAt][C1_CODFOR]
Local cLojFor   := aVendedor[oBrowse1:nAt][C1_LOJFOR]
Local dDtVenc   := dDataBase
Local cHist     := CriaVar("E2_HIST",.F.)
Local nVlrComis := aVendedor[oBrowse1:nAt][C1_VLRCOM]
Local nItem

If Aviso("Atencao","Deseja gerar o pagamento do "+AllTrim(aVendedor[oBrowse1:nAt][C1_NOMFOR])+" ?",{"Sim","Não"}) <> 1
	Return .F.
EndIf

//Filtros para Query
//AADD( aBoxParam, {1,"Prefixo"	    ,cPrefixo	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Tipo"	        ,cTipo	    ,"","","05","",050,.F.} )
AADD( aBoxParam, {1,"Natureza"	    ,cNatureza	,"","","SED","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Vencto"	    ,dDtVenc	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Historico"	    ,cHist	    ,"","","","",100,.F.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	//cPrefixo  := aRetParam[01]
	cTipo     := aRetParam[01]
	cNatureza := aRetParam[02]
	dDtVenc   := aRetParam[03]
	cHist     := aRetParam[04]

    // Verifica se o numero ja foi gravado
    cNumTit := GetSxeNum("SE2","E2_NUM")
    DbSelectArea("SE2")
    DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    While DbSeek(xFilial("SE2")+cPrefixo+cNumTit) .OR. !MayIUseCode(cMaySE2+cPrefixo+cNumTit)
        cNumTit := GetSxeNum("SE2","E2_NUM")
    EndDo

    FWMsgRun(, {|| lRetorno := GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis) }, "Aguarde", "Gerando pagamento...")

    If lRetorno
        EvalTrigger()

        While GetSX8Len() > nSaveSX8
            ConfirmSX8()
        EndDo
    Else
        While GetSX8Len() > nSaveSX8
            RollBackSX8()
        EndDo
    EndIf

    // Libera numeros reservados (MayIUseCode)
    FreeUsedCode()

    If lRetorno
        For nItem := 1 To Len(aTitulo)
            If aTitulo[nItem][C2_MARK] == "LBOK"
                DbSelectArea("Z16")
                DbGoTo(aTitulo[nItem][C2_RECZ16])
                RecLock("Z16",.F.)
                    REPLACE Z16_E2PREF WITH cPrefixo
                    REPLACE Z16_E2NUM  WITH cNumTit
                    REPLACE Z16_E2PARC WITH cParcela
                    REPLACE Z16_E2TIPO WITH cTipo
                    REPLACE Z16_STATUS WITH "2"
                MsUnlock()
            EndIf
        Next nItem

        FwMsgRun( ,{|| LoadDados() }, , "Por favor, aguarde. Carregando Dados..." )
    EndIf
EndIf

RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis)

Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aCposSE2	:= {}
Local nOpcao    := 3 // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
Local lRetorno  := .T.

Private lMsErroAuto	    := .F.
Private lMsHelpAuto 	:= .T.
//Private lAutoErrNoFile 	:= .T.

AADD( aCposSE2, {"E2_FILIAL" 	,xFilial("SE2")				,Nil})
AADD( aCposSE2, {"E2_PREFIXO" 	,cPrefixo 					,Nil})
AADD( aCposSE2, {"E2_NUM"	   	,cNumTit					,Nil})
AADD( aCposSE2, {"E2_PARCELA" 	,cParcela	  	            ,Nil})
AADD( aCposSE2, {"E2_TIPO"		,cTipo						,Nil})
AADD( aCposSE2, {"E2_NATUREZ" 	,cNatureza   		        ,Nil})
AADD( aCposSE2, {"E2_FORNECE" 	,cCodFor	  				,Nil})
AADD( aCposSE2, {"E2_LOJA"	   	,cLojFor   					,Nil})
AADD( aCposSE2, {"E2_EMISSAO" 	,dDataBase     				,Nil})
AADD( aCposSE2, {"E2_VENCTO"	,dDtVenc  					,Nil})
AADD( aCposSE2, {"E2_VENCREA" 	,DataValida(dDtVenc,.T.)	,Nil}) 
AADD( aCposSE2, {"E2_HIST" 		,cHist                      ,Nil})
AADD( aCposSE2, {"E2_VALOR"		,nVlrComis			 		,Nil})
AADD( aCposSE2, {"E2_XVLRNF"	,nVlrComis			 		,Nil})
AADD( aCposSE2, {"E2_ORIGEM"	,"FINA050"					,Nil})

BEGIN TRANSACTION

    //Gravacao do Titulo a Pagar
    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCposSE2,, nOpcao)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

    If lMsErroAuto
        DisarmTransaction()
        lRetorno := .F.

        MostraErro()
        /*
        aErro 	 := GetAutoGrLog()
        cMsgErro := ""

        For nX := 1 To Len(aErro)
            cMsgErro += aErro[nX] + CRLF
        Next nX
        */
    EndIf

END TRANSACTION

RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return lRetorno
