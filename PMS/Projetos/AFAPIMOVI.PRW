#Include "Protheus.ch"      
#Include "PrConst.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
           
#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4   
#Define CRLF	Chr(10)+Chr(13)

#DEFINE IDTKT 		1
#DEFINE TYPE		2
#DEFINE CATEGORY	3
#DEFINE CLOSEDIN	4
#DEFINE CREATEDAT	5
#DEFINE JUSTIFICA	6
#DEFINE LIFETIMEW	7
#DEFINE RESOLVEDI	8
#DEFINE STATUS		9
#DEFINE SUBJECT		10
#DEFINE URGENCY		11
#DEFINE TEAM		12
#DEFINE IDPAI		13
#DEFINE SUBJECTPAI	14

#DEFINE IDRESP		2
#DEFINE NAME		3
#DEFINE EMAIL		4

#DEFINE IDCLI		2

#DEFINE IDFIELD		2
#DEFINE IDRULE		3
#DEFINE LINE		4
#DEFINE VALUEFIELD	5
#DEFINE VALUEITEM	6

Static lJaExecutou 		:= .F.		   		// Usado na funcao SyOrdCab()
Static cToken    := "b49152ee-13b9-4fe2-a8dd-414679f5edc7"
Static cEndPoint := "https://api.movidesk.com/"
Static cMoviDesk := "S"
Static __lJob	 := .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFAPIMOVI ³ Autor ³   Fabio Rogerio       ³ Data ³ 02/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para Importacao de Dados do Movidesk        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AFAPIMOVI()

Local lRet		:= .F.
Local cError    := ""
Local lJob 		:= .F.

__lJob := lJob

If __lJob
	// Efetua a Leitura dos Projetos
	FWMsgRun(, { |oMsgRun| lRet := Projetos_Movidesk(@cError, oMsgRun) }, "Aguarde", "Consultando Projetos...")

	If lRet
		// Efetua a consulta dos apontamentos
		FWMsgRun(, { |oMsgRun| lRet := Apontamentos_Movidesk(@cError, oMsgRun) }, "Aguarde", "Consultando Apontamentos...")

		If !lRet
			Conout("Erro ao obter apontamentos: " + AllTrim(cError))
			LjWriteLog( cARQLOG, "Erro ao obter apontamentos: " + AllTrim(cError) )
		EndIf

	Else
		Conout("Erro ao obter projetos: " + AllTrim(cError))
		LjWriteLog( cARQLOG, "Erro ao obter projetos: " + AllTrim(cError) )
	EndIf

Else

	// Efetua a Leitura dos Projetos
	FWMsgRun(, { |oMsgRun| lRet := Projetos_Movidesk(@cError, oMsgRun) }, "Aguarde", "Consultando Projetos...")

	If lRet
		// Efetua a consulta dos apontamentos
		FWMsgRun(, { |oMsgRun| lRet := Apontamentos_Movidesk(@cError, oMsgRun) }, "Aguarde", "Consultando Apontamentos...")

		If !lRet
			Alert("Erro ao obter apontamentos: " + AllTrim(cError))
		EndIf

	Else
		Alert("Erro ao obter projetos: " + AllTrim(cError))
	EndIf
EndIf


Return(.T.)


Static Function Projetos_Movidesk(cError, oMsgRun)

Local cPath     := "public/v1/tickets?$select=id,subject,category,urgency,status,justification,createdDate,owner,resolvedIn,closedIn,lifetimeWorkingTime,ownerTeam"
Local oRequest  := Nil
Local oResponse	:= Nil
Local aHeader   := {}
Local lRet      := .F.
Local cEspaco	:= "%20"

aAdd(aHeader, "Content-Type: application/json")

//https://api.movidesk.com/public/v1/tickets?$select=id,subject,createdDate,category&token=b49152ee-13b9-4fe2-a8dd-414679f5edc7&$expand=owner,actions($select=origin,id),actions($expand=timeAppointments($expand=createdBy))&$filter=actions/any(a: a/timeAppointments/any(t: t/date gt 2022-10-04T00:00:00.00z and t/date le 2022-10-05T00:00:00.00z))
// Monta o path de consulta
cPath += "&token=b49152ee-13b9-4fe2-a8dd-414679f5edc7"
cPath += "&$expand=owner,clients,childrenTickets,parentTickets,customFieldValues,customFieldValues($expand=items)"
cPath += "&$filter=ownerTeam eq '95.Projetos ALFA'"
cPath += "&$orderby=category,id desc"

