#Include "FWBROWSE.CH"
#Include "PROTHEUS.CH"

#DEFINE HCONSUMED 	 1
#DEFINE HCONTRACTED  2

Static cToken    := "448f8647-50cb-47e2-995c-b2bbe474486a"
Static cEndPoint := "https://api.movidesk.com/"
Static cMoviDesk := "S"
Static __lJob	 := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFAOS03
Rotina para gerar Ordem de Serviço de acordo com o portal
@author  Lucas Oliveira
@since   10/03/2021
@version 1
/*/
//-------------------------------------------------------------------
User Function ALFAOS03(lJob)

	Local lHasContract		:= .F.
	Local cError        	:= ""
	Local cAliasContract	:= ""
	Local oTempDB			:= Nil
	Local aParamBox			:= {}
	Local aRetParam			:= {}

	Private dPerIni  := FirstDay(DATE())
	Private dPerFim  := LastDay(DATE())

	Default lJob := .F.

	__lJob := lJob

	aAdd( aParamBox, { 1, "Data Inicial", dPerIni, "", ".T.", "", "", 50, .F.} )
	aAdd( aParamBox, { 1, "Data Final"	, dPerFim, "", ".T.", "", "", 50, .F.} )

	If ParamBox(aParamBox, "Filtros", @aRetParam)

		dPerIni := aRetParam[1]
		dPerFim := aRetParam[2]

		OS03recService()

	EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Agreements
Efetua a consulta dos contratos de horas
@author  Lucas Oliveira
@since   10/03/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS03recService()

	Local aArea := GetArea()
	Local aAreaSZ2 := SZ2->(GetArea())
	Local aAreaSZ3 := SZ3->(GetArea())

	Local cQuery := ""
	Local cAliasQry := GetNextAlias()

	Local cCliente := ""
	Local cLoja  := ""
	Local cRevProj  := ""
	Local cTpHora  := ""
	Local cCoord  := ""
	Local cAprov  := ""
	Local cTpServ  := ""
	Local cNumOS := ""
	Local cItemProj := ""
	Local aValDesp := {0,0}
	Local nTamItem	:= TamSX3("Z3_ITEM")[1]

	Local cAuxDtIni := ""
	Local cAuxDtFim := ""

	cQuery := "SELECT "+CRLF
	cQuery += "		w.Id ID "+CRLF
	cQuery += "		,w.Value HOURS "+CRLF
	cQuery += "		,P.Code CODE "+CRLF
	cQuery += "		,CONVERT(DATE,t.DateTask) DATEINC "+CRLF
	cQuery += "		,C.CNPJ "+CRLF
	cQuery += "		,C.CustomerCode CLIENTE "+CRLF
	cQuery += "		,t.Description DESCRI "+CRLF
	cQuery += "		,t.ServiceType TPATEND "+CRLF
	cQuery += "		,U.Email EMAIL "+CRLF
	cQuery += "	FROM ALFA_PORTAL.dbo.WorkFlow w "+CRLF
	cQuery += "	INNER JOIN ALFA_PORTAL.dbo.TasksHistory t "+CRLF
	cQuery += "		on t.Id = w.IdType "+CRLF
	cQuery += "	INNER JOIN ALFA_PORTAL.dbo.Projects P "+CRLF
	cQuery += "		on P.Id = w.ProjectId "+CRLF
	cQuery += "	INNER JOIN ALFA_PORTAL.dbo.Customers C "+CRLF
	cQuery += "		ON P.CustomerId = C.Id "+CRLF
	cQuery += "	INNER JOIN ALFA_PORTAL.dbo.Users U "+CRLF
	cQuery += "		ON U.Id = w.UserId "+CRLF
	cQuery += "	WHERE w.Type = 'T' "+CRLF
	cQuery += "		and w.Status = 'Y' "+CRLF
	cAuxDtIni := substr(DtoS(dPerIni),1,4)+"-"+substr(DtoS(dPerIni),5,2)+"-"+substr(DtoS(dPerIni),7,2)
	cAuxDtFim := substr(DtoS(dPerFim),1,4)+"-"+substr(DtoS(dPerFim),5,2)+"-"+substr(DtoS(dPerFim),7,2)
	cQuery += "		and t.DateTask between '"+cAuxDtIni+"' and '"+cAuxDtFim+"' "+CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())

		Do While (cAliasQry)->(!Eof())

			Begin Transaction

				If OS01Cli((cAliasQry)->CODE, @cCliente, @cLoja, @cRevProj, @cTpHora, @cCoord, @cAprov, @cTpServ)

					cNumOS := OS01GetNum()

					cItemProj := OS01Item((cAliasQry)->CODE, cRevProj)

					cRecurso := OS01Rec(AllTrim((cAliasQry)->EMAIL))


					SZ2->(RecLock("SZ2", .T.))
					SZ2->Z2_FILIAL 	:= xFilial("SZ2")
					SZ2->Z2_OS		:= cNumOS
					SZ2->Z2_DATA	:= (cAliasQry)->DATEINC
					SZ2->Z2_RECURSO	:= cRecurso
					SZ2->Z2_CLIENTE	:= cCliente
					SZ2->Z2_LOJA	:= cLoja
					SZ2->Z2_HRINI1	:= "08:00"
					SZ2->Z2_HRFIM1	:= "17:00"
					SZ2->Z2_TOTALHR	:= S03Hours((cAliasQry)->HOURS)
					SZ2->Z2_STATUS	:= "2"
					SZ2->Z2_DATAINC	:= (cAliasQry)->DATEINC
					SZ2->Z2_DTENCER	:= (cAliasQry)->DATEINC
					SZ2->Z2_COORD   := cCoord
					SZ2->Z2_CODRESP := OS01Resp(cCliente+cLoja)
					SZ2->Z2_TRANSLA	:= "00:00"
					SZ2->Z2_ESTAC	:= aValDesp[1]
					SZ2->Z2_PEDAGIO	:= aValDesp[2]
					SZ2->Z2_TPATEND	:= IIF((cAliasQry)->TPATEND=='1',"2",IIF((cAliasQry)->TPATEND=='2',"1","3")) // 1=Presencial Cliente ou 2=Remoto
					SZ2->Z2_CODSER	:= cTpServ
					SZ2->Z2_MOVDESK	:= "P"
					SZ2->Z2_IDPORTA := (cAliasQry)->ID
					SZ2->(MsUnlock())

					cItemOS	:= strzero(1,nTamItem)
					SZ3->(RecLock("SZ3", .T.))
					SZ3->Z3_FILIAL	:= xFilial("SZ3")
					SZ3->Z3_OS		:= cNumOS
					SZ3->Z3_ITEM	:= cItemOS
					SZ3->Z3_PROJETO	:= (cAliasQry)->CODE
					SZ3->Z3_REVISA	:= cRevProj
					SZ3->Z3_TAREFA	:= cItemProj
					SZ3->Z3_HORAS	:= S03Hours((cAliasQry)->HOURS)
					SZ3->Z3_HUTEIS	:= (cAliasQry)->HOURS
					SZ3->Z3_STATUS	:= "2"
					SZ3->Z3_TEXTO	:= (cAliasQry)->DESCRI
					SZ3->Z3_TPHORA	:= cTpHora
					SZ3->Z3_CODSER	:= cTpServ
					SZ3->(MsUnlock())

					cQry:="UPDATE ALFA_PORTAL.dbo.WorkFlow SET Status = 'I' WHERE Id = "+allTrim(str((cAliasQry)->ID))
					If TcSqlExec(cQry)
						Alert("Erro a atualizar o dado no portal, Verifique com administrador!")

						DisarmTransaction()
					EndiF

				EndIf

			End Transaction
			(cAliasQry)->(DbSkip())
		EndDo

	EndIf

	RestArea(aAreaSZ3)
	RestArea(aAreaSZ2)
	RestArea(aArea)
Return
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
//-------------------------------------------------------------------
/*/{Protheus.doc} OS01Item
Retorna o item do projeto
@author  Victor Andrade
@since   22/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Item(cCodProj,CREVPROJ)

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
	AND AF9_REVISA = %exp:CREVPROJ%
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
/*/{Protheus.doc} OS01Rec
Retorna o código do recurso de acordo com o e-mail 
@author  Victor Andrade
@since   19/10/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function OS01Rec(CEMAIL)

	Local cAliasEmail	:= "ALIASEMAIL"
	Local cCodRec		:= ""
	Local aArea			:= GetArea()

	If Select(cAliasEmail) > 0
		(cAliasEmail)->(dbCloseArea())
	EndIf

	BeginSQL Alias cAliasEmail
	SELECT AE8_RECURS FROM %table:AE8%
	WHERE AE8_EMAIL = %exp:CEMAIL%
	AND AE8_ATIVO = '1'
	AND %notdel%
	EndSQL

	If (cAliasEmail)->(!Eof())
		cCodRec := (cAliasEmail)->AE8_RECURS
	EndIf

	(cAliasEmail)->(dbCloseArea())

	RestArea(aArea)

Return(cCodRec)

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

static Function S03Hours( nHours)

	Local cRet := "00:00"

	Default nHours := 0

	If nHours > 0

		nAuxHour := Round(nHours,0)
		nAuxMinu := nHours-nAuxHour

		cRet:= strzero(nAuxHour,2)+":"+ strzero(Round(nAuxMinu*60,-1 ),2)

	EndIf

Return cRet
