
#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} ALFAHAND
 
Descricao: Cadastro de handover

@author Pedro Oliveira
@since 13/02/2023
@version P12
/*/
//-------------------------------------------------------------------
User Function ALFAHAND()

Local oBrowse

Private aRotina 	:= FwLoadMenuDef('ALFAHAND')

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'SZK' )
oBrowse:SetDescription( 'Cadastro de handover' )
oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()     

Private aRotina        := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"  		    OPERATION 0 ACCESS 0 
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ALFAHAND"     OPERATION 1 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.ALFAHAND"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.ALFAHAND"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.ALFAHAND"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0  

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructSZK := FWFormStruct(1,"SZK", ) // Informe os campos que eu quero no cabecalho
Local oModel := Nil  // objeto modelo
//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("M_ALFAHAND",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
//oStructSZK:SetProperty( "Z2_LINHA" , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'Z2_LINHA') } )

//oStructIt:SetProperty( "ZK_PERC"   , MODEL_FIELD_VALID , {|oModel| VldTdOk(oModel,'ZK_PERC') } )


oModel:AddFields("SZKMASTER", Nil/*cOwner*/, oStructSZK ,/*Pre-Validacao*/,/*Pos-Valid*/,/*Carga*/)
oModel:SetPrimaryKey( { "ZK_FILIAL","ZK_PROPOS","ZK_ADITIV"})

oModel:GetModel("SZKMASTER"):SetDescription('Cadastro de hadover')//"Linhas"

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Pedro Henrique Oliveira
@since 04/05/2018
@version P12
*/ 
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("ALFPMS41")
Local oStructSZK   := FWFormStruct(2,"SZK", ) // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWSZK" , oStructSZK, "SZKMASTER" )
 
//oView:AddOtherObject("VIEW_OTHER", {|oPanel| fCustom(oPanel)})
oView:AddOtherObject("VIEW_OTHER1", {|oPanel| fContatos(oPanel)})
oView:AddOtherObject("VIEW_OTHER2", {|oPanel| fCustom(oPanel)})
oView:AddOtherObject("VIEW_OTHER3", {|oPanel| fCustom(oPanel)})


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

//Cria o controle de Abas
oView:CreateFolder('ABAS','INFERIOR')
oView:AddSheet('ABAS', 'ABA_PRIN', 'Contatos')
oView:AddSheet('ABAS', 'ABA_SECU', 'Produtos e Serviços Contratados ')
oView:AddSheet('ABAS', 'ABA_TERC', 'Itens da proposta')

