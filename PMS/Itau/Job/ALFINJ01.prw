#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINJ01
JOB para processamento da fila de integração de boletos Itau.

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINJ01(cEmpTrab, cFilTrab, cIntervalo, cDia)

Local nIntervalo  := 0
Local nStep		  := 0
Local nCount 	  := 0

Private cDirImp	:= "\DEBUG\"
Private cARQLOG	:= cDirImp+"ALFINJ01_"+cEmpTrab+"_"+cFilTrab+".LOG"

DEFAULT cIntervalo:= "3600000" // 60000 milisegundos = 1 minuto
DEFAULT cDia	  := "2,3,4,5,6,7" // 1==Domingo

nIntervalo := Val(cIntervalo)

// Comando para nao consumir licencas. 
RpcSetType(3)     

// Inicializa ambiente.
PREPARE ENVIRONMENT EMPRESA cEmpTrab FILIAL cFilTrab MODULO "FRT" FUNNAME "SIGAFRT"

FwMakeDir(cDirImp) // Cria diretorio de DEBUG caso nao exista

If cValToChar(DOW(DATE())) $ cDia
	Conout("")
	Conout(Replicate('-',80))
	Conout("INICIADO PROCESSAMENTO DE BOLETO ITAU: ALFINJ01() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	
	LjWriteLog( cARQLOG, Replicate('-',80) )
	LjWriteLog( cARQLOG, "INICIADO PROCESSAMENTO DE BOLETO ITAU: ALFINJ01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
		
	// Chamada da rotina de processamento. 
	ExecInteg()
	
	Conout("FINALIZADO PROCESSAMENTO DE BOLETO ITAU: ALFINJ01() - DATA/HORA: "+DToC(Date())+" AS "+Time())
	Conout(Replicate('-',80)) 
	Conout("")       
	
	LjWriteLog( cARQLOG, "FINALIZADO PROCESSAMENTO DE BOLETO ITAU: ALFINJ01() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
	LjWriteLog( cARQLOG, Replicate('-',80) )
EndIf

nStep  := 1
nCount := nIntervalo/1000
While !KillApp() .AND. nStep <= nCount
	Sleep(1000) //Sleep de 1 segundo
	nStep++
EndDo
 
// Finaliza ambiente.
RESET ENVIRONMENT   

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecInteg
JOB para processamento de requisicoes do Requestia (XTM).

@author  Wilson A. Silva Jr
@since   14/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExecInteg()

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT "+ CRLF
cQuery += " 	XTM.R_E_C_N_O_ AS XTMREC "+ CRLF
cQuery += " FROM "+RetSqlName("XTM")+" XTM (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += " 	XTM.XTM_FILIAL = '"+xFilial("XTM")+"' "+ CRLF
cQuery += " 	AND XTM.XTM_STATUS IN ('1') "+ CRLF // 1=Pendente e 3=Erro
cQuery += " 	AND XTM.XTM_ACAO IN ('4') "+ CRLF // 4=Envio de Boleto Por E-mail
cQuery += " 	AND XTM.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += "     XTM.R_E_C_N_O_ "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    XTM->(DbGoTo((CTMP1)->XTMREC))

    // DO CASE
    //     CASE XTM->XTM_ACAO == "1" // Registro Boleto
    //         U_ALFINM02()
    //     CASE XTM->XTM_ACAO == "2" // Cancelamento/Baixa Boleto
    //         U_ALFINM03()
    //     CASE XTM->XTM_ACAO == "3" // Alteração Vencimento
    //         U_ALFINM04()
    //     CASE XTM->XTM_ACAO == "4" // Envio de Boleto Por E-mail
            U_ALFINM05()
    // ENDCASE

    (cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

Return .T.

