#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS15
 
Descricao: gera arquivo csv coporis

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFPMS15( cGrupo )


Local aArea 	:= GetArea()
Private aParamBox := {} 
Private aRetParam:={}

// Parametros
Private cLocArq   := Space(200)
Private cNomArq   := alltrim(SZH->ZH_COMPETE)+'-'+alltrim(SZH->ZH_REVISAO)+'-'+alltrim(SZH->ZH_DESCRI)+'.csv'


aAdd( aParamBox, { 1, "Diretorio:"	 , cLocArq,  , "MV_PAR01:=cGetFile('Diretorio','',,,,176)", ""   , "", 50, .T.} )

IF ParamBox(aParamBox,"Informe o diretorio para geração",@aRetParam)
    cLocArq  := aRetParam[1]
    
    FwMsgRun( ,{|| GeraRelatorio(  ) 	},, "Aguarde. Gerando arquivo..." )

Endif


RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraRelatorio
Gera relatorio do tipo categorias ou filiais.

@author  Pedro Oliveira
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraRelatorio(oXml)

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT AE8_XMATCP,AE8_DESCRI,ZI_VLRTOT,ZI_VLRREEM "+ CRLF
cQuery += " FROM "+RetSqlName("SZI")+" SZI (NOLOCK) "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("SZH")+" SZH (NOLOCK) "+ CRLF
cQuery += " 	ON SZH.ZH_FILIAL = '"+xFilial("SZH")+"' "+ CRLF
cQuery += " 	AND ZH_COMPETE =  ZI_COMPETE "+ CRLF
cQuery += " 	AND ZH_REVISAO = ZI_REVISAO "+ CRLF 
cQuery += " 	AND SZH.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " INNER JOIN "+RetSqlName("AE8")+" AE8 (NOLOCK) "+ CRLF
cQuery += " 	ON AE8_FILIAL = '"+xFilial("AE8")+"' "+ CRLF
cQuery += " 	AND AE8_RECURS = ZI_RECURSO "+ CRLF 
cQuery += " 	AND AE8.D_E_L_E_T_ = ' ' "+ CRLF 

cQuery += " WHERE "+ CRLF
cQuery += " 	ZI_FILIAL = '"+xFilial("SZI")+"' "+ CRLF
cQuery += " 	AND ZI_COMPETE = '"+SZH->ZH_COMPETE+"' "+ CRLF
cQuery += " 	AND ZI_REVISAO = '"+SZH->ZH_REVISAO+"' "+ CRLF

cQuery += " 	AND SZI.D_E_L_E_T_ = ' ' "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFPMS15.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)
cArqDest:= ALLTRIM(cLocArq)+ALLTRIM(cNomArq)

nHandle := FCREATE(cArqDest, 0)
If FERROR() != 0
    Alert("Nao foi possivel criar o arquivo: " + cArqDest )
Else
    cStrCSV := 'Matricula;Nome;Remuneração Fixa;Custeio de atividade;Reembolso;Bonus Anual;Remuneração Variavel'+CRLF
    (FWRITE(nHandle, cStrCSV))			
    while (cTMP1)->(!EOF())

			cStrCSV := alltrim((cTMP1)->AE8_XMATCP)+';'
			cStrCSV += alltrim((cTMP1)->AE8_DESCRI)+';'
			cStrCSV += cValToChar( (cTMP1)->ZI_VLRTOT - (cTMP1)->ZI_VLRREEM )+';'
			cStrCSV += '0;'		
			cStrCSV += cValToChar((cTMP1)->ZI_VLRREEM)+';'
			cStrCSV += '0;'
			cStrCSV += '0'
			cStrCSV += CRLF
		
			FWrite(nHandle, cStrCSV)

        (cTMP1)->( DBSKIP())    
    end
    
    fCLose(nHandle)		
    MsgInfo("Arquivo gerado com sucesso: "+ cArqDest ,"Atenção")	
        
End 
(cTMP1)->( DBCLOSEAREA())

Return 
