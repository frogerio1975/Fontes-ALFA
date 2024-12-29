
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

#DEFINE PS_MARKFT   01
#DEFINE PS_STATUS   02
#DEFINE PS_DESCRI   03
#DEFINE PS_NUMTIT   04
#DEFINE PS_DTVENC   05
#DEFINE PS_VLRTIT   06
#DEFINE PS_NUMNFE   07
#DEFINE PS_CODCLI   08
#DEFINE PS_LOJCLI   09
#DEFINE PS_NOMCLI   10
#DEFINE PS_MAILCL   11
#DEFINE PS_MSGENV   12
#DEFINE PS_DIASVE   13
#DEFINE PS_LINKNF   14
#DEFINE PS_HISTOR   15
#DEFINE PS_RECSE1   16
#DEFINE PS_RECSA1   17


Static lOpenCmc7
Static aPrefixo
Static lFDataUse
Static __lF070AltV
Static __F070VDATA
Static lFinImp
Static dLastPcc
Static __lRatAut
Static lMVGlosa
Static __lF070EAI
Static cAliasLote
Static lTSE5FI70E
Static lGEMSE5Grv
Static lSE5FI70E
Static lF070GerAb
Static lF070CTC
Static lF070EST
Static lF070EST2
Static lF070HisCan
Static __aVAAuto
Static lPodeTVA
Static lCpoSIX
Static lF070ACRE
Static lFA070POS
Static lF070TCTR
Static lFA070ACR
Static lF070ACONT
Static lF070CTB
Static lSACI008
Static __lF70TREA
Static __lCancTBx
// Motor de retenção
Static __lTemMR		:= NIL
Static __nTotImp		:= 0
Static nOldImp 		:= 0
Static __oRetMot 		as Object
Static __lMotor 		as Logical
Static __lPccMR		as Logical
Static __lInsMR		as Logical
Static __lIrfMR		as Logical
Static __lIssMR		as Logical
Static __lImpMR  		as Logical 
Static __lPropPcc 	as Logical
Static __lGlosaMr 	as Logical // Substituição da usabilidade do parâmetro MV_GLOSA pela configuração FKM_PGTPAR
Static __lGlosIrf 	as Logical
Static __lGlosPis 	as Logical
Static __lGlosCof 	as Logical
Static __lGlosCsl 	as Logical
Static __lGlosIss 	as Logical
Static __lGlosIns 	as Logical
Static __lGlosOut 	as Logical
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS61
Envio de Lembre de Vencimento aos Clientes.

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS61()

Local aAreaAtu  := GetArea()
Local aBoxParam := {}

Local aFaturas  := {}

Private lMark     := .F.
Private aEmpFat   := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
Private aBaixas   := { "1=NORMAL" , "2=DACAO" }//,"3=DEVOLUCAO","4=CANCELAMEN","5=C.CREDITO"}
Private cEmpFat   := "1"
Private aRetParam := {}
Private cCliIni   := CriaVar("A1_COD",.F.)
Private cCliFim   := CriaVar("A1_COD",.F.)
Private dVencIni  := firstday( dDataBase )
Private dVencFim  := dDataBase
Private cTpBx     := '1'

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Vencto. DE"      , dVencIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Vencto. ATE"     , dVencFim  , "@!", "", ""   , "", 50, .t.} )
AADD( aBoxParam, {1,"Cliente DE"      , cCliIni   , "@!", "", "SA1", "", 50, .F.} )
AADD( aBoxParam, {1,"Cliente ATE"     , cCliFim   , "@!", "", "SA1", "", 50, .t.} )
AADD( aBoxParam, {2,"Tp.Baixa"        , cTpBx     , aBaixas, 50, ".F.", .T.} )

If ParamBox(aBoxParam,"Parâmetros Baixa lote.",@aRetParam,,,,,,,,.F.)

    cEmpFat := aRetParam[1]
    dVencIni:= aRetParam[2]
    dVencFim:= aRetParam[3]
    cCliIni := aRetParam[4]
    cCliFim := aRetParam[5]
    cTpBx   := aRetParam[6]

	FWMsgRun(, {|| LoadFat(@aFaturas) }, "Aguarde", "Carregando as faturas...")

	If Len(aFaturas) > 0
		FWMsgRun(, {|| ExibeFat(@aFaturas) }, "Aguarde", "Carregando tela das faturas...")
	Else
		MsgInfo( "Não existem faturas a serem enviadas.", "Aviso" )
	EndIf
EndIf

RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFat
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadFat(aFaturas)

Local aArea     := GetArea()
Local cTMP1     := ""
Local cQuery    := ""

aFaturas := {}

cQuery := " SELECT "+ CRLF
cQuery += " 	SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " 	,SA1.R_E_C_N_O_ AS RECSA1 "+ CRLF

cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = SE1.E1_CLIENTE "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = SE1.E1_LOJA "+ CRLF
cQuery += " 	AND SA1.A1_XLEMBRE = '1' "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
cQuery += "     AND SE1.E1_XNUMNFS <> ' ' "+ CRLF
cQuery += " 	AND SE1.E1_SALDO > 0 "+ CRLF
cQuery += " 	AND SE1.E1_BAIXA = ' ' "+ CRLF
cQuery += "     AND SE1.E1_XNUMNFS <> ' ' "+ CRLF


cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
cQuery += "     AND SE1.E1_VENCTO BETWEEN '"+DTOS(dVencIni)+"' AND '"+DTOS(dVencFim)+"'  "+ CRLF
cQuery += "     AND SE1.E1_CLIENTE BETWEEN '"+cCliIni+"' AND '"+cCliFim+"'  "+ CRLF


cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE1.E1_VENCTO "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery) 
MemoWrite('C:\Propostas\ALFPMS61.txt',cQuery)
While (cTMP1)->(!EOF())

	AADD( aFaturas, Array(PS_RECSA1) )
	nPos := Len(aFaturas)
    
    SE1->(DbSetOrder(1))
    SE1->(DbGoTo((cTMP1)->RECSE1))

    SA1->(DbSetOrder(1))
    SA1->(DbGoTo((cTMP1)->RECSA1))

    aFaturas[nPos][PS_MARKFT] := "LBOK"
    aFaturas[nPos][PS_STATUS] := "1"
    aFaturas[nPos][PS_DESCRI] := "Baixa Pendente"
    aFaturas[nPos][PS_NUMTIT] := SE1->E1_NUM
    aFaturas[nPos][PS_DTVENC] := DToC(SE1->E1_VENCTO)
    aFaturas[nPos][PS_VLRTIT] := SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    aFaturas[nPos][PS_NUMNFE] := SE1->E1_XNUMNFS
    aFaturas[nPos][PS_CODCLI] := SA1->A1_COD
    aFaturas[nPos][PS_LOJCLI] := SA1->A1_LOJA
    aFaturas[nPos][PS_NOMCLI] := SA1->A1_NOME
    aFaturas[nPos][PS_MAILCL] := SA1->A1_EMAILNF
    aFaturas[nPos][PS_MSGENV] := ""
    //aFaturas[nPos][PS_DIASVE] := (cTMP1)->DIAS
    aFaturas[nPos][PS_LINKNF] := SE1->E1_XLINKNF
    aFaturas[nPos][PS_HISTOR] := SE1->E1_HIST
    aFaturas[nPos][PS_RECSE1] := (cTMP1)->RECSE1
    aFaturas[nPos][PS_RECSA1] := (cTMP1)->RECSA1

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeFat
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExibeFat(aFaturas)

Local aAreaAtu  := GetArea()
Local aSize     := MsAdvSize()

Local oDlg
Local oLayer
Local oColumn
Local oPanelAux
Local oPanelCab
Local oPanelFat
Local oBrowse
Local oFont18N

DEFINE FONT oFont18N 	NAME "Arial"	SIZE 0,-18 BOLD

DEFINE MSDIALOG oDlg TITLE "Lembrete de Vencimento" FROM aSize[7],00 to aSize[6],aSize[5] OF oMainWnd PIXEL

	oLayer:= FWLayer():new()
	oLayer:Init(oDlg,.F.)
	oLayer:addLine("LIN1",100,.T.)
	oLayer:addCollumn("COL1",100,.F.,"LIN1")
	oLayer:addWindow("COL1","WIN1","Lista de Faturas",100,.F.,.F.,,"LIN1")
	
	oPanelAux := oLayer:GetWinPanel("COL1","WIN1","LIN1")

	oPanelCab := TPanel():New(0,0,"",oPanelAux,Nil,.F.,.F.,Nil,Nil,0,030,.F.,.F.)
	oPanelCab:Align := CONTROL_ALIGN_TOP

    @ 005,400  BUTTON "Baixar" SIZE 060,020 FONT oFont18N PIXEL ACTION {|| FwMsgRun( ,{|| EnvFaturas(@aFaturas), oBrowse:Refresh() }, , "Por favor, aguarde. Baixando faturas..." ) } OF oPanelAux
    @ 005,480  BUTTON "Sair"   SIZE 060,020 FONT oFont18N PIXEL ACTION {|| oDlg:End() } OF oPanelAux

    oPanelFat := TPanel():New(0,0,"",oPanelAux,NIL,.F.,.F.,NIL,NIL,0,000,.F.,.F.)
	oPanelFat:Align := CONTROL_ALIGN_ALLCLIENT
				
	DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aFaturas /*LINE HEIGHT nLineHeight*/ OF oPanelFat
		
		ADD MARKCOLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_MARKFT] } DOUBLECLICK {|| MarkReg(oBrowse, @aFaturas) } HEADERCLICK {|| MarkAll(oBrowse, @aFaturas) } OF oBrowse
		
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "1" } COLOR "WHITE" TITLE "Baixa Pendente" 	        OF oBrowse
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "2" } COLOR "GREEN" TITLE "Baixado Com Sucesso"     OF oBrowse
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "3" } COLOR "BLACK" TITLE "Erro na Baixa"           OF oBrowse
		
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_DESCRI] } TITLE "Status" 			SIZE 20 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NUMTIT] } TITLE "Título" 			SIZE 09 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_DTVENC] } TITLE "Vencimento"		SIZE 10	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NUMNFE] } TITLE "NFS"   			SIZE 09	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_VLRTIT] } TITLE "Valor"     		SIZE 12	PICTURE "@E 999,999,999.99" ALIGN CONTROL_ALIGN_RIGHT OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_CODCLI] } TITLE "Cliente" 			SIZE 06	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_LOJCLI] } TITLE "Loja" 			SIZE 02 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NOMCLI] } TITLE "Razão Social" 	SIZE 30	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        //ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_MAILCL] } TITLE "E-mail Cliente" 	SIZE 30	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_MSGENV] } TITLE "Mensagem"    		SIZE 80	ALIGN CONTROL_ALIGN_LEFT OF oBrowse
		
		oBrowse:DisableConfig()
		oBrowse:DisableSeek()
		oBrowse:DisableFilter()
		oBrowse:DisableLocate()
		oBrowse:DisableReport()		
		oBrowse:Refresh()

	ACTIVATE FWBROWSE oBrowse
	
ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkReg
Rotina de marcar e desmarcar da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   21/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarkReg(oBrowse, aFaturas)

Local cFlag := aFaturas[oBrowse:nAt][PS_MARKFT]

If cFlag == "LBNO"
    If aFaturas[oBrowse:nAt][PS_STATUS] == "2"
        MsgInfo("Fatura já Baixada.")
    Else
	    cFlag := "LBOK"
    EndIf
Else
	cFlag := "LBNO"
EndIf

aFaturas[oBrowse:nAt][PS_MARKFT] := cFlag

oBrowse:SetArray(aFaturas)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Rotina de marcar e desmarcar TUDO da primeira coluna.

@author  Wilson Antonio Silva Junior
@since   21/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarkAll(oBrowse, aFaturas)

Local cFlag := IIF( lMark, "LBOK", "LBNO" )
Local nItem

For nItem := 1 To Len(aFaturas)
	If aFaturas[nItem][PS_STATUS] == "2"
		aFaturas[nItem][PS_MARKFT] := "LBNO"
	Else
		aFaturas[nItem][PS_MARKFT] := cFlag
	EndIf
Next nItem

oBrowse:SetArray(aFaturas)
oBrowse:Refresh(.T.)

lMark := !lMark

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WFinancei
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   21/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvFaturas(aFaturas)

Local cMsgErro := ""
Local nX
local abkpRot := arotina
local cbkpperg:= SX1->X1_GRUPO
Pergunte("FIN070",.F.)
For nX := 1 To Len(aFaturas)

    cMsgErro := ""

	If aFaturas[nX][PS_MARKFT] == "LBOK"

        If WFinancei(aFaturas[nX], @cMsgErro)
            aFaturas[nX][PS_MARKFT] := "LBNO"
            aFaturas[nX][PS_STATUS] := "2"
            aFaturas[nX][PS_DESCRI] := "Baixado Com Sucesso"
            aFaturas[nX][PS_MSGENV] := ""
        Else
            aFaturas[nX][PS_MARKFT] := "LBOK"
            aFaturas[nX][PS_STATUS] := "3"
            aFaturas[nX][PS_DESCRI] := "Erro na Baixa"
            aFaturas[nX][PS_MSGENV] := cMsgErro
        EndIf
	EndIf
Next nX

Pergunte(cbkpperg,.f.)
arotina:= abkpRot

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} WFinancei
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   21/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WFinancei(aFatura, cMsgErro)

Local aAreaAtu  := GetArea()
//Local cBanco    := GetMv("MV_XBANCO")//GetNewPar("MV_XBANCO","")
//Local cAgencia  := GetMv("MV_XAGENCI")//GetNewPar("MV_XAGENCI","")
//Local cConta    := GetMv("MV_XCONTA")//GetNewPar("MV_XCONTA","")

Local lRetorno  := .T.
Local cMsgLog   := ""
private lMsErroAuto    := .F.
private lMsHelpAuto    := .T.
private lAutoErrNoFile := .T. 

Private lF070Auto	:= .f.//(xAutoCab <> NIL)
Private aAutoCab	:= {}
Private cPortado	:= CriaVar("E1_PORTADO",.F.)
Private cBanco		:= CriaVar("E1_PORTADO",.F.)
Private cAgencia	:= CriaVar("E1_AGEDEP" ,.F.)
Private cConta		:= CriaVar("E1_CONTA"  ,.F.)
Private cNatMov     := ''
Private lValidou	:= .F.
Private lOracle		:= "ORACLE"$Upper(TCGetDB())
Private aDadosRef	:= Array(7)
Private lFini055	:= FwIsInCallStack("FINI055")
Private aRatAut		:= {}
Private lCtb060		:= .T.


PRIVATE nValTot 	 := 0
PRIVATE nJuros		 := 0
PRIVATE nVA			 := 0
PRIVATE nMulta		 := 0
PRIVATE nPIS    	 := 0
PRIVATE nCOFINS    	 := 0
PRIVATE nCSLL    	 := 0
PRIVATE nIss		 := 0
PRIVATE nInss		 := 0
PRIVATE nlImpMR 	 := 0
PRIVATE nCM			 := 0
PRIVATE nDescont	 := 0
PRIVATE nTotAGer     := 0
PRIVATE nTotADesp    := 0
PRIVATE nTotADesc    := 0
PRIVATE nTotAMul     := 0
PRIVATE nTotAJur     := 0
PRIVATE nValPadrao   := 0
PRIVATE nValEstrang  := 0
PRIVATE cMarca       := Get070Mark()
PRIVATE cLote		 := ""
PRIVATE cLoteFin     := If(Type("cLoteFin") != "C", Space(TamSX3("E1_LOTE")[1]), cLoteFin)
PRIVATE cNaturLote   := Space (10)
PRIVATE nAcresc      := 0
PRIVATE nDecresc     := 0
PRIVATE aCaixaFin    := xCxFina() // Caixa Geral do Financeiro (MV_CXFIN)
PRIVATE aCols		 := {}
PRIVATE aHeader		 := {}
PRIVATE nMoedaBco	 := 1
PRIVATE nCM1      	 := 0
PRIVATE nProRata  	 := 0
PRIVATE cCodDiario	 := ""
PRIVATE nVlRetPis	 := 0
PRIVATE nVlRetCof	 := 0
PRIVATE nVlRetCsl	 := 0
PRIVATE aDadosRet 	 := Array(7)
PRIVATE nIrrf 		 := 0
PRIVATE nOldIrrf	 := 0

//Variaveis utilizada para acrescimo e decrescimo
PRIVATE aBxAcr		:= {}
PRIVATE aBxDec		:= {}
PRIVATE nDecrVlr		:= 0		//tratar visualizacao da varivel na tela de valores
PRIVATE nOdlMoedBco	 := 1

PRIVATE nTxMoeda

LoteCont( "FIN" )

PRIVATE oFontLbl, oFontAnt
PRIVATE lInverte := .F.

//***Reestruturacao SE5***
Private nPisCalc	:= 0
Private nCofCalc	:= 0
Private nCslCalc	:= 0
Private nIrfCalc	:= 0
Private nIssCalc	:= 0
Private nPisBaseR 	:= 0
Private nCofBaseR	:= 0
Private nCslBaseR 	:= 0
Private nIrfBaseR 	:= 0
Private nIssBaseR 	:= 0
Private nPisBaseC 	:= 0
Private nCofBaseC 	:= 0
Private nCslBaseC 	:= 0
Private nIrfBaseC 	:= 0
Private nIssBaseC 	:= 0
//***Reestruturacao SE5***
Private aParamAuto	:= {}
__lRatAut := .f.

SE1->(DbGoTo(aFatura[PS_RECSE1]))
SA6->( DBSetOrder(4) )
If !SA6->( MsSeek( xFilial('SA6') + SE1->E1_EMPFAT ) )
    cMsgErro := 'Problema, banco não localizado'+ AllTrim(cMsgLog)
    lRetorno := .F.
    Return lRetorno    
End


