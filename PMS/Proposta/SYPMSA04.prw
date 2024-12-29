#Include "Protheus.ch"
#DEFINE EDT_TIPO     1 //TIPO
#DEFINE EDT_DSCTP    2 //DESCRICAO DO TIPO
#DEFINE EDT_HRSTP    3 //HORAS DO TIPO
#DEFINE EDT_TOTAL 	 4 //VALOR VENDA
#DEFINE EDT_FASES 	 5 //ARRAY COM FASES

#DEFINE EDT_CODFASE  1 //CODIGO DA FASE
#DEFINE EDT_DESCRI	 2 //DESCRI
#DEFINE EDT_HORAS	 3 //HORAS
#DEFINE EDT_CUSTO	 4 //CUSTO
#DEFINE EDT_SUBARRAY 5 //ARRAY DE ETAPAS

#DEFINE EDT_SUBMEN    1 //DESCRI
#DEFINE EDT_SUBHORAS  2 //HORAS DO SUBMENU
#DEFINE EDT_SUBCUSTO  3 //HORAS DO SUBMENU
#DEFINE EDT_TAREFAS	  4 //ARRAY DE TAREFAS

#DEFINE TRF_SEQ  		1 //SEQUENCIA
#DEFINE TRF_MODULO		2 //MODULO
#DEFINE TRF_DESCRI		3 //DESCRI
#DEFINE TRF_HORASA		4 //HORAS
#DEFINE TRF_EDTID   	5 //ID
#DEFINE TRF_FASE   		6 //FASE
#DEFINE TRF_ORDEM 		7 //ORDEM
#DEFINE TRF_SUBMEN 		8 //ETAPA
#DEFINE TRF_PROCES		9 //PROCESSO
#DEFINE TRF_HORAS		10//HORAS
#DEFINE TRF_ID			11//ID MODULO
#DEFINE TRF_NITEM		12//ID TAREFA
#DEFINE TRF_CUSTO		13//Custo

#DEFINE MOD_SEQ   		1 //Sequencia
#DEFINE MOD_MODULO   	2 //Modulo
#DEFINE MOD_DESCRI   	3 //Descricao
#DEFINE MOD_TIPO   		4 //Tipo
#DEFINE MOD_HORAS   	5 //Horas
#DEFINE MOD_RESERVA   	6 //Horas Reserva
#DEFINE MOD_DISPONIVEL  7 //Horas Disponivel
#DEFINE MOD_CUSTO   	8 //Custo
#DEFINE MOD_ID 	  		9 //ID
#DEFINE MOD_CUSTOT	  	10 //Custo Total
#DEFINE MOD_PERCRES	  	11 //%Reserva
#DEFINE MOD_ITENS	  	12 //Itens
#DEFINE MOD_TOTAL	  	13 //Valor de Venda do Modulo

#DEFINE MOD_I_ETAPA   	1 //Etapa
#DEFINE MOD_I_PROCESSO 	2 //Processo
#DEFINE MOD_I_HORAS   	3 //Horas
#DEFINE MOD_I_RESERVA   4 //Horas Reservadas
#DEFINE MOD_I_DISP      5 //Horas Disponiveis
#DEFINE MOD_I_NITEM     6 //Numero da Linha do Item
#DEFINE MOD_I_TIPO      7 //Tipo do Servico (1-Consultoria, 2- Desenvolvimento)
#DEFINE MOD_I_ORDEM     8 //Ordem
#DEFINE MOD_I_FASE      9 //Fase
#DEFINE MOD_I_DESCFASE  10//Descricao Fase
#DEFINE MOD_I_ID        11//Id do Modulo Pai

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYPMSA04  ºAutor  ³Fabio Rogerio       º Data ³  03/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para gerar projeto com base na proposta              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYPMSA04()

Local aArea 	:= GetArea()
Local aButtons 	:= {}
Local nOpca 	:= 0
Local cCoord	:= Space(TamSx3("AE8_RECURS")[1])
Local oCoord
Local cCoordDev	:= Space(TamSx3("AE8_RECURS")[1])
Local oCoordDev
Local oDescCoord
Local oDescDev
Local cDescCoord:= Space(TamSx3("AE8_DESCRI")[1])
Local cDescDev	:= Space(TamSx3("AE8_DESCRI")[1])
Local cMemo 	:= 'Informar aqui os detalhes e observações do projeto...'
Local oMemo
Local oObsTohoma
Local oDlgAprova
Local oPnl2
Local oPnl3
Local oPnl4
Local oPnl5
Local oScroll
Local aModulos		:= {}
Local aSize         := {}
Local K				:= 0
Local cReserva		:= ""
Local lExibeTela    := .T.
Local nReserva      := GetNewPar("MV_XPERRET",20) //Percentual Retencao
Local nHoraCusto    := GetNewPar("MV_HORACUS",70) //Valor Hora Padrao
Local cModPrjCon    := SuperGetMv("MV_MODCON",.F.,"005") //Modelo de Projeto de Consultoria

