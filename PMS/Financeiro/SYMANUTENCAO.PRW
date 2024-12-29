#Include "Protheus.ch"

#DEFINE		LOK				 1
#DEFINE		ATUALIZADO		 2
#DEFINE		ULTFAT			 3
#DEFINE		CODIGO			 4
#DEFINE		RAZAO			 5
#DEFINE		FANTASIA		 6
#DEFINE		FATTOTAL		 7
#DEFINE		CONSULTORATU	 8
#DEFINE		CONSULTORNEW	 9
#DEFINE		COORDENADORATU	 10
#DEFINE		COORDENADORNEW	 11
#DEFINE		ULTREAJUSTE		 12
#DEFINE		IMPOSTOS		 13

#DEFINE		TIT_LOK			 1 
#DEFINE		TIT_ATU  		 2
#DEFINE		TIT_CODIGO		 3
#DEFINE		TIT_RAZAO		 4
#DEFINE		TIT_PREFIXO		 5
#DEFINE		TIT_NUM			 6
#DEFINE		TIT_PARCELA		 7
#DEFINE		TIT_TIPO		 8
#DEFINE		TIT_HISTORICO	 9
#DEFINE		TIT_VALORATU	 10
#DEFINE		TIT_VALORNEW	 11
#DEFINE		TIT_INDICE		 12
#DEFINE		TIT_PERCREAJUSTE 13
#DEFINE		TIT_FATOR		 14
#DEFINE		TIT_NATUREZA	 15       
#DEFINE		TIT_DTREAJ		 16


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

Static Function SyReajuste2()
Local aParamBox:= {} 
Local aRetParam:= {}
Local cPeriodo := Year(dDatabase)+Month(dDatabase)

//Verifica se existe percentual cadastrado para o periodo
DbSelectArea("Z19")
DbSetOrder(2)
If !DbSeek(xFilial("Z19")+cPeriodo,.T.)
	Aviso("Atencao","Nao existe nenhum indice de reajuste cadatrado para o periodo " + cPeriodo,{"Ok"})
	Return(.F.)
EndIf	


aAdd(aParamBox,{2,"Tipo","1"		   				  ,{"1-Reajuste Valor Hora","2-Reajuste Parcelas"}	,100,"",.F.})  
Aadd(aParamBox,{1,"Cliente De"	, CriaVar("E1_CLIENTE", .F.), PesqPict("SE1", "E1_CLIENTE") , "", "SA1", "", 50 , .F.})
Aadd(aParamBox,{1,"Cliente Ate"	, CriaVar("E1_CLIENTE", .F.), PesqPict("SE1", "E1_CLIENTE") , "", "SA1", "", 50 , .F.})
IF !ParamBox(aParamBox,"Informe o Tipo de Reajuste",@aRetParam)
	Return
Endif

If Left(aRetParam[1],1) == "2"
	U_SyTitReajuste(aRetParam[2],aRetParam[3],cPeriodo)
ElseIf Left(aRetParam[1],1) == "1"
	U_SyHoraReajuste(aRetParam[2],aRetParam[3],cPeriodo)
EndIf


Return

Static Function SyHoraReajuste2(cCLienteDe,cClienteAte,cPeriodo)

Local oDlg,oPnlCli, oClientes
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oAtualizado  		:= LoadBitmap(GetResources(), "BR_VERDE" )
Local oNaoAtualizado 	:= LoadBitmap(GetResources(), "BR_VERMELHO" )
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
							'',;
							'Dt.Ult.Fat',;
							'Codigo',;							
							'Razao',;
							'Fantasia',;
							'Faturamento',;
							'Consultor ',;
							'Consultor New',;
							'Coordenador',;
							'Coordenador New',;
							'Dt.Reajuste',;
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
									aClientes[oClientes:nAt,ULTREAJUSTE],;       
									Transform(aClientes[oClientes:nAt,IMPOSTOS]	,"@E 99.99999") }}

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma o indice em Fator. 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndiceReajuste := U_IndiceReajuste(cIndice,cPeriodo)
nFator          := 1 - ( nIndiceReajuste / 100 )


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

				nConsultAtuVlr	:= SA1->A1_HORACON
				nConsultNewVlr	:= Round( SA1->A1_HORACON / nFator , 2) 
				
				nCoordAtuVlr	:= SA1->A1_HORACOR
				nCoordNewVlr	:= Round( SA1->A1_HORACOR / nFator , 2 )

			Else
				
				nConsultAtuVlr	:= SA1->A1_VLCONAN
				nConsultNewVlr	:= SA1->A1_HORACON 
				
				nCoordAtuVlr	:= SA1->A1_VLCORAN
				nCoordNewVlr	:= SA1->A1_HORACOR

			EndIF
		
		EndIF
		
		Aadd(aClientes,{ .F. ,; 
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
oClientes:bLDblClick 	:= { || EditaCelula(@oClientes,@aClientes,nIndiceReajuste)}
oClientes:cToolTip		:= "Dê um duplo clique para Editar os valores."

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GravaReajuste(aClientes,cPeriodo,nIndiceReajuste,nFator,cIndice) } , "Atualizando Clientes" )
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

