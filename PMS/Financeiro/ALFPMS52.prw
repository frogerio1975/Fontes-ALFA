#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE C1_VEND     02
#DEFINE C1_NOMVEN   03
#DEFINE C1_VLRCOM   04
#DEFINE C1_EMPTY    05

#DEFINE C2_MARK     01
#DEFINE C2_PROPOS   02
#DEFINE C2_ADITIV   03
#DEFINE C2_CODCLI   04
#DEFINE C2_LOJCLI   05
#DEFINE C2_NOMCLI   06
#DEFINE C2_E1PREF   07
#DEFINE C2_E1NUM    08
#DEFINE C2_E1PARC   09
#DEFINE C2_E1TIPO   10
#DEFINE C2_E1BAIX   11
#DEFINE C2_VLRTIT   12
#DEFINE C2_IMPOST   13
#DEFINE C2_VLRLIQ   14
#DEFINE C2_COMISS   15
#DEFINE C2_VLRCOM   16
#DEFINE C2_HISTOR   17
#DEFINE C2_RECZ36   18
#DEFINE C2_TIPO     19
#DEFINE C2_PERIOD   20
#DEFINE C2_MOD      21
#DEFINE C2_EMPTY    22

STATIC lMark := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS52
Alimenta Extrato de Comissões.

@author  Wilson A. Silva Jr.
@since   02/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS52()

Local aAreaAtu  := GetArea()
Local aAreaZ36  := Z36->(GetArea())
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

aVendedor[1][C1_VEND]   := ""
aVendedor[1][C1_NOMVEN] := ""
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
aTitulo[1][C2_TIPO]   := ""
aTitulo[1][C2_PERIOD] := ""
aTitulo[1][C2_MOD]    := ""
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
	@ 010,020 MSGET oBaixaDe VAR dBaixaDe WHEN .T. OF oPanelAux FONT oFont12N PIXEL SIZE 060,010 HASBUTTON
	
	@ 001,100 SAY "Dt.Baixa ATE" OF oPanelAux FONT oFont12N PIXEL SIZE 050,010
	@ 010,100 MSGET oBaixaAte VAR dBaixaAte WHEN .T. OF oPanelAux FONT oFont12N PIXEL SIZE 060,010 HASBUTTON
	
	@ 002,180  BUTTON "Carregar" SIZE 060,020 FONT oFont20N PIXEL ACTION {|| FwMsgRun( ,{|| LoadDados() }, , "Por favor, aguarde. Carregando Dados..." ) } WHEN .T. OF oPanelAux

    @ 002,260  BUTTON "Pagar" SIZE 060,020 FONT oFont20N PIXEL ACTION {|| GeraPgto() } WHEN .T. OF oPanelAux
		
    oPanelAux := oLayer1:GetWinPanel("L2_COL1","L2_WIN1","LIN2")

	DEFINE FWBROWSE oBrowse1 DATA ARRAY ARRAY aVendedor /*LINE HEIGHT nLineHeight*/ OF oPanelAux
		
		//ADD LEGEND DATA {|| Empty(aVendedor[oBrowse1:nAt][PS_CHVINT]) }  COLOR "GREEN" 	TITLE "Documento Pendente" 	OF oBrowse1
		//ADD LEGEND DATA {|| !Empty(aVendedor[oBrowse1:nAt][PS_CHVINT]) } COLOR "RED" 	TITLE "Documento Integrado" OF oBrowse1
		
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_VEND]   } TITLE "Codigo" 	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1
		ADD COLUMN oColumn DATA {|| aVendedor[oBrowse1:nAt][C1_NOMVEN] } TITLE "Nome" 		    SIZE 20	TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse1
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
				
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_TIPO]   } TITLE "Tipo" 	        SIZE 10 TYPE "C" PICTURE "" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_PERIOD] } TITLE "Periodo" 	        SIZE 06 TYPE "C" PICTURE "" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_CODCLI] } TITLE "Cliente" 	        SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_LOJCLI] } TITLE "Loja" 	        SIZE 02 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_NOMCLI] } TITLE "Razão" 	        SIZE 20 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_MOD]    } TITLE "Modalidade" 	    SIZE 10 TYPE "C" PICTURE "" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRTIT] } TITLE "Vlr.Venda" 	    SIZE 10 TYPE "N" PICTURE "@E 999,999,999.99"  ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_IMPOST] } TITLE "Imposto" 	        SIZE 07 TYPE "N" PICTURE "@E 99.9999"       ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRLIQ] } TITLE "Vlr.Liquido" 	    SIZE 09 TYPE "N" PICTURE "@E 999,999,999.99"    ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_COMISS] } TITLE "(%)"              SIZE 05 TYPE "N" PICTURE "@E 99.99"         ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_VLRCOM] } TITLE "Comissão ($)"     SIZE 09 TYPE "N" PICTURE "@E 9,999,999.99"    ALIGN CONTROL_ALIGN_RIGHT   OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_E1BAIX] } TITLE "Dt.Baixa" 	    SIZE 08 TYPE "D" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_PROPOS] } TITLE "Proposta" 	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
        ADD COLUMN oColumn DATA {|| aTitulo[oBrowse2:nAt][C2_ADITIV] } TITLE "Aditivo"   	    SIZE 06 TYPE "C" PICTURE "@!" ALIGN CONTROL_ALIGN_LEFT    OF oBrowse2
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

