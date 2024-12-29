#Include "Protheus.ch"      
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"
#Include "TopConn.ch"
           
#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4   
#Define CRLF	Chr(10)+Chr(13)

Static lJaExecutou 		:= .F.		   		// Usado na funcao SyOrdCab()
Static nlOrdemCols	:= .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SYFINA01 ³ Autor ³   Fabio Rogerio       ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Conferencia de Pagamentos de Fornecedores        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SYFINA01()
Local oRodape
Local oFldEscopo
Local oCab
Local nI,nX
Local nStyle 		:= GD_INSERT+GD_UPDATE+GD_DELETE
Local oFnt 			:= TFont():New( "Arial",,15,,.T.,,,,,.F.)
Local cNomeFor		:= CriaVar("A2_NOME",.F.)
Local oNomeFor
Local cNomeCli		:= CriaVar("A1_NOME",.F.)
Local oNomeCli
Local oShowInd
Local aSize			:= {}
Local cTitle		:= ""
Local oPnlMaster
Local oPnlTit
Local lGrava		:= .F.
Local aAlterRes		:= {}
Private oResumo
Private oCodFor
Private oCodCli
Private oPropos
Private oQtdLic
Private oVenLic
Private oCusLic 
Private oMarLic
Private oOnVenLic
Private oOnCusLic 
Private oOnMarLic
Private oMod
Private lAdm        := .T. //compatibilidade com a tela de pesquisa de clientes
Private INCLUI		:= .F.
Private ALTERA		:= .T.
Private nlOrdemCols	:= .F.
Private aHeadRes  	:= {}
Private aColsRes  	:= {}
Private aHeadProd  	:= {}
Private aColsProd  	:= {}
Private aMod 		:= {'TODOS' , '1 = SaaS' , '2 = On Premise' , '3 = Adesao/Setup', '4 = Suporte Mensal' }
Private cCodFor		:= CriaVar("A2_COD",.F.)
Private cCodCli		:= CriaVar("A1_COD",.F.)
Private cPropos 	:= CriaVar("Z02_PROPOS",.F.)
Private cCadastro 	:= ''
Private cMod 		:= 'TODOS'
Private nQtdLic     := 0
Private nVenLic     := 0
Private nCusLic     := 0
Private nMarLic     := 0
Private nOnVenLic   := 0
Private nOnCusLic   := 0
Private nOnMarLic   := 0
Private nOpc  		:= 4
Private nPModulo  	:= 0
Private nPrcCusto 	:= 0
Private nPPrcTab   	:= 0
Private nPPrcVen	:= 0
Private nPModalidade:= 0
Private nPProposta  := 0
Private nPAditivo   := 0
Private nPCusTot    := 0
Private nPQuantidade:= 0
Private nPMargem    := 0
Private nPManutA    := 0
Private nPData      := 0
Private nPVlrMes    := 0
Private nRecno    	:= 0
Private nPPrdDescri := 0
Private nPPrdQuant  := 0
Private nPPrdVlrMes := 0
Private nPPrdTotal  := 0
Private nPPrdCustot := 0
Private nPPrdMargem := 0
Private nPPrdModulo := 0

Private oCodCliAte := nil  
Private cCodCliAte := CriaVar("A1_COD",.F.)

Private oEmp := nil
Private aEmp := {'TODAS','1=ALFA(07)','2=MOOVE','3=GNP',';4=ALFA(24)','5=CAMPINAS','6=COLABORACAO'}

Private cEmp := 'TODAS'


Private dDtApvde := ctod('')
Private dDtApvate:= ctod('')

private oDtApvde := nil
private oDtApvate:= nil

IF (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" )
	lAdm := .T.
EndIF

aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'AxInclui'			, 0,3} ,;
				{ 'Alterar'			,'AxAltera'			, 0,4} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o resumo do escopo do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize    := MsAdvSize()
cTitle   := "Conferencia de Pagamentos"

DEFINE MSDIALOG oShowInd FROM  0,0 to aSize[6],aSize[5] TITLE cTitle Of oMainWnd PIXEL STYLE DS_MODALFRAME 

oShowInd:lEscClose	:= .F.
oShowInd:lMaximized	:= .T.