Static Function EditaCelula(oClientes,aClientes,nIndiceReajuste)

If	(oClientes:ColPos == CONSULTORATU) .Or. (oClientes:ColPos == CONSULTORNEW) .Or. ;
	(oClientes:ColPos == COORDENADORATU) .Or. (oClientes:ColPos == COORDENADORNEW) .Or. (oClientes:ColPos == IMPOSTOS) 

		IF	(oClientes:ColPos == IMPOSTOS)
			lEditCell(@aClientes,oClientes,"@E 9.9999",oClientes:ColPos)

		ElseIF lEditCell(@aClientes,oClientes,"@E 9,999.99",oClientes:ColPos)

			If	(oClientes:ColPos == CONSULTORATU)
				oClientes:aArray[oClientes:nAt,CONSULTORNEW]:= Round( oClientes:aArray[oClientes:nAt,CONSULTORATU] / nIndiceReajuste , 2 )
			
			ElseIf	(oClientes:ColPos == COORDENADORATU)
				oClientes:aArray[oClientes:nAt,COORDENADORNEW]:= Round( oClientes:aArray[oClientes:nAt,COORDENADORATU] / nIndiceReajuste , 2 )
			
			EndIF
			
			oClientes:aArray[oClientes:nAt,LOK] := .T.
			
		EndIF	

ElseIF (oClientes:ColPos == LOK)

	oClientes:aArray[oClientes:nAt,1]:= !oClientes:aArray[oClientes:nAt,1]

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

Static Function SyTitReajuste2(cClienteDe,cClienteAte,cPeriodo)

Local oDlg,oPnlTit, oTitulos
Local oOk				:= LoadBitmap(GetResources(), "LBOK")
Local oNo				:= LoadBitmap(GetResources(), "LBNO")
Local oAtualizado  		:= LoadBitmap(GetResources(), "BR_VERDE" )
Local oNaoAtualizado 	:= LoadBitmap(GetResources(), "BR_VERMELHO" )
Local aSize    			:= MsAdvSize()
Local cMesAnoAtu 		:= '01' + StrZero(Year(dDataBase),4)
Local aTitulos    		:= {}                               
Local aParambox    		:= {}
Local aRetParam   	 	:= {}
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
							'Prefixo',;
							'Titulo',;
							'Parcela',;
							'Tipo',;
							'Historico',;
							'Valor Atual',;
							'Valor Novo',;
							'Indice Reajuste',;
							'% Reajuste',;
							'Natureza',;
							'Data Reajuste'}

Local bLine     		:= {|| {	IIf(aTitulos[oTitulos:nAt,TIT_LOK],oOk,oNo) ,; 
									IIf(lAtualizado,oOk,oNo),;
									aTitulos[oTitulos:nAt,TIT_CODIGO],;
									aTitulos[oTitulos:nAt,TIT_RAZAO],;
									aTitulos[oTitulos:nAt,TIT_PREFIXO],;
									aTitulos[oTitulos:nAt,TIT_NUM],;
									aTitulos[oTitulos:nAt,TIT_PARCELA],;
									aTitulos[oTitulos:nAt,TIT_TIPO],;
									Left(aTitulos[oTitulos:nAt,TIT_HISTORICO],100),;
									Transform(aTitulos[oTitulos:nAt,TIT_VALORATU]	,"@E 999,999.99"),;
									Transform(aTitulos[oTitulos:nAt,TIT_VALORNEW]	,"@E 999,999.99"),;
									aTitulos[oTitulos:nAt,TIT_INDICE],;
									Transform(aTitulos[oTitulos:nAt,TIT_PERCREAJUSTE],"@E 9,999.9999999"),;
									Transform(aTitulos[oTitulos:nAt,TIT_FATOR],"@E 9,999.9999999"),;
									aTitulos[oTitulos:nAt,TIT_NATUREZA],;       
									Dtoc(aTitulos[oTitulos:nAt,TIT_DTREAJ]) }}

Static nlOrdemCols	:= .F.
Static lJaExecutou 	:= .F.

