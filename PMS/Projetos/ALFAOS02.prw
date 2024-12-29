#Include "FWBROWSE.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFAOS02
Rotina para gerar Ordem de Servico de acordo com o Artia
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
User Function ALFAOS02()

Local aParamBox     := {}
Local aRetParam     := {}
Local cPrjFormat    := CriaVar("AF8_PROJET",.F.)
Local cCliFormat    := CriaVar("A1_COD",.F.)
Local dDtProjet     := CriaVar("E1_EMISSAO",.F.)
Local lContinue     := .F.

Private cCadastro := "Integracao Artia"

aAdd( aParamBox, { 1, "Projeto De:"		, cPrjFormat, , '.T.', "AF8", "", 50, .F.} )
aAdd( aParamBox, { 1, "Projeto Ate:"	, cPrjFormat, , '.T.', "AF8", "", 50, .T.} )
aAdd( aParamBox, { 1, "Cliente De:"		, cCliFormat, , '.T.', "SA1", "", 50, .F.} )
aAdd( aParamBox, { 1, "Cliente Ate:"	, cCliFormat, , '.T.', "SA1", "", 50, .T.} )
aAdd( aParamBox, { 1, "Data Inicio:"	, dDtProjet , , '.T.', ""   , "", 50, .T.} )
aAdd( aParamBox, { 1, "Data Final:" 	, dDtProjet , , '.T.', ""   , "", 50, .T.} )

lContinue := ParamBox(aParamBox, "Filtros", @aRetParam)

If lContinue
    FWMsgRun(, {|| OS02Proj(aRetParam[1], aRetParam[2], aRetParam[3], aRetParam[4], aRetParam[5], aRetParam[6]) },;
                    "Aguarde", "Filtrando Registros...")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Proj
Consulta os projetos e monta a tela
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Proj(cProjDe, cProjAte, cCliDe, cCliAte, dDtIni, dDtFim)

Local oTempDB   := Nil
Local cAliasPrj := OS02Alias(cProjDe, cProjAte, cCliDe, cCliAte, @oTempDB)

If !Empty(cAliasPrj)
    OS02View(cAliasPrj, dDtIni, dDtFim, oTempDB)
Else
    MsgAlert("Nao foram encontrados registros.")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Alias
Retorna o Alias populado
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Alias(cProjDe, cProjAte, cCliDe, cCliAte, oTempDB)

Local cAliasPrj     := OS02TempDB(@oTempDB)
Local cNextAlias    := "OS02ALIASAF8"

If Select(cNextAlias) > 0
    (cNextAlias)->(dbCloseArea())
EndIf

BeginSQL Alias cNextAlias
    SELECT AF8_PROJET, AF8_DESCRI, AF8_GETTRF, AF8_REVISA, AF8_TPHORA, AF8_COORD, AF8_APROVA,
    AF8_TPSERV, A1_NOME, A1_COD, A1_LOJA
    FROM %table:AF8% AF8
    INNER JOIN %table:SA1% SA1  
    ON A1_FILIAL = %xFilial:SA1% AND A1_COD = AF8_CLIENT AND A1_LOJA = AF8_LOJA
    WHERE AF8_FILIAL = %xFilial:AF8%
    AND AF8_PROJET BETWEEN %exp:cProjDe% AND %exp:cProjAte%
    AND AF8_CLIENT BETWEEN %exp:cCliDe% AND %exp:cCliAte%
    AND AF8.%notdel%
    AND SA1.%notdel%
EndSQL

(cNextAlias)->( dbGoTop() )

If (cNextAlias)->( !Eof() )
    While (cNextAlias)->( !Eof() )
        RecLock(cAliasPrj, .T.)
        (cAliasPrj)->IDPRJ      := (cNextAlias)->AF8_GETTRF
        (cAliasPrj)->CODPRJ     := (cNextAlias)->AF8_PROJET
        (cAliasPrj)->DESCRI     := (cNextAlias)->AF8_DESCRI
        (cAliasPrj)->CLIENT     := (cNextAlias)->A1_NOME
        (cAliasPrj)->CODCLIENT  := (cNextAlias)->A1_COD
        (cAliasPrj)->LOJA       := (cNextAlias)->A1_LOJA
        (cAliasPrj)->REVISAO    := (cNextAlias)->AF8_REVISA
        (cAliasPrj)->TPHORA     := (cNextAlias)->AF8_TPHORA
        (cAliasPrj)->TPSERV     := (cNextAlias)->AF8_TPSERV
        (cAliasPrj)->COORD      := (cNextAlias)->AF8_COORD
        (cAliasPrj)->APROVA     := (cNextAlias)->AF8_APROVA
        (cAliasPrj)->( MsUnlock() )

        (cNextAlias)->( dbSkip() )
    EndDo