oPnlMaster:= TPanel():New(0, 0, "", oShowInd, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPnlMaster:Align:= CONTROL_ALIGN_ALLCLIENT

oPnlTit:= TPanel():New(0, 2,'CONFERENCIA DE CUSTOS E PAGAMENTOS', oPnlMaster , NIL, .T., .F., NIL, NIL, 0,10, .T., .F. )
oPnlTit:Align	:= CONTROL_ALIGN_TOP
oPnlTit:nClrPane:= Rgb(112,128,144)
oPnlTit:oFont:= oFnt

oCab:= TPanel():New(0, 2,"", oPnlMaster , NIL, .T., .F., NIL, NIL, 0,50, .T., .F. )
oCab:Align	:= CONTROL_ALIGN_TOP

@ 005,005 SAY "Fornecedor:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 005,050 MSGET oCodFor  VAR cCodFor  OF oCab Valid(Empty(cCodFor) .Or. ExistCpo("SA2",cCodFor)) PICTURE PesqPict("SA2", "A2_COD") SIZE 40,10 F3 "SA2SOF" FONT oFnt When ( lAdm .And. Empty(cPropos) ) PIXEL
//@ 005,100 MSGET oNomeFor VAR cNomeFor OF oCab PICTURE PesqPict("SA2", "A2_NOME") SIZE 200,10 FONT oFnt When .F. PIXEL
@ 005,100 MSGET oNomeFor VAR cNomeFor OF oCab PICTURE PesqPict("SA2", "A2_NOME") SIZE 100,10 FONT oFnt When .F. PIXEL
oCodFor:bLostFocus:= {|| 	cNomeFor 	:= Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME") , oNomeFor:Refresh() }

@ 005,200 SAY "Dt.Aprov.De:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 005,250 MSGET oDtApvde  VAR dDtApvde	OF oCab PICTURE PesqPict("SUS","US_DTPRXCO") SIZE 40,10 When .T. SIZE 055,010 FONT oFnt PIXEL

@ 005,300 SAY "Dt.Aprov.Até:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 005,350 MSGET oDtApvate  VAR dDtApvate	OF oCab PICTURE PesqPict("SUS","US_DTPRXCO") SIZE 40,10 When .T. SIZE 055,010 FONT oFnt PIXEL

@ 020,005 SAY "Cliente de:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 020,050 MSGET oCodCli  VAR cCodCli  OF oCab Valid(Empty(cCodCli) .Or. ExistCpo("SA1",cCodCli)) PICTURE PesqPict("SA1", "A1_COD") SIZE 40,10 F3 "SYMOS1" FONT oFnt When ( lAdm .And. Empty(cPropos) ) PIXEL
@ 020,100 MSGET oNomeCli VAR cNomeCli OF oCab PICTURE PesqPict("SA1", "A1_NOME") SIZE 100,10 FONT oFnt When .F. PIXEL

@ 020,200 SAY "Cliente ate:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 020,250 MSGET oCodCliAte  VAR cCodCliAte  OF oCab Valid( .T.  ) PICTURE PesqPict("SA1", "A1_COD") SIZE 40,10 F3 "SYMOS1" FONT oFnt When ( lAdm .And. Empty(cPropos) ) PIXEL
//@ 020,300 MSGET oNomeCli VAR cNomeCli OF oCab PICTURE PesqPict("SA1", "A1_NOME") SIZE 200,10 FONT oFnt When .F. PIXEL
@ 020,300 MSCOMBOBOX oEmp VAR cEmp	ITEMS aEmp SIZE 080,14 OF oCab PIXEL When .T.

oCodCli:bLostFocus:= {|| 	cNomeCli 	:= Posicione("SA1",1,xFilial("SA1")+cCodCli,"A1_NOME") , oNomeCli:Refresh() }

@ 035,005 SAY "Proposta:"	OF oCab FONT oFnt COLOR CLR_BLACK Pixel SIZE 150,15
@ 035,050 MSGET oPropos  VAR cPropos  OF oCab Valid( Empty(cPropos) .Or. ExistCpo("Z02",cPropos) ) PICTURE PesqPict("Z02","Z02_PROPOS") SIZE 40,10 FONT oFnt When ( Empty(cCodFor) .And. Empty(cCodCli) ) PIXEL

@ 035,100 MSCOMBOBOX oMod VAR cMod	ITEMS aMod SIZE 080,14 OF oCab PIXEL When .T.

TButton():New( 034 , 200 , "Filtrar" 			, oCab , {|| MontaaCols() 										}	,100,14,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 005 , 400 , "Ver Proposta" 		, oCab , {|| VerProposta(oResumo) 								}	,100,14,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 034 , 400 , "Exportar Excel" 	, oCab , {|| U_SyExporExcel('Custos',aHeadRes,aColsRes,.F.)	}	,100,14,,,.F.,.T.,.F.,,.F.,,,.F. )

oPnlEscopo:= TPanel():New(0, 2,, oPnlMaster , NIL, .T., .F., NIL, NIL, 0,150, .T., .F. )
oPnlEscopo:Align	:= CONTROL_ALIGN_TOP

oPnlResumo:= TPanel():New(0, 2,, oPnlMaster , NIL, .T., .F., NIL, NIL, 0,50, .T., .F. )
oPnlResumo:Align	:= CONTROL_ALIGN_ALLCLIENT
oPnlResumo:nHeight  := oPnlResumo:nHeight-20

MontaaHeader()

Aadd(aAlterRes,"Z05_QUANT")
Aadd(aAlterRes,"Z05_CUSTO")
Aadd(aAlterRes,"Z05_DATA")
Aadd(aAlterRes,"Z05_MANUTA")
Aadd(aAlterRes,"Z05_PRCTAB")
Aadd(aAlterRes,"Z05_MODULO")

oResumo:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue"	,"",aAlterRes,,,,,,oPnlEscopo,@aHeadRes,@aColsRes)
oResumo:oBrowse:bHeaderClick := { |oObj,nCol| SyOrdena(nCol,@oResumo,@nlOrdemCols) }
oResumo:oBrowse:bChange := {|| AtuZ02(oResumo,nPProposta) }
oResumo:oBrowse:Refresh()
oResumo:nAt:= 1
oResumo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oResumo:cFieldOk := "U_SyCalcCusto(@oResumo)"    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o resumo financeiro.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFldResumo:= Nil
oFldResumo:=TFolder():New(1,1,{"Resumo","Totais"},{"HEADER","HEADER"},oPnlResumo,,,,.T.,.F.,1,1)
oFldResumo:Align := CONTROL_ALIGN_ALLCLIENT
xAlter:={'Z00_DESCRI','Z05_QUANT','Z05_VLRMES','Z05_TOTAL','Z05_CUSTOT','Z05_MODULO'}
oResProd:= Nil
oResProd:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue","AllWaysTrue"    , ,xAlter    ,,99999,,,,oFldResumo:aDialogs[1],@aHeadProd,@aColsProd)
//oResProd:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue"	,"",aAlterRes,,     ,,,,oPnlEscopo,@aHeadRes,@aColsRes)
oResProd:lInsert:= .F.
oResProd:oBrowse:Refresh()
oResProd:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
oResProd:oBrowse:bHeaderClick		:= { |oObj,nCol| U_SyOrdena(nCol,@oResProd,@nlOrdemCols,'OP') }

oRodape:= TPanel():New(0, 2,"", oFldResumo:aDialogs[2] , NIL, .T., .F., NIL, NIL, 0,60, .T., .F. )
oRodape:Align	:= CONTROL_ALIGN_BOTTOM

@ 003,005 SAY "Quantidade (Licencas): "			OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 080,15
@ 003,080 SAY oQtdLic VAR nQtdLic			    OF oRodape PICTURE '@E 999,999,999'		FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 003,150 SAY "Venda(SaaS):"				   	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 003,200 SAY oVenLic VAR nVenLic			    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 018,150 SAY "Custo(SaaS):"		           	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 018,200 SAY oCusLic VAR nCusLic			    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 033,150 SAY "Margem:"			            	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 033,200 SAY oMarLic VAR nMarLic			    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 003,350 SAY "Venda(OnPremise):"			  	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 003,400 SAY oOnVenLic VAR nOnVenLic		    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 018,350 SAY "Custo(OnPremise):"		      	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 018,400 SAY oOnCusLic VAR nOnCusLic		    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

@ 033,350 SAY "Margem:"			            	OF oRodape FONT oFnt COLOR CLR_BLACK 								Pixel SIZE 060,15
@ 033,400 SAY oOnMarLic VAR nOnMarLic		    OF oRodape PICTURE '@E 999,999,999.99' 	FONT oFnt COLOR CLR_RED 	Pixel SIZE 060,15

ACTIVATE MSDIALOG oShowInd ON INIT ( EnchoiceBar( oShowInd , {|| ( lGrava := .T. , oShowInd:End() ) } , {||IIF( MsgYesNo("Deseja sair sem Gravar as Alterações?") , oShowInd:End() , .F. ) } ,, ) ) CENTERED

If lGrava
    
	For nI:= 1 To Len(oResumo:aCols)
        
        DbSelectArea("Z05")
        
        DbGoTo( oResumo:aCols[nI,nRecno] )
		
		IF oResumo:aCols[nI,Len(oResumo:aHeader)+1]
		
			RecLock("Z05",.F.)
			DbDelete()
			MsUnLock()
        
		Else
		
			RecLock("Z05",.F.)
			Z05_MODULO	:= oResumo:aCols[nI,nPModulo]
			Z05_CUSTO  	:= oResumo:aCols[nI,nPrcCusto]
			Z05_CUSTOT 	:= oResumo:aCols[nI,nPCusTot]
			Z05_MARGEM 	:= oResumo:aCols[nI,nPMargem]
			Z05_DATA   	:= oResumo:aCols[nI,nPData]
			Z05_MANUTA 	:= oResumo:aCols[nI,nPManutA]
			MsUnLock()
		
		EndIF
		
	Next nI

EndIf

Return(.T.)

Static Function MontaaHeader()

Local nC	  := 0
Local nI      := 0
Local aCampos := {'A1_NREDUZ','Z05_PROPOS','Z05_ADITIV','Z02_DTAPRO','Z00_DESCRI','Z05_QUANT','Z05_CUSTO','Z05_CUSTOT','Z05_MANUTA','Z05_DATA','Z05_PRCVEN','Z05_VLRMES','Z05_TOTAL','Z05_PRCTAB','Z05_PERDES','Z05_MARGEM','Z05_MOD','A1_COD','Z05_MODULO','A2_COD','A2_NREDUZ'}
Local aCposPrd:= {'Z00_DESCRI','Z05_QUANT','Z05_VLRMES','Z05_TOTAL','Z05_CUSTOT','Z05_MARGEM','Z05_MODULO'}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader do Resumo.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Len(aHeadRes) == 0

	For nC := 1 To Len(aCampos)
	
		SX3->(DbSetOrder(2))
		
		IF SX3->( DbSeek(aCampos[nC]) )
			
			Aadd(aHeadRes,{TRIM(x3titulo()),;
			SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
			SX3->X3_F3,SX3->X3_CONTEXT,	SX3->X3_CBOX,SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL})
			IF ALLTRIM(SX3->X3_CAMPO) $  "Z05_QUANT/Z05_CUSTO/Z05_DATA/Z05_MANUTA/Z05_PRCTAB/Z05_MODULO/"
				aHeadRes[LEN(aHeadRes)][14] :=  'A'
			END	

    	EndIF
	
	Next
	
	Aadd(aHeadRes,{'R_E_C_N_O_','R_E_C_N_O_','999999999',9,0,'','','N','','','','',".T."})
	
EndIF

IF Len(aColsRes) == 0
	Aadd(aColsRes,Array(Len(aHeadRes)+1))
	For nI := 1 to Len(aHeadRes)
		IF aHeadRes[nI,2] == 'R_E_C_N_O_'
			aColsRes[Len(aColsRes),nI] := 0
		Else
			aColsRes[Len(aColsRes),nI] := CriaVar(aHeadRes[nI,2],.T.)
		EndIF
	Next nI
	aColsRes[Len(aColsRes),Len(aHeadRes)+1] := .F.
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader do Resumo de Produtos.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Len(aHeadProd) == 0

	For nC := 1 To Len(aCposPrd)
	
		SX3->(DbSetOrder(2))
		
		IF SX3->( DbSeek(aCposPrd[nC]) )
			
			Aadd(aHeadProd,{TRIM(x3titulo()),;
			SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
			SX3->X3_F3,SX3->X3_CONTEXT,	SX3->X3_CBOX,SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL})
			//IF ALLTRIM(SX3->X3_CAMPO) <>  'Z05_MARGEM'
			//	aHeadProd[LEN(aHeadProd)][14] :=  'A'
			//END
    	EndIF
	Next
EndIF

IF Len(aColsProd) == 0
	Aadd(aColsProd,Array(Len(aHeadProd)+1))
	For nI := 1 to Len(aHeadProd)
		aColsProd[Len(aColsProd),nI] := CriaVar(aHeadProd[nI,2],.T.)
	Next nI
	aColsProd[Len(aColsProd),Len(aHeadProd)+1] := .F.
EndIF

//Atualiza as posicoes dos vetores
nPModulo  	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_MODULO"	})
nPrcCusto 	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_CUSTO"		})
nPPrcTab   	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PRCTAB"	})
nPPrcVen	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PRCVEN"	})
nPModalidade:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_MOD"		})
nPProposta  := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PROPOS"	})
nPAditivo   := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_ADITIV"	})
nPCusTot    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_CUSTOT"	})
nPQuantidade:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_QUANT"		})
nPMargem    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_MARGEM"	})
nPManutA    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_MANUTA"	})
nPData      := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_DATA"		})
nPVlrMes    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_VLRMES"	})
nRecno    	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "R_E_C_N_O_"	})
nPPrdDescri := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z00_DESCRI"   })
nPPrdQuant  := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_QUANT"    })
nPPrdVlrMes := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_VLRMES"   })
nPPrdTotal  := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_TOTAL"    })
nPPrdCustot := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_CUSTOT"   })
nPPrdMargem := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_MARGEM"   })
nPPrdModulo := aScan(aHeadProd,{|x| AllTrim(x[2]) == "Z05_MODULO"   })
nPCodFor    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "A2_COD"        })
nPNomFor    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "A2_NREDUZ"     })


