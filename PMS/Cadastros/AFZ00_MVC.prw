#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

#Define GD_INSERT 1
#Define GD_UPDATE 2
#Define GD_DELETE 4

/*  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ALFACadMod บ Autor ณ  Fabio Rogerio    บ Data ณ  05/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Modulos/Cursos.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AFZ00_MVC()

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

oModel:= MpFormMOdel():New( "AFZ00MVC" ,  /*bPreValid*/ , {|oModel| VldTdOk(oModel) } /*bPostValid*/, /*bComValid*/ ,/*bCancel*/ )


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

Local oModel 	:= FwLoadModel("AFZ00_MVC")
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
ฑฑบDesc.     ณ Monta o Menu Padrao do MVC.                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"        	ACTION "PesqBrw"			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"       	ACTION "VIEWDEF.AFZ00_MVC" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"       		ACTION "VIEWDEF.AFZ00_MVC" 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"       		ACTION "VIEWDEF.AFZ00_MVC" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"       		ACTION "VIEWDEF.AFZ00_MVC" 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Importar Escopo"      ACTION "U_AFIMPESCOPO"	 	OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Copiar"               ACTION "VIEWDEF.AFZ00_MVC"	OPERATION 9 ACCESS 0

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
Local oStruZ24 := FwFormStruct( 1, "Z24",{|cCampo| !(AllTrim(cCampo) $ "Z24_MODULO|" )})


oStruZ00:AddTrigger( "Z00_FORNEC", "Z00_MODULO", {|| .T. }, {|oModel| GtZ00Modulo()  }  )
oStruZ00:SetProperty( 'Z00_MODULO' , MODEL_FIELD_WHEN, {|| .F. } )

oStruZ24:AddTrigger( "Z24_MARKUP", "Z24_PRCTAB", {|| .T. }, {|oModel| oModel:GetValue("Z24_MARKUP")*oModel:GetValue("Z24_CUSTO")  }  )
oStruZ24:AddTrigger( "Z24_CUSTO", "Z24_PRCTAB" , {|| .T. }, {|oModel| oModel:GetValue("Z24_MARKUP")*oModel:GetValue("Z24_CUSTO")  }  )

oStruZ24:AddTrigger( "Z24_PRCTAB", "Z24_PRCVEN" , {|| .T. }, {|oModel|oModel:GetValue("Z24_PRCTAB")-( oModel:GetValue("Z24_PRCTAB")* oModel:GetValue("Z24_DESCON")/100  )  }  )
oStruZ24:AddTrigger( "Z24_DESCON", "Z24_PRCVEN" , {|| .T. }, {|oModel|oModel:GetValue("Z24_PRCTAB")-( oModel:GetValue("Z24_PRCTAB")* oModel:GetValue("Z24_DESCON")/100  )  }  )

oStruZ24:AddTrigger( "Z24_PRCVEN", "Z24_LUCRO" , {|| .T. }, {|oModel| oModel:GetValue("Z24_PRCVEN")-oModel:GetValue("Z24_CUSTO")  }  )
oStruZ24:AddTrigger( "Z24_PRCVEN", "Z24_MLUCRO" , {|| .T. }, {|oModel| ROUND( ( oModel:GetValue("Z24_PRCVEN")-oModel:GetValue("Z24_CUSTO") )/oModel:GetValue("Z24_PRCVEN") * 100 , 2) }  )
/*
oStruZ24:SetProperty( 'Z24_PRCTAB'  , MODEL_FIELD_WHEN, {|| .F. } )
oStruZ24:SetProperty( 'Z24_PRCVEN' , MODEL_FIELD_WHEN, {|| .F. } )
*/
//oStruZ24:SetProperty( 'Z24_QTDMIN' , MODEL_FIELD_WHEN, {|| .F. } )
oStruZ24:SetProperty( 'Z24_MLUCRO' , MODEL_FIELD_WHEN, {|| .F. } )
oStruZ24:SetProperty( 'Z24_LUCRO'  , MODEL_FIELD_WHEN, {|| .F. } )



//oStruZ24:SetProperty( "Z24_QTDMIN" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z24_QTDMIN') } )
oStruZ24:SetProperty( "Z24_QTDMAX" , MODEL_FIELD_VALID , {|oModel| VldGridTdOk(oModel,'Z24_QTDMAX') } )

oStruZ24:SetProperty("Z24_QTDMIN" , MODEL_FIELD_INIT, { |oModel| AltIniPad(oModel,'Z24_QTDMAX') }  )
oStruZ24:SetProperty("Z24_QTDMAX" , MODEL_FIELD_INIT, { |oModel| AltIniPad(oModel,'Z24_QTDMAX') }  )
oStruZ24:SetProperty("Z24_FILIAL" , MODEL_FIELD_INIT, { |oModel| xFilial('Z24') }  )

oModel:AddFields("Z00MASTER", Nil, oStruZ00, /*prevalid*/, , /*bCarga*/)
oModel:SetPrimaryKey({'Z00_FILIAL', 'Z00_MODULO'})  
oModel:SetDescription("Licencas")