//Ajusta o status se a proposta for da ALFA - Propostas usadas para teste
If (Z02->Z02_CLIENT == "000080")
	RecLock("Z02",.F.)
	Replace Z02_STATUS With "5"
	Replace Z02_PROJET With ""
	MsUnlock()

	DbSelectArea("AF8")
	DbOrderNickName("AF8PROPOS")
	DbSeek(xFilial("AF8")+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
	While !Eof() .And. (AF8->AF8_PROPOS == Z02->Z02_PROPOS) .And. (AF8->AF8_ADITIV == Z02->Z02_ADITIV)

		AFC->(dbSetOrder(1))
		AFC->(dbSeek(xFilial("AFC")+AF8->AF8_PROJET))
		While !Eof() .And. (AFC->AFC_PROJET == AF8->AF8_PROJET)
			RecLock("AFC",.F.,.T.)
			DbDelete()
			MsUnLock()

			AFC->(DbSkip())
		End

		AF9->(dbSetOrder(1))
		AF9->(dbSeek(xFilial("AF9")+AF8->AF8_PROJET))
		While !Eof() .And. (AF9->AF9_PROJET == AF8->AF8_PROJET)
			RecLock("AF9",.F.,.T.)
			DbDelete()
			MsUnLock()

			AF9->(DbSkip())
		End

		RecLock("AF8",.F.,.T.)
		DbDelete()
		MsUnLock()
		AF8->(DbSkip())
	End
EndIf


oHrContrato:= Nil
oHrReserva:= Nil
oHrDisp:= Nil
oHrCusto:= Nil

cHrContrato:= ""
cHrReserva := ""
cHrDisp    := ""
cHrCusto   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a proposta está em status APROVADA.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (Z02->Z02_STATUS == '9')
	
 	Help( "",1,"Atencao",,"Este Projeto já foi aprovado. Será enviado novamente Workflow avisando sobre esta Aprovação.",1,1 )
	
	DbSelectArea("AF8")
	DbOrderNickName("AF8PROPOS")
	IF DbSeek(xFilial("AF8")+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
		
		//Envia e-mail para PMO avisando sobre cadastro de novo projeto
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + AF8->AF8_CLIENT + AF8->AF8_LOJA))
		
		cAssunto  	:= "Cadastro de Novo Projeto - Projeto: " + AF8->AF8_PROJET + " - " + AllTrim(AF8->AF8_DESCRI) + " - Cliente: " + AF8->AF8_CLIENT + "/" + AF8->AF8_LOJA + " - " + AllTrim(SA1->A1_NOME)
		cMensagem 	:= MsgMail( MSMM(AF8->AF8_CODMEM) )
		aPara 		:= {}
		

		//aAdd( aPara , GetMV("MV_MAILGER"))
		IF Z02->Z02_TIPO $ '128' 	// TOTVS
			cParEmail     := SuperGetMv("MV_MOVMAIL",.F.,"alexandro.dias@alfaerp.com.br;tailan.oliveira@mooveconsultoria.com.br;administrativo@mooveconsultoria.com.br;pmo@mooveconsultoria.com.br") 
		Else
			cParEmail     := SuperGetMv("MV_ALFMAIL",.F.,"fabio.pereira@alfaerp.com.br;alexandro.dias@alfaerp.com.br;adm@alfaerp.com.br;marcos.franca@alfaerp.com.br;pmo@alfaerp.com.br") 
		End		
		aAdd( aPara , cParEmail )
		//aAdd( aPara , 'fabio.pereira@alfaerp.com.br' )
		//aAdd( aPara , 'alexandro.dias@alfaerp.com.br' )
				
		LjMsgRun("Aguarde, enviando projeto para Coordenação...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cMensagem,.F.,'') } )
		
	EndIF
	
ElseIF (Z02->Z02_STATUS <> '5')
	
	Help( "",1,"Atencao",,"Somente é possivel gerar projeto para propostas APROVADAS.",1,1 )
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se já existe projeto gerado para esta proposta.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("AF8")
	DbOrderNickName("AF8PROPOS")
	IF DbSeek(xFilial("AF8")+Z02->Z02_PROPOS+Z02->Z02_ADITIV)
		
		Help( "",1,"Atencao",,"Já existe projeto cadastrado para esta proposta. Projeto:"+AF8->AF8_PROJET+"-"+AF8->AF8_DESCRI,1,1 )
		
	Else
		
		aModulos:={}
		cPropos := Z02->Z02_PROPOS
		cAditivo:= Z02->Z02_ADITIV
		
		DbSelectArea("Z05") 
		DbOrderNickName("Z05SEQ")
		DbSeeK(xFilial("Z05") + cPropos+cAditivo)
		While !Eof() .And. Z05->Z05_PROPOS == cPropos .And. (Z05->Z05_ADITIV == cAditivo)
			aAdd(aModulos,{Z05->Z05_SEQ,Z05->Z05_MODULO,Z05->Z05_DESCRI,Z05->Z05_TPSERV,Round(Z05->Z05_HORASA,0),0,Round(Z05->Z05_HORASA,0),Round(Z05->Z05_CUSTO,0),Z05->Z05_ID,Round(Z05->Z05_CUSTOT,0),0,{},Z05->Z05_TOTAL})
	

			DbSelectArea("Z03") 
			DbSetOrder(1)
			DbSeeK(xFilial("Z03") + cPropos + cAditivo + Z05->Z05_ID,.T.)
			While !Eof() .And. (xFilial("Z03") + cPropos + cAditivo + Z05->Z05_ID == Z03->Z03_FILIAL+Z03->Z03_PROPOS+Z03->Z03_ADITIV+Z03->Z03_ID)
				
				//So considera as atividades com Escopo = Sim ou Escopo = Atividade do Cliente
				If Z03->Z03_ESCOPO $ ('1/3')
					Z07->(DbSetOrder(1))
					Z07->(DbSeek(xFilial("Z07")+cModPrjCon+Z03->Z03_FASE,.T.))

					Aadd(aModulos[Len(aModulos),MOD_ITENS], {	Z03->Z03_SUBMEN,;
																Z03->Z03_PROCES,;
																Z03->Z03_HORAS,;
																0,;
																Z03->Z03_HORAS,;
																Z03->Z03_NITEM,;
																Z03->Z03_TIPO,;
																Z03->Z03_ORDEM,;
																Z03->Z03_FASE,;
																Z07->Z07_DESCRI,;
																Z03->Z03_ID })
				EndIf

				DbSelectArea("Z03") 
				DbSkip()
			End

			//Ordena os itens dos modulos
			aModulos[Len(aModulos),MOD_ITENS]:= aSort( aModulos[Len(aModulos),MOD_ITENS]  , , , { |x,y| x[MOD_I_FASE]+x[MOD_I_ORDEM] < y[MOD_I_FASE]+y[MOD_I_ORDEM] } )

			DbSelectArea("Z05") 
			DbSkip()
		End

		aModulos:= aSort( aModulos  , , , { |x,y| x[MOD_SEQ] < y[MOD_SEQ] } )

		If lExibeTela
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Funcao que ira gerar o projeto nas tabelas padroes do PMS.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMsg := "Confirmar Geração de Projeto referente a a Proposta [" + Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV +"]"	+ Chr(13) + Chr(10)
			cMsg += "Descrição do Projeto: " 	+ Alltrim(Z02->Z02_DESCRI) 							+ Chr(13) + Chr(10)
			cMsg += "Cliente/Prospect: " 		+ AllTrim(Z02->Z02_RAZAO)
			
			DEFINE FONT oObsTohoma  NAME "Tahoma" 	SIZE 0, -13 BOLD  
			DEFINE FONT oFontG  NAME "Arial" 	SIZE 0, -11 BOLD  
		
			//ny := 400 + 30 * Len(aModulos)
			aSize:= MsAdvSize(.F.)
			
			DEFINE MSDIALOG oDlgAprova TITLE "Gerar Projeto" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL
			
			oDlgAprova:lEscClose := .F.
			oDlgAprova:Center(.T.)
			oDlgAprova:lMaximized := .T. //Maximiza a janela

			oFwLayer := FwLayer():New()
			oFwLayer:Init(oDlgAprova,.F.)

			oFWLayer:addLine("Lin1",010	, .F.)
			oFWLayer:addLine("Lin2",010	, .F.)
			oFWLayer:addLine("Lin3",055	, .F.)
			oFWLayer:addLine("Lin4",010	, .F.)
			oFWLayer:addLine("Lin5",015, .F.)

			oPanel1 :=oFWLayer:GetLinePanel("Lin1")
			oPanel2 :=oFWLayer:GetLinePanel("Lin2")
			oPnl3   :=oFWLayer:GetLinePanel("Lin3")
			oPnl4   :=oFWLayer:GetLinePanel("Lin4")
			oPnl5   :=oFWLayer:GetLinePanel("Lin5")

			oScroll:= TScrollBox():New( oPnl3, 0, 0, 0, 0,.T.,.T.,.T.)
			oScroll:Align:= CONTROL_ALIGN_ALLCLIENT

			oPnl1 		:= TPanel():New(0, 0, "", oPanel1, NIL, .T., .F., Rgb(169,169,169), Rgb(131,111,255), 0, 0, .T., .F. )
			oPnl1:Align	:= CONTROL_ALIGN_ALLCLIENT	
			oPnl1:nClrPane:= Rgb(169,169,169)
			oPnl1:nClrText:= Rgb(169,169,169)

			oPnl2 		:= TPanel():New(0, 0, "", oPanel2, NIL, .T., .F., Rgb(192,192,192), Rgb(0,0,0), 0, 0, .T., .F. )
			oPnl2:Align	:= CONTROL_ALIGN_ALLCLIENT
			oPnl2:nClrPane:= Rgb(255,165,0)
			oPnl2:nClrText:= Rgb(255,165,0)

			@ 004, 005 SAY cMsg OF oPnl1 FONT oObsTohoma COLOR Rgb(255,255,255),Rgb(169,169,169) Pixel SIZE 500,030 HTML
			
			@ 005, 005 SAY "Gerente do Projeto" 		SIZE 500,030 OF oPnl2 PIXEL FONT oObsTohoma COLOR CLR_BLACK,Rgb(192,192,192)
			@ 004, 080 MSGET oCoord 	VAR cCoord 		SIZE 040,012 OF oPnl2 PIXEL Picture "@!" F3 "SYCOOR" Valid (  Empty(cCoord) .Or. (ExistCpo("AE8",cCoord),cDescCoord:= Posicione("AE8",1,xFilial("AE8")+cCoord,"AE8_DESCRI"),oDescCoord:Refresh(),.T.) )   
			@ 005, 125 SAY   oDescCoord VAR cDescCoord  SIZE 800,030 OF oPnl2 PIXEL FONT oObsTohoma COLOR CLR_BLACK  
			
			@ 020, 005 SAY "% Reserva" 	SIZE 500,030 OF oPnl2 PIXEL FONT oObsTohoma COLOR CLR_BLACK,Rgb(192,192,192)
			@ 019, 080 MSGET oPerRes 	VAR nReserva 	SIZE 040,012 OF oPnl2 PIXEL Picture "@E99" Valid (nReserva > 0 .And. nReserva < 100,CalcReserva(@cHrContrato,@cHrReserva,@cHrDisp,@cHrCusto,@oHrContrato,@oHrReserva,@oHrDisp,@oHrCusto,@nTotPrj,@nTotRes,@nTotDisp,@nCusto,nReserva,@aModulos),oPerRes:Refresh()) 

			@ 011, 005 SAY "Seq." 			  SIZE 500,030 OF oScroll PIXEL FONT oObsTohoma COLOR CLR_BLUE 
			@ 011, 025 SAY "Modulos" 		  SIZE 500,030 OF oScroll PIXEL FONT oObsTohoma COLOR CLR_BLUE 
			@ 011, 335 SAY "Horas" 			  SIZE 100,030 OF oScroll PIXEL FONT oObsTohoma COLOR CLR_BLUE 
			@ 011, 390 SAY "Hrs. Reserva"     SIZE 100,030 OF oScroll PIXEL FONT oObsTohoma COLOR CLR_BLUE 
			@ 011, 445 SAY "Hrs. Disponiveis" SIZE 100,030 OF oScroll PIXEL FONT oObsTohoma COLOR CLR_BLUE 
		
			nTotPrj:= 0
			nTotRes:= 0
			nTotDisp:= 0
			nCusto := 0
			For K=1 to Len(aModulos)
				cSeq	:= "oSeq" + StrZero(K,2,0)
				cTextSeq:= "{||'" + aModulos[K,MOD_SEQ]+"'}"
				&cSeq	:= TSay():New(25+(K-1)*12,005,U_MontaBlock(cTextSeq),oScroll, ,oObsTohoma,,,,.T.,CLR_GRAY, ,500,30)

				cMod	:= "oMod" + StrZero(K,2,0)
				cTextMod:= "{||'" + aModulos[K,MOD_DESCRI]+"'}"
				&cMod	:= TSay():New(25+(K-1)*12,025,U_MontaBlock(cTextMod),oScroll, ,oObsTohoma,,,,.T.,CLR_GRAY, ,500,30)
	
				cHora	 := "oHora" + StrZero(K,2,0)
				cTextHora:= "{||'" + Str(Round(aModulos[K,MOD_HORAS],0),7,2)+"'}"
				&cHora   := TSay():New(25+(K-1)*12,335,U_MontaBlock(cTextHora),oScroll, ,oObsTohoma,,,,.T.,CLR_GRAY, ,500,30)
						
				cReserva := "oReserva" + StrZero(K,2,0)
				cVar	 := "nRes" + StrZero(K,2,0)
				&cVar	 := 0
				cTextRes :="{|u| If(PCount()>0, "	+  cVar + ":= u, " + cVar+ ") }"   
				&cReserva:= TGet():New (25+(k-1)*12,400,U_MontaBlock(cTextRes),oScroll,25,8,'@E 999.99',,CLR_BLACK,,oFontG,,,.T.,,,,,,,,,,cVar)  
				&cReserva:Refresh()

				cHrDisp := "oHrDisp" + StrZero(K,2,0)
				cVar	 := "nHrDisp" + StrZero(K,2,0)
				&cVar	 := 0
				cTextDisp:="{|u| If(PCount()>0, "	+  cVar + ":= u, " + cVar+ ") }"   
				&cHrDisp := TGet():New (25+(k-1)*12,460,U_MontaBlock(cTextDisp),oScroll,25,8,'@E 999.99',,CLR_BLACK,,oFontG,,,.T.,,,,,,,,,,cVar)  
				&cHrDisp:lReadOnly:= .T.
				&cHrDisp:Refresh()

			Next

			oScroll:Refresh()

			//Carrega o titulo da proposta
			cMemo:= "Informe aqui observacoes para o projeto." + Chr(10) + Chr(13) + MSMM(Z02->Z02_TITCOD)
			@ 0,0 GET oMemo VAR cMemo MEMO When .T. OF oPnl4 PIXEL FONT oObsTohoma COLOR CLR_WHITE,CLR_GRAY
			oMemo:Align := CONTROL_ALIGN_ALLCLIENT

			cHrContrato:= "Horas Contratadas: " + Transform(Round(nTotPrj,0),"@E 999,999,999") 
			@ 0, 010 SAY oHrContrato VAR cHrContrato OF oPnl5 FONT oObsTohoma COLOR CLR_BLUE Pixel SIZE 500,030
			
			cHrReserva:= "Horas Reservadas : " + Transform(Round(nTotRes,0),"@E 999,999,999")
			@ 0, 160 SAY oHrReserva VAR cHrReserva OF oPnl5 FONT oObsTohoma COLOR CLR_RED Pixel SIZE 500,030

			cHrDisp:= "Horas Disponiveis: " + Transform(Round(nTotDisp,0),"@E 999,999,999")
			@ 0, 310 SAY oHrDisp VAR cHrDisp  OF oPnl5 FONT oObsTohoma COLOR CLR_GREEN Pixel SIZE 500,030

			cHrCusto:= "Custo: " + Transform(Round(nCusto,0),"@E 999,999,999")
			@ 0, 510 SAY oHrCusto VAR cHrCusto  OF oPnl5 FONT oObsTohoma COLOR CLR_GREEN Pixel SIZE 500,030
			
			ACTIVATE MSDIALOG oDlgAprova ON INIT (EnchoiceBar( oDlgAprova , {|| Iif(Empty(cCoord) .And. Empty(cCoordDev), nOpca:=0,nOpca := 1) , oDlgAprova:End() } , {|| oDlgAprova:End() },,aButtons ),CalcReserva(@cHrContrato,@cHrReserva,@cHrDisp,@cHrCusto,@oHrContrato,@oHrReserva,@oHrDisp,@oHrCusto,@nTotPrj,@nTotRes,@nTotDisp,@nCusto,nReserva,@aModulos)) CENTERED
			
			IF nOpca <> 1   
				Help( "",1,"Atenção",,"Você cancelou a Geração do Projeto.",1,1 )
			EndIf
		Else
			nOpca:= Aviso("Atencao","Confirma a geracao do projeto?",{"Sim","Nao"}) 
		EndIf


		If nOpca == 1
			MsgRun("Gerando Projeto...","Aguarde",{|| CursorWait(), SYGERPROJ(Z02->Z02_PROPOS,Z02->Z02_ADITIV,cCoord,cMemo,aModulos,cCoordDev), CursorArrow()})
		EndIf
	EndIf
EndIF

RestArea(aArea)

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CalcReserva ºAutor  ³Fabio Rogerio    º Data ³  23/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula as horas de reserva de acordo o %aplicado nos itensº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSA04                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcReserva(cHrContrato,cHrReserva,cHrDisp,cHrCusto,oHrContrato,oHrReserva,oHrDisp,oHrCusto,nTotPrj,nTotRes,nTotDisp,nCusto,nReserva,aModulos)
Local nModulo	:= 0
Local nItem  	:= 0
Local nHoraCusto:= GetNewPar("MV_HORACUS",70) //Valor Hora Padrao
Local nResModulo:= 0
Local nHorasMod := 0
Local nHorasDisp:= 0
Local cObj      := ""
Local cVar      := ""

nTotPrj := 0
nTotRes := 0
nTotDisp:= 0
nCusto  := 0
For nModulo:= 1 To Len(aModulos)
	nResModulo:= 0
	nHorasMod := 0
	nHorasDisp:= 0
	For nItem:= 1 To Len(aModulos[nModulo,MOD_ITENS])
		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_HORAS]  := Round(aModulos[nModulo,MOD_ITENS,nItem,MOD_I_HORAS],0) 
		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_RESERVA]:= Round(aModulos[nModulo,MOD_ITENS,nItem,MOD_I_HORAS] * (nReserva/100),0) 
		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_DISP]   := aModulos[nModulo,MOD_ITENS,nItem,MOD_I_HORAS] - aModulos[nModulo,MOD_ITENS,nItem,MOD_I_RESERVA]
	
		nHorasMod += aModulos[nModulo,MOD_ITENS,nItem,MOD_I_HORAS]
		nResModulo+= aModulos[nModulo,MOD_ITENS,nItem,MOD_I_RESERVA]
		nHorasDisp+= aModulos[nModulo,MOD_ITENS,nItem,MOD_I_DISP] 
	
	Next nItem

	//Atualiza as reservas dos modulos
	aModulos[nModulo,MOD_RESERVA]   := nResModulo
	aModulos[nModulo,MOD_DISPONIVEL]:= nHorasDisp
	aModulos[nModulo,MOD_PERCRES]   := nReserva

	//Atualiza os totais da tela
	nTotPrj	  += nHorasMod
	nTotRes	  += nResModulo
	nTotDisp  += nHorasDisp
	nCusto    += Round(nHorasDisp * nHoraCusto,0)

	cVar   := "nRes" + StrZero(nModulo,2,0)
	&(cVar):= nResModulo

	cObj:= "oReserva"  + StrZero(nModulo,2,0)
	&(cObj):Refresh()

	cVar   := "nHrDisp" + StrZero(nModulo,2,0)
	&(cVar):= nHorasDisp

	cObj:= "oHrDisp"  + StrZero(nModulo,2,0)
	&(cObj):Refresh()

