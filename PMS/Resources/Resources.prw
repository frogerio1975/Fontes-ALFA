#include "protheus.ch"


User Function Resources
Local aSize    := MsAdvSize()
Local aResource:= {}
Local nI       := 0 
Local nImg     := 0
Local nLin     := 0
Local aParamBox:= {}
Local aRetParam:= {}
 
Aadd(aParamBox,{1,"Tipo Arquivo", Space(100)  , ""   , "", "", "", 50 , .F.})
IF !ParamBox(aParamBox,"Informe os Dados para Filtro",@aRetParam)
	Return
Endif
 
 
aResource := GetResArray(aRetParam[1])
aBtn      := Len(aResource)

DEFINE MSDIALOG oTela FROM 0,0 TO aSize[6],aSize[5] TITLE "Dashboard de Projetos" Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

nCol:= 10
nLin:= 20
For nI:= 1 To Len(aResource)   

	If (nImg == 10)
		nLin+= 50
		nCol:= 10
	EndIf

    cImg := GetApoRes(aResource[nI])
	aBtn[nI] := TBtnBmp2():New( nLin, nCol, 40, 40,cImg,,,,{||Alert(aResource[nI])},oTela,,,.T. )

Next nI


ACTIVATE MSDIALOG oTela ON INIT ( EnchoiceBar(	oTela,;
												{|| oTela:End()  },;
												{|| oTela:End() }) ) CENTERED


Return