//Executa de 1000 em 1000 devido a limitacao da API

oRequest  := FWRest():New(cEndPoint)
oRequest:SetPath(StrTran(cPath, " ", cEspaco))

If oRequest:Get(aHeader)

	FWJsonDeserialize(oRequest:GetResult(), @oResponse)

	// Joga o resultado que está em um JSON para um Alias
	GravaTickets(oResponse,oMsgRun)
	lRet := .T.
Else
	cError := oRequest:GetLastError()
EndIf

FreeObj(oRequest)

Return(lRet)

Static Function GravaTickets(oResponse,oMsgRun)
Local nX		:= 0
Local nTicket   := 0
Local nCli      := 0
Local nItem     := 0
Local nField    := 0
Local cName		:= ""
Local cItem     := ""
Local dClosed   := Ctod("  /  /  ")
Local dCreate   := Ctod("  /  /  ")
Local dResolv   := Ctod("  /  /  ")


DbSelectArea("Z30")
DbSelectArea("Z31")
DbSelectArea("Z32")
DbSelectArea("Z33")

For nTicket:= 1 To Len(oResponse)
	cName:= SyAcento(oResponse[nTicket]:subject)

	If !__lJob
		oMsgRun:cCaption := "Projeto: " + Left(cName,20)
		ProcessMessage()
	Endif

	cTicket:= Padr(cValToChar(oResponse[nTicket]:id),10)

	DbSelectArea("Z30")
	DbSetOrder(1)

	If !dbSeek(xFilial("Z30")+cTIcket)
		Z30->(RecLock("Z30", .T.))
		Z30->Z30_FILIAL:= xFilial("Z30")
		Z30->Z30_IDTKT:= cTicket
	Else
		Z30->(RecLock("Z30", .F.))
	Endif

	if len(oResponse[nTicket]:childrenTickets) > 0
		Z30->Z30_TIPO := "P"
	else
		Z30->Z30_TIPO := "T"
	endif

	if ValType("oResponse[nTicket]:parentTickets") <> "U"
			if Len(oResponse[nTicket]:parentTickets) > 0
				Z30->Z30_IDPAI  := cValToChar(oResponse[nTicket]:parentTickets[1]:id)
				Z30->Z30_SUBJPA := SyAcento(oResponse[nTicket]:parentTickets[1]:subject)
			endif 
	endIf	
	
	If !Empty(oResponse[nTicket]:closedIn)
		dClosed:= Ctod(SubStr(oResponse[nTicket]:closedIn,9,2) + "/" + SubStr(oResponse[nTicket]:closedIn,6,2) + "/" + SubStr(oResponse[nTicket]:closedIn,1,4))
	Else
		dClosed:= Ctod("  /  /  ")	
	EndIf

	If !Empty(oResponse[nTicket]:createdDate)
		dCreate:= Ctod(SubStr(oResponse[nTicket]:createdDate,9,2) + "/" + SubStr(oResponse[nTicket]:createdDate,6,2) + "/" + SubStr(oResponse[nTicket]:createdDate,1,4))
	Else
		dCreate:= Ctod("  /  /  ")	
	EndIf 

	If !Empty(oResponse[nTicket]:resolvedIn)
		dResolv:= Ctod(SubStr(oResponse[nTicket]:resolvedIn,9,2) + "/" + SubStr(oResponse[nTicket]:resolvedIn,6,2) + "/" + SubStr(oResponse[nTicket]:resolvedIn,1,4))
	Else
		dResolv:= Ctod("  /  /  ")	
	EndIf	
	
	Z30->Z30_CATEGO := SyAcento(oResponse[nTicket]:category)
	Z30->Z30_CLOSED := dClosed
	Z30->Z30_CREATE := dCreate
	Z30->Z30_JUSTIF := SyAcento(oResponse[nTicket]:justification)
	Z30->Z30_LIFETI := oResponse[nTicket]:lifetimeWorkingTime
	Z30->Z30_RESOLV := dResolv
	Z30->Z30_STATUS := SyAcento(oResponse[nTicket]:status)
	Z30->Z30_SUBJEC := SyAcento(oResponse[nTicket]:subject)
	Z30->Z30_URGENC := SyAcento(oResponse[nTicket]:urgency)
	Z30->Z30_TEAM   := SyAcento(oResponse[nTicket]:ownerTeam)

	Z30->Z30_IDRESP  := oResponse[nTicket]:owner:id
	Z30->Z30_NOMERE  := SyAcento(oResponse[nTicket]:owner:businessname)
	Z30->Z30_MAILRE  := SyAcento(oResponse[nTicket]:owner:email)

	Z30->Z30_IDCLI   := oResponse[nTicket]:clients[1]:id
	Z30->Z30_CLIENT  := SyAcento(oResponse[nTicket]:clients[1]:businessname)
	Z30->Z30_MAILCL  := SyAcento(oResponse[nTicket]:clients[1]:email)

	Z30->(MsUnlock())

	For nCli:= 1 To Len(oResponse[nTicket]:clients)
		cCli:= Padr(oResponse[nTicket]:clients[nCli]:id,10)
		DbSelectArea("Z32")
		DbSetOrder(1)
		If dbseek(xFilial("Z32")+cTicket+cCli)
			RecLock("Z32", .F.)
		else
			RecLock("Z32", .T.)
			Z32->Z32_FILIAL := xFilial("Z32")
			Z32->Z32_IDCLIE := cCli							
			Z32->Z32_IDTICK := cTicket
		ENDIF	

		Z32->Z32_NOME := SyAcento(oResponse[nTicket]:clients[nCli]:businessname)
		Z32->Z32_EMAIL:= SyAcento(oResponse[nTicket]:clients[nCli]:email)
		MsUnlock()
	Next nCli

	For nField:= 1 To Len(oResponse[nTicket]:customFieldValues)
		nItem:= Len(oResponse[nTicket]:customFieldValues[nField]:items)
		nItem:= IIF(nItem == 0,1,nItem)

		cField:= Padr(cValToChar(oResponse[nTicket]:customFieldValues[nField]:customFieldId),10)
		cRule := Padr(oResponse[nTicket]:customFieldValues[nField]:customFieldRuleId,10)

		For nX:= 1 to nItem
			DbSelectArea("Z33")
			DbSetOrder(1)
			If dbseek(xFilial("Z33")+cTicket+cField+cRule)
				RecLock("Z33", .F.)
			else
				RecLock("Z33", .T.)
				Z33->Z33_FILIAL := xFilial("Z33")
				Z33->Z33_IDTICK := cTicket
				Z33->Z33_IDFIEL := cField
				Z33->Z33_IDRULE := cRule
			ENDIF	

			Z33->Z33_LINHA := cValToChar(oResponse[nTicket]:customFieldValues[nField]:line)
			Z33->Z33_VALOR := SyAcento(oResponse[nTicket]:customFieldValues[nField]:value)
			
			If nItem > 1
				Z33->Z33_VALORI:= SyAcento(oResponse[nTicket]:customFieldValues[nField]:items[nItem]:customFieldItem)
			EndIf	
			MsUnlock()
		Next nX
	Next nField
Next nTicket

Return

Static Function Apontamentos_Movidesk(cError, oMsgRun)

Local cPath     := "public/v1/tickets?$select=id,subject,status,resolvedIn,closedIn,lifetimeWorkingTime"
Local oRequest  := Nil
Local oResponse	:= Nil
Local aHeader   := {}
Local lRet      := .F.
Local cEspaco	:= "%20"

aAdd(aHeader, "Content-Type: application/json")

//https://api.movidesk.com/public/v1/tickets?$select=id,subject,createdDate,category&token=b49152ee-13b9-4fe2-a8dd-414679f5edc7&$expand=owner,actions($select=origin,id),actions($expand=timeAppointments($expand=createdBy))&$filter=actions/any(a: a/timeAppointments/any(t: t/date gt 2022-10-04T00:00:00.00z and t/date le 2022-10-05T00:00:00.00z))
// Monta o path de consulta
cPath += "&token=b49152ee-13b9-4fe2-a8dd-414679f5edc7"
cPath += "&$expand=actions($select=origin,id),actions($expand=timeAppointments($expand=createdBy))"
cPath += "&$filter=ownerTeam eq '95.Projetos ALFA' and actions/any(a: a/timeAppointments/any(t: t/date gt 2002-01-01T00:00:00.00z and t/date le 2050-12-31T00:00:00.00z))"
cPath += "&$orderby=id desc"

//Executa de 1000 em 1000 devido a limitacao da API

oRequest  := FWRest():New(cEndPoint)
oRequest:SetPath(StrTran(cPath, " ", cEspaco))

If oRequest:Get(aHeader)

	FWJsonDeserialize(oRequest:GetResult(), @oResponse)

	// Joga o resultado que está em um JSON para um Alias
	GravaApontamentos(oResponse,oMsgRun)
	lRet := .T.
Else
	cError := oRequest:GetLastError()
EndIf

FreeObj(oRequest)

Return(lRet)

Static Function GravaApontamentos(oResponse,oMsgRun)
Local nX		:= 0
Local nTicket   := 0
Local nAponta   := 0
Local cName		:= ""
Local cItem     := ""
Local dClosed   := Ctod("  /  /  ")
Local dCreate   := Ctod("  /  /  ")
Local dResolv   := Ctod("  /  /  ")
Local dAponta   := Ctod("  /  /  ")

DbSelectArea("Z34")

For nTicket:= 1 To Len(oResponse)
	cName:= SyAcento(oResponse[nTicket]:subject)

	If !__lJob
		oMsgRun:cCaption := "Apontamentos Projeto: " + Left(cName,20)
		ProcessMessage()
	Endif

	For nAponta:= 1 To Lne(oResponse[nTicket]:timeAppointments)
		cTicket:= Padr(cValToChar(oResponse[nTicket]:id),10)
		cAponta:= Padr(cValToChar(oResponse[nTicket]:timeAppointments[nAponta]:id),10)

		DbSelectArea("Z34")
		DbSetOrder(1)

		If !dbSeek(xFilial("Z34")+cTicket+cAponta)
			Z34->(RecLock("Z34", .T.))
			Z34->Z34_FILIAL:= xFilial("Z30")
			Z34->Z34_IDTKT:= cTicket
			Z34->Z34_IDACT:= cAponta
		Else
			Z34->(RecLock("Z34", .F.))
		Endif

		If !Empty(oResponse[nTicket]:timeAppointments[nAponta]:date)
			dAponta:= Ctod(SubStr(oResponse[nTicket]:timeAppointments[nAponta]:date,9,2) + "/" + SubStr(oResponse[nTicket]:timeAppointments[nAponta]:date,6,2) + "/" + SubStr(oResponse[nTicket]:timeAppointments[nAponta]:date,1,4))
		Else
			dAponta:= Ctod("  /  /  ")	
		EndIf

		If !Empty(oResponse[nTicket]:closedIn)
			dClosed:= Ctod(SubStr(oResponse[nTicket]:closedIn,9,2) + "/" + SubStr(oResponse[nTicket]:closedIn,6,2) + "/" + SubStr(oResponse[nTicket]:closedIn,1,4))
		Else
			dClosed:= Ctod("  /  /  ")	
		EndIf

		If !Empty(oResponse[nTicket]:createdDate)
			dCreate:= Ctod(SubStr(oResponse[nTicket]:createdDate,9,2) + "/" + SubStr(oResponse[nTicket]:createdDate,6,2) + "/" + SubStr(oResponse[nTicket]:createdDate,1,4))
		Else
			dCreate:= Ctod("  /  /  ")	
		EndIf 

		If !Empty(oResponse[nTicket]:resolvedIn)
			dResolv:= Ctod(SubStr(oResponse[nTicket]:resolvedIn,9,2) + "/" + SubStr(oResponse[nTicket]:resolvedIn,6,2) + "/" + SubStr(oResponse[nTicket]:resolvedIn,1,4))
		Else
			dResolv:= Ctod("  /  /  ")	
		EndIf	
		
		Z34->Z34_DATA   := dAponta
		Z34->Z34_INICIO := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:periodstart)
		Z34->Z34_FIM    := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:periodend)
		Z34->Z34_WORKTI := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:worktime)
		Z34->Z34_ATIVIV := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:activity)
		Z34->Z34_RECURSO:= SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:createdby:email)
		Z34->Z34_NOME   := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:createdby:businessname)
		Z34->Z34_EMAIL  := SyAcento(oResponse[nTicket]:timeAppointments[nAponta]:createdby:email)
		Z34->Z34_HRUTIL := oResponse[nTicket]:timeAppointments[nAponta]:accountedtime
		
//		MSMEMO()
	Next nAponta
Next nTicket

Return

Static Function SyAcento( cString ) 
Local cAux := ""
Default cString:= ""

cAux:= DecodeUTF8(cString)

Return cAux
