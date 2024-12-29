#INCLUDE "PROTHEUS.CH"
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"
#Include "TopConn.ch"

#DEFINE GRUPO_SAP_DELIVERY   3430369
#DEFINE GRUPO_SAP_FABRICA    3449650
#DEFINE GRUPO_TOTVS_DELIVERY 3449656
#DEFINE GRUPO_TOTVS_FABRICA  3449629

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFART01
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFART01()

Local aBoxParam	:= {}
Local aRetParam	:= {}
Local lRetorno 	:= .T.
Local cProjeto  := CriaVar("AF8_PROJET",.F.)
Local cMsgErro  := ""
Local aGrupos   := {}
Local nAccountId:= 3430369

AADD( aGrupos, "Projetos SAP" )
AADD( aGrupos, "Projetos TOTVS" )

AADD( aBoxParam, {1,"Projeto"               , cProjeto  , "@!", "","AF8","",50,.T.} )
AADD( aBoxParam, {3,"Grupos de Trabalho"	, 1, aGrupos, 100,,.T.} )

If ParamBox(aBoxParam,"Integração ARTIA",@aRetParam,,,,,,,,.F.)

    cProjeto := aRetParam[1]
    nOpcGrp  := aRetParam[2]

    DO CASE
        CASE nOpcGrp == 1
            nGrupoId  := GRUPO_SAP_DELIVERY
            nAccountId:= GRUPO_SAP_DELIVERY
        CASE nOpcGrp == 2
            nGrupoId  := GRUPO_TOTVS_DELIVERY
            nAccountId:= GRUPO_TOTVS_DELIVERY
    ENDCASE

    dbSelectArea("AF8")
    dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
    If dbSeek(xFilial("AF8")+cProjeto)

        // If !Empty(AF8->AF8_XIDART)
        //     Help(Nil,Nil,ProcName(),,"Projeto já foi integrado anteriormente.", 1, 5)
        // Else
            FwMsgRun( ,{|| lRetorno := U_ART01INT(cProjeto, nGrupoId, nAccountId, @cMsgErro,'',nOpcGrp) }, , "Por favor, aguarde. Enviando projeto ao ARTIA..." )

            If lRetorno
                Help(Nil,Nil,ProcName(),,"Projeto integrado com sucesso.", 1, 5)
            Else
                Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
            EndIf
        // EndIf
    Else
        Help(Nil,Nil,ProcName(),,"Projeto não localizado: " + cProjeto, 1, 5)
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ART01ENV
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   19/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ART01ENV(cProjeto, nOpcGrp, cMsgErro,cTpServ)

Local aAreaAtu   := GetArea()
Local aAreaAF8   := AF8->(GetArea())
Local aAreaAF9   := AF9->(GetArea())
Local aAreaAFC   := AFC->(GetArea())
Local nAccountId := GetNewPar("MV_XACOUNT",3430369)
Local lRetorno 	 := .T.

DEFAULT cProjeto := AF8->AF8_PROJET
DEFAULT nOpcGrp  := 1

DO CASE
    CASE nOpcGrp == 1
        nGrupoId  := GRUPO_SAP_DELIVERY
        nAccountId:= GRUPO_SAP_DELIVERY
    CASE nOpcGrp == 2
        nGrupoId  := GRUPO_TOTVS_DELIVERY
        nAccountId:= GRUPO_TOTVS_DELIVERY
ENDCASE

dbSelectArea("AF8")
dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
If dbSeek(xFilial("AF8")+cProjeto)
    lRetorno := U_ART01INT(cProjeto, nGrupoId, nAccountId, @cMsgErro,cTpServ,nOpcGrp)
Else
    cMsgErro := "Projeto não localizado: " + cProjeto
EndIf

RestArea(aAreaAFC)
RestArea(aAreaAF9)
RestArea(aAreaAF8)
RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ART01INT
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ART01INT(cProjeto,nGrupoId, nAccountId, cMsgErro,cTpServ,nOpcGrp)

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

