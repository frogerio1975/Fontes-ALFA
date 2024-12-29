#INCLUDE "PROTHEUS.CH"
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"
#Include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFOFC01
Rotina de conexão com as API's do PS OFFICE.

Usuário: integracao
Senha: Alfa2023@@
        Alfa2024@@
@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFOFC01()

Local aBoxParam	:= {}
Local aRetParam	:= {}
Local lRetorno 	:= .T.
Local cProjeto  := CriaVar("AF8_PROJET",.F.)
Local cMsgErro  := ""
Local aGrupos   := {}
Local nAccountId:= 3430369

Local cEmpresa := ''
Local c_cr := ''
AADD( aGrupos, "Projetos SAP" )
AADD( aGrupos, "Projetos TOTVS" )

AADD( aBoxParam, {1,"Projeto"               , cProjeto  , "@!", "","AF8","",50,.T.} )
AADD( aBoxParam, {3,"Grupos de Trabalho"	, 1, aGrupos, 100,,.T.} )

If ParamBox(aBoxParam,"Integração psoffice",@aRetParam,,,,,,,,.F.)

    cProjeto := aRetParam[1]
    nOpcGrp  := aRetParam[2]

    DO CASE
        CASE nOpcGrp == 1
            cEmpresa:= 'ALFA'
            c_cr := 'AF1 (Alfa)'
        CASE nOpcGrp == 2
            cEmpresa := 'MOOVE'
            c_cr := 'MO2 (Moove)'
    ENDCASE

    dbSelectArea("AF8")
    dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
    If dbSeek(xFilial("AF8")+cProjeto)


        FwMsgRun( ,{|| lRetorno := U_OFC01INT(cProjeto, cEmpresa,c_cr, @cMsgErro,'',nOpcGrp) }, , "Por favor, aguarde. Enviando projeto ao psoffice..." )

        If lRetorno
            Help(Nil,Nil,ProcName(),,"Projeto integrado com sucesso.", 1, 5)
        Else
            Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
        EndIf

    Else
        Help(Nil,Nil,ProcName(),,"Projeto não localizado: " + cProjeto, 1, 5)
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ART01ENV
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function OFC01ENV(cProjeto, nOpcGrp, cMsgErro,cTpServ)

Local aAreaAtu   := GetArea()
Local aAreaAF8   := AF8->(GetArea())
Local aAreaAF9   := AF9->(GetArea())
Local aAreaAFC   := AFC->(GetArea())
Local nAccountId := GetNewPar("MV_XACOUNT",3430369)
Local lRetorno 	 := .T.
Local cEmpresa := ''
Local c_cr := ''

DEFAULT cProjeto := AF8->AF8_PROJET
DEFAULT nOpcGrp  := 1

    DO CASE
        CASE nOpcGrp == 1
            cEmpresa:= 'ALFA'
            c_cr := 'AF1 (Alfa)'
        CASE nOpcGrp == 2
            cEmpresa := 'MOOVE'
            c_cr := 'MO2 (Moove)'
    ENDCASE
dbSelectArea("AF8")
dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
If dbSeek(xFilial("AF8")+cProjeto)
    lRetorno := U_OFC01INT(cProjeto, cEmpresa,c_cr, @cMsgErro,cTpServ,nOpcGrp)
Else
    cMsgErro := "Projeto não localizado: " + cProjeto
EndIf

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} OFC01INT
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function OFC01INT(cProjeto,cEmpresa,c_cr, cMsgErro,cTpServ,nOpcGrp)

Local cToken     := ""
Local lRetorno   := .T.
Local nParentId  := 0
Local nClienteId := 0
Local nProjectId := 0
Local nCoordId   := 0
Local lCoord     := .F.
Local lClient    := .F.
Local lProject   := .F.
Local cQuery     := ""
Local nEstRev    := 0 //Receita Estimada do Projeto
Local nEstCost   := 0 //Custo Estimado do Projeto

Local aParambox := {}
Local aRetParam := {}
LOCAL cResp := ''
dbSelectArea("AF8")
dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
lRetorno := dbSeek(xFilial("AF8")+cProjeto)