RestArea(aAreaZ36)
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
Local aAreaZ36  := Z36->(GetArea())
Local cTMP1     := ""
Local cQuery    := ""
Local nPosVnd   := 0
Local aSetField := {}
Local aTitAux   := {}

aVendedor := {}
aComissao := {}
aTitulo   := {}

cQuery := " SELECT "+ CRLF
cQuery += "     Z36.Z36_FILIAL "+ CRLF
cQuery += "     ,Z36.Z36_TIPO "+ CRLF
cQuery += "     ,Z36.Z36_PERIOD "+ CRLF
cQuery += "     ,Z36.Z36_DTGERA "+ CRLF
cQuery += "     ,Z36.Z36_PROPOS "+ CRLF
cQuery += "     ,Z36.Z36_ADITIV "+ CRLF
cQuery += "     ,Z36.Z36_CODCLI "+ CRLF
cQuery += "     ,Z36.Z36_LOJCLI "+ CRLF
cQuery += "     ,Z36.Z36_MOD "+ CRLF
cQuery += "     ,Z36.Z36_VEND "+ CRLF
cQuery += "     ,Z36.Z36_E1PREF "+ CRLF
cQuery += "     ,Z36.Z36_E1NUM "+ CRLF
cQuery += "     ,Z36.Z36_E1PARC "+ CRLF
cQuery += "     ,Z36.Z36_E1TIPO "+ CRLF
cQuery += "     ,Z36.Z36_E1BAIX "+ CRLF
cQuery += "     ,Z36.Z36_VLRBRU "+ CRLF
cQuery += "     ,Z36.Z36_IMPOST "+ CRLF
cQuery += "     ,Z36.Z36_VLRLIQ "+ CRLF
cQuery += "     ,Z36.Z36_COMISS "+ CRLF
cQuery += "     ,Z36.Z36_VLRCOM "+ CRLF
cQuery += "     ,Z36.Z36_STATUS "+ CRLF
cQuery += "     ,Z36.Z36_E1HIST "+ CRLF
cQuery += "     ,SA3.A3_NOME "+ CRLF
cQuery += "     ,ISNULL(SA1.A1_NOME,'') AS A1_NOME "+ CRLF
cQuery += "     ,Z36.R_E_C_N_O_ AS RECZ36 "+ CRLF

cQuery += " FROM "+RetSqlName("Z36")+" Z36 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += "     ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += "     AND SA3.A3_COD = Z36.Z36_VEND "+ CRLF
cQuery += "     AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += "     ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += "     AND SA1.A1_COD = Z36.Z36_CODCLI "+ CRLF
cQuery += "     AND SA1.A1_LOJA = Z36.Z36_LOJCLI "+ CRLF
cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	Z36.Z36_FILIAL = '"+xFilial("Z36")+"' "+ CRLF
cQuery += " 	AND Z36.Z36_E1BAIX BETWEEN '"+DToS(dBaixaDe)+"' AND '"+DToS(dBaixaAte)+"' "+ CRLF
cQuery += "     AND Z36.Z36_STATUS IN ('1') "+ CRLF
cQuery += " 	AND Z36.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += "     Z36.Z36_VEND "+ CRLF
cQuery += "     ,Z36.Z36_CODCLI "+ CRLF
cQuery += "     ,Z36.Z36_LOJCLI "+ CRLF
cQuery += "     ,Z36.Z36_E1BAIX "+ CRLF

