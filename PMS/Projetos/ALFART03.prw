#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFART03
Rotina de integração dos apontamentos do ARTIA via Linked Server.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFART03()

Local aBoxParam	:= {}
Local aRetParam	:= {}
Local dPerIni   := FirstDay(dDatabase)
Local dPerFim   := LastDay(dDatabase)
Local lRetorno 	:= .T.
Local cMsgErro  := ""
Local cTMP1     := ""

AADD( aBoxParam, {1,"Período DE"   , dPerIni  , "@!", "", ""   , "", 50, .F.} )
AADD( aBoxParam, {1,"Período ATE"  , dPerFim  , "@!", "", ""   , "", 50, .F.} )

If ParamBox(aBoxParam,"Integração Apontamentos ARTIA",@aRetParam,,,,,,,,.F.)

    dPerIni := aRetParam[1]
    dPerFim := aRetParam[2]
    
    FwMsgRun( ,{|| cTMP1 := LoadDados(dPerIni, dPerFim) }, , "Por favor, aguarde. Conectando no ARTIA..." )

    If (cTMP1)->(!EOF())

        FwMsgRun( ,{|| lRetorno := OS01GrvOS(cTMP1, @cMsgErro) }, , "Por favor, aguarde. Integrando apontamentos do ARTIA..." )

        If lRetorno
            Help(Nil,Nil,"Sucesso",,"Apontamentos foram integrados com sucesso.", 1, 5)
        Else
            Help(Nil,Nil,"Erro",,"Existem apontamentos com erro.", 1, 5)
        EndIf
    Else
        Help(Nil,Nil,ProcName(),,"Não existem apontamentos no período informado.", 1, 5)
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDados
Rotina para carregar os dados do relatorio via query.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadDados(dPerIni, dPerFim)

Local cTMP1  := ""
Local cQuery := ""