Else
    cAliasPrj := ""
EndIf

Return(cAliasPrj)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02View
Monta a tela
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02View(cAliasPrj, dDtIni, dDtFim, oTempDB)

Local aColumns  := OS02Columns()
Local oMark     := Nil
Local bClose    := {||}
Local bDetail   := {||}
Local bConfirm  := {||}
Local oSize     := FWDefSize():New(.T.)
Local aCoors    := FWGetDialogSize(oMainWnd)

oSize:AddObject( "DLG", 100, 100, .T., .T.)
oSize:SetWindowSize(aCoors)
oSize:lProp     := .T.
oSize:lLateral := .T.
oSize:Process()

DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] Title "Contratos de Horas" OF oMainWnd PIXEL

oMark := FWMarkBrowse():New()
oMark:SetOwner(oDlg)
    
//Tipo de dados
oMark:SetTemporary()
oMark:SetAlias(cAliasPrj)
    
oMark:SetFieldMark("mark")
oMark:SetColumns(aColumns)
oMark:SetAllMark({|| OS01Mark(oMark)})
    
oMark:SetMenuDef( "" )
oMark:DisableReport()
oMark:DisableConfig()
oMark:DisableFilter()
oMark:SetWalkThru(.F.)
oMark:SetAmbiente(.F.)
    
bClose	    := { || oDlg:End() }
bDetail     := {|| FWMsgRun(,{ || OS02Detail(oMark, dDtIni, dDtFim) }, "Aguarde", "Consultando Registros...") }
bConfirm    := {|| FWMsgRun(,{ |oMsgRun| OS02Confirm(oMark, oMsgRun, dDtIni, dDtFim), oDlg:End() }, "Aguarde", "Processando...") }
    
oMark:AddButton("Sair", bClose)
oMark:AddButton("Confirmar", bConfirm)
oMark:AddButton("Detalhes", bDetail)

oMark:Activate()
    
ACTIVATE MsDialog oDlg CENTERED
    
// Encerra a tabela temporaria
OS02DelWT(oTempDB)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Detail
Possibilita que o usuario consulte mais detalhes do cliente 
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Detail(oMark, dDtIni, dDtFim)

Local cAliasBrw	    := oMark:Alias()
Local cIDProj	    := (cAliasBrw)->idprj
Local cError	    := ""
Local aAtividades   := OS02Activities(cIDProj, cError, dDtIni, dDtFim)
Local aData         := {}
Local aAppointments := {}
Local nX            := 0
Local nY            := 0

If Empty(cError)
    For nX := 1 To Len(aAtividades)
        aData := OS02Appointments(aAtividades[nX], @cError)

        If Empty(cError)
            For nY := 1 To Len(aData)
                aAdd(aAppointments, {   aData[nY][1],;
                                        aData[nY][2],;
                                        aData[nY][3],;
                                        aData[nY][4],;
                                        aData[nY][5],;
                                        aData[nY][6],;
                                        aData[nY][7] } )
            Next nY
        Else
            MsgAlert("Erro: " + cError)
        EndIf

        aData   := {}
        nY      := 0

    Next nX

    If Empty(cError)
        If Len(aAppointments) > 0
            OS02VwDet(aAppointments)
        Else
            MsgAlert("Não foram encontrados registros", "Atenção")
        EndIf
    Else
        MsgAlert(cError, "Atenção")
    EndIf

Else
    MsgAlert(cError, "Atenção")
EndIf
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02TempDB
Efetua a criacao da tabela temporaria
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02TempDB(oTempTable)

Local aFields	:= OS02Struct()
Local cAliasPRJ	:= "OS02ALIAS"
    
If Select(cAliasPRJ) > 0
    (cAliasPRJ)->(dbCloseArea())
EndIf
    
oTempTable := FWTemporaryTable():New(cAliasPRJ)
oTempTable:SetFields(aFields)
oTempTable:AddIndex("01", {"codprj", "client"} )
oTempTable:Create()
    
