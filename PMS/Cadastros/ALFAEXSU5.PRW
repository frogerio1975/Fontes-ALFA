#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4   
//#Define CRLF	Chr(10)+Chr(13)
#Define CRLF	Chr(10)
        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ALFAEXSU5  บAutor  ณ Fabio Rogerioบ Data ณ  16/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function ALFAEXSU5()

Local aParambox		:= {}
Local aRetParam		:= {}
Private lCoord     := .F.

aAdd(aParamBox,{1,"Cliente"			, CriaVar("A1_COD",.F.) 	,PesqPict("SA1","A1_COD")		,""	,"SA1","",100,.F.})
aAdd(aParamBox,{2,"Produto"		 	,3		   				,{"1-TOTVS","2-SAP","3-AMBOS"}	,100,"",.F.})  
aAdd(aParamBox,{2,"Apenas Contato Principal?",2		   		,{"1-Sim","2-Nao"}	,100,"",.F.})  

IF ParamBox(aParamBox,"Informe os Dados para Filtro",@aRetParam)
	Processa( {|lEnd| U_EXPSU5(aRetParam) } , "Aguarde, Exportando Contatos..." )
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EXPSU5บAutor  ณ Fabio Rogerioบ Data ณ  26/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria Aba com o Relatorio KPI.					  		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function EXPSU5(aRetParam)

Local nItem  	:= 0
Local cQuery    := ""
Local nRecTot   := 0
Local aCab      :={}
Local aDados    :={}


cQuery:= " SELECT "
cQuery+= " CASE A1_PRODUTO "
cQuery+= " 	WHEN '1' THEN 'TOTVS' "
cQuery+= " 	WHEN '2' THEN 'SAP' "
cQuery+= " 	ELSE 'NAO PREENCHIDO' "
cQuery+= " END AS PRODUTO, "
cQuery+= " 'CLIENTE' AS ORIGEM, "
cQuery+= " A1_CURVA AS CURVA_ABC, "
cQuery+= " ISNULL(MAX(E1_EMISSAO),'') AS ULTCOM, "
cQuery+= " A1_SEGMEN AS SEGMENTO, "
cQuery+= " A1_CGC AS CNPJ, "
cQuery+= " A1_NOME AS EMPRESA, "
cQuery+= " A1_GRUPO AS GRUPO, "
cQuery+= " U5_CONTAT AS NOME,"
cQuery+= " U5_SOBREN AS SOBRENOME,"
cQuery+= " LOWER(U5_EMAIL) AS EMAIL,"
cQuery+= " ISNULL(UM_DESC,'') AS CARGO,"
cQuery+= " U5_FCOM1 AS TELEFONE,"
cQuery+= " U5_CELULAR AS CELULAR"
cQuery+= " FROM " + RetSqlName("SU5") + " SU5 "
cQuery+= " INNER JOIN " + RetSqlName("AC8") + " AC8  ON AC8.D_E_L_E_T_ = '' AND SU5.U5_CODCONT = AC8.AC8_CODCON"
cQuery+= " INNER JOIN " + RetSqlName("SA1") + " SA1  ON SA1.D_E_L_E_T_ = '' AND SA1.A1_COD+SA1.A1_LOJA = AC8.AC8_CODENT"
cQuery+= " LEFT JOIN "  + RetSqlName('SUM') + " SUM_  ON SUM_.D_E_L_E_T_ = '' AND SU5.U5_FUNCAO = SUM_.UM_CARGO"
cQuery+= " LEFT JOIN "  + RetSqlName('SE1') + " SE1   ON SE1.D_E_L_E_T_ = '' AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA AND '-' NOT IN (SE1.E1_TIPO )"
cQuery+= " WHERE "
cQuery+= " SU5.D_E_L_E_T_ = ''"
cQuery+= " AND SU5.U5_CODCONT <> '104431'"

If (!Empty(aRetParam[1]))
    cQuery+= " AND SA1.A1_COD = '" + aRetParam[1] = "'"
ENDIF

cProduto:= IIF(ValType(aRetParam[2]) == "N",cValToChar(aRetParam[2]),Left(aRetParam[2],1))
If (cProduto == "3")
    cQuery+= " AND SA1.A1_PRODUTO IN ('1','2')"
Else
    cQuery+= " AND SA1.A1_PRODUTO = '" + cValToChar(aRetParam[2] ) + "'"
EndIf

cPrincipal:= IIF(ValType(aRetParam[3]) == "N",cValToChar(aRetParam[3]),Left(aRetParam[3],1))
If (cPrincipal == "1")
    cQuery+= " AND SU5.U5_CONTPRI = '1' "
EndIf

