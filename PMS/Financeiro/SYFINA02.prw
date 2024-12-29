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
Static cEmExecucaoPend 	:= '00:00'			// Usado na funcao SyMostraPend
Static oTimerCrd                   			// Objeto do timer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SYFINA02 ³ Autor ³   Fabio Rogerio       ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Conferencia de Comissoes        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SYFINA02()
Local oRodape
Local nI,nX
Local oFntP 		:= TFont():New( "Arial",,18,,.T.,,,,,.F.)
Local oFntM 		:= TFont():New( "Arial",,22,,.T.,,,,,.F.)
Local oFldEscopo
Local oCab
Local cNomeFor:= CriaVar("A2_NOME",.F.)
Local oNomeFor
Local oShowInd
Local nStyle 		:= GD_INSERT+GD_UPDATE+GD_DELETE
Local aSize:= {}
Local cTitle:= ""
Local oPnlMaster
Local oPnlTit
Local lGrava:= .F.
Local aAlterRes     := {}
Private dPerIni     := FirstDay(dDatabase)
Private dPerFim     := LastDay(dDatabase)
Private aHeadRes  	:= {}
Private aColsRes  	:= {}
Private oResumo
Private cCodFor     := CriaVar("A2_COD",.F.)
Private oCodFor
Private oQtdTit
Private oValTit
Private nPValTit    := 0
Private nQtdTit     := 0
Private nValTit     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o resumo do escopo do projeto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize    := MsAdvSize()
cTitle   := "Conferencia de Pagamentos"
//DEFINE MSDIALOG oShowInd FROM 0,0 TO 800,1500 TITLE cTitle Of oMainWnd PIXEL STYLE DS_MODALFRAME 
DEFINE MSDIALOG oShowInd FROM  0,0 to aSize[6],aSize[5] TITLE cTitle Of oMainWnd PIXEL STYLE DS_MODALFRAME 

oShowInd:lEscClose	:= .F.
oShowInd:lMaximized	:= .T.

oPnlMaster:= TPanel():New(0, 0, "", oShowInd, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
oPnlMaster:Align:= CONTROL_ALIGN_ALLCLIENT

oPnlTit:= TPanel():New(0, 2,'CONFERENCIA DE COMISSOES', oPnlMaster , NIL, .T., .F., NIL, NIL, 0,10, .T., .F. )
oPnlTit:Align	:= CONTROL_ALIGN_TOP
oPnlTit:nClrPane:= Rgb(112,128,144)
oPnlTit:oFont:= oFntP

oCab:= TPanel():New(0, 2,"", oPnlMaster , NIL, .T., .F., NIL, NIL, 0,20, .T., .F. )
oCab:Align	:= CONTROL_ALIGN_TOP

@ 005,005 SAY "Vendedor:"	OF oCab FONT oFntM COLOR CLR_BLACK 							Pixel SIZE 150,15
@ 005,060 MSGET oCodFor  VAR cCodFor  OF oCab Valid (Empty(cCodFor) .Or. ExistCpo("SA2",cCodFor)) PICTURE PesqPict("SA2", "A2_COD") SIZE 40,10 F3 "SA2VEN" FONT oFnt When .T. PIXEL
@ 005,120 MSGET oNomeFor VAR cNomeFor OF oCab PICTURE PesqPict("SA2", "A2_NOME") SIZE 200,10 FONT oFnt When .F. PIXEL
oCodFor:bLostFocus:= {|| cNomeFor := Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME") 	, oNomeFor:Refresh() , MontaaCols()}

@ 005,325 SAY "Periodo:"	OF oCab FONT oFntM COLOR CLR_BLACK 							Pixel SIZE 150,15
@ 005,360 MSGET oPerIni  VAR dPerIni  OF oCab PICTURE PesqPict("SE2", "E2_VENCREA") SIZE 60,10 FONT oFnt When .T. PIXEL VALID !Empty(dPerIni)
@ 005,420 MSGET oPerFim  VAR dPerFim  OF oCab PICTURE PesqPict("SE2", "E2_VENCREA") SIZE 60,10 FONT oFnt When .T. PIXEL VALID (dPerFim >= dPerIni)
oPerFim:bLostFocus:= {|| Alert("Data") , MontaaCols()}

oFldEscopo:= TPanel():New(0, 2,, oPnlMaster , NIL, .T., .F., NIL, NIL, 0,100, .T., .F. )
oFldEscopo:Align	:= CONTROL_ALIGN_ALLCLIENT

oRodape:= TPanel():New(0, 2,"", oFldEscopo , NIL, .T., .F., NIL, NIL, 0,40, .T., .F. )
oRodape:Align	:= CONTROL_ALIGN_BOTTOM

MontaaHeader()
nPValTit   	:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "E2_VALOR"})

Aadd(aAlterRes,"E2_VALOR")
Aadd(aAlterRes,"E2_VENCREA")

oResumo:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue",,aAlterRes,,99999,,,,oFldEscopo,aHeadRes,aColsRes)
oResumo:oBrowse:Refresh()
oResumo:nAt:= 1
oResumo:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oResumo:cFieldOk := "U_SyCalcComis(@oResumo)"

aEval(oResumo:aCols, {|x| nQtdTit  +=  1 } )
aEval(oResumo:aCols, {|x| nValTit  +=  x[nPValTit]     } )

@ 003,005 SAY "Quantidade (Titulos):"       	OF oRodape FONT oFntM COLOR CLR_BLACK 							Pixel SIZE 150,15
@ 003,125 SAY oQtdTit VAR nQtdTit			    OF oRodape PICTURE '@E 9,999,999.99' FONT oFntM COLOR CLR_RED 	Pixel SIZE 100,15

@ 003,175 SAY "Valor Total:"	            	OF oRodape FONT oFntM COLOR CLR_BLACK 							Pixel SIZE 150,15
@ 003,270 SAY oValTit VAR nValTit			    OF oRodape PICTURE '@E 9,999,999.99' FONT oFntM COLOR CLR_RED 	Pixel SIZE 100,15


ACTIVATE MSDIALOG oShowInd ON INIT ( EnchoiceBar(oShowInd,{|| (lGrava:= .T.,oShowInd:End()) } , {||  (lGrava:= .F.,oShowInd:End()) },,) ) CENTERED

If lGrava
    /*
	For nI:= 1 To Len(oResumo:aCols)
        dbSelectArea("Z05")
		dbSetOrder(2) //
		If dbSeek(xFilial("Z05")+oResumo:aCols[nI,nPProposta]+oResumo:aCols[nI,nPModulo])
			RecLock("Z05",.F.)
			Z05_ValTO := oResumo:aCols[nI,nPValto]
			Z05_ValTOT:= oResumo:aCols[nI,nPValTot]
			Z05_MARGEM:= oResumo:aCols[nI,nPMargem]
			Z05_DATA  := oResumo:aCols[nI,nPData]
			Z05_MANUTA:= oResumo:aCols[nI,nPManutA]
			MsUnLock()
		EndIf	
	Next nI
    */
EndIf

Return(.T.)

