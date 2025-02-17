#include "protheus.ch"


/**************************************************************************************************
Fun��o:
XMLPerg

Autor:
Tiago Bandeira Brasiliano

Data:
24/03/2009

Descri��o:
Rotina utilizada para criar um dialogo contendo as perguntas e os par�metros necess�rios para a 
cria��o de relat�rios XML Excel

Par�metros:
cPerg     => Pergunta (SX1) utilizada pelo relat�rio
cDir      => Diret�rio default onde ser�o salvos os arquivos criados (Default: C:\)
bOk       => Rotina executada pelo bot�o Ok (confirma). Esta rotina dever� voltar um string com 
             o conte�do que ser� salvo no arquivo. 
             O Primeiro par�metro desta rotina deve ser uma vari�vel l�gica que ir� permitir o 
             controle de cancelamento do processamento.
             O segundo par�metro desta rotina ser� o caminho + nome do arquivo que ser� gerado.
cTitulo   => Titulo do relat�rio que ser� exibido na janela
cNome     => Nome do relat�rio. Este nome tamb�m ser� o nome padr�o do arquivo gerado
cDesc     => Descri��o do relat�rio
cExtensao => Extens�o do arquivo que ser� gerado ap�s o processamento da rotina em bOK
             (valor default: XML)
nOpc      => Op��o de gera��o:
             1 = Gera arquivo no disco e depois abre (default)
             2 = Some gera o arquivo em disco
cMsgProc  => Mensagem para ser exibida durante o processamento. Al�m desta op��o, � poss�vel
             utilizar dentro da rotina executada pela op��o bOk as rotinas ProcRegua() e
             IncProc().

Retorno:
Nenhum
**************************************************************************************************/
User Function XMLPerg(cPerg, cDir, bOk, cTitulo, cNome, cDesc, cExtensao, nOpc, cMsgProc)

Local oFont1    
Local oDialog
Local oImagem
Local cTipoArq 	:= "Todos os Arquivos (*.*)     | *.* |"
Local cArquivo  := ""
Local cXML      := ""
Local lCancela  := .F.
Local bGravaArq := {|| Iif(lCancela, Alert("Processamento cancelado pelo usu�rio."), Iif(!Empty(cXML), Eval({|| Iif(nOpc == 1, ShellExecute("open", AllTrim(cArquivo)+"."+AllTrim(cExtensao), "", "", 1), NIL), Aviso("Resultado de processamento", "Arquivo gerado com sucesso!", {"Ok"})}), Alert("Nenhum arquivo foi gerado!")))}

DEFAULT cPerg	  := ""
DEFAULT cDir      := "C:\"
DEFAULT cExtensao := "XML"
DEFAULT cMsgProc  := "Aguarde. Gerando relat�rio..."

If !Empty(cPerg)
	Pergunte(cPerg, .F.)
EndIf

cArquivo := cDir + cNome
cArquivo := PadR(cArquivo, 250)

oFont1 := TFont():New(,,16,,.T.) 

oDialog := MSDialog():New(0, 0, 270, 400, OemToAnsi(cTitulo),,,,,,CLR_WHITE,,,.T.,,,)

TSay():New(005,063,{|| "Gera��o de relat�rio Excel"},,,oFont1,,,,.T.)

TGroup():New(015,004,043,197," Destino: "  ,oDialog,,,.T.)
TGet():New(024,008,bSetGet(cArquivo),,171,010,,,,,,,,.T.)
//TButton():New(024,180, "...",,{|| cPath := cGetFile(cTipoArq,"Selecione o diret�rio de destino",0,cDir,.T.,GETF_LOCALHARD+GETF_RETDIRECTORY, .F.), cDir := Iif(Empty(cPath), cDir, cPath), cArquivo := PadR(cDir + cNome, 250)},012,012,,,,.T.)
TBtnBmp2():New(047,359,026,026,"SDUOPEN",,,,{|| cPath := cGetFile(cTipoArq,"Selecione o diret�rio de destino",0,cDir,.T.,GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY, .F.), cDir := Iif(Empty(cPath), cDir, cPath), cArquivo := PadR(cDir + cNome, 250)},oDialog,"Pesquisa local de destino")

TGroup():New(045,004,100,197," Descri��o: ",oDialog,,,.T.)
TMultiGet():New(054,008,bSetGet(cDesc),,185,040,,,,,,.T.,,,,,,.T.,,,)
                                                          
TGroup():New(102,004,133,095," Op��es: ",oDialog,,,.T.)
oImagem := TBitmap():New(113,009, 32, 32, "MDIEXCEL",,.T.,oDialog,,,,,,,,,.T.,,,.T.)
TRadMenu():New(110,025,{"Gera arquivo + Abre","Somente gera arquivo"},bSetGet(nOpc), oDialog,,{|| oImagem:Load(Iif(nOpc == 1, "MDIEXCEL", "SALVAR"))},,,,,,065,011,,,,.T.)

If !Empty(cPerg)
	SButton():New(120, 110, 5, {|| Pergunte(cPerg, .T.)}) // Parametros
EndIf     
SButton():New(120, 140, 1, {|| Iif(VldNomeArq(@cArquivo, cExtensao), Eval({|| Processa({|lEnd| cXML := Eval(bOk, @lEnd, AllTrim(cArquivo)+"."+AllTrim(cExtensao)), lCancela := lEnd},cMsgProc,,.T.), Eval(bGravaArq), oDialog:End()}),Nil)} ) // Ok
SButton():New(120, 170, 2, {|| oDialog:End()})         // Cancela

Activate Dialog oDialog CENTERED

Return .T.


/**************************************************************************************************
Fun��o:
VldNomeArq

Autor:
Tiago Bandeira Brasiliano

Data:
08/05/2009

Descri��o:
Esta fun��o verifica se j� existe um arquivo com o mesmo nome do arquivo que est� sendo salvo.
Caso exista � exibida uma mensagem informando que j� existe um arquivo com o mesmo nome, e pergunta
ao usu�rio se ele deseja substituir, ou se deseja manter o arquivo atual.

Par�metros:
cArq     => Path e nome do arquivo
cExt     => Extens�o do arquivo

Retorno: 
lRet     => Booleano indicando se deve prosseguir com o processamento do arquivo ou n�o.
            .T. - Continua com o processamento.
            .F. - Cancela o processamento. 

**************************************************************************************************/
Static Function VldNomeArq(cArq, cExt)
Local lRet     := .T.
Local lAchou   := .F.
Local cNomeRel := SubStr(cArq, RAt("\", cArq) + 1)
Local cPath    := SubStr(cArq, 1, RAt("\", cArq))

// Procura pelo arquivo no diret�rio
aEval(Directory(cPath+"*."+cExt), {|aArqTXT| Iif(AllTrim(Upper(SubStr(aArqTXT[1],1,RAt(".",aArqTXT[1]) - 1))) == AllTrim(Upper(cNomeRel)), lAchou := .T., Nil)})

If lAchou	
	If MsgNoYes("J� existe um arquivo no diret�rio com este nome. Deseja continuar e substituir este arquivo?")
		If FErase(AllTrim(cArq)+"."+AllTrim(cExt)) < 0// Apaga o arquivo
			lRet := .F.
			Alert("Aten��o! N�o foi poss�vel excluir o arquivo "+AllTrim(cArq)+"."+AllTrim(cExt)+". Verifique se o mesmo est� aberto ou sendo utilizado por outro programa.")
		EndIf		
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet
