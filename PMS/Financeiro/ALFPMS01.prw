#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS01
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS01(cEmpTrab, cFilTrab, cIntervalo, cDia)

Local nIntervalo  := 0
Local nStep		  := 0
Local nCount 	  := 0

Private cDirImp	:= "\DEBUG\"
Private cARQLOG	:= cDirImp+"ALFPMS01_"+cEmpTrab+"_"+cFilTrab+".LOG"

DEFAULT cIntervalo:= "3600000" // 60000 milisegundos = 1 minuto
DEFAULT cDia	  := "2,3,4,5,6,7" // 1==Domingo

nIntervalo := Val(cIntervalo)

// Comando para nao consumir licencas. 
RpcSetType(3)     

// Inicializa ambiente.
PREPARE ENVIRONMENT EMPRESA cEmpTrab FILIAL cFilTrab MODULO "FRT" FUNNAME "SIGAFRT"

FwMakeDir(cDirImp) // Cria diretorio de DEBUG caso nao exista
	
If cValToChar(DOW(DATE())) $ cDia
	Conout("")
	Conout(Replicate('-',80))
	Conout("INICIADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	
	LjWriteLog( cARQLOG, Replicate('-',80) )
	LjWriteLog( cARQLOG, "INICIADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
	
	// Chamada da rotina de processamento.
	WFinancei(.T.,'1')
	WFinancei(.T.,'2')

	Conout("FINALIZADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	Conout(Replicate('-',80)) 
	Conout("")       
	
	LjWriteLog( cARQLOG, "FINALIZADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
	LjWriteLog( cARQLOG, Replicate('-',80) )
EndIf

nStep  := 1
nCount := nIntervalo/1000
While !KillApp() .AND. nStep <= nCount
	Sleep(1000) //Sleep de 1 segundo
	nStep++
EndDo
 
// Finaliza ambiente.
RESET ENVIRONMENT   

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS01
Rotina manual workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function PMS01MAN()

Local aBoxParam  := {}
Local aRetParam  := {}

Private cDirImp	:= "\DEBUG\"
Private cARQLOG	:= cDirImp+"ALFPMS01_"+cEmpAnt+"_"+cFilAnt+".LOG"

FwMakeDir(cDirImp) // Cria diretorio de DEBUG caso nao exista

If !MSGYESNO("Este processo pode levar algumas horas. Depois de iniciado não poderá ser interrompido. Deseja Prosseguir?","Aviso")
	Return .F.
EndIf

Conout("")
Conout(Replicate('-',80))
Conout("INICIADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time())

LjWriteLog( cARQLOG, Replicate('-',80) )
LjWriteLog( cARQLOG, "INICIADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )

// Chamada da rotina de processamento.
PROCESSA( {|lEnd| WFinancei(.F.) }, "Aguarde, carregando dados..." )

Conout("FINALIZADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time())
Conout(Replicate('-',80)) 
Conout("")       

LjWriteLog( cARQLOG, "FINALIZADO ROTINA DE LEMBRETE DE FATURA: ALFPMS01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
LjWriteLog( cARQLOG, Replicate('-',80) )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WFinancei
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WFinancei(lJob,cEmpFat)

Local aAreaAtu  := GetArea()
Local cBanco    := GetNewPar("MV_XBANCO","")
Local cAgencia  := GetNewPar("MV_XAGENCI","")
Local cConta    := GetNewPar("MV_XCONTA","")
Local cFavorec  := GetNewPar("MV_XFAVORE","")
Local cCNPJ     := GetNewPar("MV_XCNPJFA","")
Local cOpcao    := GetNewPar("MV_XOPWFFI","")
Local cEmailTST := GetNewPar("MV_XEMATST","")
Local cTit      := GetNewPar("MV_XTITEMA","Lembrete Fatura Financeiro")
Local nQtdApos  := GetNewPar("MV_XDAPOS",03)
Local nQtdAntes := GetNewPar("MV_XDANTES",05)
Local cMailTo   := ""
Local cBody	    := ""
Local cTMP1     := ""
Local cQuery    := ""
Local cHTMLSrc  := "samples/wf/FINA740_mail001.html"
Local cHTMLDst  := "samples/wf/FINA740_MTmp001.htm" //Destino deve ser .htm pois o metodo :SaveFile salva somente neste formato.
Local oHTMLBody := Nil
Local lRet	    := .T.
Local cMsgLog   := ""
Local nValor    := 0

IF cEmpFat == '2' // MOOVE
    cHTMLSrc  := "samples/wf/FINA740_MOOVE.html"
END

If AllTrim(cOpcao) == "3"
    Conout('Rotina de WorkFlow Financeira esta desativada!Parametro WFinancei = 3')
    LjWriteLog( cARQLOG, 'Rotina de WorkFlow Financeira esta desativada!Parametro WFinancei = 3' )
    Return .F.
EndIf

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

cQuery += "     AND E1_EMPFAT = '"+cEmpFat+"' "+ CRLF

cQuery += " 	AND DATEDIFF(DAY,GETDATE(),E1_XDTENVI) <> 0 "+ CRLF
cQuery += " 	AND ( "+ CRLF
cQuery += " 		DATEDIFF(DAY,GETDATE(),E1_VENCTO) = "+cValToChar(nQtdAntes)+" "+ CRLF // Lembrete dias antes do vencimento
cQuery += " 		OR DATEDIFF(DAY,GETDATE(),E1_VENCTO) = 0 "+ CRLF // Lembrete no dia do vencimento
cQuery += " 		OR DATEDIFF(DAY,GETDATE(),E1_VENCTO) = "+cValToChar(-1*nQtdApos)+" "+ CRLF // Lembrete dias apos o vencimento
cQuery += " 	) "+ CRLF
cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ORDER BY "+ CRLF
cQuery += " 	SE1.E1_VENCTO "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery) 

If (cTMP1)->(EOF())
    Conout('WFinancei - Nao existe faturas a serem enviadas!')
    LjWriteLog( cARQLOG, 'WFinancei - Nao existe faturas a serem enviadas!' )
    lRet := .F.
EndIf

If lRet
    If File(cHTMLSrc)
        oHTMLBody:= TWFHTML():New(cHTMLSrc)
    Else
        Conout('Falha ao localizar o arquivo HTML na pasta samples/WF!')
        LjWriteLog( cARQLOG, 'Falha ao localizar o arquivo HTML na pasta samples/WF!' )
        lRet := .F.
    EndIf
EndIf

If lRet
    While (cTMP1)->(!EOF())

        SE1->(DbSetOrder(1))
        SE1->(DbGoTo((cTMP1)->RECSE1))

        SA1->(DbSetOrder(1))
        SA1->(DbGoTo((cTMP1)->RECSA1))
            
        If cOpcao == "2" //Modo homologação, pego o email que está no parâmetro
            cMailTo := cEmailTST
        Else //Modo Produção, envio para o cliente a fatura
            cMailTo := SA1->A1_EMAILNF // SA1->A1_EMAIL
        EndIf

        nValor := SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

        //Ajuste do HTML para receber os valores dos campos
        oHTMLBody:ValByName('cTexto'	, If((cTMP1)->DIAS < 0, "Fatura Vencida","Fatura em Aberto") )
        oHTMLBody:ValByName('nValor'	, "R$ " + AllTrim(Transform(nValor,"@E 999,999,999.99"))  )
        oHTMLBody:ValByName('cDtVenc'	, DToC(SE1->E1_VENCTO) )
        oHTMLBody:ValByName('cNF'	    , SE1->E1_XNUMNFS)
        oHTMLBody:ValByName('cBanco'	, cBanco   )
        oHTMLBody:ValByName('cAgencia'  , cAgencia )
        oHTMLBody:ValByName('cConta'    , cConta   ) 
        oHTMLBody:ValByName('cFavore'	, cFavorec )
        oHTMLBody:ValByName('cCNPJ'	    , cCNPJ    )
        oHTMLBody:ValByName('cLinkNF'   , SE1->E1_XLINKNF )
        oHTMLBody:ValByName('cRefere'   , SE1->E1_HIST )
        
        oHTMLBody:SaveFile(cHTMLDst)

        cBody := MtHTML2Str(cHTMLDst)

        FErase(cHTMLDst)

        If Empty(cMailTo)
            Conout('Email do destinatario em branco: '+AllTrim(SA1->A1_NOME))
            LjWriteLog( cARQLOG, 'Email do destinatario em branco: '+AllTrim(SA1->A1_NOME) )
            (cTMP1)->(DbSkip())
            LOOP
        EndIf

        If Empty(cBody)
            Conout("Necessario a utilizacao do arquivo FINA740_mail001.html na pasta protheus_data/samples/wf para o envio de e-mail")
            LjWriteLog( cARQLOG, "Necessario a utilizacao do arquivo FINA740_mail001.html na pasta protheus_data/samples/wf para o envio de e-mail" )
            (cTMP1)->(DbSkip())
            LOOP
        EndIf

        cMsgLog := ""
        
        If u_FstMail(cMailTo, "", cTit, cBody, @cMsgLog)
            
            RecLock("SE1",.F.)
                REPLACE SE1->E1_XDTENVI WITH DATE()
            MsUnlock()

            Conout('Enviado com sucesso o email de faturamento para o cliente: '+AllTrim(SA1->A1_NOME))
            LjWriteLog( cARQLOG, 'Enviado com sucesso o email de faturamento para o cliente: '+AllTrim(SA1->A1_NOME) )
        Else
            Conout('Problema para enviar o email de faturamento para o cliente: ' + AllTrim(cMsgLog) )
            LjWriteLog( cARQLOG, 'Problema para enviar o email de faturamento para o cliente: ' + AllTrim(cMsgLog) )
        EndIf
        
        (cTMP1)->(DbSkip())
    EndDo
EndIf

(cTMP1)->(DbCloseArea())

RestArea(aAreaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FstMail
Workflow financeiro, lembrete de fatura para os clientes.

@author  Wilson A. Silva Jr.
@since   09/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function FstMail(cMailTo, cMailCC, cAssunto, cMsg, cMsgLog)

Local lRet        := .T.
Local cSMTPServer := GetNewPar("AL_MAILSRV","email-ssl.com.br")
Local cSMTPUser   := GetNewPar("AL_MAILUSR","adm@alfaerp.com.br")
Local cSMTPPass   := GetNewPar("AL_MAILPSW","240820@Alfa")
Local cMailFrom   := GetNewPar("AL_MAILROM","adm@alfaerp.com.br")
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

DEFAULT cMsg := "<hr>Envio de e-mail via Protheus<hr>"

If Empty(cMailCC)
    cMailCC := cCopia
EndIf

 //----------------- DISPARO OUTLOOK -------------------------------------
//cSMTPServer 	:= "smtp-mail.outlook.com"
//cSMTPUser 		:= "@hotmail.com"
//cSMTPPass 		:= ""
//cMailFrom 		:= "@hotmail.com"
//cMailTo			:= cPara
//cMailCC			:= cCopia
//lUseAuth 		    := .T.
//oMail:SetUseTLS(.T.)
//oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, 587  )
//nErro := oMail:SmtpConnect()
//---------------------------------------------------------

//------------------- DISPARO ALFA
//cSMTPServer 	:= "email-ssl.com.br"
//cSMTPUser 		:= "@alfaerp.com.br"
//cSMTPPass 		:= ""
//cMailFrom 		:= "@alfaerp.com.br"
//cMailTo			:= cPara
//cMailCC			:= cCopia
//lUseAuth 		:= .T.
//nStatusCode := oMail:Init("",cSMTPServer,cSMTPUser,cSMTPPass,,587)
//nErro := oMail:SmtpConnect()
//oMail:SetUseTLS(.T.)
//---------------

Conout('Conectando com SMTP ['+cSMTPServer+'] ') 

oMail := TMailManager():New()

If lTLS
    Conout('Utilizando autenticacao TLS')
    oMail:SetUseTLS(.T.)
ElseIf lSSL
    Conout('Utilizando autenticacao SSL')
    oMail:SetUseSSL(.T.)
EndIf

Conout('Inicializando SMTP')
nErro := oMail:Init("",cSMTPServer,cSMTPUser,cSMTPPass,,nPorta)
Conout('Status de Retorno = '+str(nErro,6))

Conout('Setando Time-Out')
oMail:SetSmtpTimeOut( nTimeOut )

Conout('Conectando com servidor...')
nErro := oMail:SmtpConnect()
Conout('Status de Retorno = '+str(nErro,6))

If lUseAuth
	
	Conout("Autenticando Usuario ["+cSMTPUser+"] senha ["+cSMTPPass+"]")
	nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
	
	Conout('Status de Retorno = '+str(nErro,6))
	
	If nErro <> 0
		
		// Recupera erro ...
		cMsgLog := oMail:GetErrorString(nErro)
		cMsgLog := "Erro de Autenticacao "+str(nErro,4)+' ('+cMsgLog+')'
        Conout(cMsgLog)
		lRet := .F.
	EndIf
	
EndIf

If nErro <> 0
	// Recupera erro
	cMsgLog := oMail:GetErrorString(nErro)
	cMsgLog := "Erro de Conexão SMTP "+str(nErro,4)+' ('+cMsgLog+')'
	Conout(cMsgLog)

	Conout('Desconectando do SMTP')
	oMail:SMTPDisconnect()

	lRet := .F.
EndIf

If lRet
	Conout('Compondo mensagem em memória')
	
	oMessage := TMailMessage():New()
	oMessage:Clear()
    
	oMessage:cFrom 	  := cMailFrom
	oMessage:cTo	  := cMailTo
	oMessage:cCc 	  := cMailCC
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := cMsg
	
	Conout('Enviando Mensagem para ['+cMailTo+'] ')
	nErro := oMessage:Send( oMail )
	
	If nErro <> 0
		cMsgLog := oMail:GetErrorString(nErro)
	    cMsgLog := "Erro de Envio SMTP "+str(nErro,4)+" ("+cMsgLog+")"
		Conout(cMsgLog)
		lRet := .F.
	EndIf
	
	Conout('Desconectando do SMTP')
	oMail:SMTPDisconnect()
EndIf	

Return lRet