dbSelectArea("AF8")
dbSetOrder(1) // AF8_FILIAL+AF8_PROJET
lRetorno := dbSeek(xFilial("AF8")+cProjeto)

If lRetorno

    If !U_ART01CON(@cToken, @cMsgErro)
        Help(Nil,Nil,ProcName(),,cMsgErro, 1, 5)
        Return .F.
    EndIf

    //Posiciona no cadastro de recurso para pegar o ID
    AE8->(dbSetOrder(1))
    AE8->(dbSeek(xFilial("AE8")+AF8->AF8_COORD))

    //Posiciona no cadastro de cliente 
    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA))

    //Posiciona no cadastro de cliente X GP
    dbSelectArea("Z23")
    dbSetOrder(1)
    If dbSeek(xFilial("Z23")+AF8->AF8_CLIENT+AF8->AF8_LOJA+AE8->AE8_RECURS)
        nCoordId  := Val(Z23->Z23_ARTREC)
        nClienteId:= Val(Z23->Z23_ARTCLI)
    Else     
        DO CASE
            CASE nOpcGrp == 1
                nCoordId  := Val(AE8->AE8_XIDART)
            CASE nOpcGrp == 2
                nCoordId  := Val(AE8->AE8_XIDAR2)
        ENDCASE

        //Cria o registro
        RecLock("Z23",.T.)
        Replace Z23_FILIAL With xFilial("Z23")
        Replace Z23_CLIENT With AF8->AF8_CLIENT+AF8->AF8_LOJA
        Replace Z23_COORD  With AF8->AF8_COORD
        MsUnlock()

    EndIf

    //Verifica se ja existe a amarracao Grupo/Coordenador/Cliente/Projeto
    dbSelectArea("Z22")
    dbSetOrder(1)
    If dbSeek(xFilial("Z22")+cValToChar(nGrupoID)+AF8->AF8_COORD+AF8->AF8_CLIENT+AF8->AF8_LOJA+AF8->AF8_PROJET)
        If !Empty(Z22->Z22_ARTREC)
            nCoordId  := Val(Z22->Z22_ARTREC)
            lCoord:= .T.
        EndIf

        If !Empty(Z22->Z22_ARTCLI)    
            nClienteId:= Val(Z22->Z22_ARTCLI)
            lClient:= .T.
        EndIf

        If !Empty(Z22->Z22_ARTPRJ)    
            nProjectId:= Val(Z22->Z22_ARTPRJ)
            lProject:= .T.
        EndIf    
    Else
        //Cria o registro
        RecLock("Z22",.T.)
        Replace Z22_FILIAL With xFilial("Z22")
        Replace Z22_GRUPO  With cValToChar(nGrupoID)
        Replace Z22_COORD  With AF8->AF8_COORD
        Replace Z22_CLIENT With AF8->AF8_CLIENT + AF8->AF8_LOJA
        Replace Z22_PROJET With AF8->AF8_PROJET

        If (nCoordId > 0)
            Replace Z22_ARTREC With StrZero(nCoordId,10)
            lCoord:= .T.
        EndIf

        If (nClienteId > 0)
            Replace Z22_ARTCLI With StrZero(nClienteId,10)
            lClient:= .T.
        EndIf

        MsUnLock()
    EndIf 

    If !lCoord
        //Criar Folder para o GP
        dbSelectArea("AE8")
        dbSetOrder(1) // AE8_FILIAL+AE8_RECURS
        If dbSeek(xFilial("AE8")+AF8->AF8_COORD) .And. Empty(AE8->AE8_XIDART)
            cName := Upper(AllTrim(AE8->AE8_DESCRI))
            nParentId := nAccountId

            lRetorno := EnvFolder(cToken, @nCoordId, @cMsgErro, cName, nParentId, nGrupoId, Nil, Nil,0,0,0)
            If lRetorno
                RecLock("AE8",.F.)
                
                DO CASE
                    CASE nOpcGrp == 1
                        REPLACE AE8_XIDART WITH StrZero(nCoordId,10)
                    CASE nOpcGrp == 2
                        REPLACE AE8_XIDAR2 WITH StrZero(nCoordId,10)
                ENDCASE

                REPLACE AE8_XDTART WITH DATE()
                REPLACE AE8_XHRART WITH TIME()
                MsUnLock()
            EndIf

            nCoordId:= Val(AE8->AE8_XIDART)
            RecLock("Z22",.F.)
            Replace Z22_ARTREC With StrZero(nCoordId,10)
            MsUnLock()

            RecLock("Z23",.F.)
            Replace Z23_ARTREC With StrZero(nCoordId,10)
            MsUnLock()
        EndIf
    EndIf
    
    //Cria uma pasta para o cliente
    If lRetorno .And. !lClient
        dbSelectArea("SA1")
        dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
        If dbSeek(xFilial("SA1")+AF8->AF8_CLIENT+AF8->AF8_LOJA)
            cName := Upper(SubStr(SA1->A1_COD,-4) + "-" + AllTrim(SA1->A1_NREDUZ))
            nParentId := nCoordId

            lRetorno := EnvFolder(cToken, @nClienteId, @cMsgErro, cName, nParentId, nGrupoId, Nil, Nil,0,0,0)
            If lRetorno
                RecLock("SA1",.F.)
    
                DO CASE
                    CASE nOpcGrp == 1
                        REPLACE A1_XIDART  WITH StrZero(nClienteId,10)
                    CASE nOpcGrp == 2
                        REPLACE A1_XIDART2 WITH StrZero(nClienteId,10)
                ENDCASE

                REPLACE A1_XDTART WITH DATE()
                REPLACE A1_XHRART WITH TIME()
                MsUnLock()

                RecLock("Z22",.F.)
                Replace Z22_ARTCLI With StrZero(nClienteId,10)
                MsUnLock()

                RecLock("Z23",.F.)
                Replace Z23_ARTCLI With StrZero(nClienteId,10)
                MsUnLock()
            EndIf
        EndIf
    EndIf
        
    If lRetorno .And. !lProject
        If Empty(AF8->AF8_XIDART)
            cName      := Upper(SubStr(AF8->AF8_PROPOS,-4) + "-" + AllTrim(AF8->AF8_DESCRI))
            nParentId  := nClienteId
            nEstEffort := AF8->AF8_HORAS
            nEstCost   := AF8->AF8_CUSTO
            nEstRev    := AF8->AF8_RECEIT

            lRetorno := EnvProject(cToken, @nProjectId, @cMsgErro, cName, nParentId, nGrupoId, Nil, Nil, nEstEffort, AF8->AF8_PROJET,nEstCost,nEstRev)
            If lRetorno
                RecLock("AF8",.F.)
                REPLACE AF8_XIDART WITH StrZero(nProjectId,10)
                REPLACE AF8_XDTART WITH DATE()
                REPLACE AF8_XHRART WITH TIME()
                MsUnLock()

                RecLock("Z22",.F.)
                Replace Z22_ARTPRJ With StrZero(nProjectId,10)
                MsUnLock()
            EndIf
        EndIf
    EndIf