Return(.T.)

Static Function MontaaCols()

Local cQuery := ""
Local nX     := 0
Local nI     := 0

aColsRes := {}
aColsProd:= {}
//A1_EMPFAT  	:= IIf(lTOTVS,'2',Z02->Z02_EMPFAT)
IF ( !Empty(cCodFor) .And. !Empty(cCodCli) )

	cQuery:= " SELECT A1_COD , A1_NREDUZ, A2_COD,A2_NREDUZ , Z05.* , Z02.*, Z00.* "
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "
	cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO AND Z00.Z00_FORNEC = '" + cCodFor + "'"
	cQuery+= " AND Z00_FILIAL = '"+xFilial('Z00')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02_TIPO IN ('3','4','8') AND Z02.Z02_PROPOS = Z05.Z05_PROPOS AND Z02.Z02_ADITIV = Z05.Z05_ADITIV AND Z02_STATUS IN ('5','9') "
	cQuery+= " AND Z02_FILIAL = '"+xFilial('Z02')+"'  "+CRLF
	//cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT AND SA1.A1_COD = '" + cCodCli + "'"
	if !Empty(cCodCliAte)
		cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "+CRLF
		cQuery+= " ON SA1.D_E_L_E_T_ = ''  "+CRLF
		cQuery+= " AND SA1.A1_COD = Z02.Z02_CLIENT  "+CRLF
		cQuery+= " AND SA1.A1_COD BETWEEN '" + cCodCli + "' AND  '"+cCodCliAte+"' " +CRLF
	else 
		cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT AND SA1.A1_COD = '" + cCodCli + "'"
	end
	cQuery+= " AND A1_FILIAL = '"+xFilial('SA1')+"'  "+CRLF