cQuery := " SELECT "+ CRLF
cQuery += "     artia.apontamentoId "+ CRLF
cQuery += "     ,artia.status "+ CRLF
cQuery += "     ,artia.projetoId "+ CRLF
cQuery += "     ,artia.projetoNumero "+ CRLF
cQuery += "     ,artia.projetoNome "+ CRLF
cQuery += " 	,CONVERT(varchar(255), artia.breadcrumb) as diretorio "+ CRLF
cQuery += "     ,artia.usuarioRecurso "+ CRLF
cQuery += "     ,artia.dataApontamento "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.horaInicio) as horaInicio "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.horaFim) as horaFim "+ CRLF
cQuery += "     ,artia.duracao "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.dataCriacao) as dataCriacao "+ CRLF
cQuery += "     ,CONVERT(varchar(19), artia.dataAlteracao) as dataAlteracao "+ CRLF
cQuery += "     ,artia.atividadeId "+ CRLF
cQuery += "     ,CONVERT(varchar(255), artia.atividadeTitulo) as atividadeTitulo "+ CRLF
cQuery += " 	,artia.inicioEstimado as inicioEstimado "+ CRLF
cQuery += " 	,artia.finalEstimado as finalEstimado "+ CRLF
cQuery += " 	,artia.esforcoEstimado as esforcoEstimado "+ CRLF
cQuery += " 	,' ' as apontObs "+ CRLF //cQuery += " 	,CONVERT(varchar(255), artia.observacao) as apontObs "+ CRLF
cQuery += " 	,ISNULL(CONVERT(varchar(20), artia.tipoAtendimento),' ') as tipoAtendimento "+ CRLF
cQuery += "     ,AF8.AF8_PROJET "+ CRLF
cQuery += "     ,AF8.AF8_PROPOS "+ CRLF
cQuery += "     ,AF8.AF8_DESCRI "+ CRLF
cQuery += "     ,AF8.AF8_CLIENT "+ CRLF
cQuery += "     ,AF8.AF8_LOJA "+ CRLF
cQuery += "     ,SA1.A1_NOME "+ CRLF
cQuery += "     ,SA1.A1_NREDUZ "+ CRLF
cQuery += "     ,SA1.A1_CGC "+ CRLF
cQuery += "     ,AF8.AF8_DATA "+ CRLF
cQuery += "     ,AF8.AF8_HORAS "+ CRLF
cQuery += "     ,AF8.AF8_APORTE "+ CRLF
cQuery += "     ,AF8.AF8_CUSTO "+ CRLF
cQuery += "     ,AF8.AF8_REVISA "+ CRLF
cQuery += "     ,AF8.AF8_TPHORA "+ CRLF
cQuery += "     ,AF8.AF8_COORD "+ CRLF
cQuery += "     ,AF8.AF8_APROVA "+ CRLF
cQuery += "     ,AF8.AF8_TPSERV "+ CRLF
cQuery += "     ,AE8.AE8_RECURS "+ CRLF
cQuery += " FROM OPENQUERY( [ARTIA-ALFA], "+ CRLF
cQuery += "     'SELECT "+ CRLF
cQuery += "         apo.id as apontamentoId "+ CRLF
cQuery += "         ,apo.status as status "+ CRLF
cQuery += "         ,apo.folder_last_project_id as projetoId "+ CRLF
cQuery += "         ,prj.project_number as projetoNumero "+ CRLF
cQuery += "         ,prj.project_name as projetoNome "+ CRLF
cQuery += "         ,prj.breadcrumb as breadcrumb "+ CRLF
cQuery += "         ,apo.member_email as usuarioRecurso "+ CRLF
cQuery += "         ,apo.date_at as dataApontamento "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.start_time,''+00:00'',''-03:00'') as horaInicio "+ CRLF
cQuery += "         ,CONVERT_TZ(DATE_ADD(apo.start_time, INTERVAL (3600*apo.duration_hour) SECOND),''+00:00'',''-03:00'') as horaFim "+ CRLF
cQuery += "         ,apo.duration_hour as duracao "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.created_at,''+00:00'',''-03:00'') as dataCriacao "+ CRLF
cQuery += "         ,CONVERT_TZ(apo.updated_at,''+00:00'',''-03:00'') as dataAlteracao "+ CRLF
cQuery += "         ,apo.activity_id as atividadeId "+ CRLF
cQuery += "         ,apo.activity_title as atividadeTitulo "+ CRLF
cQuery += " 	    ,act.estimated_start as inicioEstimado "+ CRLF
cQuery += " 	    ,act.estimated_end as finalEstimado "+ CRLF
cQuery += " 	    ,act.estimated_effort as esforcoEstimado "+ CRLF
cQuery += "         ,apo.observation as observacao "+ CRLF
cQuery += " 	    ,apo.atendimento as tipoAtendimento "+ CRLF
cQuery += "     FROM organization_103444_time_entries apo "+ CRLF
cQuery += "     LEFT JOIN organization_103444_projects prj "+ CRLF
cQuery += "         ON prj.id = apo.folder_last_project_id "+ CRLF
cQuery += "         AND prj.account_id = apo.account_id "+ CRLF
cQuery += "     LEFT JOIN organization_103444_activities act "+ CRLF
cQuery += "         ON act.id = apo.activity_id "+ CRLF
cQuery += "         AND act.account_id = apo.account_id "+ CRLF
cQuery += "     WHERE "+ CRLF
cQuery += "         apo.date_at BETWEEN ''"+Transform(DToS(dPerIni),"@R 9999-99-99")+"'' AND ''"+Transform(DToS(dPerFim),"@R 9999-99-99")+"'' "+ CRLF
cQuery += " ') artia "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("AF8")+" AF8 (NOLOCK) "+ CRLF
cQuery += " 	ON AF8.AF8_FILIAL = '"+xFilial("AF8")+"' "+ CRLF
cQuery += " 	AND AF8.AF8_PROJET = FORMAT(CONVERT(INT, artia.projetoNumero), '0000000000') "+ CRLF
cQuery += " 	AND AF8.AF8_PROJET <> '0000000000' "+ CRLF
cQuery += " 	AND AF8.AF8_DATA >= '20180101' "+ CRLF
cQuery += " 	AND AF8.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF
cQuery += " 	ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF
cQuery += " 	AND SA1.A1_COD = AF8.AF8_CLIENT "+ CRLF
cQuery += " 	AND SA1.A1_LOJA = AF8.AF8_LOJA "+ CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " LEFT JOIN "+RetSqlName("AE8")+" AE8 (NOLOCK) "+ CRLF
cQuery += "     ON AE8.AE8_FILIAL = '"+xFilial("AE8")+"' "+ CRLF
cQuery += "     AND AE8.AE8_EMAIL = artia.usuarioRecurso "+ CRLF
// cQuery += "     AND AE8.AE8_ATIVO = '1' "+ CRLF
cQuery += "     AND AE8.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	artia.apontamentoId "+ CRLF

