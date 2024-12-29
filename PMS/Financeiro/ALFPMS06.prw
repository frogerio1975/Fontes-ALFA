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

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS06
Envio de Lembre de Vencimento aos Clientes.

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS06()

Local aAreaAtu  := GetArea()
Local aBoxParam := {}

Local aFaturas  := {}
Local cBanco    := GetMV("MV_XBANCO",.F.,"")
Local cAgencia  := GetMV("MV_XAGENCI",.F.,"")
Local cConta    := GetMV("MV_XCONTA",.F.,"")
Local cFavorec  := GetMV("MV_XFAVORE",.F.,"")
Local cCNPJ     := GetMV("MV_XCNPJFA",.F.,"")
Local cOpcao    := GetMV("MV_XOPWFFI",.F.,"")
Local cEmailTST := GetMV("MV_XEMATST",.F.,"")
Local cCopia    := GetMV("AL_XCOPFAT",.F.,"")
Local cTitulo   := GetMV("MV_XTITEMA",.F.,"")
Local nQtdPos   := GetMV("MV_XDAPOS",.F.,0)
Local nQtdAntes := GetMV("MV_XDANTES",.F.,0)
Local cServer   := GetMV("AL_MAILSRV",.F.,"email-ssl.com.br")
Local cUser     := GetMV("AL_MAILUSR",.F.,"adm@alfaerp.com.br")
Local cPass     := GetMV("AL_MAILPSW",.F.,"240820@Alfa")
Local nPorta    := GetMV("AL_MAILPOR",.F.,587)
// Local lUseAuth 	:= GetMV("AL_MAILAUT",.F.,.T.) 
// Local lTLS	    := GetMV("AL_MAILTLS",.F.,.F.)
// Local lSSL   	:= GetMV("AL_MAILSSL",.F.,.F.) 
// Local nTimeOut 	:= GetMV("AL_MAILTIM",.F.,30)
Local cMsgLog   := ""

Private lMark   := .F.
Private aEmpFat  := { "1=SYMM", "2=ERP", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
Private cEmpFat  := "1"
Private aRetParam := {}

Private dVencIni := CriaVar("E2_VENCREA",.F.)
Private dVencFim := CriaVar("E2_VENCREA",.F.)

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
AADD( aBoxParam, {1,"Banco"                         ,PadR(cBanco,50)    ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Agencia"                       ,PadR(cAgencia,50)  ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Conta"                         ,PadR(cConta,50)    ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Favorecido"                    ,PadR(cFavorec,70)  ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"CNPJ"                          ,PadR(cCNPJ,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {2,"Opcao"                         ,cOpcao             ,{"1=Ativo","2=Homologacao","3=Inativo"},60,,.F.} )
AADD( aBoxParam, {1,"E-mail"                        ,PadR(cEmailTST,50) ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Copia Para"                    ,PadR(cCopia,50)    ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Título e-mail"                 ,PadR(cTitulo,50)   ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Qtd. dias após vencimento"     ,nQtdPos            ,"@R 999","","","",100,.F.} )
AADD( aBoxParam, {1,"Qtd. dias antes vencimento"    ,nQtdAntes          ,"@R 999","","","",100,.F.} )
AADD( aBoxParam, {1,"Servidor SMTP"                 ,PadR(cServer,50)   ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Usuario E-mail"                ,PadR(cUser,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Senha E-mail"                  ,PadR(cPass,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Porta SMTP"                    ,nPorta             ,"@R 999","","","",50,.F.} )

AADD( aBoxParam, {1,"Vencto. DE"      , dVencIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Vencto. ATE"     , dVencFim  , "@!", "", ""   , "", 50, .F.} )

// AADD( aBoxParam, {4,"Autentica"                     ,lUseAuth           ,"",50,"",.F.} )
// AADD( aBoxParam, {4,"TLS"                           ,lTLS               ,"",50,"",.F.} )
// AADD( aBoxParam, {4,"SSL"                           ,lSSL               ,"",50,"",.F.} )
// AADD( aBoxParam, {1,"TimeOut"                       ,nTimeOut           ,"@R 999","","","",50,.F.} )

If ParamBox(aBoxParam,"Parâmetros WorkFlow Financeiro.",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]

    PutMV("MV_XBANCO"  , aRetParam[02])
    PutMV("MV_XAGENCI" , aRetParam[03])
    PutMV("MV_XCONTA"  , aRetParam[04])
    PutMV("MV_XFAVORE" , aRetParam[05])
    PutMV("MV_XCNPJFA" , aRetParam[06])
    PutMV("MV_XOPWFFI" , aRetParam[07])
    PutMV("MV_XEMATST" , aRetParam[08])
    PutMV("AL_XCOPFAT" , aRetParam[09])
    PutMV("MV_XTITEMA" , aRetParam[10])
    PutMV("MV_XDAPOS"  , aRetParam[11])
    PutMV("MV_XDANTES" , aRetParam[12])
    PutMV("AL_MAILSRV" , aRetParam[13])
    PutMV("AL_MAILUSR" , aRetParam[14])
    PutMV("AL_MAILPSW" , aRetParam[15])
    PutMV("AL_MAILPOR" , aRetParam[16])
    // PutMV("AL_MAILAUT" , aRetParam[15])
    // PutMV("AL_MAILTLS" , aRetParam[16])
    // PutMV("AL_MAILSSL" , aRetParam[17])
    // PutMV("AL_MAILTIM" , aRetParam[18])

    dVencIni := aRetParam[17]
    dVencFim := aRetParam[18]

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
Local nQtdApos  := GetMV("MV_XDAPOS")//GetNewPar("MV_XDAPOS",03)
Local nQtdAntes := GetMV("MV_XDANTES")//GetNewPar("MV_XDANTES",05)

aFaturas := {}

cQuery := " SELECT "+ CRLF
cQuery += " 	SE1.R_E_C_N_O_ AS RECSE1 "+ CRLF
cQuery += " 	,SA1.R_E_C_N_O_ AS RECSA1 "+ CRLF
cQuery += " 	,DATEDIFF(DAY,GETDATE(),E1_VENCTO) AS DIAS "+ CRLF

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
cQuery += " 	AND DATEDIFF(DAY,GETDATE(),E1_XDTENVI) <> 0 "+ CRLF
/*
//cQuery += "     AND DATEDIFF(DAY,GETDATE(),E1_VENCTO) BETWEEN "+cValToChar(-1*nQtdApos)+" AND "+cValToChar(nQtdAntes)+""+CRLF
cQuery += " 	AND ( "+ CRLF
cQuery += " 		DATEDIFF(DAY,GETDATE(),E1_VENCTO) = "+cValToChar(nQtdAntes)+" "+ CRLF // Lembrete dias antes do vencimento
cQuery += " 		OR DATEDIFF(DAY,GETDATE(),E1_VENCTO) = 0 "+ CRLF // Lembrete no dia do vencimento
//cQuery += " 		OR DATEDIFF(DAY,GETDATE(),E1_VENCTO) = "+cValToChar(-1*nQtdApos)+" "+ CRLF // Lembrete dias apos o vencimento
cQuery += " 		OR DATEDIFF(DAY,GETDATE(),E1_VENCTO) < "+cValToChar(-1*nQtdApos)+" "+ CRLF // Lembrete dias apos o vencimento
cQuery += " 	) "+ CRLF
*/

    /*
cQuery += " 	    AND ( "+CRLF
cQuery += " 	        DATEDIFF(DAY, GETDATE(), TRY_CAST(SE1.E1_VENCTO AS DATE)) = "+cValToChar(nQtdAntes)+" "+CRLF
cQuery += " 	        OR DATEDIFF(DAY, GETDATE(), TRY_CAST(SE1.E1_VENCTO AS DATE)) = 0 "+CRLF
cQuery += " 	        OR DATEDIFF(DAY, GETDATE(), TRY_CAST(SE1.E1_VENCTO AS DATE)) < "+cValToChar(-1*nQtdApos)+" "+CRLF
cQuery += " 	    ) "+CRLF
    */

cQuery += "     AND SE1.E1_VENCTO BETWEEN '"+DTOS(dVencIni)+"' AND '"+DTOS(dVencFim)+"'  "+ CRLF

cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE1.E1_VENCTO "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery) 
MemoWrite('C:\Propostas\ALFPMS06.txt',cQuery)
While (cTMP1)->(!EOF())

	AADD( aFaturas, Array(PS_RECSA1) )
	nPos := Len(aFaturas)
    
    SE1->(DbSetOrder(1))
    SE1->(DbGoTo((cTMP1)->RECSE1))

    SA1->(DbSetOrder(1))
    SA1->(DbGoTo((cTMP1)->RECSA1))

    aFaturas[nPos][PS_MARKFT] := "LBOK"
    aFaturas[nPos][PS_STATUS] := "1"
    aFaturas[nPos][PS_DESCRI] := "Envio Pendente"
    aFaturas[nPos][PS_NUMTIT] := SE1->E1_NUM
    aFaturas[nPos][PS_DTVENC] := DToC(SE1->E1_VENCTO)
    aFaturas[nPos][PS_VLRTIT] := SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
    aFaturas[nPos][PS_NUMNFE] := SE1->E1_XNUMNFS
    aFaturas[nPos][PS_CODCLI] := SA1->A1_COD
    aFaturas[nPos][PS_LOJCLI] := SA1->A1_LOJA
    aFaturas[nPos][PS_NOMCLI] := SA1->A1_NOME
    aFaturas[nPos][PS_MAILCL] := SA1->A1_EMAILNF
    aFaturas[nPos][PS_MSGENV] := ""
    aFaturas[nPos][PS_DIASVE] := (cTMP1)->DIAS
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

    @ 005,400  BUTTON "Enviar" SIZE 060,020 FONT oFont18N PIXEL ACTION {|| FwMsgRun( ,{|| EnvFaturas(@aFaturas), oBrowse:Refresh() }, , "Por favor, aguarde. Enviando E-mails..." ) } OF oPanelAux
    @ 005,480  BUTTON "Sair"   SIZE 060,020 FONT oFont18N PIXEL ACTION {|| oDlg:End() } OF oPanelAux

    oPanelFat := TPanel():New(0,0,"",oPanelAux,NIL,.F.,.F.,NIL,NIL,0,000,.F.,.F.)
	oPanelFat:Align := CONTROL_ALIGN_ALLCLIENT
				
	DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aFaturas /*LINE HEIGHT nLineHeight*/ OF oPanelFat
		
		ADD MARKCOLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_MARKFT] } DOUBLECLICK {|| MarkReg(oBrowse, @aFaturas) } HEADERCLICK {|| MarkAll(oBrowse, @aFaturas) } OF oBrowse
		
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "1" } COLOR "WHITE" TITLE "Envio Pendente" 	        OF oBrowse
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "2" } COLOR "GREEN" TITLE "Enviado Com Sucesso"     OF oBrowse
		ADD LEGEND DATA {|| aFaturas[oBrowse:nAt][PS_STATUS] == "3" } COLOR "BLACK" TITLE "Erro no Envio"           OF oBrowse
		
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_DESCRI] } TITLE "Status" 			SIZE 20 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NUMTIT] } TITLE "Título" 			SIZE 09 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_DTVENC] } TITLE "Vencimento"		SIZE 10	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NUMNFE] } TITLE "NFS"   			SIZE 09	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_VLRTIT] } TITLE "Valor"     		SIZE 12	PICTURE "@E 999,999,999.99" ALIGN CONTROL_ALIGN_RIGHT OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_CODCLI] } TITLE "Cliente" 			SIZE 06	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
		ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_LOJCLI] } TITLE "Loja" 			SIZE 02 ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_NOMCLI] } TITLE "Razão Social" 	SIZE 30	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
        ADD COLUMN oColumn DATA {|| aFaturas[oBrowse:nAt][PS_MAILCL] } TITLE "E-mail Cliente" 	SIZE 30	ALIGN CONTROL_ALIGN_LEFT  OF oBrowse
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
        MsgInfo("Fatura já enviada ao cliente.")
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

