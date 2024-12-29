#include "protheus.ch"

User Function PAINELFIN(cGrupo)

Local oTela
Local oFnt2
Local oFnt3
Local oSay01
Local oSay02
Local aSize    := MsAdvSize()
Local cStyle   := "QFrame{ border-style:solid; border-width:1px; border-color:#CDCDCD; background-color:#FFFFFF;}"
Local lHtml    := .T.
Local cTitle01 := ""
Local cTitle02 := ""

Default cGrupo := ""

IF !( ( cGrupo $ "ADMINISTRADOR/RH") .Or. __cUserID == '000000' )

	//Verifica se é coordenador ou PMO
	DbSelectArea("AE8")
	DbSetOrder(3)
	IF DbSeek(xFilial("AE8")+__cUserID)
	
		IF AE8->AE8_EQUIPE == "5" .Or. AE8->AE8_EQUIPE == "6"			//Coordenacao
			MsgAlert('Nao Autorizado.')
			Return
		Endif
	EndIF

EndIF

//Montagem da Tela
DEFINE FONT oFnt NAME "ARIAL" SIZE 0,-12 BOLD
DEFINE FONT oFnt2 NAME "ARIAL" SIZE 0,-32 BOLD
DEFINE FONT oFnt3 NAME "ARIAL" SIZE 0,-6 BOLD
DEFINE MSDIALOG oTela FROM 0,0 TO aSize[6],aSize[5] TITLE "Painel Financeiro" Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

//****************CADASTROS  ******************
cTitle01:= '<font size="3" color="#FFD700">Cadastros</font>'
oSay01:= TSay():New( 033, 010,{|| cTitle01}, oTela,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)

IF cGrupo == "RH"
	oPnl01:= TPanelCSS():New(040,10,nil,oTela,nil,nil,nil,nil,nil,650,100,nil,nil)
Else
	oPnl01:= TPanelCSS():New(040,10,nil,oTela,nil,nil,nil,nil,nil,650,080,nil,nil)
EndIF
oPnl01:setCSS(cStyle)

