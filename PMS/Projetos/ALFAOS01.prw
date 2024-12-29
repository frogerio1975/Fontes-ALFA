#Include "FWBROWSE.CH"
#Include "PROTHEUS.CH"

#DEFINE HCONSUMED 	 1
#DEFINE HCONTRACTED  2

//Static cToken    := "448f8647-50cb-47e2-995c-b2bbe474486a"
Static cToken    := "b49152ee-13b9-4fe2-a8dd-414679f5edc7"
Static cEndPoint := "https://api.movidesk.com/"
Static cMoviDesk := "S"
Static __lJob	 := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFAOS01
Rotina para gerar Ordem de Serviço de acordo com o MovieDesk
@author  Victor Andrade
@since   08/10/2019
@version 1
/*/
//-------------------------------------------------------------------
User Function ALFAOS01(lJob)

Local lHasContract		:= .F.
Local cError        	:= ""
Local cAliasContract	:= ""
Local oTempDB			:= Nil
Local aParamBox			:= {}
Local aRetParam			:= {}

Private aErros 	 := {}
Private cPeriodo := ""
Private dPerIni  := FirstDay(DATE())
Private dPerFim  := LastDay(DATE())

Default lJob := .F.

__lJob := lJob

If __lJob
	/*
	dDtProc := FirstDay(DATE()-1)
	If SubStr(DToS(dDtProc),1,6) <> SubStr(DToS(DATE()),1,6)
		cPeriodo := StrZero(Year(dDtProc),4) + "-" + StrZero(Month(dDtProc),2) + "-" + StrZero(Day(dDtProc),2)
	EndIf
	*/
	lHasContract := OS01Agreements(@cAliasContract, @cError, Nil, @oTempDB)

	If lHasContract
		
		(cAliasContract)->(dbGoTop())

		While (cAliasContract)->(!Eof())
		
			Conout("Processando Contrato: " + AllTrim((cAliasContract)->name))
			LjWriteLog( cARQLOG, "Processando Contrato: " + AllTrim((cAliasContract)->name) )

			// Efetua a consulta das ordens de serviço no moviedesk e gera a SZ2/SZ3
			OS01Proc((cAliasContract)->name, Nil)

			(cAliasContract)->(dbSkip())
		EndDo
	Else
		Conout("Erro ao obter contratos: " + AllTrim(cError))
		LjWriteLog( cARQLOG, "Erro ao obter contratos: " + AllTrim(cError) )
	EndIf

Else
	//aAdd( aParamBox, { 3, "Período"			  ,1,{"Atual","Anteriores"},50,"",.T.})
	//aAdd( aParamBox, { 1, "Data Renovacao (Per. Anterior)", Space(11), "@E 99-99-9999", '.T.', "", "", 50, .F.} )

	aAdd( aParamBox, { 1, "Data Inicial", dPerIni, "", ".T.", "", "", 50, .F.} )
	aAdd( aParamBox, { 1, "Data Final"	, dPerFim, "", ".T.", "", "", 50, .F.} )

	If ParamBox(aParamBox, "Filtros", @aRetParam)
		/*
		If aRetParam[1] == 2
			cPeriodo := SubStr(aRetParam[2],7,4) + "-" + SubStr(aRetParam[2],4,2) + "-" + SubStr(aRetParam[2],1,2)
		EndIf
		*/
		dPerIni := aRetParam[1]
		dPerFim := aRetParam[2]
		
		// Efetua a consulta dos contratos de horas
		FWMsgRun(, { |oMsgRun| lHasContract := OS01Agreements(@cAliasContract, @cError, oMsgRun, @oTempDB) }, "Aguarde", "Consultando Contratos...")
		
		If lHasContract
			OS01View(cAliasContract, oTempDB)
		Else
			MsgAlert( "Erro ao obter contratos: " + Chr(13) + Chr(10); 
						+ AllTrim(cError), "Atencao" )
		EndIf
		
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Agreements
Efetua a consulta dos contratos de horas
@author  Victor Andrade
@since   08/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Agreements(cAliasCtt, cError, oMsgRun, oTempDB)

Local cPath     := "public/v1/timeAgreement?token=" + cToken + "&$select=name"
Local oRequest  := Nil
Local oResponse	:= Nil
Local aHeader   := {}
Local lRet      := .F.

aAdd(aHeader, "Content-Type: application/json")