ElseIF !Empty(cCodFor)

	cQuery:= " SELECT A1_COD , A1_NREDUZ, A2_COD,A2_NREDUZ , Z05.* , Z02.*, Z00.* "
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "
	cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO AND Z00.Z00_FORNEC = '" + cCodFor + "'"
	cQuery+= " AND Z00_FILIAL = '"+xFilial('Z00')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02_TIPO IN ('3','4','8') AND Z02.Z02_PROPOS = Z05.Z05_PROPOS AND Z02.Z02_ADITIV = Z05.Z05_ADITIV AND Z02_STATUS IN ('5','9') "
	cQuery+= " AND Z02_FILIAL = '"+xFilial('Z02')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT "
	cQuery+= " AND A1_FILIAL = '"+xFilial('SA1')+"'  "+CRLF

ElseIF !Empty(cCodCli) .or. !Empty(cCodCliAte)

	cQuery:= " SELECT A1_COD , A1_NREDUZ, A2_COD,A2_NREDUZ , Z05.* , Z02.*, Z00.* "
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "
	cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO "
	cQuery+= " AND Z00_FILIAL = '"+xFilial('Z00')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02_TIPO IN ('3','4','8') AND Z02.Z02_PROPOS = Z05.Z05_PROPOS AND Z02.Z02_ADITIV = Z05.Z05_ADITIV AND Z02_STATUS IN ('5','9') "
	cQuery+= " AND Z02_FILIAL = '"+xFilial('Z02')+"'  "+CRLF
	if !Empty(cCodCliAte)
		cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "+CRLF
		cQuery+= " ON SA1.D_E_L_E_T_ = ''  "+CRLF
		cQuery+= " AND SA1.A1_COD = Z02.Z02_CLIENT  "+CRLF
		cQuery+= " AND SA1.A1_COD BETWEEN '" + cCodCli + "' AND  '"+cCodCliAte+"' " +CRLF
	else 
		cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT AND SA1.A1_COD = '" + cCodCli + "'"		
	end
	cQuery+= " AND A1_FILIAL = '"+xFilial('SA1')+"'  "+CRLF

