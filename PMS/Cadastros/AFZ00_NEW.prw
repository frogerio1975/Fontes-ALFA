#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4

/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AFZ00_NEW บ Autor ณ  Fabio Rogerio    บ Data ณ  05/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Modulos/Cursos.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AFZ00_NEW()

Local cFilterDefault := ""

Private aRotina := MenuDef()
Private oBrowse
Private cCadastro := "Cadastro de Modulos/Oferta/Licenca"

Private cZ00Produt:= "" //Variavel usada em Filtro no SXB da Z00 para selecionar somente os modulos do produto selecionado
Private nTipo     := "" //Variavel para controle do Tipo da Tela (Modulo, Oferta ou Licenca) para controle na MVC

cFilterDefault:= FiltroBrowse()

// Instanciamento da Classe de Browse
DEFINE FWMBROWSE oBrowse ALIAS "Z00" FILTERDEFAULT cFilterDefault DESCRIPTION cCadastro

		// Adiciona legenda no Browse
		ADD LEGEND DATA {|| Z00->Z00_LIBERA == "1" } COLOR "GREEN" 	TITLE "M๓dulo Liberado" 		OF oBrowse
		ADD LEGEND DATA {|| Z00->Z00_LIBERA == "2" } COLOR "RED" 	TITLE "Modulo Bloqueado" 		OF oBrowse

// Ativacao da Classe
ACTIVATE FWMBROWSE oBrowse

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelDef  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ModelDef Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local oModel

oModel:= MpFormMOdel():New( "AFZ00MVC" ,  /*bPreValid*/ , /*bPostValid*/, /*bComValid*/ ,/*bCancel*/ )

If (nTipo == 1)
	ModelModulo(@oModel)
ElseIf (nTipo == 2)
	ModelOferta(@oModel)
ElseIf (nTipo == 3)
	ModelLicenca(@oModel)
EndIf

Return oModel


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewDef  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ViewDef Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

Local oModel 	:= FwLoadModel("AFZ00_NEW")
Local oView     := Nil

oView := FwFormView():New()
oView:SetModel(oModel)

If (nTipo == 1)
	ViewModulo(@oView)
ElseIf (nTipo == 2)
	ViewOferta(@oView)
ElseIf (nTipo == 3)
	ViewLicenca(@oView)
EndIf

Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o Menu Padrao do MVC.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        	ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.AFZ00_NEW" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"       		ACTION "VIEWDEF.AFZ00_NEW" 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"       		ACTION "VIEWDEF.AFZ00_NEW" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"       		ACTION "VIEWDEF.AFZ00_NEW" 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Importar Escopo"      ACTION "U_AFIMPESCOPO"	 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Copiar"               ACTION "VIEWDEF.AFZ00_NEW"	OPERATION 9 ACCESS 0

Return aRotina 

/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FiltroBrowse บ Autor ณ  Fabio Rogerio    บ Data ณ  05/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FiltroBrowse de  de Modulos/Cursos.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FiltroBrowse()
Local aParamBox	:= {}
Local aRet		:= {}
Local cFiltro   := ""

Aadd(aParamBox,{3,"Produtos",1,{"Todos","SAP","TOTVS"},50,"",.T.})
Aadd(aParamBox,{3,"Tipos",2,{"Bloqueados","Liberados", "Ambos"},50,"",.T.})
Aadd(aParamBox,{3,"Modulo/Oferta/Licenca",1,{"Modulo","Oferta","Licenca"},50,"",.T.})
Aadd(aParamBox,{1,"Fornecedor",Space(6),"","","SA2","",0,.F.})

