#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ALFAFIN01 � Autor �  Fabio Rogerio    � Data �  25/02/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Indices de Reajuste.						      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ALFAFIN01()

Local aCores := {}
Local aArea  := GetArea()

Private cCadastro	:= "Cadastro de Indices de Reajuste"

Private aRotina 	:= {	;
{"Pesquisar"	,"AxPesqui"  		,0,1},;
{"Visualizar"	,"AxVisual"  		,0,2},;
{"Incluir"		,"U_AFIncIndice"  	,0,3},;
{"Alterar"		,"U_AFAltIndice"  	,0,4},;
{"Legenda"		,"U_AFLegIndice"	,0,9 }}

Aadd( aCores, { " Z19_STATUS == '1' " , "BR_VERDE" } )
Aadd( aCores, { " Z19_STATUS <> '1' " , "BR_VERMELHO" } )

DbSelectArea("Z19")
DbSetOrder(1)   
DbGoTop()

mBrowse(6,1,22,75,"Z19",,,,,,aCores)

RestArea(aArea)

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    AFIncIndice  � Fabio Rogerio        � Data � 23/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Programa de Inclusao de Metas                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CALL CENTER                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AFIncIndice(cAlias,nReg,nOpc)

Local aArea := GetArea()
Local nOpcA := AxInclui(cAlias,nReg,nOpc)
Local cQuery:= ""

If (nOpcA == 1)
    cQuery:= "UPDATE " + RetSqlName("Z19") + " SET Z19_STATUS = '2' FROM " + RetSqlName("Z19") + " WHERE Z19_INDICE = '" + Z19->Z19_INDICE + "'"
    TcSqlExec(cQuery)

    RecLock("Z19",.F.)
    Replace Z19_STATUS With '1'
    MsUnLock()
EndIF

RestArea(aArea)

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    AFAltIndice  � Fabio Rogerio        � Data � 23/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Programa de Inclusao de Metas                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �CALL CENTER                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AFAltIndice(cAlias,nReg,nOpc)

Local aArea := GetArea()
Local nOpcA := AxAltera(cAlias,nReg,nOpc)


RestArea(aArea)

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  AFLegIndice � Autor �  Fabio Rogerio    � Data �  25/02/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Legenda.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AFLegIndice()

BrwLegenda(cCadastro,'Legenda',{{'BR_VERDE'	    ,'Indice Ativo' 	},;
                                {'BR_VERMELHO'  ,'Indice Inativo'	}})

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  IndiceReajuste � Autor �  Fabio Rogerio� Data �  25/02/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Legenda.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function IndiceReajuste(cIndice,cPeriodo)

Local aArea    := GetArea()
Local nIndice  := 0
Local cQuery   := ""
DEFAULT cIndice  := "IPCA"
DEFAULT cPeriodo := StrZero(Year(dDatabase),4)+StrZero(Month(dDatabase),2)

cQuery:= "SELECT Z19_PERC FROM " + RetSqlName("Z19") + " Z19 WHERE Z19.D_E_L_E_T_ = '' AND Z19.Z19_STATUS = '1' AND Z19.Z19_INDICE = '" + cIndice + "' AND Z19.Z19_PERIOD = '" + cPeriodo + "'"

If Select("TMPZ19") > 0
    TMPZ19->(DbCloseArea())
EndIf

TcQuery cQuery New Alias "TMPZ19"			 

While !TMPZ19->(Eof())
    nIndice:= TMPZ19->Z19_PERC
    TMPZ19->(DbSkip())
EndDo
TMPZ19->(DbCloseArea())    		

RestArea(aArea)
Return(nIndice)