oRequest  := FWRest():New(cEndPoint)
oRequest:SetPath(cPath)

If oRequest:Get(aHeader)
	FWJsonDeserialize(oRequest:GetResult(), @oResponse)
    
    // Joga o resultado que está em um JSON para um Alias
    cAliasCtt := OS01ToAlias(oResponse, oMsgRun, @oTempDB)
    lRet := .T.
Else
    cError := oRequest:GetLastError()
EndIf

FreeObj(oRequest)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01View
Monta a tela para que possa selecionar os contratos
para geração das ordens de Serviço
@author  Victor Andrade
@since   08/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01View(cAliasCTT, oTempDB)

Local oDlg      := Nil
Local oMark     := Nil
Local oSize     := FWDefSize():New(.T.)
Local aCoors    := FWGetDialogSize(oMainWnd)
Local aColumns	:= OS01Columns()
Local bConfirm	:=	{||}
Local bClose	:=	{||}

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
oMark:SetAlias(cAliasCTT)

//Configuração de colunas
oMark:SetFieldMark("mark")
oMark:SetColumns(aColumns)
oMark:SetAllMark({|| OS01Mark(oMark)})

//Configuracao de opcoes
oMark:SetMenuDef( "" )
oMark:DisableReport()
oMark:DisableConfig()
oMark:DisableFilter()
oMark:SetWalkThru(.F.)
oMark:SetAmbiente(.F.)

bClose		:= {|| oDlg:End() }
bConfirm	:= {|| FWMsgRun(,{ |oMsgRun| OS01Confirm(oMark, oMsgRun), oDlg:End() }, "Aguarde", "Processando...") }
bMoreDet	:= {|| FWMsgRun(,{ || OS01Detail(oMark) }, "Aguarde", "Consultando Registros...") }

oMark:AddButton("Sair", bClose)
oMark:AddButton("Confirmar", bConfirm)
oMark:AddButton("Detalhes", bMoreDet)

oMark:Activate()

OS01Mark(oMark)

ACTIVATE MsDialog oDlg CENTERED

// Encerra a tabela temporária
OS01DelWT(oTempDB)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01ToAlias
Gera a tabela temporária com os contratos
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01ToAlias(oResponse, oMsgRun, oTempDB)

Local nX		:= 0
Local cAliasCTT := OS01TempDB(@oTempDB)
Local aDataCTT	:= {}
Local cName		:= ""

For nX := 1 To Len(oResponse)
	
	cName := DecodeUTF8(oResponse[nX]:name)

	If !__lJob
		oMsgRun:cCaption := "Verificando Contrato: " + cName
		ProcessMessage()
	EndIf
	
	// Consulta os dados dos contratos de clientes
	//aDataCTT	:= OS01HrCTT(oResponse[nX]:name)
	
	RecLock(cAliasCTT, .T.)
	(cAliasCTT)->name		:= FwNoAccent(AllTrim(cName))
	(cAliasCTT)->contracted	:= 0//aDataCTT[HCONTRACTED]
	(cAliasCTT)->consumed	:= 0//aDataCTT[HCONSUMED]
	(cAliasCTT)->(MsUnlock())
Next nX

Return(cAliasCTT)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01TempDB
Efetua a criação da tabela temporária
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01TempDB(oTempTable)

Local aFields	:= OS01Struct()
Local cAliasCTT	:= "OS01ALIAS"

If Select(cAliasCTT) > 0
	(cAliasCTT)->(dbCloseArea())
EndIf

oTempTable := FWTemporaryTable():New(cAliasCTT)
oTempTable:SetFields(aFields)
oTempTable:AddIndex("01", {"NAME"} )
oTempTable:Create()

Return(cAliasCTT)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Columns
Retorna a estrutura das colunas do browser
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Columns()

Local aStruct	:= OS01Struct()
Local nPos		:= 0
Local aColumns	:= {}
Local nI        := 0

For nI := 2 to Len( aStruct )
	nPos++
	aAdd( aColumns, FWBrwColumn():New() )

	aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
	aColumns[nPos]:SetTitle( aStruct[nI,5])
	aColumns[nPos]:SetSize(aStruct[nI,3])
	aColumns[nPos]:SetDecimal(aStruct[nI,4])
	aColumns[nPos]:SetPicture(aStruct[nI,6])
	aColumns[nPos]:SetType(aStruct[nI,2])
	aColumns[nPos]:SetAlign(1)