AADD( aSetField, { "Z36_DTGERA", "D", 08, 0 } )
AADD( aSetField, { "Z36_E1BAIX", "D", 08, 0 } )
AADD( aSetField, { "Z36_VLRBRU", "N", 12, 2 } )
AADD( aSetField, { "Z36_IMPOST", "N", 12, 4 } )
AADD( aSetField, { "Z36_VLRLIQ", "N", 12, 2 } )
AADD( aSetField, { "Z36_COMISS", "N", 12, 2 } )
AADD( aSetField, { "Z36_VLRCOM", "N", 12, 2 } )

cTMP1 := MPSysOpenQuery(cQuery,,aSetField)

While (cTMP1)->(!EOF())

    cChave := (cTMP1)->(Z36_VEND)
    
    nVlrTotal := 0

    AADD( aVendedor, Array(C1_EMPTY) )
    nPosVnd++

    aVendedor[nPosVnd][C1_VEND]   := (cTMP1)->Z36_VEND
    aVendedor[nPosVnd][C1_NOMVEN] := (cTMP1)->A3_NOME
    aVendedor[nPosVnd][C1_VLRCOM] := 0
    aVendedor[nPosVnd][C1_EMPTY]  := ""

    AADD( aComissao, {} )

    While (cTMP1)->(!EOF()) .And. cChave == (cTMP1)->(Z36_VEND)

        aTitAux := Array(C2_EMPTY)

        cPeriodo := IIF((cTMP1)->Z36_PERIOD=="M","Mensal","Trimestral")

        DO CASE
            CASE (cTMP1)->Z36_TIPO == "P"
                cTipoCom := "Proposta"
            CASE (cTMP1)->Z36_TIPO == "A"
                cTipoCom := "Apontamento"
            CASE (cTMP1)->Z36_TIPO == "B"
                cTipoCom := "Bonus"
            OTHERWISE
                cTipoCom := (cTMP1)->Z36_TIPO
        END CASE
        
        //1=Servicos;2=Produtos;3=Setup Cloud;4=Parcelas Mensais;5=Suporte Mensal
        DO CASE
            CASE (cTMP1)->Z36_MOD == "1"
                cModalidade := "Servicos"
            CASE (cTMP1)->Z36_MOD == "2"
                cModalidade := "Produtos"
            CASE (cTMP1)->Z36_MOD == "3"
                cModalidade := "Setup Cloud"
            CASE (cTMP1)->Z36_MOD == "4"
                cModalidade := "Parcelas Mensais"
            CASE (cTMP1)->Z36_MOD == "5"
                cModalidade := "Suporte Mensal"
            OTHERWISE
                cModalidade := (cTMP1)->Z36_MOD
        END CASE

        aTitAux[C2_MARK]   := "LBOK"
        aTitAux[C2_TIPO]   := cTipoCom
        aTitAux[C2_PERIOD] := cPeriodo
        aTitAux[C2_PROPOS] := (cTMP1)->Z36_PROPOS
        aTitAux[C2_ADITIV] := (cTMP1)->Z36_ADITIV
        aTitAux[C2_CODCLI] := (cTMP1)->Z36_CODCLI
        aTitAux[C2_LOJCLI] := (cTMP1)->Z36_LOJCLI
        aTitAux[C2_MOD]    := cModalidade
        aTitAux[C2_NOMCLI] := (cTMP1)->A1_NOME
        aTitAux[C2_E1PREF] := (cTMP1)->Z36_E1PREF
        aTitAux[C2_E1NUM ] := (cTMP1)->Z36_E1NUM
        aTitAux[C2_E1PARC] := (cTMP1)->Z36_E1PARC
        aTitAux[C2_E1TIPO] := (cTMP1)->Z36_E1TIPO
        aTitAux[C2_E1BAIX] := (cTMP1)->Z36_E1BAIX
        aTitAux[C2_VLRTIT] := (cTMP1)->Z36_VLRBRU
        aTitAux[C2_IMPOST] := (cTMP1)->Z36_IMPOST
        aTitAux[C2_VLRLIQ] := (cTMP1)->Z36_VLRLIQ
        aTitAux[C2_COMISS] := (cTMP1)->Z36_COMISS
        aTitAux[C2_VLRCOM] := (cTMP1)->Z36_VLRCOM
        aTitAux[C2_HISTOR] := (cTMP1)->Z36_E1HIST
        aTitAux[C2_RECZ36] := (cTMP1)->RECZ36
        aTitAux[C2_EMPTY]  := ""

        AADD( aComissao[nPosVnd], aTitAux )

        nVlrTotal += (cTMP1)->Z36_VLRCOM

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