Return(cAliasPRJ)
    
//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Columns
Retorna a estrutura das colunas do browse
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Columns()
    
Local aStruct	:= OS02Struct()
Local nPos		:= 0
Local nI        := 0
Local aColumns	:= {}
    
For nI := 2 to Len( aStruct )
    
    If aStruct[nI][7]
        nPos++
        aAdd( aColumns, FWBrwColumn():New() )
        
        aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
        aColumns[nPos]:SetTitle( aStruct[nI,5])
        aColumns[nPos]:SetSize(aStruct[nI,3])
        aColumns[nPos]:SetDecimal(aStruct[nI,4])
        aColumns[nPos]:SetPicture(aStruct[nI,6])
        aColumns[nPos]:SetType(aStruct[nI,2])
        aColumns[nPos]:SetAlign(1)
    EndIf

Next nI
    
Return(aColumns)
    
//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Struct
Retorna a estrutura das para o arquivo temporario
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Struct()
    
Local aFields := {}
    
aAdd(aFields, {"mark"		, "C", 01 ,0, "", ""})
aAdd(aFields, {"codprj"		, "C", 20 ,0, "Cod. Projeto"        , "@!", .T.})
aAdd(aFields, {"descri"	    , "C", 35 ,0, "Descrição Projeto"	, "@!", .T.})
aAdd(aFields, {"codclient"	, "C", TamSX3("A1_COD")[1] ,0, "Cod. Cliente"        , "@!", .T.})
aAdd(aFields, {"loja"	    , "C", TamSX3("A1_LOJA")[1] ,0, "Loja"                , "@!", .T.})
aAdd(aFields, {"client"	    , "C", 35 ,0, "Cliente"	            , "@!", .T.})
aAdd(aFields, {"idprj"	    , "C", TamSX3("AF8_GETTRF")[1] ,0, "ID Artia"            , "@!", .T.})
aAdd(aFields, {"revisao"	, "C", TamSX3("AF8_REVISA")[1] ,0, "ID Artia"            , "@!", .F.})
aAdd(aFields, {"tphora"	    , "C", TamSX3("AF8_TPHORA")[1] ,0, "ID Artia"            , "@!", .F.})
aAdd(aFields, {"tpserv"	    , "C", TamSX3("AF8_TPSERV")[1] ,0, "ID Artia"            , "@!", .F.})
aAdd(aFields, {"coord"	    , "C", TamSX3("AF8_COORD")[1] ,0, "ID Artia"            , "@!", .F.})
aAdd(aFields, {"aprova"	    , "C", TamSX3("AF8_APROVA")[1] ,0, "ID Artia"            , "@!", .F.})

Return(aFields)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Confirm
Confirmação da interface para geração das Ordens de Serviços
@author  Victor Andrade
@since   26/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Confirm(oMark, oMsgRun, dDtIni, dDtFim)

Local cAliasBrw	    := oMark:Alias()
Local cMark		    := oMark:Mark()
Local aAtividades   := {}
Local aAppointments := {}
Local aOrdem        := {} // Ordem de Serviço Completa
Local aDetOS        := {} // Horas da Ordem de Serviço
Local aOS           := {} // Lista com todas as ordens de Serviço
Local cError        := ""
Local cRecurso      := ""
Local nPosAppoint   := 0
Local nX            := 0
Local nY            := 0

(cAliasBrw)->(dbGoTop())

