#Include 'protheus.ch'
#Include 'parmtype.ch'

/*/{Protheus.doc} ALFAOSR1
Impressão do log de conferêcia
@author Victor Andrade
@since 20/10/2019
@version undefined
@type function
/*/
User Function ALFAOSR1(aLog)

Private oReport := Nil
Private aErros	:= aLog

If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel		
	oReport := ReportDef()
	oReport:PrintDialog()		
EndIf

Return

/*/{Protheus.doc} ReportDef
Definicao do Report
@author Victor Andrade
@since 20/10/2019
/*/
Static Function ReportDef()

oReport := TReport():New("ALFAOSR1","Log de Processamento", "", {|oReport| ReportPrint(oReport)},"Log de Atualização de registros")

oReport:HideParamPage()
oReport:HideHeader()
oReport:HideFooter()
oReport:SetDevice(4) 			// Planilha Excel
oReport:SetEnvironment(2)		// Local
oReport:SetPortrait()

oSection1:= TRSection():New(oReport,OemToAnsi("Log de Processamento"),)

TRCell():New(oSection1,"DESCR"  ,/*Tabela*/,"Descrição" ,,150 ,,{|| cDescr },,,,,,.F.)

oSection1:SetLeftMargin(14)

Return oReport

/*/{Protheus.doc} ReportPrint
Impressão do log
@author Victor Andrade
@since 20/10/2019
@type function
/*/
Static Function ReportPrint(oReport)

Local nX := 0

For nX:= 1 To Len(aErros)
	
	oReport:Section(1):Init()
	oReport:IncMeter()
    
    cDescr := AllTrim(aErros[nX])
   
	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:Section(1):PrintLine()
	
Next nX

oReport:Section(1):Finish()

Return