// Salva query em disco para debug.
If .T.//GetNewPar("SY_DEBUG", .T.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_ALFART03.SQL", cQuery)
EndIf

cTMP1 := MPSysOpenQuery(cQuery)

Return cTMP1

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01GrvOS
Realiza a gravação das Ordens de Serviço.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OS01GrvOS(cTMP1, cMsgErro)

Local aAreaAtu  := GetArea()
Local lRetorno  := .T.
Local cNumOS	:= ""
Local cRecurso	:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cCodProj	:= ""
Local cRevProj	:= ""
Local cItemProj	:= ""
Local cTpHora	:= ""
Local cCoord	:= ""
Local cAprov	:= "104431"
Local cTpServ	:= ""
Local dAgenda   := SToD("")
Local cHrIni	:= ""
Local cHrFim	:= ""
Local cHrTot	:= ""
Local nTamItem	:= TamSX3("Z3_ITEM")[1]

While (cTMP1)->(!EOF())

    lRetorno := .T.

    cIdArtia := StrZero((cTMP1)->apontamentoId,10)
    
    cCodProj := (cTMP1)->AF8_PROJET
    cRecurso := (cTMP1)->AE8_RECURS
    cCliente := (cTMP1)->AF8_CLIENT
    cLoja	 := (cTMP1)->AF8_LOJA
	cRevProj := (cTMP1)->AF8_REVISA
	cTpHora	 := (cTMP1)->AF8_TPHORA
	cTpServ  := (cTMP1)->AF8_TPSERV

    dAgenda  := (cTMP1)->dataApontamento
    cHrIni	 := RetHora((cTMP1)->horaInicio)
    cHrFim	 := RetHora((cTMP1)->horaFim)
    cHrTot	 := ConvTime((cTMP1)->duracao)

    DO CASE
        CASE AllTrim(UPPER((cTMP1)->tipoAtendimento)) == "PRESENCIAL"
            cTpAtend := "1" // 1=Atendimento Presencial no Cliente;
        CASE AllTrim(UPPER((cTMP1)->tipoAtendimento)) == "REMOTO"
            cTpAtend := "2" // 2=Atendimento Remoto;
        CASE AllTrim(UPPER((cTMP1)->tipoAtendimento)) == "ALFA"
            cTpAtend := "3" // 3=Atendimento Presencial na Consultoria
        OTHERWISE
            cTpAtend := "3" // 3=Atendimento Presencial na Consultoria
    ENDCASE

    If lRetorno .And. Empty(cCodProj)
        lRetorno := .F.
        cMsgErro := "Projeto não localizado ("+(cTMP1)->projetoNumero+")"
    EndIf

    If lRetorno .And. Empty(cRecurso)
        lRetorno := .F.
        cMsgErro := "Recurso não localizado ("+(cTMP1)->usuarioRecurso+")"
    EndIf

    // Caso já exista OS do ARTIA exclui para lançar atualizada.
    lRetorno := lRetorno .And. DelOSAntiga(cRecurso, dAgenda, cCliente, cLoja, cIdArtia, @cMsgErro)
    
    If !lRetorno
        (cTMP1)->(dbSkip())
        LOOP
    EndIf

    cNumOS := OS01GetNum()
    
    // Obtém o item do projeto
    cTarRet := ""
    If !OS01Item(cCodProj, cRevProj, (cTMP1)->atividadeId, @cTarRet)
        cTarRet := OS01NewTar(;
            cCodProj,;
            cRevProj,;
            (cTMP1)->atividadeId,;
            (cTMP1)->atividadeTitulo,;
            (cTMP1)->esforcoEstimado,;
            (cTMP1)->inicioEstimado,;
            (cTMP1)->finalEstimado )
    EndIf
    
    // Gravação do Cabeçalho da O.S
    RecLock("SZ2",.T.)
        REPLACE Z2_FILIAL 	WITH xFilial("SZ2")
        REPLACE Z2_OS		WITH cNumOS
        REPLACE Z2_DATA	    WITH dAgenda
        REPLACE Z2_RECURSO	WITH cRecurso
        REPLACE Z2_CLIENTE	WITH cCliente
        REPLACE Z2_LOJA	    WITH cLoja
        REPLACE Z2_HRINI1	WITH Left(cHrIni,5)
        REPLACE Z2_HRFIM1	WITH Left(cHrFim,5)
        REPLACE Z2_TOTALHR	WITH Left(cHrTot,5)
        REPLACE Z2_STATUS	WITH "2"
        REPLACE Z2_DATAINC	WITH RetData((cTMP1)->dataCriacao)
        REPLACE Z2_DTENCER	WITH RetData((cTMP1)->horaInicio)
        REPLACE Z2_COORD    WITH cCoord
        REPLACE Z2_CODRESP  WITH cAprov
        REPLACE Z2_TRANSLA	WITH "00:00"
        REPLACE Z2_ESTAC	WITH 0
        REPLACE Z2_PEDAGIO	WITH 0
        REPLACE Z2_TPATEND	WITH cTpAtend
        REPLACE Z2_CODSER	WITH cTpServ
        REPLACE Z2_ARTIA	WITH "S"
        REPLACE Z2_DTARTIA	WITH DATE()
        REPLACE Z2_HRARTIA	WITH TIME()
        REPLACE Z2_HRARTIA	WITH TIME()
        REPLACE Z2_XIDARTI	WITH cIdArtia
    SZ2->(MsUnlock())
    
    // Gravação dos itens da O.S
    RecLock("SZ3",.T.)
        REPLACE Z3_FILIAL	WITH xFilial("SZ3")
        REPLACE Z3_OS		WITH cNumOS
        REPLACE Z3_ITEM	    WITH StrZero(1,nTamItem)
        REPLACE Z3_PROJETO	WITH cCodProj
        REPLACE Z3_REVISA	WITH cRevProj
        REPLACE Z3_TAREFA	WITH cTarRet
        REPLACE Z3_HORAS	WITH Left(cHrTot,5)
        REPLACE Z3_HUTEIS	WITH (cTMP1)->duracao
        REPLACE Z3_STATUS	WITH "2"
        REPLACE Z3_TEXTO	WITH (cTMP1)->atividadeTitulo
        REPLACE Z3_TPHORA	WITH cTpHora
        REPLACE Z3_CODSER	WITH cTpServ
    SZ3->(MsUnlock())

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01GetNum
Retorna código e loja do cliente por referência 

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OS01GetNum()