ElseIF !Empty(cPropos)

	cQuery:= " SELECT A1_COD , A1_NREDUZ, A2_COD,A2_NREDUZ , Z05.* , Z02.*, Z00.* "
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "
	cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO "
	cQuery+= " AND Z00_FILIAL = '"+xFilial('Z00')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02_TIPO IN ('3','4','8') AND Z02.Z02_PROPOS = Z05.Z05_PROPOS AND Z02.Z02_ADITIV = Z05.Z05_ADITIV AND Z02_STATUS IN ('5','9') AND Z02.Z02_PROPOS = '" + cPropos + "'"
	cQuery+= " AND Z02_FILIAL = '"+xFilial('Z02')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT "
	cQuery+= " AND A1_FILIAL = '"+xFilial('SA1')+"'  "+CRLF

Else

	cQuery:= " SELECT A1_COD , A1_NREDUZ, A2_COD,A2_NREDUZ , Z05.* , Z02.*, Z00.* "
	cQuery+= " FROM " + RetSqlName("Z05") + " Z05 "
	cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO "
	cQuery+= " AND Z00_FILIAL = '"+xFilial('Z00')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02_TIPO IN ('3','4','8') AND Z02.Z02_PROPOS = Z05.Z05_PROPOS AND Z02.Z02_ADITIV = Z05.Z05_ADITIV AND Z02_STATUS IN ('5','9') "
	cQuery+= " AND Z02_FILIAL = '"+xFilial('Z02')+"'  "+CRLF
	cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT "
	cQuery+= " AND A1_FILIAL = '"+xFilial('SA1')+"'  "+CRLF