Next nI

Return(aColumns)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Struct
Retorna a estrutura das para o arquivo temporário
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Struct()

Local aFields := {}

aAdd(aFields, {"mark"		, "C", 01 ,0, "", ""})
aAdd(aFields, {"name"		, "C", 50 ,0, "Contrato", "@!"})
aAdd(aFields, {"contracted"	, "N", 07 ,2, "Horas Contratadas"	, "@E 99999.99"})
aAdd(aFields, {"consumed"	, "N", 07 ,2, "Horas Consumidas"	, "@E 99999.99"})

Return(aFields)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Mark
Inverte a marcação de um determinado registro
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Mark(oMark)

Local cAliasBrw	:= oMark:Alias()
Local cMark		:= oMark:Mark()
Local nRecno	:= (cAliasBrw)->(Recno())

(cAliasBrw)->(dbGoTop())
	
While (cAliasBrw)->(!Eof())
	If RecLock(cAliasBrw, .F.)
		(cAliasBrw)->MARK := Iif((cAliasBrw)->MARK == cMark, "  ", cMark)
		(cAliasBrw)->(MsUnlock())
	EndIf
	(cAliasBrw)->( DBSkip() )
EndDo
	
(cAliasBrw)->(dbGoto(nRecno))
oMark:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Detail
Possibilita que o usuário consulte mais detalhes do cliente 
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Detail(oMark)

Local oContract	:= Nil
Local cAliasBrw	:= oMark:Alias()
Local cContract	:= (cAliasBrw)->name
Local cError	:= ""
Local aFields	:= {}
Local aExpand	:= {}

aAdd(aFields, "name")
aAdd(aExpand, "timeAppointments($expand=createdBy, createdByTeam)")

//$filter=timeAppointments/any(a: a/date ge 2020-01-17 ) AND timeAppointments/any(a: a/date le 2020-01-17)&$select=name&$expand=timeAppointments($filter=date ge 2020-01-17 AND date le 2020-01-17)

oContract := OS01DataCTT(cContract, @cError, aFields, aExpand)

If Empty(cError)
	// Monta a tela com os detalhes das O.S
	If Len(oContract) > 0
		OS01VwDet(oContract)
	Else
		MsgAlert("Não foram encontrados registros", "Atenção")
	EndIf
	
Else
    MsgAlert("Não foram encontrados registros", "Atenção")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01DataCTT
Consulta um contrato específico na API
@author  Victor Andrade
@since   13/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01DataCTT(cCont, cError, aFields, aExpand)

Local cEspaco	:= "%20"
Local cContract	:= AllTrim(StrTran(cCont, " ", cEspaco))
Local cPath 	:= ""
Local aHeader   := {}
Local oRequest	:= Nil
Local oResponse	:= Nil
Local nX		:= 0
Local cPerIni 	:= StrZero(Year(dPerIni),4) + "-" + StrZero(Month(dPerIni),2) + "-" + StrZero(Day(dPerIni),2)
Local cPerFim 	:= StrZero(Year(dPerFim),4) + "-" + StrZero(Month(dPerFim),2) + "-" + StrZero(Day(dPerFim),2)

Default aFields := {}
Default aExpand	:= {}

// Monta o path de consulta
cPath := "public/v1/timeAgreementConsumption?token=" + cToken

cPath += "&name=" + cContract
cPath += "&startPeriod=" + cPerIni
cPath += "&endPeriod=" + cPerFim
/*
If Empty(cPeriodo)
	cPath += "&name=" + cContract
Else

	// A API só permite customizar campos em períodos anteriores...
	cPath += "&$filter=name Eq '" + cContract + "' And period Eq " + cPeriodo
		
	//Consultar campos específicos...
	If Len(aFields) > 0
		cPath += "&$select="
		For nX := 1 To Len(aFields)
			cPath += aFields[nX] + ","
		Next nX
		
		// Remover a virgula final
		cPath := Left(cPath, Len(cPath) - 1)
	EndIf
	
	//Expandir itens filhos...
	If Len(aExpand) > 0
		cPath += "&$expand="
		For nX := 1 To Len(aExpand)
			cPath += aExpand[nX] + ","
		Next nX
		
		// Remover a virgula final
		cPath := Left(cPath, Len(cPath) - 1)
	EndIf

EndIf
*/
aAdd(aHeader, "Content-Type: application/json")