//lRet := u_xfA070Tit("SE1",SE1->(Recno()),4)
lRetorno := fA070Tit("SE1",SE1->(Recno()),4)
if !lRetorno
        
    //alErroAuto := getAutoGRLog()
    //aEval( alErroAuto, {|x| cMsgErro += allTrim( x ) + ' '})
                        
    lRetorno := .F.
    cMsgErro := "Não foi possível realizar a baixa do titulo "     
                            
else                                                 
        
    cMsgErro  := "Titulo  baixado com sucesso!"
    lRetorno := .T.
endif

/*
cBanco      := SA6->A6_COD
cAgencia    := SA6->A6_AGENCIA
cConta      := SA6->A6_NUMCON
cHistorico  := 'Valor recebido s/ Titulo'
nJuros      := 0
nValBx      := aFatura[PS_VLRTIT]//SE1->E1_VALOR
//SA60104	nonclustered located on PRIMARY	A6_FILIAL, A6_EMPFAT, R_E_C_N_O_, D_E_L_E_T_
aBaixa := {{"E1_FILIAL"   ,fwxFilial( "SE1" )   ,nil },;
		   {"E1_PREFIXO"  ,SE1->E1_PREFIXO   ,nil },;
           {"E1_NUM"      ,SE1->E1_NUM       ,nil },;
           {"E1_TIPO"     ,SE1->E1_TIPO      ,nil },;
		   {"E1_PARCELA"  ,SE1->E1_PARCELA   ,nil },;
		   {"E1_CLIENTE"  ,SE1->E1_CLIENTE   ,nil },;
		   {"E1_LOJA   "  ,SE1->E1_LOJA      ,nil },;
           {"AUTMOTBX"    ,"NOR"      ,nil },; // Baixa sempre sera normal
           {"AUTBANCO"    ,cBanco     ,nil },;
           {"AUTAGENCIA"  ,cAgencia   ,nil },;
           {"AUTCONTA"    ,cConta     ,nil },;
           {"AUTDTBAIXA"  ,dDataBase   ,nil },;
           {"AUTDTCREDITO",dDataBase   ,nil },;
           {"AUTHIST"     ,cHistorico ,nil },;
           {"AUTJUROS"    ,nJuros     ,nil, .T. },;
           {"AUTVALREC"   ,nValBx     ,nil }}

lMsErroAuto := .F. 
MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 

if lMsErroAuto
        
    alErroAuto := getAutoGRLog()
    aEval( alErroAuto, {|x| cMsgErro += allTrim( x ) + ' '})
                        
    lRetorno := .F.
    //cMsg := "Não foi possível realizar a baixa do titulo " + cTitulo
    //cMsg += cMsgErro
                            
else                                                 
        
    cMsgErro  := "Titulo [" + SE1->E1_NUM + "] baixado com sucesso!"
    lRetorno := .T.
endif
*/


RestArea(aAreaAtu)

Return lRetorno

Static Function Get070Mark()
Local cMarca

cMarca :=GetMark()
While cMarca == "xx"
  cMarca := Getmark()
End
Return cMarca

user Function xfA070Tit(cAlias,nReg,nOpcx,aM,lAut)
LOCAL oDlg
LOCAL oCbx
LOCAL oNumTit
LOCAL oCodCLi
LOCAL aDescMotbx	:= {}    
LOCAL oMulta
LOCAL oJuros
LOCAL oVA
LOCAL oPIS
LOCAL oCOFINS
LOCAL oCSLL
LOCAL oOtrga
LOCAL oDifCambio
LOCAL nDecrescF
LOCAL nOpt
LOCAL nHdlPrv		:= 0
LOCAL nTotal		:= 0
LOCAL lPadrao
LOCAL cArquivo
LOCAL lRet     		:= .T.
LOCAL nSalvRec		:= 0
LOCAL cParcela
LOCAL cNum			:= CRIAVAR ("E1_NUM",.F.)
LOCAL cPrefixo
LOCAL cMoeda
LOCAL nOrdem
LOCAL nT			:= 0
LOCAL nY			:= 0
LOCAL nErro			:= 0
LOCAL lBaixou		:= .F.
LOCAL lJuros
LOCAL aCaixaLoja
LOCAL nTolerPg		:= GetMv("MV_TOLERPG")
Local lFINA200		:= FunName() == "FINA200" .Or. FwIsInCallStack("fA200Ger")
Local lREC2TIT		:= SuperGetMv("MV_REC2TIT",,"2") == "1"
Local lFina450		:= FwIsInCallStack("Fa450cmp")
LOCAL lContabiliza	:= Iif(mv_par04==1,.T.,.F.) .and. !lFINA200 .and. !lFINA450
Local lFa070Tit		:= ExistBlock("FA070TIT")
Local lTFa070Tit	:= ExistTemplate("FA070TIT")
Local lFa070MDB		:= ExistBlock("FA070MDB")
Local lMdbOk		:= .F.
LOCAL aMotBx		:= ReadMotBx()
LOCAL nEstOriginal	:= 0
Local cMoedaTx, nA	:= 0
LOCAL aModalSPB		:= {"1=TED","2=CIP","3=COMP"}
LOCAL oModSpb
LOCAL lSpbInUse		:= SpbInUse()
Local oTxMoeda
Local nUltLin
Local bSetKey		:= {||}
Local oMultNat
Local lOk			:= .F. //Controla se foi confirmada a distribuicao 
Local aColsSEV		:= {}
Local NI
Local lFa070Bco		:= ExistBlock("FA070BCO")    
Local lF070Bxpc		:= ExistBlock("F070BXPC") 
Local aArea			:= GetArea()
Local nTotAdto		:= 0
Local lBaixaAbat	:= .F.
Local nVlrBaixa		:= 0
Local lBxCec		:= .F.
Local lBxLiq		:= .F.
Local cTipo 
Local cCliente
Local cLoja            
Local aBaixa		:= {}
Local x 
Local nLinha		:= 0
Local aButtons		:= {}      
Local lImpBxCr		:= GetNewPar( "MV_IMPBXCR", "1" ) == "2" 
LOCAL oValorLiq
Local nLin2			:= 0 
Local oCM1
Local oProRata
Local lGemInUse		:= .F.
Local aSeqSe5		:= {} // Para gravar a sequencia no SEF com a mesma sequencia dos movimentos bancarios gerados
Local nVlMinImp		:= GetNewPar("MV_VL10925",5000)
Local aLocal		:= {} // array utilizado pelo GE para verificar se existe local de prova
Local lPanelFin		:= IsPanelFin()
LOCAL oNaturez 
LOCAL oTipo 
LOCAL aDiario		:= {}
Local aGrvLctPco	:= {{"000004","09","FINA070"},;
						{"000004","10","FINA070"}}
Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local lIntDL		:= SuperGetMv("MV_INTDL",.F.,"N") == "S" //-- integracao com Distribuicao e Logistica
Local lAcessMul		:= .T.
Local lAcessJur		:= .T.
Local lAcessDesc	:= .T.
Local lAcessdBaixa	:= .T.
Local lAcessDtCredito	:= .T.
Local lAcessCSLL	:= .T.
Local lAcessCOF		:= .T.
Local lAcessPIS		:= .T.
Local lMultNat 		:= .F.

Local oDtBaixa 
Local oDtCredito		
Local aCposDes		:= {}
Local nTotMult		:= 0

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr		:= FPccBxCr(.T.)
Local lEECFAT		:= SuperGetMv("MV_EECFAT",.F.,.F.) 
Local lEECFIN		:= SuperGetMv("MV_AVG0131",.F.,.F.) //DFS - 17/02/11 - Parâmetro para verificar integração com financeiro.
Local aHdlPrv		:= {} 

Local lIrPjBxCr		:= FIrPjBxCr(.T.)	 //Controla IRPJ na baixa
Local oIrrf

Local lTipBxCP		:= .F.
Local lSigaloja		:= .F.

Local cMvJurTipo	:= SuperGetMv("MV_JURTIPO",,"")  // calculo de Multa do Loja , se JURTIPO == L

Local lMulLoj		:= SuperGetMv("MV_LJINTFS", ,.F.) //Calcula multa conforme regra do loja, se integração com financial estiver habilitada
Local lF070VLAD		:= ExistBlock("F070VLAD")

Local lSubsPrv		:= FwIsInCallStack("FINA040")   
Local lFA070BLQ		:= ExistBlock("FA070BLQ")
Local lLibCm		:= .F.
Local lVlTitCR		:= GetNewPar("MV_VLTITCR",.F.)
Local lTpDesc		:= cPaisLoc == "BRA" //Verifica campo TPDESC na tabela SE5 (<C>ondicional ou <I>ncondicional)
Local lNatApura		:= .F. //Natureza configurada para apurar impostos no SPED PIS/COFINS.                                    
Local lCposSped		:= cPaisLoc == "BRA" //Campos que apuram impostos no SPED PIS/COFINS.
Local aAreaSED 		:= {}
Local lTravaSa1 	:= ExistBlock("F070TRAVA")
Local lRMBibli		:= GetNewPar('MV_RMBIBLI',.F.) 
Local lRMClass		:= GetNewPar('MV_RMCLASS',.F.)
Local lBQ10925		:= .F.
Local cFilOrgTr		:= "" //Filial de origem do documento de ISS, processo de transferência 
Local nTotAbISS		:= 0 //Valor do abatimento de ISS na origem, processo de transferência
Local oSize
Local oMasterPanel
Local lMoedaBco		:= SuperGetMv("MV_MOEDBCO",, .F.)
Local dDtRecbAux
Local nValOld		:= 0
//desconto da bolsa para classis
Local nDescBol		:= 0
Local nBolsaPont	:= 0
Local nBolsa		:= 0
Local cData			:= ""
Local cAuxMBx		:= ""
Local lSaveState	:= ALTERA
Local aAlt			:= {}
Local cChaveTit		:= ""
Local cChaveFK7		:= ""
Local aPcc       	:= {}
Local lBruto     	:= SuperGetMV("MV_BQ10925",,"2") == "1"
Local nBase      	:= 0
Local lJurMulDes 	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
Local nPccRetPrc 	:= 0
Local lGerPCCBD  	:= .F.
Local lGerChqAdt 	:= .F.
Local cTipoOr    	:= ""
Local aBaixas    	:= {}
Local aVlOringl  	:= Array( 8 )//|1=Valor recebido|2=Pis|3=Cofins|4=Csll|5=Juros|6=Multa|7=Desconto|8=Base 
local lCalcPCC	 	:= .T.
Local lRecIss	 	:= .F.
Local lCalcIssBx 	:= GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
Local nPos 			:= 0
Local lSDACRVL 		:= SuperGetMv("MV_SDACRVL",.T.,.F.)
Local lSDDECVL	 	:= .F.
Local aRelTit	 	:= {}									//Array contendo o titulo baixado para impressao do Recibo
Local aFormPg	 	:= {}									//Array contendo os pagamento em cheque para impressao do Recibo
Local lLojrRec	 	:= FindFunction("LOJRREC")				//Relatorio de impressao de Recibo (OBSOLETO)
Local lULOJRREC	 	:= FindFunction("U_LOJRRecibo")		//Relatorio de impressao de Recibo (RDMAKE)
Local lImpLjRe	 	:= SuperGetMV( "MV_IMPLJRE",.F., .F.)
Local aAreaSe1	 	:= {}
Local aAreaSe5	 	:= {}
Local aAreaRec	 	:= {} 
//Valores Acessorios
Local oModelVA	 	:= Nil
Local nLaco		 	:= 0
Local lFINI070	 	:= FWIsInCallStack("FINI070")
//Validaca da Baixa para nao permitir a baixa apenas no Protheus da Integracao RM Classis X Protheus
Local cProdRM	 	:= GETNEWPAR('MV_RMORIG', "E|U|S")
Local lExistVA 	 	:= TableInDic("FKD") .and. TableInDic("FKC")
Local cAcaoVA 		:= ""
Local nVaCalc 		:= 0
Local cAuxMoeda 	:= ""
Local lSigaGSP 		:= GetNewPar("MV_SIGAGSP") == "1"
Local lCalcCM 		:= GetMv("MV_CALCCM") == "S"
Local cBxDtFin 		:= SuperGetMv( "MV_BXDTFIN",, "1" )
Local lSaldoChq 	:= GetMv("MV_SLDBXCR") == "C"
Local lAntCred 		:= GetMv("MV_ANTCRED")
Local cPrefRM   	:= SuperGetMv("MV_PREFRM",,"TIN")
Local aRetInteg		:= {}
Local lAutoCab		:= Type("aAutoCab") == "A"
Local l070Auto		:= Type('lF070Auto') =='U'
Local nRecSe1   	:= 0 
Local lJFilBco  	:= ExistFunc("JurVldSA6") .And. SuperGetMv("MV_JFILBCO", .F., .F.) //Indica se filtra as contas correntes vinculadas ao escritório logado - SIGAPFS
Local cEscrit   	:= IIF(lJFilBco, JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD"), "")
Local cF3Bco    	:= IIF(lJFilBco, "SA6JUR", "SA6")
Local nDecs			:= SuperGetMv("MV_CENT") 
// Motor de Retenção
Local aImpos 	as Array	// Motor de retenção
Local lTemImpPad 	:= .F.
Local nW 			:= 0
Local nImp 			:= 0
Local cChaveAux 	:= ""
Local cIdTit 		:= ""
Local nAbatMot 		:= 0
Local cMsg 			:= ""

PRIVATE lRaRtImp	:= lFinImp .And.FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A 
PRIVATE nParciais	:= 0
PRIVATE aBaixaSE5	:= {}
PRIVATE cMotBx		:= ""
PRIVATE oVlEstrang	:= nil
PRIVATE oValrec		:= nil
PRIVATE oCM			:= nil
PRIVATE oAgencia := oBanco := oConta := nil
PRIVATE oDescont	:= nil
PRIVATE nOtrga		:= 0
PRIVATE nDifCambio	:= 0
PRIVATE aTxMoedas	:= {}
PRIVATE cModSpb		:= "1"        
PRIVATE nAcrescF	:= 0
//Variaveis PRIVATE utilizadas pela funcao FA040AxAlt()
PRIVATE nIndexSE1	:= ""
PRIVATE cIndexSE1	:= ""
PRIVATE lAltera		:= .T.
PRIVATE nOldValor	:= SE1->E1_VALOR
PRIVATE nOldIss		:= SE1->E1_ISS
PRIVATE nOldInss	:= SE1->E1_INSS
PRIVATE nOldPis		:= SE1->E1_PIS
PRIVATE nOldCofins	:= SE1->E1_COFINS
PRIVATE nOldCsll	:= SE1->E1_CSLL
PRIVATE nOldVlAcres	:= SE1->E1_ACRESC
PRIVATE nOldIrrf	:= SE1->E1_IRRF
PRIVATE nOldVlDecres	:= SE1->E1_DECRESC                          
PRIVATE lAlterNat	:= .F.
PRIVATE nOldVencto	:= SE1->E1_VENCTO
PRIVATE nOldVenRea	:= SE1->E1_VENCREA
PRIVATE cOldNatur	:= SE1->E1_NATUREZ
PRIVATE nOldVlCruz	:= SE1->E1_VLCRUZ
PRIVATE lAlterImp	:= .F.
PRIVATE aDadosRet	:= {}
PRIVATE nSomaCheq	:= 0  
Private nIrrf		:= 0
PRIVATE nOldDescont	:= 0
PRIVATE nOldMulta	:= 0
PRIVATE nOldJuros	:= 0 
PRIVATE nOldVA 		:= 0
PRIVATE cOldVA 		:= ""
PRIVATE lTitLote  	:= .T.
Private cTpDesc 	:= "I"                
PRIVATE lBloqSa1   	:= .T.
PRIVATE cFilAbat 	:= cFilAnt
Private lBolsa		:= .F.
PRIVATE nDescCalc 	:= 0
PRIVATE nJurosCalc 	:= 0
PRIVATE nMultaCalc 	:= 0
Private aRetMsg		:= {}
 	
aImpos 	:= {}	// Motor de retenção
If lF070Auto
	PRIVATE lAutValRec := .F.
EndIf

//Tratamento para não redeclarar a variável.
//No retorno CNAB com calculo de PCC + IR esta variável já vem declarada.
If Type("dBaixa")=="U"
	PRIVATE dBaixa	:= CriaVar("E1_BAIXA")
Endif

If lPccBxCr .and. dBaixa >= dLastPcc
	nVlMinImp	:= 0
EndIf

lBQ10925 := SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp

//Variaveis utilizada para acrescimo e decrescimo
aBxAcr					:= {} 
aBxDec					:= {} 
nDecrVlr				:= 0		//tratar visualizacao da varivel na tela de valores
aFill( aVlOringl , 0 )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha seja um titulo gerado pelo SIGAEIC ou SIGAEEC não poderá sofrer baixa através desta rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV("MV_EASYFIN") == "S" .And. UPPER(Alltrim(SE1->E1_ORIGEM)) $ "SIGAEIC"
	HELP(" ",1,"FAORIEIC")
	Return      
Endif

//If lEECFAT .And. UPPER(Alltrim(SE1->E1_ORIGEM)) $ "SIGAEEC" //DFS - A integração do financeiro independe da integração com o faturamento
// TDF - 26/12/11 - Acrescentado o módulo EFF para permitir liquidação
If lEECFIN .And. UPPER(Alltrim(SE1->E1_ORIGEM)) $ "SIGAEEC" .AND. !(cModulo $ "EEC/EDC/ECO/EFF") //DFS - 17/02/11 - Trava para outros módulos para títulos gerados no EEC 
   HELP(" ",1,"FAORIEEC")                                                           
   Return
Endif

//Validação de mensagem de titulo RM Classis 
If(AllTrim(SE1->E1_ORIGEM) $ cProdRM .And. !lF070Auto)
	HELP(" ",1,"ProtheusXClassis" ,,'STR0277',2,0,,,,,, {'STR0279'})//"Título gerado pela Integração Protheus X Classis não Pode ser baixado pelo Protheus" ## "Efetua a baixa através do sistema RM Classis"
	return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
//³I = Carteira Caixa Loja                                        ³
//³J = Carteira Caixa Geral                                       ³
//³Nao permitir esta operacao, pois ele precisa ser transferido   ³
//³antes pelas rotinas do SIGALOJA.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//SITCOB
If Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J" .AND. Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701"
	Help(" ",1,"NOUSACLJ")
	Return
Endif

//Caso a rotina esteja cadastrada no adapter, so pode ser enviada como 'Sincrona'. Uma baixa enviada como assincrona 
//sera concretizada mesmo que de erro no sistema integrado.
If !lFini055 .And. !lF070Auto
	If !(FA070Integ(.F.))
		Return .F.
	Endif
Endif

//PCREQ-3782 - Bloqueio por situação de cobrança
If !F023VerBlq("1","0003",SE1->E1_SITUACA,.T.)
	Return .F.
Endif

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0                   

cTpDesc	:= "I"	
lF415Auto := IIf(Type("lF415Auto")=="U",.F.,lF415Auto)		// Sergio Fuzinaka - 05.06.02
cPortado  := IIf(Type("cPortado")=="U",CriaVar("E1_PORTADO",.F.),cPortado)
cBanco 	 := IIf(Type("cBanco")=="U",CriaVar("E1_PORTADO",.F.), cBanco)
cAgencia  := IIf(Type("cAgencia")=="U",CriaVar("E1_AGEDEP" ,.F.),cAgencia)
cConta	 := IIf(Type("cConta")=="U",CriaVar("E1_CONTA"  ,.F.),cConta)

If mv_par10 == 1 .And. FunName() == "FINA740"
	cPortado	:= cPorta740
	cBanco 		:= cBanco740
	cAgencia	:= cAgenc740
	cConta		:= cConta740	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza o modulo de Gerenciamento Academico.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_ACATIVO", .F.)
	JA1->(dbSetOrder(8))

	If JA1->(MsSeek(xFilial("JA1") + SE1->E1_PREFIXO + SE1->E1_NUM))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe Local associado ao Processo Seletivo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		JA9->(dbSetOrder(1))
		JA9->(MsSeek(xFilial("JA9") + JA1->JA1_PROSEL))

		If JA9->(!Found())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O titulo somente podera ser baixado quando houver um local associado ao ³
			//³ Processo Seletivo.                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Help(" ",1,"ACAA070_11")

			Return .F.
		EndIf
		
		aLocal := Aca070Lugar( JA1->JA1_CODINS,JA1->JA1_LOCAL,,,JA1->JA1_PROSEL,JA1->JA1_TPCAND,,,JA1->JA1_TIPDEF,JA1->JA1_TIPREL)
        
		If Empty(aLocal)
			Return .F.
		EndIf
	EndIf
EndIf

nOpc1    := 0
If cPaisLoc <> "BRA"
   aAdd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
   For nA	:=	2 To MoedFin()
	  cMoedaTx := Str(nA,IIf(nA <= 9,1,2))
	  cAuxMoeda := GetMv( "MV_MOEDA" + cMoedaTx ) 	  
	  If ! Empty( cAuxMoeda )
	  	If lF070Auto .And. nA==SE1->E1_MOEDA
			 aAdd( aTxMoedas, {cAuxMoeda, SE1->E1_TXMOEDA, PesqPict("SM2", "M2_MOEDA" + cMoedaTx)} )
		Else
			 aAdd( aTxMoedas, {cAuxMoeda, RecMoeda(dDataBase,nA), PesqPict("SM2", "M2_MOEDA" + cMoedaTx)} )
		Endif
	  Else
		 Exit
	  Endif
   Next
   nTotAGer     := 0
   nTotADesp    := 0
   nTotADesc    := 0
   nTotAMul     := 0
   nTotAJur     := 0
   cMarca       := Get070Mark()
   cLoteFin     := Space(TamSX3("E1_LOTE")[1])
EndIf   
  			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA 																	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock( "FA070CHK" ) )
	If !(ExecBlock("FA070CHK",.F.,.F.))
		Return .F.
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA TEMPLATE	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistTemplate( "FA070CHK" ) )
	If !(ExecTemplate("FA070CHK",.F.,.F.))
	
		// Indica que houve um erro ao executar por rotina automatica, para tratamento externo
		If Type('lF070Auto') == 'L' .And. lF070Auto
			lMsErroAuto := .T.
		Endif	
		
		Return .F.
	EndIf