EndIf

// Envia EDT's
lRetorno := lRetorno .And. EnvEDTs(cToken, @cMsgErro, cProjeto, Nil, nProjectId, nGrupoId)

// Envia Atividades
lRetorno := lRetorno .And. EnvTarefas(cToken, @cMsgErro, cProjeto, nGrupoId)

If !lRetorno
    If MsgYesNo('O id do GP/Coodernador no PMS é : '+ALLTRIM(STR(VAL(Z22->Z22_ARTREC)))+CRLF+;
                'O id do Cliente no PMS é : '+ALLTRIM(STR(VAL(Z22->Z22_ARTCLI)))+CRLF+;
                'Deseja altera ?','Atenção')

        aAdd(aParamBox,{9,"ID GP/Coodernador: "+ALLTRIM(STR(VAL(Z22->Z22_ARTREC))) ,150,7,.T.})
        aAdd(aParamBox,{9,"ID Cliente :"+ALLTRIM(STR(VAL(Z22->Z22_ARTCLI))),150,7,.T.})
        AADD(aParamBox,{1,"Novo ID GP/Coodernador?" ,Space(TAMSX3('Z22_ARTREC')[1]),"@!","","","",100,.F.})
        AADD(aParamBox,{1,"Novo ID Cliente ?",Space(TAMSX3('Z22_ARTCLI')[1]),"@!","","","",100,.F.})
        If ParamBox(aParamBox,"ID ARTIA...",@aRetParam)
            Z22->(RecLock("Z22",.F.))
                Z22->Z22_ARTREC := StrZero(VAL( Alltrim(aRetParam[3]) ),10)
                Z22->Z22_ARTCLI := iIF( EMPTY(aRetParam[4]),'', StrZero(VAL( Alltrim(aRetParam[4]) ),10)   ) 
            Z22->(MsUnLock())

           MsgInfo('Alterado com sucesso! Realizar a integração novamente.') 
        EndIf        
    EndIf
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvProject
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvProject(cToken, nProjectId, cMsgErro, cName, nParentId, nGrupoId, dEstStart, dEstEnd, nEstEffort, cProjERP, nEstCost, nEstRev)

Local cURL      := GetNewPar("MV_XURLART","https://app.artia.com/graphql")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oBody     := Nil
Local cErro     := Nil
Local cQryArt   := ""
Local nX

Private oResponse := Nil

nFolderId := 0

If !U_ART01CON(@cToken, @cMsgErro)
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

cQryArt := ' mutation{'
cQryArt += '     createProject('
cQryArt += '         name: "'+EncodeUtf8(cName)+'",' // # OBRIGATÓRIO
cQryArt += '         parentId: '+cValToChar(nParentId)+',' // # OBRIGATÓRIO - ID do pai (projeto, pasta ou grupo de trabalho)
cQryArt += '         accountId: '+cValToChar(nGrupoId)+',' // # OBRIGATÓRIO - ID do grupo de trabalho
//cQryArt += '         accountId: '+cValToChar(nAccountId)+',' // # OBRIGATÓRIO - ID do grupo de trabalho
//cQryArt += '         createdForUser: true,' // # Criado por usuário
//cQryArt += '         skipNotification: 0,' // # Deixar de notificar as alterações
//cQryArt += '         templateId: 4,' // # ID do modelo
//cQryArt += '         categoryText: "Categoria",' // # Categirua
//cQryArt += '         templateKeepParticipant: 0,' // # Manter os usuários associados no projeto ao criar modelo (0/1)
//cQryArt += '           folderTypeId: 0,' // # ID do tipo de projeto
//cQryArt += '         priority: 0,' // # Prioridade
//cQryArt += '         #customerId: 0,' // # ID de cliente
//cQryArt += '         justification: "",'
If !Empty(dEstStart)
    cQryArt += '         estimatedStart: "'+FormatDt(dEstStart)+'",' // # Inicio Estimado
EndIf
If !Empty(dEstEnd)
    cQryArt += '         estimatedEnd: "'+FormatDt(dEstEnd)+'",' // # Término Estimado
EndIf
//cQryArt += '         premise: "",'
//cQryArt += '         actualStart: "",' // # Inicio Real
//cQryArt += '         actualEnd: "",' // # Término Real
//cQryArt += '         restriction: "",'
//cQryArt += '         description: "'+EncodeUtf8(cName)+'",'
cQryArt += '         projectNumber: '+cValToChar(Val(cProjERP))+',' // # Número do projeto
//cQryArt += '         lastInformations: "",'
cQryArt += '         estimatedEffort: '+cValToChar(nEstEffort)+',' // # Esforço Estimado
//cQryArt += '         completedPercent: 0.0,' // # Percentual Completo
//cQryArt += '         actualCost: 0.0,' // # Custo Atual
cQryArt += '         estimatedCost: '+cValToChar(nEstCost)+','  // # Custo Estimado
//cQryArt += '         actualRevenue: 0.0,' // # Receita Atual
cQryArt += '         estimatedRevenue:'+cValToChar(nEstRev)+',' // # Receita Estimada
//cQryArt += '         actualIncome: 0.0,' // # Margem Real
//cQryArt += '         estimatedIncome: 0.0,' // # Margem Estimada
cQryArt += '         ) {'
cQryArt += '         id,'
cQryArt += '         accountId,'
cQryArt += '         status,'
cQryArt += '         name'
cQryArt += '     }'
cQryArt += ' }'

oBody['query']     := cQryArt
oBody['variables'] := JsonObject():New()

oRest:SetPostParams(oBody:toJson())

If oRest:Post(aHeadOut)

    cResponse := oRest:GetResult()

    oResponse := JsonObject():New()
    cErro := oResponse:FromJson(cResponse)

    If ValType(cErro) == "C"
        cMsgErro := "Falha ao popular JsonObject. Erro: " + cErro
    Else
        If oResponse['data'] <> Nil
            nProjectId := Val(oResponse['data']['createProject']['id'])
            lRetorno   := nProjectId > 0
        Else
            For nX := 1 To Len(oResponse['errors'])
                cMsgErro += oResponse['errors'][nX]['message'] + CRLF
            Next nX
        EndIf
    EndIf

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvFolder
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvFolder(cToken, nFolderId, cMsgErro, cName, nParentId, nGrupoId, dEstStart, dEstEnd, nEstCost,nEstEffort,nEstRev)

Local cURL      := GetNewPar("MV_XURLART","https://app.artia.com/graphql")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oResponse := Nil
Local oBody     := Nil
Local cErro     := Nil
Local cQryArt   := ""
Local nX

nFolderId := 0

If !U_ART01CON(@cToken, @cMsgErro)
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

cQryArt := ' mutation{'
cQryArt += '     createFolder('
cQryArt += '         name: "'+EncodeUtf8(cName)+'",' // # OBRIGATÓRIO
cQryArt += '         parentId: '+cValToChar(nParentId)+',' // # OBRIGATÓRIO - ID do pai (pasta, projeto ou grupo de trabalho)
cQryArt += '         accountId: '+cValToChar(nGrupoId)+',' // # OBRIGATÓRIO - ID do grupo de trabalho
//cQryArt += '         folderTypeId: 1,' // # ID do folder type de pasta
If !Empty(dEstStart)
    cQryArt += '         estimatedStart: "'+FormatDt(dEstStart)+'",' // # Inicio Estimado
EndIf
If !Empty(dEstEnd)
    cQryArt += '         estimatedEnd: "'+FormatDt(dEstEnd)+'",' // # Término Estimado
EndIf
//cQryArt += '         actualStart: "2020-05-05",' // # Inicio Real
//cQryArt += '         actualEnd: "2020-05-05",' // # Término Real
cQryArt += '         estimatedEffort: '+cValToChar(nEstEffort)+',' // # Esforço Estimado
//cQryArt += '         completedPercent: 89.9,' // # Percentual Completo
cQryArt += '         estimatedRevenue: '+cValToChar(nEstRev)+',' // # Receita Estimada
//cQryArt += '         actualRevenue: 1800,' // # Receita Real
cQryArt += '         estimatedCost: '+cValToChar(nEstCost * -1)+',' // # Gasto Estimado -> valor negativo por ser gasto
//cQryArt += '         actualCost: -900' //# Gasto Real -> valor negativo por ser gasto
cQryArt += '         ) {'
cQryArt += '         id,'
cQryArt += '         name,'
cQryArt += '         accountId'
cQryArt += '     }'
cQryArt += ' }'

oBody['query']     := cQryArt
oBody['variables'] := JsonObject():New()

oRest:SetPostParams(oBody:toJson())

