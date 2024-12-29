#Include "Protheus.ch"      
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ALENVIABOLETOS ³ Autor ³ Alexandro Dias  ³ Data ³ 10/09/18 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#Define cEOL CHR(13) + CHR(10)

User Function ALEnviaBoletos(cBolPath)

Local lApiBol  := GetNewPar("MV_XAPIBOL",.T.) // Habilita Integração de Boletos via API com o Itau
Local lRetorno := .T.
Local cMsgErro := ""

Default cBolPath := ''

If lApiBol
	If FWIsInCallStack("U_ALFPMS06")
		lRetorno:= U_ALEnvNFBol(lApiBol, cMsgErro,@cBolPath)
	else
		// Realiza Registro do Boleto no Banco
		LjMsgRun("Registrando boleto no banco e enviando ao cliente....",,{|| lRetorno := U_ALFINM06() } )
	end
Else
	LjMsgRun("Enviando NF e/ou Boleto para: " + Alltrim(SE1->E1_NOMCLI),,{|| lRetorno := U_ALEnvNFBol(lApiBol, cMsgErro) } )

	If !lRetorno
		Help(Nil,Nil,ProcName(),,cMsgErro,1,5)
	EndIf
EndIf

Return(.T.)

User Function ALEnvNFBol(lApiBol, cMsgErro,cBolPath)

Local nX, nCntFor
Local aArea     	:= GetArea()
Local lAttach		:= .T.
Local aPara			:= {}
Local cAssunto		:= ''
Local cDescProposta	:= ''
Local cHtml			:= ''
Local lResult   	:= .T.								// Se a conexao com o SMPT esta ok
Local lRet	   		:= .T.								// Se tem autorizacao para o envio de e-mail
Local lRelauth  	:= GetMV("MV_RELAUTH",, .F.)		// Parametro que indica se existe autenticacao no e-mail
Local cContato		:= 'Prezado(a)'
Local cPathSrv 		:= '\boletos\'
Local cPathClient 	:= 'c:\boletos\'
Local cServer   	:= Alltrim(GetNewPar('MV_XWSRV'+SE1->E1_EMPFAT)) 	// Ex.: smtp.ig.com.br ou 200.181.100.51
Local cCtaAut   	:= Alltrim(GetNewPar('MV_XWCNT'+SE1->E1_EMPFAT)) 	// usuario para Autenticacao Ex.: fuladetal
Local cConta    	:= Alltrim(GetNewPar('MV_XWCNT'+SE1->E1_EMPFAT))	// usuario para Autenticacao Ex.: fuladetal
Local cPsw      	:= Alltrim(GetNewPar('MV_XWPSW'+SE1->E1_EMPFAT))	// Senha de acesso Ex.: 123abc
Local cFrom			:= cConta
Local cEmailTo  	:= ''								// E-mail de destino
Local cEmailBcc 	:= '' 								// E-mail de copia
Local cEmailInt		:= ''
Local cError    	:= ''								// String de erro
Local cAttach		:= ''
Local cNumBoleto	:= ''
Local cCodCli 		:= SE1->E1_CLIENTE+SE1->E1_LOJA
Local cProposta		:= SE1->E1_PROPOS
Local cAditivo		:= SE1->E1_ADITIV
Local nValorNF		:= SE1->E1_SALDO
Local nValorBol 	:= SE1->E1_SALDO - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

Default cAttach 	:= ""
Default lApiBol  	:= .F.
Default cMsgErro 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega nome correto do boleto.							       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumBoleto := SE1->E1_CLIENTE +'-'+ Alltrim(SE1->E1_XNUMNFS) + '-' + StrZero(Day(dDataBase),2) + StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4) + '.PDF'

Aadd(aPara,'cristina.satie@alfaerp.com.br')
//Aadd(aPara,'alexandro.dias@alfaerp.com.br')
//Aadd(aPara,'fabio.pereira@alfaerp.com.br')
cEmailBcc := 'alexandro.dias@alfaerp.com.br;fabio.pereira@alfaerp.com.br'

If SE1->E1_EMPFAT == '2' // ERP - 13
	Aadd(aPara,'tailan.oliveira@mooveconsultoria.com.br')
EndIf

Z02->( DbSetOrder(1) )
IF Z02->( DbSeek( xFilial('Z02') + cProposta + cAditivo ) )
	cDescProposta := Alltrim(cProposta) + '/' + Alltrim(cAditivo) + ' - ' + Alltrim(Z02->Z02_DESCRI)
EndIF

If SE1->E1_EMPFAT == '2' // MOOVE - 13
	cAssunto := 'Workflow MOOVE - Faturamento: ' + Capital( Alltrim(SE1->E1_HIST) )