EndIF

cQuery+= " LEFT JOIN " + RetSqlName("SA2") + " SA2 "+CRLF
cQuery+= " ON SA2.D_E_L_E_T_ = ''  "+CRLF
cQuery+= " AND SA2.A2_FILIAL = '"+xFilial('SA2')+"'  "+CRLF
cQuery+= " AND SA2.A2_COD = Z00_FORNEC  "+CRLF


cQuery+= " WHERE Z05.D_E_L_E_T_ = '' "
cQuery+= " AND Z05_FILIAL = '"+xFilial('Z05')+"'  "+CRLF
IF Left(cMod,1) != 'T'
	cQuery+= " AND Z05.Z05_MOD = '" + Left(cMod,1) + "' "
EndIF

IF Left(cEmp,1) != 'T'
	cQuery+= " AND A1_EMPFAT = '" + Left(cEmp,1) + "' "
EndIF

If !empty(dDtApvate)
	cQuery+= " AND Z02_DTAPRO BETWEEN '"+DTOS(dDtApvde)+"' AND '"+DTOS(dDtApvate)+"' "
End

cQuery+= " ORDER BY A1_COD,Z05_PROPOS,Z05_ADITIV,Z05_MODULO "


IF !Empty(cQuery)

	TcQuery cQuery new Alias "TMP"
	TcSetField("TMP", "Z05_DATA"	, "D" , 8 , 0 )
	TcSetField("TMP", "Z02_VIGENC"	, "D" , 8 , 0 )
	TcSetField("TMP", "Z02_DTAPRO"	, "D" , 8 , 0 )

	While TMP->( !Eof() )
	
	    Aadd(aColsRes,Array(Len(aHeadRes)+1))
		nAT:= Len(aColsRes)
	
		For nX	:= 1 To Len(aHeadRes)
	        IF ( AllTrim(aHeadRes[nX,2]) == "FLAG")
	            aColsRes[nAt,nX] := ""
	        Else
	            aColsRes[nAT,nX] := TMP->(FieldGet(FieldPos(aHeadRes[nX,2])))
	        EndIF
	    Next nX
	
		aColsRes[nAt,Len(aHeadRes)+1] := .F.

		nPosPrd:= aScan(aColsProd,{|x| x[nPPrdDescri] == TMP->Z00_DESCRI})
		If (nPosPrd == 0 )
			Aadd(aColsProd,Array(Len(aHeadProd)+1))
			nAT:= Len(aColsProd)
		
			For nX	:= 1 To Len(aHeadProd)
				IF ( AllTrim(aHeadProd[nX,2]) == "FLAG")
					aColsProd[nAt,nX] := ""
				Else
					aColsProd[nAT,nX] := TMP->(FieldGet(FieldPos(aHeadProd[nX,2])))
				EndIF
			Next nX
	
			aColsProd[nAt,Len(aHeadProd)+1] := .F.
	    Else
			aColsProd[nPosPrd,nPPrdQuant] += TMP->Z05_QUANT
			aColsProd[nPosPrd,nPPrdVlrMes]+= TMP->Z05_VLRMES
			aColsProd[nPosPrd,nPPrdTotal] += TMP->Z05_TOTAL
			aColsProd[nPosPrd,nPPrdCustot]+= TMP->Z05_CUSTOT
			aColsProd[nPosPrd,nPPrdMargem]:= Round((aColsProd[nPosPrd,nPPrdVlrMes]-aColsProd[nPosPrd,nPPrdCustot])/aColsProd[nPosPrd,nPPrdVlrMes] *100,2)
		EndIf
		
		TMP->(dbSkip())

	EndDo
	
	TMP->(dbCloseArea())