oModel:AddGrid  ('Z24GRID' , 'Z00MASTER',     oStruZ24, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )                       
oModel:SetRelation( "Z24GRID", { { "Z24_FILIAL", "xFilial('Z24')" }, { "Z24_MODULO", "Z00_MODULO" } }, Z24->( IndexKey( 1 ) ) )

oModel:GetModel( "Z00MASTER" ):SetDescription( "Licencas" )
oModel:GetModel( "Z24GRID" ):SetDescription( "Tabela de Preco" )

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

oStruZ00:AddTrigger( "Z00_FORNEC", "Z00_MODULO", {|| .T. }, {|oModel| GtZ00Modulo()  }  )
oStruZ00:SetProperty( 'Z00_MODULO' , MODEL_FIELD_WHEN, {|| .F. } )

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

oStruZ00:AddTrigger( "Z00_FORNEC", "Z00_MODULO", {|| .T. }, {|oModel| GtZ00Modulo()  }  )
oStruZ00:SetProperty( 'Z00_MODULO' , MODEL_FIELD_WHEN, {|| .F. } )

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
Local oStruZ24  := FwFormStruct( 2, "Z24",{|cCampo| !(AllTrim(cCampo) $ "Z24_MODULO|" )} )

oView:AddField("VIEW_Z00", oStruZ00 , "Z00MASTER")
oView:AddGrid ( "VIEW_Z24", oStruZ24,  "Z24GRID" )

oView:CreateHorizontalBox("SUPERIOR", 50)
oView:CreateHorizontalBox("INFERIOR", 50)

oView:AddIncrementField( 'VIEW_Z24', 'Z24_ITEM' )

oView:SetOwnerView("VIEW_Z00", "SUPERIOR")
oView:SetOwnerView("Z24GRID", "INFERIOR")

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
Local nLinZ18  := 0
Local oGridZ01
Local oGridZ18
Local nDefHors := SuperGetMv("AF_DEFHORA",.F. , 8 )

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
		nHoras:= xValue * nDefHors//10
		oGridZ01:LoadValue('Z01_DIAS',xValue)	
		oGridZ01:LoadValue('Z01_HORAS',nHoras)		
	EndIf

	nTotHoras:= CalcTotalValue(oView) 
	oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nTotHoras)
ElseIf (cIdView == "VIEW_Z18")	
	oGridZ18:= oView:GetModel("Z18DETAIL")
	nLinZ18:= oGridZ18:GetLine()

	If (cField == "Z18_ESCOPO")
		oGridZ18:LoadValue('Z18_ESCOPO',xValue)	

		If (xValue == "2")
			nHoras:= oGridZ18:GetValue('Z18_HORAS')
		EndIf	
	ElseIf (cField == "Z18_DIAS")
		oGridZ18:LoadValue('Z18_DIAS',xValue)	
		oGridZ18:LoadValue('Z18_HORAS',xValue * nDefHors)		
	EndIf

	nHorasZ17:= oView:GetModel("Z17DETAIL"):GetValue("Z17_HORAS")
	nTotHoras:= CalcTotalValue(oView) 
	oView:GetModel("Z00MASTER"):LoadValue("Z00_HORAS",nTotHoras)
	oView:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nTotHoras)
	oGridZ18:GoLine(nLinZ18)

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
Local nHorasGP := 0
Local nLinha   := 0
Local nLinZ17  := 0
Local nLinZ18  := 0
Local nOpcao   := oView:GetModel():GetOperation()
Local cEscopo  := ""
Local nDefHors := SuperGetMv("AF_DEFHORA",.F. , 8 )
Local cProdGP  := GetNewPar("MV_AFGP","SAP-I001") //Produto do Gerente de Projeto SAP
Local cProdGPFS:= GetNewPar("MV_AFGPFS","SAP-I003") //Produto do Gerente de Desenvolvimento SAP

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
				nHorasZ18+= IIf(ReadVar() == "M->Z18_DIAS",M->Z18_DIAS * nDefHors, oGridZ18:GetValue("Z18_HORAS",nItem))
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

		//Nao soma as horas de GP pois sera recalculadas.
		If (oGridZ17:GetValue("Z17_MODULO",nItem) <> cProdGP)
			nHoras+= oGridZ17:GetValue("Z17_HORAS",nItem)
		EndIf	
	Next nItem

	oGridZ17:GoLine(nLinZ17)

	//Verifica se existe a linha da coordenacao e recalcula as horas de GP e do Projeto
	//$ (cProdGP+"/"+cProdGPFS)
	nLinZ17:= oGridZ17:GetLine()
	If oGridZ17:SeekLine({{"Z17_MODULO",cProdGP}},.F.,.T.)
		nHorasGP:= Round(nHoras * 0.2,0)
		nHoras  += nHorasGP
		oGridZ17:LoadValue('Z17_HORAS',nHorasGP)
		oGridZ17:SetValue('Z17_HORAS',nHorasGP)

		oGridZ17:GoLine(nLinZ17)
	EndIf	
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
Local nLinha   := 0
Local nTotHoras:= 0

dbSelectArea("Z01")
dbSetOrder(1)
dbSeek(xFilial("Z01")+cModulo)