Local aArea    := GetArea()
Local cTMP1    := ""
Local cQuery   := ""
Local cNextCod := StrZero(0,TAMSX3("Z2_OS")[1])

cQuery := " SELECT "+ CRLF
cQuery += "     MAX(SZ2.Z2_OS) AS MAXNUM "+ CRLF
cQuery += " FROM "+RetSqlName("SZ2")+" SZ2 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SZ2.Z2_FILIAL = '"+xFilial("SZ2")+"' "+ CRLF
cQuery += "     AND SZ2.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
	cNextCod := SOMA1((cTMP1)->MAXNUM)
EndIf

(cTMP1)->(dbCloseArea())

RestArea(aArea)

Return cNextCod

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Item
Retorna o item do projeto

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OS01Item(cCodProj, cRevProj, nIdAtiv, cTarRet)

Local aArea    := GetArea()
Local cTMP1    := ""
Local cQuery   := ""
Local lRetorno := .T.

cQuery := " SELECT "+ CRLF
cQuery += "     AF9.AF9_TAREFA "+ CRLF
cQuery += " FROM "+RetSqlName("AF9")+" AF9 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     AF9.AF9_FILIAL = '"+xFilial("AF9")+"' "+ CRLF
cQuery += "     AND AF9.AF9_PROJET = '"+cCodProj+"' "+ CRLF
cQuery += "     AND AF9.AF9_REVISA = '"+cRevProj+"' "+ CRLF
cQuery += "     AND AF9.AF9_XIDART = '"+StrZero(nIdAtiv,TAMSX3("AF9_XIDART")[1])+"' "+ CRLF
cQuery += "     AND AF9.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
	cTarRet := (cTMP1)->AF9_TAREFA