oRequest  := FWRest():New(cEndPoint)
oRequest:SetPath(StrTran(cPath, " ", cEspaco))

If oRequest:Get(aHeader)
	FWJsonDeserialize(oRequest:GetResult(), @oResponse)
Else
    cError := oRequest:GetLastError()
EndIf

FreeObj(oRequest)

Return(oResponse)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01VwDet
Monta a view contendo os detalhes de apontameto das Ordens de Serviço
@author  Victor Andrade
@since   17/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01VwDet(oJson)

Local nContract := 0
Local nItemOs	:= 0
Local aItem		:= {}
Local aOS		:= {}
Local oDlgDet	:= Nil
Local oBrwDet	:= Nil
Local oSize     := FWDefSize():New(.T.)

If ValType(oJson) == "A"
	For nContract := 1 To Len(oJson)
		For nItemOS := 1 To Len(oJson[nContract]:timeAppointments)
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:createdBy:businessName )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:createdBy:email )
			
			If ValType(oJson[nContract]:timeAppointments[nItemOS]:createdByTeam) == "O"
				aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:createdByTeam:name )
			Else
				aAdd(aItem, "" )			
			EndIf
			
			aAdd(aItem, DecodeUTF8(oJson[nContract]:timeAppointments[nItemOS]:activity) )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:date )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:periodStart )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:periodEnd )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:workTime )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:workTypeName )
			aAdd(aItem, oJson[nContract]:timeAppointments[nItemOS]:ticketNumber )
		
			aAdd(aOS, aItem)
			aItem := {}
		Next nItemOS
	Next nContract
ElseIf ValType(oJson) == "O"
	
	If ValType(oJson:timeAppointments) == "A"
		For nItemOS := 1 To Len(oJson:timeAppointments)
			aAdd(aItem, oJson:timeAppointments[nItemOS]:createdBy:businessName )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:createdBy:email )
			
			If ValType(oJson:timeAppointments[nItemOS]:createdByTeam) == "O"
				aAdd(aItem, oJson:timeAppointments[nItemOS]:createdByTeam:name )
			Else
				aAdd(aItem, "" )			
			EndIf
			
			aAdd(aItem, DecodeUTF8(oJson:timeAppointments[nItemOS]:activity) )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:date )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:periodStart )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:periodEnd )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:workTime )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:workTypeName )
			aAdd(aItem, oJson:timeAppointments[nItemOS]:ticketNumber )
			
			aAdd(aOS, aItem)
			aItem := {}
		Next nItemOS
	EndIf		
EndIf

DEFINE MSDIALOG oDlgDet FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] Title "Detalhes Apontamentos" OF oMainWnd PIXEL

DEFINE FWBROWSE oBrwDet DATA ARRAY ARRAY aOS NO SEEK NO CONFIG NO REPORT NO LOCATE Of oDlgDet

ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),1] } Title "Recurso" 	    SIZE 20 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),2] } Title "E-mail"    	SIZE 20 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),3] } Title "Time"   		SIZE 20 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),4] } Title "Atividade"  	SIZE 35 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),5] } Title "Data" 	    SIZE 15 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),6] } Title "Hr Inicial" 	SIZE 08 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),7] } Title "Hr Final" 	SIZE 08 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),8] } Title "Hrs Trab" 	SIZE 08 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),9] } Title "Tipo Trab" 	SIZE 10 Of oBrwDet
ADD COLUMN oColumn DATA { || aOS[oBrwDet:At(),10]} Title "Ticket" 		SIZE 10 Of oBrwDet

ACTIVATE FWBrowse oBrwDet

Activate MsDialog oDlgDet ON INIT EnchoiceBar(oDlgDet, { || oDlgDet:End() }, { || oDlgDet:End()},,) CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01DelWT
Deleta os arquivos de trabalho
@author  Victor Andrade
@since   17/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01DelWT(oTempDB)

oTempDB:Delete()

DelClassIntF()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01HrCTT
Confirmação da interface para geração das Ordens de Serviços
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01HrCTT(cNameCtt)

Local aRet		:= Array(2)                                 
Local oContract	:= Nil
Local nX		:= 0
Local cError	:= ""