cQuery+= " GROUP BY A1_PRODUTO,A1_CURVA,A1_GRUPO,A1_SEGMEN,A1_CGC,A1_NOME,U5_CONTAT,U5_SOBREN,U5_EMAIL,UM_DESC,U5_FCOM1,U5_CELULAR"

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf

//Pega o Total de Registos
cQryTot:= "SELECT COUNT(*) AS TOT FROM (" + cQuery + ") X"
TcQuery cQryTot new Alias "TMPTOT"
nRecTot:= TMPTOT->TOT
TMPTOT->(dbCloseArea())                     


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Salva query em disco para debug. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If GetNewPar("SY_DEBUG", .F.)
    MakeDir("\DEBUG\")
    MemoWrite("\DEBUG\"+__cUserID+"_ALFAEXSU5.SQL", cQuery)
EndIf

MakeDir("\CONTATOS\")

//TcQuery cQuery new Alias "TMP"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,ChangeQuery(cQuery)),"TMP",.F.,.T.)		
DbSelectArea("TMP")

TcSetField("TMP", "ULTCOM"	, "D" , 10 , 0 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona o Cabecalho
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aAdd( aCab, {"PRODUTO" 	,"C", 10, 0})
aAdd( aCab, {"ORIGEM" 	,"C", 10, 0})
aAdd( aCab, {"CURVA_ABC","D", 10, 0})
aAdd( aCab, {"ATIVO"    ,"C", 10, 0})
aAdd( aCab, {"SEGMENTO" ,"D", 30, 0})
aAdd( aCab, {"CNPJ" 	,"C", 20, 0})
aAdd( aCab, {"EMPRESA"  ,"C", 20, 0})
aAdd( aCab, {"GRUPO"    ,"C", 20, 0})
aAdd( aCab, {"NOME" 	,"C", 20, 0})
aAdd( aCab, {"SOBRENOME","C", 20, 0})
aAdd( aCab, {"EMAIL" 	,"C", 40, 0})
aAdd( aCab, {"CARGO" 	,"C", 40, 0})
aAdd( aCab, {"TELEFONE" ,"C", 20, 0})
aAdd( aCab, {"CELULAR" 	,"C", 20, 0})

nItem  := 0

nHandle:= 0
If TMP->( !Eof() )
	cFile:= "\CONTATOS\CONTATO_"+__cUserId+'_'+Dtos(dDatabase)+'.CSV'
	If File(cFile)
		FErase(cFile)
	EndIf
	nHandle := FCreate( cFile , 0 )

	cLinha:=	"PRODUTO;"+;
				"ORIGEM;"+;
				"CURVA_ABC;"+;
				"ATIVO;"+;
				"SEGMENTO;"+;
				"CNPJ;"+;
				"EMPRESA;"+;
				"GRUPO;"+;
				"NOME;"+;
				"SOBRENOME;"+;
				"EMAIL;"+;
				"CARGO;"+;
				"TELEFONE;"+;
				"CELULAR"

	fWrite(nHandle,cLinha+CRLF)
EndIf

aEmail:= {}
ProcRegua(nRecTot)																																				
While TMP->( !Eof() )

	
	nItem++
	IncProc("Lendo Registro " + cValToChar(nItem) + "/" + cValToChar(nRecTot))

    iF aScan(aEmail,TMP->EMAIL) == 0
        aAdd(aEmail,TMP->EMAIL)
    else
        dbSkip()
        Loop
    endIf        


    cTel:= SYFORMAT(TMP->TELEFONE, "", .F., 'C')
    cCel:= SYFORMAT(TMP->CELULAR, "", .F., 'C')
    //11967917775
    //1135889997
    If (Len(cTel) == 10)
        cTel:= '(' + Left(cTel,2) + ')' + SubStr(cTel,3,4) + '-' + SubStr(cTel,7,4)
    ElseIf(Len(cTel) > 5)
        cTel:= '(11)' + SubStr(cTel,1,4) + '-' + SubStr(cTel,5,4)
    else
        cTel:= ''
    EndIf    

    If (Len(cCel) == 11)
        cCel:= '(' + Left(cCel,2) + ')' + SubStr(cCel,3,5) + '-' + SubStr(cCel,8,4)
    ElseIf(Len(cCel) > 5)
        cCel:= '(11)' + SubStr(cCel,1,5) + '-' + SubStr(cCel,6,4)
    else
        cCel:= ''
    EndIf    

    aAdd( aDados, { TMP->PRODUTO,; 	
                    TMP->ORIGEM,;	
                    TMP->CURVA_ABC,;		
                    IIF(TMP->ULTCOM < (dDatabase-730),"NAO","SIM"),; 		
                    TMP->SEGMENTO,; 
                    TransForm(StrZero(Val(TMP->CNPJ),14), "@R 99.999.999/9999-99"),;
                    TMP->EMPRESA,;
                    TMP->GRUPO,;		
                    TMP->NOME,;	
                    TMP->SOBRENOME,;	
                    TMP->EMAIL,;		
                    TMP->CARGO,;		
                    cTel,;	
                    cCel})
	

	If nHandle >= 0
		cLinha:=	TMP->PRODUTO    + ";" + ; 	
                    TMP->ORIGEM     + ";" + ;	
                    TMP->CURVA_ABC  + ";" + ;		
                    IIF(TMP->ULTCOM < (dDatabase-730),"NAO","SIM") + ";" + ; 		
                    TMP->SEGMENTO   + ";" + ; 
                    TransForm(StrZero(Val(TMP->CNPJ),14), "@R 99.999.999/9999-99") + ";" + ;
                    TMP->EMPRESA    + ";" + ;
                    TMP->GRUPO   + ";" + ;		
                    TMP->NOME       + ";" + ;	
                    TMP->SOBRENOME  + ";" + ;	
                    TMP->EMAIL      + ";" + ;		
                    TMP->CARGO      + ";" + ;		
                    cTel   + ";" + ;
                    cCel

		fWrite(nHandle,cLinha+CRLF)
	EndIf

	TMP->( dbSkip() )
	
EndDo	

TMP->( dbCloseArea() )

If (nHandle >= 0)
	fClose(nHandle)
EndIf

//Abre no Excel

MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
		{||DlgToExcel({{"GETDADOS",;
		"Contatos",;
		aCab,aDados}})})



Return 

//-- Retira caracteres especiais de campos pre-formatados (CEP, CNPJ, etc)
Static Function SYFORMAT(cTexto, cCpo, lFormata, cTipo)

Local cAux     := ""
Local nI       := 0     
Local cAcentos := "แเใโมภรย้่๊ษศสํ์๎อฬฮ๓๒๕๔ำาีิ๚๙๛ฺูÛ็วั๑"
Local cOutros  := "?!:,./\|@#$%&()-"

Default lFormata := .F.     
Default cTipo    := "N" 
                                                      
Do Case
	Case cTipo == "N"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48) .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)
				cAux += SubStr(cTexto, nI, 1)
			EndIf
		Next nI                                        
		
	Case cTipo == "C"
		For nI := 1 To Len(cTexto)                   
			If (ASC( SubStr(cTexto, nI, 1) ) >= 48)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 57)  .Or.; 
			   (ASC( SubStr(cTexto, nI, 1) ) >= 65)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 90)  .Or.;
			   (ASC( SubStr(cTexto, nI, 1) ) >= 97)  .And. (ASC( SubStr(cTexto, nI, 1) ) <= 122) 
				If (SubStr(cTexto, nI, 1) $ Alltrim(cOutros)) .Or. (SubStr(cTexto, nI, 1) $ Alltrim(cAcentos))
				If SubStr(cTexto, nI, 1) == "&"
					cAux += "e"
					Else
						cAux += SubStr(cTexto, nI, 1)
					EndIf
				Else
					cAux += SubStr(cTexto, nI, 1)
				EndIf
			EndIf
		Next nI                                        