Else
    lRetorno := .F.
EndIf

(cTMP1)->(dbCloseArea())

RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01NewTar
Retorna o item do projeto

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OS01NewTar(cCodProj, cRevProj, nIdAtiv, cTitle, nDuracao, dStart, dFinish)

Local aArea    := GetArea()
Local cEDTPai  := "01"
Local cEDT     := "01.99"
Local cTarefa  := "01.99.01"
Local cTMP1    := ""
Local cQuery   := ""
Local nX

cQuery := " SELECT "+ CRLF
cQuery += "     MAX(SUBSTRING(AF9.AF9_TAREFA,7,2)) AS MAXTAR "+ CRLF
cQuery += " FROM "+RetSqlName("AF9")+" AF9 (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     AF9.AF9_FILIAL = '"+xFilial("AF9")+"' "+ CRLF
cQuery += "     AND AF9.AF9_PROJET = '"+cCodProj+"' "+ CRLF
cQuery += "     AND AF9.AF9_REVISA = '"+cRevProj+"' "+ CRLF
cQuery += "     AND AF9.AF9_EDTPAI = '"+cEDT+"' "+ CRLF
cQuery += "     AND AF9.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
	cTarefa := cEDT + "." + SOMA1((cTMP1)->MAXTAR)
EndIf

(cTMP1)->(dbCloseArea())

dbSelectArea("AFC")
dbSetOrder(1) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
If !dbSeek(xFilial("AFC")+cCodProj+cRevProj+cEDT)
    RecLock("AFC",.T.)
        For nX := 1 To FCount()
            FieldPut(nX, CriaVar(FieldName(nX), .T.) )
        Next nX

        REPLACE AFC_FILIAL WITH xFilial("AFC")
        REPLACE AFC_PROJET WITH cCodProj
        REPLACE AFC_REVISA WITH cRevProj
        REPLACE AFC_EDT    WITH cEDT
        REPLACE AFC_NIVEL  WITH "002"
        REPLACE AFC_DESCRI WITH "Atividades Integradas do ARTIA"
        REPLACE AFC_QUANT  WITH 1
        REPLACE AFC_CALEND WITH "001"
        REPLACE AFC_START  WITH DATE()
        REPLACE AFC_FINISH WITH DATE()
        REPLACE AFC_EDTPAI WITH cEDTPai
        REPLACE AFC_HUTEIS WITH 0
        REPLACE AFC_HDURAC WITH 0
    MsUnLock()
EndIf

RecLock("AF9",.T.)
    For nX := 1 To FCount()
        FieldPut(nX, CriaVar(FieldName(nX), .T.) )							
    Next nX

    REPLACE AF9_FILIAL WITH xFilial("AF9")
    REPLACE AF9_PROJET WITH cCodProj
    REPLACE AF9_REVISA WITH cRevProj        
    REPLACE AF9_TAREFA WITH cTarefa
    REPLACE AF9_NIVEL  WITH "003"
    REPLACE AF9_DESCRI WITH cTitle
    REPLACE AF9_QUANT  WITH 1
    REPLACE AF9_HDURAC WITH nDuracao
    REPLACE AF9_CALEND WITH "001"
    REPLACE AF9_START  WITH dStart
    REPLACE AF9_FINISH WITH dFinish
    REPLACE AF9_HUTEIS WITH nDuracao
    REPLACE AF9_FATURA WITH "1"
    REPLACE AF9_EDTPAI WITH cEDT
    REPLACE AF9_FASE   WITH "01"
    REPLACE AF9_XIDART WITH StrZero(nIdAtiv,TAMSX3("AF9_XIDART")[1])
    REPLACE AF9_XDTART WITH DATE()
    REPLACE AF9_XHRART WITH TIME()