Static Function MontaaHeader()
Local nI:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aHeader do Resumo.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Len(aHeadRes) == 0
    Aadd(aHeadRes,{""			,"FLAG"		 ,"@BMP"  		,03	,0,".F.","û","C",""	," " } ) 
    Aadd(aHeadRes,{"Valor"      ,"E2_VALOR"  ,"@E 99,999.99",TamSX3("E2_VALOR")[1]	    ,2,".F.","û","N",""	," " } )
    Aadd(aHeadRes,{"Data Vencto","E2_VENCREA",""    	    ,TamSX3("E2_VENCREA")[1]	,0,".F.","û","D",""	," " } )
    Aadd(aHeadRes,{"Vendedor"	,"A3_COD"	 ,"@!"			,TamSX3("A3_COD")[1]		,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Nome"	    ,"A3_NOME"   ,"@S20!"		,TamSX3("A3_NOME")[1]	    ,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Cliente"	,"A1_COD"	 ,"@!"			,TamSX3("A1_COD")[1]		,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Fantasia"	,"A1_NREDUZ" ,"@S20!"		,TamSX3("A1_NREDUZ")[1]	    ,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Proposta"   ,"Z02_PROPOS","@!"    		,TamSX3("Z02_PROPOS")[1]	,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Aditivo"    ,"Z02_ADITIV","@!"    		,TamSX3("Z02_ADITIV")[1]	,0,".F.","û","C",""	," " } )
    Aadd(aHeadRes,{"Descricao"  ,"Z02_DESCRI","@!"   	    ,TamSX3("Z02_DESCRI")[1]	,0,".F.","û","C",""	," " } )


EndIF

IF Len(aColsRes) == 0
	Aadd(aColsRes,Array(Len(aHeadRes)+1))
	For nI := 1 to Len(aHeadRes)
        If aHeadRes[nI,2] <> "FLAG"
		    aColsRes[Len(aColsRes),nI] := CriaVar(aHeadRes[nI,2],.F.)
        EndIf    
	Next nI
	aColsRes[Len(aColsRes),Len(aHeadRes)+1] := .F.
EndIF

Return(.T.)

Static Function MontaaCols()
Local cQuery:= ""
Local nI    := 0
Local nX    := 0

If Empty(cCodFor) .And. (Empty(dPerIni) .Or. Empty(dPerFim))
    Return(.F.)
EndIf 

cQuery:= "SELECT E2_VALOR,E2_VENCREA,A3_COD,A3_NOME,A1_COD,A1_NREDUZ,Z02_PROPOS,Z02_DESCRI"
cQuery+= " FROM " + RetSqlName("SE2") + " SE2 "
cQuery+= " INNER JOIN " + RetSqlName("SA3") + " SA3 ON SA3.D_E_L_E_T_ = '' AND SA3.A3_FORNECE = SE2.E2_FORNECE"
cQuery+= " INNER JOIN " + RetSqlName("Z08") + " Z08 ON Z08.D_E_L_E_T_ = '' AND Z08.Z08_PREFIX = SE2.E2_PREFIXO AND Z08.Z08_NUM = SE2.E2_NUM AND Z08.Z08_FORNEC = SE2.E2_FORNECE"
cQuery+= " INNER JOIN " + RetSqlName("Z02") + " Z02 ON Z02.D_E_L_E_T_ = '' AND Z02.Z02_PROPOS = Z08.Z08_PROPOS "
cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD = Z02.Z02_CLIENT "
cQuery+= " WHERE SA3.D_E_L_E_T_ = '' "
cQuery+= " AND SE2.D_E_L_E_T_ = '' AND SE2.E2_PREFIXO = 'COM' AND SE2.E2_TIPO = 'PR' AND SE2.E2_VENCREA BETWEEN '" + Dtos(dPerIni) + "' AND '" + Dtos(dPerFim) + "'" + IIf(!Empty(cCodFor)," AND SE2.E2_FORNECE = '" + cCodFor + "'",'')
cQuery+= " ORDER BY A3_NOME,A1_NREDUZ,E2_VENCREA,Z02_PROPOS"

TcQuery cQuery new Alias "TMP"
TcSetField("TMP", "E2_VENCREA"	, "D" , 8 , 0 )

aColsRes:= {}

If TMP->( Eof() )
    Aadd(aColsRes,Array(Len(aHeadRes)+1))
	nAT:= Len(aColsRes)
    For nI := 1 to Len(aHeadRes)
        If aHeadRes[nI,2] <> "FLAG"
		    aColsRes[nAT,nI] := CriaVar(aHeadRes[nI,2],.T.)
        EndIf    
	Next nI
	aColsRes[Len(aColsRes),Len(aHeadRes)+1] := .F.

    TMP->(dbCloseArea())
	Return 	
EndIf

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
    TMP->(dbSkip())
END
TMP->(dbCloseArea())

nQtdTit:= 0
nValTit:= 0
aEval(aColsRes, {|x| nQtdTit  +=  1 } )
aEval(aColsRes, {|x| nValTit  +=  x[nPValTit]     } )
    
oQtdTit:Refresh()
oValTit:Refresh()
oResumo:aCols:= aColsRes
oResumo:ForceRefresh()

Return(.T.)

User Function SyCalcComis(oResumo) 
Local aArea			:= GetArea()
Local nPValTit	    := aScan(aHeadRes,{|x| AllTrim(x[2]) == "E2_VALOR"})

nQtdTit:= 0
nValTit:= 0
aEval(aColsRes, {|x| nQtdTit  +=  1 } )
aEval(aColsRes, {|x| nValTit  +=  x[nPValTit]     } )
    
oQtdTit:Refresh()
oValTit:Refresh()
oResumo:aCols:= aColsRes
oResumo:ForceRefresh()

RestArea(aArea)

Return(.T.)