If oRest:Post(aHeadOut)

    cResponse := oRest:GetResult()

    oResponse := JsonObject():New()
    cErro := oResponse:FromJson(cResponse)

    If ValType(cErro) == "C"
        cMsgErro := "Falha ao popular JsonObject. Erro: " + cErro
    Else
        If oResponse['data'] <> Nil
            nFolderId := Val(oResponse['data']['createFolder']['id'])
            lRetorno  := nFolderId > 0
        Else
            For nX := 1 To Len(oResponse['errors'])
                cMsgErro += oResponse['errors'][nX]['message'] + CRLF
            Next nX
        EndIf
    EndIf

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvEDTs
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvEDTs(cToken, cMsgErro, cProjeto, cEDTPai, nParentId, nGrupoId)

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
    cQuery += "     AND AFC_NIVEL = '002' "+ CRLF    
EndIf
cQuery += "     AND AFC.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY "+ CRLF
cQuery += " 	AFC_EDT "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

While (cTMP1)->(!EOF())

    If Empty((cTMP1)->AFC_XIDART)
        cName := Upper(AllTrim((cTMP1)->AFC_DESCRI))
        dEstStart := SToD((cTMP1)->AFC_START)
        dEstEnd   := SToD((cTMP1)->AFC_FINISH)
        nEstCost  := (cTMP1)->AFC_CUSTO
        nEstEffort:= (cTMP1)->AFC_HUTEIS
        nEstRev   := (cTMP1)->AFC_TOTAL
        
        lRetorno := EnvFolder(cToken, @nFolderId, @cMsgErro, cName, nParentId, nGrupoId, dEstStart, dEstEnd, nEstCost,nEstEffort,nEstRev)
        If lRetorno
            AFC->(dbGoTo((cTMP1)->NUMREG))
            RecLock("AFC",.F.)
                REPLACE AFC_XIDART WITH StrZero(nFolderId,10)
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
        lRetorno := EnvEDTs(cToken, @cMsgErro, cProjeto, cEDTPai, nFolderId, nGrupoId)
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
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvActivity(cToken, nActiId, cMsgErro, cName, nFolderId, nGrupoId, dEstStart, dEstEnd, nEstEffort, nEstCost)

Local cURL      := GetNewPar("MV_XURLART","https://app.artia.com/graphql")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oResponse := Nil
Local oBody     := Nil
Local cErro     := Nil
Local cQryArt   := ""
Local nX

If !U_ART01CON(@cToken, @cMsgErro)
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

cQryArt := ' mutation{'
cQryArt += '     createActivity('
cQryArt += '         title: "'+EncodeUtf8(cName)+'",' // # OBRIGATÓRIO
cQryArt += '         accountId: '+cValToChar(nGrupoId)+',' // # OBRIGATÓRIO - ID do grupo de trabalho
cQryArt += '         folderId: '+cValToChar(nFolderId)+',' // # OBRIGATÓRIO - ID da pasta ou do projeto 
//cQryArt += '         description: "'+EncodeUtf8(cName)+'",'
// cQryArt += '         folderTypeId: 1,' // # ID do Tipo de Atividade
// cQryArt += '         responsibleId: 1,' // # ID do usuário responsável pela atividade
If !Empty(dEstStart)
    cQryArt += '         estimatedStart: "'+FormatDt(dEstStart)+'",' // # Inicio Estimado
EndIf
If !Empty(dEstEnd)
    cQryArt += '         estimatedEnd: "'+FormatDt(dEstEnd)+'",' // # Término Estimado
EndIf
// cQryArt += '         actualStart: "2020-08-26",' // # Início Real
// cQryArt += '         actualEnd: "",' // # Término Real
cQryArt += '         estimatedEffort: '+cValToChar(nEstEffort)+',' // # Esforço Estimado
// cQryArt += '         categoryText: "Categoria da Atividade",'
// cQryArt += '         priority: 100,' // # Prioridade
// cQryArt += '         timeEstimatedStart: "08:00",' // # Hora de Início Estimado
// cQryArt += '         timeEstimatedEnd: "18:00",' // # Hora de Término Estimado
// cQryArt += '         timeActualStart: "08:30",' // # Hora de Início Real
// cQryArt += '         timeActualEnd: "",' // # Hora de Término Real
// cQryArt += '         completedPercent: 80.15,' // # Percentual Completo
cQryArt += '     ) {'
cQryArt += '         id,'
cQryArt += '         uid,'
cQryArt += '         communityId,'
cQryArt += '         status,'
cQryArt += '         folderTypeName,'
cQryArt += '         title,'
cQryArt += '         description,'
cQryArt += '     }'
cQryArt += ' }'