If ParamBox(aParamBox,"Filtros...",@aRet)

	IF MV_PAR01 == 2
		cFiltro := "Z00_PRODUT == '2'"
		cZ00Produt:= "2"
	ElseIF MV_PAR01 == 3
		cFiltro := "Z00_PRODUT == '1'"
		cZ00Produt:= "1"
	Else
		cFiltro := ".T. "
		cZ00Produt:= "2"
	EndIF

	IF MV_PAR02 == 1
		cFiltro += " .AND. Z00_LIBERA == '2'"
	ElseIF MV_PAR02 == 2
		cFiltro += " .AND. Z00_LIBERA == '1'"
	EndIF
	
	IF !Empty(MV_PAR04)
		cFiltro += " .AND. Z00_FORNEC == '" + Alltrim(MV_PAR04) + "' "
	EndIF

	IF MV_PAR03 == 1
		cFiltro += " .AND. Z00_TPMOD == '1'"
	ElseIF MV_PAR03 == 2
		cFiltro += " .AND. Z00_TPMOD == '2'"
	ElseIF MV_PAR03 == 3
		cFiltro += " .AND. Z00_TPMOD == '3'"
	EndIF

    //Atualiza a variavel global de controle
    nTipo:= MV_PAR03
Else    
    //Atualiza a variavel global de controle
    nTipo:= 1
    cFiltro:= "Z00_TPMOD == '1'"
Endif

Return(cFiltro)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelLicenca  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ModelLicenca Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelLicenca(oModel)
Local oStruZ00 := FwFormStruct( 1, "Z00")
Local oStruZ01 := FwFormStruct( 1, "Z01")
Local oStruZ24 := FwFormStruct( 1, "Z24")

oModel:AddFields("Z00MASTER", Nil, oStruZ00, /*prevalid*/, , /*bCarga*/)
oModel:SetPrimaryKey({'Z00_FILIAL', 'Z00_MODULO'})  
oModel:SetDescription("Licencas")

oModel:GetModel( "Z00MASTER" ):SetDescription( "Licencas" )

//Se for licenciamento de add-on jแ carrega o escopo do modulo
If (Z00->Z00_TPLIC == '2')

	FWMemoVirtual( oStruZ01,{ { 'Z01_CODMEM' , 'Z01_MEMO' }  } )

	oModel:AddGrid("Z01DETAIL", "Z00MASTER", oStruZ01, /*prevalid*/, , /*bCarga*/)
	oModel:AddGrid("Z24DETAIL", "Z00MASTER", oStruZ24, /*prevalid*/, , /*bCarga*/)
	oModel:SetPrimaryKey({'Z00_FILIAL', 'Z00_MODULO'})  
	oModel:SetRelation("Z01DETAIL", {{"Z01_FILIAL", "FwXFilial('Z01')"}, {"Z01_MODULO", "Z00_MODULO"}}, Z01->(IndexKey(1)))
	oModel:SetRelation("Z24DETAIL", {{"Z24_FILIAL", "FwXFilial('Z24')"}, {"Z24_MODULO", "Z00_MODULO"}}, Z24->(IndexKey(1)))
	oModel:SetDescription("M๓dulos")

	oModel:GetModel( "Z00MASTER" ):SetDescription( "M๓dulo" )
	oModel:GetModel( "Z01DETAIL" ):SetDescription( "Escopo do M๓dulo" )
	oModel:GetModel( "Z24DETAIL" ):SetDescription( "Faixas de Licenciamento" )

	oModel:GetModel( "Z01DETAIL" ):SetUniqueLine( {"Z01_ORDEM"} )
	oModel:GetModel( "Z24DETAIL" ):SetUniqueLine( {"Z24_ORDEM"} )
EndIf

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelModulo  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ModelModulo Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelModulo(oModel)
Local oStruZ00 := FwFormStruct( 1, "Z00")
Local oStruZ01 := FwFormStruct( 1, "Z01")

FWMemoVirtual( oStruZ00,{ { 'Z00_CODM1' , 'Z00_MEMO1' }  } )
FWMemoVirtual( oStruZ01,{ { 'Z01_CODMEM' , 'Z01_MEMO' }  } )