Else // ALFA - 07
	cAssunto := 'Workflow ALFA - Faturamento: ' + Capital( Alltrim(SE1->E1_HIST) )
EndIf

SA1->( DbSetOrder(1) )
IF SA1->( DbSeek( xFilial('SA1') + cCodCli ) )

	IF !Empty(SA1->A1_EMAILNF)
		cEmailTo := Alltrim(SA1->A1_EMAILNF)
	Else
		cMsgErro := 'O e-mail de recebimento da NF/Boleto não esta cadastrado.'
		RestArea(aArea)
		Return(.F.)
	EndIF 

Else
	cMsgErro := 'Cliente não encontrado.'
	RestArea(aArea)
	Return(.F.)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Remonta os destinatarios utilizando o vetor.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEmailInt := ''
For nCntFor := 1 To Len(aPara)
	IF !Empty(cEmailInt)
		cEmailInt += ';'
	EndIF
	cEmailInt += aPara[nCntFor]
Next

If !lApiBol
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia boleto para o servidor.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := __CopyFile( cPathClient + cNumBoleto , cPathSrv + cNumBoleto )
		
	IF !lRet
		cMsgErro := 'Nao foi possivel enviar o Boleto do Banco do Brasil: ' + cPathClient + cNumBoleto 
		RestArea(aArea)
		Return(.F.)
	EndIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem anexo.				                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lAttach
	aDirectory := Directory( cPathSrv + cNumBoleto )
		
	For nX := 1 To Len(aDirectory)
		cAttach += cPathSrv + aDirectory[nX,1] + IIF(nX < Len(aDirectory) , ',' , '')
	Next
EndIF

If FWIsInCallStack("U_ALFPMS06")
	cNumBoleto := SE1->E1_CLIENTE +'-'+ Alltrim(SE1->E1_XNUMNFS) + '*.pdf'
	aDirectory := Directory( cPathSrv + cNumBoleto )
	For nX := 1 To Len(aDirectory)
		cAttach += cPathSrv + aDirectory[nX,1] + IIF(nX < Len(aDirectory) , ',' , '')
	Next	
	cBolPath := cAttach
	lResult:= .t.
else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta HTML para enviar NF + Boleto.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cHtml := HtmlBoleto(@cHtml,cDescProposta,nValorNF,nValorBol)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia o mail para a lista selecionada.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmailTo += ';' + cEmailInt

	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

	// Se a conexao com o SMPT esta ok
	If lResult

		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lRet := Mailauth( cCtaAut, cPsw )
		Else
			lRet := .T.	
		Endif    

		If lRet
			
			SEND MAIL; 
			FROM 		cFrom;
			TO      	cEmailTo;
			BCC     	cEmailBcc;
			SUBJECT 	cAssunto;
			BODY    	cHtml;
			ATTACHMENT  cAttach;
			RESULT 		lResult

			If !lResult
				//Erro no envio do email
				GET MAIL ERROR cError
				cMsgErro := cError + " " + cEmailTo
			Endif

		Else
			GET MAIL ERROR cError
			cMsgErro := 'Erro de autenticação, Verifique a conta e a senha para envio'
		Endif
			
		DISCONNECT SMTP SERVER
				
		// MsgAlert('Enviado para:' + cEmailTo)	
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		cMsgErro := cError
	Endif
end

Return(lResult)

Static Function HtmlBoleto(cHtml,cDescProposta,nValorNF,nValorBol)

cHtml := '<HTML>'
cHtml += '<HEAD>'
cHtml += '<TITLE>ALFA Sistemas</TITLE>'
cHtml += '<Style>'
cHtml += 'BODY 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'DIV 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'TABLE	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'TD 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += '.Mini	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
cHtml += 'FORM 	{MARGIN: 0pt}'
cHtml += '.S_A 	{FONT-SIZE: 10pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #FFFFFF; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFA500; TEXT-ALIGN: left} '
cHtml += '.S_B 	{FONT-SIZE: 10pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFFFF; TEXT-ALIGN: left} '
cHtml += '</Style>'
cHtml += '</HEAD>'
cHtml += '<BODY>'

cHtml += ' <TR> '
cHtml += ' <B>Prezado(a) ' +Capital(SA1->A1_NOMENFS)+ '</B> '
cHtml += ' <BR> '
If SE1->E1_EMPFAT == '2' // ERP - 13
	cHtml += ' <BR>Segue faturamento referente a Prestação de Serviços executados pela <B>Moove Consultoria.</B><BR> '
Else
	cHtml += ' <BR>Segue faturamento referente a Prestação de Serviços executados pela <B>ALFA Sistemas.</B><BR> '