oBody['query']     := cQryArt
oBody['variables'] := JsonObject():New()

oRest:SetPostParams(oBody:toJson())

If oRest:Post(aHeadOut)

    cResponse := oRest:GetResult()

    oResponse := JsonObject():New()
    cErro := oResponse:FromJson(cResponse)

    If ValType(cErro) == "C"
        cMsgErro := "Falha ao popular JsonObject. Erro: " + cErro
    Else
        If oResponse['data'] <> Nil
            nActiId   := Val(oResponse['data']['createActivity']['id'])
            lRetorno  := nActiId > 0
        Else
            For nX := 1 To Len(oResponse['errors'])
                cMsgErro += oResponse['errors'][nX]['message'] + CRLF
            Next nX
        EndIf
    EndIf

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvActivity
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnvTarefas(cToken, cMsgErro, cProjeto, nGrupoId)

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

    dEstStart += 1
    dEstEnd   += 1
    
    lRetorno := EnvActivity(cToken, @nActiId, @cMsgErro, cName, nFolderId, nGrupoId, dEstStart, dEstEnd, nEstEffort, nEstCost)
    If lRetorno
        AF9->(dbGoTo((cTMP1)->NUMREG))
        RecLock("AF9",.F.)
            REPLACE AF9_XIDART WITH StrZero(nActiId,10)
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
/*/{Protheus.doc} ALFART01
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ART01CON(cToken, cMsgErro)

Local cURL      := GetNewPar("MV_XURLART","https://app.artia.com/graphql")
Local cClientId := GetNewPar("MV_XCLIART","d6473f239eda288f6d50f19904d0202ce07bc8fd1900876fc9d14c087c633315")
Local cSecret   := GetNewPar("MV_XKEYART","26124380a91071caa8c5cd0b3f3e261b9057cf948673d5007508403eaa8091b3")
Local lRetorno  := .F.
Local aHeadOut  := {}
Local cResponse := ""
Local oResponse := Nil
Local oBody     := Nil
Local cErro     := Nil
Local nX

AADD( aHeadOut, "Content-Type: application/json" )
AADD( aHeadOut, "User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() )

oRest := FWRest():New(cURL)
oRest:nTimeOut := 600
oRest:SetPath("/")

oBody := JsonObject():New()

cQryArt := ' mutation{'
cQryArt += '     authenticationByClient('
cQryArt += '         clientId: "'+cClientId+'", '
cQryArt += '         secret: "'+cSecret+'" '
cQryArt += '     ) {'
cQryArt += '         token'
cQryArt += '     }'
cQryArt += ' }'

oBody['query']     := cQryArt
oBody['variables'] := JsonObject():New()

oRest:SetPostParams(oBody:toJson())

If oRest:Post(aHeadOut)

    cResponse := oRest:GetResult()

    oResponse := JsonObject():New()
    cErro := oResponse:FromJson(cResponse)

    If ValType(cErro) == "C"
        cMsgErro := "Falha ao popular JsonObject. Erro: " + cErro
    Else
        If oResponse['data'] <> Nil
            cToken := oResponse['data']['authenticationByClient']['token']
            If !Empty(cToken)
                cMsgErro := ""
                lRetorno := .T.
            EndIf
        Else
            For nX := 1 To Len(oResponse['errors'])
                cMsgErro += oResponse['errors'][nX]['message'] + CRLF
            Next nX
        EndIf
    EndIf

    FreeObj(oResponse)
Else	
    cMsgErro := oRest:GetLastError()
EndIf

FreeObj(oRest)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatDt
Rotina de conexão com as API's do ARTIA.

@author  Wilson A. Silva Jr
@since   11/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FormatDt(dData)
Return Transform(DToS(dData),"@R 9999-99-99")