EndIF

IF Len(aColsRes) == 0
	Aadd(aColsRes,Array(Len(aHeadRes)+1))
	For nI := 1 to Len(aHeadRes)
		IF aHeadRes[nI,2] == 'R_E_C_N_O_'
			aColsRes[Len(aColsRes),nI] := 0
		Else
			aColsRes[Len(aColsRes),nI] := CriaVar(aHeadRes[nI,2],.T.)
		EndIF
	Next nI
	aColsRes[Len(aColsRes),Len(aHeadRes)+1] := .F.
EndIF

If Len(aColsProd) == 0 
	Aadd(aColsProd,Array(Len(aHeadProd)+1))
	nAT:= Len(aColsProd)

	For nX	:= 1 To Len(aHeadProd)
		IF ( AllTrim(aHeadProd[nX,2]) == "FLAG")
			aColsProd[nAt,nX] := ""
		Else
			aColsProd[nAT,nX] := CriaVar(aHeadProd[nX,2],.T.)//TMP->(FieldGet(FieldPos(aHeadProd[nX,2])))
		EndIF
	Next nX

	aColsProd[nAt,Len(aHeadProd)+1] := .F.

    aSort( aColsProd ,,, {|x,y| x[1] > y[1] } )

EndIf

oResumo:aCols:= aColsRes
oResumo:ForceRefresh()

oResProd:aCols:= aColsProd
oResProd:ForceRefresh()

CalcRodape()

Return(.T.)

User Function SyCalcCusto(oResumo) 

Local aArea			:= GetArea()
Local nQuant		:= 0
Local nPrecoVenda	:= 0

nQuant		:= oResumo:aCols[oResumo:nAt,nPQuantidade]
nPrecoVenda	:= oResumo:aCols[oResumo:nAt,nPPrcVen]
nPrecoTab   := oResumo:aCols[oResumo:nAt,nPPrcTab]
nCusto      := oResumo:aCols[oResumo:nAt,nPrcCusto]

IF ( 'M->Z05_CUSTO' == ReadVar() )	
	nCusto:= &(ReadVar())