Endif

IF ExistBlock("F070MNAT")
	lMultNat := ExecBlock("F070MNAT",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Hist¢rico da Baixa para digita‡„o pelo usu rio                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cHist070 := Criavar("E5_HISTOR")        //Inicilizador padrao

If Empty(cHist070)
	cHist070 := 'Valor recebido s/ Titulo'+Space(Len(cHist070)-24)  // "Valor recebido s/ T¡tulo"
Endif

cMotBx := criavar("E5_MOTBX")
IF lAut=NIL
	lAut:=.F.
EndIF

//*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//*³Salva ordem atual                                                     ³
//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem:=IndexOrd()
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as vari veis utilizadas para receber os dados do t¡tulo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDtCredito  := dDataBase
If Alltrim(SE1->E1_ORIGEM) $ "LOJA010|LOJXTEF"

	aCaixaLoja  := xCxLoja()
	cPortado    := SE1->E1_PORTADO
	cBanco      := SE1->E1_PORTADO
	cAgencia    := SE1->E1_AGEDEP
	cConta      := SE1->E1_CONTA
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCaixaFin conter  os dados Bco/Age/Cta do Caixa Geral, caso o titulo  ³
	//³esteja em carteira (SITUACA == 0).                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 0 = Carteira
	// F = Carteira Protesto
	// G = Carteira Acordo
	//SITCOB
	If (mv_par10 == 2 .or. Empty(cBanco)) .and. (Len(aAutoCab) == 0)
		If ! lJFilBco
			cPortado    := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[1] ,SE1->E1_PORTADO)
			cBanco      := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[1] ,SE1->E1_PORTADO)
			cAgencia    := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[2] ,SE1->E1_AGEDEP)
			cConta      := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[3] ,SE1->E1_CONTA)
		Else
			cPortado    := CriaVar("E1_PORTADO",.F.)
			cBanco      := CriaVar("E1_PORTADO",.F.)
			cAgencia    := CriaVar("E1_AGEDEP",.F.)
			cConta      := CriaVar("E1_CONTA",.F.)
		EndIf	
	Else
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTBANCO'})) > 0
			 cBanco:= aAutoCab[nPos][2]
		Endif	
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTAGENCIA'}) ) > 0
			 cAgencia:= aAutoCab[nPos][2]
		EndIf	
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTCONTA'}) ) > 0
			 cConta:= aAutoCab[nPos][2]	
		EndIf
		//Si es para Argentina, viene de la rutina FINA074 y tiene la variable aDatBnDif defina y con datos
		If Upper(AllTrim(SE1->E1_ORIGEM)) == "FINA074" .And. cPaisLoc == "ARG" .And. (Empty(cPortado) .Or. Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)) .And. (Type("aDatBnDif") != "U" .And. Len(aDatBnDif) > 0)
			cPortado := aDatBnDif[1][1]
			cBanco := aDatBnDif[1][1]
			cAgencia := aDatBnDif[1][2]
			cConta := aDatBnDif[1][3]
		EndIf
		//Caso seja rotina automatica e não sejam passados os dados bancarios para baixa
		//Verificamos se possui informações de portador do título e assume como conta corrente da baixa 
		If lF070Auto
			If (Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)) .and. ;
				!Empty(SE1->E1_PORTADO) .AND. !Empty(SE1->E1_AGEDEP) .AND. !Empty(SE1->E1_CONTA)
				cBanco	:= SE1->E1_PORTADO
				cAgencia	:= SE1->E1_AGEDEP
				cConta	:= SE1->E1_CONTA
			Endif
		Endif
	Endif		
EndIf

//Obtem a moeda do banco
nOrdSA6:=SA6->(IndexOrd())
DbSetOrder(1)
If cPaisLoc == "BRA"
	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
ElseIf cPaisLoc == "ARG" .And. !(Empty(cBanco) .And. Empty(cAgencia) .And. Empty(cConta))
	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
Endif
nMoedaBco:= Max(SA6->A6_MOEDA,1)
SA6->(DbSetOrder(nOrdSA6))

//
// Eh um titulo gerado pelo template GEM ?
//
If HasTemplate("LOT") .and. ExistTemplate("GEMSE1LIX")
	lGemInUse := ExecTemplate("GEMSE1LIX",.F.,.F.)
EndIf 
If !SoftLock( "SE1" )
	Return
EndIf
// Verifica integracao com PMS e nao permite alteracao de titulos que tenham solicitacoes
// de transferencias em aberto.
If !( Alltrim(Upper(FunName())) == "FINA630" .or. (Type("lF630Auto")=="L" .and.  lF630Auto) ) .And. !Empty(SE1->E1_NUMSOL)
	HELP(" ",1,"FIN62003")
	Return
Endif

// Nao permitir baixar titulos de adiantamento relacionados a pedido
If cPaisLoc == "BRA" .and. AliasInDic("FIE")
	If FinAdtSld( "R", SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) )
		Help(" ",1,"ADTXPED",,"Adiantamento relacionado a um pedido. Somente poderá ser utilizado no relacionamento com pedidos.",1,0) //
		Return(.F.)
	Endif
Endif

If SE1->( Deleted() )
	Help( " " , 1 , "RECNO" )
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SIGAPFS‚ A cotação para baixa dos títulos no módulo jurídico deve ser sempre na cotação diária.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If UPPER(Alltrim(SE1->E1_ORIGEM)) $ "JURA203"  
	nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dBaixa,SE1->E1_MOEDA), 0)
Else
	nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
EndIf

// Se estiver utilizando CMC7, abre a porta para cadastro do cheque recebido.
If lOpenCmc7 == Nil .And. !lAut .And. GetMv("MV_CMC7FIN") == "S" 
	OpenCMC7()
	lOpenCmc7 := .T.
Endif

lTemImpPad := !( __lPccMR .And. __lInsMR .And. __lIrfMR .And. __lIssMR )

If !lF070Auto .And. lImpBxCr .And. (SE1->E1_MULTNAT != "1" .or. (SE1->E1_MULTNAT == "1" .AND. F070RTMNBL())) .And. lTemImpPad
	AADD(aButtons, {"SIMULACAO", {|| FaCalcImp(.T.)}, "Recálculo dos Impostos", "Impostos" }) //
EndIf

//Botao de Cheques no Painel Financeiro
AADD(aButtons, {"LIQCHECK", {|| CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1)}, "Cheques" }) //

//Valores Acessorios.	
If lPodeTVA .and. lExistVA
 	FAPodeTVA(SE1->E1_TIPO,SE1->E1_NATUREZ,.F.,"R")			
	Aadd(aButtons, {"VALACESS", {||	If (FINA070VA() == 0,fA070Val(nVA,nTxMoeda),/**/) },"Valores Acessórios"	})	//
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os botoes de usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA070BTN")
	aButtons:= ExecBlock("FA070BTN",.F.,.F.,{aButtons})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os botoes de usuarios no Template.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HasTemplate("LOT") .and. ExistTemplate("FA070BTN")
	aButtons := ExecTemplate("FA070BTN",.F.,.F.,{aButtons})
EndIf                                                                               

//Ponto de entrada para desabilitar campos de Multa, Juros ou Descontos, data de baixa, data de credito
If ExistBlock("F070DCNB")
	aCposDes:=ExecBlock("F070DCNB",.F.,.F.)
	If Len(aCposDes) > 0
		IF (nT := ascan(aCposDes,'MULTA')) > 0
			lAcessMul := .F.
		Endif
		IF (nT := ascan(aCposDes,'DESCONTO')) > 0
			lAcessDesc := .F.
		Endif
		IF (nT := ascan(aCposDes,'JUROS')) > 0
			lAcessJur := .F.
		Endif
		IF (nT := ascan(aCposDes,'DATABAIXA')) > 0	
			lAcessdBaixa := .F.
		Endif		
		IF (nT := ascan(aCposDes,'DATACREDITO')) > 0	
			lAcessDtCredito := .F.
		Endif	
		IF (nT := ascan(aCposDes,'PIS')) > 0	
			lAcessPIS := .F.
		Endif		
		IF (nT := ascan(aCposDes,'COFINS')) > 0	
			lAcessCOF := .F.
		Endif		
		IF (nT := ascan(aCposDes,'CSLL')) > 0	
			lAcessCSLL := .F.
		Endif		
	Endif
Endif

//verifica se o titulo é da integração Protheus X Tin, caso afirmativo, não e permitido alterar os valores
If AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. !lF070Auto .And. SuperGetMv("MV_ITLBCPO",,.F.) == .F.
	lAcessMul := .F.
	lAcessDesc := .F.
	lAcessJur := .F.
	lAcessdBaixa := .F.
	lAcessDtCredito := .F.
Elseif AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. !lF070Auto .And. SuperGetMv("MV_ITLBCPO",,.F.) == .T.
	lAcessMul := .T.
	lAcessDesc := .T.
	lAcessJur := .T.
	lAcessdBaixa := .T.
	lAcessDtCredito := .T. 
Endif