While (cAliasBrw)->(!Eof())

    If (cAliasBrw)->mark == cMark

        oMsgRun:cCaption := "Verificando Apontamentos (" + AllTrim((cAliasBrw)->client) + ")"
        ProcessMessage()

        aAtividades := OS02Activities((cAliasBrw)->idprj, @cError, dDtIni, dDtFim)

        If Empty(cError)
            For nX := 1 To Len(aAtividades)
                aData := OS02Appointments(aAtividades[nX], @cError)

                If Empty(cError)
                    For nY := 1 To Len(aData)
                        cRecurso    := OS02Rec(AllTrim(aData[nY][7]))
                        nPosAppoint := OS02Pos( aOS, aData[nY][1], AllTrim((cAliasBrw)->codprj), AllTrim(cRecurso) )

                        // Se ja existir apontamento, somente inclui a tarefa...
                        // Se nao existir monta a estrutura completa
                        If nPosAppoint > 0

                            aAdd( aOS[nPosAppoint][1][11], {} )

                            aAdd( aDetOS, aData[nY][2] )
                            aAdd( aDetOS, aData[nY][3] )
                            aAdd( aDetOS, aData[nY][4] )
                            aAdd( aDetOS, aData[nY][5] )
                            aAdd( aDetOS, aData[nY][6] )
                            aAdd( aDetOS, aData[nY][7] )

                            aOS[nPosAppoint][1][11][Len(aOS[nPosAppoint][1][11])] := aDetOS
                        Else

                            // Cabeçalho da O.S
                            aAdd( aOrdem, aData[nY][1] )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->codprj) )
                            aAdd( aOrdem, AllTrim(cRecurso) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->codclient) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->loja) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->revisao) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->tphora) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->coord) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->aprova) )
                            aAdd( aOrdem, AllTrim((cAliasBrw)->tpserv) )

                            aAdd( aOrdem, {} )
                            
                            // Apontamentos da O.S
                            aAdd( aDetOS, aData[nY][2] )
                            aAdd( aDetOS, aData[nY][3] )
                            aAdd( aDetOS, aData[nY][4] )
                            aAdd( aDetOS, aData[nY][5] )
                            aAdd( aDetOS, aData[nY][6] )
                            aAdd( aDetOS, aData[nY][7] )

                            aAdd( aOrdem[Len(aOrdem)], aDetOS )

                            aAdd( aAppointments, aOrdem )
                        EndIf

                        If Len(aAppointments) > 0
                            aAdd(aOS, aAppointments)
                        EndIf
                        
                        aDetOS          := {}
                        aOrdem          := {}
                        aAppointments   := {}
                        
                    Next nY
                Else
                    MsgAlert("Erro: " + cError, "Atenção")
                    Exit
                EndIf

                aData   := {}
                nY      := 0

            Next nX
        EndIf

        aAtividades := {}

    EndIf
    
    (cAliasBrw)->(dbSkip())
EndDo

If Len(aOS) > 0
    OS02GerOS(aOS, oMsgRun)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02DelWT
Deleta os arquivos de trabalho
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02DelWT(oTempDB)

oTempDB:Delete()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Appointments
Retorna os apontamentos de uma determinada atividade
@author  Victor Andrade
@since   30/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Appointments(nIdActivity, cError)

Local cURL      := "https://app.artia.com"
Local cEndPoint := "/api/v1/a/" + AllTrim(cValToChar(nIdActivity)) + "/time_entries"
Local oRest     := FWRest():New(cURL)
Local oResponse := Nil
Local aHeader   := OS02Header()
Local aRet      := {}
Local aTemp     := {}
Local nX        := 0

oRest:SetPath(cEndPoint)

If oRest:Get(aHeader)
    FWJsonDeserialize(oRest:GetResult(), @oResponse)

    For nX := 1 To Len(oResponse)
        aAdd( aTemp, oResponse[nX]["date_at"] )
        aAdd( aTemp, oResponse[nX]["start_time"] )
        aAdd( aTemp, oResponse[nX]["end_time"] )
        aAdd( aTemp, oResponse[nX]["duration"] )
        aAdd( aTemp, oResponse[nX]["created_at"] )
        aAdd( aTemp, oResponse[nX]["observation"] )
        aAdd( aTemp, oResponse[nX]["email"] )

        aAdd(aRet, aTemp)
        aTemp   := {}
    Next nX
Else
    cError := oRest:GetLastError()
EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Header
Retorna o Header da requisicao
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Header()

Local oAuth     := OS02Auth()
Local aHeader   := {}

aAdd(aHeader, "Content-Type: application/json")
aAdd(aHeader, "Authorization: Bearer " + oAuth["access_token"] )

Return(aHeader)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Header
Efetua a Autenticação no Artia
@author  Victor Andrade
@since   25/11/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Auth()

Local cURL          := "https://app.artia.com"
Local cClientID     := "68c8b82484e2ff5314f1822a71af83ed2c86e3cc0de635a78712abad52210cd4"
Local cSecret       := "ba35783cf01c4b218834f73a9ac40c371ada9ecb380ede814a63b99404738926"
Local cGrant        := "client_credentials"
Local cPath         := "/oauth/token?client_id=" + cClientID + "&client_secret=" + cSecret + "&grant_type=" + cGrant
Local oRest         := FWRest():New(cURL)
Local aHeader       := {}
Local oResponse     := JsonObject():New()