Next nModulo

cHrContrato:= "Horas Contratadas: " + Transform(nTotPrj,"@E 999,999,999") 
cHrReserva := "Horas Reservadas : " + Transform(nTotRes,"@E 999,999,999")
cHrDisp    := "Horas Disponiveis: " + Transform(nTotDisp,"@E 999,999,999")
cHrCusto   := "Custo Previsto   : " + Transform(nCusto,"@E 999,999,999")

oHrContrato:Refresh()
oHrReserva:Refresh()
oHrDisp:Refresh()
oHrCusto:Refresh()		

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYGERPROJ ºAutor  ³Cris Barroso        º Data ³  23/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o projeto nas tabelas padroes do PMS                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SYMPMSA04                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SYGERPROJ(cCodProp,cAditivo,cCoord,cMemo,aModulos,cCoordDev)

Local aArea	    := GetArea()
Local cRevisa   := "0001"  
Local nSaveSx8  := GetSX8Len()
Local nHorasPrj := 0
Local nHorasCor := 0
Local nHorasDev := 0
Local nHoraCorD := 0
Local nTipo     := 0
Local nFase     := 0
Local nEtapa    := 0
Local nTarefa   := 0
Local nSubMen   := 0
Local cCoordAF8 := ""
Local cDescrAF8 := ""
Local nHorasAF8 := 0
Local nCustoAF8 := 0
Local nX        := 0
Local cMay      := ""
Local cCodProj  := ""
Local aEDT      := {}
Local cEDTPai   := ""
Local nEDT      := 0
Local cEDT      := ""
Local cTarefa   := ""
Local cProjetos := ""
Local nCustoDev := 0
Local nCustoCon := 0
Local nCustoCor := 0
Local nCustoCDev:= 0
Local cMsgErro  := ""
Local cModPrjCon:= SuperGetMv("MV_MODCON",.F.,"005") //Modelo de Projeto de Consultoria
Local cTpServ   := ""
Local nCustoTrf := 0
Local nCustoPrj := 0
Local nHoraCusto:= GetNewPar("MV_HORACUS",70) //Valor Hora Padrao
Local nTrfDisp  := 0
Local nHrsDisp  := 0
Local nModulo   := 0
Local nHorasDia := GetNewPar("MV_AFHRDIA",10) //Horas por Dia
Local cProdGP   := GetNewPar("MV_AFGP","SAP-I001") //Produto do Gerente de Projeto SAP
Local cProdGPFS := GetNewPar("MV_AFGPFS","SAP-I003") //Produto do Gerente de Desenvolvimento SAP
Local nItem     := 0
Local cChaveSub := ""
Local nTotal    := 0 //Valor de Venda do Modulo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os totais de horas por projeto modelo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("Z02")
dbSetOrder(1)
dbSeek(xFilial("Z02")+cCodProp+cAditivo)
If (Z02->Z02_STATUS <> '5')
	Help( "",1,"Atencao",,"Somente é possivel gerar projeto para propostas APROVADAS.",1,1 )
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Monta a estrutura
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
For nModulo:= 1 To Len(aModulos)
	nPercRes := aModulos[nModulo,MOD_PERCRES]
	nHrsDisp := aModulos[nModulo,MOD_DISPONIVEL] 
	cTpServ  := aModulos[nModulo,MOD_TIPO]
	cDescServ:= IIF(cTpServ == '1','Projetos','FSW - Fabrica de Software')
	nTotal   := aModulos[nModulo,MOD_TOTAL]
	
	For nItem:= 1 To Len(aModulos[nModulo,MOD_ITENS])

		//Calcula as horas disponiveis de cada atividade considerando o percentual de reserva aplicado na geracao do projeto
		nTrfDisp := aModulos[nModulo,MOD_ITENS,nItem,MOD_I_DISP]
		nCustoTrf:= nTrfDisp * nHoraCusto
	
		//Soma as horas e custo do projetos
		nHorasPrj+= nTrfDisp
		nCustoPrj+= nCustoTrf

		//Se for atividade de projeto considera o SubMenu como agrupador, se for desenvolvimento considera a customizacao como agrupador
		If (cTpServ == "1")
			cChaveSub:= aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ETAPA] 
		Else
			cChaveSub:= AllTrim(aModulos[nModulo,MOD_MODULO]) + ' - ' + AllTrim(aModulos[nModulo,MOD_DESCRI])
		EndIf	

		//Verifica qual o tipo de projeto é o modulo (Consultoria ou Desenvolvimento)
		nTipo:= aScan(aEDT,{|x| x[EDT_TIPO] == cTpServ }) 
		If (nTipo == 0)
			//Tipo 1- Projeto, 2-FSW
			aAdd(aEDT,{cTpServ,	cDescServ, nTrfDisp,0,;
													{{	aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_DESCFASE],;
														nTrfDisp,;
														nCustoTrf,;
														{{	cChaveSub,;
															nTrfDisp,;
															nCustoTrf,;
															{{	aModulos[nModulo,MOD_SEQ],;
																aModulos[nModulo,MOD_MODULO],;
																aModulos[nModulo,MOD_DESCRI],;
																nHrsDisp,;
																aModulos[nModulo,MOD_ID],;
																aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
																aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ORDEM],;
																aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ETAPA],;
																aModulos[nModulo,MOD_ITENS,nItem,MOD_I_PROCESSO],;
																nTrfDisp,;
																aModulos[nModulo,MOD_ID],;
																aModulos[nModulo,MOD_ITENS,nItem,MOD_I_NITEM],;
																nCustoTrf	} }}}}}})
		Else

			//Verifica se ja existe a Fase da MIA
			aEDT[nTipo,EDT_HRSTP]+= nTrfDisp
			nFase:= aScan(aEDT[nTipo,EDT_FASES],{|x| x[EDT_CODFASE] == aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE] })
			If (nFase == 0)
				aAdd(aEDT[nTipo,EDT_FASES],{	aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
												aModulos[nModulo,MOD_ITENS,nItem,MOD_I_DESCFASE],;
												nTrfDisp,;
												nCustoTrf,;
												{{	cChaveSub,;
													nTrfDisp,;
													nCustoTrf,;
													{{	aModulos[nModulo,MOD_SEQ],;
														aModulos[nModulo,MOD_MODULO],;
														aModulos[nModulo,MOD_DESCRI],;
														nHrsDisp,;
														aModulos[nModulo,MOD_ID],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ORDEM],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ETAPA],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_PROCESSO],;
														nTrfDisp,;
														aModulos[nModulo,MOD_ID],;
														aModulos[nModulo,MOD_ITENS,nItem,MOD_I_NITEM],;
														nCustoTrf	} }}}})
			Else

				//Verifica se ja existe a Etapa do Modulo
				aEDT[nTipo,EDT_FASES,nFase,EDT_HORAS]+= nTrfDisp
				aEDT[nTipo,EDT_FASES,nFase,EDT_CUSTO]+= nCustoTrf
	
				nSubMen:= aScan(aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY],{|x| x[EDT_SUBMEN] == cChaveSub })
				If (nSubMen == 0)
					aAdd(aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY],{ cChaveSub,;
																	nTrfDisp,;
																	nCustoTrf,;
																	{{	aModulos[nModulo,MOD_SEQ],;
																		aModulos[nModulo,MOD_MODULO],;
																		aModulos[nModulo,MOD_DESCRI],;
																		nHrsDisp,;
																		aModulos[nModulo,MOD_ID],;
																		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
																		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ORDEM],;
																		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ETAPA],;
																		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_PROCESSO],;
																		nTrfDisp,;
																		aModulos[nModulo,MOD_ID],;
																		aModulos[nModulo,MOD_ITENS,nItem,MOD_I_NITEM],;
																		nCustoTrf	}}} )
				Else

					//Verifica se ja existe a Tarefa
					aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBHORAS]+= nTrfDisp
					aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBCUSTO]+= nCustoTrf
					nTarefa:= aScan(aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS],{|x| x[TRF_ID]+x[TRF_NITEM] == aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ID]+aModulos[nModulo,MOD_ITENS,nItem,MOD_I_NITEM] })
					If (nTarefa == 0)
						aAdd(aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS],{ aModulos[nModulo,MOD_SEQ],;
																							aModulos[nModulo,MOD_MODULO],;
																							aModulos[nModulo,MOD_DESCRI],;
																							nHrsDisp,;
																							aModulos[nModulo,MOD_ID],;
																							aModulos[nModulo,MOD_ITENS,nItem,MOD_I_FASE],;
																							aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ORDEM],;
																							aModulos[nModulo,MOD_ITENS,nItem,MOD_I_ETAPA],;
																							aModulos[nModulo,MOD_ITENS,nItem,MOD_I_PROCESSO],;
																							nTrfDisp,;
																							aModulos[nModulo,MOD_ID],;
																							aModulos[nModulo,MOD_ITENS,nItem,MOD_I_NITEM],;
																							nCustoTrf	} )
					Else
						aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_HORAS]+= nTrfDisp
						aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_CUSTO]+= nCustoTrf
					EndIf
				
					//Ordena as Tarefas
					aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS]:= aSort( aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS] , , , { |x,y| x[TRF_ID]+x[TRF_NITEM]+x[TRF_ORDEM] < y[TRF_ID]+y[TRF_NITEM]+y[TRF_ORDEM] } )

				EndIf
			
				//Ordena as Etapas
				aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY]:= aSort( aEDT[nTipo,EDT_FASES,nFase,EDT_SUBARRAY]  , , , { |x,y| x[EDT_SUBMEN] < y[EDT_SUBMEN] } )

			EndIf
			
			//Ordena as Fases
			aEDT[nTipo,EDT_FASES]:= aSort( aEDT[nTipo,EDT_FASES]  , , , { |x,y| x[EDT_CODFASE] < y[EDT_CODFASE] } )
		EndIf
	Next nItem

	//Soma a receita do modulo 
	nTipo:= aScan(aEDT,{|x| x[EDT_TIPO] == cTpServ }) 
	If (nTipo > 0)
		aEDT[nTipo,EDT_TOTAL]+= nTotal
	EndIf

