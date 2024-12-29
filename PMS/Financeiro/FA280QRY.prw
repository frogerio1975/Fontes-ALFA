#Include "Protheus.ch"

/*  
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Programa  �FA280QRY � Autor �  Alexandro Dias    � Data �  02/05/20   ���
������������������������������������������������������������������������͹��
���Desc.     � Filtra da rotina de FATURAS a RECEBER                     ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������

*/

User Function FA280QRY()

Local aParamBox	:= {}
Local aRet		:= {}
Local cFiltro
Local cPar1Orig := MV_PAR01
Local cPar2Orig := MV_PAR02

aAdd(aParamBox,{1,"Do Vencimento?" 	,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
aAdd(aParamBox,{1,"At� Vencimento?"	,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data

IF ParamBox(aParamBox,"Filtros...",@aRet)

	cFiltro := " E1_VENCREA >= '" +Dtos(MV_PAR01) + "' AND E1_VENCREA <= '" + Dtos(MV_PAR02) + "'"
	
	Alert(cFiltro)

EndIF

MV_PAR01 := cPar1Orig
MV_PAR02 := cPar2Orig

Return(cFiltro)