For nX := 1 To Len(aFaturas)

    cMsgErro := ""

	If aFaturas[nX][PS_MARKFT] == "LBOK"

        If WFinancei(aFaturas[nX], @cMsgErro)
            aFaturas[nX][PS_MARKFT] := "LBNO"
            aFaturas[nX][PS_STATUS] := "2"
            aFaturas[nX][PS_DESCRI] := "Enviado Com Sucesso"
            aFaturas[nX][PS_MSGENV] := ""
        Else
            aFaturas[nX][PS_MARKFT] := "LBOK"
            aFaturas[nX][PS_STATUS] := "3"
            aFaturas[nX][PS_DESCRI] := "Erro no Envio"
            aFaturas[nX][PS_MSGENV] := cMsgErro
        EndIf
	EndIf
Next nX

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
Local cBanco    := GetMv("MV_XBANCO")//GetNewPar("MV_XBANCO","")
Local cAgencia  := GetMv("MV_XAGENCI")//GetNewPar("MV_XAGENCI","")
Local cConta    := GetMv("MV_XCONTA")//GetNewPar("MV_XCONTA","")
Local cFavorec  := GetMv("MV_XFAVORE")//GetNewPar("MV_XFAVORE","")
Local cCNPJ     := GetMv("MV_XCNPJFA")//GetNewPar("MV_XCNPJFA","")
Local cOpcao    := GetMv("MV_XOPWFFI")//GetNewPar("MV_XOPWFFI","")
Local cEmailTST := GetMv("MV_XEMATST")//GetNewPar("MV_XEMATST","")
Local cTit      := GetMv("MV_XTITEMA")//GetNewPar("MV_XTITEMA","Lembrete Fatura Financeiro")
Local cMailTo   := ""
Local cBody	    := ""
Local cHTMLSrc  := "samples/wf/FINA740_mail001.html"
Local cHTMLDst  := "samples/wf/FINA740_MTmp001.htm" //Destino deve ser .htm pois o metodo :SaveFile salva somente neste formato.
Local oHTMLBody := Nil
Local lRetorno  := .T.
Local cMsgLog   := ""
Local cEmpTxt   := 'ALFA SISTEMAS DE GEST&Atilde;O LTDA'
SE1->(DbGoTo(aFatura[PS_RECSE1]))
IF SE1->E1_EMPFAT == '2' // MOOVE
    cHTMLSrc  := "samples/wf/FINA740_MOOVE.html"
    cEmpTxt   :='MOOVE CONSULTORIA LTDA'
END
    //aFaturas[nPos][PS_RECSE1] := (cTMP1)->RECSE1
    //aFaturas[nPos][PS_RECSA1] := (cTMP1)->RECSA1

If AllTrim(cOpcao) == "3"
    cMsgErro := 'Rotina de WorkFlow Financeira esta desativada!Parametro WFinancei = 3'
    lRetorno := .F.
EndIf

If lRetorno
    If File(cHTMLSrc)
        oHTMLBody:= TWFHTML():New(cHTMLSrc)
    Else
        cMsgErro := 'Falha ao localizar o arquivo HTML na pasta samples/WF!'
        lRetorno := .F.
    EndIf
EndIf

If lRetorno
        
    If cOpcao == "2" //Modo homologação, pego o email que está no parâmetro
        cMailTo := cEmailTST
    Else //Modo Produção, envio para o cliente a fatura
        cMailTo := aFatura[PS_MAILCL]
    EndIf

    //Ajuste do HTML para receber os valores dos campos
    oHTMLBody:ValByName('cTexto'	, If( aFatura[PS_DIASVE] < 0, "Fatura Vencida","Fatura em Aberto") )
    
    xTexto := ''
    If aFatura[PS_DIASVE] < 0        
        xTexto+='<h2><p>Prezado Cliente,</p>'+CRLF
        xTexto+='<p>N&atilde;o identificamos o recebimento do valor abaixo:</p>'+CRLF
        xTexto+='<p>Por favor, realizar o pagamento em 24 horas.</p>'+CRLF
        xTexto+='<p>Esta &eacute; uma mensagem autom&aacute;tica enviada pela '+cEmpTxt+'.</p>'+CRLF
        xTexto+='<p>Caso j&aacute; tenha realizado o pagamento, por favor enviar comprovante por e-mail.</p>'+CRLF
        xTexto+='<br></h2> '+CRLF
    Else
        xTexto+='<h2 style="text-align=center; font:normal normal normal 14px open sans, sans-serif;"><b>Esta &eacute; uma mensagem autom&aacute;tica enviada pela '+cEmpTxt+'.' 
        xTexto+='<h5>Caso j&aacute; tenha realizado o pagamento, por favor desconsidere esta mensagem.</h5></b><h2>'
    End
    oHTMLBody:ValByName('cTexto2'	, xTexto )


    oHTMLBody:ValByName('nValor'	, "R$ " + AllTrim(Transform(aFatura[PS_VLRTIT],"@E 999,999,999.99"))  )
    oHTMLBody:ValByName('cDtVenc'	, aFatura[PS_DTVENC] )
    oHTMLBody:ValByName('cNF'	    , aFatura[PS_NUMNFE])
    oHTMLBody:ValByName('cBanco'	, cBanco   )
    oHTMLBody:ValByName('cAgencia'  , cAgencia )
    oHTMLBody:ValByName('cConta'    , cConta   ) 
    oHTMLBody:ValByName('cFavore'	, cFavorec )
    oHTMLBody:ValByName('cCNPJ'	    , cCNPJ    )
    oHTMLBody:ValByName('cLinkNF'   , aFatura[PS_LINKNF] )
    oHTMLBody:ValByName('cRefere'   , aFatura[PS_HISTOR] )
    
    oHTMLBody:SaveFile(cHTMLDst)

    cBody := MtHTML2Str(cHTMLDst)

    FErase(cHTMLDst)

    If Empty(cMailTo)
        cMsgErro := 'Email do destinatario em branco'
    EndIf

    If Empty(cBody)
        cMsgErro := "Necessario a utilizacao do arquivo FINA740_mail001.html na pasta protheus_data/samples/wf para o envio de e-mail"
    EndIf

    cMsgLog := ""
    SE1->(DbGoTo(aFatura[PS_RECSE1]))
    If EnvMail(cMailTo, "", cTit, cBody, @cMsgLog)
        SE1->(DbGoTo(aFatura[PS_RECSE1]))
        RecLock("SE1",.F.)
            REPLACE SE1->E1_XDTENVI WITH DATE()
        MsUnlock()
        
        lRetorno := .T.
    Else
        cMsgErro := 'Problema para enviar o email de faturamento para o cliente: ' + AllTrim(cMsgLog)
        lRetorno := .F.
    EndIf