oModel:AddFields("Z00MASTER", Nil, oStruZ00, /*prevalid*/, , /*bCarga*/)
oModel:AddGrid("Z01DETAIL", "Z00MASTER", oStruZ01, /*prevalid*/, , /*bCarga*/)
oModel:SetPrimaryKey({'Z00_FILIAL', 'Z00_MODULO'})  
oModel:SetRelation("Z01DETAIL", {{"Z01_FILIAL", "FwXFilial('Z01')"}, {"Z01_MODULO", "Z00_MODULO"}}, Z01->(IndexKey(1)))
oModel:SetDescription("M๓dulos")

oModel:GetModel( "Z00MASTER" ):SetDescription( "M๓dulo" )
oModel:GetModel( "Z01DETAIL" ):SetDescription( "Itens do M๓dulo" )

oModel:GetModel( "Z01DETAIL" ):SetUniqueLine( {"Z01_ORDEM"} )
//oModel:AddCalc( 'Z01CALC1', 'Z00MASTER', 'Z01DETAIL', 'Z01_HORAS', 'Z01CALCHORAS', 'FORMULA',,,'Total de Horas do Projeto',{|oModel,nTotalAtual,xValor,lSomando| CalcTotalValue(oModel,nTotalAtual,xValor,lSomando)} )


Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelOferta  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ModelOferta Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelOferta(oModel)
Local oStruZ00 := FwFormStruct( 1, "Z00")
Local oStruZ17 := FwFormStruct( 1, "Z17")
Local oStruZ18 := FwFormStruct( 1, "Z18")

FWMemoVirtual( oStruZ00,{ { 'Z00_CODM1' , 'Z00_MEMO1' }  } )
FWMemoVirtual( oStruZ18,{ { 'Z18_CODMEM' , 'Z18_MEMO' }  } )

oModel:AddFields("Z00MASTER", Nil, oStruZ00, /*prevalid*/, , /*bCarga*/)
oModel:AddGrid("Z17DETAIL", "Z00MASTER", oStruZ17, /*prevalid*/, , /*bCarga*/)
oModel:AddGrid("Z18DETAIL", "Z17DETAIL", oStruZ18, /*prevalid*/, /*posvalid*/, /*bCarga*/)
oModel:SetPrimaryKey({'Z00_FILIAL', 'Z00_MODULO'})  
oModel:SetRelation("Z17DETAIL", {{"Z17_FILIAL", "FwXFilial('Z17')"}, {"Z17_ESCOPO", "Z00_MODULO"}}, Z17->(IndexKey(1)))
oModel:SetRelation("Z18DETAIL", {{"Z18_FILIAL", "FwXFilial('Z18')"}, {"Z18_CODESC", "Z00_MODULO"}, {"Z18_MODULO", "Z17_MODULO"}}, Z18->(IndexKey(1)))
oModel:SetDescription("Ofertas")

oModel:GetModel( "Z00MASTER" ):SetDescription( "Escopo" )
oModel:GetModel( "Z17DETAIL" ):SetDescription( "M๓dulos" )
oModel:GetModel( "Z18DETAIL" ):SetDescription( "Itens do M๓dulo" )

oModel:GetModel( "Z17DETAIL" ):SetUniqueLine( {"Z17_MODULO","Z17_SEQ"} )
oModel:GetModel( "Z18DETAIL" ):SetUniqueLine( {"Z18_CODESC","Z18_MODULO","Z18_ORDEM"} )

//oModel:AddCalc( 'Z18CALC1', 'Z17DETAIL', 'Z18DETAIL', 'Z18_HORAS', 'Z18CALCHORAS', 'FORMULA',,,'Total de Horas do Projeto',{|oModel,nTotalAtual,xValor,lSomando| CalcTotalValue(oModel,nTotalAtual,xValor,lSomando)} )

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewLicenca  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ViewLicenca Padrao do MVC.                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewLicenca(oView)
Local oStruZ00  := FwFormStruct( 2, "Z00")