oContract := OS01DataCTT(cNameCtt, @cError, {"consumedHours", "contractedHours"} )

If Empty(cError)
    aRet[HCONSUMED]		:= 0
    aRet[HCONTRACTED]	:= 0
    
    If ValType(oContract) == "A"
	    For nX := 1 To Len(oContract)
		    aRet[HCONSUMED]		+= oContract[nX]:consumedHours
		    aRet[HCONTRACTED]	+= oContract[nX]:contractedHours
		Next nX
	ElseIf ValType(oContract) == "O"
		aRet[HCONSUMED]		+= oContract:consumedHours
		aRet[HCONTRACTED]	+= oContract:contractedHours	
	EndIf
EndIf

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Confirm
Confirmação da interface para geração das Ordens de Serviços
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Confirm(oMark, oMsgRun)

Local cAliasBrw	:= oMark:Alias()
Local cMark		:= oMark:Mark()

(cAliasBrw)->(dbGoTop())

While (cAliasBrw)->(!Eof())

	If (cAliasBrw)->mark == cMark
		// Efetua a consulta das ordens de serviço no moviedesk e gera a SZ2/SZ3
		OS01Proc((cAliasBrw)->name, oMsgRun)
	EndIf

	(cAliasBrw)->(dbSkip())
EndDo

MsgAlert("Processamento finalizado.")

If Len(aErros) > 0
	If MsgYesNo("Deseja imprimir o log de processamento?")
		OS01Report()
	EndIf
	
	aErros := {}
EndIf

// Restaura o browse
(cAliasBrw)->(dbGoTop())
While (cAliasBrw)->(!Eof())
	If (cAliasBrw)->mark == cMark
		RecLock(cAliasBrw, .F.)
		(cAliasBrw)->mark := "  "
		(cAliasBrw)->(MsUnlock())
	EndIf
	(cAliasBrw)->(dbSkip())
EndDo

(cAliasBrw)->(dbGoTop())
oMark:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Proc
Consulta os dados de um contrato e verifica se deve gerar a O.S
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Proc(cNameCTT, oMsgRun)

Local oContract 	:= Nil
Local cError		:= ""
Local cCreatedTeam	:= ""
Local nContract		:= 0
Local nItemOS		:= 0
Local nPosConsult	:= 0
Local aAppointments	:= {}
Local aOrdens		:= {}
Local aOrdem		:= {}
Local dDateOS		:= ""
Local aFields		:= {}
Local aExpand		:= {}
Local aContract 	:= {}
Local nItDesp		:= 0
Local aExpenses		:= {}
Local lPresencial 	:= .F.

aAdd(aFields, "name")
aAdd(aExpand, "timeAppointments($expand=createdBy, createdByTeam)")

aContract := {}
oContract := OS01DataCTT(cNameCTT, @cError, aFields, aExpand)

If Empty(cError)
	If ValType(oContract) == "O"
		AADD( aContract, oContract )
	Else
		aContract := oContract
	EndIf

	For nContract := 1 To Len(aContract)

		// Despesas
		aExpenses := aContract[nContract]:expenses

		// Carrega Apontamentos
		aAppointments := aContract[nContract]:timeAppointments
		For nItemOS := 1 To Len(aAppointments)

			lPresencial := .F.
			
			dDateOS := OS01Date(aAppointments[nItemOS]:date)
			
			If !__lJob
				oMsgRun:cCaption := "Gerando O.S: " + AllTrim(aAppointments[nItemOS]:createdBy:email) + " - " + DTOC(dDateOS)
				ProcessMessage()
			EndIf
			
			If ValType(aAppointments[nItemOS]:createdByTeam) == "O"
				cCreatedTeam := aAppointments[nItemOS]:createdByTeam:name
			EndIf
			
			aAdd(aOrdem, cCreatedTeam)
			aAdd(aOrdem, DecodeUTF8(aAppointments[nItemOS]:activity) )
			aAdd(aOrdem, aAppointments[nItemOS]:periodStart )
			aAdd(aOrdem, aAppointments[nItemOS]:periodEnd )
			aAdd(aOrdem, aAppointments[nItemOS]:workTime )
			aAdd(aOrdem, aAppointments[nItemOS]:workTypeName )
			aAdd(aOrdem, aAppointments[nItemOS]:ticketNumber )

			// Se tiver despesa coloca OS como Presencial
			lPresencial := aScan( aExpenses, {|x| x:createdBy:email == aAppointments[nItemOS]:createdBy:email .And. x:date == aAppointments[nItemOS]:date } ) > 0

			// Agrupa as Ordens de Serviço por analista/data
			nPosConsult := aScan( aOrdens, {|x| x[1] == aAppointments[nItemOS]:createdBy:email .And. x[3] == dDateOS } ) 
			
			If nPosConsult > 0
				aAdd(aOrdens[nPosConsult][4],;
					aOrdem)
			Else
				aAdd(aOrdens, {;
				aAppointments[nItemOS]:createdBy:email,;
				aAppointments[nItemOS]:createdBy:businessName,;
				dDateOS,;
				{ aOrdem },;
				lPresencial })
			EndIf
		
			aOrdem 		:= {}
			nPosConsult	:= 0
			cCreatedTeam := ""
			
		Next nItemOS
	Next nContract
Else
	MsgAlert(cError, "Atencao")
EndIf

If Len(aOrdens) > 0
	OS01GrvOS(aOrdens, cNameCTT)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01GrvOS
Realiza a gravação das Ordens de Serviço caso não exista 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01GrvOS(aOrdens, cNameCTT)

Local nX 		:= 0
Local nY		:= 0
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
Local cItemOS	:= "000"
Local cHrIni	:= "00:00:00"
Local cHrFim	:= "00:00:00"
Local cHrTot	:= "00:00:00"
Local nTamItem	:= TamSX3("Z3_ITEM")[1]
Local aValDesp	:= {}

SZ2->(dbSetOrder(3)) // Z2_FILIAL+Z2_RECURSO+Z2_DATA+Z2_CLIENTE+Z2_LOJA

For nX :=  1 To Len(aOrdens)

	cRecurso := OS01Rec(AllTrim(aOrdens[nX][1])) // Obtém o código do recurso
	
	If !Empty(cRecurso)
		
		// Obtém o cliente/loja de acordo com o projeto do MovieDesk
		// O código do projeto são os 10 últimos caracteres da descrição do contrato 
		cCodProj := Right(AllTrim(cNameCTT), 10)
		
		If OS01Cli(cCodProj, @cCliente, @cLoja, @cRevProj, @cTpHora, @cCoord, @cAprov, @cTpServ)

			// Caso já exista OS do Movidesk exclui e lança de novo.
			SZ2->(dbSetOrder(3)) // Z2_FILIAL+Z2_RECURSO+Z2_DATA+Z2_CLIENTE+Z2_LOJA
			If SZ2->(dbSeek(xFilial("SZ2") + cRecurso + DTOS(aOrdens[nX][3]) + cCliente + cLoja))
						
				While SZ2->(!EOF()) .And. SZ2->(Z2_FILIAL+Z2_RECURSO+DTOS(Z2_DATA)+Z2_CLIENTE+Z2_LOJA) == (xFilial("SZ2") + cRecurso + DTOS(aOrdens[nX][3]) + cCliente + cLoja)

					If SZ2->Z2_MOVDESK <> cMoviDesk
						SZ2->(dbSkip())
						LOOP
					EndIf

					SZ3->(dbSetOrder(1)) // Z3_FILIAL+Z3_OS+Z3_ITEM
					If SZ3->(dbSeek(xFilial("SZ3") + SZ2->Z2_OS))
					
						While SZ3->(!EOF()) .And. SZ3->(Z3_FILIAL+Z3_OS) == SZ2->(Z2_FILIAL+Z2_OS)

							RecLock("SZ3",.F.)
								SZ3->(dbDelete())
							SZ3->(MsUnlock())

							SZ3->(dbSkip())
						EndDo
					EndIf

					RecLock("SZ2",.F.)
						SZ2->(dbDelete())
					SZ2->(MsUnlock())

					SZ2->(dbSkip())
				EndDo
			EndIf
				
			// Obtém a soma das despesas
			aValDesp := {0,0}//OS01Desp(aOrdens[nX][4])
			
			// Obtém por referência os horas para gravação na SZ2
			OS01Horas(aOrdens[nX][4], @cHrIni, @cHrFim, @cHrTot)
			
			cNumOS := OS01GetNum()
			
			// Obtém o item do projeto
			// Conforme alinhado com o Fábio, em projetos de SD, só há 1 item.
			cItemProj := OS01Item(cCodProj, cRevProj)
			
			// Gravação do Cabeçalho da O.S
			RecLock("SZ2", .T.)
				SZ2->Z2_FILIAL 	:= xFilial("SZ2")
				SZ2->Z2_OS		:= cNumOS
				SZ2->Z2_DATA	:= aOrdens[nX][3]
				SZ2->Z2_RECURSO	:= cRecurso
				SZ2->Z2_CLIENTE	:= cCliente
				SZ2->Z2_LOJA	:= cLoja
				SZ2->Z2_HRINI1	:= Left(cHrIni, 5)
				SZ2->Z2_HRFIM1	:= Left(cHrFim, 5)
				SZ2->Z2_TOTALHR	:= Left(cHrTot, 5)
				SZ2->Z2_STATUS	:= "2"
				SZ2->Z2_DATAINC	:= aOrdens[nX][3]
				SZ2->Z2_DTENCER	:= aOrdens[nX][3]
				SZ2->Z2_COORD   := cCoord
				SZ2->Z2_CODRESP := "104431" // cAprov // OS01Resp(cCliente+cLoja)
				SZ2->Z2_TRANSLA	:= "00:00"
				SZ2->Z2_ESTAC	:= aValDesp[1]
				SZ2->Z2_PEDAGIO	:= aValDesp[2]
				SZ2->Z2_TPATEND	:= IIF(aOrdens[nX][5],"1","2") // 1=Presencial Cliente ou 2=Remoto
				SZ2->Z2_CODSER	:= cTpServ
				If SZ2->(FieldPos("Z2_MOVDESK")) > 0
					SZ2->Z2_MOVDESK	:= cMoviDesk
				EndIf
				If SZ2->(FieldPos("Z2_DTMDESK")) > 0
					SZ2->Z2_DTMDESK	:= DATE()
				EndIf
				If SZ2->(FieldPos("Z2_HRMDESK")) > 0
					SZ2->Z2_HRMDESK	:= TIME()
				EndIf
			SZ2->(MsUnlock())
			
			// Gravação dos itens da O.S
			For nY := 1 To Len(aOrdens[nX][4])
				cItemOS	:= Soma1(cItemOS, nTamItem)
				RecLock("SZ3", .T.)
					SZ3->Z3_FILIAL	:= xFilial("SZ3")
					SZ3->Z3_OS		:= cNumOS
					SZ3->Z3_ITEM	:= cItemOS
					SZ3->Z3_PROJETO	:= cCodProj
					SZ3->Z3_REVISA	:= cRevProj
					SZ3->Z3_TAREFA	:= cItemProj
					SZ3->Z3_HORAS	:= Left(aOrdens[nX][4][nY][5], 5)
					SZ3->Z3_HUTEIS	:= CALCHORAS(Left(aOrdens[nX][4][nY][5], 5)) 
					SZ3->Z3_STATUS	:= "2"
					SZ3->Z3_TEXTO	:= aOrdens[nX][4][nY][2]
					SZ3->Z3_TPHORA	:= cTpHora
					SZ3->Z3_CODSER	:= cTpServ
				SZ3->(MsUnlock())
			Next nY
			
			ConfirmSX8()
		Else
			aAdd(aErros, "Contrato " + cNameCTT + " não encontrado." )
		EndIf
	Else
		aAdd(aErros, AllTrim(aOrdens[nX][1]) + " recurso não encontrado." )
	EndIf
	
	cRecurso := ""
	cCliente := ""
	cLoja	 := ""
	cHrIni	 := ""
	cHrFim	 := ""
	cHrTot	 := ""
	cTpServ	 := ""

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Rec
Retorna o código do recurso de acordo com o e-mail 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Rec(cEmail)

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
/*/{Protheus.doc} OS01Cli
Retorna código e loja do cliente por referência 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Cli(cCodProj, cCliente, cLoja, cRevProj, cTpHora, cCoord, cAprov, cTpServ)

Local aArea 	:= GetArea()
Local lRet		:= .F.
Local cAliasAF8	:= "ALIASAF8"

If Select(cAliasAF8) > 0
	(cAliasAF8)->(dbCloseArea())
EndIf

BeginSQL Alias cAliasAF8
	SELECT AF8_CLIENT, AF8_LOJA, AF8_PROJET, AF8_REVISA, AF8_TPHORA, 
	AF8_COORD, AF8_APROVA, AF8_TPSERV FROM %table:AF8%
	WHERE AF8_PROJET = %exp:cCodProj%
	AND %notdel%
EndSQL

(cAliasAF8)->(dbGoTop())

If (cAliasAF8)->(!Eof())
	lRet := .T.
	cCliente := (cAliasAF8)->AF8_CLIENT 
	cLoja	 := (cAliasAF8)->AF8_LOJA
	cRevProj := (cAliasAF8)->AF8_REVISA
	cTpHora	 := (cAliasAF8)->AF8_TPHORA
	cTpServ  := (cAliasAF8)->AF8_TPSERV
EndIf

(cAliasAF8)->(dbCloseArea())

RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Horas
Retorna a Hora Inicial/Final e o total de horas de atendimento de um
recurso/cliente 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Horas(aHoras, cHrIni, cHrFim, cHrTot)

Local nX := 0

// Ordena o array por hora inicial crescente
aSort(aHoras,,, { | x,y | x[3] < y[3] } )
cHrIni := aHoras[1][3]

// Ordena o array por hora final decrescente
aSort(aHoras,,, { | x,y | x[4] > y[4] } )
cHrFim := aHoras[1][4]

// Obtém o total de horas trabalhadas para aquele cliente
For nX := 1 To Len(aHoras)
	cHrTot := IncTime( cHrTot, Val(SubStr(aHoras[nX][5],1,2)), Val(SubStr(aHoras[nX][5],4,2)), Val(SubStr(aHoras[nX][5],7,2)) )
Next nX

If cHrIni == Nil
	cHrIni := "00:00:00"
EndIf

If cHrFim == Nil
	cHrFim := "00:00:00"
EndIf

If cHrTot == Nil
	cHrTot := "00:00:00"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Date
Converte Data TimeStamp para data ADVPL
recurso/cliente 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Date(cTSDate)
Return( STOD( StrTran(SubStr(cTSDate, 1, 10), "-", "") ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Report
Realiza a impressão do log de processamento
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Report()
	U_ALFAOSR1(aErros)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Item
Retorna o item do projeto
@author  Victor Andrade
@since   22/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Item(cCodProj, cRevProj)

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
/*/{Protheus.doc} OS01Desp
Obtém as despesas de um determinado ticket
@author  Victor Andrade
@since   24/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Desp(aAponts)