dDtBase := dDataBase 
oDtBase := TGet():New(005,010,bSetGet(dDtBase) ,oPnl01,050,011,X3Picture('Z02_DTAPROV'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Data Base:",2,,CLR_BLUE,"Digite...")
oDtBase:bChange := {|| dDataBase := dDtBase } 

IF cGrupo == "RH"
	
	TButton():New( 030 , 010 , "Fornecedores"		,oPnl01,{|| LjMsgRun("Acessando..."	     ,,{|| MATA020()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 100 , "Recursos"			,oPnl01,{|| LjMsgRun("Acessando..."	     ,,{|| PMSA050()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 200 , "Vendedores"			,oPnl01,{|| LjMsgRun("Acessando..."	     ,,{|| MATA040()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )	
	TButton():New( 030 , 300 , "FECHAMENTO PMS"		,oPnl01,{|| LjMsgRun("FECHAMENTO PMS..." ,,{|| U_ALFPMS11( cGrupo )}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 400 , "Rel.Recursos"		,oPnl01,{|| LjMsgRun("Acessando..." 	 ,,{|| U_ALFARH03( cGrupo )}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 050 , 010 , "Grupo"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| TRMA030()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 050 , 100 , "Departamento"		,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| CSAA100()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 100 , "Departamento"		,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_ALFARH02()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 200 , "Centro de Custo"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| CONA060()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 300 , "Cargos"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_ALFARH01()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 050 , 300 , "Cargos"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| TRMA020()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 400 , "Funções"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| GPEA030()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 500 , "Tipos de Cursos"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA210()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 070 , 010 , "Cursos"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA020()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 070 , 100 , "Processo Seletivo"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA140()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 070 , 200 , "Vagas"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA100()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 070 , 300 , "Currículos"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA010()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 070 , 400 , "Agenda"				,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA150()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 070 , 500 , "Aplicar Teste"		,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| RSPA130()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	

Else


	TButton():New( 030 , 010 , "Clientes"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| MATA030()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 100 , "Fornecedores"		,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| MATA020()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 200 , "Recursos"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| PMSA050()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 300 , "Vendedores"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| MATA040()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 030 , 400 , "Painel Financeiro"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_SyPnl01()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 400 , "Painel Cobranças"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_AFCOB001()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 030 , 500 , "Propostas"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_ShowGrfVda()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	TButton():New( 030 , 580 , "Cad.Contratos"			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| u_ALFPMS70(cGrupo)}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	TButton():New( 050 , 580 , "Apuracao Contr."			,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_ALFPMS71(cGrupo)}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )


	TButton():New( 050 , 010 , "Ocorrencias  Cnab"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| FINA140()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 100 , "Parametros Bancos"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| FINA130()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 200 , "Modelos de Escopo"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_AFZ00_MVC()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 300 , "Modelos de Projeto"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_SYPMSA06()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 400 , "Saldos Bancários"	,oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_SySE8()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 050 , 500 , "Indices de Reajuste",oPnl01,{|| LjMsgRun("Acessando..."	,,{|| U_ALFAFIN01()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//****************CONTAS A RECEBER  ******************
	cTitle02:= '<font size="3" color="#FFD700">Contas a Receber</font>'
	oSay02:= TSay():New( 130, 010,{|| cTitle02}, oTela,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)
	
	oPnl02:= TPanelCSS():New(140,10,nil,oTela,nil,nil,nil,nil,nil,650,080,nil,nil)
	oPnl02:setCSS(cStyle)
	
	TButton():New( 020 , 010 , "Bancos"						,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| SYMATA070()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 110 , "Naturezas"					,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| SYFINA010()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 210 , "Cond.Pagamento"				,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| MATA360()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 310 , "Ajuste de OS"				,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_SYPMSA31()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 410 , "Painel de Projetos"			,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_AFPMSC110()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 510 , "Exportacao Contatos"		,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_ALFAEXSU5()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 040 , 010 , "Contas a Receber"			,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| SYFINA740()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 110 , "Faturamento Cliente Tela"	,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_SYGRRCCLIENTE()}) } ,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 210 , "Faturamento Cliente Rel"	,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_SYPMSR03()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 310 , "Reajuste"					,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_SYREAJUSTE()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 410 , "Painel Comercial"			,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| U_ShowGrfVda()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 510 , "Faturas a Receber"			,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| FINA280()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )		

	//TButton():New( 060 , 010 , "Baixas Contas a Receber"			,oPnl02,{|| LjMsgRun("Acessando..."	,,{|| SYFINA070()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	//****************Contas a Pagar  ******************
	cTitle03:= '<font size="3" color="#FFD700">Contas a Pagar</font>'
	oSay03:= TSay():New( 230, 010,{|| cTitle03}, oTela,,oFnt,,,,.T.,,,200,20,,,,,,lHtml)
	
	oPnl03:= TPanelCSS():New(240,10,nil,oTela,nil,nil,nil,nil,nil,650,080,nil,nil)
	oPnl03:setCSS(cStyle)
	
	TButton():New( 020 , 010 , "Contas a Pagar"			,oPnl03,{|| LjMsgRun("Acessando Contas a Pagar..."				,,{|| SYFINA050()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 110 , "Baixa Contas a Pagar"	,oPnl03,{|| LjMsgRun("Acessando Baixa Contas a Pagar..."		,,{|| SYFINA080()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 210 , "Pagto. Prestadores Tela",oPnl03,{|| LjMsgRun("Acessando Pagto. Prestadores Tela..."		,,{|| U_SYGRPGCONSULT()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 310 , "Pagto. Prestadores Rel"	,oPnl03,{|| LjMsgRun("Acessando Pagto. Prestadores Relatorio...",,{|| U_SYPMSR06()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 410 , "Pedido de Compras"		,oPnl03,{|| LjMsgRun("Acessando Pedido de Compra..."			,,{|| MATA121()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 020 , 510 , "Centros de Custo"		,oPnl03,{|| LjMsgRun("Acessando..."								,,{|| CTBA180()}) }			,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//TButton():New( 040 , 010 , "Gera Comissao"			,oPnl03,{|| LjMsgRun("Acessando Recalc. Comissao..."			,,{|| U_AtuComissao()}) }	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 040 , 110 , "Lista de Comissoes"		,oPnl03,{|| LjMsgRun("Acessando Comissoes..."					,,{|| SYMATA490()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 040 , 210 , "Relacao Comissoes"		,oPnl03,{|| LjMsgRun("Acessando Relacao Comissoes..."			,,{|| U_SYMATR540()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 010 , "Conf.Fornecedores"		,oPnl03,{|| LjMsgRun("Acessando Conferencia de Fornecedores..."	,,{|| U_SYFINA01()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 110 , "Conf.Comissao"			,oPnl03,{|| LjMsgRun("Acessando Conferencia de Comissoes..."	,,{|| U_SYFINA02()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 210 , "Comissões"				,oPnl03,{|| U_ALFPMS55()}	,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 310 , "Proposta - MVC"			,oPnl03,{|| LjMsgRun("Acessando Propostas..."					,,{|| U_AF02WIZ_MVC(3)}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	// TButton():New( 040 , 410 , "ARTIA"					,oPnl03,{|| LjMsgRun("Integração ARTIA..."						,,{|| U_ALFART00()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 040 , 410 , "MOVIDESK"				,oPnl03,{|| LjMsgRun("Integração Movidesk..."					,,{|| U_AFAPIMOVI()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 040 , 410 , "FECHAMENTO PMS"			,oPnl03,{|| LjMsgRun("FECHAMENTO PMS..."					,,{|| U_ALFPMS11( cGrupo )}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New( 040 , 510 , "Conta Contabil"			,oPnl03,{|| LjMsgRun("Conta Contail..."					,,{|| SYCTBA20(  )}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	
	TButton():New( 060 , 010 , "Lib.Cta.Pagar"		,oPnl03,{|| LjMsgRun("Acessando Liberação de contas a pagar..."	,,{|| FINA580()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	TButton():New( 060 , 110 , "Cad.Produtos"		,oPnl03,{|| LjMsgRun("Acessando CADASTRO DE PRODUTO..."	,,{|| MATA010()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 060 , 210 , "Recurso x Produtos"	,oPnl03,{|| LjMsgRun("Acessando RECURSO X PRODUTOS..."	,,{|| U_ALFPMS16()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	//TButton():New( 060 , 310 , "Cad.Mot.Baixa"	,oPnl03,{|| LjMsgRun("Acessando CADASTRO DE MOTIVO DE BAIXA..."	,,{|| FINA490()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 060 , 310 , "Fatura a Pagar"	,oPnl03,{|| LjMsgRun("Acessando Fatura a Pagar..."	,,{|| FINA290()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 060 , 310 , "Liquidação a Pagar"	,oPnl03,{|| LjMsgRun("Acessando Liquidação a Pagar..."	,,{|| FINA565()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 060 , 410 , "Fatura a Pagar"	,oPnl03,{|| LjMsgRun("Acessando Fatura a Pagar..."	,,{|| FINA290()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )//TButton():New( 060 , 310 , "Fatura a Pagar"	,oPnl03,{|| LjMsgRun("Acessando Fatura a Pagar..."	,,{|| FINA290()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	//TButton():New( 040 , 210 , "Previsao de Comissoes"	,oPnl03,{|| LjMsgRun("Acessando Previsao de Comissoes..."		,,{|| SYFINR610()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 040 , 110 , "Recalcula Comissao"		,oPnl03,{|| LjMsgRun("Acessando Recalc. Comissao..."			,,{|| SYFINA440()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
//	TButton():New( 040 , 310 , "Modelos de Escopo NEW"	,oPnl03,{|| LjMsgRun("Acessando..."	,,{|| U_ALFACadMod()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	//TButton():New( 040 , 410 , "Proposta NEW"			,oPnl03,{|| LjMsgRun("Acessando..."	,,{|| U_ALFAZ02()}) }		,60,12,,,.F.,.T.,.F.,,.F.,,,.F. )

EndIF

ACTIVATE MSDIALOG oTela ON INIT ( EnchoiceBar(	oTela,;
												{|| oTela:End()  },;
												{|| oTela:End() }) ) CENTERED

Return

Static Function SYFINA050()

VerificaSaldo()

SetFunName("FINA050")

FINA050()

Return

Static Function SYFINA080()

SetFunName("FINA080")

FINA080()

Return

Static Function SYMATA070()

SetFunName("MATA070")

cFiltro:= "(A6_BLOCKED <> '1')"
SA6->(DbSetfilter({||&cFiltro},cFiltro))

MATA070()

Return


Static Function SYFINA010()

SetFunName("FINA010")

FINA010()

Return

Static Function SYFINA740()

Local nBkpMod:= nModulo
Local cBkpMod:= cModulo
VerificaSaldo()

SetFunName("FINA740")
nModulo:= 6
cModulo:='FIN'
FINA740()

nModulo := nBkpMod
cModulo := cBkpMod

Return

User Function SYSE8()

Local cAlias  := "SE8"
Local cTitulo := "Saldos Bancarios"
Local cVldExc := ".T."
Local cVldAlt := ".T." 

//FA030CHAVE()

CriaSaldoZero()

dbSelectArea( "SE8" )
SE8->(dbSetOrder( 1 ))

cFiltro:= "(SA6->A6_BLOCKED <> '1' .And. !(Alltrim(SA6->A6_COD) $ 'CX1/C01/999') .And. Dtos(SE8->E8_DTSALAT) = '"+Dtos(dDatabase) + "')"
SE8->(DbSetfilter({||&cFiltro},cFiltro))


AxCadastro( cAlias, cTitulo, cVldExc, cVldAlt )

Return

/*
Static Function FA030CHAVE()

SX3->(dbSetOrder(1))
SX3->(dbSeek("SE8",.T.))
While !Eof() .And. (Alltrim(SX3->X3_ARQUIVO) = "SE8")
	RecLock("SX3",.F.)
	Replace X3_VALID With ""
	MsUnLock()
	
	SX3->(dbSkip())
End


Return(.T.)
*/
/*
Fabio Rogerio - 22/04/2019
Cria saldo zerado no dia se não existir lancamento de saldo para que a query do BI nao volte vazia

*/
Static Function CriaSaldoZero()

//Cria o saldo zerado do dia para a query de saldo nao retornar em branco
dbSelectArea("SA6")
dbSetOrder(1)
DbGoTop()
While !Eof()
	If SA6->A6_BLOCKED == '1' .Or. (Alltrim(SA6->A6_COD) $ "CX1/C01/999") //Bloqueada/Inativa
		dbSelectArea("SA6")
		dbSkip()
	EndIf	
		
	dbSelectArea("SE8")
	dbSetOrder(1)
	If !dbSeek(xFilial("SE8") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON + Dtos(dDatabase))
		RecLock("SE8",.T.)
		Replace E8_FILIAL  With xFilial("SE8")
		Replace E8_BANCO   With SA6->A6_COD 
		Replace E8_AGENCIA With SA6->A6_AGENCIA
		Replace E8_CONTA   With SA6->A6_NUMCON
		Replace E8_DTSALAT With dDatabase
		Replace E8_SALDOIN With 0
		MsUnlock()
	EndIf
	

	dbSelectArea("SA6")
	dbSkip()
	
End

Return(.T.)

/*
Fabio Rogerio - 22/04/2019
Cria saldo zerado no dia se não existir lancamento de saldo para que a query do BI nao volte vazia

*/
Static Function VerificaSaldo()

Local lZerado:= .F.
Local cMsg   := ""

//Verifica se todas as contas estao com saldo informados

//Cria o saldo zerado do dia para a query de saldo nao retornar em branco
dbSelectArea("SA6")
dbSetOrder(1)
DbGoTop()
While !Eof()
	If SA6->A6_BLOCKED == '1' .Or. (Alltrim(SA6->A6_COD) $ "CX1/C01/999") //Bloqueada/Inativa
		dbSelectArea("SA6")
		dbSkip()
	EndIf	
		
	dbSelectArea("SE8")
	dbSetOrder(1)
	dbSeek(xFilial("SE8") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON + Dtos(dDatabase))

	If !Eof() .And. (SE8->E8_SALDOIN == 0)
		lZerado:= .T.
		
		If !Empty(cMsg)
			cMsg+= Chr(10)+Chr(13)
		EndIf
	
		cMsg+= "Banco/Agencia/Conta: " + SA6->A6_COD + "/" + SA6->A6_AGENCIA + "/" + SA6->A6_NUMCON 
	
	EndIf
	

	dbSelectArea("SA6")
	dbSkip()
	
End

If !Empty(cMsg) .And. lZerado
	cMsg:= "Existem contas sem saldo do dia informado:" + Chr(10) + Chr(13) + cMsg + Chr(10) + Chr(13) + Chr(10) + Chr(13) + "Deseja incluir saldo agora?"

	If Aviso("Atenção",cMsg,{"Sim","Não"}) == 1
		U_SySE8()
	EndIf
	
EndIf

Return(.T.)


User Function SyDateX()

If ValType("dDtbase") == "D"	
	dDatabase:= dDtbase
EndIf
Return(dDatabase)

Static Function SYCTBA20()


//SetFunName("FINA740")

CTBA020()

Return

Static Function SYFINA070()

SetFunName("FINA070")

FINA070()

Return