EndIf
cHtml += ' <BR>'
xconta:= 'workflow@alfaerp.com.br'//Alltrim(GetNewPar('MV_XWCNT'+SE1->E1_EMPFAT))
cHtml += ' Pedimos que por favor cadastre o e-mail '+xconta+' como confiável para recebimento dos faturamentos.'
cHtml += ' <BR>'
cHtml += ' <BR>'

cHtml += ' Lembrando que o Link da Nota Fiscal esta no corpo do e-mail e Boleto Anexo.<BR>'
cHtml += ' Pagamentos serão aceitos apenas via boleto emitido por gentileza.'

cHtml += ' <BR>'
cHtml += ' <BR>'

cHtml += ' <B>Em caso de dúvidas segue nossos Contatos:</B>'

cHtml += ' <BR>'
cHtml += ' <BR>'

cHtml += ' Telefone Fixo: (11) 3588-9997 <BR>'
cHtml += ' WhatsApp Equipe Contas a Receber: 11 97490-3611 <BR>'
cHtml += ' WhatsApp Gerente Administrativo: 11 98801-5136 <BR>'
IF SE1->E1_EMPFAT == '2'
	cHtml += ' E-mail: <a href="mailto:contasareceber@alfaerp.com.br">contasareceber@alfaerp.com.br</a> '
Else
	cHtml += ' E-mail: <a href="mailto:contasareceber@alfaerp.com.br">contasareceber@alfaerp.com.br</a> '	
END
cHtml += ' <BR>'
cHtml += ' <BR>'

cHtml += ' </TR>'

IF !Empty(SE1->E1_MSGMAIL)
	cHtml += ' <TR> '
	cHtml +=		Alltrim(SE1->E1_MSGMAIL)
	cHtml += '      <BR>'
	cHtml += ' </TR> '
EndIF

cHtml += ' <BODY> '   
cHtml += ' <TABLE Style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1> '

cHtml += ' <TR> '
cHtml += '	<TD Class=S_B Style="WIDTH: 15%"><B>Cliente</B></TD> '
cHtml += '	<TD Class=S_B Style="WIDTH: 85%">' +Alltrim(SA1->A1_NOME)+ '</TD> '
cHtml += ' </TR> '

cHtml += ' <TR> '
cHtml += '	<TD Class=S_B Style="WIDTH: 15%"><B>Contrato</B></TD> '
cHtml += '	<TD Class=S_B Style="WIDTH: 85%">' +cDescProposta+ '</TD> '
cHtml += ' </TR> '

cHtml += '			<TR> '
cHtml += '				<TD Class=S_A Style="WIDTH: 15%"><B>Onde está o Boleto?</B></TD> '
cHtml += '				<TD Class=S_A Style="WIDTH: 85%">Esta anexado.</TD> '
cHtml += '			</TR> '

cHtml += '			<TR> '
cHtml += '				<TD Class=S_B Style="WIDTH: 15%"><B>Valor do Boleto</B></TD> '
cHtml += '				<TD Class=S_B Style="WIDTH: 85%"> R$ ' +Alltrim(Transform(nValorBol,'@E 999,999,999.99'))+ '</TD> '
cHtml += '			</TR> '

IF !Empty(SE1->E1_XLINKNF)

	cHtml += '			<TR> '
	cHtml += '				<TD Class=S_A Style="WIDTH: 15%"><B>Cadê a NFS-e?</B></TD> '
	cHtml += '				<TD Class=S_A Style="WIDTH: 85%">O PDF da DANFE esta neste Link da Prefeitura: ' +Alltrim(SE1->E1_XLINKNF)+ '</TD> '
	cHtml += '			</TR> '
	
	cHtml += '			<TR> '
	cHtml += '				<TD Class=S_B Style="WIDTH: 15%"><B>Valor da NFS-e</B></TD> '
	cHtml += '				<TD Class=S_B Style="WIDTH: 85%"> R$ ' +Alltrim(Transform(nValorNF,'@E 999,999,999.99'))+ '</TD> '
	cHtml += '			</TR> '

EndIF
/*
IF !Empty(SE1->E1_MSGNF)
	cHtml += '			<TR> '
	cHtml += '				<TD Class=S_A Style="WIDTH: 15%"><B>Observações</B></TD> '
	cHtml += '				<TD Class=S_A Style="WIDTH: 85%">' +Alltrim(SE1->E1_MSGNF)+ '</TD> '
	cHtml += '			</TR> '
EndIF
*/
cHtml += '			<TR> '
cHtml += '				<TD Class=S_B Style="WIDTH: 15%"><B>Vencimento do Boleto</B></TD> '
cHtml += '				<TD Class=S_B Style="WIDTH: 85%"> ' +Dtoc(SE1->E1_VENCREA)+ '</TD> '
cHtml += '			</TR> '

