#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFARH03

relatorio de recursos

@author Pedro Oliveira
@since 01/10/2019
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFARH03()

Local cPerg      := PADR('ALFARH03',10)
Local cArquivo      := ''
Local oSay 		   := nil
Private oFWMsExcel  := Nil
Private aExcel      := {}

ValidPerg(cPerg)


If !Pergunte(cPerg,.T.)
    Return
EndIf

oFWMsExcel := FWMSExcel():New()	
FWMsgRun(, {|oSay| GeraExcel(oSay,cArquivo) }, "Gerando arquivo Excel", "Processando a rotina...")

FWMsgRun(, {|oSay|  AbreExcel() }, "Abrindo Excel", "Processando a rotina...")



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

aAdd(aRegs,{cPerg,"01","Recurso de ?","",""              ,"mv_ch1","C", TAMSX3('C7_NUM')[1],0,0,"G",""		,"mv_par01",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","AE8" } )
aAdd(aRegs,{cPerg,"02","Recurso ate ?","",""             ,"mv_ch2","C", TAMSX3('C7_NUM')[1],0,0,"G",""		,"mv_par02",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","AE8" } )
aAdd(aRegs,{cPerg,"03","Somente Ativos?","",""           ,"mv_ch3","N", 1  ,0,0,"C",""		,"mv_par03","1=Sim","1=Sim","1=Sim","","2=Não","2=Não"   ,"2=Não"   ,"","3=Ambos","3=Ambos","3=Ambos","","","","","","","","","","","","","","" } )

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

Local cPlan     := "ALFARH03 - Relatorio Recursos"
Local aAux	    :={}

Local cQuery    := ''
oSay:cCaption := "Gerando dados..."


cQuery+=" SELECT "+CRLF
cQuery+=" AE8_RECURS"+CRLF
cQuery+=" ,AE8_DESCRI"+CRLF
cQuery+=" ,AE8_CELULA"+CRLF
cQuery+=" ,AE8_EMAIL"+CRLF
cQuery+=" ,CASE WHEN AE8_SEXO='2' THEN 'Feminino' Else 'Masculino' END AE8_SEXO"+CRLF
cQuery+=" ,AE8_DTINI"+CRLF
cQuery+=" ,AE8_DTFIM"+CRLF
cQuery+=" ,AE8_CUSFIX"+CRLF
cQuery+=" ,CASE "+CRLF
cQuery+=" 	WHEN AE8_TPCONT='1' THEN 'CLT' "+CRLF
cQuery+=" 	WHEN AE8_TPCONT='2' THEN 'PJ' "+CRLF
cQuery+=" 	WHEN AE8_TPCONT='3' THEN 'PJ Horista' "+CRLF
cQuery+=" 	WHEN AE8_TPCONT='4' THEN 'Cooperado Horista' "+CRLF
cQuery+=" 	WHEN AE8_TPCONT='5' THEN 'Cooperado Mensalista' "+CRLF
cQuery+=" 	ELSE ''"+CRLF
cQuery+="  END AE8_TPCONT"+CRLF
cQuery+=" ,CASE WHEN AE8_ATIVO='2' THEN 'Inativo' Else 'Ativo' END AE8_ATIVO"+CRLF
cQuery+=" ,AE8_DTREAJ"+CRLF
cQuery+=" ,AE8_CARGO"+CRLF
cQuery+=" ,Z40.Z40_DESCRI "+CRLF
cQuery+=" ,AE8_CARGOA "+CRLF
cQuery+=" ,Z40A.Z40_DESCRI CARGOA "+CRLF
cQuery+=" ,CASE "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='1' THEN 'ALFA(07)' "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='2' THEN 'MOOVE' "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='3' THEN 'GNP' "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='4' THEN 'ALFA(24)' "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='5' THEN 'CAMPINAS' "+CRLF
cQuery+=" 	WHEN AE8_EMPFAT='6' THEN 'COLABORACAO' "+CRLF
cQuery+=" 	ELSE ''"+CRLF
cQuery+="  END AE8_EMPFAT"+CRLF
cQuery+=" ,AE8_AREA"+CRLF
cQuery+=" ,Z41_DESCRI"+CRLF
cQuery+=" ,AE8_COORD"+CRLF
cQuery+=" ,CASE WHEN AE8_XCLASS='1' THEN 'MOI' Else 'MOD' END AE8_XCLASS"+CRLF 
cQuery+=" FROM "+RetSqlName('AE8')+" AE8 "+CRLF
cQuery+=" LEFT JOIN "+RetSqlName('Z40')+" Z40 ON Z40.Z40_FILIAL ='"+xFilial('Z40')+"' AND Z40.Z40_CODIGO = AE8_CARGO AND Z40.D_E_L_E_T_=''"+CRLF
cQuery+=" LEFT JOIN "+RetSqlName('Z40')+" Z40A ON Z40A.Z40_FILIAL ='"+xFilial('Z40')+"' AND Z40A.Z40_CODIGO = AE8_CARGOA AND Z40A.D_E_L_E_T_=''"+CRLF
cQuery+=" LEFT JOIN "+RetSqlName('Z41')+" Z41 ON Z41_FILIAL ='"+xFilial('Z41')+"' AND Z41_CODIGO = AE8_AREA AND Z41.D_E_L_E_T_=''"+CRLF
cQuery+=" WHERE "+CRLF
cQuery+=" AE8_FILIAL='"+xFilial('AE8')+"'"+CRLF
cQuery+=" AND AE8_RECURS BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF

IF MV_PAR03 <> 3
    cQuery+=" AND AE8_ATIVO = '"+ALLTRIM(STR(MV_PAR03))+"'"+CRLF
END

cQuery+=" AND AE8.D_E_L_E_T_=''"+CRLF
//cQuery+=" AND AE8_DESCRI LIKE '%PEDRO H%'"+CRLF

cTmp := MPSysOpenQuery(cQuery)
//Aba 01 - Teste           ABA
oFWMsExcel:AddworkSheet(cPlan) //Não utilizar número junto com sinal de menos. Ex.: 1- 
//Criando a Tabela     ABA             TABELA
oFWMsExcel:AddTable(cPlan,cPlan)


oFWMsExcel:AddColumn(cPlan, cPlan, 'Recurso	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Nome	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Celular Part	'   ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Email	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Sexo	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Dt Inicio	'       ,2,4) // centro - data
oFWMsExcel:AddColumn(cPlan, cPlan, 'Dt Saida	'       ,2,4) // centro - data
oFWMsExcel:AddColumn(cPlan, cPlan, 'Valor	'           ,3,2) // direita - numero        		
oFWMsExcel:AddColumn(cPlan, cPlan, 'Tp Contrato'        ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Status	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Dt.Reajuste	'       ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Cargo ATUAL	'       ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'CARGO NOVO	'       ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Empresa	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Área	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Gestor	'           ,1,1) // esquerda - texto
oFWMsExcel:AddColumn(cPlan, cPlan, 'Classificação	'   ,1,1) // esquerda - texto


while (cTmp)->(!eof())

    
    aAux :={}

    AADD(aAux, (cTmp)->AE8_RECURS )		
    AADD(aAux, (cTmp)->AE8_DESCRI )		
    AADD(aAux, (cTmp)->AE8_CELULA )		
    AADD(aAux, (cTmp)->AE8_EMAIL )		
    AADD(aAux, (cTmp)->AE8_SEXO )		
    AADD(aAux, DTOC(STOD( (cTmp)->AE8_DTINI)) )		 
    AADD(aAux, DTOC(STOD( (cTmp)->AE8_DTFIM)) )		
    AADD(aAux, (cTmp)->AE8_CUSFIX )		    
    AADD(aAux, (cTmp)->AE8_TPCONT )		
    AADD(aAux, (cTmp)->AE8_ATIVO )		
    AADD(aAux, DTOC(STOD((cTmp)->AE8_DTREAJ)) )	
    AADD(aAux, (cTmp)->Z40_DESCRI )		
    AADD(aAux, (cTmp)->CARGOA ) // novo cargo		
    AADD(aAux, (cTmp)->AE8_EMPFAT )		
    AADD(aAux, (cTmp)->Z41_DESCRI )		
    AADD(aAux, POSICIONE("AE8",1,xFilial("AE8")+(cTmp)->AE8_COORD,"AE8_NREDUZ")  )		    
    AADD(aAux, (cTmp)->AE8_XCLASS )		
    		


    oFWMsExcel:AddRow(cPlan,cPlan,aAux)   	

    (cTmp)->( dbSkip() )    
end

(cTmp)->( DbCloseArea() )

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

Local cDir	:= GetTempPath() 
Local cArq	:= cDir+"BAUTQD02-"+Alltrim(DtoS(dDataBase))+"-"+Alltrim(STRTRAN(TIME(),":",""))+".xls"

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
