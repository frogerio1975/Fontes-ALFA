#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM01
Inclui ações na fila de integração com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM01(cAcao)

Local aAreaAtu := GetArea()
Local lRetorno := .T.
Local cMay     := "XTM"+ Alltrim(xFilial("XTM"))
Local cChave   := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
Local cSequen  := RetSeqTit(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)

// Verifica se já existe acao pendente de processamento para o título, se sim ignora.
If ExistXTM(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, cAcao)
    Return .T.
EndIf

While !MayIUseCode(cMay+cChave+cSequen)
    cSequen := SOMA1(cSequen)
EndDo

RecLock("XTM",.T.)
    REPLACE XTM_FILIAL  WITH xFilial("XTM")
    REPLACE XTM_PREFIX  WITH SE1->E1_PREFIXO
    REPLACE XTM_NUMTIT  WITH SE1->E1_NUM
    REPLACE XTM_PARCEL  WITH SE1->E1_PARCELA
    REPLACE XTM_TIPO    WITH SE1->E1_TIPO
    REPLACE XTM_CLIENT  WITH SE1->E1_CLIENTE
    REPLACE XTM_LOJA    WITH SE1->E1_LOJA
    REPLACE XTM_SEQUEN  WITH cSequen
    REPLACE XTM_ACAO    WITH cAcao
    REPLACE XTM_STATUS  WITH "1" // 1=Pendente
    REPLACE XTM_USER    WITH cUserName
    REPLACE XTM_DTINC   WITH DATE()
    REPLACE XTM_HRINC   WITH TIME()
    REPLACE XTM_EMPFAT  WITH SE1->E1_EMPFAT
MsUnlock()

FreeUsedCode()

RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSeqTit
Retorna próximo numero de sequencia de ação para um título.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSeqTit(cPrefix, cNumTit, cParcela, cTipo, cCodCli, cLojCli)

Local aAreaAtu := GetArea()
Local cSequen  := StrZero(0,TAMSX3("XTM_SEQUEN")[1])
Local cTMP1    := ""
Local cQuery   := ""

cQuery := " SELECT "+ CRLF
cQuery += "     ISNULL(MAX(XTM.XTM_SEQUEN),'"+cSequen+"') AS SEQTIT "+ CRLF
cQuery += " FROM "+RetSqlName("XTM")+" XTM (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     XTM.XTM_FILIAL = '"+xFilial("XTM")+"' "+ CRLF
cQuery += "     AND XTM.XTM_PREFIX = '"+cPrefix+"' "+ CRLF
cQuery += "     AND XTM.XTM_NUMTIT = '"+cNumTit+"' "+ CRLF
cQuery += "     AND XTM.XTM_PARCEL = '"+cParcela+"' "+ CRLF
cQuery += "     AND XTM.XTM_TIPO = '"+cTipo+"' "+ CRLF
cQuery += "     AND XTM.XTM_CLIENT = '"+cCodCli+"' "+ CRLF
cQuery += "     AND XTM.XTM_LOJA = '"+cLojCli+"' "+ CRLF
cQuery += "     AND XTM.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    cSequen := SOMA1((cTMP1)->SEQTIT)
EndIf

(cTMP1)->(DbCloseArea())

RestArea(aAreaAtu)

Return cSequen


//-------------------------------------------------------------------
/*/{Protheus.doc} ExistXTM
Verifica se já existe acao pendente de processamento para o título

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExistXTM(cPrefix, cNumTit, cParcela, cTipo, cCodCli, cLojCli, cAcao)

Local aAreaAtu := GetArea()
Local cTMP1    := ""
Local cQuery   := ""
Local lExistXTM:= .F.

cQuery := " SELECT "+ CRLF
cQuery += "     XTM.R_E_C_N_O_ AS XTMREC "+ CRLF
cQuery += " FROM "+RetSqlName("XTM")+" XTM (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     XTM.XTM_FILIAL = '"+xFilial("XTM")+"' "+ CRLF
cQuery += "     AND XTM.XTM_PREFIX = '"+cPrefix+"' "+ CRLF
cQuery += "     AND XTM.XTM_NUMTIT = '"+cNumTit+"' "+ CRLF
cQuery += "     AND XTM.XTM_PARCEL = '"+cParcela+"' "+ CRLF
cQuery += "     AND XTM.XTM_TIPO = '"+cTipo+"' "+ CRLF
cQuery += "     AND XTM.XTM_CLIENT = '"+cCodCli+"' "+ CRLF
cQuery += "     AND XTM.XTM_LOJA = '"+cLojCli+"' "+ CRLF
cQuery += "     AND XTM.XTM_ACAO = '"+cAcao+"' "+ CRLF
cQuery += "     AND XTM.XTM_STATUS = '1' "+ CRLF
cQuery += "     AND XTM.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())
    lExistXTM := .T.
EndIf

(cTMP1)->(DbCloseArea())

RestArea(aAreaAtu)

Return lExistXTM
