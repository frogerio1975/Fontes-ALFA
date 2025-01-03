#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFIMPOS
Ajusta Imposto de Acordo com a Natureza

@author FR
@since   02/01/2025
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFIMPOS()
Local aBoxParam	:= {}
Local aRetParam	:= {}
Local lRetorno 	:= .T.
Local c_Nature  := ""
Local nVlr1     := 0

// Parametros
Private aEmpFat  := { "1=ALFA", "2=MOOVE", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração","0-TODAS" }
Private aTipo    := { "1=Contas a Receber", "2=Contas a Pagar" }
Private cTipo    := ""
Private cEmpFat  := "1"
Private cNaturez := CriaVar("E1_NATUREZ")

AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat , 80, ".F.", .T.} )
AADD( aBoxParam, {1,"Natureza"        , cNaturez  , "@!", "", "", "", 50, .T.} )
AADD( aBoxParam, {2,"Tipo"            , cTipo     , aTipo, 80, ".F.", .T.} )

If ParamBox(aBoxParam,"Parametros - Ajusta Imposto",@aRetParam,,,,,,,,.F.)

    cEmpFat  := aRetParam[1]
    cNaturez := aRetParam[2]
    cTipo    := aRetParam[3]

    cTMP1 := LoadDados() 


    While (cTMP1)->(!EOF())

        lMsErroAuto := .F.//231117//000043681
        lMsHelpAuto := .F.
        aVetor      := {}
        
        IF (cTipo == "1")
            c_Nature := (cTMP1)->E1_NATUREZ 
            nVlr1    := (cTMP1)->E1_VALOR       

            aVetor := { {"E1_FILIAL", 	(cTMP1)->E1_FILIAL, 	NIL},;			
                        {"E1_PREFIXO", 	(cTMP1)->E1_PREFIXO, 	NIL},;
                        {"E1_NUM", 		(cTMP1)->E1_NUM, 		NIL},;
                        {"E1_PARCELA", 	(cTMP1)->E1_PARCELA,	NIL},;
                        {"E1_TIPO", 	(cTMP1)->E1_TIPO, 	    NIL},;
                        {"E1_CLIENTE", 	(cTMP1)->E1_CLIENTE, 	NIL},;
                        {"E1_LOJA", 	(cTMP1)->E1_LOJA, 	    NIL},;
                        {"E1_VALOR", 	nVlr1, 	                NIL}   ,;
                        {"E1_NATUREZ", 	c_Nature, 	            NIL}   }                        

            LjMsgRun( 'Titulo: ' + AllTrim((cTMP1)->E1_NUM) + "/" + AllTrim((cTMP1)->E1_PARCELA) + " - " + Left((cTMP1)->E1_NOMCLI,20), "Atualizando Impostos do Titulo", {|| MSExecAuto({|x,y| FINA040(x,y)},aVetor,4) })
		
        Else    
            c_Nature := (cTMP1)->E2_NATUREZ        
            nVlr1    := (cTMP1)->E2_VALOR

            aVetor := { {"E2_FILIAL", 	(cTMP1)->E2_FILIAL, 	NIL},;			
                        {"E2_PREFIXO", 	(cTMP1)->E2_PREFIXO, 	NIL},;
                        {"E2_NUM", 		(cTMP1)->E2_NUM, 		NIL},;
                        {"E2_PARCELA", 	(cTMP1)->E2_PARCELA,	NIL},;
                        {"E2_TIPO", 	(cTMP1)->E2_TIPO, 	    NIL},;
                        {"E2_CLIENTE", 	(cTMP1)->E2_FORNECE, 	NIL},;
                        {"E2_LOJA", 	(cTMP1)->E2_LOJA, 	    NIL},;
                        {"E2_VALOR", 	nVlr1,          	    NIL},;
                        {"E2_NATUREZ", 	c_Nature, 	            NIL}   }                        

            LjMsgRun( 'Titulo: ' + AllTrim((cTMP1)->E2_NUM) + "/" + AllTrim((cTMP1)->E2_PARCELA) + " - " + Left((cTMP1)->E1_NOMFOR,20),"Atualizando Impostos do Titulo", {|| MSExecAuto({|x,y| FINA050(x,y)},aVetor,4) })
        EndIf

        IF lMsErroAuto
            lRet := .F.
            MostraErro()                    
        Else
            lRet := .T.                    
        EndIF
        
        (cTMP1)->(dbSkip())
               
    End 
    (cTMP1)->(dbCloseArea()) 
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CompetenciaLoadDados
Rotina para carregar os dados do relatorio via query. Regime de Competencia

@author  Wilson A. Silva Jr
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados()

Local cTMP1    := ""
Local cQuery   := ""
Local nX
Local cAlias   := ""

cAlias:=  IIF(cTipo =="1","SE1","SE2")

cQuery := " SELECT * "+ CRLF
cQuery += " FROM "+RetSqlName(cAlias)+" " + cAlias +" (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("SED")+" SED (NOLOCK) "+ CRLF
cQuery += " 	ON SED.ED_FILIAL = '"+xFilial("SED")+"' "+ CRLF

If (cTipo == "1")
    cQuery += " 	AND SED.ED_CODIGO = E1_NATUREZ "+ CRLF
Else
    cQuery += " 	AND SED.ED_CODIGO = E2_NATUREZ "+ CRLF
EndIf
cQuery += " 	AND SED.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " WHERE "+ CRLF

If (cTipo == "1")
    cQuery += " 	SE1.E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
    cQuery += " 	AND SE1.E1_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE1.E1_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE1.E1_BAIXA =  '        ' " + CRLF
    cQuery += " 	AND SE1.E1_VALOR = SE1.E1_SALDO " + CRLF
    cQuery += " 	AND (SE1.E1_FATURA = ' ' OR E1_FATURA = 'NOTFAT')"+ CRLF
    cQuery += " 	AND SE1.E1_NATUREZ =  '" + cNaturez + "' " + CRLF
    cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
Else
    cQuery += " 	SE2.E2_FILIAL = '"+xFilial("SE2")+"' "+ CRLF
    cQuery += " 	AND SE2.E2_EMPFAT = '"+cEmpFat+"' "+ CRLF
    cQuery += " 	AND SE2.E2_TIPO = 'DP' "+ CRLF
    cQuery += " 	AND SE2.E2_BAIXA =  '        ' " + CRLF
    cQuery += " 	AND SE2.E2_VALOR = SE2.E2_SALDO " + CRLF
    cQuery += " 	AND SE2.E2_NATUREZ =  '" + cNaturez + "' " + CRLF
    cQuery += " 	AND SE2.D_E_L_E_T_ = ' ' "+ CRLF
EndIf

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFIMPOSTO.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1
