
#INCLUDE "FWEditPanel.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "TBIConn.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Set.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS72
Descricao: RELATORIO CADASTRO DE CONTRATOS

@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS72()
	Local cArquivo  := ''
	Local cPerg:='ALFPMS72'
    Private oFWMsExcel := Nil

	ValidPerg(cPerg)
	iF Pergunte(cPerg,.T.)

        //Criando o objeto que irá gerar o conteúdo do Excel
        oFWMsExcel := FWMSExcel():New()	
        FWMsgRun(, {|oSay| GeraExcel(oSay,cArquivo) }, "Gerando arquivo Excel", "Processando a rotina...")

        FWMsgRun(, {|| AbreExcel() }, "Abrindo Excel", "Processando a rotina...")


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
	//aAdd(aRegs,{cPerg,"05","Vigencia de ?"     ,"",""         ,"mv_ch5","D", 8                   ,0,0,"G",""	,"mv_par05",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	//aAdd(aRegs,{cPerg,"06","Vigencia ate ?"    ,"",""         ,"mv_ch6","D", 8                   ,0,0,"G",""	,"mv_par06",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	//aAdd(aRegs,{cPerg,"07","Vencimento de ?"   ,"",""         ,"mv_ch7","D", 8                   ,0,0,"G",""	,"mv_par07",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
	//aAdd(aRegs,{cPerg,"08","Vencimento ate ?"  ,"",""         ,"mv_ch8","D", 8                   ,0,0,"G",""	,"mv_par08",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )


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


//-------------------------------------------------------------------
/*/{Protheus.doc} GERAEXCEL
Exporta tela para excel

@author PEDRO OLIVEIRA
@since 03/05/2018
@version P11
/*/
//-------------------------------------------------------------------
Static Function GERAEXCEL(oSay,cArquivo)

//Local aExcel := oGdTop:aCols
Local nI     := 0
Local cPlan := "ALFPMS72 - CADASTRO DE CONTRATOS "
Local aAux	:={}
Local nCol  := 1
Local nC    := 1 
Local cQuery:= '' 

oSay:cCaption := "Gerando dados..."
     
//Aba 01 - Teste           ABA
oFWMsExcel:AddworkSheet(cPlan) //Não utilizar número junto com sinal de menos. Ex.: 1- 
//Criando a Tabela     ABA             TABELA
oFWMsExcel:AddTable(cPlan,cPlan)
    

oFWMsExcel:AddColumn(cPlan, cPlan, 'Nr.Contrato' ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'N.Fornecedor' ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'N.Cliente' ,1,1) // esquerda - texto

oFWMsExcel:AddColumn(cPlan, cPlan, 'Qtd.Licenças' ,3,2) // direita - numero        		
oFWMsExcel:AddColumn(cPlan, cPlan, 'Vlr.Unitário' ,3,2) // direita - numero        		
oFWMsExcel:AddColumn(cPlan, cPlan, 'Vlr.Total' ,3,2) // direita - numero        		

oFWMsExcel:AddColumn(cPlan, cPlan, 'Custo Unitário' ,3,2) // direita - numero        		
oFWMsExcel:AddColumn(cPlan, cPlan, 'Custo Total' ,3,2) // direita - numero        		

//oFWMsExcel:AddColumn(cPlan, cPlan, 'Custo Total' ,3,2) // direita - numero        		
oFWMsExcel:AddColumn(cPlan, cPlan, '%Markup' ,3,2) // direita - numero        		