//Cria os Box que serão vinculados as abas
oView:CreateHorizontalBox( 'BOX_PRIN' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_PRIN')
oView:CreateHorizontalBox( 'BOX_SECU' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_SECU')
oView:CreateHorizontalBox( 'BOX_TERC' ,100, /*owner*/, /*lUsePixel*/, 'ABAS', 'ABA_TERC')

//Amarra as Abas aos Views de Struct criados
oView:SetOwnerView('VIEW_OTHER1','BOX_PRIN')
oView:SetOwnerView('VIEW_OTHER2','BOX_SECU')
oView:SetOwnerView('VIEW_OTHER3','BOX_TERC')

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWSZK' , 'SUPERIOR' )
//oView:SetOwnerView( 'VIEWGSZK', 'INFERIOR' )

//Titulos
oView:EnableTitleView('VIEWSZK'    , "HandOver")
oView:EnableTitleView("VIEW_OTHER1", "Contatos")
oView:EnableTitleView("VIEW_OTHER2", "Produtos e Serviços Contratados")
oView:EnableTitleView("VIEW_OTHER3", "Itens da proposta")


Return oView

User Function AFHANDCAD(cProposta,cAditivo,lVisual)

Local nOpc    := iif(lVisual, 1 , MODEL_OPERATION_UPDATE) 
Local cTela   := "Cadastro de HandOver"

oModel := FWLoadModel("ALFAHAND")

SZK->(DBSETORDER( 1 ))
IF SZK->( MSSEEK( XFILIAL('SZK')+cProposta + cAditivo ))	    
	FWExecView(cTela, "ALFAHAND", nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aBtnView*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel)
ELSE
	nOpc    := MODEL_OPERATION_INSERT
	oModel:SetOperation( nOpc )
	oModel:Activate()	
	oStrCabc := oModel:GetModel( 'SZKMASTER' )  
    oStrCabc:SetValue('ZK_PROPOS'   , Z02->Z02_PROPOS )
    oStrCabc:SetValue('ZK_ADITIV'   , Z02->Z02_ADITIV )
	oStrCabc:SetValue('ZK_CLIENTE'  , Z02->Z02_CLIENT )
	oStrCabc:SetValue('ZK_LOJA'  	, Z02->Z02_LOJA )
	//oStrCabc:SetValue('ZK_NOME'  	, Z02->Z02_NOME )

	FWExecView(cTela, "ALFAHAND", nOpc, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/, /*aBtnView*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModel)
END


oModel:Destroy()

Return

Static Function fCustom(oPanel)
    Local aArea       := FWGetArea()
    Local cFontNome   := "Tahoma"
    Local oFontPadrao := TFont():New(cFontNome, , -12)
    Local lDimPixels  := .T.
    local nSaldo := 0
    //objeto2 - usando a classe TSay
    nObjLinha := 18
    nObjColun := 4
    nObjLargu := 45
    nObjAltur := 6
    oSayObj   := TSay():New(nObjLinha, nObjColun, {|| "Saldo Produto:"}, oPanel, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)  
    //objeto3 - usando a classe TGet
    nObjLinha := 16
    nObjColun := 49
    nObjLargu := 100
    nObjAltur := 10
    oGetObj   := TGet():New(nObjLinha, nObjColun, {|| nSaldo}, oPanel, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
    oGetObj:lReadOnly  := .T.
  
    FWRestArea(aArea)
Return


Static Function fContatos(oPanel)
    Local aArea       := FWGetArea()

    Local aAlterSU5   := {}
    Local oModel      := FwModelActive()
    Local nOperation  := oModel:GetOperation()
    Local nStyle 	  := GD_INSERT+GD_UPDATE+GD_DELETE
    LOCAL aColsSU5    := {}
    LOCAL aHeaderSU5  := {}

    MontaSU5(@aColsSU5,@aHeaderSU5,Z02->Z02_TIPO)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Panel 1. - IdentIFicacao Proposta ³	
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF nOperation <> 1
        Aadd(aAlterSU5,"U5_CONTAT")
        Aadd(aAlterSU5,"U5_SOBREN")
        Aadd(aAlterSU5,"U5_EMAIL")
        Aadd(aAlterSU5,"U5_DDD")
        Aadd(aAlterSU5,"U5_FCOM1")
        Aadd(aAlterSU5,"U5_CELULAR")
        Aadd(aAlterSU5,"U5_FUNCAO")
        Aadd(aAlterSU5,"U5_XAPROV")
    EndIf


    oContatos:= MsNewGetDados():New(0,0,0,0,nStyle,"AllWaysTrue"	,"AllWaysTrue",,aAlterSU5,,99999,,,,oPanel,@aHeaderSU5,@aColsSU5)
    oContatos:oBrowse:Refresh()
    oContatos:nAt:= 1
    oContatos:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    //oContatos:bChange := {|| SetaContato(nOpc,@oProposta)}


    //Local cFontNome   := "Tahoma"
    //Local oFontPadrao := TFont():New(cFontNome, , -12)
    //Local lDimPixels  := .T.
    //local nSaldo := 0
    ////objeto2 - usando a classe TSay
    //nObjLinha := 18
    //nObjColun := 4
    //nObjLargu := 45
    //nObjAltur := 6
    //oSayObj   := TSay():New(nObjLinha, nObjColun, {|| "Saldo Produto:"}, oPanel, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)
  //
    ////objeto3 - usando a classe TGet
    //nObjLinha := 16
    //nObjColun := 49
    //nObjLargu := 100
    //nObjAltur := 10
    //oGetObj   := TGet():New(nObjLinha, nObjColun, {|| nSaldo}, oPanel, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
    //oGetObj:lReadOnly  := .T.
  
    FWRestArea(aArea)
Return


Static Function MontaSU5(aColsSU5,aHeaderSU5,cTipo)

Local aArea    := GetArea()
Local nX       := 0

aColsSU5  := {}
aHeaderSU5:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeaderSU5 a partir dos campos do SX3         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetorder(1)
MsSeek('SU5')
While !Eof() .And. (SX3->X3_ARQUIVO == 'SU5' )

	//Nao exibe campos nao necessarios
	If !Alltrim(SX3->X3_CAMPO) $ "U5_CODCONT/U5_CONTAT/U5_SOBREN/U5_DDD/U5_FCOM1/U5_CELULAR/U5_FUNCAO/U5_DFUNCAO/U5_EMAIL/U5_XAPROV"
		SX3->(DbSkip())
		Loop
	EndIf    

	IF X3Uso(X3_USADO) .And. (cNivel >= SX3->X3_NIVEL)
		AADD(aHeaderSU5,{ TRIM(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE,	SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT, SX3->(X3cBox()),SX3->X3_RELACAO,SX3->X3_WHEN,SX3->X3_VISUAL,SX3->X3_VLDUSER,"",.F.  } )
		
	EndIF
	
	SX3->(DbSkip())
	
EndDo

cQuery := " SELECT SU5.R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName("SU5") + " SU5, "
cQuery += RetSqlName("AC8") + " AC8 "
cQuery += " WHERE SU5.U5_FILIAL = '" 	+ xFilial("SU5") 	+ "'"
cQuery += " AND SU5.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.D_E_L_E_T_ 	= ' ' "
cQuery += " AND AC8.AC8_FILIAL  = SU5.U5_FILIAL "
cQuery += " AND SU5.U5_CODCONT	= AC8.AC8_CODCON "

If !Empty(Z02->Z02_CLIENT)
	cQuery += " AND  AC8.AC8_ENTIDA = 'SA1' AND AC8.AC8_CODENT = '" + Z02->Z02_CLIENT+Z02->Z02_LOJA + "'"
Else
	cQuery += " AND  AC8.AC8_ENTIDA = 'SUS' AND AC8.AC8_CODENT = '" + Z02->Z02_PROSPE+Z02->Z02_LOJAPR + "'"
EndIf

cQuery += " AND SU5.U5_MSBLQL <> '2'"
cQuery += " ORDER BY U5_CONTAT"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

DbSelectArea("TMP")
DbGoTop()
While !Eof()
	
	DbSelectarea("SU5")
	DbGoto( TMP->RECNO )
	
	Aadd(aColsSU5,Array(Len(aHeaderSU5)+1))
	For nX	:= 1 To Len(aHeaderSU5)
		IF ( aHeaderSU5[nX][10] != "V" )
			aColsSU5[Len(aColsSU5)][nX] := FieldGet(FieldPos(aHeaderSU5[nX][2]))
		Else
			aColsSU5[Len(aColsSU5)][nX] := CriaVar(aHeaderSU5[nX][2])
		EndIF
	Next nX
	aColsSU5[Len(aColsSU5)][Len(aHeaderSU5)+1] := .F.
	
	DbSelectarea("TMP")
	DbSkip()
	
EndDo
TMP->(DbCloseArea())

IF Len(aColsSU5) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aCols auxiliares vazios.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aColsSU5,Array(Len(aHeaderSU5)+1))
	For nX := 1 To Len(aHeaderSU5)
		aColsSU5[Len(aColsSU5),nX] := CriaVar(aHeaderSU5[nX,2])
	Next nX
	aColsSU5[Len(aColsSU5),Len(aHeaderSU5)+1] := .F.
EndIF

RestArea(aArea)

Return(.T.)
