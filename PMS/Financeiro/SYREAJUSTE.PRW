#Include "Protheus.ch"

#DEFINE		LOK				1
#DEFINE		ATUALIZADO		2
#DEFINE		ULTFAT			3
#DEFINE		CODIGO			4
#DEFINE		RAZAO			5
#DEFINE		FANTASIA		6
#DEFINE		FATTOTAL		7
#DEFINE		CONSULTORATU	8
#DEFINE		CONSULTORNEW	9
#DEFINE		COORDENADORATU	10
#DEFINE		COORDENADORNEW	11
#DEFINE		PERCREAJUSTE	12
#DEFINE		ULTREAJUSTE		13
#DEFINE		IMPOSTOS		14

#DEFINE		TIT_LOK			1
#DEFINE		TIT_ATU  		2
#DEFINE		TIT_CODIGO		3
#DEFINE		TIT_RAZAO		4
#DEFINE		TIT_CONTRATO	5
#DEFINE		TIT_ADITIVO		6
#DEFINE		TIT_PREFIXO		7
#DEFINE		TIT_NUM			8
#DEFINE		TIT_PARCELA		9
#DEFINE		TIT_TIPO		10
#DEFINE		TIT_VENCREA		11
#DEFINE		TIT_VALORANT	12
#DEFINE		TIT_PERC		13
#DEFINE		TIT_ACRESCIMO	14
#DEFINE		TIT_VALORNEW	15
#DEFINE		TIT_DTREAJ		16
#DEFINE		TIT_HISTORICO	17
#DEFINE		TIT_NATUREZA	18
#DEFINE		TIT_INDICE	    19

#DEFINE		MNT_LOK				1
#DEFINE	    MNT_ATUALIZADO		2
#DEFINE		MNT_ULTREAJ			3
#DEFINE		MNT_CODIGO			4
#DEFINE		MNT_NOME			5
#DEFINE		MNT_PROPOSTA		6
#DEFINE		MNT_ADITIVO			7
#DEFINE		MNT_HISTORICO		8
#DEFINE		MNT_INDICE			9
#DEFINE		MNT_PERCREAJUSTE	10
#DEFINE		MNT_FATOR			11
#DEFINE		MNT_VLRMANUTATU		12
#DEFINE		MNT_VLRMANUTNEW		13

#DEFINE		RJ_PERIODO	1
#DEFINE		RJ_INDICE	2
#DEFINE		RJ_PERC		3
#DEFINE		RJ_FATOR	4
#DEFINE		RJ_CONATUAL	5
#DEFINE		RJ_CORATUAL	6
#DEFINE		RJ_CONANT	7
#DEFINE		RJ_CORANT	8
#DEFINE		RJ_DATA		9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SYReajuste  ³Autor  ³ Fabio Rogerio   ³ Data ³  05/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reajuste de Valores.                            			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyReajuste()

Local aParamBox			:= {} 
Local aRetParam			:= {}
Local cPeriodo 			:= StrZero(Year(dDatabase),4)+StrZero(Month(dDatabase),2)

//Verifica se existe percentual cadastrado para o periodo
DbSelectArea("Z19")
DbSetOrder(2)
If !DbSeek(xFilial("Z19")+cPeriodo,.T.)
	Aviso("Atencao","Nao existe nenhum indice de reajuste cadastrado para o periodo " + cPeriodo,{"Ok"})
	Return(.F.)
EndIf	

aAdd(aParamBox,{2,"Tipo","1"		   				  ,{"1-Reajuste Valor Hora","2-Reajuste Parcelas Mensais","3-Estorno de Reajuste de Parcelas","4-Gera Manutencao Anual OnPremise"}	,100,"",.F.})  
Aadd(aParamBox,{1,"Cliente De"	, CriaVar("E1_CLIENTE", .F.), PesqPict("SE1", "E1_CLIENTE") , "", "SA1", "", 50 , .F.})
Aadd(aParamBox,{1,"Cliente Ate"	, CriaVar("E1_CLIENTE", .F.), PesqPict("SE1", "E1_CLIENTE") , "", "SA1", "", 50 , .F.})
Aadd(aParamBox,{1,"Data Limite"	, LastDay(dDatabase-90), PesqPict("SE1", "E1_VENCREA") , "", "", "", 50 , .F.})
aAdd(aParamBox,{2,"Exibe Atualizados?","2"		   				  ,{"1-Sim","2-Nao"}	,100,"",.F.})  
Aadd(aParamBox,{1,"Valor Minimo", 190, "@E 9999.99" , "Mv_Par06 >= 0", "", "", 50 , .T.})


IF !ParamBox(aParamBox,"Informe o Tipo de Reajuste",@aRetParam)
	Return
Endif

If Left(aRetParam[1],1) == "2"

	U_SyTitReajuste(aRetParam[2],aRetParam[3],cPeriodo,aRetParam)

ElseIf Left(aRetParam[1],1) == "1"

	U_SyHoraReajuste(aRetParam[2],aRetParam[3],cPeriodo)

ElseIf Left(aRetParam[1],1) == "3"

	U_SyEstornoTit(aRetParam[2],aRetParam[3],cPeriodo,aRetParam)

ElseIf Left(aRetParam[1],1) == "4"

	SyGeraManutencao(aRetParam[2],aRetParam[3],cPeriodo,aRetParam)
	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyHoraReajuste³ Auto  ³ Fabio Rogerio   ³ Data ³  05/02/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reajuste do Valor Hora de Cadastro.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyHoraReajuste(cCLienteDe,cClienteAte,cPeriodo)

Local oDlg,oPnlCli, oClientes
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oAtualizado  		:= LoadBitmap(GetResources(), "BR_VERMELHO" )
Local oNaoAtualizado 	:= LoadBitmap(GetResources(), "BR_VERDE" )
Local aSize    			:= MsAdvSize()
Local cMesAnoAtu 		:= '01' + StrZero(Year(dDataBase),4)
Local aClientes    		:= {}                               
Local aParambox    		:= {}
Local aRetParam   	 	:= {}
Local nOpcao       		:= 0
Local nConsultAtuVlr  	:= 0
Local nConsultNewVlr  	:= 0
Local nCoordAtuVlr  	:= 0
Local nCoordNewVlr  	:= 0
Local lAtualizado		:= 0
Local nIndiceReajuste 	:= 0
Local nFator		 	:= 0
Local cIndice           := "IPCA"

Local aCampos 			:= {'',;
							'Atualizado?',;
							'Dt.Ult.Fat',;
							'Codigo',;							
							'Razao',;
							'Fantasia',;
							'Faturamento Total (Historico)',;
							'Valor Hora Atual (Consultor) ',;
							'Valor Hora Reajustado (Consultor)',;
							'Valor Hora Atual (Coordenador)',;
							'Valor Hora Reajustado (Coordenador)',;
							'% de Reajuste',;
							'Dt.Ultimo Reajuste',;
							'Impostos'}

Local bLine     		:= {|| {	IIf(aClientes[oClientes:nAt,LOK],oOk,oNo) ,; 
									IIf(aClientes[oClientes:nAt,ATUALIZADO],oAtualizado,oNaoAtualizado) ,;
									aClientes[oClientes:nAt,ULTFAT],;
									aClientes[oClientes:nAt,CODIGO],;
									aClientes[oClientes:nAt,RAZAO],;
									aClientes[oClientes:nAt,FANTASIA],;							
									Transform(aClientes[oClientes:nAt,FATTOTAL]		,"@E 99,999,999.99"),;
									Transform(aClientes[oClientes:nAt,CONSULTORATU]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,CONSULTORNEW]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,COORDENADORATU]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,COORDENADORNEW]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,PERCREAJUSTE]	,"@E 9,999.99"),;
									aClientes[oClientes:nAt,ULTREAJUSTE],;       
									Transform(aClientes[oClientes:nAt,IMPOSTOS]	,"@E 99.99999") }}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma o indice em Fator. 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndiceReajuste := U_IndiceReajuste(cIndice,cPeriodo)