ElseIF ( 'M->Z05_PRCTAB' == ReadVar() )	
	nPrecoTab:= &(ReadVar())
EndIF

IF nPrecoTab <= 0
	nPrecoTab:= Z00->Z00_PRCTAB	
EndIF

oResumo:aCols[oResumo:nAt,nPPrcTab]  := nPrecoTab
oResumo:aCols[oResumo:nAt,nPrcCusto] := nCusto
oResumo:aCols[oResumo:nAt,nPCusTot]  := Round((nCusto * nQuant )	,2)
oResumo:aCols[oResumo:nAt,nPMargem]  := Round((( nPrecoVenda - nCusto ) / nPrecoVenda) * 100,2)

If (oResumo:aCols[oResumo:nAt,nPModalidade] = '2') //OnPremise
    oResumo:aCols[oResumo:nAt,nPManutA]   := (nPrecoTab * nQuant ) * 0.15 //Manutencao Anual
EndIf

oResumo:Refresh()

M->Z05_QUANT	:= nQuant
M->Z05_CUSTO	:= nCusto
M->Z05_CUSTOT	:= Round(nCusto * nQuant,2 )

CalcRodape()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SyOrdena ³ Autor ³                       ³ Data ³ 24/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena ao clicar na coluna da GetDados.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SyOrdena(nPos,oGetDados,lOrdemCols)

IF !lJaExecutou
	
	lJaExecutou := .T.
	lOrdemCols := !lOrdemCols
	
	IF lOrdemCols 
    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
    	aSort( oGetDados:aCols ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF

	oGetDados:oBrowse:nAt := 1
	oGetDados:oBrowse:Refresh()
	oGetDados:oBrowse:SetFocus()

Else

	lJaExecutou := .F.

EndIf

Static Function VerProposta(oResumo)

Local aArea		:= GetArea()
Local cProposta := oResumo:aCols[ oResumo:nAt , aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PROPOS"}) ]
Local cAditivo  := oResumo:aCols[ oResumo:nAt , aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_ADITIV"}) ]

aRotina   := { 	{ 'Pesquisar'		,'PesqBrw'   		, 0,1} ,;
				{ 'Visualizar'		,'AxVisual'			, 0,2} ,;
				{ 'Incluir'			,'AxInclui'			, 0,3} ,;
				{ 'Alterar'			,'AxAltera'			, 0,4} }


Inclui := .T.
Altera := .T.

DbSelectArea('Z02')
DbSetOrder(1)
IF DbSeek( xFilial('Z02') + cProposta + cAditivo)
	U_AF02WIZARD(2)	
EndIF

RestArea(aArea)

Return(.T.)

Static Function CalcRodape()

nQtdLic		:= 0
nVenLic		:= 0
nCusLic		:= 0
nMarLic		:= 0
nOnVenLic	:= 0
nOnCusLic	:= 0
nOnMarLic	:= 0

aEval(oResumo:aCols, {|x| nQtdLic  +=  x[nPQuantidade] } )

//SaaS
aEval(oResumo:aCols, {|x| nVenLic  +=  IIF( x[nPModalidade] == '1' , x[nPVlrMes] , 0 ) } )
aEval(oResumo:aCols, {|x| nCusLic  +=  IIF( x[nPModalidade] == '1' , x[nPCusTot] , 0 ) } )

nMarLic := nVenLic - nCusLic

//OnPremise
aEval(oResumo:aCols, {|x| nOnVenLic  +=  IIF( x[nPModalidade] <> '1' , x[nPVlrMes] , 0 ) } )
aEval(oResumo:aCols, {|x| nOnCusLic  +=  IIF( x[nPModalidade] <> '1' , x[nPCusTot] , 0 ) } )

nOnMarLic := nOnVenLic - nOnCusLic

oQtdLic:Refresh()
oVenLic:Refresh()
oCusLic:Refresh()
oMarLic:Refresh()

oOnVenLic:Refresh()
oOnCusLic:Refresh()
oOnMarLic:Refresh()

Return(.T.)

Static Function AtuZ02(oResumo,nPProposta)

Z02->( DbSetOrder(1) )
IF Z02->( DbSeek( xFilial('Z02') + oResumo:aCols[oResumo:nAt,nPProposta] ) )
   	RegToMemory('Z02',.F.)
EndIF                              

Return(.T.)