oRest:SetPath(cPath)

aAdd(aHeader, "Content-Type: application/json")

If oRest:Post(aHeader)
    oResponse:FromJson( oRest:GetResult() )
EndIf

Return(oResponse)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02VwDet
Monta a view contendo os detalhes de apontameto das Ordens de Serviço
@author  Victor Andrade
@since   17/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02VwDet(aOS)

Local oDlgDet	:= Nil
Local oBrwDet	:= Nil
Local oSize     := FWDefSize():New(.T.)
    
DEFINE MSDIALOG oDlgDet FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] Title "Detalhes Apontamentos" OF oMainWnd PIXEL

DEFINE FWBROWSE oBrwDet DATA ARRAY ARRAY aOS NO SEEK NO CONFIG NO REPORT NO LOCATE Of oDlgDet
    
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),1] } Title "Data" 	        SIZE 10 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),2] } Title "Horario Inicial"  SIZE 08 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),3] } Title "Horario Final"   	SIZE 08 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),4] } Title "Duração"  	    SIZE 05 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),5] } Title "Data Criação"     SIZE 20 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),6] } Title "Observação"       SIZE 30 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),7] } Title "E-mail"           SIZE 08 Of oBrwDet

ACTIVATE FWBrowse oBrwDet
    
Activate MsDialog oDlgDet ON INIT EnchoiceBar(oDlgDet, { || oDlgDet:End() }, { || oDlgDet:End()},,) CENTERED
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Item
Retorna o item do projeto
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Item(cCodProj, cRevProj)

Local aArea 	:= GetArea()
Local cAliasAF9	:= "ALIASAF9"
Local cTarRet	:= ""
    
If Select(cAliasAF9) > 0
    (cAliasAF9)->(dbCloseArea())
EndIf
    
BeginSQL Alias cAliasAF9
    SELECT AF9_TAREFA FROM %table:AF9% AF9
    WHERE AF9_FILIAL = %xFilial:AF9%
    AND AF9_PROJET = %exp:cCodProj%
    AND AF9_REVISA = %exp:cRevProj%
    AND AF9.%notdel%
EndSQL
    
(cAliasAF9)->(dbGoTop())
    
If (cAliasAF9)->(!Eof())
    cTarRet := (cAliasAF9)->AF9_TAREFA
EndIf
    
(cAliasAF9)->(dbCloseArea())
    
RestArea(aArea)
    