If lRetorno
    
    CUPD:= " UPDATE AFC010 SET AFC_XIDART = '',AFC_XDTART='',AFC_XHRART='' WHERE AFC_PROJET='"+cProjeto+"' "
    TCSQLEXEC( CUPD)
    CUPD:= " UPDATE AF9010 SET AF9_XIDART = '',AF9_XDTART='',AF9_XHRART='' WHERE AF9_PROJET='"+cProjeto+"' "
    TCSQLEXEC( CUPD)

    If !U_OFC01CON(@cToken, @cMsgErro)
        Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
        Return .F.
    EndIf
    

    //Posiciona no cadastro de recurso para pegar o ID
    AE8->(dbSetOrder(1))
    AE8->(dbSeek(xFilial("AE8")+AF8->AF8_COORD))
    cgerente := LOWER(AllTrim(AE8->AE8_EMAIL))

    cResp := LOWER(AllTrim(AE8->AE8_NREDUZ)) 

    //Posiciona no cadastro de cliente 
    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA))
    nGrupoId   :=0
    nEstEffort := AF8->AF8_HORAS
    nEstCost   := AF8->AF8_CUSTO
    nEstRev    := AF8->AF8_RECEIT

    cnome:= AF8->AF8_PROJET
    ccodigo:= AF8->AF8_PROJET
    cobjetivo:=ALLTRIM(AF8->AF8_DESCRI)
    cCliente:=ALLTRIM(SA1->A1_NREDUZ)
    cnumeroProposta:=AF8->AF8_PROPOS
    lRetorno := EnvProject(cToken, @nProjectId, @cMsgErro, cnome,ccodigo,cobjetivo,cCliente,cEmpresa,cnumeroProposta,c_cr,cgerente  )


EndIf

If lRetorno
    // Envia EDT's
    lRetorno := lRetorno .And. EnvEDTs(cToken, @cMsgErro, cProjeto, Nil, nProjectId, nGrupoId , nil,cnumeroProposta+'-'+cobjetivo)

    // Envia Atividades
    lRetorno := lRetorno .And. EnvTarefas(cToken, @cMsgErro, cProjeto, nGrupoId,cResp,cnumeroProposta+'-'+cobjetivo)

EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvProject
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvProject(cToken, nProjectId, cMsgErro, cnome,ccodigo,cobjetivo,cCliente,cEmpresa,cnumeroProposta,c_cr,cgerente)

Local cURL      := GetNewPar("MV_XURLOFC","https://psofficeapp.com.br/alfaerp")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oBody     := Nil
Local cErro     := Nil
Local cQryArt   := ""
Local nX

Private oResponse := Nil

nFolderId := 0

If !U_OFC01CON(@cToken, @cMsgErro)
    Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
    Return .F.
EndIf