nFator          := 1 + ( nIndiceReajuste / 100 )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizado Ultima Compra e Total Faturado. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AtuValores()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o List de Clientes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSetOrder(1)
DbGotop()

While !Eof()

		lAtualizado := .F.
		
		IF ( cMesAnoAtu == ( StrZero(Month(SA1->A1_DTVALID),2) + StrZero(Year(SA1->A1_DTVALID),4) ) )
			lAtualizado := .T.
		EndIF
		
		IF lAtualizado
			
			nConsultAtuVlr  := SA1->A1_VLCONAN		// Preco Anterior
			nConsultNewVlr	:= SA1->A1_HORACON 		// Novo Preco

			nCoordAtuVlr  	:= SA1->A1_VLCORAN		// Preco Anterior
			nCoordNewVlr	:= SA1->A1_HORACOR 		// Novo Preco
		
		Else

			IF nIndiceReajuste > 0

				//nConsultAtuVlr	:= SA1->A1_HORACON
				nConsultAtuVlr	:= IIf(SA1->A1_ULTCOM < (dDatabase - 180),Mv_Par06,SA1->A1_HORACON)
				nConsultNewVlr	:= Round( nConsultAtuVlr * nFator , 2) 
				
				nCoordAtuVlr	:= IIf(SA1->A1_ULTCOM < (dDatabase - 180),Mv_Par06,SA1->A1_HORACOR)
				nCoordNewVlr	:= Round( nCoordAtuVlr * nFator , 2 )

			Else
				
				nConsultAtuVlr	:= SA1->A1_VLCONAN
				nConsultNewVlr	:= SA1->A1_HORACON
				
				nCoordAtuVlr	:= SA1->A1_VLCORAN
				nCoordNewVlr	:= SA1->A1_HORACOR

			EndIF
		
		EndIF
		
		Aadd(aClientes,{ .T. ,; 
		lAtualizado,;
		SA1->A1_ULTCOM ,;
		SA1->A1_COD+SA1->A1_LOJA,;
		SA1->A1_NOME,;
		SA1->A1_NREDUZ,;
		SA1->A1_MCOMPRA,;
		nConsultAtuVlr,;
		nConsultNewVlr,;
		nCoordAtuVlr,;
		nCoordNewVlr,;
		nIndiceReajuste,;
		SA1->A1_DTVALID,;
		SA1->A1_IMPOSTO})

	DbSelectArea("SA1")
	DbSkip()

EndDo

aSort( aClientes , , , { |x,y| x[FATTOTAL] > y[FATTOTAL] } )

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5] TITLE "Reajuste de Valor Hora de Clientes" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlCli:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlCli:Align:= CONTROL_ALIGN_ALLCLIENT

oClientes				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oClientes:Align     	:= CONTROL_ALIGN_ALLCLIENT
oClientes:lColDrag		:= .T.
oClientes:SetArray(aClientes)
oClientes:bLine 		:= {|| Eval(bLine) }
oClientes:bHeaderClick	:= { |oObj,nCol| SyOrdena(nCol,@oClientes,@aClientes,@nlOrdemCols) }
oClientes:bLDblClick 	:= { || EditaCelula(@oClientes,@aClientes,nIndiceReajuste,nFator)}
oClientes:cToolTip		:= "Dê um duplo clique para Editar os valores."

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GravaReajuste(aClientes,cPeriodo,nIndiceReajuste,nFator,cIndice) } , "Atualizando Clientes" )
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SyTitReajuste ³ Auto  ³ Fabio Rogerio   ³ Data ³  05/02/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reajuste dos Titulos.			                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyTitReajuste(cClienteDe,cClienteAte,cPeriodo,aRetParam)

Local oDlg,oPnlTit, oTitulos
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oNaoAtualizado  	:= LoadBitmap(GetResources(), "BR_VERDE" )
Local oAtualizado 	    := LoadBitmap(GetResources(), "BR_VERMELHO" )
Local aSize    			:= MsAdvSize()
Local cMesAnoAtu 		:= '01' + StrZero(Year(dDataBase),4)
Local aTitulos    		:= {}                               
Local nOpcao       		:= 0
Local nVlrAtu		  	:= 0
Local nVlrNew		  	:= 0
Local lAtualizado		:= .F.
Local nIndiceReajuste 	:= 0
Local nFator            := 0

Local aCampos 			:= {'',;
							'',;
							'Cliente',;
							'Nome',;
							'Contrato',;
							'Aditivo',;
							'Prefixo',;
							'Titulo',;
							'Parcela',;
							'Tipo',;
							'Dt.Vencto',;
							'Valor(Anterior)',;
							'% Reajuste',;
							'Acrescimo',;
							'Valor(Novo)',;
							'Data Reajuste',;
							'Historico',;
							'Natureza',;
							'Nome Indice'}

Local bLine     		:= {|| {	IIf(aTitulos[oTitulos:nAt,TIT_LOK],oOk,oNo) ,; 
									IIf(aTitulos[oTitulos:nAt,TIT_ATU],oAtualizado,oNaoAtualizado),;
									aTitulos[oTitulos:nAt,TIT_CODIGO],;
									aTitulos[oTitulos:nAt,TIT_RAZAO],;
									aTitulos[oTitulos:nAt,TIT_CONTRATO],;
									aTitulos[oTitulos:nAt,TIT_ADITIVO],;
									aTitulos[oTitulos:nAt,TIT_PREFIXO],;
									aTitulos[oTitulos:nAt,TIT_NUM],;
									aTitulos[oTitulos:nAt,TIT_PARCELA],;
									aTitulos[oTitulos:nAt,TIT_TIPO],;
									Dtoc(aTitulos[oTitulos:nAt,TIT_VENCREA]),;
									Transform(aTitulos[oTitulos:nAt,TIT_VALORANT]	,"@E 999,999.99"),;
									Transform(aTitulos[oTitulos:nAt,TIT_PERC]		,"@E 999.999999"),;
									Transform(aTitulos[oTitulos:nAt,TIT_ACRESCIMO]	,"@E 999,999.99"),;
									Transform(aTitulos[oTitulos:nAt,TIT_VALORNEW]	,"@E 999,999.99"),;
									Dtoc(aTitulos[oTitulos:nAt,TIT_DTREAJ]),;
									Left(aTitulos[oTitulos:nAt,TIT_HISTORICO],100),;
									aTitulos[oTitulos:nAt,TIT_NATUREZA],;
									aTitulos[oTitulos:nAt,TIT_INDICE] }}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os Titulos.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cClienteDe := aRetParam[2]
cClienteAte:= IIf(Empty(aRetParam[3]),"ZZZZZZ",aRetParam[3])
dVenctoAte := aRetParam[4]
lExibeAtualizados:= IIF(Left(aRetParam[5],1) == "1",.T.,.F.)

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_XTPPARC IN ('4','5') "
cQuery += " AND E1_XTIPO IN ('2','3','4','6','8') "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_CLIENTE BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "'"
cQuery += " AND E1_EMISSAO <= '" + Dtos(dVenctoAte) + "'" 
//cQuery += " AND (E1_XDTINIR = '' OR E1_XDTINIR <= '" + Dtos(dDatabase) + "' )"
cQuery += " AND E1_PORTADO <> '999'"   //Juridico
cQuery += " AND RIGHT(E1_TIPO,1) <> '-'"
cQuery += " AND D_E_L_E_T_ =  ' ' "
cQuery += " ORDER BY E1_NOMCLI,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCREA "
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "E1_XDTREAJ", "D" , 8 , 0 )
TcSetField("TMP", "E1_VENCREA", "D" , 8 , 0 )

ProcRegua(TMP->(RecCount()))

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	IncProc('Calculando Reajuste')
	
	lAtualizado := .F.
		
	IF ( cMesAnoAtu == ( StrZero(Month(TMP->E1_XDTREAJ),2) + StrZero(Year(TMP->E1_XDTREAJ),4) ) )
		lAtualizado := .T.
	EndIF

	IF lAtualizado .And. lExibeAtualizados

		Aadd(aTitulos,{ .F. ,; 
					lAtualizado,;
					TMP->E1_CLIENTE,;
					TMP->E1_NOMCLI,;
					TMP->E1_PROPOS,;
					TMP->E1_ADITIV,;
					TMP->E1_PREFIXO,;
					TMP->E1_NUM,;
					TMP->E1_PARCELA,;
					TMP->E1_TIPO,;
					TMP->E1_VENCREA,;
					TMP->E1_XVALANT,;
					TMP->E1_XPERC,;
					TMP->E1_XDIFVAL,;
					TMP->E1_VALOR,;
					TMP->E1_XDTREAJ,;
					TMP->E1_HIST,;
					TMP->E1_NATUREZ,;
					TMP->E1_XINDICE})

	ElseIf !lAtualizado
		
		nIndiceReajuste	:= U_IndiceReajuste(TMP->E1_XINDICE,cPeriodo) 
		nFator          := 1 + ( nIndiceReajuste / 100 )

		nValorAnt	:= TMP->E1_VALOR
		//nValorErr   := TMP->E1_XVALERR
		//nAcrescimo	:= nValorAnt * nIndiceReajuste
		//nValorNew	:= nValorAnt + nAcrescimo

		//nValDif:= 0	
		//If (nValorErr > 0)
		//	nValDif     := nAcrescimo - (nValorErr - nValorAnt)
		//EndIf	

		nValorNew	:= Round(nValorAnt * nFator,2)
		nAcrescimo  := Round(nValorNew - nValorAnt,2)

		Aadd(aTitulos,{.T.,; 
					lAtualizado,;
					TMP->E1_CLIENTE,;
					TMP->E1_NOMCLI,;
					TMP->E1_PROPOS,;
					TMP->E1_ADITIV,;
					TMP->E1_PREFIXO,;
					TMP->E1_NUM,;
					TMP->E1_PARCELA,;
					TMP->E1_TIPO,;
					TMP->E1_VENCREA,;
					nValorAnt,;
					nIndiceReajuste,;
					nAcrescimo,;
					nValorNew,;
					TMP->E1_XDTREAJ,;
					TMP->E1_HIST,;
					TMP->E1_NATUREZ,;
					TMP->E1_XINDICE})
		
	EndIF

	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

If Len(aTitulos) == 0
	Aadd(aTitulos,{.F.,	.F.,'','','','','','','','',Ctod(''),0,0,0,0,Ctod(''),'','',''})
EndIf

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5]-50 TITLE "Reajuste de Mensalidades" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlTit:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlTit:Align:= CONTROL_ALIGN_ALLCLIENT

oTitulos				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlTit,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oTitulos:Align	     	:= CONTROL_ALIGN_ALLCLIENT
oTitulos:lColDrag		:= .T.
oTitulos:SetArray(aTitulos)
oTitulos:bLine 			:= {|| Eval(bLine) }
oTitulos:bHeaderClick	:= { |oObj,nCol| SyOrdena(nCol,@oTitulos,@aTitulos,@nlOrdemCols) }
oTitulos:bLDblClick 	:= { || Tit_EditaCelula(@oTitulos,@aTitulos,.T.,nFator)}
oTitulos:cToolTip		:= "Dê um duplo clique para Editar os valores."

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GrvTitReaj(aTitulos,cPeriodo,nIndiceReajuste,nFator) } , "Atualizando Titulos" )
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaReajust³ Autor ³ Fabio Rogerio   ³ Data ³  05/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o reajuste                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GravaReajuste(aClientes,cPeriodo,nIndiceReajuste,nFator,cIndice)

Local aArea		:= GetArea()
Local nX        := 0

ProcRegua( Len(aClientes) ) 

For nX := 1 To Len(aClientes)
	
	IncProc("Atualizando Cliente :" + aClientes[nX,RAZAO])

	DbSelectArea("SA1")
	DbSetOrder(1)
	
	IF aClientes[nX,LOK]
	
		IF DbSeek( xFilial("SA1") + aClientes[nX,CODIGO] )
			//Atualiza valores no cadastro do cliente	
			RecLock("SA1",.F.)
			
			Replace A1_DTVALID  With dDataBase
			
			Replace A1_VLCONAN  With aClientes[nX,CONSULTORATU]
			Replace A1_HORACON  With aClientes[nX,CONSULTORNEW]
	
			Replace A1_VLCORAN  With aClientes[nX,COORDENADORATU]
			Replace A1_HORACOR  With aClientes[nX,COORDENADORNEW]
			
			Replace A1_IMPOSTO  With aClientes[nX,IMPOSTOS]
			MsUnLock()
	
	
			//Atualiza valores no historico de reajustes de valores do cliente
			RecLock("Z20",.T.)			
			Replace Z20_FILIAL 	With xFilial("Z20")
			Replace Z20_CLIENT  With SA1->A1_COD
			Replace Z20_LOJA	With SA1->A1_LOJA
			Replace Z20_VLCONA  With aClientes[nX,CONSULTORATU]
			Replace Z20_VLCONN  With aClientes[nX,CONSULTORNEW]
			Replace Z20_VLCORA  With aClientes[nX,COORDENADORATU]
			Replace Z20_VLCORN  With aClientes[nX,COORDENADORNEW]	
			Replace Z20_INDICE  With cIndice	
			Replace Z20_PERC    With nIndiceReajuste
			Replace Z20_FATOR   With nFator
			Replace Z20_PERIOD  With cPeriodo
			Replace Z20_DATA    With dDataBase
			MsUnLock()
		EndIf	
	
	EndIF

Next nX

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EditaCelula ³ Autor ³ Alexandro Dias  ³ Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Edita os valores.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function EditaCelula(oClientes,aClientes,nIndiceReajuste,nFator)

If	(oClientes:ColPos == CONSULTORATU) .Or. (oClientes:ColPos == CONSULTORNEW) .Or. ;
	(oClientes:ColPos == COORDENADORATU) .Or. (oClientes:ColPos == COORDENADORNEW) .Or. (oClientes:ColPos == IMPOSTOS) 

		IF	(oClientes:ColPos == IMPOSTOS)
			lEditCell(@aClientes,oClientes,"@E 9.9999",oClientes:ColPos)

		ElseIF lEditCell(@aClientes,oClientes,"@E 9,999.99",oClientes:ColPos)

			If	(oClientes:ColPos == CONSULTORATU)
				oClientes:aArray[oClientes:nAt,CONSULTORNEW]:= Round( oClientes:aArray[oClientes:nAt,CONSULTORATU] * nFator , 2 )
			
			ElseIf	(oClientes:ColPos == COORDENADORATU)
				oClientes:aArray[oClientes:nAt,COORDENADORNEW]:= Round( oClientes:aArray[oClientes:nAt,COORDENADORATU] * nFator , 2 )
			
			EndIF
			
			oClientes:aArray[oClientes:nAt,LOK] := .T.
			
		EndIF	

ElseIF (oClientes:ColPos == LOK)

	oClientes:aArray[oClientes:nAt,1]:= !oClientes:aArray[oClientes:nAt,1]

EndIf

If oClientes:aArray[oClientes:nAt,2]
	oClientes:aArray[oClientes:nAt,1]:= .F.
EndIf

aClientes := oClientes:aArray 	

oClientes:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SyOrdena    ³ Autor ³ Alexandro Dias  ³ Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ordena as colunas.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SyOrdena(nCol,oClientes,aClientes,lOrdemCols)

Local nPos := nCol

IF !lJaExecutou
	
	lJaExecutou := .T.
	lOrdemCols := !lOrdemCols
	
	IF lOrdemCols 
    	aSort( oClientes:aArray ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
    	aSort( oClientes:aArray ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF
	
	aClientes := oClientes:aArray
	oClientes:nAt := 1
	oClientes:Refresh()
	oClientes:SetFocus()

Else

	lJaExecutou := .F.

EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuValores  ³ Autor ³ Alexandro Dias  ³ Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza as estatisticas dos clientes.                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuValores()

Local cQry := ''

cQry := " UPDATE SA1010 SET A1_MCOMPRA = TOTAL FROM "
cQry += "    ( SELECT E1_CLIENTE+E1_LOJA AS CLIENTE , SUM(E1_VALOR) AS TOTAL FROM SE1010 WHERE D_E_L_E_T_ = '' GROUP BY E1_CLIENTE+E1_LOJA ) AS TABAUX "
cQry += " WHERE A1_COD+A1_LOJA = CLIENTE "
TcSqlExec(cQry)

cQry := " UPDATE SA1010 SET A1_ULTCOM = EMISSAO FROM "
cQry := "     ( SELECT E1_CLIENTE+E1_LOJA AS CLIENTE , MAX(E1_EMISSAO) AS EMISSAO FROM SE1010 WHERE D_E_L_E_T_ = '' GROUP BY E1_CLIENTE+E1_LOJA ) AS TABAUX "
cQry := " WHERE A1_COD+A1_LOJA = CLIENTE "
TcSqlExec(cQry)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Tit_EditaCelula ³ Autor ³ Fabio Rogerio³ Data ³  03/01/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Edita os valores.                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Tit_EditaCelula(oTitulos,aTitulos,lReajuste,nFator)
DEFAULT lReajuste:= .T.

IF (oTitulos:ColPos == TIT_INDICE) .And. !Empty(oTitulos:aArray[oTitulos:nAt,TIT_NUM])
	//lEditCell(@aTitulos,oTitulos,"@E 9,999.9999999",oTitulos:ColPos)


	//oTitulos:aArray[oTitulos:nAt,TIT_VALORNEW]:= Round( oTitulos:aArray[oTitulos:nAt,TIT_VALOR] * (1 + nIndiceReajuste / 100) , 2 )
	//oTitulos:aArray[oTitulos:nAt,TIT_LOK] := .T.

ElseIF (oTitulos:ColPos == TIT_LOK)


	oTitulos:aArray[oTitulos:nAt,1]:= !oTitulos:aArray[oTitulos:nAt,1]

EndIf

If oTitulos:aArray[oTitulos:nAt,2] .And. lReajuste
	oTitulos:aArray[oTitulos:nAt,1]:= .F.
EndIf

aTitulos := oTitulos:aArray 	

oTitulos:Refresh()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GrvTitReaju   Autor ³ Fabio Rogerio   ³ Data ³  03/01/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o reajuste                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GrvTitReaj(aTitulos,cPeriodo,nIndiceReajuste,nFator)

Local aArea		:= GetArea()
Local nX        := 0
Local aSE1		:= {}
Local cPropos   := ""

ProcRegua( Len(aTitulos) ) 

For nX := 1 To Len(aTitulos)
	//alert("1-entrou no laco")
	
	IncProc("Atualizando Titulos :" + aTitulos[nX,TIT_RAZAO] + " - " + aTitulos[nX,TIT_NUM])

	DbSelectArea("SE1")
	DbSetOrder(1)
	
	IF aTitulos[nX,TIT_LOK]
		//alert("2-titulo marcado")
	
	
		IF DbSeek( xFilial("SE1") + aTitulos[nX,TIT_PREFIXO] + aTitulos[nX,TIT_NUM] + aTitulos[nX,TIT_PARCELA] + aTitulos[nX,TIT_TIPO] + aTitulos[nX,TIT_CODIGO],.T. )
			//alert("3-achou o titulo")
				
			Begin Transaction
				
				cPropos := SE1->E1_PROPOS
				cAditiv := SE1->E1_ADITIV

				RecLock("SE1",.F.)
				Replace E1_XVALANT  With aTitulos[nX,TIT_VALORANT]
				Replace E1_XPERC	With aTitulos[nX,TIT_PERC]
				Replace E1_XINDICE  With aTitulos[nX,TIT_INDICE]
				Replace E1_XDIFVAL  With aTitulos[nX,TIT_ACRESCIMO]
				Replace E1_VALOR    With aTitulos[nX,TIT_VALORNEW] 
				Replace E1_XDTREAJ  With dDataBase
				Replace E1_SALDO    With aTitulos[nX,TIT_VALORNEW]
				Replace E1_VLCRUZ   With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEIRF  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEPIS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASECOF  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASECSL  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEINS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEISS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEISS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_NATUREZ  With ''
		
				MsUnLock()

				//alert("4-gravou o titulo")
		
				lMsErroAuto := .F.                                                                                    	
				lMsHelpAuto := .F.
	
				aSE1 := {}

				Aadd( aSE1 ,	{"E1_FILIAL" 	,xFilial("SE1")									,Nil})
				Aadd( aSE1 ,	{"E1_PREFIXO" 	,SE1->E1_PREFIXO								,Nil})
				Aadd( aSE1 ,	{"E1_NUM"	   	,SE1->E1_NUM				       				,Nil})
				Aadd( aSE1 ,	{"E1_PARCELA" 	,SE1->E1_PARCELA							  	,Nil})
				Aadd( aSE1 ,	{"E1_TIPO"		,SE1->E1_TIPO									,Nil})
				Aadd( aSE1 ,	{"E1_NATUREZ" 	,aTitulos[nX,TIT_NATUREZA]						,Nil})
				Aadd( aSE1 ,	{"E1_CLIENTE" 	,SE1->E1_CLIENTE  								,Nil})
				Aadd( aSE1 ,	{"E1_LOJA"	   	,SE1->E1_LOJA   								,Nil})
				Aadd( aSE1 ,	{"E1_VALOR"	   	,aTitulos[nX,TIT_VALORNEW]          			,Nil})
			
				MSExecAuto({|x,y| FINA040(x,y)},aSE1,4)
				IF lMsErroAuto
					//alert("5-erro na execauto")
					
					MostraErro()
					IF ( __lSX8)
						RollBackSX8()
					EndIF
					DisarmTransaction()
					Break
					
				Else
					//alert("7-execauto realizado com sucesso")
				
					//Atualiza valores no historico de reajustes de valores do cliente
					RecLock("Z21",.T.)			
					Replace Z21_FILIAL 	With xFilial("Z21")
					Replace Z21_CLIENT  With SA1->A1_COD
					Replace Z21_LOJA	With SA1->A1_LOJA
					Replace Z21_TITULO  With xFilial("SE1")+aTitulos[nX,TIT_PREFIXO] + aTitulos[nX,TIT_NUM] + aTitulos[nX,TIT_PARCELA] + aTitulos[nX,TIT_TIPO] + aTitulos[nX,TIT_CODIGO]
					Replace Z21_VLATUAL With aTitulos[nX,TIT_VALORNEW] 
					Replace Z21_VLANT   With aTitulos[nX,TIT_VALORANT]
					Replace Z21_DIFVAL  With aTitulos[nX,TIT_ACRESCIMO]
					Replace Z21_INDICE  With aTitulos[nX,TIT_INDICE]	
					Replace Z21_PERC    With aTitulos[nX,TIT_PERC]
					Replace Z21_PERIOD  With cPeriodo
					Replace Z21_DATA    With dDataBase
					MsUnLock()
				
					//Atualiza os campos na proposta também.
					DbSelectArea("Z02")
					DbSetOrder(1)
					IF DbSeek(xFilial("Z02") + cPropos + cAditiv)
						RecLock("Z02",.F.)
						Replace Z02_PERC 	With nIndiceReajuste
						Replace Z02_DTREAJ 	With dDataBase						
						MsUnLock()
					EndIf

				EndIf
/*
				lMsErroAuto := .F.                                                                                    	
				lMsHelpAuto := .F.
	
				aSE1 := {}

				Aadd( aSE1 ,	{"E1_FILIAL" 	,xFilial("SE1")									,Nil})
				Aadd( aSE1 ,	{"E1_PREFIXO" 	,SE1->E1_PREFIXO								,Nil})
				Aadd( aSE1 ,	{"E1_NUM"	   	,SE1->E1_NUM				       				,Nil})
				Aadd( aSE1 ,	{"E1_PARCELA" 	,SE1->E1_PARCELA							  	,Nil})
				Aadd( aSE1 ,	{"E1_TIPO"		,SE1->E1_TIPO									,Nil})
				Aadd( aSE1 ,	{"E1_NATUREZ" 	,cNaturez		   								,Nil})
				Aadd( aSE1 ,	{"E1_CLIENTE" 	,SE1->E1_CLIENTE  								,Nil})
				Aadd( aSE1 ,	{"E1_LOJA"	   	,SE1->E1_LOJA   								,Nil})
			
				MSExecAuto({|x,y| FINA040(x,y)},aSE1,4)
				IF lMsErroAuto
					//alert("8-erro na execauto")
					
					MostraErro()
					IF ( __lSX8)
						RollBackSX8()
					EndIF
					DisarmTransaction()
					Break
					
				Else
					//alert("9-execauto realizado com sucesso")
				
				EndIf
  */
			End Transaction
		Else
			alert("6-nao achou o titulo")
		EndIf	
	
	EndIF

Next nX

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SYGeraManutencao³Autor  ³ Fabio Rogerio   ³ Data ³  05/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Manutencao.                                 			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyGeraManutencao(cCLienteDe,cClienteAte,cPeriodo)

Local oDlg,oPnlCli, oManut, oPnlTot
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oAtualizado  		:= LoadBitmap(GetResources(), "BR_VERDE" )
Local oNaoAtualizado 	:= LoadBitmap(GetResources(), "BR_VERMELHO" )
Local aSize    			:= MsAdvSize()
Local cMesAnoAtu 		:= '01' + StrZero(Year(dDataBase),4)
Local aManut    		:= {}                               
Local aParambox    		:= {}
Local aRetParam   	 	:= {}
Local nOpcao       		:= 0
Local nVlrAtu       	:= 0
Local nVlrNew  			:= 0
Local nVal1             := 0
Local nVal2             := 0
Local nVal3             := 0
Local lAtualizado		:= 0
Local nIndiceReajuste 	:= 0    
Local nFator            := 0
Local cTitle01          := '' 
Local cTitle02          := ''
Local cTitle03          := ''
Local oSay1
Local oSay2
Local oSay3

Local aCampos 			:= {'',;
							'',;
							'Dt.Ult.Reajuste',;
							'Cliente',;							
							'Nome',;
							'Proposta',;
							'Aditivo',;
							'Historico ',;
							'Indice',;
							'% Reajuste',;
							'Fator de Reajuste',;
							'Vlr.Manutencao Atual',;
							'Vlr.Manutencao Corrigido'}

Local bLine     		:= {|| {	IIf(aManut[oManut:nAt,MNT_LOK],oOk,oNo) ,; 
									IIf(aManut[oManut:nAt,MNT_ATUALIZADO],oAtualizado,oNaoAtualizado) ,;
									aManut[oManut:nAt,MNT_ULTREAJ],;
									aManut[oManut:nAt,MNT_CODIGO],;
									aManut[oManut:nAt,MNT_NOME],;
									aManut[oManut:nAt,MNT_PROPOSTA],;							
									aManut[oManut:nAt,MNT_ADITIVO],;							
									aManut[oManut:nAt,MNT_HISTORICO],;							
									aManut[oManut:nAt,MNT_INDICE],;							
									Transform(aManut[oManut:nAt,MNT_PERCREAJUSTE]	,"@E 999,999.999999"),;
									Transform(aManut[oManut:nAt,MNT_FATOR]	,"@E 999,999.999999"),;
									Transform(aManut[oManut:nAt,MNT_VLRMANUTATU]	,"@E 999,999.99"),;
									Transform(aManut[oManut:nAt,MNT_VLRMANUTNEW]	,"@E 999,999.99") }}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

/*
Aadd(aParamBox,{1,"Taxa Reajuste", CriaVar("E1_VALOR", .F.), "@E 9999.9999" , "Mv_Par01 >= 0", "", "", 50 , .F.})

IF !ParamBox(aParamBox,"Informe a Taxa para o Reajuste.",@aRetParam)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma o indice em Fator. 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndiceReajuste := 1 - ( MV_PAR01 / 100 )
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o List de Manut.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as propostas de manutencao anual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("Z02") + " Z02"
cQuery += " WHERE Z02.D_E_L_E_T_ = ''"
cQuery += " AND Z02_FILIAL = '"+xFilial("Z02")+"' "
cQuery += " AND Z02.Z02_TIPO = '4' "
cQuery += " AND Z02.Z02_STATUS IN  ('5','9')"
cQuery += " AND Z02.Z02_TPMANU = '2'"
cQuery += " AND Z02.Z02_CLIENT >=  '" + cClienteDe + "'"
cQuery += " AND Z02.Z02_CLIENT <=  '" + cClienteAte + "'"
cQuery += " ORDER BY Z02_CLIENT,Z02_PROPOS,Z02_ADITIV "
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "Z02_DTREAJ", "D" , 8 , 0 )

ProcRegua(TMP->(RecCount()))

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	IncProc('Calculando Reajuste')
	
	lAtualizado := .F.
		
	IF ( cMesAnoAtu == ( StrZero(Month(TMP->Z02_DTREAJ),2) + StrZero(Year(TMP->Z02_DTREAJ),4) ) )
		lAtualizado := .T.
	EndIF
		
	IF lAtualizado
			
		nVlrAtu := TMP->Z02_MNTANT		// Preco Anterior
		nVlrNew	:= TMP->Z02_MNTATU 		// Novo Preco

	Else

		nIndiceReajuste:= U_IndiceReajuste(TMP->Z02_INDICE,cPeriodo)
		nFator         := 1 + ( nIndiceReajuste / 100 )

		IF nIndiceReajuste > 0

			nVlrAtu	:= TMP->Z02_MNTATU
			nVlrNew	:= Round( TMP->Z02_MNTATU * nFator , 2) 
				
		Else
				
			nVlrAtu	:= TMP->Z02_MNTATU
			nVlrNew	:= TMP->Z02_MNTATU
				
		EndIF
		
	EndIF

	Aadd(aManut,{ .T. ,; 
					lAtualizado,;
					TMP->Z02_DTREAJ,;
					TMP->Z02_CLIENT ,;
					TMP->Z02_RAZAO,;
					TMP->Z02_PROPOS,;
					TMP->Z02_ADITIV,;
					TMP->Z02_DESCRI,;
					TMP->Z02_INDICE,;
					nIndiceReajuste,;
					nFator,;
					nVlrAtu,;
					nVlrNew})
	
	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

If Len(aManut) == 0
	Aadd(aManut,{ .F. ,; 
			      .F.,;
				  "" ,;
				  "",;
				  "",;
				  "",;
				  "",;
				  "",;
				  "",;
				  0,;
				  0,;
			 	  0,;
			   	  0})
EndIf


aSort( aManut , , , { |x,y| x[MNT_NOME] > y[MNT_NOME] } )

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5] TITLE "Reajuste da Manutencao Anual" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlCli:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlCli:Align:= CONTROL_ALIGN_ALLCLIENT

oPnlTot:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlTot:Align:= CONTROL_ALIGN_BOTTOM

oManut				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oManut:Align     	:= CONTROL_ALIGN_ALLCLIENT
oManut:lColDrag		:= .T.
oManut:SetArray(aManut)
oManut:bLine 		:= {|| (Eval(bLine),AtuTotMnt(aManut,@nVal1,@nVal2,@nVal3)) }
oManut:bHeaderClick	:= { |oObj,nCol| SyOrdena(nCol,@oManut,@aManut,@nlOrdemCols) }
oManut:bLDblClick 	:= { || EditaCelula(@oManut,@aManut,nIndiceReajuste,nFator)}
oManut:cToolTip		:= "Dê um duplo clique para Editar os valores."

cTitle01:= '<font size="3" color="#FFD700">Vlr.Manutencao Atual R$ ' + 	Transform(nVal1	,"@E 999,999.99") + '</font>'
oSay01:= TSay():New( 033, 010,{|| cTitle01}, oPnlTot,,oFnt,,,,.T.,,,200,20,,,,,,.F.)

cTitle02:= '<font size="3" color="#FFD700">Vlr.Manutencao Corrigido R$ ' + 	Transform(nVal2	,"@E 999,999.99") + '</font>'
oSay02:= TSay():New( 033, 010,{|| cTitle02}, oPnlTot,,oFnt,,,,.T.,,,200,20,,,,,,.F.)

cTitle03:= '<font size="3" color="#FFD700">Diferenca R$ ' + 	Transform(nVal3	,"@E 999,999.99") + '</font>'
oSay03:= TSay():New( 033, 010,{|| cTitle03}, oPnlTot,,oFnt,,,,.T.,,,200,20,,,,,,.F.)

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GrvMnt(aManut,cPeriodo) } , "Gerando Manutencao Anual" )
EndIf

Return(.T.)                                         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuTotMnt  ³ Fabio Rogerio   ³ Data ³  05/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza Totais da Manutencao                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuTotMnt(aManut,nVal1,nVal2,nVal3)

nVal1:= 0
nVal2:= 0
nVal3:= 0

aEval(aManut, {|x| nVal1 += IIF(x[MNT_LOK],x[MNT_VLRMANUTATU],0)})
aEval(aManut, {|x| nVal2 += IIF(x[MNT_LOK],x[MNT_VLRMANUTATU],0)})
nVal3 := nVal2-nVal1

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GrvMnt  ³ Fabio Rogerio   ³ Data ³  05/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera os titulos de Manutencao                     			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrvMnt(aManut,cPeriodo)
Local aArea		:= GetArea()
Local nX        := 0
Local aSE1		:= {}

ProcRegua( Len(aManut) ) 

For nX := 1 To Len(aManut)
	//alert("1-entrou no laco")
	
	IncProc("Gerando Titulos de Manutencao :" + aManut[nX,MNT_NOME] + " - " + aManut[nX,MNT_PROPOSTA] + '/' + aManut[nX,MNT_ADITIVO])

	IF aManut[nX,MNT_LOK] .And. !aManut[nX,MNT_ATUALIZADO]
		//alert("2-titulo marcado")
	
	
		Begin Transaction
	
			lMsErroAuto := .F.                                                                                    	
			lMsHelpAuto := .F.

			aSE1 := {}

			Aadd( aSE1 ,	{"E1_FILIAL" 	,xFilial("SE1")					,Nil})
			Aadd( aSE1 ,	{"E1_PREFIXO" 	,Criavar("SE1","E1_PREFIXO")	,Nil})
			Aadd( aSE1 ,	{"E1_NUM"	   	,Criavar("SE1","E1_NUM")		,Nil})
			Aadd( aSE1 ,	{"E1_PARCELA" 	,"01"							,Nil})
			Aadd( aSE1 ,	{"E1_TIPO"		,"DP"							,Nil})
			Aadd( aSE1 ,	{"E1_NATUREZ" 	,GetMV("AL_NATMAN","010101")	,Nil})
			Aadd( aSE1 ,	{"E1_CLIENTE" 	,aManut[nX,MNT_CLIENTE]  		,Nil})
			Aadd( aSE1 ,	{"E1_LOJA"	   	,"01"							,Nil})
			Aadd( aSE1 ,	{"E1_VALOR"	   	,aManut[nX,MNT_VLRMANUTNEW]    	,Nil})
			Aadd( aSE1 ,	{"E1_HIST"	   	,cValToChar(Year(Date())) + " - MANUTENCAO ANUAL SAP BUSINESS ONE - PROPOSTA " + aManut[nX,MNT_PROPOSTA]+'/'+ aManut[nX,MNT_ADITIVO],Nil})
			Aadd( aSE1 ,	{"E1_XINDICE"	,aManut[nX,MNT_INDICE],Nil})
		
			MSExecAuto({|x,y| FINA040(x,y)},aSE1,3)
			IF lMsErroAuto
				alert("5-erro na execauto")
				
				MostraErro()
				IF ( __lSX8)
					RollBackSX8()
				EndIF
				DisarmTransaction()
				Break
				
			Else

				//Atualiza valores no historico de reajustes de valores do cliente
				RecLock("Z21",.T.)			
				Replace Z21_FILIAL 	With xFilial("Z21")
				Replace Z21_CLIENT  With SA1->A1_COD
				Replace Z21_LOJA	With SA1->A1_LOJA
				Replace Z21_TITULO  With xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
				Replace Z21_VLATUAL With aManut[nX,MNT_VLRMANUTNEW] 
				Replace Z21_VLANT   With 0
				Replace Z21_INDICE  With aManut[nX,MNT_INDICE]
				Replace Z21_PERC    With aManut[nX,MNT_PERCREAJUSTE]
				Replace Z21_FATOR   With aManut[nX,MNT_FATOR]
				Replace Z21_PERIOD  With cPeriodo
				Replace Z21_DATA    With dDataBase
				MsUnLock()

				alert("7-execauto realizado com sucesso")
			
			EndIf
		End Transaction
	EndIF

Next nX

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewReajuste  ³Autor  ³ Fabio Rogerio   ³ Data ³  05/02/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza o Histórico de Reajuste do Valor Hora de Cadastro±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ViewReajuste(cCliente,cLoja,cTitulo)
Local oDlg,oPnlCli, oClientes
Local aSize    			:= MsAdvSize()
Local aClientes    		:= {}                               
Local cQuery            := ""
Local aCampos 			:= {'Periodo do Reajuste',;
							'Indice',;							
							'% de Reajuste',;
							'Fator',;
							'Valor Hora Atual (Consultor) ',;
							'Valor Hora Atual (Coordenador)',;
							'Valor Hora Anterior (Consultor)',;
							'Valor Hora Anterior (Coordenador)',;
							'Data do Reajuste'}

Local bLine     		:= {|| {	Transform(aClientes[oClientes:nAt,RJ_PERIODO],"@R 9999/99"),; 
									aClientes[oClientes:nAt,RJ_INDICE],;
									Transform(aClientes[oClientes:nAt,RJ_PERC]		,"@E 99,999,999.9999"),;
									Transform(aClientes[oClientes:nAt,RJ_FATOR]		,"@E 9,999.9999"),;
									Transform(aClientes[oClientes:nAt,RJ_CONATUAL]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CORATUAL]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CONANT]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CORANT]	,"@E 9,999.99"),;
									aClientes[oClientes:nAt,RJ_DATA]}}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

DEFAULT cCliente:= ""
DEFAULT cLoja   := ""
DEFAULT cTitulo := ""

//Verifica se os dados do cliente vieram em branco
If Empty(cCliente)
	Aviso("Atencao","Favor infomar um cliente valido.",{"Ok"})
	Return(.F.)
EndIf

cQuery:= "SELECT * FROM " + RetSqlName("Z20") + " Z20 "
cQuery+= "WHERE Z20.D_E_L_E_T_ = '' AND Z20.Z20_FILIAL = '" + xFilial("Z20") + "' AND Z20.Z20_CLIENT = '" + cCliente + "' AND Z20.Z20_LOJA = '" + cLoja + "'"

IF Select("TMPZ20") > 0 
	TMPZ20->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ20",.F.,.T.)

TcSetField("TMPZ20", "Z20_DATA", "D" , 8 , 0 )

ProcRegua(TMPZ20->(RecCount()))

DbSelectArea("TMPZ20")
DbGoTop()
While !Eof()
	
	IncProc('Carregando Historico de Reajuste')

	Aadd(aClientes,{ 	TMPZ20->Z20_PERIOD,;
						TMPZ20->Z20_INDICE,;
						TMPZ20->Z20_PERC,;
						TMPZ20->Z20_FATOR,;
						TMPZ20->Z20_VLCONN,;
						TMPZ20->Z20_VLCORN,;
						TMPZ20->Z20_VLCONA,;
						TMPZ20->Z20_VLCORA,;
						TMPZ20->Z20_DATA	})

	DbSelectArea("TMPZ20")
	DbSkip()

EndDo

If Len(aClientes) == 0
	Aadd(aClientes,{ 	'',;
						'',;
						0,;
						0,;
						0,;
						0,;
						0,;
						'',;
						Ctod('')})
EndIf

aSort( aClientes , , , { |x,y| x[RJ_PERIODO] < y[RJ_PERIODO] } )

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5] TITLE "Historico de Reajuste de Valor" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlCli:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlCli:Align:= CONTROL_ALIGN_ALLCLIENT

oClientes				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oClientes:Align     	:= CONTROL_ALIGN_ALLCLIENT
oClientes:lColDrag		:= .T.
oClientes:SetArray(aClientes)
oClientes:bLine 		:= {|| Eval(bLine) }

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End() }, {|| oDlg:End() }) ) CENTERED

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TitViewReaj  ³Autor  ³ Fabio Rogerio     ³ Data ³  05/02/15º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza o Histórico de Reajuste do Titulos                ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function TitViewReaj(cCliente,cLoja,cTitulo)
Local oDlg,oPnlCli, oClientes
Local aSize    			:= MsAdvSize()
Local aClientes    		:= {}                               
Local cQuery            := ""
Local aCampos 			:= {'Periodo do Reajuste',;
							'Indice',;							
							'% de Reajuste',;
							'Fator',;
							'Valor Hora Atual (Consultor) ',;
							'Valor Hora Atual (Coordenador)',;
							'Valor Hora Anterior (Consultor)',;
							'Valor Hora Anterior (Coordenador)',;
							'Data do Reajuste'}

Local bLine     		:= {|| {	Transform(aClientes[oClientes:nAt,RJ_PERIODO],"@R 9999/99"),; 
									aClientes[oClientes:nAt,RJ_INDICE],;
									Transform(aClientes[oClientes:nAt,RJ_PERC]		,"@E 99,999,999.9999"),;
									Transform(aClientes[oClientes:nAt,RJ_FATOR]		,"@E 9,999.9999"),;
									Transform(aClientes[oClientes:nAt,RJ_CONATUAL]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CORATUAL]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CONANT]	,"@E 9,999.99"),;
									Transform(aClientes[oClientes:nAt,RJ_CORANT]	,"@E 9,999.99"),;
									aClientes[oClientes:nAt,RJ_DATA]}}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

DEFAULT cCliente:= ""
DEFAULT cLoja   := ""
DEFAULT cTitulo := ""

//Verifica se os dados do cliente vieram em branco
If Empty(cCliente) .Or. Empty(cTitulo)
	Aviso("Atencao","Favor infomar um cliente ou titulo valido.",{"Ok"})
	Return(.F.)
EndIf

cQuery:= "SELECT * FROM " + RetSqlName("Z21") + " Z21 "
cQuery+= "WHERE Z21.D_E_L_E_T_ = '' AND Z21.Z21_FILIAL = '" + xFilial("Z21") + "' AND Z20.Z20_CLIENT = '" + cCliente + "' AND Z20.Z20_LOJA = '" + cLoja + "'"

IF Select("TMPZ20") > 0 
	TMPZ20->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPZ20",.F.,.T.)

TcSetField("TMPZ20", "Z20_DATA", "D" , 8 , 0 )

ProcRegua(TMPZ20->(RecCount()))

DbSelectArea("TMPZ20")
DbGoTop()
While !Eof()
	
	IncProc('Carregando Historico de Reajuste')

	Aadd(aClientes,{ 	TMPZ20->Z20_PERIOD,;
						TMPZ20->Z20_INDICE,;
						TMPZ20->Z20_PERC,;
						TMPZ20->Z20_FATOR,;
						TMPZ20->Z20_VLCONN,;
						TMPZ20->Z20_VLCORN,;
						TMPZ20->Z20_VLCONA,;
						TMPZ20->Z20_VLCORA,;
						TMPZ20->Z20_DATA	})

	DbSelectArea("TMPZ20")
	DbSkip()

EndDo

If Len(aClientes) == 0
	Aadd(aClientes,{ 	'',;
						'',;
						0,;
						0,;
						0,;
						0,;
						0,;
						'',;
						Ctod('')})
EndIf

aSort( aClientes , , , { |x,y| x[RJ_PERIODO] < y[RJ_PERIODO] } )

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5] TITLE "Historico de Reajuste de Valor" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlCli:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlCli:Align:= CONTROL_ALIGN_ALLCLIENT

oClientes				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlCli,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oClientes:Align     	:= CONTROL_ALIGN_ALLCLIENT
oClientes:lColDrag		:= .T.
oClientes:SetArray(aClientes)
oClientes:bLine 		:= {|| Eval(bLine) }

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End() }, {|| oDlg:End() }) ) CENTERED

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  SyEstornoTit ³ Auto  ³ Fabio Rogerio   ³ Data ³  18/01/21  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Estorno do Reajuste dos Titulos.			                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function SyEstornoTit(cClienteDe,cClienteAte,cPeriodo,aRetParam)

Local oDlg,oPnlEst, oEstorno
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oNaoAtualizado  	:= LoadBitmap(GetResources(), "BR_VERDE" )
Local oAtualizado 	    := LoadBitmap(GetResources(), "BR_VERMELHO" )
Local aSize    			:= MsAdvSize()
Local cMesAnoAtu 		:= '01' + StrZero(Year(dDataBase),4)
Local aEstorno    		:= {}                               
Local nOpcao       		:= 0
Local nVlrAtu		  	:= 0
Local nVlrNew		  	:= 0
Local lAtualizado		:= .F.
Local nIndiceReajuste 	:= 0
Local nFator            := 0

Local aCampos 			:= {'',;
							'',;
							'Cliente',;
							'Nome',;
							'Contrato',;
							'Aditivo',;
							'Prefixo',;
							'Titulo',;
							'Parcela',;
							'Tipo',;
							'Dt.Vencto',;
							'Valor(Anterior)',;
							'% Reajuste',;
							'Acrescimo',;
							'Valor(Novo)',;
							'Data Reajuste',;
							'Historico',;
							'Natureza',;
							'Nome Indice'}

Local bLine     		:= {|| {	IIf(aEstorno[oEstorno:nAt,TIT_LOK],oOk,oNo) ,; 
									IIf(aEstorno[oEstorno:nAt,TIT_ATU],oAtualizado,oNaoAtualizado),;
									aEstorno[oEstorno:nAt,TIT_CODIGO],;
									aEstorno[oEstorno:nAt,TIT_RAZAO],;
									aEstorno[oEstorno:nAt,TIT_CONTRATO],;
									aEstorno[oEstorno:nAt,TIT_ADITIVO],;
									aEstorno[oEstorno:nAt,TIT_PREFIXO],;
									aEstorno[oEstorno:nAt,TIT_NUM],;
									aEstorno[oEstorno:nAt,TIT_PARCELA],;
									aEstorno[oEstorno:nAt,TIT_TIPO],;
									Dtoc(aEstorno[oEstorno:nAt,TIT_VENCREA]),;
									Transform(aEstorno[oEstorno:nAt,TIT_VALORANT]	,"@E 999,999.99"),;
									Transform(aEstorno[oEstorno:nAt,TIT_PERC]		,"@E 999.999999"),;
									Transform(aEstorno[oEstorno:nAt,TIT_ACRESCIMO]	,"@E 999,999.99"),;
									Transform(aEstorno[oEstorno:nAt,TIT_VALORNEW]	,"@E 999,999.99"),;
									Dtoc(aEstorno[oEstorno:nAt,TIT_DTREAJ]),;
									Left(aEstorno[oEstorno:nAt,TIT_HISTORICO],100),;
									aEstorno[oEstorno:nAt,TIT_NATUREZA],;
									aEstorno[oEstorno:nAt,TIT_INDICE] }}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os Titulos.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cClienteDe := aRetParam[2]
cClienteAte:= aRetParam[3]
dVenctoAte := aRetParam[4]
lExibeAtualizados:= IIF(Left(aRetParam[5],1) == "1",.T.,.F.)

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_XTPPARC IN ('4','5') "
cQuery += " AND E1_XTIPO IN ('2','3','4','6','8') "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_CLIENTE BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "'"
cQuery += " AND E1_EMISSAO  <='" + Dtos(dVenctoAte) + "'" 
cQuery += " AND E1_PORTADO <> '999'"   //Juridico
cQuery += " AND RIGHT(E1_TIPO,1) <> '-'"
cQuery += " AND (E1_XDTREAJ BETWEEN '" + Dtos(FirstDay(dDataBase)) + "' AND '" + Dtos(LastDay(dDataBase)) + "')" 
cQuery += " AND D_E_L_E_T_ =  ' ' "
cQuery += " ORDER BY E1_NOMCLI,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCREA "
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "E1_XDTREAJ", "D" , 8 , 0 )
TcSetField("TMP", "E1_VENCREA", "D" , 8 , 0 )

ProcRegua(TMP->(RecCount()))

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	IncProc('Selecionado Titulos')
	
	lAtualizado := .F.
		
	IF ( cMesAnoAtu == ( StrZero(Month(TMP->E1_XDTREAJ),2) + StrZero(Year(TMP->E1_XDTREAJ),4) ) )
		lAtualizado := .T.
	EndIF

	IF lAtualizado 

		Aadd(aEstorno,{ .T. ,; 
					lAtualizado,;
					TMP->E1_CLIENTE,;
					TMP->E1_NOMCLI,;
					TMP->E1_PROPOS,;
					TMP->E1_ADITIV,;
					TMP->E1_PREFIXO,;
					TMP->E1_NUM,;
					TMP->E1_PARCELA,;
					TMP->E1_TIPO,;
					TMP->E1_VENCREA,;
					TMP->E1_XVALANT,;
					TMP->E1_XPERC,;
					TMP->E1_XDIFVAL,;
					TMP->E1_VALOR,;
					TMP->E1_XDTREAJ,;
					TMP->E1_HIST,;
					TMP->E1_NATUREZ,;
					TMP->E1_XINDICE})

	EndIF

	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

If Len(aEstorno) == 0
	Aadd(aEstorno,{.F.,	.F.,'','','','','','','','',Ctod(''),0,0,0,0,Ctod(''),'','',''})
EndIf

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5]-50 TITLE "Estorno de Reajuste de Mensalidades" Of oMainWnd PIXEL

oDlg:lEscClose  := .F.
oDlg:lMaximized := .T.

oPnlEst:= TPanel():New(0, 0, "", oDlg, NIL, .T., .F., NIL, NIL, 0,060, .T., .F. )
oPnlEst:Align:= CONTROL_ALIGN_ALLCLIENT

oEstorno				:= TwBrowse():New(1,1,1,1,,aCampos,, oPnlEst,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oEstorno:Align	     	:= CONTROL_ALIGN_ALLCLIENT
oEstorno:lColDrag		:= .T.
oEstorno:SetArray(aEstorno)
oEstorno:bLine 			:= {|| Eval(bLine) }
oEstorno:bHeaderClick	:= { |oObj,nCol| SyOrdena(nCol,@oEstorno,@aEstorno,@nlOrdemCols) }
oEstorno:bLDblClick 	:= { || Tit_EditaCelula(@oEstorno,@aEstorno,.F.,nFator)}
oEstorno:cToolTip		:= "Selecione os titulos que devem ser estornados"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GrvEstorno(aEstorno,cPeriodo,nIndiceReajuste,nFator) } , "Atualizando Titulos" )
EndIf

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GrvEstorno   Autor ³ Fabio Rogerio   ³ Data ³  18/01/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava o estorno reajuste                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GrvEstorno(aEstorno,cPeriodo,nIndiceReajuste,nFator)

Local aArea		:= GetArea()
Local nX        := 0
Local aSE1		:= {}
Local cPropos   := ""

ProcRegua( Len(aEstorno) ) 

For nX := 1 To Len(aEstorno)
	//alert("1-entrou no laco")
	
	IncProc("Atualizando Titulos :" + aEstorno[nX,TIT_RAZAO] + " - " + aEstorno[nX,TIT_NUM])

	DbSelectArea("SE1")
	DbSetOrder(1)
	
	IF aEstorno[nX,TIT_LOK]
		//alert("2-titulo marcado")
	
	
		IF DbSeek( xFilial("SE1") + aEstorno[nX,TIT_PREFIXO] + aEstorno[nX,TIT_NUM] + aEstorno[nX,TIT_PARCELA] + aEstorno[nX,TIT_TIPO] + aEstorno[nX,TIT_CODIGO],.T. )
			//alert("3-achou o titulo")
			Begin Transaction
				
				cPropos := SE1->E1_PROPOS
				cAditiv := SE1->E1_ADITIV

				RecLock("SE1",.F.)
				Replace E1_XVALANT  With 0
				Replace E1_XPERC	With 0
				Replace E1_XINDICE  With aEstorno[nX,TIT_INDICE]
				Replace E1_XDIFVAL  With 0
				Replace E1_XDIFJAN  With 0
				Replace E1_VALOR    With aEstorno[nX,TIT_VALORANT]
				Replace E1_XDTREAJ  With Ctod("")
				Replace E1_SALDO    With aEstorno[nX,TIT_VALORANT]
				Replace E1_VLCRUZ   With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASEIRF  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASEPIS  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASECOF  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASECSL  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASEINS  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASEISS  With aEstorno[nX,TIT_VALORANT]
				Replace E1_BASEISS  With aEstorno[nX,TIT_VALORANT]
				Replace E1_NATUREZ  With ''
		
				MsUnLock()

				//alert("4-gravou o titulo")
		
				lMsErroAuto := .F.                                                                                    	
				lMsHelpAuto := .F.
	
				aSE1 := {}

				Aadd( aSE1 ,	{"E1_FILIAL" 	,xFilial("SE1")									,Nil})
				Aadd( aSE1 ,	{"E1_PREFIXO" 	,SE1->E1_PREFIXO								,Nil})
				Aadd( aSE1 ,	{"E1_NUM"	   	,SE1->E1_NUM				       				,Nil})
				Aadd( aSE1 ,	{"E1_PARCELA" 	,SE1->E1_PARCELA							  	,Nil})
				Aadd( aSE1 ,	{"E1_TIPO"		,SE1->E1_TIPO									,Nil})
				Aadd( aSE1 ,	{"E1_NATUREZ" 	,aEstorno[nX,TIT_NATUREZA]						,Nil})
				Aadd( aSE1 ,	{"E1_CLIENTE" 	,SE1->E1_CLIENTE  								,Nil})
				Aadd( aSE1 ,	{"E1_LOJA"	   	,SE1->E1_LOJA   								,Nil})
				Aadd( aSE1 ,	{"E1_VALOR"	   	,aEstorno[nX,TIT_VALORANT]          			,Nil})
			
				MSExecAuto({|x,y| FINA040(x,y)},aSE1,4)
				IF lMsErroAuto
					//alert("5-erro na execauto")
					
					MostraErro()
					IF ( __lSX8)
						RollBackSX8()
					EndIF
					DisarmTransaction()
					Break
					
				Else
					cTitulo:= Padr(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE,TamSX3("Z21_TITULO")[1])
					dbSelectArea("Z21")
					DbSetOrder(1)
					If DbSeek(xFilial("Z21")+SE1->E1_CLIENTE+SE1->E1_LOJA+cTitulo+cPeriodo)
						RecLock("Z21",.F.,.T.)
						Z21->(DbDelete())
						MsUnLock()
					EndIf

					//Atualiza os campos na proposta também.
					DbSelectArea("Z02")
					DbSetOrder(1)
					IF DbSeek(xFilial("Z02") + cPropos + cAditiv)
						RecLock("Z02",.F.)
						Replace Z02_PERC 	With 0
						Replace Z02_DTREAJ 	With Ctod("")
						MsUnLock()
					EndIf

				EndIf
			End Transaction
		Else
			alert("6-nao achou o titulo")
		EndIf	
	
	EndIF

Next nX

RestArea(aArea)

Return(.T.)