Next nModulo

//Se existe itens gera o projeto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a Gravação dos Projetos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aEDT) > 0
	Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria o projeto com base na proposta.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("Z02")
		dbSetOrder(1)
		dbSeek(xFilial("Z02")+cCodProp)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega a numeracao do projeto                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("AF8")
		cCodProj := GetSXENum("AF8","AF8_PROJET")
		cMay := "AF8"+AllTrim( xFilial("AF8") )+cCodProj
		FreeUsedCode()
		dbSetOrder(1)                                      
		While dbSeek(xFilial("AF8")+cCodProj) .Or. !MayIUseCode(cMay+cCodProj)
			While (GetSX8Len() > nSaveSx8)
				ConfirmSx8()
			End
	
			cCodProj := GetSXENum("AF8","AF8_PROJET")
			FreeUsedCode()
			cMay := "AF8"+Alltrim(xFilial(""))+cCodProj
		EndDo
		ConfirmSx8()
		cProjetos:= cCodProj
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava dados do projeto.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("AF8", .T.)                     
		For nX := 1 To FCount()
			FieldPut(nX, CriaVar(FieldName(nX), .T.) )
		Next nI
		Replace AF8_FILIAL With xFilial("AF8")
		Replace AF8_PROJET With cCodProj
		Replace AF8_DATA   With dDataBase
		Replace AF8_DESCRI With Z02->Z02_DESCRI
		Replace AF8_CLIENT With Z02->Z02_CLIENT 
		Replace AF8_LOJA   With Z02->Z02_LOJA
		Replace AF8_REVISA With cRevisa
		Replace AF8_CALEND With "001"
		Replace AF8_PROPOS With Z02->Z02_PROPOS
		Replace AF8_ADITIV With Z02->Z02_ADITIV
		Replace AF8_FASE   With "01"
		Replace AF8_PRJREV With "1"
		Replace AF8_CTRUSR With "2"
		Replace AF8_NMAX   With 999
		Replace AF8_NMAXF3 With 999
		Replace AF8_HORAS  With Round(nHorasPrj,0)
		Replace AF8_COORD  With cCoord
		Replace AF8_TPHORA With "01" //Horas Faturaveis
		Replace AF8_GETTRF With "AUDITADO"
		Replace AF8_CUSTO  With Round(nHorasPrj,0) * nHoraCusto
		Replace AF8_RECEIT With Z02->Z02_VLRLIQ
		MsUnLock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava observacao e detalhes do projeto.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MSMM(,TamSx3("AF8_OBS")[1],,cMemo,1,,,"AF8","AF8_CODMEM")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cadastra a EDT Nivel 001 do Projeto.(Dados do Proprio Projeto)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cEDT   := "00"
		cEDTPai:= ""
		RecLock("AFC", .T.)                    
		For nX := 1 To FCount()
			FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
		Next nX				

		AFC_FILIAL := xFilial("AFC")
		AFC_PROJET := cCodProj
		AFC_REVISA := cRevisa
		AFC_EDT    := cEDT
		AFC_NIVEL  := "001"
		AFC_DESCRI := Z02->Z02_DESCRI
		AFC_QUANT  := 1
		AFC_CALEND := "001"
		AFC_START  := dDataBase
		AFC_FINISH := dDataBase
		AFC_EDTPAI := cEDTPai
		AFC_HUTEIS := Round(nHorasPrj,0)
		AFC_HDURAC := Round(nHorasPrj,0)
		AFC_CUSTO  := Round(nHorasPrj,0) * nHoraCusto
		AFC_TOTAL  := Z02->Z02_VLRLIQ
		MsUnLock()                         

		//Gera as EDTs do Projeto
		For nEDT:= 1 To Len(aEDT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cadastra a EDT do Projeto.
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEDT   := StrZero(nEDT,2)
			cEDTPai:= "00"
			RecLock("AFC", .T.)                    
			For nX := 1 To FCount()
				FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
			Next nX				

			AFC_FILIAL := xFilial("AFC")
			AFC_PROJET := cCodProj
			AFC_REVISA := cRevisa
			AFC_EDT    := cEDT
			AFC_NIVEL  := "002"
			AFC_DESCRI := aEDT[nEDT,EDT_DSCTP]
			AFC_QUANT  := 1
			AFC_CALEND := "001"
			AFC_START  := dDataBase
			AFC_FINISH := dDataBase
			AFC_EDTPAI := cEDTPai
			AFC_HUTEIS := Round(aEDT[nEDT,EDT_HRSTP],0)
			AFC_HDURAC := Round(aEDT[nEDT,EDT_HRSTP],0)
			AFC_CUSTO  := Round(aEDT[nEDT,EDT_HRSTP],0) * nHoraCusto
			AFC_TOTAL  := aEDT[nEDT,EDT_TOTAL]
			MsUnLock()                         

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cadastra a EDT Nivel 003.(Dados das Fases do Projeto)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cEDTPai:= cEDT
			For nFase:= 1 To Len(aEDT[nEDT,EDT_FASES])

				cEDT  := cEDTPai + "." + StrZero(nFase,2)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cadastra a EDT da FASE.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("AFC", .T.)                    
				For nX := 1 To FCount()
					FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
				Next nX				

				AFC_FILIAL := xFilial("AFC")
				AFC_PROJET := cCodProj
				AFC_REVISA := cRevisa
				AFC_EDT    := cEDT
				AFC_NIVEL  := "003"
				AFC_DESCRI := aEDT[nEDT,EDT_FASES,nFase,EDT_DESCRI]
				AFC_QUANT  := 1
				AFC_CALEND := "001"
				AFC_START  := dDataBase
				AFC_FINISH := dDataBase
				AFC_EDTPAI := cEDTPai
				AFC_HUTEIS := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_HORAS],0)
				AFC_HDURAC := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_HORAS],0)
				AFC_CUSTO  := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_HORAS],0) * nHoraCusto
				MsUnLock()                         

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cadastra a EDT Nivel 004 do Projeto.(Submenu das Fases do Projeto)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEDTPaiSub:= cEDT
				For nSubMen:= 1 To Len(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY])

					cEDT  := cEDTPaiSub + "." + StrZero(nSubMen,2)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cadastra a EDT do SubMenu.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					RecLock("AFC", .T.)                    
					For nX := 1 To FCount()
						FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
					Next nX				

					AFC_FILIAL := xFilial("AFC")
					AFC_PROJET := cCodProj
					AFC_REVISA := cRevisa
					AFC_EDT    := cEDT
					AFC_NIVEL  := "004"
					AFC_DESCRI := aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBMEN]
					AFC_QUANT  := 1
					AFC_CALEND := "001"
					AFC_START  := dDataBase
					AFC_FINISH := dDataBase
					AFC_EDTPAI := cEDTPaiSub
					AFC_HUTEIS := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBHORAS],0)
					AFC_HDURAC := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBHORAS],0)
					AFC_CUSTO  := Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_SUBHORAS],0) * nHoraCusto
					MsUnLock()                         

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cria as TAREFAS do PROCESSO na EDT DO PROCESSO.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cTarefa:= "00"
					For nTarefa:= 1 To Len(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS])
						cTarefa:= Soma1(cTarefa,2)

						RecLock("AF9", .T.)
						For nX := 1 To FCount()
							FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
						Next nX

						Replace AF9_FILIAL With xFilial("AF9")
						Replace AF9_PROJET With cCodProj
						Replace AF9_REVISA With cRevisa        
						Replace AF9_TAREFA With cEDT + "." + cTarefa
						Replace AF9_NIVEL  With "005"
						Replace AF9_DESCRI With aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_PROCES]
						Replace AF9_QUANT  With 1
						Replace AF9_HDURAC With Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_HORAS],0)
						Replace AF9_CALEND With "001"
						Replace AF9_START  With dDataBase
						Replace AF9_FINISH With dDataBase
						Replace AF9_HUTEIS With Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_HORAS],0)
						Replace AF9_CUSTO  With Round(aEDT[nEDT,EDT_FASES,nFase,EDT_SUBARRAY,nSubMen,EDT_TAREFAS,nTarefa,TRF_HORAS],0) * nHoraCusto
						Replace AF9_FATURA With "1"
						Replace AF9_EDTPAI With cEDT
						Replace AF9_FASE   With "01"
						MsUnLock()				
					Next nTarefa
				Next nSubMen
			Next nFase
		Next nEDT
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Integração com o ARTIA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_XENVART",.T.) 
		cTpServ := aEDT[nEDT,EDT_TIPO]
		nOpcGrp := U_XGRPART(cTpServ, Z02->Z02_TIPO) // Consultoria/Serviço

		If nOpcGrp > 0
			lRetorno := .F.
			FwMsgRun( ,{|| lRetorno := U_ART01ENV(cCodProj, nOpcGrp, @cMsgErro,cTpServ) }, , "Por favor, aguarde. Enviando projeto ao ARTIA..." )

			If lRetorno
				Help(Nil,Nil,ProcName(),,"Projeto integrado com sucesso: " + cCodProj, 1, 5)
			Else
				Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Envia e-mail para PMO avisando sobre cadastro de novo projeto
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + AF8->AF8_CLIENT + AF8->AF8_LOJA))

	cAssunto  	:= "Novo Projeto [" + Right(AF8->AF8_PROJET,6) + " - " + AllTrim(AF8->AF8_DESCRI) + "] Cliente: " + AF8->AF8_CLIENT + "/" + AF8->AF8_LOJA + " - " + AllTrim(SA1->A1_NOME)
	cMensagem 	:= MsgMail(cMemo)
	aPara 		:= {}

	aAdd( aPara , 'servicos@alfaerp.com.br')
	aAdd( aPara , 'fabio.pereira@alfaerp.com.br' )
	aAdd( aPara , 'alexandro.dias@alfaerp.com.br' )
	aAdd( aPara , GetMV("MV_MAILGER") )

	LjMsgRun("Aguarde, enviando projeto para Coordenação...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cMensagem,.F.,'') } )

EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Atualiza projeto na proposta
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("Z02")
dbSetOrder(1)
dbSeek(xFilial("Z02")+cCodProp+cAditivo)
RecLock("Z02",.F.)
Replace Z02_PROJET With cProjetos
Replace Z02_STATUS With '9'
MSUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Atualiza projeto nos titulos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
DbOrderNickName("E1PROPOS")
dbSeek(xFilial("SE1")+cCodProp+cAditivo)
While !Eof() .And. (xFilial("SE1")+cCodProp+cAditivo == SE1->E1_FILIAL+SE1->E1_PROPOS+SE1->E1_ADITIV)
	RecLock("SE1",.F.)
	Replace E1_PROJ With cProjetos
	MSUnlock()
    
	dbSelectArea("SE1")
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Se deu certo aviso dos projetos gerados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cProjetos)
	Aviso("Atencao","Os projetos " + cProjetos + " foram gerados com sucesso!",{"Ok"})
EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MsgMail   ºAutor  ³Fabio Rogerio       º Data ³  05/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MsgMail(cMemo)

Local cMensagem:= ""

cMensagem 	+= '<HTML>  '
cMensagem 	+= '	<HEAD>  '
cMensagem 	+= '		<TITLE></TITLE>   '
cMensagem 	+= '		<STYLE>   '
cMensagem 	+= '			BODY {FONT-FAMILY: 	Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}   '
cMensagem 	+= '			DIV {FONT-FAMILY: 	Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}   '
cMensagem 	+= '			TABLE {FONT-FAMILY: 	Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}   '
cMensagem 	+= '			TD {FONT-FAMILY: 	Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}   '
cMensagem 	+= '			.Mini {FONT-FAMILY: 	Arial, Helvetica, sans-serif; FONT-SIZE: 10px}   '
cMensagem 	+= '			FORM {MARGIN: 0px}   '
cMensagem 	+= '			 .S_A  {FONT-SIZE: 28px; VERTICAL-ALIGN: top; WIDTH: 100%; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: center}  '
cMensagem 	+= '			 .S_B  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF99; TEXT-ALIGN: left}   '
cMensagem 	+= '			 .S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left}   '
cMensagem 	+= '			 .S_D  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left}   '
cMensagem 	+= '			 .S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 05% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
cMensagem 	+= '		</STYLE>   '
cMensagem 	+= '	</HEAD>   '
cMensagem 	+= '	<BODY>   '
cMensagem 	+= '		<TABLE style="COLOR: rgb(0,0,0)" width="100%" border=1>   '
cMensagem 	+= '			<TBODY>   '
cMensagem 	+= '				<TR>   '
cMensagem 	+= '					<TD CLASS=S_A width="100%"><P align=center><B>CADASTRO DE NOVO PROJETO</B></P></TD>   '
cMensagem 	+= '				</TR>   '
cMensagem 	+= '			</TBODY>   '
cMensagem 	+= '		</TABLE>   '
cMensagem 	+= '		<DIV align=center>&nbsp;</DIV>  '
cMensagem 	+= '		<TABLE width="100%" border=0>  '
cMensagem 	+= '			<TBODY>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD CLASS=S_O><P align=left><B>PMO,</B></P></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD CLASS=S_O><P align=left><B>Foi gerado um novo projeto associado à proposta ' + AF8->AF8_PROPOS + '/' + AF8->AF8_ADITIV +'. </B></P></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD CLASS=S_O><P align=left><B>Favor completar os dados do projeto, designar e alinhar com o coordenador. </B></P></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '			</TBODY>  '
cMensagem 	+= '		</TABLE>  '
cMensagem 	+= '		<TABLE style="WIDTH: 100%; HEIGHT: 26px" cellSpacing=0 border=1>  '
cMensagem 	+= '			<TBODY>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 15%"><B>PROPOSTA</B></TD> '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 85%"><B>'+AF8->AF8_PROPOS+'/'+AF8->AF8_ADITIV+'</B></TD> '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 15%"><B>CLIENTE</B></TD>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 85%"><B>'+SA1->A1_COD+"/"+SA1->A1_LOJA+'-'+SA1->A1_NOME+'</B></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 15%"><B>PROJETO</B></TD>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 85%"><B>'+AF8->AF8_PROJET+' - '+AF8->AF8_DESCRI+'</B></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_B style="WIDTH: 15%"><B>HORAS</B></TD>  '
cMensagem 	+= '					<TD class=S_B style="WIDTH: 85%"><B>'+Transform(AF8->AF8_HORAS,PesqPict("AF8","AF8_HORAS"))+'</B></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 15%"><B>COORDENADOR INDICADO</B></TD>  '
cMensagem 	+= '					<TD class=S_D style="WIDTH: 85%"><B>'+Posicione("AE8",1,xFilial("AE8")+AF8->AF8_COORD,"AE8_DESCRI")+'</B></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=S_B style="WIDTH: 15%"><B>OBSERVAÇÕES</B></TD>  '
cMensagem 	+= '					<TD class=S_B style="WIDTH: 85%"><B>'+cMemo+'</B></TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '			</TBODY>  '
cMensagem 	+= '		</TABLE>  '
cMensagem 	+= '		<TABLE width="100%" border=0>  '
cMensagem 	+= '			<TBODY>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD class=Mini></TD></TR>  '
cMensagem 	+= '				<TR>  '
cMensagem 	+= '					<TD CLASS=Mini>WorkFlow Powered by ALFA Sistemas [ www.alfaerp.com.br ]</TD>  '
cMensagem 	+= '				</TR>  '
cMensagem 	+= '			</TBODY>  '
cMensagem 	+= '		</TABLE>  '
cMensagem 	+= '	</BODY>  '
cMensagem 	+= '</HTML> '

Return(cMensagem)       



user Function MontaBlock( cBlock )
Return (&cBlock)

//-------------------------------------------------------------------
/*/{Protheus.doc} XGRPART
Rotina de conexão com as API's do ARTIA.
@type function
@author  Wilson A. Silva Jr
@since   19/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function XGRPART(cTpServ, cTipo)

Local nOpcGrp := 0

DO CASE
	CASE cTpServ == "1" .And. Z02->Z02_TIPO $ "5,7" // GRUPO_SAP_DELIVERY
		nOpcGrp := 1
	CASE cTpServ == "2" .And. Z02->Z02_TIPO $ "5,7" // GRUPO_SAP_FABRICA
		nOpcGrp := 2
	CASE cTpServ == "1" .And. Z02->Z02_TIPO $ "0,1" // GRUPO_TOTVS_DELIVERY
		nOpcGrp := 3
	CASE cTpServ == "2" .And. Z02->Z02_TIPO $ "0,1" // GRUPO_TOTVS_FABRICA
		nOpcGrp := 4
	OTHERWISE
		nOpcGrp := 0
ENDCASE

Return nOpcGrp