oFWMsExcel:AddColumn(cPlan, cPlan, 'Proposta' ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Aditivo' ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Produto' ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Descricao' ,1,1) // esquerda - texto

cQuery := " SELECT   "+CRLF
cQuery += "  * "+CRLF
cQuery += " FROM "+RetSqlName("Z42")+" Z42 "+CRLF
cQuery += " INNER JOIN "+RetSqlName("Z43")+" Z43   "+CRLF
cQuery += " ON  Z43_FILIAL = Z42_FILIAL "+CRLF
cQuery += " AND Z43_NUMERO = Z42_NUMERO "+CRLF
cQuery += " AND Z43_FORNEC = Z42_FORNEC"+CRLF
cQuery += " AND Z43_LJFOR  = Z42_LJFOR"+CRLF
cQuery += " AND Z43.D_E_L_E_T_='' "+CRLF
cQuery += "WHERE "        + CRLF
cQuery += " Z42_FILIAL = '" + FWxfilial('Z42') + "' "        + CRLF
cQuery += " AND Z42_FORNEC  BETWEEN '" + MV_PAR01 + "'  AND '"+MV_PAR02+"' "+ CRLF
cQuery += " AND Z42_CLIENT  BETWEEN '" + MV_PAR03 + "'  AND '"+MV_PAR04+"' "+ CRLF 
cQuery += " AND Z42.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY"+ CRLF
cQuery += " Z42_FILIAL "+CRLF
cQuery += " ,Z42_NUMERO "+CRLF
cQuery += " ,Z42_FORNEC "+CRLF
cQuery += " ,Z42_LJFOR "+CRLF
cQuery += " ,Z43_ITEM "+CRLF

cTmpE2:= MPSysOpenQuery(cQuery)

While (cTmpE2)->(!Eof())
    aAux :={}

	aadd(aAux,	(cTmpE2)->Z42_NUMERO 	    )
	aadd(aAux,	(cTmpE2)->Z42_NFOR 	)
	aadd(aAux,	(cTmpE2)->Z42_NCLI 		)
	aadd(aAux,	(cTmpE2)->Z43_QUANT 		)
	aadd(aAux,	(cTmpE2)->Z43_PUNIT 	)
	aadd(aAux,	(cTmpE2)->Z43_PTOTAL 	)

	aadd(aAux,	(cTmpE2)->Z43_CUNIT 	)
	aadd(aAux,	(cTmpE2)->Z43_CTOTAL 	)
	aadd(aAux,	(cTmpE2)->Z43_MARKUP 	)
	aadd(aAux,	(cTmpE2)->Z43_PROPOS 	)
	aadd(aAux,	(cTmpE2)->Z43_ADITIV 	)
	aadd(aAux,	(cTmpE2)->Z43_PRODUT 	)	
	aadd(aAux,	POSICIONE("Z00",1,XFILIAL("Z00")+(cTmpE2)->Z43_PRODUT ,"Z00_DESCRI") 	)	
    // Cria Linha
    oFWMsExcel:AddRow(cPlan,cPlan,aAux)
	(cTmpE2)->(DbSkip())
EndDo

(cTmpE2)->(dbCloseArea())


Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} AbreExcel

Abre relatório - EXCEL

@author Pedro Henrique Oliveira
@since 15/05/2018
@version P12
/*/ 
//-------------------------------------------------------------------
Static Function AbreExcel(nTipo)

Local cDir	:= "C:\TEMP\"
Local cArq	:= cDir+"ALFPMS72-"+Alltrim(DtoS(dDataBase))+"-"+Alltrim(STRTRAN(TIME(),":",""))+".xls"

If nTipo == 2
	cArq	:= cDir+"ALFPMS72-"+Alltrim(DtoS(dDataBase))+"-"+Alltrim(STRTRAN(TIME(),":",""))+".xls"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Veriifica se a pasta existe.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cDir)    
	MakeDir(cDir)
EndIf

//Ativando o arquivo e gerando o xml
oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArq)
    
If ! ApOleClient( 'MsExcel' )
	MsgStop('MsExcel nao instalado') 	
	Return
EndIf

//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()             	//Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArq)     	//Abre uma planilha
oExcel:SetVisible(.T.)                 	//Visualiza a planilha
oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
 
MsgInfo("Relatório gerado!","Atenção")                          

Return