MsUnLock()

RestArea(aArea)

Return cTarefa

//-------------------------------------------------------------------
/*/{Protheus.doc} DelOSAntiga
Deleta OS antigas.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelOSAntiga(cRecurso, dAgenda, cCliente, cLoja, cIdArtia, cMsgErro)

Local aArea    := GetArea()
Local cQuery   := ""
Local nStatus  := 0
Local lRetorno := .T.

cMsgErro := ""

cQuery := " DELETE SZ3 "+ CRLF
cQuery += " FROM "+RetSqlName("SZ2")+" SZ2 "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("SZ3")+" SZ3 "+ CRLF
cQuery += "     ON SZ3.Z3_FILIAL = '"+xFilial("SZ3")+"' "+ CRLF
cQuery += "     AND SZ3.Z3_OS = SZ2.Z2_OS "+ CRLF
cQuery += "     AND SZ3.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     SZ2.Z2_FILIAL = '"+xFilial("SZ2")+"' "+ CRLF
cQuery += "     AND SZ2.Z2_RECURSO = '"+cRecurso+"' "+ CRLF
cQuery += "     AND SZ2.Z2_DATA = '"+DToS(dAgenda)+"' "+ CRLF
cQuery += "     AND SZ2.Z2_CLIENTE = '"+cCliente+"' "+ CRLF
cQuery += "     AND SZ2.Z2_LOJA = '"+cLoja+"' "+ CRLF
cQuery += "     AND SZ2.Z2_XIDARTI = '"+cIdArtia+"' "+ CRLF
cQuery += "     AND SZ2.Z2_ARTIA = 'S' "+ CRLF
cQuery += "     AND SZ2.D_E_L_E_T_ = ' ' "+ CRLF

nStatus := TcSqlExec(cQuery)

If (nStatus < 0)
    lRetorno := .F.
    cMsgErro := TcSqlError()
EndIf

If lRetorno
    cQuery := " DELETE "+RetSqlName("SZ2")+" "+ CRLF
    cQuery += " WHERE "+ CRLF
    cQuery += "     Z2_FILIAL = '"+xFilial("SZ2")+"' "+ CRLF
    cQuery += "     AND Z2_RECURSO = '"+cRecurso+"' "+ CRLF
    cQuery += "     AND Z2_DATA = '"+DToS(dAgenda)+"' "+ CRLF
    cQuery += "     AND Z2_CLIENTE = '"+cCliente+"' "+ CRLF
    cQuery += "     AND Z2_LOJA = '"+cLoja+"' "+ CRLF
    cQuery += "     AND Z2_XIDARTI = '"+cIdArtia+"' "+ CRLF
    cQuery += "     AND Z2_ARTIA = 'S' "+ CRLF
    cQuery += "     AND D_E_L_E_T_ = ' ' "+ CRLF

    nStatus := TcSqlExec(cQuery)

    If (nStatus < 0)
        lRetorno := .F.
        cMsgErro := TcSqlError()
    EndIf
EndIf

RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RetData
Deleta OS antigas.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetData(cDtTime)
Return SToD(StrTran(SubStr(cDtTime,1,10),"-",""))

//-------------------------------------------------------------------
/*/{Protheus.doc} RetHora
Deleta OS antigas.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetHora(cDtTime)
Return SubStr(cDtTime,12,5)

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvTime
Deleta OS antigas.

@author  Wilson A. Silva Jr
@since   28/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConvTime(nHrTot)

Local nHoras   := Int(nHrTot)
Local nMinutos := Int((nHrTot - nHoras) * 60)
Local cRetorno := StrZero(nHoras,2) + ":" + StrZero(nMinutos,2)

Return cRetorno