EndCase		

If lFormata
	cAux := PadR(AllTrim(cAux), TamSx3(cCpo)[01])
else
    cAux:= AllTrim(cAux)
EndIf

Return cAux

//Rotina usada no cadastro manual do contas a receber para validar os tipos corretos de vendas e parcela
User Function ValTipoParcela()
Local lRet:= .F.

If (M->E1_XTIPO $ "157") .And. (M->E1_XTPPARC == "1")
    lRet:= .T.
ElseIf (M->E1_XTIPO $ "38") .And. (M->E1_XTPPARC $ "345")
    lRet:= .T.
ElseIf (M->E1_XTIPO $ "26") .And. (M->E1_XTPPARC == "5")
    lRet:= .T.
ElseIf (M->E1_XTIPO $ "4") .And. (M->E1_XTPPARC $ "24")
    lRet:= .T.
ElseIf (M->E1_XTPPARC == "6")
    lRet:= .T.
ElseIf (M->E1_XTIPO $ "9") .And. (M->E1_XTPPARC $ "7")
    lRet:= .T.    
EndIf

If !lRet
    Aviso("Aten็ao","O Tipo de Parcela selecionado nao ้ permitido para o Tipo de Venda escolhido! ",{"Ok"})
    M->E1_XTPPARC:= " "
EndIf

Return (lRet)