RestArea(aAreaZ36)
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
Local cVendedor := aVendedor[oBrowse1:nAt][C1_VEND]
Local dDtVenc   := dDataBase
Local cHist     := CriaVar("E2_HIST",.F.)
Local nVlrComis := aVendedor[oBrowse1:nAt][C1_VLRCOM]
Local nItem

Local aEmpFat  := { "1=ALFA(07)", "2=MOOVE", "3=GNP", "4=ALFA(24)","5=CAMPINAS","6=COLABORACAO" }
Local cEmpFat  := "1"

If Aviso("Atencao","Deseja gerar o pagamento do "+AllTrim(aVendedor[oBrowse1:nAt][C1_NOMVEN])+" ?",{"Sim","Não"}) <> 1
	Return .F.
EndIf

//Filtros para Query
AADD( aBoxParam, {2,"Faturar por"   ,cEmpFat    ,aEmpFat,050,".F.",.T.} )
AADD( aBoxParam, {1,"Tipo"	        ,cTipo	    ,"","","05","",050,.F.} )
AADD( aBoxParam, {1,"Natureza"	    ,cNatureza	,"","","SED","",050,.F.} )
AADD( aBoxParam, {1,"Dt.Vencto"	    ,dDtVenc	,"","","","",050,.F.} )
AADD( aBoxParam, {1,"Historico"	    ,cHist	    ,"","","","",100,.F.} )

If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)

	cEmpFat   := aRetParam[01]
	cTipo     := aRetParam[02]
	cNatureza := aRetParam[03]
	dDtVenc   := aRetParam[04]
	cHist     := aRetParam[05]

    cCodFor := ""
    cLojFor := ""
    BuscaFor(cVendedor, @cCodFor, @cLojFor)

    // Verifica se o numero ja foi gravado
    cNumTit := GetSxeNum("SE2","E2_NUM")
    DbSelectArea("SE2")
    DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    While DbSeek(xFilial("SE2")+cPrefixo+cNumTit) .OR. !MayIUseCode(cMaySE2+cPrefixo+cNumTit)
        cNumTit := GetSxeNum("SE2","E2_NUM")
    EndDo

    FWMsgRun(, {|| lRetorno := GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis, cEmpFat) }, "Aguarde", "Gerando pagamento...")

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
                DbSelectArea("Z36")
                DbGoTo(aTitulo[nItem][C2_RECZ36])
                RecLock("Z36",.F.)
                    REPLACE Z36_E2PREF WITH cPrefixo
                    REPLACE Z36_E2NUM  WITH cNumTit
                    REPLACE Z36_E2PARC WITH cParcela
                    REPLACE Z36_E2TIPO WITH cTipo
                    REPLACE Z36_STATUS WITH "2"
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
Static Function GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis, cEmpFat)

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
AADD( aCposSE2, {"E2_EMPFAT"    ,cEmpFat			 		,Nil})

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

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaFor
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   07/11/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function BuscaFor(cVendedor, cCodFor, cLojFor)

Local aAreaAtu  := GetArea()
Local cTMP1     := ""
Local cQuery    := ""

cQuery := " SELECT "+ CRLF
cQuery += "     SA3.A3_FORNECE "+ CRLF
cQuery += "     ,SA3.A3_LOJA "+ CRLF
cQuery += " FROM "+RetSqlName("SA3")+" SA3 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SA3.A3_FILIAL = '"+xFilial("SA3")+"' "+ CRLF
cQuery += "     AND SA3.A3_COD = '"+cVendedor+"' "+ CRLF
cQuery += "     AND SA3.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    cCodFor := (cTMP1)->A3_FORNECE
    cLojFor := (cTMP1)->A3_LOJA
EndIf

(cTMP1)->(DbCloseArea())

RestArea(aAreaAtu)

Return .T.
