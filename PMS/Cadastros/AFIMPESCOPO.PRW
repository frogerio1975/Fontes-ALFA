#Include "Protheus.ch"
#Include "Protheus.ch"      
#Include "PrConst.ch"
#Include "MsmGadd.ch"     
#Include "Ap5Mail.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} AFIMPESCOPO
Rotina para realizar a importacao do escopo dos modulo para utilizacao na proposta através da importacao de arquivo CSV
@type function
@version 1.0
@author Fábio Rogério
@since 29/03/2021
/*/
User Function AFIMPESCOPO()
Local cPath   := getTempPath()
Local aFiles  := {}
Local cTipo   := ""
Local cFileZ00:= ""
Local cFileZ01:= ""

cPath:= cGetFile( '*.csv|*.csv' , 'Arquivos de Escopo (CSV)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
aFiles:= Directory( cPath + '*.CSV')

If Len(aFiles) == 0
	Aviso("Atencao","Nao existem arquivos de escopo para importacao.",{"Ok"})
	Return(.F.)
EndIf

//Valida a nomenclatura e estrutura do arquivo
For nX := 1 To Len(aFiles)
	//Valida a estrutura do arquivo se está de acordo com a tabela
	IF ValidaEstrutura(cPath+aFiles[nX,1],@cTipo)
		If (cTipo == "1")
			cFileZ00:= cPath+aFiles[nX,1]
		ElseIf(cTipo == "2")
			cFileZ01:= cPath+aFiles[nX,1]
		EndIf	
	Else	
		Aviso("Atencao", "O arquivo de Escopo " + aFiles[nX,1] + " nao tem a estrutura correta! Verifique a estrutura do arquivo.",{"Ok"})
		Return(.F.)
	EndIf
Next

//Nao deixa importar se estiver faltando um dos arquivos.
If Empty(cFileZ00) .Or. Empty(cFileZ01)
	Aviso("Atencao","Arquivos não são validos para a importacao. Esta faltando o arquivo de cabecalho ou o arquivo de itens de escopo.",{"Ok"})
	Return(.F.)
EndIf

//Faz backup da tabela
BackupArquivo(cFileZ00,cFileZ01)

//Processa a importacao dos dados
Processa( {|| ImportaEscopo(cFileZ00,cFileZ01) } , "Processando Importacao de Escopos..." )

Return(.T.)

/*/{Protheus.doc} ValidaEstrutura
Rotina para validar a estrutura do arquivo que será importado
@type function
@version 1.0
@author Fábio Rogério
@since 29/03/2021
@param cFile, character, caminho e nome do arquivo para a importacao
@return lógico, retorna se a estrutura está validada ou nao
/*/
Static Function ValidaEstrutura(cFile,cTipo)

Local nHandle  := FT_FUSE(cFile)
Local cBuffer  := ''
Local nI       := 0
Local oStruZ00 := FwFormStruct( 1, "Z00")
Local oStruZ01 := FwFormStruct( 1, "Z01")
Local aStruArq := {}
Local nPos     := 0
Local nFile    := 0

FT_FGOTOP()
ProcRegua(FT_FLASTREC())

While ! FT_FEOF()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura da linha do arquivo texto.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBuffer	:= TrataCaracter(FT_FREADLN())
	//cBuffer := SubStr(cBuffer,4,Len(cBuffer))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Interrompe o laco pois deseja verificar apenas validar a estrutura
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	Exit

EndDo

FClose(nHandle)

aStruArq:= Separa(cBuffer,";")

For nI:= 1 To Len(aStruArq)
	If !Empty(aStruArq[nI])
		nPos:= aScan(oStruZ00:aFields,{|x| x[3] == aStruArq[nI]})
		cTipo:= "1" //Z00

		//Se nao existir o item na estrutura aborta o processo
		If (nPos == 0)
			cTipo:= "2" //Z01
			nPos:= aScan(oStruZ01:aFields,{|x| x[3] == aStruArq[nI]})
			If (nPos == 0)
				Return(.F.)
			EndIf
		EndIf
	EndIf
Next nI

Return(.T.)

/*/{Protheus.doc} BackupArquivo
Realiza o backup dos arquivos de escopo (Z00/Z01/Z17/Z18)
@type function
@version 1.0
@author Fábio Rogério
@since 30/03/2021
@param nOpcao, numeric, opcao de backup
/*/
Static Function BackupArquivo()
Local aTabelas := { {"Z00",RetSqlName("Z00")},;
					{"Z01",RetSqlName("Z01")},;
					{"Z17",RetSqlName("Z17")},;
					{"Z18",RetSqlName("Z18")}}
Local cPathDest:= "C:\TEMP\BACKUP_PROTHEUS\"
Local nX       := 0
Local cArqXls  := ""

MakeDir(cPathDest)

For nX:= 1 To Len(aTabelas)

	cArqXls:= aTabelas[nX,2] + "_" + Dtos(dDatabase) + "_" + Substr(Time(),1,2) + Substr(Time(),4,2) + ".xls"
    
	//Copiando tabela para o arquivo Excel
    DbSelectArea(aTabelas[nX,1])
    //Copy To &("\system\"+cArqXls)
    ExpExcel("\system\"+cArqXls)

    //Copia o arquivo para a máquina
    __CopyFile("\system\"+cArqXls, cPathDest + cArqXls)
Next nX

Return()

/*/{Protheus.doc} ImportaEscopo
Rotina para a importacao das tabelas de Escopos
@type function
@version 1.0
@author Fábio Rogério
@since 30/03/2021
@param cFile, character, param_description
/*/
Static Function ImportaEscopo(cFileZ00,cFileZ01)
Local nHandle  := 0
Local cBuffer  := ''
Local nI       := 0
Local oStruZ00 := FwFormStruct( 1, "Z00")
Local oStruZ01 := FwFormStruct( 1, "Z01")
Local aStruArq := {}
Local aRegArq  := {}
Local nPos     := 0
Local nLin     := 0
Local nPosMod  := 0
Local nPosIt   := 0
Local cCampo   := ""
Local cTpCpo   := ""
Local cChave   := ""
Local nFile    := 0
Local aModulos := {}

//Processa Gravacao da Z00 se existir arquivo
If File(cFileZ00)
	nHandle  := FT_FUSE(cFileZ00)
	
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())

	nLin:= 0
	While ! FT_FEOF()
		nLin++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Leitura da linha do arquivo texto.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBuffer	:= TrataCaracter(FT_FREADLN())
		If (nLin == 1)
			//Separa a estrutura num array
			aStruArq:= Separa(cBuffer,";")
			nPosMod := aScan(aStruArq,"Z00_MODULO")

			FT_FSKIP()
			Loop

		EndIf

		aRegArq:= Separa(cBuffer,";")
		If (Len(aRegArq) > 0)
			If Empty(aRegArq[nPosMod])
				FT_FSKIP()
				Loop
			EndIf	

			IncProc("Gravando Z00 - Módulo: " + aRegArq[nPosMod])
			aAdd(aModulos,Padr(aRegArq[nPosMod],TamSX3("Z00_MODULO")[1]))

			//Apaga os registros do modulo que sera reimportado
			cRevisao:= "01"//GetProxRevisao(aRegArq[nPosMod],nOpcao)

			//Pesquisa se o registro existe
			cChave:= xFilial('Z00') + Padr(aRegArq[nPosMod],TamSX3("Z00_MODULO")[1]) + cRevisao

			//Apaga os registros da tabela para nova importacao
			DbSelectArea('Z00')
			DbSetOrder(1)
			IF DbSeek( cChave )
				RecLock("Z00",.F.,.T.)
				DbDelete()
				MsUnLock()
			End

			//Regrava a tabela de cabecalho dos itens
			RecLock('Z00',.T.)
			Z00_FILIAL	:= xFilial('Z00')
			Z00_MODULO  := aRegArq[nPosMod]
			Z00_REVISA  := cRevisao
			For nI:= 1 To Len(aStruArq)
				cCampo:= aStruArq[nI]
				cTpCpo:= FWSX3Util():GetFieldType( cCampo ) 

				If Z00->(FieldPos(cCampo))
					If (cTpCpo == "C")
						Z00->(FieldPut(FieldPos(aStruArq[nI]),aRegArq[nI]))
					ElseIf (cTpCpo == "N")	
						Z00->(FieldPut(FieldPos(aStruArq[nI]),Val(aRegArq[nI])))
					ElseIf (cTpCpo == "D")
						Z00->(FieldPut(FieldPos(aStruArq[nI]),Ctod(aRegArq[nI])))
					EndIf
				EndIf	
			Next nI
			MsUnLock()
		EndIf
		FT_FSKIP()
	EndDo

	FClose(nHandle)
EndIf

//Processa Gravacao da Z01 se existir arquivo
If File(cFileZ01)
	//Apaga os itens dos modulos que serao regravados
	If Len(aModulos) > 0
		For nModulo:= 1 To Len(aModulos)

			//Apaga os itens do modulo
			cChaveZ01:= xFilial('Z01') + aModulos[nModulo]
			DbSelectArea("Z01")
			DbSetOrder(1)
			DbSeek(cChaveZ01,.T.)
			While !Eof() .And. (Z01->Z01_FILIAL+Z01->Z01_MODULO == cChaveZ01)
				RecLock("Z01",.F.,.T.)
				DbDelete()
				MsUnLock()

				DbSkip()
			End	

		Next nModulo
	EndIf
	
	nHandle  := FT_FUSE(cFileZ01)
	
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())

	nLin:= 0
	While ! FT_FEOF()
		nLin++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Leitura da linha do arquivo texto.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBuffer	:= TrataCaracter(FT_FREADLN())
		If (nLin == 1)
			//Separa a estrutura num array
			aStruArq:= Separa(cBuffer,";")
			nPosMod:= aScan(aStruArq,"Z01_MODULO")
			nPosIt := aScan(aStruArq,"Z01_ORDEM")

			FT_FSKIP()
			Loop

		EndIf

		aRegArq:= Separa(cBuffer,";")
		If (Len(aRegArq) > 0)
		
			If Empty(aRegArq[nPosMod])
				FT_FSKIP()
				Loop
			EndIf	

			IncProc("Gravando Z01 - Módulo: " + aRegArq[nPosMod])
			cRevisao:= "01"
			cChaveZ01:= xFilial('Z01') + Padr(aRegArq[nPosMod],TamSX3("Z01_MODULO")[1]) + Padr(aRegArq[nPosIt], TamSX3("Z01_ORDEM")[1]) + cRevisao
			DbSelectArea('Z01')
			DbSetOrder(1)
			If DbSeek( cChave )
				RecLock("Z01",.F.,.T.)
				DbDelete()
				MsUnLock()
			EndIf

			RecLock('Z01',.T.)
			Z01_FILIAL	:= xFilial('Z01')
			Z01_MODULO  := aRegArq[nPosMod]
			Z01_ORDEM   := aRegArq[nPosIt]
			Z01_REVISA  := cRevisao
			For nI:= 1 To Len(aStruArq)
				cCampo:= aStruArq[nI]
				cTpCpo:= FWSX3Util():GetFieldType( cCampo ) 

				If Z01->(FieldPos(cCampo))
					If (cTpCpo == "C")
						Z01->(FieldPut(FieldPos(aStruArq[nI]),aRegArq[nI]))
					ElseIf (cTpCpo == "N")	
						Z01->(FieldPut(FieldPos(aStruArq[nI]),Val(aRegArq[nI])))
					ElseIf (cTpCpo == "D")
						Z01->(FieldPut(FieldPos(aStruArq[nI]),Ctod(aRegArq[nI])))
					EndIf
				EndIf	
			Next nI
			MsUnLock()
			
		EndIf
		FT_FSKIP()
	EndDo

	FClose(nHandle)
EndIf

Return(.T.)


/*/{Protheus.doc} TrataCaracter
Rotina para tratar os caracteres especiais
@type function
@version 1.0
@author Fábio Rogério
@since 30/03/2021
@param cFile, character, param_description
/*/
Static Function TrataCaracter(cBuffer)
Local cTxt:= ""
Local nI  := 0

For nI:= 1 To Len(cBuffer)
	If !SubStr(cBuffer,nI,1) $ "ï»¿" 
		cTxt+= SubStr(cBuffer,nI,1)
	EndIf	
Next nI

Return(cTxt)

/*/{Protheus.doc} GetProxRevisao
Rotina para gerar a proxima revisao dos escopos
@type function
@version 1.0
@author Fábio Rogério
@since 08/06/2021
@param cFile, character, param_description
/*/
Static Function GetProxRevisao(cModulo,nOpcao)
Local cRevisao:= "01"
Local cQuery  := ""
Local nHdlLock:= 0

If ( nHdlLock := MSFCREATE("IMPESCOPO.LCK") ) < 0
	MsgAlert("Rotina ja em execucao por outro usuario")
	Return .F.
Endif

cQuery:= " SELECT MAX(Z00_REVISA) Z00_REVISA "
cQuery+= " FROM " + RetSqlName("Z00") + " Z00 "
cQuery+= " WHERE Z00.D_E_L_E_T_ = '' "
cQuery+= " AND Z00.Z00_MODULO = '" + cModulo + "'"

TcQuery cQuery new Alias "TMP"
If !(Eof() .And. Bof())
	//Gera nova revisao
	If (nOpcao == 1)
		cRevisao:= Soma1(TMP->Z00_REVISA)
	Else
		cRevisao:= TMP->Z00_REVISA
	EndIf	
EndIf
dbCloseArea("TMP")

If nHdlLock > 0
	FClose(nHdlLock)
	FErase("IMPESCOPO.LCK")
Endif

Return(cRevisao)