oView:AddField("VIEW_Z00", oStruZ00 , "Z00MASTER")

//Se for licenciamento de add-on jแ carrega o escopo do modulo
If (Z00->Z00_TPLIC == '2')
	oView:CreateHorizontalBox("SUPERIOR", 50)
	oView:CreateHorizontalBox("INFERIOR", 50)

	oView:SetOwnerView("VIEW_Z00", "SUPERIOR")
	oView:SetOwnerView("VIEW_Z01", "INFERIOR")

	oView:CreateHorizontalBox( 'BOX6', 100)
	oView:CreateFolder( 'FOLDER7', 'BOX6')

	oView:AddSheet('FOLDER7','SHEET9','SHEET9')
	oView:CreateHorizontalBox( 'BOXFORM2', 100, , , 'FOLDER7', 'SHEET9')

	oView:AddSheet('FOLDER7','SHEET8','SHEET8')
	oView:CreateHorizontalBox( 'BOXFORM4', 100, , , 'FOLDER7', 'SHEET8')

	oView:SetOwnerView('ZA1MASTER','BOXFORM2')
	oView:SetOwnerView('ZA2DETAIL','BOXFORM4')

Else
	oView:CreateHorizontalBox("SUPERIOR", 100)

	oView:SetOwnerView("VIEW_Z00", "SUPERIOR")
EndIf 

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewModulo  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ViewModulo Padrao do MVC.                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewModulo(oView)
Local oStruZ00  := FwFormStruct( 2, "Z00")
Local oStruZ01  := FwFormStruct( 2, "Z01")

oView:AddField("VIEW_Z00", oStruZ00 , "Z00MASTER")
oView:AddGrid( "VIEW_Z01", oStruZ01 , "Z01DETAIL")

oView:CreateHorizontalBox("SUPERIOR", 50)
oView:CreateHorizontalBox("INFERIOR", 50)

oView:SetOwnerView("VIEW_Z00", "SUPERIOR")
oView:SetOwnerView("VIEW_Z01", "INFERIOR")

oView:AddIncrementField( 'VIEW_Z01', 'Z01_ORDEM' )
oView:SetFieldAction("Z01_ESCOPO", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 
oView:SetFieldAction("Z01_HORAS", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 
oView:SetFieldAction("Z01_DIAS", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 

oView:SetViewProperty( 'VIEW_Z01', "ENABLEDCOPYLINE",  {VK_F12} )

oView:SetViewProperty( "VIEW_Z01", "ENABLENEWGRID" )		// Define que o grid deve usar como interface visual o browse (FWBrowse)
oView:SetViewProperty( "VIEW_Z01", "SETCSS", { "QTableView { selection-color: #FFFFFF; selection-background-color: #000080; }"} ) // Seta a cor de backgroud da linha selecionda         

oView:SetViewAction( 'DELETELINE'  , { |oView,cIdView,nNumLine| DeleteLineModulo( oView,cIdView,nNumLine ) } )`
oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| UnDeleteLineModulo( oView,cIdView,nNumLine ) } )`

Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewOferta  บAutor  ณ Fabio Rogerio  บ Data ณ  17/03/21   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o ViewOferta Padrao do MVC.                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewOferta(oView)
Local oStruZ00  := FwFormStruct( 2, "Z00")
Local oStruZ17  := FwFormStruct( 2, "Z17")
Local oStruZ18  := FwFormStruct( 2, "Z18")

oView:AddField("VIEW_Z00", oStruZ00 , "Z00MASTER")
oView:AddGrid( "VIEW_Z17", oStruZ17 , "Z17DETAIL")
oView:AddGrid( "VIEW_Z18", oStruZ18 , "Z18DETAIL")

oView:CreateHorizontalBox("SUPERIOR", 25)
oView:CreateHorizontalBox("MEIO", 35)
oView:CreateHorizontalBox("INFERIOR", 40)

oView:SetOwnerView("VIEW_Z00", "SUPERIOR")
oView:SetOwnerView("VIEW_Z17", "MEIO")
oView:SetOwnerView("VIEW_Z18", "INFERIOR")

oView:AddIncrementField( 'VIEW_Z17', 'Z17_SEQ' )
oView:AddIncrementField( 'VIEW_Z18', 'Z18_ORDEM' )

oView:EnableTitleView( 'VIEW_Z17' )
oView:EnableTitleView( 'VIEW_Z18' )

oView:SetViewProperty( "VIEW_Z17", "ENABLENEWGRID" )		// Define que o grid deve usar como interface visual o browse (FWBrowse)
oView:SetViewProperty( "VIEW_Z17", "SETCSS", { "QTableView { selection-color: #FFFFFF; selection-background-color: #000080; }"} ) // Seta a cor de backgroud da linha selecionda         

oView:SetViewProperty( 'VIEW_Z18', "ENABLEDCOPYLINE",  {VK_F12} )

oView:SetFieldAction("Z18_ESCOPO", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 
oView:SetFieldAction("Z18_HORAS", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 
oView:SetFieldAction("Z18_DIAS", 	{ |oView, cIDView, cField, xValue| FieldAction(@oView, cIDView, cField, xValue ) } ) 

oView:SetViewAction( 'DELETELINE'  , { |oView,cIdView,nNumLine| DeleteLineModulo( oView,cIdView,nNumLine ) } )`
oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| UnDeleteLineModulo( oView,cIdView,nNumLine ) } )`
Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FieldAction  บAutor  ณ Fabio Rogerio  บ Data ณ17/03/21บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o FieldAction Padrao do MVC.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FieldAction(oView, cIdView, cField, xValue)
Local nTotHoras:= 0
Local nHoras   := 0
Local nHorasZ17:= 0
Local oGridZ01
Local oGridZ18

IF 	(oView:GetModel("Z01DETAIL") <> Nil) .And. ;
	(oView:GetModel("Z18DETAIL") <> Nil)
	Return(oView)
EndIf

//Se fizer parte do Escopo soma o total de horas
IF (cIdView == "VIEW_Z01")
	oGridZ01:= oView:GetModel("Z01DETAIL")
	If (cField == "Z01_ESCOPO")
		oGridZ01:LoadValue('Z01_ESCOPO',xValue)	

		If (xValue == "2")
			nHoras:= oGridZ01:GetValue('Z01_HORAS')
		EndIf	
	ElseIf (cField == "Z01_DIAS")
		nHoras:= xValue * 10
		oGridZ01:LoadValue('Z01_DIAS',xValue)	
		oGridZ01:LoadValue('Z01_HORAS',nHoras)		
	EndIf

	nTotHoras:= CalcTotalValue(oView) 
	oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nTotHoras)
ElseIf (cIdView == "VIEW_Z18")	
	oGridZ18:= oView:GetModel("Z18DETAIL")
	If (cField == "Z18_ESCOPO")
		oGridZ18:LoadValue('Z18_ESCOPO',xValue)	

		If (xValue == "2")
			nHoras:= oGridZ18:GetValue('Z18_HORAS')
		EndIf	
	ElseIf (cField == "Z18_DIAS")
		oGridZ18:LoadValue('Z18_DIAS',xValue)	
		oGridZ18:LoadValue('Z18_HORAS',xValue * 10)		
	EndIf

	nHorasZ17:= oView:GetModel("Z17DETAIL"):GetValue("Z17_HORAS")
	nTotHoras:= CalcTotalValue(oView) 
	oView:GetModel("Z00MASTER"):LoadValue("Z00_HORAS",nTotHoras)
	oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nTotHoras)

EndIf

oView:Refresh()

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CalcTotalValue  บAutor  ณ Fabio Rogerio  บ Data ณ17/03/21บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o DeleteLineModulo Padrao do MVC.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcTotalValue(oView)
Local oGridItem
Local oGridZ17
Local oGridZ18
Local nItem    := 0
Local nHoras   := 0
Local nHorasZ18:= 0
Local nLinha   := 0
Local nLinZ17  := 0
Local nLinZ18  := 0
Local nOpcao   := oView:GetModel():GetOperation()
Local cEscopo  := ""

If ((nOpcao <> 4) .And.;
   (nOpcao <> 3)) //.Or. (ReadVar() == "")
   Return(0)
EndIF	

//Ao deletar a linha do Modulo, deleta as linhas dos itens
If (oView:GetModel("Z01DETAIL") <> nil )
	oGridItem:= oView:GetModel('Z01DETAIL')
	nLinha:= oGridItem:GetLine()

	For nItem:= 1 To oGridItem:Length()
		oGridItem:GoLine(nItem)

		If oGridItem:GetValue("Z01_ESCOPO",nItem) == "1"
			nHoras+= oGridItem:GetValue("Z01_HORAS",nItem)
		EndIf
	Next nItem

	oGridItem:GoLine(nLinha)

ElseIf (oView:GetModel("Z18DETAIL") <> Nil)
	oGridZ18:= oView:GetModel('Z18DETAIL')
	nLinZ18:= oGridZ18:GetLine()

	For nItem:= 1 To oGridZ18:Length()
		oGridZ18:GoLine(nItem)
		
		If (nItem == nLinZ18)
			cEscopo:= IIf(Readvar() == "M->Z18_ESCOPO",M->Z18_ESCOPO,oGridZ18:GetValue("Z18_ESCOPO",nItem))
			If (cEscopo == "1") 
				nHorasZ18+= IIf(ReadVar() == "M->Z18_DIAS",M->Z18_DIAS * 10, oGridZ18:GetValue("Z18_HORAS",nItem))
			EndIf
		Else
			cEscopo:= oGridZ18:GetValue("Z18_ESCOPO",nItem)
			If (cEscopo == "1") 
				nHorasZ18+= oGridZ18:GetValue("Z18_HORAS",nItem)
			EndIf
		EndIf	
	Next nItem
	oGridZ18:GoLine(nLinZ18)

	oGridZ17:= oView:GetModel('Z17DETAIL')
	oGridZ17:LoadValue('Z17_HORAS',nHorasZ18)
	oGridZ17:SetValue('Z17_HORAS',nHorasZ18)
	nLinZ17:= oGridZ17:GetLine()

	For nItem:= 1 To oGridZ17:Length()
		oGridZ17:GoLine(nItem)
		nHoras+= oGridZ17:GetValue("Z17_HORAS",nItem)
	Next nItem

	oGridZ17:GoLine(nLinZ17)

EndIf

oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nHoras)
oView:Refresh()

Return(nHoras)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DeleteLineModulo  บAutor  ณ Fabio Rogerio  บ Data ณ17/03/21บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o DeleteLineModulo Padrao do MVC.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DeleteLineModulo(oView,cIdView,nNumLine)
Local oGridItem
Local nItem    := 0
Local nHoras   := 0
Local nHorasIt := 0

//Ao deletar a linha do Modulo, deleta as linhas dos itens
If (cIdView == 'Z17DETAIL')
	oGridItem:= oView:GetModel('Z18DETAIL')
	oGridItem:DelAllLine()

	For nItem:= 1 To oGridItem:Length()
		oGridItem:GoLine(nItem)
		nHorasIt+= oGridItem:GetValue("Z18_HORAS",nItem)
		oGridItem:LoadValue("Z18_ESCOPO","2")
	Next 
ElseIf (cIdView == 'Z18DETAIL')
	oGridItem:= oView:GetModel('Z18DETAIL')
	nHorasIt+= oGridItem:GetValue("Z18_HORAS",nNumLine)
	oGridItem:LoadValue("Z18_ESCOPO","2")
Else
	oGridItem:= oView:GetModel('Z01DETAIL')
	nHorasIt:= oGridItem:GetValue("Z01_HORAS",nNumLine)
	oGridItem:LoadValue("Z01_ESCOPO","2")
EndIf

//Se fizer parte do Escopo soma o total de horas
nHoras:= CalcTotalValue(oView) //- nHorasIt
oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nHoras)
oView:Refresh()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UnDeleteLineModulo  บAutor  ณ Fabio Rogerio  บ Data ณ17/03/21บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o UnDeleteLineModulo Padrao do MVC.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function UnDeleteLineModulo(oView,cIdView,nNumLine)
Local oGridItem
Local nItem    := 0
Local nHoras   := 0
Local nHorasIt := 0

//Ao deletar a linha do Modulo, deleta as linhas dos itens
If (cIdView == 'Z17DETAIL')
	oGridItem:= oView:GetModel('Z18DETAIL')
	For nItem:= 1 To oGridItem:Length()
		oGridItem:GoLine(nItem)
		oGridItem:UnDeleteLine()
		nHorasIt+= oGridItem:GetValue("Z18_HORAS",nItem)
		oGridItem:LoadValue("Z18_ESCOPO","1")
	Next 
ElseIf (cIdView == 'Z18DETAIL')
	oGridItem:= oView:GetModel('Z18DETAIL')
	nHorasIt+= oGridItem:GetValue("Z18_HORAS",nNumLine)
	oGridItem:LoadValue("Z18_ESCOPO","1")
Else	
	oGridItem:= oView:GetModel('Z01DETAIL')
	nHorasIt:= oGridItem:GetValue("Z01_HORAS",nNumLine)
	oGridItem:LoadValue("Z01_ESCOPO","1")
EndIf

//Se fizer parte do Escopo soma o total de horas
nHoras:= CalcTotalValue(oView) //+ nHorasIt
oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nHoras)
oView:Refresh()

Return(.T.)

/*/{Protheus.doc} LoadZ18
Carraga os dados da Z01 na Z18
@type function
@version 1.0
@author Fแbio Rog้rio
@since 31/03/2021
@return caracter, Codigo do Modulo
/*/
User Function LoadZ18()
Local cModulo := M->Z18_MODULO
Local oViewAct:= FWViewActive()
Local oModel  := oViewAct:GetModel("Z17DETAIL")
Local oGridZ18:= oViewAct:GetModel("Z18DETAIL")
Local nI      := 0 
Local nField  := 0 
Local cModulo := M->Z17_MODULO
Local oStruZ18 := FwFormStruct( 1, "Z18")
Local oStruZ01 := FwFormStruct( 1, "Z01")
Local nPos     := 0
Local cCampo   := ""
Local cCampoZ01:= ""

dbSelectArea("Z01")
dbSetOrder(1)
dbSeek(xFilial("Z01")+cModulo)

While !Eof() .And. (Z01->Z01_FILIAL == xFilial("Z01")) .And. (Z01->Z01_MODULO == cModulo)
	nI++ 

	If (nI > 1)
		oGridZ18:AddLine()
	EndIf	

	For nField:= 1 To Len(oStruZ01:aFields)
		cCampoZ01:= oStruZ01:aFields[nField,3]
		cCampo:= "Z18" + SubString(cCampoZ01,4,Len(cCampoZ01))
		nPos:= aScan(oStruZ18:aFields,{|x| x[3] == cCampo})
		If (nPos > 0)
			oGridZ18:SetValue(cCampo,Z01->(FieldGet(FieldPos(cCampoZ01))))
		EndIf	
	Next

	dbSelectArea("Z01")
	dbSkip()
End

oGridZ18:GoLine(1)
oViewAct:Refresh("Z17DETAIL")
oViewAct:Refresh("Z18DETAIL")
oViewAct:Refresh()

Return(M->Z17_MODULO)