/*
Aadd(aParamBox,{1,"Taxa Reajuste", CriaVar("E1_VALOR", .F.), "@E 9999.9999999" , "Mv_Par01 >= 0", "", "", 50 , .F.})

IF !ParamBox(aParamBox,"Informe a Taxa para o Reajuste.",@aRetParam)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma o indice em Fator. 			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndiceReajuste := MV_PAR01
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega os Titulos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SE1")
cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_XTPPARC = '4' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_CLIENTE >=  '" + cClienteDe + "'"
cQuery += " AND E1_CLIENTE <=  '" + cClienteAte + "'"
cQuery += " AND E1_PORTADO <> '999'"   //Juridico
cQuery += " AND RIGHT(E1_TIPO,1) <> '-'"
cQuery += " AND D_E_L_E_T_ =  ' ' "
cQuery += " ORDER BY E1_NOMCLI,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCREA "
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

TcSetField("TMP", "E1_XDTREAJ", "D" , 8 , 0 )

ProcRegua(TMP->(RecCount()))

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	IncProc('Calculando Reajuste')
	
	lAtualizado := .F.
		
	IF ( cMesAnoAtu == ( StrZero(Month(TMP->E1_XDTREAJ),2) + StrZero(Year(TMP->E1_XDTREAJ),4) ) )
		lAtualizado := .T.
	EndIF
		
	IF lAtualizado
			
		nVlrAtu := TMP->E1_XVALANT		// Preco Anterior
		nVlrNew	:= TMP->E1_VALOR 		// Novo Preco

	Else
		nIndiceReajuste:= U_IndiceReajuste(TMP->E1_XINDICE,cPeriodo)
		nFator         := 1 - ( nIndiceReajuste / 100 )

		IF nIndiceReajuste > 0

			nVlrAtu	:= TMP->E1_VALOR
			nVlrNew	:= Round( TMP->E1_VALOR * (1 + nFator/100) , 2) 
				
		Else
				
			nVlrAtu	:= TMP->E1_VALOR
			nVlrNew	:= TMP->E1_VALOR 
				
		EndIF
		
	EndIF
		
	Aadd(aTitulos,{ .T. ,; 
					lAtualizado,;
					TMP->E1_CLIENTE ,;
					TMP->E1_NOMCLI,;
					TMP->E1_PREFIXO,;
					TMP->E1_NUM,;
					TMP->E1_PARCELA,;
					TMP->E1_TIPO,;
					TMP->E1_HIST,;
					nVlrAtu,;
					nVlrNew,;
					TMP->E1_XINDICE,;
					nIndiceReajuste,;
					nFator,;
					TMP->E1_NATUREZ,;
					TMP->E1_XDTREAJ})
	
	DbSelectArea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

If Len(aTitulos) == 0
	Aadd(aTitulos,{ .F. ,; 
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
				"",;
				0,;
				0,;
				"",;
				Ctod("  /  /    ")})
EndIf

//aSort( aClientes , , , { |x,y| x[FATTOTAL] > y[FATTOTAL] } )

DEFINE FONT oFnt  NAME "Courier" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 to aSize[6],aSize[5] TITLE "Reajuste de Mensalidades" Of oMainWnd PIXEL

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
oTitulos:bLDblClick 	:= { || Tit_EditaCelula(@oTitulos,@aTitulos)}
oTitulos:cToolTip		:= "Dê um duplo clique para Editar os valores."

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{|| nOpcao:=1 , oDlg:End() }, {|| nOpcao:= 0, oDlg:End() }) ) CENTERED

If (nOpcao == 1)
	Processa( {|lEnd| GrvTitReaj(aTitulos,cPeriodo,nIndiceReajuste,nFator,cIndice) } , "Atualizando Titulos" )
EndIf

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

Static Function Tit_EditaCelula(oTitulos,aTitulos)

IF (oTitulos:ColPos == TIT_INDICE) .And. !Empty(oTitulos:aArray[oTitulos:nAt,TIT_NUM])
	//lEditCell(@aTitulos,oTitulos,"@E 9,999.9999999",oTitulos:ColPos)


	//oTitulos:aArray[oTitulos:nAt,TIT_VALORNEW]:= Round( oTitulos:aArray[oTitulos:nAt,TIT_VALORATU] * (1 + nIndiceReajuste / 100) , 2 )
	//oTitulos:aArray[oTitulos:nAt,TIT_LOK] := .T.

ElseIF (oTitulos:ColPos == TIT_LOK)

	oTitulos:aArray[oTitulos:nAt,1]:= !oTitulos:aArray[oTitulos:nAt,1]

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

Static Function GrvTitReaj(aTitulos,cPeriodo,nIndiceReajuste,nFator,cIndice)

Local aArea		:= GetArea()
Local nX        := 0
Local aSE1		:= {}
Local cNaturez  := ""

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
				cNaturez:= SE1->E1_NATUREZ
				
				RecLock("SE1",.F.)
				
				Replace E1_NATUREZ  With ""
				Replace E1_XDTREAJ  With dDataBase
				Replace E1_XVALANT  With aTitulos[nX,TIT_VALORATU]
				Replace E1_VALOR    With aTitulos[nX,TIT_VALORNEW]
				Replace E1_SALDO    With aTitulos[nX,TIT_VALORNEW]
				Replace E1_VLCRUZ   With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEIRF  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEPIS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASECOF  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASECSL  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEINS  With aTitulos[nX,TIT_VALORNEW]
				Replace E1_BASEISS  With aTitulos[nX,TIT_VALORNEW]
		
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
				Aadd( aSE1 ,	{"E1_NATUREZ" 	,cNaturez		   								,Nil})
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
					Replace Z21_VLANT   With aTitulos[nX,TIT_VALORATU]
					Replace Z21_INDICE  With aTitulos[nX,TIT_INDICE]	
					Replace Z21_PERC    With aTitulos[nX,TIT_PERCREAJUSTE]
					Replace Z21_FATOR   With aTitulos[nX,TIT_FATOR]
					Replace Z21_PERIOD  With cPeriodo
					Replace Z21_DATA    With dDataBase
					MsUnLock()
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