Return(cTarRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Rec
Retorna o codigo do recurso de acordo com o e-mail 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Rec(cEmail)

Local cAliasEmail	:= "ALIASEMAIL"
Local cCodRec		:= ""
Local aArea			:= GetArea()
    
If Select(cAliasEmail) > 0
    (cAliasEmail)->(dbCloseArea())
EndIf
    
BeginSQL Alias cAliasEmail
    SELECT AE8_RECURS FROM %table:AE8%
    WHERE AE8_EMAIL = %exp:cEmail%
    AND AE8_ATIVO = '1'
    AND %notdel%
EndSQL
    
If (cAliasEmail)->(!Eof())
    cCodRec := (cAliasEmail)->AE8_RECURS
EndIf
    
(cAliasEmail)->(dbCloseArea())
    
RestArea(aArea)
    
Return(cCodRec)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02GerOS
Geração da Ordem de Serviço
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02GerOS(aAppointments, oMsgRun)

Local nX        := 0
Local nY        := 0
Local nPosRec   := TamSX3("Z2_RECURSO")[1]
Local cHrIni    := ""
Local cHrFim    := ""
Local cHrTot    := ""
Local cCodProj	:= ""
Local cRevProj	:= ""
Local cItemProj	:= ""
Local cRecurso  := ""
Local dDataOS   := ""
Local cClient   := ""
Local cLoja     := ""
Local cTpHora   := ""
Local cTpServ   := ""
Local cItemOS	:= "000"
Local cNumOS    := ""
Local nTamItem	:= TamSX3("Z3_ITEM")[1]

oMsgRun:cCaption := "Incluindo Ordens de Serviço"
ProcessMessage()

SZ2->( dbSetOrder(3) )

For nX := 1 To Len(aAppointments)

    cRecurso    := PadR( AllTrim(aAppointments[nX][1][3]), nPosRec)
    dDataOS     := OS02Date(aAppointments[nX][1][1])
    cClient     := aAppointments[nX][1][4]
    cLoja       := aAppointments[nX][1][5]
    cTpHora     := aAppointments[nX][1][7]
    cTpServ     := aAppointments[nX][1][10]

    If !SZ2->( MsSeek( xFilial("SZ2") + cRecurso + DTOS(dDataOS) + cClient + cLoja ) )

        // Obtem por referencia os horas para gravação na SZ2
        OS02Horas(aAppointments[nX][1][11], @cHrIni, @cHrFim, @cHrTot)

        cCodProj := aAppointments[nX][1][2]
        cRevProj := aAppointments[nX][1][6]
        
        // Obtem o item do projeto
        // Conforme alinhado com o Fabio, em projetos de SD, so ha 1 item.
        cItemProj := OS02Item(cCodProj, cRevProj)

        cNumOS  := OS02GetNum()

        // Gravacao do Cabecalho da O.S
        RecLock("SZ2", .T.)
        SZ2->Z2_FILIAL 	:= xFilial("SZ2")
        SZ2->Z2_OS		:= cNumOS
        SZ2->Z2_DATA	:= dDataOS
        SZ2->Z2_RECURSO	:= cRecurso
        SZ2->Z2_CLIENTE	:= cClient
        SZ2->Z2_LOJA	:= cLoja
        SZ2->Z2_HRINI1	:= Left(cHrIni, 5)
        SZ2->Z2_HRFIM1	:= Left(cHrFim, 5)
        SZ2->Z2_TOTALHR	:= Left(cHrTot, 5)
        SZ2->Z2_STATUS	:= "2"
        SZ2->Z2_DATAINC	:= dDataOS
        SZ2->Z2_DTENCER	:= dDataOS
        SZ2->Z2_COORD   := aAppointments[nX][1][8]
        SZ2->Z2_CODRESP := aAppointments[nX][1][9]
		SZ2->Z2_CODSER	:= cTpServ
		SZ2->Z2_CODRESP	:= OS02Resp(cClient+cLoja)
        SZ2->(MsUnlock())
        
        // Gravação dos itens da O.S
        For nY := 1 To Len(aAppointments[nX][1][11])
            cItemOS	:= Soma1(cItemOS, nTamItem)
            RecLock("SZ3", .T.)
            SZ3->Z3_FILIAL	:= xFilial("SZ3")
            SZ3->Z3_OS		:= cNumOS
            SZ3->Z3_ITEM	:= cItemOS
            SZ3->Z3_PROJETO	:= cCodProj
            SZ3->Z3_REVISA	:= cRevProj
            SZ3->Z3_TAREFA	:= cItemProj
            SZ3->Z3_HORAS	:= OS02GetHour(aAppointments[nX][1][11][nY][3])
            SZ3->Z3_HUTEIS	:= CALCHORAS( OS02GetHour(aAppointments[nX][1][11][nY][3]) ) 
            SZ3->Z3_STATUS	:= "2"
            SZ3->Z3_TEXTO	:= aAppointments[nX][1][11][nY][5]
            SZ3->Z3_TPHORA	:= aAppointments[nX][1][7]
			SZ3->Z3_TPHORA	:= cTpHora
			SZ3->Z3_CODSER	:= cTpServ
            SZ3->(MsUnlock())
        Next nY
    EndIf
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Horas
Retorna a Hora Inicial/Final e o total de horas de atendimento de um
recurso/cliente
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Horas(aHoras, cHrIni, cHrFim, cHrTot)

Local nX        := 0
Local nDecimal  := 0
Local nInteiro  := 0
Local nMinutos  := 0
Local nEsforco  := 0
Local nHrTot    := 0

// Ordena o array por hora inicial crescente
aSort(aHoras,,, { | x,y | x[1] < y[1] } )
cHrIni := aHoras[1][1]
    
// Ordena o array por hora final decrescente
aSort(aHoras,,, { | x,y | x[2] > y[2] } )
cHrFim := aHoras[1][2]
    
// Obtem o total de horas trabalhadas para aquele cliente
For nX := 1 To Len(aHoras)
    nInteiro    := Int(aHoras[nX][3])
    nDecimal    := aHoras[nX][3] - nInteiro
    nMinutos    := ((nDecimal * 60)/100)
    nEsforco    := Round(nInteiro + nMinutos,2)
    nHrTot      := SomaHoras(nHrTot, nEsforco)
Next nX

nInteiro    := Int(nHrTot)
nDecimal    := nHrTot - nInteiro
nMinutos    := ( ((nDecimal * 60)/100) * 100 )
cHrTot      := StrZero(nInteiro, 2) + ":" + StrZero( Round(nMinutos, 2), 2 ) + ":00"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Pos
Retorna a posiçao de um array
recurso/cliente
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Pos( aOS, cData, cCodprj, cRecurso )

Local nPosArray := 0
Local nX        := 0

For nX := 1 To Len(aOS)
    If aOS[nX][1][1] == cData .And. aOS[nX][1][2] == cCodprj .And. aOS[nX][1][3] == cRecurso
        nPosArray   := nX
        Exit
    EndIf
Next nX

Return(nPosArray)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02GetNum
Retorna o sequencial
recurso/cliente
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02GetNum()

Local cNextCode := ""
Local cAliasSeq	:=	"ALIASSEQ"
    
If Select(cAliasSeq) > 0
    (cAliasSeq)->(dbCloseArea())
EndIf
    
BeginSQL Alias cAliasSeq
    SELECT MAX( Z2_OS ) MAX_NUM FROM %table:SZ2% SZ2
        WHERE SZ2.Z2_FILIAL = %xFilial:SZ2%
        AND SZ2.%notdel%
EndSQL
    
(cAliasSeq)->(dbGoTop())
    
If (cAliasSeq)->( !Eof() )
    cNextCode := Soma1((cAliasSeq)->MAX_NUM)
EndIf
    
(cAliasSeq)->(dbCloseArea())
    
Return(cNextCode)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Date
Converte o formato de data
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02Date(cTSDate)
Return( STOD( StrTran(SubStr(cTSDate, 1, 10), "-", "") ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} OS02Date
Retorna a hora formatada
@author  Victor Andrade
@since   01/12/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS02GetHour(nHrTot)

Local nInteiro    := Int(nHrTot)
Local nDecimal    := nHrTot - nInteiro
Local nMinutos    := ( ((nDecimal * 60)/100) * 100 )
Local cHrTot      := StrZero(nInteiro, 2) + ":" + StrZero( Round(nMinutos, 2), 2 )

Return(cHrTot)

Static Function OS02TOStamp(dDate)
Local cData := DTOS(dDate)
Return( SubStr(cData, 1, 4) + "-" + SubStr(cData, 5, 2) + "-" + SubStr(cData, 7, 2)  )

Static Function OS02Resp(cChave)

Local cAliasCTT	:=	"ALIASCTT"
Local cContRet	:= ""
    
If Select(cAliasCTT) > 0
    (cAliasCTT)->(dbCloseArea())
EndIf
    
BeginSQL Alias cAliasCTT
    SELECT AC8_CODCON FROM %table:AC8% AC8
    INNER JOIN %table:SU5% SU5
    ON U5_FILIAL = AC8_FILIAL
    AND U5_CODCONT = AC8_CODCON 
    WHERE AC8.AC8_FILIAL = %xFilial:AC8%
    AND AC8_ENTIDA = 'SA1'
    AND AC8_CODENT = %exp:cChave%
    AND U5_ATIVO = '1'
    AND U5_APRVOS = '1'
    AND AC8.%notdel%
EndSQL
    
(cAliasCTT)->(dbGoTop())
    
If (cAliasCTT)->( !Eof() )
    cContRet := (cAliasCTT)->AC8_CODCON
EndIf
    
(cAliasCTT)->(dbCloseArea())
    
Return(cContRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CALCHORAS ºAutor  ³Fabio Rogerio       º Data ³  08/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para o calculo de horas em horal centesimal          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALCHORAS(cHora)

Local nHoras   := 0
Local nMinutos := 0
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Converte para numerico	            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nHoras   := Val(SubStr(cHora,1, At(":", cHora)-1))
nMinutos := Val(SubStr(cHora,At(":", cHora)+1, 2))
    
While .T.
    If nMinutos >= 60
        nMinutos -= 60
        nHoras++
    Else
        Exit
    EndIf
End
nHoras+= nMinutos/60
    
Return nHoras