cHtml += ' </TABLE> '
cHtml += ' </BODY> '

//cHtml += ' <BR><B>Se preferir efetuar o pagamento via depósito ou transferência bancária, segue nossa conta bancária:</B><BR><BR>'

cHtml += ' <BR>Após o vencimento será aplicado multa e juros conforme prevê o contrato.<BR><BR>'
cHtml += ' Dúvidas estamos à disposição,<BR>'
cHtml += ' Atenciosamente,<BR>'
cHtml += ' Administrativo Financeiro<BR>'
IF SE1->E1_EMPFAT == '2' // ERP - 13
	cHtml += ' <BR><a href="mailto:administrativo@mooveconsultoria.com.br">administrativo@mooveconsultoria.com.br</a> '
else
	cHtml += ' <BR><a href="mailto:adm@alfaerp.com.br">adm@alfaerp.com.br</a> '
end
/*
IF SE1->E1_EMPFAT == '2' // ERP - 13

	cHtml += '      <B>Banco:</B> 341 (Itaú) <BR> '
	cHtml += '      <B>Agencia:</B> 0018 <BR> '
	cHtml += '      <B>Conta:</B> 51567-6 <BR> '
	cHtml += '      <B>Favorecido:</B> ALFA SISTEMAS E TECNOLOGIA LTDA <BR> '
	cHtml += '      <B>CNPJ:</B> 13.400.708/0001-81 <BR> '

ElseIf (SE1->E1_EMPFAT == '4') // ALFA (24) Licencas

	cHtml += '      <B>Banco:</B> 341 (Itaú) <BR> '
	cHtml += '      <B>Agencia:</B> 0018 <BR> '
	cHtml += '      <B>Conta:</B> 99453-3 <BR> '
	cHtml += '      <B>Favorecido:</B> ALFA SISTEMAS LTDA <BR> '
	cHtml += '      <B>CNPJ:</B> 24.495.268/0001-00 <BR> '
Else // ALFA - 07.640

	cHtml += '      <B>Banco:</B> 341 (Itaú) <BR> '
	cHtml += '      <B>Agencia:</B> 0018 <BR> '
	cHtml += '      <B>Conta:</B> 77729-2 <BR> '
	cHtml += '      <B>Favorecido:</B> ALFA SISTEMAS DE GESTAO LTDA <BR> '
	cHtml += '      <B>CNPJ:</B> 07.640.028/0001-32 <BR> '

EndIF


cHtml += ' <BR>Questionamentos em relação a este faturamento devem ocorrer em até 02 dias após o recebimento deste.<BR>'
cHtml += ' <BR><B><U>Por favor, acusar o recebimento.</U></B><BR> '
cHtml += ' <BR>Em caso de dúvida, entrar em contato.<BR> '
cHtml += ' <BR>Atenciosamente, '
cHtml += ' <BR> '

If SE1->E1_EMPFAT == '2' // ERP - 13
	cHtml += ' <BR>Administrativo '
	cHtml += ' <BR>(11) 3588-9997 '
	cHtml += ' <BR><a href="mailto:administrativo@mooveconsultoria.com.br">administrativo@mooveconsultoria.com.br</a> '
	cHtml += ' <BR> '
	cHtml += ' <BR><a href="https://www.mooveconsultoria.com.br">www.mooveconsultoria.com.br</a> '
	cHtml += ' <BR>[11] 3588.9192 Suporte (TOTVS) ' 
	cHtml += ' <BR> '
	cHtml += ' <BR><a href="https://www.mooveconsultoria.com.br"><img width="255" height="74" src="https://mooveconsultoria.com.br/wp-content/uploads/2021/11/logo-moove-2.svg" alt="Logo Moove Consultoria"></a> '
Else
	cHtml += ' <BR>Administrativo '
	cHtml += ' <BR>(11) 3588-9997 '
	cHtml += ' <BR><a href="mailto:adm@alfaerp.com.br">adm@alfaerp.com.br</a> '
	cHtml += ' <BR> '
	cHtml += ' <BR><a href="https://alfaerp.com.br">alfaerp.com.br</a> '
	cHtml += ' <BR> '
	cHtml += ' <BR><a href="https://alfaerp.com.br"><img width="600" height="60" src="https://alfaerp.com.br/wp-content/themes/alfa2020/assets/images/alfa-sap-top.png" alt="Logo ALFA ERP"></a> '
EndIf
*/

cHtml += ' <BR> '
cHtml += ' </body>
cHtml += ' </HTML> '

MemoWrite('C:\Propostas\Exemplo-Fat.html',cHtml)

Return(cHtml)
