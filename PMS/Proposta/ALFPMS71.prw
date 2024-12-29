
#INCLUDE "FWEditPanel.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "TBIConn.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Set.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS71
Descricao: Apuração  de contratos

@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS71()

	Local cPerg:='AFPMS70B'

	ValidPerg(cPerg)
	iF Pergunte(cPerg,.T.)

        fMontaTela()
	End

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
CRIA SX1
@author TOTVS OESTE
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValidPerg(cPerg)

	Local aArea  := SX1->(GetArea())
	Local aRegs := {}
	Local i,j


	aAdd(aRegs,{cPerg,"01","Fornecedor de ?"   ,"",""         ,"mv_ch1","C", TAMSX3('A2_COD')[1] ,0,0,"G",""	,"mv_par01",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )
	aAdd(aRegs,{cPerg,"02","Fornecedor ate ?"  ,"",""         ,"mv_ch2","C", TAMSX3('A2_COD')[1] ,0,0,"G",""	,"mv_par02",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )
	aAdd(aRegs,{cPerg,"03","Cliente de ?"      ,"",""         ,"mv_ch3","C", TAMSX3('A1_COD')[1] ,0,0,"G",""	,"mv_par03",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA1" } )
	aAdd(aRegs,{cPerg,"04","Cliente ate ?"     ,"",""         ,"mv_ch4","C", TAMSX3('A1_COD')[1] ,0,0,"G",""	,"mv_par04",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA1" } )
	aAdd(aRegs,{cPerg,"05","Vigencia de ?"     ,"",""         ,"mv_ch5","D", 8                   ,0,0,"G",""	,"mv_par05",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	aAdd(aRegs,{cPerg,"06","Vigencia ate ?"    ,"",""         ,"mv_ch6","D", 8                   ,0,0,"G",""	,"mv_par06",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	aAdd(aRegs,{cPerg,"07","Vencimento de ?"   ,"",""         ,"mv_ch7","D", 8                   ,0,0,"G",""	,"mv_par07",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	aAdd(aRegs,{cPerg,"08","Vencimento ate ?"  ,"",""         ,"mv_ch8","D", 8                   ,0,0,"G",""	,"mv_par08",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )


	DbselectArea('SX1')
	SX1->(DBSETORDER(1))
	For i:= 1 To Len(aRegs)
		If ! SX1->(DBSEEK( AvKey(cPerg,"X1_GRUPO") +aRegs[i,2]) )
			Reclock('SX1', .T.)

			FOR j:= 1 to SX1->( FCOUNT() )
				IF j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				ENDIF
			Next j

			SX1->(MsUnlock())
		Endif

	Next i

	RestArea(aArea)
Return(cPerg)



/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Atilio
@since 30/08/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aColunas := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad,,-14)
	Local lOk         := .F.
	
	//Janela e componentes
	Private oPanGrid
	Private oBrowseTmp
	Private cAliasTmp := GetNextAlias()
	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]
	//Ordenação da tela
	Private cUltOrdem := ""
	Private lDescend  := .F.

	//------------------------
	Static 	cTitulo		:= ''//"Pedidos x Bloqueios"
	//------------------------
	Private oDlgTela	:= Nil
	Private oBrowse		:= NIL
	Private dDatDe		:= CtoD("  /  /    ")
	Private dDatAte		:= CtoD("  /  /    ")
	Private oCbxFiltro	:= Nil
	Private cFiltroSel	:= ""
	
	aSize	:= FWGetDialogSize( oMainWnd )
	cTitulo:= 'Apuração de Contratos'
	//Criando a janela
	oDlgTela := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitulo,,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. ) 

	oLayer := FWLayer():New()
	oLayer:Init(oDlgTela,.F.,.T.)

	//-- DIVISOR DE TELA SUPEIROR [ FILTRO ]
	oLayer:AddLine("LINESUP", 15 )
	oLayer:AddCollumn("BOX01", 100,, "LINESUP" )
	oLayer:AddWindow("BOX01", "PANEL01", "Filtros", 100, .F.,,, "LINESUP" ) //"Filtros"

	//-- DIVISOR DE TELA INFERIOR [ GRID ]
	oLayer:AddLine("LINEINF", 85 )
	oLayer:AddCollumn( "BOX02", 100,, "LINEINF" )
	oLayer:AddWindow( "BOX02", "PANEL02", "Apuração de contratos"	, 100, .F.,,, "LINEINF" ) 

	//-- ALOCA CADA COMPONENTE EM SEU RESPECTIVO BOX ( TPANEL )
	FPanel01( oLayer:GetWinPanel( "BOX01", "PANEL01", "LINESUP" ) ) //Contrução do Painel de Filtros
	FPanel02( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINEINF" ) ) //Contrução do Painel Pedidos x Bloqueios
	
	oDlgTela:Activate()

	//Deleta a temporária e desativa a tela de marcação
	//oTempTable:Delete()
	//oBrowseTmp:DeActivate()

	RestArea(aArea)
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel01
@Sample	        :   FPanel01()
@description    :   Cria a parte superior da janela "Filtros" e aloca ao painel 01.
	
@Param		    :   oPanel - Painel para alocar os componentes de filtro.
@Return 	    :   Null

@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function FPanel01( oPanel )


Local bFiltrar	:=	Nil

//-- Inclui a borda pora apresentacao dos componentes em tela
TGroup():New( 005, 005, (oPanel:nHeight/2) - 005, (oPanel:nWidth/2) - 010 , "Filtros", oPanel,,, .T. ) //"Filtros"
//Inclui botao filtrar -
bFiltrar := { || ExecFil("Aplicando Filtros") } 
TButton():New( 020,010, "Filtrar", oPanel, bFiltrar, 050, 013,,,, .T. ) //"Filtrar"

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} FPanel02
@Sample	        :   FPanel02()
@description	:   Cria a parte inferior da janela "Grid Browse" e aloca ao painel 02.

@Param		    :   oPanel
@Return 	    :   Null

@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function FPanel02( oPanel,lAllQry )

Local cAliasQry	:= GetNextAlias() 
Local bVisual	:= Nil
Local aIndex	:= {}
Local aSeek 	:= {} 
Local cRetChave	:= ""
Local cQuery 	:= ""
Local nTpQry	:= 0

Default lAllQry	:= .T. // Carrega todos os bloqueios

// Aplica as definicoes para um Browse de tabela temporaria
oBrowse := FWFormBrowse():New()
//oBrowse := FWMarkBrowse():New()
oBrowse:SetDescription(cTitulo)
oBrowse:SetTemporary(.T.)
oBrowse:SetAlias(cAliasQry)
oBrowse:SetDataQuery()
oBrowse:SetQuery(GetQuery())


oBrowse:SetOwner(oPanel)
oBrowse:SetDoubleClick({|| cRetChave := (oBrowse:Alias())->Z44_NUMERO, oDlgTela:End()})

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
bMark := { || If(!EMPTY((cAliasQry)->Z44_OK),'LBOK','LBNO') }
bLDblClick := { |oBrowse| Marca(oBrowse) }
//bHeaderClick := { |oBrowse| MarcaAll(oBrowse) }
oBrowse:AddMarkColumns ( bMark, bLDblClick, nil )

oBrowse:SetColumns(GetColumns(cAliasQry))
oBrowse:DisableDetails()

// ---------------------------------------------+
//  Faz o inserção dos botoes para o browse     |
// ---------------------------------------------+
oBrowse:AddButton( OemTOAnsi("Apurar Contratos") , {|| ApuraZ44() } 	,, 2 ) //"Fechar"
oBrowse:AddButton( OemTOAnsi("Fechar")		    , {|| oDlgTela:End() } 	,, 2 ) //"Fechar"
oBrowse:AddButton( OemTOAnsi("Legenda")			, {|| LegendBrw() } 	,, 2 ) //"Legenda"

// ------------------------------------------------------+
//  Cria Indices para obter a busca por pedido e Cliente |
// ------------------------------------------------------+
Aadd( aIndex, "Z44_NUMERO" )
Aadd( aSeek, { "Contrato", { {"","C",TamSx3('Z44_NUMERO')[1],0,"Contrato","@!"}  },1  } ) 

Aadd( aIndex, "Z44_NFOR" ) 
Aadd( aSeek, { "Fornecedor", { {"","C",TamSx3('Z44_NFOR')[1],0,"Fornecedor","@!"}  },2  } ) 

Aadd( aIndex, "Z44_NFFOR" )  
Aadd( aSeek, { "Nota Fornecedor", { {"","C",TamSx3('Z44_NFFOR')[1],0,"Nota Fornecedor","@!"}  },3  } ) 

Aadd( aIndex, "Z44_NUMTIT" )  
Aadd( aSeek, { "Numero Titulo", { {"","C",TamSx3('Z44_NFFOR')[1],0,"Numero Titulo","@!"}  },4  } ) 


//Aadd( aIndex, "C5_CLIENTE+C5_LOJACLI" )
//Aadd( aSeek, { "Cliente+Loja" , {	{"","C",TamSx3('C5_CLIENTE')[1],0,"Cliente"	,"@!"} ,;
//									{"","C",TamSx3('C5_LOJACLI')[1],0,"Loja"	,"@!"} },3  } ) 
//
Aadd( aIndex, "STATUS" ) 
Aadd( aSeek, { "Status", { {"","C",01,0,"Status","@!"}  },5  } ) 

oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)
//-------------------------
// Ativa exibição do browse 
oBrowse:Activate()

Return()

/*{Protheus.Doc} Marca    
Função para marcar os itens.
@project 	MAN00000010101_EF_003
@param  	oBrowse Objeto da tela     
@author  	Alexandre Arume 
@version 	P11 R1.0
@since   	29/09/2014  
@menu	
*/
Static Function Marca(oBrowse,lTodos,lMarcar)

	Local cAlias		:= oBrowse:cAlias
	Local aAreaSav	:= GetArea()

	Default lTodos	:= .F.
	Default lMarcar	:= .F.
	
	If lTodos 
		(cAlias)->(dbGoTop())
		While !(cAlias)->(Eof())
            If (cAlias)->STATUS == '1'
                If RecLock(cAlias, .F.)
                    (cAlias)->Z44_OK := If(lMarcar,'1',' ')
                    (cAlias)->(MsUnlock())
                    
                Endif
            End
			(cAlias)->(dbSkip())
		EndDo
		oBrowse:Refresh(.T.)
	Else
        If (cAlias)->STATUS == '1'
            If RecLock(cAlias, .F.)
                (cAlias)->Z44_OK := IIf(Empty((cAlias)->Z44_OK), '1', ' ')
                (cAlias)->(MsUnlock())
            Endif
        End
	EndIf
	
	RestArea(aAreaSav)

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
@Sample	        :   Retorna consulta sql de pedidos x bloqueios 
@description    :   Monta consulta sql para buscar os pedidos que possuem bloqueios. 
@Param		    :   nTipo = 1 Query para buscar os pedidos bloqueados por estoque
                    nTipo = 2 Query para buscar os pedidos excluidos por usuario
                    nTipo = 3 Query para buscar os pedidos com romaneio cancelado
@Return 	    :   cQuery

@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function GetQuery()

Local cQryDados 	:= ""

//Monta a consulta
cQryDados += " SELECT '  ' Z44_OK "        + CRLF
cQryDados += " ,Z44_STATUS STATUS "+CRLF
cQryDados += " ,Z44_NUMERO "+CRLF
cQryDados += " ,Z44_FORNEC "+CRLF
cQryDados += " ,Z44_LJFOR "+CRLF
cQryDados += " ,Z44_NFOR "+CRLF
cQryDados += " ,Z42_NCLI "+CRLF

cQryDados += " ,Z44_PARCEL "+CRLF
cQryDados += " ,Z44_VALOR "+CRLF
cQryDados += " ,Z44_VENCTO "+CRLF
cQryDados += " ,Z44_DIAVEN "+CRLF
cQryDados += " ,Z44_VENCRE "+CRLF
cQryDados += " ,Z44_MESREF "+CRLF
cQryDados += " ,Z44_INICOB "+CRLF
cQryDados += " ,Z44_DTFIM "+CRLF
cQryDados += " ,Z44_MULTA "+CRLF
cQryDados += " ,Z44_NFFOR "+CRLF
cQryDados += " ,Z44_NUMTIT "+CRLF
cQryDados += " ,Z44_DTBX "+CRLF
cQryDados += " ,Z44.R_E_C_N_O_ RECNO "
cQryDados += "FROM "        + CRLF
cQryDados += RetSqlName('Z44')+"  Z44 "+ CRLF
cQryDados += " INNER JOIN "+RetSqlName('Z42')+" Z42 "+CRLF
cQryDados += " ON Z42_FILIAL = Z44_FILIAL "+CRLF
cQryDados += " AND Z42_NUMERO = Z44_NUMERO "+CRLF
cQryDados += " AND Z42_FORNEC = Z44_FORNEC"+CRLF
cQryDados += " AND Z42_LJFOR = Z44_LJFOR"+CRLF
//1=Contrato Incluso;2=Aguardando Aprovação;3=Aprovado;4=Reprovado
//cQryDados += " AND Z42_STATUS = '3' "+CRLF 

cQryDados += " AND Z42.D_E_L_E_T_='' "+CRLF
cQryDados += "WHERE "        + CRLF
cQryDados += " Z44_FILIAL = '" + FWxfilial('Z44') + "' "        + CRLF
cQryDados += " AND Z44_FORNEC  BETWEEN '" + MV_PAR01 + "'  AND '"+MV_PAR02+"' "+ CRLF
cQryDados += " AND Z44_CLIENT  BETWEEN '" + MV_PAR03 + "'  AND '"+MV_PAR04+"' "+ CRLF 

//cQryDados += " AND Z44_CLIENT  BETWEEN '" + DTOS(MV_PAR05) + "'  AND '"+DTOS(MV_PAR06)+"' "        + CRLF 
cQryDados += " AND Z44_VENCRE  BETWEEN '" + DTOS(MV_PAR07) + "'  AND '"+DTOS(MV_PAR08)+"' "        + CRLF 

cQryDados += " AND Z44.D_E_L_E_T_ = ' ' "        + CRLF


Return(cQryDados)

//---------------------------------------------------------------------
/*/{Protheus.doc} ExecFil
@Sample	UpdateBrw()
	Executa rotina de atualização do browse com opção de tela de processamento. 
@Param		cMsgRun

@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function ExecFil(cMsgRun)

Local cPerg:='AFPMS70B'
Default cMsgRun	:=  "" 

iF Pergunte(cPerg,.T.)


	If !Empty(cMsgRun)
		FWMsgRun( ,{|| UpdateBrw() },"Aguarde",cMsgRun)	
	Else
		CursorWait()
		UpdateBrw()
		CursorArrow()
	EndIf

End

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} UpdateBrw
@Sample	UpdateBrw()
	Faz atualização dos dados que estao no browse (REFRESH) 
@Param		Null

@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function UpdateBrw()

oBrowse:Data():DeActivate()
oBrowse:SetQuery( GetQuery() )
oBrowse:Data():Activate()
oBrowse:UpdateBrowse(.T.)
oBrowse:GoBottom()
oBrowse:GoTo(1,.T.)
oBrowse:Refresh(.T.)

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} GetColumns
@Sample	GetColumns()
	Rotina responsavel por montar a estrutura das colunas do Browse.
	
@Param		cAlias
@Return 	aColumns Estrutura de colunas do Browse - FwFormBrowse
@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function GetColumns(cAlias)

Local aArea	:= GetArea()
Local cCampo	:= ""
Local aCampos	:= {}
Local aColumns	:= {}
Local nX		:= 0
Local nLinha	:= 0
Local cIniBrw	:= ""
Local aCpoQry	:= {}


aCampos := {'Z44_STATUS'	, ;	
			'Z44_NFOR',;
			'Z42_NCLI',;
			'Z44_NUMERO'	, ; //'Z44_FORNEC', 'Z44_LJFOR',;						
			'Z44_PARCEL',;
			'Z44_VALOR',;
			'Z44_VENCTO',;
			'Z44_DIAVEN',;
			'Z44_VENCRE',;
			'Z44_MESREF',;
			'Z44_INICOB',;
			'Z44_DTFIM',;
			'Z44_MULTA',;
			'Z44_NFFOR',;
			'Z44_NUMTIT',;
			'Z44_DTBX',;
            'RECNO' }


DbSelectArea("SX3")
DbSetOrder(2)//X3_CAMPO

AAdd(aColumns,FWBrwColumn():New())
nLinha := Len(aColumns)
//aColumns[nLinha]:SetData(&(  "{ || IIF( ('"+cAlias+"')->Z44_STATUS =='1','BLUE', IIF( ('"+cAlias+"')->Z44_STATUS == '2','YELLOW', IIF( ('"+cAlias+"')->Z44_STATUS == '3','GREEN','RED') ) ) } "))
//aColumns[nLinha]:SetData(&(  "{ || IIF( ('"+cAlias+"')->STATUS =='1','BLUE', IIF( ('"+cAlias+"')->STATUS == '2','YELLOW', IIF( ('"+cAlias+"')->STATUS == '3','GREEN','RED') ) ) } "))
//aColumns[nLinha]:SetData(&(  "{ || IIF( (cAlias)->STATUS =='1','BR_LARANJA', IIF( (cAlias)->STATUS == '2','BR_VERMELHO','BR_PINK')) } "))
aColumns[nLinha]:SetData(&(  "{ || IIF( (cAlias)->STATUS =='1','BR_AZUL', IIF( (cAlias)->STATUS == '2','BR_AMARELO', IIF( (cAlias)->STATUS == '3','BR_VERDE', IIF( (cAlias)->STATUS == '0','BR_CINZA','BR_VERMELHO') ) )  )  } "))

//oColumn:SetData(&(  "{ || IIF( (cAliasTmp)->Z44_STATUS =='1','BLUE', IIF( (cAliasTmp)->Z44_STATUS == '2','YELLOW', IIF( (cAliasTmp)->Z44_STATUS == '3','GREEN','RED') ) ) } "))
aColumns[nLinha]:SetTitle("")
aColumns[nLinha]:SetType("C")
aColumns[nLinha]:SetPicture("@BMP")
aColumns[nLinha]:SetSize(1)
aColumns[nLinha]:SetDecimal(0)
aColumns[nLinha]:SetDoubleClick({|| LegendBrw() })
aColumns[nLinha]:SetImage(.T.)
//@E 9,999,999,999,999.99
For nX := 1 To Len(aCampos)
	If SX3->(DbSeek(AllTrim(aCampos[nX]))) .and. aCampos[nX] <>'Z44_STATUS'
		If (X3USO(SX3->X3_USADO) .AND. SX3->X3_BROWSE == "S" .AND. SX3->X3_TIPO <> "M") .OR. SX3->X3_CAMPO = "Z44_FILIAL"
			AAdd(aColumns,FWBrwColumn():New())
			nLinha	:= Len(aColumns)
			cCampo 	:= AllTrim(SX3->X3_CAMPO)
			cIniBrw := AllTrim(SX3->X3_INIBRW)
			aColumns[nLinha]:SetType(SX3->X3_TIPO)
			If SX3->X3_CONTEXT <> "V"
				aAdd(aCpoQry,cCampo)
				If SX3->X3_TIPO = "D"
					aColumns[nLinha]:SetData( &("{|| sTod("  + "('"+cAlias+"')->" + cCampo + ") }") )
				ElseIf SX3->X3_TIPO = "N"
					aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
					aColumns[nLinha]:SetPicture( PesqPict('Z44',cCampo) )
				ElseIf !Empty(X3CBox())
					aColumns[nLinha]:SetData( &("{|| X3Combo('" +  cCampo + "',('"+cAlias+"')->" + cCampo + ") }") )
				Else
					aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
				EndIf
			Else
				aColumns[nLinha]:SetData( &("{|| U_LbRetBrw(" + "'"+cIniBrw+"','"+cAlias+"'" + ") }") )
			EndIf
			aColumns[nLinha]:SetTitle(X3Titulo())
			aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
			aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)

			// Adiciona na memoria o conteudo da celula ao realizar o duplo click
			If aCampos[nX] $ "Z44_NUM|Z44_NUMERO||"
				aColumns[nLinha]:SetDoubleClick( &("{|| CopytoClipboard(" + "('"+cAlias+"')->" + cCampo + ") }") )
			EndIf 

		EndIf
	ElseIf aCampos[nX] == "RECNO"
		
		cCampo := "RECNO"
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
		aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
		aColumns[nLinha]:SetTitle("RECNO")
		aColumns[nLinha]:SetType("C")
		aColumns[nLinha]:SetPicture("9999999")
		aColumns[nLinha]:SetSize(7)
		aColumns[nLinha]:SetDecimal(0)
		aColumns[nLinha]:SetDoubleClick( &("{|| CopytoClipboard(" + "('"+cAlias+"')->" + cCampo + ") }") )

	EndIf
Next nX

RestArea(aArea)

Return(aColumns)


//---------------------------------------------------------------------
/*/{Protheus.doc} 
@Sample	
	Executa funcao definida no inicializador padrao do browse X3_INIBRW
@Param		cIniBrw -> 
			cAlias	->

@Return 	cRetorno
@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
User Function LbRetBrw(cIniBrw,cAlias)
Local cRetorno := ""

DbSelectArea(cAlias)
DbSetOrder(1)//

If DbSeek(xFilial(cAlias)+(cAlias)->C5_NUM)
	cRetorno := &(cIniBrw)
EndIf    

Return(cRetorno)  


//---------------------------------------------------------------------
/*/{Protheus.doc} LegendBrw
@Sample	LegendBrw()
	Monta interface com as legenda do browse
@Param		Null
@Return 	Null
@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function LegendBrw()

Local oLegenda  :=  FWLegend():New()
//0=Agt.Liberacao;1=Liberado;2=Aguardando Baixa do Pagto;3=Pago;4=Bloqueado
oLegenda:Add("","BR_CINZA"	    ,"Agt.Liberacao")
oLegenda:Add("","BR_AZUL"	    ,"Liberado	")
oLegenda:Add("","BR_AMARELO" 	,"Aguardando Baixa")
oLegenda:Add("","BR_VERDE"		,"Pago")
oLegenda:Add("","BR_VERMELHO"	,"Bloqueado")
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} ApuraZ44

Apura z44 e gera contas a pagar

@Param		Null
@Return 	Null
@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function ApuraZ44()
Local cMsgRun:= 'Atualizando dados'
Local aSe2   := {}

private aParamBox := {}
private aRetParam := {}
Private dDtVenc := CriaVar("E2_EMISSAO",.F.)

AADD( aParamBox, { 1, "Data Pagamento"      , dDtVenc  , "@!", "MV_PAR01 >=DATE() ", ""   , "", 50, .t.} )
cAlias:= oBrowse:calias
//oBrowse:calias
//oBrowse:crealalias
If MSGYESNO('Confirma a apuração dos contratos marcados ? ')
	(cAlias)->( dbGoTop())
    While (cAlias)->(!Eof())
        If alltrim((cAlias)->Z44_OK) == '1'

			nscan := Ascan(aSe2,{|x| x[1]+x[2] == (cAlias)->Z44_FORNEC + (cAlias)->Z44_LJFOR})
			if nscan > 0 
				aSe2[nscan][3] += (cAlias)->Z44_VALOR
				aadd(aSe2[nscan][4], (cAlias)->RECNO )
			else
				aadd(aSe2,{  (cAlias)->Z44_FORNEC ,;
							 (cAlias)->Z44_LJFOR ,;
							 (cAlias)->Z44_VALOR,;
							 { (cAlias)->RECNO  } }) 
			end							
        End
        (cAlias)->(dbSkip())
    EndDo
	
	If len(aSe2) > 0 .AND. ParamBox(aParamBox,"Informe a data de pagamento",@aRetParam)
		dDtVenc:= aRetParam[1]
		FWMsgRun( ,{|| GeraFinSE2(aSe2,dDtVenc) },"Aguarde","Gerando pagamento...")	
		//FWMsgRun(, {|| lRetorno := GeraSE2(cPrefixo, cNumTit, cParcela, cTipo, cNatureza, cCodFor, cLojFor, dDtVenc, cHist, nVlrComis, cEmpFat,nOpcExec) }, "Aguarde", "Gerando pagamento...")
		cPerg:='AFPMS70B'		
		Pergunte(cPerg,.f.)
		
	End
End

FWMsgRun( ,{|| UpdateBrw() },"Aguarde",cMsgRun)	
/*
oBrowse:Data():DeActivate()
oBrowse:SetQuery( GetQuery() )
oBrowse:Data():Activate()
oBrowse:UpdateBrowse(.T.)
oBrowse:GoBottom()
oBrowse:GoTo(1,.T.)
oBrowse:Refresh(.T.)
*/
Return



//---------------------------------------------------------------------
/*/{Protheus.doc} GeraFinSE2

Gera contas a pagar

@Param		Null
@Return 	Null
@Author		pedro.oliveira
@Since		24/07/2024	
@Version	12.1.17
/*/
//--------------------------------------------------------------------- 
Static Function GeraFinSE2(aSe2 , dDtVenc )

local nx	:=0
local ny	:=0
Local aAreaAtu  := GetArea()
Local aAreaSE2  := SE2->(GetArea())
Local aCposSE2	:= {}
Local lRetorno  := .T.


Local cEmpFat   := ''
Local cTipo     := 'DP '
Local cNatureza := ''
//Local dDtVenc   := SZH->ZH_DTPAGTO
Local cHist     := 'PAGAMENTO DE CONTRATOS'
Local cPrefixo	:= "MAN"
Local cNumTit   := ""
Local cParcela  := StrZero(1, TamSx3("E2_PARCELA")[1])
Local lRetorno  := .F.
Local cMaySE2 	:= "SE2"+AllTrim(xFilial("SE2"))
Local nOpcExec  := 3
Local nSaveSX8 	:= GetSX8Len()

Private lMsErroAuto	    := .F.
Private lMsHelpAuto 	:= .T.
//Private lAutoErrNoFile 	:= .T.

for nx:=1 to len(aSe2)
	lMsErroAuto:= .f.
	cNatureza   := Posicione('SA2',1,xFilial('SA2')+ aSe2[nx][1] + aSe2[nx][2],'A2_NATUREZ')
	cParcela    := StrZero(1, TamSx3("E2_PARCELA")[1])
	cCodFor		:= ase2[nx][1]
	cLojFor		:= ase2[nx][2]
	nVlrComis   := ase2[nx][3]
	cEmpFat		:= '1'
	// Verifica se o numero ja foi gravado
	cNumTit := GetSxeNum("SE2","E2_NUM")
	DbSelectArea("SE2")
	DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	While DbSeek(xFilial("SE2")+cPrefixo+cNumTit) .OR. !MayIUseCode(cMaySE2+cPrefixo+cNumTit)
		cNumTit := GetSxeNum("SE2","E2_NUM")
	EndDo
	
	nOpcao    := 3 
	aCposSE2:= {}
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
	AADD( aCposSE2, {"E2_ORIGEM"	,"FINA050"					,Nil})
	AADD( aCposSE2, {"E2_EMPFAT"    ,cEmpFat			 		,Nil})
	AADD( aCposSE2, {"E2_XVLRNF"    ,nVlrComis			 		,Nil})

	//Gravacao do Titulo a Pagar
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCposSE2,, nOpcao)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	If lMsErroAuto
		DisarmTransaction()
		lRetorno := .F.

		MostraErro()
	Else
		for ny := 1 to len(ase2[nx][4])
			Z44->( DbGoTo(ase2[nx][4][ny]) )
			Z44->( RECLOCK('Z44',.F.) )
				Z44->Z44_NUMTIT := cPrefixo+cNumTit+cParcela
				Z44->Z44_STATUS := '2' // AGUARDANDO BAIXA
			Z44->(MSUNLOCK())
		next ny 
	EndIf

next nx


RestArea(aAreaSE2)
RestArea(aAreaAtu)

Return lRetorno