EndIf

RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvMail
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvMail(cMailTo, cMailCC, cAssunto, cMsg, cMsgLog)

Local lRet        := .T.
Local cSMTPServer := GetNewPar("AL_MAILSRV","email-ssl.com.br")
Local cSMTPUser   := GetNewPar("AL_MAILUSR","adm@alfaerp.com.br")
Local cSMTPPass   := GetNewPar("AL_MAILPSW","240820@Alfa")
Local nPorta      := GetNewPar("AL_MAILPOR",587)
Local lUseAuth 	  := GetNewPar("AL_MAILAUT",.T.) 
Local lTLS	      := GetNewPar("AL_MAILTLS",.F.)
Local lSSL   	  := GetNewPar("AL_MAILSSL",.F.) 
Local nTimeOut 	  := GetNewPar("AL_MAILTIM",30)
Local cCopia      := GetNewPar("AL_XCOPFAT","")
Local oMail
Local oMessage
Local nErro
Local nI
Local cBolPath := ''
DEFAULT cMsg := "<hr>Envio de e-mail via Protheus<hr>"

lret:= u_ALEnviaBoletos(@cBolPath)

cMailTo:= StrTran(cMailTo,'adm@alfaerp.com.br','contasareceber@alfaerp.com.br')
If !'contasareceber@alfaerp.com.br' $ cMailTo
    cMailTo:= alltrim(cMailTo)+';contasareceber@alfaerp.com.br'
End

If Empty(cMailCC)
    cMailCC := cCopia
EndIf

oMail := TMailManager():New()

If lTLS
    oMail:SetUseTLS(.T.)
ElseIf lSSL
    oMail:SetUseSSL(.T.)
EndIf

nErro := oMail:Init("",cSMTPServer,cSMTPUser,cSMTPPass,,nPorta)

oMail:SetSmtpTimeOut( nTimeOut )

nErro := oMail:SmtpConnect()

If lUseAuth
	nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
	
	If nErro <> 0		
		// Recupera erro ...
		cMsgLog := oMail:GetErrorString(nErro)
		cMsgLog := "Erro de Autenticacao "+str(nErro,4)+' ('+cMsgLog+')'
        
		lRet := .F.
	EndIf
	
EndIf

If nErro <> 0
	// Recupera erro
	cMsgLog := oMail:GetErrorString(nErro)
	cMsgLog := "Erro de Conexão SMTP "+str(nErro,4)+' ('+cMsgLog+')'

	oMail:SMTPDisconnect()

	lRet := .F.
EndIf

If lRet	
	oMessage := TMailMessage():New()
	oMessage:Clear()
    
	oMessage:cFrom 	  := cSMTPUser
	oMessage:cTo	  := cMailTo
	oMessage:cCc 	  := cMailCC
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := cMsg
	if !empty(cBolPath)
        oMessage:AttachFile( cBolPath )    
    end
	nErro := oMessage:Send( oMail )
	
	If nErro <> 0
		cMsgLog := oMail:GetErrorString(nErro)
	    cMsgLog := "Erro de Envio SMTP "+str(nErro,4)+" ("+cMsgLog+")"
		Conout(cMsgLog)
		lRet := .F.
	EndIf
	
	oMail:SMTPDisconnect()
EndIf	

Return lRet