AADD( aHeadOut, "Content-Type: application/json" )
AADD( aHeadOut, "User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() )
AADD( aHeadOut, "Authorization: Bearer " + cToken)

oRest := FWRest():New(cURL)
oRest:nTimeOut := 600
oRest:SetPath("/")

oBody := JsonObject():New()
/*
{
    "nome": "teste190901",
    "codigo": "teste190901DA",
    "objetivo": "teste API",
    "cliente": "ETNA",
    "empresa": "MOOVE",
    "numeroProposta": "ab123",
    "cr":"AF1 (Alfa)",
    "gerente": "vitor.rodrigues@mooveconsultoria.com.br",
    "udf1": "eee",
    "nomeProjTemplate": "nome do projeto a ser copiado"
}
*/
oBody['nome']               := cnumeroProposta+'-'+cobjetivo//cnome
oBody['codigo']             := ccodigo
oBody['objetivo']           := cnumeroProposta+'-'+cobjetivo
oBody['cliente']            := cCliente
oBody['empresa']            := cEmpresa
oBody['numeroProposta']     := cnumeroProposta
oBody['cr']                 := c_cr
oBody['gerente']            := cgerente
oBody['udf1']               := ''
oBody['nomeProjTemplate']   := ccodigo+' '+cobjetivo

//oBody['variables'] := JsonObject():New()

oRest:SetPostParams(oBody:toJson())
oRest:setPath( '/api/v1/projetos/projeto' )
If oRest:Post(aHeadOut)
    _cHttpMsg:=''
    cResponse := oRest:GetResult()
    If HTTPGetStatus(@_cHttpMsg) == 200 
        If IsNumber(cResponse)
            nProjectId := Val( cResponse ) 
            lRetorno:= .t.
        Else
            cMsgErro := cResponse           
        End
    End

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvFolder
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvFolder(cToken,nFolderId,cMsgErro,cnomeProjeto,cAtvPai,cNomeAtv,cPrecedentes,cduracao,cdtInicio,cdtFim,cNPrj)



Local cURL      := GetNewPar("MV_XURLOFC","https://psofficeapp.com.br/alfaerp")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oResponse := Nil
Local oBody     := Nil

nFolderId := 0

If !U_OFC01CON(@cToken, @cMsgErro)
    Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
    Return .F.
EndIf

AADD( aHeadOut, "Content-Type: application/json" )
//AADD( aHeadOut, "User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() )
AADD( aHeadOut, "Authorization: Bearer " + cToken)

oRest := FWRest():New(cURL)
oRest:nTimeOut := 600
//oRest:SetPath("/")
oBody := JsonObject():New()

/*
{
    "nomeProjeto": "teste190901",
    "nomeAtividaePai": "teste teste api3", //fase
    "nomeAtividade": "teste atividade", // atividade
    "nomesAtividadesPrecedentes": "",
    "duracao": "60",
    "dtInicio": "01/10/2023",
    "dtFim":"01/10/2023",
    "recursos": "Apoio",
    "udf1": "eee"
}
*/
oBody['nomeProjeto']                := cNPrj//cnomeProjeto
oBody['nomeAtividaePai']            := cAtvPai
oBody['nomeAtividade']              := cNomeAtv
oBody['nomesAtividadesPrecedentes'] := cPrecedentes
oBody['duracao']                    := cduracao
oBody['dtInicio']                   := cdtInicio
oBody['dtFim']                      := cdtFim
oBody['recursos']                   := 'Consultor(a)'
oBody['udf1']                       := ''

cjson := EncodeUTF8(oBody:ToJSON() )

oRest:SetPostParams( cjson )
oRest:setPath( '/api/v1/atividades/atividade' )
_cHeadRet:=''
//_cPostRet := HttpPost( cURL+"/api/v1/atividades/atividade", '', oBody:toJson(), 120, aHeadOut, @_cHeadRet)
If oRest:Post(aHeadOut)
    _cHttpMsg:=''
    cResponse := oRest:GetResult()
    If HTTPGetStatus(@_cHttpMsg) == 200 
        If IsNumber(cResponse)
            nFolderId := Val( cResponse ) 
            lRetorno:= .t.
        Else
            cMsgErro := cResponse            
        End
    End

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvEDTs
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvEDTs(cToken, cMsgErro, cProjeto, cEDTPai, nParentId, nGrupoId,cNomePai,cNPrj)

Local cTMP1     := ""
Local cQuery    := ""
Local lRetorno  := .T.
Local nFolderId := 0
Local cName     := ""
Local dEstStart := SToD("")
Local dEstEnd   := SToD("")
Local nEstCost  := 0
Local nEstEffort:= 0

DEFAULT cEDTPai := CriaVar("AFC_EDTPAI",.F.)
Default cNomePai:= ''
cQuery := " SELECT "+ CRLF
cQuery += " 	AFC_EDT "+ CRLF
cQuery += " 	,AFC_EDTPAI "+ CRLF
cQuery += " 	,AFC_NIVEL "+ CRLF
cQuery += " 	,AFC_DESCRI "+ CRLF
cQuery += " 	,AFC_HDURAC "+ CRLF
cQuery += " 	,AFC_START "+ CRLF
cQuery += " 	,AFC_FINISH "+ CRLF
cQuery += " 	,AFC_HUTEIS "+ CRLF
cQuery += " 	,AFC_XIDART "+ CRLF
cQuery += "     ,AFC.R_E_C_N_O_ AS NUMREG "+ CRLF
cQuery += "     ,AFC.AFC_CUSTO  "+ CRLF
cQuery += "     ,AFC.AFC_TOTAL  "+ CRLF
cQuery += " FROM "+RetSqlName("AFC")+" AFC (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     AFC_FILIAL = '"+xFilial("AFC")+"' "+ CRLF
cQuery += "     AND AFC_PROJET = '"+cProjeto+"' "+ CRLF
If !Empty(cEDTPai)
    cQuery += "     AND AFC_EDTPAI = '"+cEDTPai+"' "+ CRLF
Else
    cQuery += "     AND AFC_NIVEL IN('001') "+ CRLF    //cQuery += "     AND AFC_NIVEL IN('001','002') "+ CRLF    
EndIf
cQuery += "     AND AFC.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	AFC_EDT "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    If Empty((cTMP1)->AFC_XIDART)        
        cName := Upper(AllTrim((cTMP1)->AFC_DESCRI))
        cNomePai:= Iif( empty(cNomePai), cName, cNomePai)
        dEstStart := dtoc(SToD((cTMP1)->AFC_START))
        dEstEnd   := dtoc(SToD((cTMP1)->AFC_FINISH))
        nEstCost  := (cTMP1)->AFC_CUSTO
        nEstEffort:= (cTMP1)->AFC_HUTEIS
        nEstRev   := (cTMP1)->AFC_TOTAL
        
        lRetorno := EnvFolder(cToken, @nFolderId, @cMsgErro, cProjeto,cNomePai,cName,'',alltrim(str(nEstEffort)),dEstStart,dEstEnd,cNPrj)
        
        If lRetorno
            AFC->(dbGoTo((cTMP1)->NUMREG))
            RecLock("AFC",.F.)
                REPLACE AFC_XIDART WITH alltrim(str(nFolderId))//StrZero(nFolderId,10)
                REPLACE AFC_XDTART WITH DATE()
                REPLACE AFC_XHRART WITH TIME()
            MsUnLock()
        EndIf
    Else
        nFolderId := Val((cTMP1)->AFC_XIDART)
        lRetorno  := .T.
    EndIf
    
    If lRetorno
        cEDTPai  := (cTMP1)->AFC_EDT
        cNomePai := Upper(AllTrim((cTMP1)->AFC_DESCRI))
        lRetorno := EnvEDTs(cToken, @cMsgErro, cProjeto, cEDTPai, nFolderId, nGrupoId,cNomePai,cNPrj)
    EndIf

    If !lRetorno
        EXIT
    EndIf

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvActivity
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvTarefas(cToken, cMsgErro, cProjeto, nGrupoId,cResp,cNPrj)

Local cTMP1     := ""
Local cQuery    := ""
Local lRetorno  := .T.
Local cName     := ""
Local dEstStart := DATE()
Local dEstEnd   := DATE()
Local nActiId   := 0
Local nEstCost  := 0

cQuery := " SELECT "+ CRLF
cQuery += " 	AF9_TAREFA "+ CRLF
cQuery += " 	,AF9_NIVEL "+ CRLF
cQuery += " 	,AF9_DESCRI "+ CRLF
cQuery += " 	,AF9_HDURAC "+ CRLF
cQuery += " 	,AF9_START "+ CRLF
cQuery += " 	,AF9_FINISH "+ CRLF
cQuery += " 	,AF9_HUTEIS "+ CRLF
cQuery += " 	,AF9_EDTPAI "+ CRLF
cQuery += " 	,AF9_STATUS "+ CRLF
cQuery += " 	,AF9_XIDART "+ CRLF
cQuery += "     ,AF9.R_E_C_N_O_ AS NUMREG "+ CRLF
cQuery += "     ,AFC_XIDART "+ CRLF
cQuery += "     ,AFC_DESCRI "+ CRLF
cQuery += "     ,AF9_CUSTO "+ CRLF
cQuery += " FROM "+RetSqlName("AF9")+" AF9 (NOLOCK) "+ CRLF
cQuery += " INNER JOIN "+RetSqlName("AFC")+" AFC (NOLOCK) "+ CRLF
cQuery += "     ON AFC_FILIAL = AF9_FILIAL "+ CRLF
cQuery += "     AND AFC_EDT = AF9_EDTPAI "+ CRLF
cQuery += "     AND AFC_PROJET = AF9_PROJET "+ CRLF
cQuery += " 	AND AFC_XIDART <> ' ' "+ CRLF
cQuery += "     AND AFC.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     AF9_FILIAL = '"+xFilial("AF9")+"' "+ CRLF
cQuery += "     AND AF9_PROJET = '"+cProjeto+"' "+ CRLF
cQuery += " 	AND AF9_XIDART = ' ' "+ CRLF
cQuery += " 	AND AF9_DESCRI <> ' ' "+ CRLF
cQuery += "     AND AF9.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	AF9_TAREFA "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    cName      := Upper(AllTrim((cTMP1)->AF9_DESCRI)) //SubStr(AllTrim((cTMP1)->AF9_TAREFA),-2) + "-" + AllTrim((cTMP1)->AF9_DESCRI)
    dEstStart  := SToD((cTMP1)->AF9_START)
    dEstEnd    := SToD((cTMP1)->AF9_FINISH)
    nEstEffort := (cTMP1)->AF9_HDURAC
    nEstCost   := (cTMP1)->AF9_CUSTO
    nFolderId  := Val((cTMP1)->AFC_XIDART)
    
    cNomePai :=  Upper(AllTrim((cTMP1)->AFC_DESCRI))

    dEstStart += 1
    dEstEnd   += 1
    
    dEstStart  := dtoc( dEstStart )
    dEstEnd    := dtoc( dEstEnd )

    //lRetorno := EnvActivity(cToken, @nActiId, @cMsgErro, cName, nFolderId, nGrupoId, dEstStart, dEstEnd, nEstEffort, nEstCost)
    lRetorno := EnvPenden(cToken, @nFolderId, @cMsgErro, cProjeto,cNomePai,cName,'',alltrim(str(nEstEffort)),dEstStart,dEstEnd,cResp,cNPrj,@nActiId)

    If lRetorno
        AF9->(dbGoTo((cTMP1)->NUMREG))
        RecLock("AF9",.F.)
            REPLACE AF9_XIDART WITH alltrim(str(nActiId))//StrZero(nActiId,10)
            REPLACE AF9_XDTART WITH DATE()
            REPLACE AF9_XHRART WITH TIME()
        MsUnLock()
    EndIf

    If !lRetorno
        EXIT
    EndIf

    (cTMP1)->(dbSkip())
EndDo

(cTMP1)->(dbCloseArea())

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFOFC01
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
User Function OFC01CON(cToken, cMsgErro)

Local cXToken      := GetNewPar("MV_XTOKOFC","d650efe9861fbe723d43b649a4f8a897")
Local lRetorno  := .t.

cToken := cXToken
        
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatDt
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FormatDt(dData)
Return Transform(DToS(dData),"@R 9999-99-99")


//-------------------------------------------------------------------
/*/{???????Protheus.doc}??????? IsNumber

Valida se é Numerico.

@author Pedro Oliveira
@since 09/03/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function IsNumber(cTexto)

	Local nL := 0

	cTexto := ALLTRIM(cTexto)
	
	For nL := 1 To Len(cTexto)
		If !IsDigit(SUBSTR(cTexto, nL, 1))
			Return .F.
		EndIf
	Next

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} EnvFolder
Rotina de conexão com as API's do psoffice.

@author  Pedro H. Oliveira
@since   19/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvPenden(cToken,nFolderId,cMsgErro,cnomeProjeto,cAtvPai,cNomeAtv,cPrecedentes,cduracao,cdtInicio,cdtFim,cResp,cNPrj,nActiId)



Local cURL      := GetNewPar("MV_XURLOFC","https://psofficeapp.com.br/alfaerp")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oResponse := Nil
Local oBody     := Nil

//nFolderId := 0

If !U_OFC01CON(@cToken, @cMsgErro)
    Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
    Return .F.
EndIf

AADD( aHeadOut, "Content-Type: application/json" )
AADD( aHeadOut, "User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() )
AADD( aHeadOut, "Authorization: Bearer " + cToken)

oRest := FWRest():New(cURL)
oRest:nTimeOut := 600
//oRest:SetPath("/")
oBody := JsonObject():New()

/*
{
    "projeto": "0000004771",
    "assunto": "teste API",
    "descricao": "ACME",
    "tipo": "melhoria",
    "prioridade": "grave",
    "dataPrevista":"01/11/2023",
    "responsavel": "vitor rodrigues"
}
*/
oBody['projeto']     := cNPrj//cnomeProjeto
oBody['assunto']     := cNomeAtv
oBody['descricao']   := cNomeAtv
oBody['tipo']        := "Atividade"//"Escopo"
oBody['prioridade']  := "Impeditiva"
oBody['dataPrevista']:= cdtFim
//oBody['responsavel'] := cResp

oBody['ativId'] := alltrim(str(nFolderId))

cjson := EncodeUTF8(oBody:ToJSON() )
oRest:SetPostParams( cjson )
oRest:setPath( '/api/v1/pendencias/pendencia' )


If oRest:Post(aHeadOut)
    _cHttpMsg:=''
    cResponse := oRest:GetResult()
    If HTTPGetStatus(@_cHttpMsg) == 200 
        If IsNumber(cResponse)
            //nFolderId := Val( cResponse ) 
            nActiId :=  Val( cResponse ) 
            lRetorno:= .t.
        Else
            cMsgErro := cResponse            
        End
    End

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno
