#Include "Protheus.ch"

#DEFINE		LOK				1
#DEFINE		ATUALIZADO		2
#DEFINE		ULTFAT			3
#DEFINE		CODIGO			4
#DEFINE		RAZAO			5
#DEFINE		FANTASIA		6
#DEFINE		FATTOTAL		7
#DEFINE		CONSULTORATU	8
#DEFINE		CONSULTORNEW	9
#DEFINE		COORDENADORATU	10
#DEFINE		COORDENADORNEW	11
#DEFINE		PERCREAJUSTE	12
#DEFINE		ULTREAJUSTE		13
#DEFINE		IMPOSTOS		14

#DEFINE		TIT_LOK			1
#DEFINE		TIT_ATU  		2
#DEFINE		TIT_CODIGO		3
#DEFINE		TIT_RAZAO		4
#DEFINE		TIT_CONTRATO	5
#DEFINE		TIT_ADITIVO		6
#DEFINE		TIT_PREFIXO		7
#DEFINE		TIT_NUM			8
#DEFINE		TIT_PARCELA		9
#DEFINE		TIT_TIPO		10
#DEFINE		TIT_VENCREA		11
#DEFINE		TIT_VALORANT	12
#DEFINE		TIT_PERC		13
#DEFINE		TIT_ACRESCIMO	14
#DEFINE		TIT_VALORNEW	15
#DEFINE		TIT_DTREAJ		16
#DEFINE		TIT_HISTORICO	17
#DEFINE		TIT_NATUREZA	18
#DEFINE		TIT_INDICE	    19

#DEFINE		MNT_LOK				1
#DEFINE	    MNT_ATUALIZADO		2
#DEFINE		MNT_ULTREAJ			3
#DEFINE		MNT_CODIGO			4
#DEFINE		MNT_NOME			5
#DEFINE		MNT_PROPOSTA		6
#DEFINE		MNT_ADITIVO			7
#DEFINE		MNT_HISTORICO		8
#DEFINE		MNT_INDICE			9
#DEFINE		MNT_PERCREAJUSTE	10
#DEFINE		MNT_FATOR			11
#DEFINE		MNT_VLRMANUTATU		12
#DEFINE		MNT_VLRMANUTNEW		13

#DEFINE		RJ_PERIODO	1
#DEFINE		RJ_INDICE	2
#DEFINE		RJ_PERC		3
#DEFINE		RJ_FATOR	4
#DEFINE		RJ_CONATUAL	5
#DEFINE		RJ_CORATUAL	6
#DEFINE		RJ_CONANT	7
#DEFINE		RJ_CORANT	8
#DEFINE		RJ_DATA		9

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออัอออออออัอออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjustaContratos  ณAutor  ณ Fabio Rogerio   ณ Data ณ  15/03/23   บฑฑ
ฑฑฬออออออออออุอออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ajusta os Contratos                            			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AjustaContratos()

	Processa( {|lEnd| AjustaZ02() } , "Atualizando Contratos" )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัอออออออออออออออออัออออออัออออออออออออปฑฑ
ฑฑบPrograma  AjustaZ02 Auto  ณ Fabio Rogerio   ณ Data ณ  15/03/23  บฑฑ
ฑฑฬออออออออออุออออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ AjustaZ02.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function AjustaZ02()
Local aArea   := GetArea()
Local cQuery  := ""
Local cCliente:= ""
Local cLoja   := ""
Local cPropos := ""
Local cAditivo:= ""
Local cContrato:= ""

cQuery:= " SELECT * FROM " + RetSqlName("Z02") + " Z02 "
cQuery+= " WHERE Z02.D_E_L_E_T_ = '' "
cQuery+= " AND Z02.Z02_TIPO IN ('3','4')"
cQuery+= " AND Z02.Z02_STATUS IN ('5','9')"
cQuery+= " AND Z02.Z02_CLIENT <> ''"
cQuery+= " ORDER BY Z02.Z02_CLIENT,Z02.Z02_LOJA,Z02.Z02_PROPOS,Z02.Z02_ADITIV"
cQuery:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)