While .T.
	nOpc1		:= 0
	nJuros      := 0
	nVA			:= 0		//Valores Acessorios
	nPIS	    := 0
	nCOFINS    	:= 0	
	nCSLL    	:= 0	
	nVlRetPis	:= 0
	nVlRetCof	:= 0
	nVlRetCsl	:= 0	
	nMulta      := 0
	nCM         := 0
	nDescont    := 0
	If !lF070Auto 
		If Type("nValRec")=="U"
			nValRec     := 0
			dBaixa      := CriaVar("E1_BAIXA")
		ElseIf Type("nValRec")!="N" 
			nValRec     := 0		
		Endif
	Endif
	nValEstrang := 0
	nParciais   := 0
	aBaixaSE5   :={}

	nAcrescF	:= SE1->E1_SDACRES
	nDeCrescF	:= SE1->E1_SDDECRE  + nDecrVlr 
	
	// Motor de Retenção
	__lMotor 	:= .F.
	__lPccMR	:= .F.
	__lInsMR	:= .F.
	__lIrfMR	:= .F.
	__lIssMR	:= .F.
	__lImpMR  	:= .F.
	__lGlosaMr	:= .F.
 	__lGlosIrf	:= .F.
 	__lGlosPis	:= .F.
 	__lGlosCof	:= .F.
	__lGlosCsl	:= .F.
 	__lGlosIss	:= .F.
 	__lGlosIns	:= .F.
 	__lGlosOut	:= .F.
 	__lPropPcc	:= .F.
	//***Reestruturacao SE5***
	nPisCalc	:= 0
	nCofCalc	:= 0
	nCslCalc	:= 0
	nIrfCalc	:= 0
	nIssCalc	:= 0
	nPisBaseR 	:= 0
	nCofBaseR	:= 0
	nCslBaseR 	:= 0
	nIrfBaseR 	:= 0
	nIssBaseR 	:= 0
	nPisBaseC 	:= 0
	nCofBaseC 	:= 0
	nCslBaseC 	:= 0
	nIrfBaseC 	:= 0
	nIssBaseC 	:= 0
	//***Reestruturacao SE5***

	If lF070ACRE
		ExecBlock("F070ACRE",.F.,.F.)
	EndIf

	lNatApura	:=	.F.	
	aAreaSED 	:= SED->(GetArea())
	DbSelectArea("SED")							
	DbSetOrder(1)			
	If DbSeek(xFilial("SED")+ SE1->E1_NATUREZ) .And. lCposSped
		If (!Empty(SED->ED_APURCOF) .Or. !Empty(SED->ED_APURPIS))
			lNatApura	:=	.T. //Natureza configurada para apurar impostos no SPED PIS/COFINS.
		Endif	
	Endif
	RestArea(aAreaSED)

	nAcresc     := Round(NoRound(xMoeda(nAcrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nDecresc    := Round(NoRound(xMoeda(nDeCrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nCM1        := 0
	nProRata    := 0

	// Motor de retenção
  	If __lTemMR
  		aImpos := F070VldImp(Iif(SE1->E1_VALOR <> SE1->E1_SALDO, 0, SE1->E1_VALOR), dBaixa, @lPccBxCr, @lIrPjBxCr, @lCalcIssBx)
  	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o T¡tulo j  foi Baixado Totalmente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->E1_SALDO == 0 .And. !(FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)) .And. ;
		!( lFINA200 .And. lREC2TIT )// Tratamento do Parâmeto MV_REC2TIT - Geração de RECANT(RA) via RETORNO CNAB.
		Help(" ",1,"TITBAIXADO")
		MsUnlock()
		Exit
	EndIF
	
	If lVlTitCR .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) 
		aAreaSE1:=SE1->(GetArea())
		nBusca := F070BuscCR( "SE1", SE1->E1_CLIENTE, SE1->E1_LOJA )
		If nBusca <> 0
			lAD := .T.
			cMsg := "O Cliente deste titulo possui " //
			Do Case 
				Case nBusca = 1 // Recebimento Antecipado
					cMsg += "Recebimento(s) Antecipado(s)." //
				Case nBusca = 2 // NCC
					cMsg += "titulo(s) de credito." //
			End Case
			cMsg += chr(13)+chr(10)
			cMsg += "Deseja mesmo assim baixa-lo ?" //
			If isBlind()
				If lF070VLAD
					If !(ExecBlock("F070VLAD",.F.,.F.))
						Return .F.
					Endif
				Endif
			Else
				If !MsgYesNo( cMsg )
					Return .F. /*Function fA070Tit*/
				Endif
			Endif
		Endif
		RestArea(aAreaSE1)
	Endif
	
	If !(AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
		//----------------------------------------------------------------------------------------------------------------------
		// Verifica se o tipo de calculo de juros é igual (L)loja ou Indicacao do calculo de Multa do Loja, calcula a multa 
		//----------------------------------------------------------------------------------------------------------------------
		If !( SE1->E1_TIPO $ MVRECANT + "|" + MV_CRNEG ) .And. ( cMvJurTipo == "L" .OR. lMulLoj )       			
				//--------------------------------------------------------------------
				// Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          
				//--------------------------------------------------------------------
				nMulta := LojxRMul( , , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDtCredito, , SE1->E1_MULTA, ,;
				  					 SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1",.T. ) 
			
		EndIf
	EndIf
	//Trato o desconto por bolsa de estudos quando há integração com o RM Classis
	If FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
		nDescBol := SE1->E1_VLBOLSA
	EndIf	

	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³Verifica se ‚ um registro Principal                                 ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SE1->E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVFUABT //adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		Help(" ",1,"NAOPRINCIP")
		MsUnlock()
		Exit
	End

	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³Verifica se ‚ um t¡tulo provis¢rio                                    ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SE1->E1_TIPO $ MVPROVIS .AND. !lSubsPrv .and. !lFini055
		Help(" ",1,"TITULOPROV")
		MsUnlock()
		Exit
	EndIf

	nSalvRec  := RecNO()
	cNum      := SE1->E1_NUM
	cPrefixo  := SE1->E1_PREFIXO
	cParcela  := SE1->E1_PARCELA
	cTipo     := SE1->E1_TIPO
	cCliente  := SE1->E1_CLIENTE
	cLoja     := SE1->E1_LOJA
	nTotAbat  := 0
	nTotAbImp := 0
	nTotAbLiq := 0
	nValorLiq := 0     
	nValPadrao:= 0
	nTotAbat  := SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp,,,,,,cFilAbat, nTxMoeda)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca os valores de ISS no caso de documento transferido com ISS na origem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilOrgTr := FilISSTran()
	If !Empty( cFilOrgTr )
		SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,nTotAbImp,,,,,,cFilOrgTr, nTxMoeda,@nTotAbISS)
		nTotAbat  += nTotAbISS
		nTotAbImp += nTotAbISS  
	EndIf

	nTotAbLiq := nTotAbat - nTotAbImp
	dbGoto(nSalvRec)
	cMoeda := IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))

	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³Recebe os dados do t¡tulo a ser baixado                               ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	cTitulo 	:= SE1->E1_PREFIXO + " " + SE1->E1_NUM+ " " + SE1->E1_PARCELA
	cSituacao 	:= SE1->E1_SITUACA + " " + fa070situa()
	cDescMoeda 	:= SubStr(GetMV("MV_SIMB"+cMoeda),1,3)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para que o valor da baixa parcial nao fique negativo, verifico o saldo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SE1->E1_SALDO+SE1->E1_SDACRES)>0 .And. Empty(SE1->E1_TIPOLIQ)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura pelas baixas deste titulo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTipBxCP:=lRaRtImp

		aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, cPrefixo	, cNum			, cParcela	,;
								cTipo								, @nTotAdto	, @lBaixaAbat	, cCliente	,; 
								cLoja								, @nVlrBaixa, Nil			, @lBxCec	,; 
								@lBxLiq 							, @lSigaloja, @lTipBxCP		)

		For x := 1 To Len(aBaixaSE5)

			// Não considera a baixa de um recebimento de titulo pago em dinheiro originado pelo SIGALOJA
			If AllTrim(aBaixaSE5[x][25]) == "BA" .AND. AllTrim(aBaixaSE5[x][29]) == "LOJ" .AND. IsMoney(aBaixaSE5[x][24])
				Loop
			EndIf

			nParciais += Iif(SE1->E1_MOEDA > 1, aBaixaSE5[x][8]-aBaixaSE5[x,17]/*VlCorr*/, aBaixaSE5[x][8]/*E5_VALOR*/)
   			If lPccBxCR
   				If lRaRtImp //.And. nParciais > nVlMinImp
			   		nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
			   	EndIf 
			   	nPccRetPrc += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+ IIf( lIrPjBxCr , aBaixaSE5[x][30] , 0 )
			Elseif lIrPjBxCr .And. lRaRtImp  
		  		nParciais += aBaixaSE5[x][30]
			Endif   
			nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa   
			If lRaRtImp
		 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
		 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
			Endif
			
			//Verifica baixas parciais no caso de desconto.
			If ABAIXASE5[x][16] > 0 .and. lSDACRVL	
				nParciais += ABAIXASE5[x][16]
			Endif
				
		Next
		nParciais += nTotAdto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma valor de decrescimo em baixas parciais, para evitar         ³
		//³ diferencas entre valor original e valor recebido                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_SDDECRE <> SE1->E1_DECRESC
			If SE1->E1_SDDECRE = 0
				lSDDECVL := .T.
				If lSDACRVL 
					nParciais -= SE1->E1_DECRESC
				Endif 
			Else
				If lSDACRVL
					nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
				Endif
			Endif
		EndIf

	Else
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif
	
	If "RA" $ SE1->E1_TIPO
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array aDescMotbx contendo apenas a descricao do motivo das Baixas. 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len( aDescMotbx ) == 0
		For nI := 1 to len( aMotBx )
			If SubStr(aMotBx[nI],34,01) == "A" .or. SubStr(aMotBx[nI],34,01) =="R"
				If !(substr(aMotBx[nI],01,03) $ "FAT|LOJ|LIQ|CEC|CMP|STP") 
					AADD( aDescMotbx,SubStr(aMotBx[nI],07,10))
				EndIf
			EndIf
		Next nI
	EndIf

	// Carrega varivael cMotBx para sua verifcacao na funcao fa070totmes()
	cMotBx	:= aDescMotBx[1]	//Motivo das baixas

	If !(AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)	
		// Calcula o desconto e o juros (se houver) e valida a data
		// Idem para Valores Acessórios
		fA070Data(@nTxMoeda,.F.) 
		F070Ret()
	EndIf
	
	nDescCalc 	:= nDescont + nDecresc
	nJurosCalc 	:= IIf(cPaisLoc<>"CHI",nJuros + nAcresc,nOtrga)
	nMultaCalc 	:= nMulta

	// adiciona o desconto da bolsa ao desconto financeiro para o Classis
	If (SE1->E1_ORIGEM $ 'L|S|T') .And. (SE1->E1_VALOR == SE1->E1_SALDO)
		nDescont := nDescbol + nDescont
		// para validação da bolsa
		lBolsa := .T.
	EndIf

	If FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
		nDescont := nDescBol + SE1->E1_DESCONT + nDescont
	EndIf

	If !lF070Auto
		nOldValRec	:= nValRec
	Else
		lAutValRec := (nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})) > 0
		If TYPE("nValRec") == "N"
			If nValRec == 0
				If lAutValRec
					nValRec := aAutoCab[nPos][2]
					If lBq10925 .And. nValRec == SE1->E1_SALDO
			        	nValRec := SE1->E1_VALOR - nParciais + nTotMult
			        EndIf
				else
					nValRec := SE1->E1_VALOR
					nValRec -= nParciais - nTotMult
				EndIf
			Endif
		ElseIf TYPE("nValRec") == "U"
			If lAutValRec
				nValRec := aAutoCab[nPos][2]
			else
				nValRec := SE1->E1_VALOR
				nValRec -= nParciais - nTotMult
			EndIf
		Endif
	Endif	
	
 	If	lIrPjBxCr .and. SE1->E1_TIPO # MVRECANT
		If (lMVGlosa .and. !__lIrfMR) .or. __lGlosIrf
			If nParciais == 0 // Não houve baixas parciais ainda			
				nIrrf := SE1->E1_IRRF
			Else
				nIrrf := 0
			Endif		
		Else 
			If __lTemMR .And. __lIrfMR
	  			nParciais += Iif(nParciais > 0, nIrrf, 0)
	  		Else
	  			nParciais += nIrrf
	  		EndIf
			If !lF070Auto
				nValRec := SE1->E1_VALOR - (nParciais - iF(lJurMulDes,0,nTotMult))
			Endif	
			If lAutoCab .and. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. (aAutoCab[nPos][2] == 'TRF'))
				nIrrf := 0
			ElseIf !__lIrfMR
				nIrrf:=FCaIrBxCR(nValRec,,(SE1->E1_VALOR <> SE1->E1_SALDO .AND. (lRaRtImp .Or. lBQ10925)),,!(nParciais == 0),,dBaixa)
			EndIf
   		EndIf
	EndIf     	
	
	If lPccBxCR
		If (lMVGlosa .And. !__lPccMR) .or. (__lGlosPis .or. __lGlosCof .or. __lGlosCsl) 
			If nParciais == 0 // Não houve baixas parciais ainda
				nPis    := SE1->E1_PIS	
				nCofins := SE1->E1_COFINS
				nCsll   := SE1->E1_CSLL
			Else
				nPis    := 0	
				nCofins := 0
				nCsll   := 0			
			Endif 
			If Len(aDadosRef) < 7
				aDadosRef := Array(7)
				AFill( aDadosRef, 0 ) 
			Endif
			If Len(adadosRet) < 7
				aDadosRet := Array(7)
				AFill( aDadosRet, 0 ) 
			Endif			
		Else
		    If SE1->E1_MOEDA > 1
		    	If !lF070Auto
					nValRec := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
				Else
					If Type("nValRec")=="N"
						nValRec := xMoeda(nValRec,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
					Endif
				Endif
				nValRec:=nValRec - (IIf((!lBQ10925 .And. Alltrim(SE1->E1_ORIGEM) == "FINA280"), SE1->E1_VALLIQ, nParciais) - nTotMult)			
	        Else       
		    	If !lF070Auto
		    	    If (lPccBxCR .And. !__lPccMR) .and. dBaixa < dLastPcc    	  	
		        		nValRec := SE1->E1_VALOR - (IIf((!lBQ10925 .And. Alltrim(SE1->E1_ORIGEM) == "FINA280"), SE1->E1_VALLIQ, nParciais) - nTotMult) // (nTotMult = pagamento de multas nas baixas efetuadas anteriormente). Se fizermos 2 baixas parciais com multa alta, o valor SE1->E1_VALOR - nParciais será negativo
		        	Else
		        		If lBq10925
		        			nValRec := SE1->E1_VALOR - nParciais + nTotMult
		        		Else
		        			nValRec := SE1->E1_SALDO
		        		EndIf
		        	EndIf
	   	        	nOldValRec	:= nValRec
		   		Endif
			EndIf
			If lAutoCab .and. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. (aAutoCab[nPos][2] == 'TRF'))
				aAdd(aDadosRet, 0)
			Else
				If dBaixa < dLastPcc
					f070TotMes(dBaixa,.T.,,,,nTxMoeda)
				Else
					nBase	:= FBaseRPCC(nValRec,@lCalcPCC)
					If lJurMulDes
						If nBase-nDescont+nJuros+nVA+nMulta+nAcresc-nDecresc > 0
							nBase 	:= nBase-nDescont+nJuros+nVA+nMulta+nAcresc-nDecresc
						EndIf
					Else
						If FwIsInCallStack("FA450CMP") .AND. SE1->E1_SALDO <= (nValRec+Iif(!IsIssBx("R"), getVlIss(SE1->E1_FILIAL,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)), 0)+If(!lIrPjBxCr,SE1->E1_IRRF,0)+Iif(!lPropBx,  SE1->E1_INSS, 0)+Iif(lPccbxCr, SE1->(E1_PIS+E1_COFINS+E1_CSLL),0))
							nBase	+= Iif(!IsIssBx("R"), getVlIss(SE1->E1_FILIAL,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)), 0)
							nBase	+= If(!lIrPjBxCr,SE1->E1_IRRF,0)				
							nBase 	+= Iif(!lPropBx,  SE1->E1_INSS, 0)
							If lPccBxCR .and. nBase + SE1->(E1_PIS+E1_COFINS+E1_CSLL) == SE1->E1_VALOR
								nBase	+= SE1->(E1_PIS+E1_COFINS+E1_CSLL)
							EndIf
						Endif
					EndIf
					If !Empty(SE1->E1_NUMBOR)
						lGerPCCBD := FGERPCCBOR("R", SE1->(Recno()))
					EndIf
					
				  	If !__lPccMR .And. SE1->E1_TIPO # MVRECANT .and. ( !lGerPCCBD .Or. lFINA200 ) .And. lCalcPCC //.And. Empty(SE1->E1_NUMBOR)
						aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA)
						nPis	:= aPcc[2]
						nCofins	:= aPcc[3]
						nCsll	:= aPcc[4]
						//Reestruturacao SE5 - Para gravação das tabelas FK3 e FK4
						nPisCalc	:= nPis
						nPisBaseC	:= nBase	
						nPisBaseR 	:= nBase
						nCofCalc	:= nCofins	
						nCofBaseC	:= nBase
						nCofBaseR 	:= nBase
						nCslCalc	:= nCsll	
						nCslBaseC	:= nBase
						nCslBaseR 	:= nBase
						If lBq10925 .And. FwIsInCallStack("FA450CMP") .And. (nBase == SE1->E1_SALDO .and. nValRec <> nBase - (nPis + nCofins + nCsll))
							nValRec	:= nValRec - (nPis + nCofins + nCsll)
					  	Endif	
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf !__lPccMR .and. !__lIrfMR
		If cPaisLoc == "BRA" .And. !lF070Auto 
			nValRec := (xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda) - xMoeda(nParciais,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda))
			If dBaixa >= dLastPcc
				nValRec	-= nTotAbat
			EndIf
		ElseIf !lAutValRec
			nValRec := (xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,nDecs,nTxMoeda) - xMoeda(nParciais,SE1->E1_MOEDA,1,dDatabase,nDecs,nTxMoeda))
		Endif 	
	Endif	

	// Motor de retenção
  	If __lTemMR .And. SE1->E1_VALOR != SE1->E1_SALDO
  		aImpos := F070VldImp(nValRec, dBaixa, @lPccBxCr, @lIrPjBxCr, @lCalcIssBx)
  	EndIf
	//Carrego a variável para validação quando origem for mensagem única
	cAuxMBx	:= IIf(lAutoCab .And. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0), aAutoCab[nPos][2],"")

	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³Pr‚-inicializa o valor recebido.                                   ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMotBx	:= aDescMotBx[1]	//Motivo das baixas

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PONTO DE ENTRADA FA070POS  ³
	//³                           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite a altera‡„o de vari veis apos carga de dados do t¡tulo a ser ³
	//³ baixado, antes das informa‡äes serem mostradas na Tela.              ³
	//³ Vari veis dispon¡veis para serem alteradas :                         ³
	//³                                                                      ³
	//³ cBanco , cAgencia, cConta, cCheque                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Dourado 31/08/2000 criacao do ponto de entrada na mesma
	// posicao que foi criado no FINA080A.PRX (FA080POS), para a
	// inclusao da taxa do dolar do momento.
	// Carlao. 23/11/2005 - Inclusao de ponto de entrada de template

	// Template GEM
	If HasTemplate("LOT") .and. ExistTemplate("FA070POS")
		ExecTemplate("FA070POS",.F.,.F.)
	Endif
	If lFA070POS
		ExecBlock("FA070POS",.F.,.F.)
	Endif
	
	aColsSEV := {}
   
	fa070val( nValrec, nTxMoeda )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pr‚-inicializa a modalidade de SPB                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSpbInUse
		If !Empty(SE1->E1_MODSPB)
			cModSpb := SE1->E1_MODSPB
		Else
		   cModSpb := "1"
		Endif		
	Endif  
	
	If lFA070BLQ
	     lLibCm := ExecBlock("FA070BLQ",.F.,.F.)
    Endif
    
    
	If l070Auto .or. ! lF070Auto
		bSetKey := SetKey(VK_F4,{|| If( !SE1->E1_TIPO $ MV_CRNEG,CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1),.F.)})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recebe os dados do t¡tulo a ser baixado                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cPaisLoc=="CHI" )
			DEFINE FONT oFontLbl NAME "Arial" SIZE 6,15 BOLD
			DEFINE MSDIALOG oDlg FROM  69,33 TO 530,581 TITLE "Baixas a Receber" PIXEL OF oMainWnd  //
		Else			
			DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
			nLin2 := If(cPaisLoc=="BRA",657,520)
			// Template GEM, nova linha do rodape para os campos especificos do template.
			If lGemInUse
				nLin2 += 24
			EndIf
			
		    DEFINE MSDIALOG oDlg FROM  69,33 TO nLin2,581 TITLE "Baixas a Receber" PIXEL OF oMainWnd  //"Baixas a Receber"
		EndIf   

		If !Empty(cMotBx) .and. !MovBcoBx(cMotBx, .T.)
			cBanco 		:= CriaVar("E1_PORTADO",.F.)
			cAgencia	:= CriaVar("E1_AGEDEP" ,.F.)
			cConta 		:= CriaVar("E1_CONTA"  ,.F.) 
		Endif
		
		//Defino o tamanho dos componentes através do método FwDefSize(), amarrando ao objeto oDlg
		oSize := FwDefSize():New(.T.,,,oDlg)
	
		oSize:lLateral := .F.
		oSize:lProp := .T.
	
		oSize:AddObject("MASTER",100,100,.T.,.T.)
		
		oSize:Process()

		//Instancio um painel "master" como container dos demais paineis, mantendo a hierarquia
		oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),oSize:GetDimension("MASTER","COLINI"),;
								,oDlg,,,,,,oSize:GetDimension("MASTER","XSIZE"),oSize:GetDimension("MASTER","YSIZE"),.F.,.F.)
	
		oPanel1 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,, ,45,45,.f.,.f. )
		oPanel1:Align := CONTROL_ALIGN_TOP
		
		oPanel2 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,, ,30,30,.f.,.f. )
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		@ 001,002 GROUP oGrp1 TO 043, 272 LABEL "Principal" OF oPanel1 PIXEL //
		@ 001,002 GROUP oGrp2 TO If(cPaisLoc=="BRA",214,165), 133 LABEL "Dados Gerais" OF oPanel2  PIXEL //
		@ 001,139 GROUP oGrp3 TO If(cPaisLoc=="BRA",214,165), 272 LABEL "Valores da Baixa" OF oPanel2  PIXEL //
		oGrp1:oFont := oFontLbl
		oGrp2:oFont := oFontLbl
		oGrp3:oFont := oFontLbl

		//////////////////////////
		//Dados do titulo
		@ 008,004 SAY "Prefixo"				SIZE 31,07 OF oPanel1 PIXEL //
		@ 008,027 MSGET SE1->E1_PREFIXO	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,060 SAY 'Número' 				SIZE 31,07 OF oPanel1 PIXEL //"Número"
		@ 008,085 MSGET SE1->E1_NUM		SIZE 70,08 OF oPanel1 PIXEL When .F.
		@ 008,165 SAY 'Parcela'				SIZE 31,07 OF oPanel1 PIXEL //"Parcela"
		@ 008,188 MSGET SE1->E1_PARCELA	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,220 SAY 'Tipo'				SIZE 31,07 OF oPanel1 PIXEL //"Tipo"
		@ 008,238 MSGET oTipo VAR cTipo	F3 "SE1RDO" SIZE 30,08 OF oPanel1 PIXEL HASBUTTON
		oTipo:lReadOnly := .T.
		
		@ 019,004 SAY "Cliente" SIZE 22, 07 OF oPanel1 PIXEL //
		@ 019,027 MSGET oCodCli VAR SE1->E1_CLIENTE F3 "SA1" SIZE 65,08 OF oPanel1 PIXEL HASBUTTON //READONLY 
		oCodCli:lReadOnly := .T.
		@ 019,105 MSGET SA1->A1_NOME SIZE 165,08 OF oPanel1 PIXEL When .F.

		@ 030,004 SAY "Natureza" 				SIZE 31,07 OF oPanel1 PIXEL //
		@ 030,027 MSGET oNaturez VAR SE1->E1_NATUREZ	F3 "SED" SIZE 70,08 OF oPanel1 PIXEL HASBUTTON
		oNaturez:lReadOnly := .T.
		@ 030,105 SAY 'Emissao' 				SIZE 31,07 OF oPanel1 PIXEL //"Emiss„o"
		@ 030,133 MSGET SE1->E1_EMISSAO	SIZE 48,08 OF oPanel1 PIXEL HASBUTTON When .F.
		@ 030,189 SAY "Vencto.Atual" 				SIZE 49,07 OF oPanel1 PIXEL //"Vencto.Atual"
		@ 030,222 MSGET SE1->E1_VENCREA	SIZE 48,08 OF oPanel1 PIXEL HASBUTTON When .F.
      
		//////////////////////////
		//Dados Gerais		

		nUltLin := 10
		@ nUltLin,005 SAY "Hist.Emiss„o" SIZE 39, 07 OF oPanel2 PIXEL //"Hist.Emiss„o"
		@ nUltLin,065 MSGET SE1->E1_HIST       SIZE 65, 08 OF oPanel2 PIXEL When .F.

		nUltLin += 12
		@ nUltLin,005 SAY "Situa‡„o" SIZE 35, 07 OF oPanel2 PIXEL //"Situa‡„o"
		@ nUltLin,065 MSGET cSituacao          SIZE 65, 08 OF oPanel2 PIXEL When .F.

		nUltLin += 12	
		@ nUltLin,005 SAY "Mot.Baixa" SIZE 32, 07 OF oPanel2 PIXEL //"Mot.Baixa"

		aVlOringl[ 1 ] := nValRec
		aVlOringl[ 2 ] := nPIS 
		aVlOringl[ 3 ] := nCOFINS
		aVlOringl[ 4 ] := nCSLL
		aVlOringl[ 5 ] := nJuros
		aVlOringl[ 6 ] := nMulta
		aVlOringl[ 7 ] := nDescont
		aVlOringl[ 8 ] := nBase

		@ nUltLin,065 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotBx SIZE 65, 47 OF oPanel2 PIXEL ;
					ON CHANGE oBanco:lReadOnly := FN022SITCB(SE1->E1_SITUACA)[3] .or. !MovBcobx(cMotBx, .T.) ;
					VALID fa070BDev(oJuros, oMulta, oDescont, oCm, nTxMoeda, oCbx,.T.)	.and. ;
					fA070Val(nValRec,nTxMoeda,(!Empty(oCbx) .AND. oCbx:lModified),.T.) .and. ;
					IIF(lFA070MDB,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.),.T.)
	
		nUltLin += 18
		@ nUltLin,005 SAY "Banco" SIZE 32, 07 OF oPanel2 PIXEL //"Banco"
		@ nUltLin,065 MSGET oBanco var cBanco  SIZE 65, 08 OF oPanel2 PIXEL F3 cF3Bco ;
				Valid (AtulValidou() .And. !MovBcobx(cMotBx, .T.) .and. Empty(cBanco)) .or. ;
						(IiF(lFa070Bco,ExecBlock("FA070BCO",.F.,.F.),.T.) .And.;
							  F070VldBco(cBanco,@cAgencia,@cConta,.T.,.T.) .And. ;
							  f070AltBco(nTxMoeda,oJuros, oMulta, oDescont, oCm, oBanco,nValRec, @oTxMoeda) .And. ;
							  Iif(lMoedaBco .And. SE1->E1_MOEDA <> SA6->A6_MOEDA, ( F070CnvPcc(nTxMoeda, SE1->E1_MOEDA), oPanel2:Refresh()),.T.) .And. ;
							  IIF(lJFilBco, JurVldSA6("1", {cEscrit, cBanco, cAgencia, cConta}), .T.)) HASBUTTON
		oBanco:lReadOnly := (FN022SITCB(SE1->E1_SITUACA)[3] .OR. !MovBcobx(cMotBx, .T.))
		
		nUltLin += 12
		@ nUltLin,005 SAY "Agencia" SIZE 32, 07 OF oPanel2 PIXEL //"Agˆncia"
		@ nUltLin,065 MSGET oAgencia var cAgencia  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(F070VldBco(cBanco,cAgencia,@cConta,.T.,.T.,cAgencia) .AND. ;
							f070AltBco(nTxMoeda,oJuros, oMulta, oDescont, oCm,oBanco,nValRec, @oTxMoeda),.T.,oBanco:SetFocus()),.T.) .And. ;
							IIF(lJFilBco, JurVldSA6("2", {cEscrit, cBanco, cAgencia, cConta}), .T.) ;
							WHEN ( !FN022SITCB(SE1->E1_SITUACA)[3] .and. MovBcoBx(cMotBx, .T.) )
		nUltLin += 12
		@ nUltLin,005 SAY "Conta" SIZE 28, 07 OF oPanel2 PIXEL //"Conta"
		@ nUltLin,065 MSGET oConta var cConta  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(F070VldBco(cBanco,cAgencia,cConta,.T.,.T.,cAgencia+cConta) .And. ;
							f070AltBco(nTxMoeda,oJuros, oMulta, oDescont, oCm,oBanco,nValRec, @oTxMoeda),.T.,oBanco:SetFocus()),.T.) .And. ;
							IIF(lJFilBco, JurVldSA6("3", {cEscrit, cBanco, cAgencia, cConta}), .T.) ;
							WHEN ( !FN022SITCB(SE1->E1_SITUACA)[3] .and. MovBcoBx(cMotBx, .T.) )

		nUltLin += 12
		dDtRecbAux := dBaixa
		@ nUltLin,005 SAY "Data Receb." SIZE 39, 07 OF oPanel2 PIXEL//"Data Receb."
		@ nUltLin,065 MSGET oDtBaixa VAR dBaixa SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON When F070DtRe() .and. lAcessdBaixa Valid fA070Data(@nTxMoeda,,oDtBaixa,oJuros,,,,@aImpos) ; //feito a chamada aqui, pois nao estava executando a funcao fa070data ao perder o foco no campo
							 .And. ( Iif( lSigaGSP, GSPF250(), .T.) .And. ( nOldJuros := nJuros, .T. ).and. If (dBaixa <> dDataBase .and.;
							  SE1->E1_VALOR == nValRec+nPis+nCofins+nCsll+nIrrf,(Iif(!__lIrfMR,nIrrf:=FCaIrBxCR(SE1->E1_VALOR),nIrrf),Iif(dBaixa < dLastPcc,f070TotMes(dBaixa,.T.,,,dBaixa <> dDtRecbAux),.T.)), .T. ))
							    
		nUltLin += 12
		@ nUltLin,005 SAY "Data Credito" SIZE 32, 07 OF oPanel2 PIXEL //"Data Cr‚dito"
		@ nUltLin,065 MSGET oDtCredito VAR dDtCredito SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Valid (dDtCredito >= dBaixa  .and. Iif(cBxDtFin == "2", DtMovFin(dDtCredito,,"2"), .T.) ) .or. lAntCred
		oDtCredito:SetEnable( lAcessDtCredito )
	
		nUltLin += 12
		@ nUltLin,005 SAY "Hist.Baixa" SIZE 32, 07 OF oPanel2 PIXEL //"Hist.Baixa"
		@ nUltLin,065 MSGET cHist070           SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Picture "@!" VALID CheckSX3("E5_HISTOR") When VisualSX3("E5_HISTOR")

		If cPaisLoc == "BRA" .And. SE1->E1_MOEDA > 1
			nUltLin += 12
			@ nUltLin,005 SAY "Taxa contratada" 	SIZE 53, 07 OF oPanel2 PIXEL //"Taxa contratada"
			@ nUltLin,065 MSGET oTxMoeda VAR nTxMoeda  SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SM2","M2_MOEDA"+AllTrim(Str(SE1->E1_MOEDA))) ;
						 			Valid ( Iif( nOldJuros + nJuros > 0 , fA070Data(nTxMoeda,.F.,,,,.T.) , Nil ) , Iif( nOldMulta + nMulta > 0 , fA070Val(nMulta,nTxMoeda) , Nil ) , F070CnvPcc(nTxMoeda, SE1->E1_MOEDA) , oPanel2:Refresh() )
		Endif	

		If lSpbInUse
			nUltLin += 12
			@ nUltLin,005 SAY "Modalidade SPB" SIZE 32, 07 OF oPanel2 PIXEL  //"Modalidade SPB"
			@ nUltLin,065 COMBOBOX oModSPB VAR cModSpb ITEMS aModalSpb SIZE 65, 47 OF oPanel2 PIXEL ;
								  When MovBcoBx(cMotBx,.T.)
		Endif

		nUltLin += 12
		@ nUltLin,005 SAY "Rateio Mult.Naturezas" SIZE 100, 07 OF oPanel2 PIXEL	//"Rateio Mult.Naturezas"
		@ nUltLin,065 CHECKBOX oMultNat VAR lMultNat PROMPT "" SIZE 12,12 OF oPanel2 PIXEL

		//////////////////////////
		//Dados da Baixa		
		nLinha := 10
		If cPaisLoc <> "CHI"
		   @ nLinha,144 SAY "Valor Original " + cDescMoeda SIZE 53, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE//"Valor Original "
		   @ nLinha,204 MSGET SE1->E1_VALOR  SIZE 66, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE When .F. Picture PesqPict("SE1","E1_VALOR") HASBUTTON //"@E 999,999,999,999.99"

		Else
		   @ nLinha,144 SAY "Valor Original " SIZE 53, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE //"Valor Original "
		   @ nLinha,204 MSGET SE1->E1_VLCRUZ      SIZE 66, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE When .F. Picture PesqPict("SE1","E1_VLCRUZ") HASBUTTON //"@E 999,999,999,999.99"		
		EndIf

		nEstOriginal := nValEstrang-(xMoeda(nJuros+nVA+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))  

		FA070CORR(nEstOriginal,nTxMoeda)
	
		If cPaisLoc <> "CHI"
			nLinha +=12
			@ nLinha,144 SAY "- Abatimentos" SIZE 53, 07 OF oPanel2 PIXEL // "- Abatimentos"
			@ nLinha,204 MSGET nTotAbLiq   SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" ) HASBUTTON  //"@E 999,999,999,999.99"

			If cPaisLoc == "BRA"		
				nLinha +=12
				@ nLinha,144 SAY "- Impostos" SIZE 53, 07 OF oPanel2 PIXEL // "- Impostos"
				@ nLinha,204 MSGET nTotAbImp  SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" ) HASBUTTON //"@E 999,999,999,999.99"    

				nValorLiq :=  (SE1->E1_VALOR - nTotAbLiq - nTotAbImp)
				nLinha +=12
				@ nLinha,144 SAY "Valor Liquido" SIZE 53, 07 OF oPanel2 PIXEL // "Valor Liquido"
				@ nLinha,204 MSGET oValorLiq VAR nValorLiq     SIZE 66, 08 OF oPanel2 PIXEL When .F. Picture PesqPict("SE1","E1_VLCRUZ") HASBUTTON //"@E 999,999,999,999.99"		
			Endif
		Else 
			nLinha +=12
			@ nLinha,144 SAY "+/- Dif. Cambio" SIZE 53, 7 OF oPanel2 PIXEL // "+/- Dif. Cambio"
			@ nLinha,204 MSGET oDifCambio VAR nDifCambio SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("SE1","E1_VLCRUZ" /*"E1_CAMBIO"*/)  When .F. 
		EndIf
		nLinha +=12
		@ nLinha,144 SAY "- Pagtos Parciais" SIZE 53, 07 OF oPanel2 PIXEL //"- Pagtos Parciais"
		@ nLinha,204 MSGET nParciais          SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When .F.  Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

		nLinha +=12                                                                  
		@ nLinha,144 SAY  "- Decrescimo" SIZE 53, 07 OF oPanel2 PIXEL //"- Decrescimo"
		@ nLinha,204 MSGET Iif(lSDDECVL, SE1->E1_DECRESC,Iif(nDecrescF > 0,nDecrescF,nDecrVlr))  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_DECRESC" )  When .f. 

		nLinha +=12                                                                  
		@ nLinha,144 SAY "+ Acrescimo" SIZE 53, 07 OF oPanel2 PIXEL //"+ Acrescimo"
		@ nLinha,204 MSGET IIF(lSDACRVL,SE1->E1_ACRESC,nAcresc)  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_ACRESC" )  When .F.
		
		// Template GEM, campos especifico do template.
		If lGemInUse
			nLinha +=12 
			@ nLinha,144 SAY "+ C.M." SIZE 53, 07 OF oPanel2 PIXEL // "+ C.M."
			@ nLinha,204 MSGET oCM1 VAR nCM1  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When iIf(GMBLQCM() .Or. SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99" 
																Valid fa070CM1(oCM1,oJuros,oMulta) .AND. fa070Calc( nTxMoeda )
		EndIf
        
		nLinha +=12
		@ nLinha,144 SAY "- Descontos" SIZE 53, 07 OF oPanel2 PIXEL //"- Descontos"
		@ nLinha,204 MSGET oDescont VAR nDescont  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When F070DSC() .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.) .And. lAcessDesc Picture PesqPict( "SE1","E1_DESCONT" ) ; //"@E 999,999,999,999.99" 
																Valid F70VlDsc(lTpDesc,lNatApura) 

		oDescont:SetEnable( lAcessDesc )
		nOldDescont := nDescont
																	
		// Template GEM, campo especifico do template.
		If lGemInUse
			nLinha +=12
			@ nLinha,144 SAY "+ Pro Rata" SIZE 53, 07 OF oPanel2 PIXEL // "+ Pro Rata"
			@ nLinha,204 MSGET oProRata VAR nProRata SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When iIf(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99" 
																Valid fa070PRata( oProRata ,oJuros ,oMulta ) .AND. fa070Calc( nTxMoeda )
		EndIf

		nLinha +=12
		@ nLinha,144 SAY "+ Multa" SIZE 53, 07 OF oPanel2 PIXEL //"+ Multa"
		@ nLinha,204 MSGET oMulta VAR nMulta  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When If(F070Mul(oMulta) .And. SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  .And. lAcessMul Picture PesqPict( "SE1","E1_MULTA" ) ; //"@E 999,999,999,999.99" 
															Valid (F070Mul(oMulta),Iif( (!Empty(oMulta) .AND. oMulta:lModified), (fA070Val(nMulta,nTxMoeda),nOldMulta := nMulta), .T.))	
															//Valid (F070Mul(oMulta) .and. fA070Val(nMulta,nTxMoeda)) //Augusto 07/04/2015 Foi retirado a comparal?o com nMulta e nOldMulta para for?r a atualiza?o,pois estava calculando errado															
		oMulta:SetEnable( lAcessMul )
		nOldMulta := nMulta

	   If cPaisLoc <> "CHI"
			nLinha +=12
			@ nLinha,144 SAY "+ Tx.Permanenc." SIZE 53, 07 OF oPanel2 PIXEL //"+ Tx.Permanenc."
			@ nLinha,204 MSGET oJuros VAR nJuros   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When F070Jrs() .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.) .And. lAcessJur Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99"
															Valid F070TxPer(oJuros) .AND. Iif(!Empty(oJuros) .and. oJuros:lModified, (fA070Val(nJuros,nTxMoeda),nOldJuros := nJuros),.T.)
															//Valid (F070TxPer(oJuros) .AND. fA070Val(nJuros,nTxMoeda))	//Augusto 07/04/2015 Foi retirado a comparal?o com nJuros e nOldJuros para for?r a atualiza?o,pois estava calculando errado		   													 
		   oJuros:SetEnable( lAcessJur )
			nOldJuros := nJuros
		Else 
		   nLinha +=12
		   @ nLinha,144 SAY "- Outros Gastos" SIZE 53, 07 OF oPanel2 PIXEL //"- Outros Gastos"
		   @ nLinha,204 MSGET oOtrga VAR nOtrga  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_OTRGA" ) ; //"@E 999,999,999,999.99" 		   													
		   Valid fA070Val(nOtrga)
		EndIf     
		
		//Valores Acessorios
		If lPodeTVA .and. lExistVA
		 	FAPodeTVA(SE1->E1_TIPO,SE1->E1_NATUREZ,.F.,"R")
			nLinha +=12
			@ nLinha,144 SAY "+ " + "Valores Acessórios" 	SIZE 53,07 OF oPanel2 PIXEL		//"Valores Acessórios"
			@ nLinha,204 MSGET oVA VAR nVA SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("FKD","FKD_VALOR") When  .F.
			nOldVA := nVA  
		EndIf
		
		//Controla IRPJ na baixa
		If cPaisLoc == "BRA" .And. lIrPjBxCr .And. !__lIrfMR
			nLinha +=12	
			@ nLinha,144 SAY "- IRRF"  SIZE 53, 07 OF oPanel2 PIXEL  // "- IRRF"
			@ nLinha,204 MSGET oIrrf VAR nIrrf SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_IRRF" ); //"@E 999,999,999,999.99"
															 Valid Iif( nOldIrrf # nIrrf, (fA070Val(nIrrf,nTxMoeda,.T.),nOldIrrf := nIrrf), .T.)//f070ValRec(@nValorRec,nTotAbLiq,nPis,nCofins,nCsll,nIrrf,nIss,nInss)
			nOldIrrf := nIrrf
		EndIf 
				
		If cPaisLoc == "BRA" .And. lPccBxCR .And. !__lPccMR //1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default)
			nLinha +=12
			@ nLinha,144 SAY "- PIS" SIZE 53, 07 OF oPanel2 PIXEL //"- PIS"
			@ nLinha,204 MSGET oPIS VAR nPIS   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON  Picture PesqPict( "SE1","E1_PIS" ) ; //"@E 999,999,999,999.99"
					Valid Iif(nOldPis # nPis, (fA070Val(nPIS,nTxMoeda,.T.),nOldPis := nPis), .T.)
			nOldPis := nPis
			oPIS:SetEnable( lAcessPIS )
		
			nLinha +=12
			@ nLinha,144 SAY "- COFINS" SIZE 53, 07 OF oPanel2 PIXEL //"- COFINS"
			@ nLinha,204 MSGET oCOFINS VAR nCOFINS   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_COFINS" ) ; //"@E 999,999,999,999.99"
				Valid Iif(nOldCofins # nCofins, (fA070Val(nCOFINS,nTxMoeda,.T.),nOldCofins := nCofins), .T.)
			nOldCofins := nCofins			
			oCOFINS:SetEnable( lAcessCOF )		

			nLinha +=12
			@ nLinha,144 SAY "- CSLL" SIZE 53, 07 OF oPanel2 PIXEL //"- CSLL"
			@ nLinha,204 MSGET oCSLL VAR nCSLL   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_CSLL" ) ; //"@E 999,999,999,999.99"
				Valid (oCSLL:Refresh(),Iif(nOldCsll # nCsll, (fA070Val(nCsll,nTxMoeda,.T.),nOldCsll := nCsll), .T.))
			nOldCsll := nCsll			
			oCSLL:SetEnable( lAcessCSLL )
		EndIf          	

		If __lTemMR .And. __nTotImp > 0
			nLinha +=12
			@ nLinha,144 SAY "- Retenções"	SIZE 53,07 OF oPanel2 PIXEL //"- Retenções"
			@ nLinha,204 MSGET __oRetMot VAR __nTotImp	SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("SE1","E1_VALLIQ")  ;
			Valid .T. When .F.
		EndIf

		  
		IF SE1->E1_MOEDA > 1 .Or. cPaisLoc <> "BRA"	
		   nLinha +=12
			@ nLinha,144 SAY "= Valor Recebido" SIZE 53,07 OF oPanel2 PIXEL COLOR CLR_HBLUE //"= Valor Recebido"
			@ nLinha,204 MSGET oValRec VAR nValRec SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON COLOR CLR_HBLUE Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99" 
															Valid ( oValRec:Refresh(),;                                                                           
																		fa070Calc(nTxMoeda,.F.,.T.),;															
																		Fa070ValVR(nTxMoeda),;
																		FA070ValRec(oJuros,oMulta,oProRata,oDescont,aVlOringl,@aImpos),;
																		oVlEstrang:Refresh(),;																		
																		oCM:Refresh() )
			nLinha +=12
			@ nLinha,144 SAY "Valor "+SubStr(GetMV("MV_SIMB"+cMoeda),1,3) SIZE 53, 7 OF oPanel2 PIXEL // "Valor "
			@ nLinha,204 MSGET oVlEstrang VAR nValEstrang SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON  ;
						 Picture PesqPict( "SE1","E1_VALOR" )  ;
						 VALID FA070Estrang(nTxMoeda) .And.;
						 		 Fa070ValEstrang(	nValEstrang,@nTxMoeda,@nValRec,dBaixa,oValRec,oTxMoeda,;
														nJuros+(nCm1+nProRata),nMulta,nDescont,nOtrga,nEstOriginal,oVlEstrang) .And.;
								FA070ValRec(oJuros,oMulta,oProRata,oDescont,,@aImpos)
			nLinha +=12
			@ nLinha,144 SAY "+ Corr.Monetaria" SIZE 53,07 OF oPanel2 PIXEL // "+ Corr.Monet ria"
			@ nLinha,204 MSGET oCM     VAR nCM		SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1", "E1_CORREC" )  ; // "@E 999,999,999,999.99" 
															When ( lCalcCM .And. cPaisLoc <> "BRA" ) .OR. lLibCm
		

		Else

		   nLinha +=12
			@ nLinha,144 SAY "= Valor Recebido" SIZE 53,07 OF oPanel2 PIXEL COLOR CLR_HBLUE //"= Valor Recebido"
			@ nLinha,204 MSGET oValRec VAR nValRec        SIZE 66, 08 OF oPanel2 ;
							PIXEL HASBUTTON COLOR CLR_HBLUE ;
							Valid ( oValRec:Refresh(), FA070ValRec(oJuros,oMulta,oProRata,oDescont,aVlOringl,@aImpos) .and. Fa070Liq(oJuros,oValRec, oPanel2),  nValEstrang := nValRec ) ;
							Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"
		Endif
	
		If ( cPaisLoc <> "BRA" )
			AADD(aButtons, {"TABPRICE", {|| (nTxMoeda:=Fa070SetMd(),f070AltBco(nTxMoeda,oJuros, oMulta, oDescont, oCm))},"MOEDAS" }) //Troca de Taxas
		Endif  
		
		If __lTemMR .And. __nTotImp > 0
			Aadd(aButtons, {"NOTE", {||F070ConImp(aImpos)},,"Retenção de impostos" ,"Retenção de impostos" }) //"Retenção de impostos" 
		EndIf
		
		If lPanelFin	
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{|| IIf(FA070BtOK(),iIf( IIf( MovBcoBx(cMotBx, .T.),F070VldBco(cBanco,cAgencia,cConta,.T.,.F.), .T. ) ;
					.and. If(cBxDtFin == "2",DtMovFin(dBaixa,,"2"),.T.) .and. PcoVldLan("000004","01","FINA070") .and. iIf(lFA070MDB .and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.) ,.T.) ,;
					(nOpc1 := 1,oDlg:End()),Nil),Nil)},;
					{||(nOpc1 := 0,oDlg:End())},aButtons) CENTERED
		Else
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf(FA070BtOK(),iIf( IIf( MovBcoBx(cMotBx, .T.),F070VldBco(cBanco,cAgencia,cConta,.T.,.T.), .T. ) ;
					.and. If(cBxDtFin == "2",DtMovFin(dBaixa,,"2"),.T.) .and. 	PcoVldLan("000004","01","FINA070") .and. iIf(lFA070MDB .and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.) ,.T.) ;
					,IIf( UsaSeqCor(), IIf( FA070Diario(), (nOpc1 := 1,oDlg:End()),Nil), (nOpc1 := 1,oDlg:End()) ) ;
					,Nil),Nil)};
					,{||(nOpc1 := 0,oDlg:End())},,aButtons) CENTERED
		EndIf
		
		If __lTemMR  .and. __lPropPcc .and. nValrec < __nTotImp 
			nImp := Len(aImpos)
			For nW := 1 To nImp
				Do Case
					Case __lPccMR .And. nPis <> nOldPis .And. AllTrim(aImpos[nW,8]) == "PIS" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nPis
					Case __lPccMR .And. nCofins <> nOldCofins .And. AllTrim(aImpos[nW,8]) == "COF" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nCofins
					Case __lPccMR .And. nCsll <> nOldCsll .And. AllTrim(aImpos[nW,8]) == "CSL" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nCsll 
					Case __nTotImp <> nOldImp .And.(!(AllTrim(aImpos[nW,8]) == "PIS") .And. !(AllTrim(aImpos[nW,8]) == "COF") .And. !(AllTrim(aImpos[nW,8]) == "CSL"))  .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := __nTotImp 
				End Case  
			Next nW
		Endif
   		If (nPis+nCofins+nCSLL) <> (nOldPis+nOldCofins+nOldCsll)
	   		//Atualiza valores retido, caso o usuário tenha alterado o valor dos impostos
	   		nVlRetPis := nPis
	   		nVlRetCof := nCofins
	   		nVlRetCsl := nCsll
	   		//Refazendo base de retenção caso ocorra alteração do usuário
			nPisBaseR   := nPis * 100
			nCofBaseR   := nCofins * 100
			nCslBaseR   := nCsll * 100
	   	Endif
  		SetKey(VK_F4,bSetKey)
    Else
    	If FwIsInCallStack("FA450CMP")
			nValOld := nValRec
    	Endif

		//Valores Acessorios
		//ESTRUTURA __aVAAuto
		//__aVAAuto[nLaco][1] = cChaveFK7
		//__aVAAuto[nLaco][2] = Código do VA
		//__aVAAuto[nLaco][3] = Valor do VA
		If lPodeTVA .and. lExistVA
			FKD->( dbSetOrder( 2 ) ) //FKD_FILIAL+FKD_IDDOC+FKD_CODIGO
			nRecSe1 := SE1->(RecNo())
			
			If Len(__aVAAuto) > 0
				FVAAuto( .T. ) //Indica que, ao ativar o model FINA070VA, os VAs não serão recalculados (pois os valores já vieram na execauto)  
								
				For nLaco := 1 To Len(__aVAAuto)
							
					cAcaoVA := Posicione( "FKC", 1, FWxFilial("FKC") + __aVAAuto[nLaco][2], "FKC_ACAO" )
					If cAcaoVA == "2" //Se for VA de subtração, então multiplica o valor informado na execauto por -1
						nVaCalc := __aVAAuto[nLaco][3] * -1
					Else
						nVaCalc := __aVAAuto[nLaco][3]
					Endif
					
					If FKD->( msSeek( FWxFilial("FKD") + __aVAAuto[nLaco][1] + __aVAAuto[nLaco][2] ) )
						RecLock("FKD",.F.)
							FKD->FKD_VLCALC := nVaCalc
							FKD->FKD_VLINFO := nVaCalc
						FKD->(MsUnlock())
					Else
						RecLock("FKD",.T.)
							FKD->FKD_FILIAL := xFilial("FKD")
							FKD->FKD_IDDOC  := __aVAAuto[nLaco][1]
							FKD->FKD_CODIGO := __aVAAuto[nLaco][2]
							FKD->FKD_VALOR  := __aVAAuto[nLaco][3]
							FKD->FKD_SALDO  := 0
							FKD->FKD_DTBAIX := CtoD("//")
							FKD->FKD_VLCALC := nVaCalc
							FKD->FKD_VLINFO := nVaCalc
						FKD->(MsUnlock())
					EndIf
				Next nLaco
			ElseIf lF070Auto 				
				FVAAuto( .F. ) //Indica que, ao ativar o model FINA070VA, os VAs serão calculados				
			Endif
			
			//Ativa o modelo de dados para calcular os VAs (ou considerar os valores recebidos na execauto)			
			cOldVA := ""
			oModelVA := FWLoadModel("FINA070VA")
			oModelVA:SetOperation( MODEL_OPERATION_UPDATE )
			oModelVA:Activate()
			cOldVA  := oModelVA:GetXMLData()
			oModelVa:Deactivate()
			oModelVa:Destroy()
			oModelVa := NIL
			FVAAuto( .F. )
			
			dbSelectArea("SE1")
			SE1->( dbGoTo(nRecSe1) )
								
		Endif
		
		aValidGet:= {}
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMOTBX'})) > 0
			cMotBx	:=	aAutoCab[nT,2]	
			If Len(AllTrim(cMotBx)) == 3
				If (nY := ascan(aMotBx,{|x| SubStr(x,1,3) == AllTrim(cMotBx)})) > 0
					aAutoCab[nT,2] := SubStr(aMotBx[nY],07,10)
					cMotBx := aAutoCab[nT,2]
				EndIf
			EndIf
			If ! lFA070MDB
	 	 		Aadd(aValidGet,{'cMotBx' ,aAutoCab[nT,2],"fa070BDev()",.t.})
	 	 	Else
 	 			Aadd(aValidGet,{'cMotBx' ,aAutoCab[nT,2],"fa070BDev()	.and. ExecBlock('FA070MDB',.F.,.F.)",.t.})
 	 		EndIf	
 	 	EndIf	
		If (! FN022SITCB(SE1->E1_SITUACA)[3]) .and. MovBcobx(cMotBx, .T.)
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTBANCO'})) > 0
				Aadd(aValidGet,{'cBanco' ,aAutoCab[nT,2],"CarregaSa6(@cBanco,,,.T.)",.t.})		
			Endif	
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTAGENCIA'}) ) > 0
				Aadd(aValidGet,{'cAgencia' ,aAutoCab[nT,2],"CarregaSa6(@cBanco,@cAgencia,,.T.)",.t.})		
			EndIf	
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCONTA'}) ) > 0
				Aadd(aValidGet,{'cConta' ,aAutoCab[nT,2],"CarregaSa6(@cBanco,@cAgencia,@cConta,.T.,,.T.)",.t.})		
			EndIf	
		EndIF
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDTBAIXA'}) ) > 0
			Aadd(aValidGet,{'dBaixa' ,aAutoCab[nT,2],"fA070Data(,.F.)",.t.})
		EndIf	
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDTCREDITO'}) ) > 0
		   Aadd(aValidGet,{'dDTCredito' ,aAutoCab[nT,2],"(dDtCredito >= dBaixa  .and. Iif(SuperGetMv('MV_BXDTFIN',,'1') == '2', DtMovFin(dDtCredito), .T.)) .or. GetMv('MV_ANTCRED')",.t.})
		EndIf	
		If VisualSX3("E5_HISTOR") .AND. (nT := ascan(aAutoCab,{|x| x[1]='AUTHIST'}) ) > 0
			Aadd(aValidGet,{'cHist070' ,aAutoCab[nT,2],"CheckSX3('E5_HISTOR')",.t.})		
		EndIf	

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
			Aadd(aValidGet,{'nAcresc' ,aAutoCab[nT,2],"fA070Val(nAcresc)",.t.})		
		EndIf	
		
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			Aadd(aValidGet,{'nMulta' ,aAutoCab[nT,2],"fA070Val(nMulta)",.t.})		
		EndIf	
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			Aadd(aValidGet,{'nJuros' ,aAutoCab[nT,2],"fA070Val(nJuros)",.t.})		
		EndIf	
		
		// Template GEM, validacao dos campos especificos do template.
		If lGemInUse
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCM1'}) ) > 0
				Aadd(aValidGet,{'nCM1' ,aAutoCab[nT,2],"fa070Calc()",.t.})
			EndIf
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTPRORATA'}) ) > 0
				Aadd(aValidGet,{'nProRata' ,aAutoCab[nT,2],"fa070Calc()",.t.})
			EndIf
		EndIf
		
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			If lGemInUse
				Aadd(aValidGet,{'nDescont' ,aAutoCab[nT,2],"FA070DESC(oDescont) .and. fA070Val(nDescont) .and. (nDescont <= (Round(nCM1+nMulta+nJuros+nVA+nProRata,2)+xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBAIXA)))",.t.})
			Else
				Aadd(aValidGet,{'nDescont' ,aAutoCab[nT,2],"FA070DESC(oDescont) .and. fA070Val(nDescont) .and. (nDescont <= Round(nMulta+nJuros+nVA,2)+xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBAIXA))",.t.})		
			Endif

		EndIf	

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
		 	Aadd(aValidGet,{'nDecresc' ,aAutoCab[nT,2],"fA070Val(nDecresc)",.t.})		
		EndIf
				
		If SE1->E1_MOEDA > 1  .Or. cPaisLoc<>"BRA"
			If cPaisLoc == "BRA"
				If (nT := ascan(aAutoCab,{|x| x[1]='AUTTXMOEDA'}) ) > 0
					nTxMoeda	:=	aAutoCab[nT,2]
					Aadd(aValidGet,{'nTxMoeda' ,aAutoCab[nT,2],"Fa070Val(0,"+STR(nTxMoeda,17,TamSx3("E2_TXMOEDA")[2])+")",.t.})		
				EndIf	                            
			Endif
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
				Aadd(aValidGet,{'nValRec' ,aAutoCab[nT,2],"Fa070ValVR("+Alltrim(Str(nTxMoeda))+")",.t.})
			EndIf	
		Else
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
				Aadd(aValidGet,{'nValRec' ,aAutoCab[nT,2],".T.",.t.})		
			EndIf	
		Endif
		
		nEstOriginal := nValEstrang-(xMoeda(nJuros+nVA+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))
		FA070CORR(nEstOriginal)
		
		If !(AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
			If ! SE1->(MsVldGAuto(aValidGet)) // consiste os gets
				Return .f.
			EndIf     
		EndIf
		
		If lF070Auto
			//Se o valor acessório vínculado (FKD) não foi informado na ExecAuto, então a rotina fará o cálculo e nesse trecho irá tratar (subtrair ou somar) o VA no valor recebido. 
			If ValType( __AVAAUTO ) <> "A" .Or. Len( __AVAAUTO ) == 0
				nValRec := nValRec + nVA
			EndIf
									
			If !lMvGlosa
				If lFINA200 .Or. FwIsInCallStack("Fa450cmp") .Or. (AllTrim(SE1->E1_ORIGEM) $ 'S|L|T') // se for retorno do Cnab ou compesação entre carteiras ou baixa oriunda de integração
				
					// Considera diretamente os valores passados pela EXECAUTO.
					If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
						nJuros := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
						nDescont := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
						nMulta := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
						nAcresc := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
						nDecresc := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					IF !("FINA040" $ SE1->E1_ORIGEM)
						SC5->(dbSetOrder(1))
						If SC5->(MsSeek(xfilial("SC5")+SE1->E1_PEDIDO))
							lRecIss := (SC5->C5_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
						Else
							lRecIss := (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
						Endif
					Else
						lRecIss := (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
					Endif

					If nValRec == SE1->E1_VALOR // Só se for baixa total por Cnab
						nValrec -= SE1->( IIF( !lPccBxCr, SE1->(E1_PIS+E1_COFINS+E1_CSLL), 0 ) + ; //PCC
										  IIF( !lIrPjBxCr, SE1->E1_IRRF, 0 ) + ;				   //IRRF
										  IIF( lRecIss, E1_ISS, 0 ) + E1_INSS )					   //ISS e INSS
					Endif

					If lPccBxCr
						nValrec -= nPis + nCofins + nCsll
					EndIf
					If lIrPjBxCr 
						nValrec -= nIrrf
					EndIf
					If lCalcIssBx
						nValrec -= IIF( lRecIss, SE1->E1_ISS, 0 )
					EndIf
	
					nValRec += nJuros + nVA - nDescont + nMulta + nAcresc - nDecresc
					
					If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
						aAutoCab[nT,2] := Round(NoRound(nValRec,2),2)
					EndIf
				Else
					If !lBq10925 // Baixa Parcial - Liquido
						nOldValRec := nValRec
						nValRec := nValRec - nPis - nCoFins - nCsll - nIrrf
												
						If nValRec < 0
							nValRec := nOldValRec
						Endif
						
						If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
							aAutoCab[nT,2] := Round(NoRound(nValRec,2),2)
						EndIf
					EndIf
				EndIf
			EndIf
		Endif
	   
		nOpc1 := 1 
		
		// Se o conteudo do campo estiver vazio(zero), se existir o 4o. elemento no array de campos
		// e o mesmo retornar .T., assume os valores que o usuario enviou no array da rotina automatica
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nJuros := aAutoCab[nT,2]
				fa070val(nJuros,nTxMoeda,.F.)
			Endif	
		EndIf	
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nMulta := aAutoCab[nT,2]
				fa070val(nMulta,nTxMoeda,.F.)
			Endif	
		EndIf	
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nDescont := aAutoCab[nT,2]
				fa070val(nDescont,nTxMoeda,.F.)
			Endif	
		EndIf
		
		// Template GEM, validacao dos campos especificos do template.
		If lGemInUse
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCM1'}) ) > 0
				If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
					nCM1 := aAutoCab[nT,2]
					fa070val(nCM1)
				EndIf
			EndIf
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTPRORATA'}) ) > 0
				If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
					nProRata := aAutoCab[nT,2]
					fa070val(nProRata)
				EndIf
			EndIf
		EndIf		
	EndIf  
	
	//Define a variável estática que indica se a tela de baixa foi cancelada (controle de processo com integração Protheus x TIN)
	__lCancTBx := ( nOpc1 == 0 ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para permitir um controle do total de ³
	//³ cheques informados com o total a ser baixado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF070TCTR .And. nOpc1 > 0 .And. nSomaCheq > 0
	   nOpc1 := ExecBlock("F070TCTR",.F.,.F.,{nOpc1,nSomaCheq,nValRec})
	EndIf
	
	If nOpc1 == 0
		nErro ++
	EndIF
    
	If !lF070Auto .And. nOpc1 == 0 .And. AllTrim(SE1->E1_ORIGEM)=="FINI055"		
		If FWHasEAI("FINI070A",.T.,,.T.) 
			SetRotInteg('FINI070A')
			MsgRun ( "Atualizando título"+" "+rTrim(SE1->E1_NUM)+ " " +"a valor presente...",'Valor Presente',{||aRetMsg:=FinI070A()} )//"Atualizando título" "a valor presente..." Valor Presente									
			If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
				If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
					MsgAlert("Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:" + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
				Else
					MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título "  + " " + Rtrim(SE1->E1_NUM)+". "+"Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
				EndIf
			ElseIf Valtype(aRetMSg[1]) == "U"
				MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título "  + " " + Rtrim(SE1->E1_NUM) + ". " + "Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
			Endif
			SetRotInteg('FINA070')
		Else
			MsgAlert("Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL.")//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
		EndIf
	Endif

	If SE1->( Deleted() )
		nOpc1 := 0
		Help( " " , 1 , "RECNO" )
		Return .F.
	EndIf

	If nErro > 2
		nErro :=0
		If Abandona()
			MsUnlock()
			Return Nil
		Endif
	Endif
	If nOpc1 == 1
	    
		If nCM1 > 0
			nJuros += nCM1
		Else
			nDescont -= nCM1
		EndIf
		
		If nProRata > 0
			nJuros += nProRata
		Else
			nDescont -= nProRata
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se dados bancários estão OK                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !FwIsInCallStack("FA450CMP")
			If MovBcobx(cMotBx, .T.) .and. !CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.)
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
				// dados, senao abandona a baixa.
				If l070Auto .or. ! lF070Auto
					loop
				Else
					lRet := .F.
					Exit
				Endif
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se nao foi alterado o banco quando for tit. em desconto.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( FN022SITCB(SE1->E1_SITUACA)[3] .And.;
			cBanco+cAgencia+cConta!=SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA )
			Help(" ",1,"FINA070BCO")
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If l070Auto .or. ! lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se valor da baixa ‚ maior que o valor m ximo a receber       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If !( lFINA200 .And. lREC2TIT ) .and. !FwIsInCallStack("FA450CMP") // Tratamento do Parâmeto MV_REC2TIT - Geração de RECANT(RA) via RETORNO CNAB.
			If cPaisLoc<>"BRA"     
				nTxMoeda:=Iif(nMoedaBco>0,aTxMoedas[nMoedaBco][2],1)
				nTxMdaOr:=aTxMoedas[SE1->E1_MOEDA][2]
				nValRecL := Round(XMoeda(nValRec,SE1->E1_MOEDA,nMoedaBco,dBaixa,7,,nTxMdaOr),2)
			EndIf
			If !lF070Auto
				IF Str(Iif(cPaisLoc<>"BRA",nValRecL,nValRec),17,2) > Str(Round(xMoeda(SE1->E1_SALDO-nTotAbat + Iif(SE1->E1_JUROS > 0,nMulta,nTotMult),SE1->E1_MOEDA,nMoedaBco,dBaixa,7,nTxMoeda),2)+Round(Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nVA+nMulta-nDescont-nOtrga+nDifCambio+nTolerPg+nAcresc-nDecresc),2),17,2)
					Help(" ",1,"ValorMaior")
					If ( SE1->E1_MOEDA == 1 )
						// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
						// dados, senao abandona a baixa.
						If l070Auto .or. ! lF070Auto
							nIrrf := 0 
							loop
						Else
							lRet := .F.
							Exit
						Endif
					Else
						loop
					EndIf
				EndIf
			EndIf
		EndIf
				
		// Se controla saldo na compensacao do cheque
		// A primeira baixa tem que ter no mínimo o valor dos cheques, pois esses são completamente baixados 
		// pelo sistema.
		If FwIsInCallStack("FA450CMP")
			nValRec:= nValOld
		EndIf
		If lSaldoChq
			If	!(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				// Soma o total recebido em cheque
				nSomaCheq := SomaCheqCr(.F.,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE)
				If nValRec < nSomaCheq
			   		Aviso('STR0219',"Não é possível realizar baixa de valor inferior aos cheques amarrados quando MV_SLDBXCR = 'C'."+;
                    "Nessa configuração, os cheques serão sempre baixados primeiro.",{'STR0221'}) //"Não é possível realizar baixa de valor inferior aos cheques amarrados quando MV_SLDBXCR = 'C'.""Nessa configuração, os cheques serão sempre baixados primeiro."
                    
			   		lRet := .F.
			   		exit		
				EndIf
			EndIf	
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se e baixa parcial, quando e titulo do BIBLIOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If alltrim(Upper(SE1->E1_ORIGEM)) = 'L' .and. lRMBibli        
	        If nValRec < (SE1->E1_VALOR - SE1->E1_DECRESC + E1_ACRESC - nDescont + nMulta + nJuros + nVA )
		   		Aviso('STR0219','STR0220',{'STR0221'}) //"Não é possivel realizar a baixa parcial de um título nativo do RM Biblios"
		   		lRet := .F.
		   		exit
			endif			
        endif
	
	   //Baixa de titulo em moeda forte com a cotacao da moeda igual a zero !!
		If SE1->E1_MOEDA > 1 .and. RECMOEDA(dBaixa,cMoeda) == 0 .and. nTxMoeda == 0 .and. ;
				nValRec == 0 .and. nValEstrang == 0
			Help(" ",1,"TX_MOEDA",, "Nao sera possivel baixar este titulo pois a cotacao da moeda do titulo na data da baixa é igual a zero.",1,0)	//"Nao sera possivel baixar este titulo pois a cotacao da moeda do titulo na data da baixa é igual a zero."
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If l070Auto .or. ! lF070Auto
				loop
			Else
				lRet := .F.			
				Exit
			Endif
		Endif 
		iF FwIsInCallStack("FA450CMP")
			nValRec := nValOld
		Endif
		If nValRec < (nJuros + nVA + nAcresc)                                                               
			nValPadrao := nValRec-(nJuros + nVA+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont-nDecresc)
			If nValRec < nAcresc .and. nValRec <> 0 
				nAcresc		:= nValRec
			Endif		
		Else
			nValPadrao := nValRec-(nJuros + nVA+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont+nAcresc-nDecresc)	
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se saldo estava em outra moeda, caso estiver, converte valor ³
		//³recebido pela taxa diaria da moeda                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpt  := IIF(Str(nValPadrao,14,2)=Str(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda),14,2),1,2)
	Else
		lRet := .F.
		MsUnlock()
		//Se os valores dos impostos de abatimentos foram recalculados e se a baixa
		//do titulo nao for confirmada, restauro os valores calculados pelo sistema
		If lAlterImp
         
			//Guardo os valores "nOld" para retornar apos calculos
			nAntPis   	:= nOldPis    
			nAntCofins	:= nOldCofins
			nAntCsll  	:= nOldCsll
			nAntIrrf  	:= nOldIrrf
			nAntIss	   := nOldIss
			nAntInss  	:= nOldInss	  

			nPisAlter := SE1->E1_PIS
			nCofAlter := SE1->E1_COFINS
			nCslAlter := SE1->E1_CSLL
			nIrfAlter := SE1->E1_IRRF
			nIssAlter := SE1->E1_ISS
			nInsAlter := SE1->E1_INSS

			//Altero os valores somente para a funcao considerar o calculo
			//pois os valores de SE1-> e nOld precisam ser diferentes
			RecLock("SE1")
			If !lPccBxCr
				SE1->E1_PIS    := nOldPis
				SE1->E1_COFINS := nOldCofins
				SE1->E1_CSLL   := nOldCsll
			EndIf
			If !lIrPjBxCr
				SE1->E1_IRRF   := nOldIrrf
			EndIf
			SE1->E1_ISS	 := nOldIss
			SE1->E1_INSS   := nOldInss
			SE1->(MsUnlock())
	      
			nOldPis    := nPisAlter
			nOldCofins := nCofAlter
			nOldCsll   := nCslAlter		
			nOldIrrf	 := nIrfAlter
			nOldIss	 := nIssAlter
			nOldInss	 := nInsAlter		
	
			//Faz a alteração dos valores
			FA040AxAlt(cAlias,lAlterImp)          
                                    
			//Restauro os valores para nao gerar problemas em novos calculos
			nOldPis    := nAntPis
			nOldCofins := nAntCofins
			nOldCsll   := nAntCsll		
			nOldIrrf		:= nAntIrrf
			nOldIss		:= nAntIss
			nOldInss		:= nAntInss

			//Se o valor total for menor que o valor minimo de retenção
			If  !lPccBxCr .and. (aDadosRet[1] + nValRec) <= nVlMinImp
				RecLock("SE1")
				SE1->E1_SABTPIS	+= If(SE1->E1_SABTPIS >= 0 ,nOldPis,0)
				SE1->E1_SABTCOF	+= If(SE1->E1_SABTCOF >= 0 ,nOldCofins,0)
				SE1->E1_SABTCSL	+= If(SE1->E1_SABTCSL >= 0 ,nOldCsll,0)
				SE1->E1_PIS			:= SE1->E1_SABTPIS
				SE1->E1_COFINS		:= SE1->E1_SABTCOF
				SE1->E1_CSLL		:= SE1->E1_SABTCSL
				SE1->(MsUnlock())
			Endif
		EndIf
		Exit
	Endif
	If Empty( cMotBx )
		cMotBx	:= aDescMotBx[1]	//Motivo das baixas
	Endif
	IF nOpc1 == 1 
         
		 If lFA070ACR
		 	nAux := ExecBlock("FA070ACR",.F.,.F.,{nDecrVlr}) 
		 	If Valtype(nAux) == "N"
            	nDecresc := nAux
    		EndIf 
     	 Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se data da baixa e valida                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF (dBaixa < SE1->E1_EMISSAO .OR. dBaixa > dDataBase) .and. !lAntCred
			Help( " ", 1, "DATAERR" )
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If l070Auto .or. ! lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se modalidade do SPB é valida.									    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSpbInUse
			cModSpb := Substr(cModSpb,1,1)
			IF !(SpbTipo("SE1",cModSpb,SE1->E1_TIPO))
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
				// dados, senao abandona a baixa.
				If l070Auto .or. ! lF070Auto
					loop
				Else
					lRet := .F.
					Exit
				Endif
			Endif
		Endif                    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se permite ou nao baixar o titulo com o valor recebido menor ³
		//³que a soma dos valores de juros, multa e desconto                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !F070VldRec()
			If l070Auto .or. !lF070Auto
				loop
			Else
				lRet := .F.			
				Exit
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada de Template para Confirmacao da Baixa       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTFa070Tit
			lRet := ExecTemplate("FA070TIT",.F.,.F.,{nParciais})
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para Confirmacao da Baixa                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFa070Tit
			lRet := ExecBlock("FA070TIT",.F.,.F.,{nParciais})
			If !lRet
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os dados, senao abandona a baixa.
				If l070Auto .or. !lF070Auto
					loop
				Else
					Exit
				Endif
			Endif
		Endif

		If !lRet
			Return lRet
		EndIf

		dbSelectArea("SE1")
		IF Empty(dBaixa) .or. (nValRec < 0 ) .or. Empty(cMotBx)
			Help(" ",1,"FA070INV")
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If l070Auto .or. ! lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		EndIF

		// Aqui neste ponto a variavel nJuros esta somada com o valor de nCM1
		// e da Prorata se esta for positiva, se for negativa
		// a prorata eh somada a nDescont
       
        IF nModulo == 43 //TMS
			If nDescont != Round(nMulta+nJuros + nVA+xMoeda((SE1->E1_SALDO+SE1->E1_ACRESC-SE1->E1_DECRESC),SE1->E1_MOEDA,1,dBaixa,2,nTxMoeda),2)
				If (nTotAbat=0.and.nValRec=0.and.nDescont==0).or.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.;
					 nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					Help(" ",1,"FA070INV")
					// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
					// dados, senao abandona a baixa.
					If l070Auto .or. ! lF070Auto
						loop
					Else
						lRet := .F.
						Exit
					Endif
				EndIf
			EndIF                            
	    Else
			If nDescont != Round(nMulta+nJuros + nVA+xMoeda((SE1->E1_SALDO+SE1->E1_ACRESC-(SE1->E1_DECRESC+nDecrescF+nDecrVlr)),SE1->E1_MOEDA,1,dBaixa,2,nTxMoeda),2) .And.;
				(!(AllTrim(SE1->E1_ORIGEM) $ "S|L|T") .And. AllTrim(cAuxMBx) <> "BOL") 
				If (nTotAbat=0.and.nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					Help(" ",1,"FA070INV")
					// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
					// dados, senao abandona a baixa.
					If l070Auto .or. ! lF070Auto
						loop
					Else
						lRet := .F.
						Exit
					Endif
				Else
					If (nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
						If MsgYESNO( 'STR0247' + chr(10) + chr(13) + ;
							'STR0248', "= Valor Recebido" )
							loop
						Else
							lRet := .F.
							Exit
						Endif
					EndIf
				EndIf
			EndIF
	    EndIf

		If !FA070ValMo()
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If l070Auto .or. ! lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma nos totalizadores, exceto se a situa‡„o do t¡tulo for:     ³
		//³2 - Cobran‡a Descontada   ou   7 - Cobranca Cau‡„o Descontada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !(FN022SITCB(SE1->E1_SITUACA)[3])
			nTotAGer  += nValRec
			nTotADesc += nDescont+nDecresc
			nTotAMul  += nMulta
			nTotAJur  += nJuros + nVA + nAcresc 
			nTotADesp += Iif(SE1->E1_MOEDA<=1,nCM,0)
		Endif 
		// verifica se nao esta utilizando rotina automatica para poder gerar os lanctos contabeis
		cPadrao   := fA070Pad()
		lPadrao   := VerPadrao(cPadrao)

	  	IF l070Auto .or. ! lF070Auto
			// Verifica se esta utilizando multiplas naturezas
			// E chama a rotina para distribuir o valor entre as naturezas
			If MV_MULNATR .and. lMultNat
				MultNatB("SE1",.F.,STR(mv_par07,1),@lOk,@aColsSEV,@lMultNat)
			Endif
		ElseIf __lRatAut
			If MV_MULNATR
				lMultNat := .T.
				MultNatB("SE1",.F.,'1',@lOk,@aColsSEV,@lMultNat,.T.)
			Endif		
		Endif		
       
       	If nModulo == 12  // SIGALOJA Não atualiza saldo do cliente padrão			
			If AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) == AllTrim(SuperGetMv("MV_CLIPAD",,"")) + AllTrim(SuperGetMv("MV_LOJAPAD",,""))
				lBloqSa1 := .F. 
			EndIf
		EndIf
       
       	If lTravaSa1	
			lBloqSa1 := ExecBlock("F070TRAVA",.f.,.f.)
		EndIf 
		  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000004")
		
		If  lOracle .and. Iif(mv_par01==1,.T.,.F.) .and. Iif(MV_PAR04==1,.T.,.F.)
			Private aAltera		:= {}
			Private aHeader		:= {}
			CtbCrTmpBD()
			
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da prote‡„o via TTS                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		Begin Transaction
			If lRMClass .And. SE1->E1_IDLAN != 0
				If FWHasEAI("FINI070A",.T.,,.T.) 
					SetRotInteg('FINI070A')
					aRetMsg := FinI070A()									
					If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
						If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
							MsgAlert("Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:" + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
						Else
							MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título "  + " " + Rtrim(SE1->E1_NUM)+". "+"Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
						EndIf
					ElseIf Valtype(aRetMSg[1]) == "U"
						MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título "  + " " + Rtrim(SE1->E1_NUM) + ". " + "Verifique as configurações da integração  e tente novamente.")//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
					Endif
					SetRotInteg('FINA070')
				Else
					MsgAlert("Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL.")//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
				EndIf							
			EndIf
		
			lJuros  := IIF( mv_par05 == 1, .T., .F. )
			
			Aadd(aHdlPrv,{nHdlPrv,cPadrao,aFlagCTB,cArquivo}) 
			
			If !l070Auto
				If lF070Auto .And. len(aAutoCab) > 0
					nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})	
					If nPos > 0
						nValrec := aAutoCab[nPos,2]
					EndIf				
				EndIf
			EndIf 
			iF FwIsInCallStack("FA450CMP")
				nValRec := nValOld
			Endif
			lSaveState := ALTERA
			
			//-----------------------------------------------------------
			//Valores Acessorios.
			//-----------------------------------------------------------			
			//Se for execauto, primeiro chama as funções de baixa e somente depois chama a função FAtuFKDBx, para atualização da data de baixa do VA na FKD, evitando gravação duplicada de FK6 quando informadas 2 baixas parciais via integração com VA de aplicação única
			If !l070Auto .And. lF070Auto
											
				lBaixou := fA070Grv(lPadrao,Nil,NIl,Nil,lFINA200,dDtCredito,lJuros,Nil,Nil,nTxMoeda,mv_par08==1,aSeqSe5,aHdlPrv,lBloqSa1,lMultNat,, aImpos,__lPccMR,__lIrfMR,__lInsMR,__lIssMR,__lGlosaMr,__lImpMR) //Nil=Arquivo Cnab						
			
				If lPodeTVA .and. lExistVA
					FAtuFKDBx()
				Endif
			
			Else
				
				If lPodeTVA .and. lExistVA
					FAtuFKDBx()
				Endif
				
				lBaixou := fA070Grv(lPadrao,Nil,NIl,Nil,lFINA200,dDtCredito,lJuros,Nil,Nil,nTxMoeda,mv_par08==1,aSeqSe5,aHdlPrv,lBloqSa1,lMultNat,, aImpos,__lPccMR,__lIrfMR,__lInsMR,__lIssMR,__lGlosaMr,__lImpMR) //Nil=Arquivo Cnab
				
			Endif
			
			If lFINA200
				lBAIXCNAB := lBaixou
			EndIf
			ALTERA := lSaveState
			nHdlPrv	:= aHdlPrv[1][1]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			F070PcoDet()
					
			// Se nao for baixa por rotina automatica, chama a rotina de contabilizacao
		  	//-----
		  	//Caso o o executo esteja com a opção de ratear a baixa poderá ser rateada com a replica do rateio da inclusão
		  	IF l070Auto .or. ! lF070Auto
				// Verifica se esta utilizando multiplas naturezas
				If MV_MULNATR .and. lMultNat .and. lOk .And. ( AllTrim(SE1->E1_TIPO) <> "RA" )
					MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,STR(mv_par07,1),,lOk,aColsSEV,lBaixou,aGrvLctPco)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada antes da contabilizacao.			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lF070ACONT
					ExecBlock("F070ACONT",.F.,.F.)
				EndIf
	
				If lBaixou
		  			GravaChqCR(SE5->E5_SEQ,"FINA070",,aSeqSe5,lBaixou,aFormPg) // Grava os cheques no SEF
					
					//Monta o Array para impressao do Recibo
		  			aAdd(aRelTit, {	SE1->E1_NUM				,;	//01-Nro do Titulo
							       	SE1->E1_PREFIXO			,;	//02-Prefixo
							       	SE1->E1_PARCELA			,;	//03-Parcela
							       	SE1->E1_TIPO 			,;	//04-Tipo
							       	SE1->E1_CLIENTE			,;	//05-Cliente
							       	SE1->E1_LOJA			,;	//06-Loja
							       	Dtos(SE1->E1_EMISSAO)	,;	//07-Emissao
							       	Dtos(SE1->E1_VENCTO)	,;	//08-Vencimento
							       	SE1->E1_VLCRUZ			,;	//09-Valor Original
							       	SE1->E1_SALDO			,;	//10-Saldo
							       	SE1->E1_MULTA			,;	//11-Multa
							       	SE1->E1_JUROS			,;	//12-Juros
							       	SE1->E1_DESCONT			,;	//13-Desconto
							       	SE1->E1_VALLIQ			})	//14-Valor Recebido
		  		Endif
		  	ElseIf __lRatAut
					// Verifica se esta utilizando multiplas naturezas
				If MV_MULNATR .and. lOk .And. ( AllTrim(SE1->E1_TIPO) <> "RA" )
					lMultNat := .T.
					MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,'1',,lOk,aColsSEV,lBaixou,aGrvLctPco)
				Endif	  	
			Endif
			
					/*
			Atualiza o status do titulo no SERASA */
			If cPaisLoc == "BRA"
				If SE1->E1_SALDO <= 0
					cChaveTit := xFilial("SE1") + "|" +;
								SE1->E1_PREFIXO + "|" +;
								SE1->E1_NUM		+ "|" +;
								SE1->E1_PARCELA + "|" +;
								SE1->E1_TIPO	+ "|" +;
								SE1->E1_CLIENTE + "|" +;
								SE1->E1_LOJA
					cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
					F770BxRen("1",TrazCodMot(cMotBx),cChaveFK7)
					dbSelectArea("SE1")
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoFinLan("000004")
			
			If ChqMotBx( cMotBx ) // Verifica se Motivo de baixa gera cheque
				If mv_par08 == 1  // Verifica se o Parâmetro "Gera Cheque para Adiantamento" = Sim
					lGerChqAdt := .T.
				Else
					lGerChqAdt := .F.
				EndIf
			Else
				lGerChqAdt := .F.		
			EndIf 
			
			cTipoOr		:= SE1->E1_TIPO
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso seja baixa de adiantamento, dever  ser estornado saldo  ³
			//³ banc rio. Apenas Baixa que gere movimentacao bancaria		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
				If (MovBcoBx(cMotBx, .T.) .And. !lGerChqAdt) .Or. cAuxMBx == "TRF"
					AtuSalBco( cBanco, cAgencia, cConta, dBaixa, nValRec, "-" )
				Endif

				fa070Adiant( lPadrao, lContabiliza, IIF(cMotBx == "CEC", .T.,lGerChqAdt), @aBaixas, dDtCredito , nTxMoeda, lMultNat )

				// Verifica se esta utilizando multiplas naturezas e grava o flag de rateio no SE1
				If MV_MULNATR .and. lMultNat
					MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,STR(mv_par07,1),,lOk,aColsSEV,lBaixou,aGrvLctPco)
					If !Empty(SE5->E5_SEQ) .And. SE1->E1_MULTNAT <> "1"
						RecLock("SE1",.F.)
						SE1->E1_MULTNAT := "1"
						SE1->(MsUnlock())
					Endif
				Endif
				
				If cPaisLoc == "COL"
					If FindFunction("FinProcITF") .And. FinProcITF( SE5->( Recno() ),1 ) .and. cTipoOr=='RA '
						FinProcITF( SE5->( Recno() ), 3, , .F.,, )
					EndIf
				EndIf
			EndIf

			IF lPadrao .and. lContabiliza .and. lBaixou 
				If nHdlPrv <= 0			
					nHdlPrv		:= HeadProva(cLote,"FINA070",Substr(cUsuario,7,6),@cArquivo)
				EndIf

				VALOR			:= SE1->E1_VALLIQ
				ABATIMENTO	:= Round(NoRound(xMoeda(nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)

				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Endif
				nTotal += DetProva( nHdlPrv, cPadrao, "FINA070", cLote, /*nLinha*/, /*lExecuta*/,;
				                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
				                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )

				If lF070CTB
					nTotal += ExecBlock("F070CTB",.F.,.F.,{cPadrao,nHdlPrv})
				Endif
			Endif
			IF lPadrao .and. lContabiliza .and. lBaixou
				//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela 
				//-- sera exibida caso ocorram erros nos lançamentos padronizados
				If lF070Auto
					lSetAuto := _SetAutoMode(.F.)
					lSetHelp := HelpInDark(.F.)
					If Type('lMSHelpAuto') == 'L'
						lMSHelpAuto := !lMSHelpAuto
					EndIf						
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localizacao Portugal - Gera dados para diario contabil ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If UsaSeqCor() 
					AAdd( aDiario, {"SE5",SE5->(Recno()),cCodDiario,"E5_NODIA","E5_DIACTB"} )
				Else
					aDiario := {} 
				EndIf      
				
				RodaProva(nHdlPrv,nTotal)                               

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lan‡amento Cont bil                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, Iif(mv_par01==1,.T.,.F.) /*lDigita*/,;
				           Iif(mv_par02==1,.T.,.F.) /*lAglut*/,;
				           /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
				
				If lF070Auto
					HelpInDark(lSetHelp)
					_SetAutoMode(lSetAuto)
					If Type('lMSHelpAuto') == 'L'
						lMSHelpAuto := !lMSHelpAuto
					EndIf
				EndIf					
			EndIf          
		   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trecho incluido para integração e-commerce          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBaixou 
				If  LJ861EC01(SE1->E1_NUM, SE1->E1_PREFIXO, .T./*PrecisaTerPedido*/, SE1->E1_FILORIG)
					LJ861EC02(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_FILORIG)
				EndIf		
			EndIf

			// Integração SIGAPFS x SIGAFIN
			If lBaixou .And. FindFunction("JGrvBaixa")
				lRet := JGrvBaixa(SE1->(Recno()), SE5->(Recno()))

				If !lRet
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Final  da prote‡„o via TTS                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lFini055 .and. FWHasEAI("FINA070",.T.,,.T.) .and. SE1->E1_PREFIXO <> cPrefRM
				cIntegSeq := SE5->E5_SEQ//utilizada na integdef. Nao transformar em local.
				aRetInteg := FwIntegDef( 'FINA070' )
				//Se der erro no envio da integração, então faz rollback e apresenta mensagem em tela para o usuário
				If ValType(aRetInteg) == "A" .AND. Len(aRetInteg) >= 2 .AND. !aRetInteg[1]
					If ! IsBlind()
						Help( ,, "FINA070INTEG",, "Ocorreu um erro inesperado na tentativa de atualização do título "  + ": " + "Verifique se a integração está configurada corretamente."  + " - " + AllTrim( aRetInteg[2] ), 1, 0,,,,,, {"Verifique as configurações da integração  e tente novamente."} ) //"Ocorreu um erro inesperado na tentativa de atualização do título: Baixa de Títulos ", "Verifique se a integração está configurada corretamente."  						
					Endif
					DisarmTransaction()
					Return .F.
				Endif  
			Endif
			
			If !("FINA630" $ FunName())
				///numbor			
				aAlt := {}
			    aadd( aAlt,{ 'STR0259','','','','STR0260' +  Alltrim(Transform(SE5->E5_VALOR,PesqPict("SE5","E5_VALOR"))) })   
				///chamada da Função que cria o Histórico de Cobrança
				DbSelectArea("SE1")
				FinaCONC(aAlt)
			endif
			
		End Transaction
		
		If !lF070Auto .And. AllTrim(SE1->E1_ORIGEM)=="FINI055"
			If FWHasEAI("FINI070A",.T.,,.T.) 
				SetRotInteg('FINI070A')
				MsgRun ( "Atualizando título"+" "+rTrim(SE1->E1_NUM)+ " " +"a valor presente...",'Valor Presente',{||aRetMsg:=FinI070A()} )//"Atualizando título" "a valor presente..." Valor Presente									
				If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
					If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
						MsgAlert("Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:" + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
					Else
						MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título ." + " " + Rtrim(SE1->E1_NUM)+". "+'Verifique as configurações da integração  e tente novamente."')//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
					EndIf
				ElseIf Valtype(aRetMSg[1]) == "U"
					MsgAlert("Ocorreu um erro inesperado na tentativa de atualização do título ." + " " + Rtrim(SE1->E1_NUM) + ". " + 'Verifique as configurações da integração  e tente novamente.')//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
				Endif
				SetRotInteg('FINA070')
			Else
				MsgAlert("Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL.")//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
			EndIf	
		Endif
			
		IF (SE1->E1_SITUACA != "2" .And. SE1->E1_SITUACA != "7") ;
			.And. MovBcoBx(cMotBx, .T.) .and. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .and. Empty( cLoteFin )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Saldo Banc rio 											        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc<>"BRA"
				AtuSalBco(cBanco,cAgencia,cConta,dDtCredito,xMoeda(nValRec-nSomaCheq,SE1->E1_MOEDA,nMoedaBco,,,nTxMoeda),"+")
			Else
				AtuSalBco(cBanco,cAgencia,cConta,dDtCredito,Iif( lPccBxCr .And. nValRec - ( nPis + nCofins + nCsll ) == nOldValRec , nOldValRec , nValRec ) - nSomaCheq , "+" )
			Endif
		EndIf

		//..... 
		//    Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
		//    MV_SIGAGSP - 0-Nao / 1-Integra                               ³                
		//    Gera os Lancamentos de Orcamentos
		//    ........
		If GetNewPar("MV_SIGAGSP","0") == "1" 
			GSPF210()
		EndIf

		//Ponto de entrada do Template.
		If ExistTemplate("SACI008")
			ExecTemplate("SACI008",.F.,.F.)
		EndIf

		If lSACI008
			ExecBlock("SACI008",.F.,.F.)
		EndIf 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Integracao protheus X tin	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		
	EndIF

	If lF070Bxpc .And. ( SE1->E1_SALDO > 0 )
	   	ExecBlock( "F070BXPC", .F., .F. )         
	Else
		Exit
	EndIf	
End     

If "CX" $ cBanco
	aCaixaFin[1] := cBanco
	aCaixaFin[2] := cAgencia
	aCaixaFin[3] := cConta
Endif

If cAlias != NIL
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoTo( nReg )
EndIf

RestArea (aArea)

If nOpc1 == 0
	aCols := aSize(aCols, 0)
EndIf

If FunName() == "FINA740"
	cPorta740 := cPortado	
	cBanco740 := cBanco 		
	cAgenc740 := cAgencia	
	cConta740 := cConta		 
Endif

If ValType( aVlOringl ) == "A"
	aSize( aVlOringl , 0 )
	aVlOringl := Nil
EndIf

//Faz a impressao do Recibo
If lImpLjRe .And. lBaixou .And. (lLojrRec .Or. lULOJRREC) 
	aAreaSe1 := SE1->(GetArea())
	aAreaSe5 := SE5->(GetArea())
	aAreaRec := GetArea()

	//Passo os parametros do SE5 para futura reimpressão do recibo deverá pegar as informações do E5, pois a baixa pode ser
	//parcial, o numero do recibo será Numero+Cliente+Loja+E5_SEQ. Desenvolver a reimpressão usando estas informações na query
	If lULOJRREC
		//Fonte não será mais padrao mas sim um RDMake padrão.
		U_LOJRRecibo(	""				, ""				, aRelTit			, aFormPg				,;
						Nil				, SE5->E5_HISTOR	, SE5->E5_SEQ		, DTOC(SE5->E5_DATA)	,;
						SE5->E5_TIPODOC	, SE5->E5_MOTBX		, SE5->E5_NUMERO	, SE5->E5_PARCELA		,;
						SE5->E5_CLIFOR	, SE5->E5_LOJA 		)
	Else
		LOJRREC(	""				, ""				, aRelTit			, aFormPg				,;
					Nil				, SE5->E5_HISTOR	, SE5->E5_SEQ		, DTOC(SE5->E5_DATA)	,;
					SE5->E5_TIPODOC	, SE5->E5_MOTBX		, SE5->E5_NUMERO	, SE5->E5_PARCELA		,;
					SE5->E5_CLIFOR	, SE5->E5_LOJA 		)
	EndIf
	RestArea(aAreaSe1)
	RestArea(aAreaSe5)
	RestArea(aAreaRec)
Endif

Return lRet