Local cPath 	:= ""
Local aHeader	:= {}
Local oRequest	:= Nil
Local oResponse	:= Nil
Local cNumTkt	:= ""	
Local cError	:= ""
Local nAction	:= 0
Local nExpense	:= 0
Local nAppont	:= 0
Local nValEst	:= 0
Local nValPed	:= 0
Local aValues	:= Array(2)
Local aTickets	:= {}

aAdd(aHeader, "Content-Type: application/json")

// Evita consultar ticket em duplicidade
For nAppont := 1 To Len(aAponts)
	If aScan(aTickets, {|x| x == aAponts[nAppont][7]}) <= 0
		aAdd(aTickets, aAponts[nAppont][7])
	EndIf
Next nAppont

For nAppont := 1 To Len(aTickets)

	cNumTkt := aTickets[nAppont]
	cPath := "public/v1/tickets?token=" + cToken + "&id=" + cNumTkt
	oRequest  := FWRest():New(cEndPoint)
	oRequest:SetPath(cPath)
	
	If oRequest:Get(aHeader)
		FWJsonDeserialize(oRequest:GetResult(), @oResponse)
		
		For nAction := 1 To Len(oResponse:actions)
			For nExpense := 1 To Len(oResponse:actions[nAction]:expenses)
				If Lower(oResponse:actions[nAction]:expenses[nExpense]:type) == "estacionamento"
					nValEst += oResponse:actions[nAction]:expenses[nExpense]:value
				ElseIf Lower(oResponse:actions[nAction]:expenses[nExpense]:type) == "pedagio"
					nValPed += oResponse:actions[nAction]:expenses[nExpense]:value
				EndIf
			Next nExpense
		Next nAction
				
	Else
	    cError := oRequest:GetLastError()
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)
Next nAppont 

aValues[1] := nValEst
aValues[2] := nValPed

Return(aValues)

Static Function OS01GetNum()

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

Static Function OS01Resp(cChave)

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