DbSelectArea("TRB")
DbGoTop()
While !Eof()
	If (TRB->Z02_CLIENT+TRB->Z02_LOJA <> cCliente+cLoja)
		cCliente:= TRB->Z02_CLIENT
		cLoja   := TRB->Z02_LOJA
		cPropos := TRB->Z02_PROPOS
		cAditivo:= "00"

		cPropAnt:= TRB->Z02_PROPOS 
		cAdtAnt := TRB->Z02_ADITIV

//		cContrato:= CriaContrato(cCliente,cLoja,cPropos,cAditivo)

	Else
		cPropAnt:= TRB->Z02_PROPOS 
		cAdtAnt := TRB->Z02_ADITIV
		cAditivo:= Soma1(cAditivo,2)	

	EndIf

	aAreaTRB:= TRB->(GetArea())

	//Atualiza a numeracao de contrato
	dbSelectArea("Z02")
	dbSetOrder(1)
	If dbSeek(xFilial("Z02")+cPropAnt+cAdtAnt)
		RecLock("Z02",.F.)
		Replace Z02_PROPOS With cPropos
		Replace Z02_ADITIV With cAditivo
		MsUnLock()

		AtualizaZ03(cPropAnt,cAdtAnt,cPropos,cAditivo)
		AtualizaZ04(cPropAnt,cAdtAnt,cPropos,cAditivo)
		AtualizaZ05(cPropAnt,cAdtAnt,cPropos,cAditivo)
		AtualizaZ08(cPropAnt,cAdtAnt,cPropos,cAditivo)
	EndIf
	TRB->(RestArea(aAreaTRB))

	TRB->DbSkip()
EndDo
TRB->(DbCloseArea())

RestArea(aArea)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออัอออออออัอออออออออออออออออัออออออัออออออออออออปฑฑ
ฑฑบPrograma  CriaContrato Auto  ณ Fabio Rogerio   ณ Data ณ  15/03/23  บฑฑ
ฑฑฬออออออออออุออออออออออออออฯอออออออฯอออออออออออออออออฯออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Cria o contrato por Parceiro x Cliente.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function CriaContrato(cCliente,cLoja,cPropos,cAditivo)
Local aArea   := GetArea()
Local cQuery  := ""
Local cContrato:= ""
Local cParceiro:= ""

cQuery:= " SELECT * FROM " + RetSqlName("Z05") + " Z05 "
cQuery+= " INNER JOIN " + RetSqlName("Z00") + " Z00 ON Z00.D_E_L_E_T_ = '' AND Z00.Z00_MODULO = Z05.Z05_MODULO "
cQuery+= " WHERE Z05.D_E_L_E_T_ = '' "
cQuery+= " AND Z05.Z05_PROPOS ='" + cPropos + "' "
cQuery+= " AND Z05.Z05_ADITIV ='" + cAditivo + "' "
cQuery+= " ORDER BY Z00.Z00_FORNEC,Z00.Z00_MODULO "
cQuery:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB2",.F.,.T.)

DbSelectArea("TRB2")
DbGoTop()
While !Eof()
	If (TRB2->Z00_FORNEC <> cParceiro)
		cParceiro:= TRB2->Z00_FORNEC

		dbSelectArea("Z25")
		dbSetOrder(1)
		If !dbSeek(xFilial("Z25")+cPropos+cAditivo+cParceiro)
			RecLock("Z25",.T.)
			Replace Z25_FILIAL With Xfilial("Z25")
			Replace Z25_PROPOS With cPropos
			Replace Z25_ADITIV With cAditivo
			Replace Z25_FORNEC With cParceiro
			Replace Z25_CLIENT With cCliente
			MsUnLock()
		EndIf
		cContrato:= Z25->Z25_CONTRA
	ENDIF

	TRB2->DBSKIP()
END
TRB2->DBCLOSEAREA(  )

Return(cContrato)
