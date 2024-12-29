#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFAOS00
Job integração com o Movidesk para importação das ordens de serviço.

@author  Wilson A. Silva Jr.
@since   21/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFAOS00(cEmpTrab, cFilTrab, cIntervalo, cHorario, cDia)

Local nIntervalo  := 0
Local nStep		  := 0
Local nCount 	  := 0

Private cDirImp	:= "\DEBUG\"
Private cARQLOG	:= cDirImp+"ALFAOS00_"+cEmpTrab+"_"+cFilTrab+".LOG"
Private cHoras 	:= ""

DEFAULT cIntervalo := "60000" // 60000 milisegundos = 1 minuto
DEFAULT cHorario   := "23:30:00"
DEFAULT cDia	   := "1,2,3,4,5,6,7" // 1==Domingo

nIntervalo := Val(cIntervalo)
cHoras 	   := LEFT(cHorario,5) 

// Comando para nao consumir licencas. 
RpcSetType(3)     

// Inicializa ambiente.
PREPARE ENVIRONMENT EMPRESA cEmpTrab FILIAL cFilTrab MODULO "FRT" FUNNAME "SIGAFRT"

FwMakeDir(cDirImp) // Cria diretorio de DEBUG caso nao exista

While !KillApp()
	
    If LEFT(Time(),5) == cHoras .AND. cValToChar(DOW(DATE())) $ cDia
        Conout("")
        Conout(Replicate('-',80))
        Conout("INICIADO ROTINA DE INTEGRACAO MOVIDESK: ALFAOS00() - DATA/HORA: "+DToC(Date())+" AS "+Time())
        
        LjWriteLog( cARQLOG, Replicate('-',80) )
        LjWriteLog( cARQLOG, "INICIADO ROTINA DE INTEGRACAO MOVIDESK: ALFAOS00() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
        
        // Chamada da rotina de processamento.
        U_ALFAOS01(.T.)
        
        Conout("FINALIZADO ROTINA DE INTEGRACAO MOVIDESK: ALFAOS00() - DATA/HORA: "+DToC(Date())+" AS "+Time())
        Conout(Replicate('-',80)) 
        Conout("")       
        
        LjWriteLog( cARQLOG, "FINALIZADO ROTINA DE INTEGRACAO MOVIDESK: ALFAOS00() - DATA/HORA: "+DToC(Date())+" AS "+Time() )
        LjWriteLog( cARQLOG, Replicate('-',80) )
        
		// Apos execucao sai da rotina.
		EXIT
    EndIf

    nStep  := 1
    nCount := nIntervalo/1000
    While !KillApp() .AND. nStep <= nCount
        Sleep(1000) //Sleep de 1 segundo
        nStep++
    EndDo
EndDo
 
// Finaliza ambiente.
RESET ENVIRONMENT   

Return .T.