While !Eof() .And. (Z01->Z01_FILIAL == xFilial("Z01")) .And. (Z01->Z01_MODULO == cModulo)
	nI++ 

	If (nI > 1)
		nLinha:= oGridZ18:AddLine()
		oGridZ18:SetLine(nLinha)
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

nTotHoras:= CalcTotalValue(oViewAct) 
oViewAct:GetModel("Z00MASTER"):LoadValue("Z00_HORAS",nTotHoras)
oViewAct:GetModel("Z00MASTER"):SetValue("Z00_HORAS",nTotHoras)


Return(M->Z17_MODULO)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldGridTdOk 
@type				: Funcao estatica
@Sample				: VldGridTdOk(oModel)
@description	    : Realiza a valida็ใo do modelo de dados para o mesmo ser ativado.						
@Param				: oModel - Model a ser validado
@return				: lRet - .T. = Sucesso = .F. Erro
@ ------------------|----------------
@author				: Pedro Henrique Oliveira
@since				: 11/04/2019
@version			: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Static Function VldGridTdOk(oModel,cCampo)
Local oModel    := FwModelActive()
Local nOperation    := oModel:GetOperation()
Local lRet          := .T.
Local aArea 		:= GetArea()   
Local oGrid    		:= oModel:GetModel("Z24GRID")
Local nLinAtu 		:= oGrid:GetLine() 
Local xValCpo       := oGrid:GetValue( cCampo , oGrid:GetLine()  )   

If nOperation ==  MODEL_OPERATION_INSERT .OR.  nOperation ==  MODEL_OPERATION_UPDATE

	If cCampo == 'Z24_QTDMAX'
		If xValCpo <= 0					
			Help(,, 'HELP',, "Valor informado deve ser maior que ZERO.", 1, 0)				 
			lRet := .f.
		EndIf 

		If oGrid:GetLine()   > 1   .And. oGrid:GetValue( cCampo, oGrid:GetLine() - 1 ) >= xValCpo 
			Help(,, 'HELP',, "Valor informado deve ser maior que a linha anterior.", 1, 0)				 
			lRet := .f.
		EndIf 

		If oGrid:Length() >  nLinAtu .And. xValCpo >= oGrid:GetValue( 'Z24_QTDMIN', oGrid:GetLine() + 1 )  
			Help(,, 'HELP',, "Valor informado deve ser menor que a proxima linha.", 1, 0)				 
			lRet := .f.
		EndIf

	EndIf		 			

EndIf

RestArea(aArea)

Return(lRet)

Static Function AltIniPad(oModel,cCampo)

Local nRet 	   := 1
Local oModel   := FwModelActive()
Local oGrid    := oModel:GetModel("Z24GRID")

If oGrid:GetLine() > 1
	nRet:=   oGrid:GetValue( cCampo , oGrid:GetLine()  )  +1 
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GtZ00Modulo()
Preenche sequencial o codigo do modulo
@author Pedro Henrique Oliveira
@since  19/01/2022
@version 12
/*/ 
//-------------------------------------------------------------------
Static Function GtZ00Modulo()
Local oModel   := FWModelActive()
Local oAux     := oModel:GetModel( 'Z00MASTER' )
Local cRet 	   := ''
Local cFornece := oAux:GetValue('Z00_FORNEC') 
Local cQuery   := ''
Local cTmp:= GetNextAlias()
cQuery+= " SELECT ISNULL(MAX(Z00_MODULO),'') Z00_MODULO FROM "+RetSqlName("Z00")+" Z00"+CRLF
cQuery+= " WHERE "+CRLF
cQuery+= " 	Z00_FILIAL = '"+xFilial("Z00")+"'"+CRLF
cQuery+= " AND Z00_FORNEC = '"+cFornece+"'"+CRLF
cQuery+= " AND SUBSTRING(Z00_MODULO,1,6) = '"+cFornece+"'"+CRLF
cQuery+= " AND Z00.D_E_L_E_T_ = ''"+CRLF
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cTmp ,.T.,.T.)

If (cTmp)->( !Eof())
	cRet:= cFornece + "-" +soma1(   RIGHT( (cTmp)->Z00_MODULO,3 ) )
Else
	cRet:= cFornece+'-001'
EndIf

Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldTdOk 
@type				: Funcao estatica
@Sample				: VldTdOk(oModel)
@description	    : Realiza a valida็ใo do modelo de dados para o mesmo ser ativado.						
@Param				: oModel - Model a ser validado
@return				: lRet - .T. = Sucesso = .F. Erro
@ ------------------|----------------
@author				: Pedro Henrique Oliveira
@since				: 19/01/2022
@version			: Protheus 12.1.17
/*/
//------------------------------------------------------------------------------------------
Static Function VldTdOk(oModel)

Local nOperation    := oModel:GetOperation()
Local lRet          := .T.
Local aArea := GetArea()   
Local oField    := oModel:GetModel("Z00MASTER")

If nOperation ==  MODEL_OPERATION_INSERT .OR.  nOperation ==  MODEL_OPERATION_UPDATE
	oField:SetValue( "Z00_DTATU" ,date())
EndIf

RestArea(aArea)

Return(lRet)
