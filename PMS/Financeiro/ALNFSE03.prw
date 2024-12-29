#Include "FWBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "protheus.ch" 
#Include "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALNFSE03
Monitor da NFS-e
@author  Victor Andrade
@since   27/03/2018
@version 1
/*/
//-------------------------------------------------------------------

User Function ALNFSE03()

Local aArea := GetArea()

Private oBrwSE1	:= Nil
Private oDlgSE1	:= Nil
Private aTitSE1	:= {}

IF Empty(SE1->E1_PREFIXO)
	MsgAlert( "Falta incluir o PREFIXO do Titulo para emitir a NFS-e.", "Atenção" )	
	Return(.T.)
EndIF

// Alimenta o array com os dados do título
AL03Refresh(.F.)

// Mostra a tela
AL03View()

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AL03View
Monta a Tela
@author  Victor Andrade
@since   27/03/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL03View()

Local oFnt
Local oPanelBrw
Local oPanelBT
Local oPropos
Local oNomCli
Local oEmissao
Local oVencRea
Local oContato
Local oEmail
Local oMsgNF  
Local oMsgMail
Local oDesPro
Local oCobranca
Local oAssunto
Local oPanelCabec
Local oFolderMsg
Local oPanelDados
Local oPanelMsgNF
Local oPanelMsgMail
Local oPanelCobranca
Local lSair		:= .F.
Local oLayer    := FWLayer():New()
Local aSizeSE1	:= {05,05,480,1000}
Local cMsgNF	:= aTitSE1[1,12]
Local cMsgMail	:= aTitSE1[1,18]
Local cCobranca := aTitSE1[1,19]
Local cAssunto 	:= aTitSE1[1,20]
Local cPropos	:= 'Proposta: ' + aTitSE1[1,13]
Local cNomCli	:= 'Cliente:  ' + Alltrim(Posicione('SA1',1,xFilial('SA1')+aTitSE1[1,15],'A1_NREDUZ'))
Local cEmissao	:= 'Emissao:    ' + Dtoc(aTitSE1[1,16])
Local cVencRea	:= 'Vencimento: ' + Dtoc(aTitSE1[1,17])
Local cDesPro 	:= Posicione('Z02',1,xFilial('Z02')+aTitSE1[1,13]+aTitSE1[1,14],'Z02_DESCRI')
Local cContato 	:= Posicione('SA1',1,xFilial('SA1')+aTitSE1[1,15],'A1_NOMENFS')
Local cEmail 	:= Posicione('SA1',1,xFilial('SA1')+aTitSE1[1,15],'A1_EMAILNF')

DEFINE FONT oFnt NAME "Courier New" SIZE 0,-14 BOLD 

oDlgSE1 := TDialog():New(aSizeSE1[1],aSizeSE1[2],aSizeSE1[3],aSizeSE1[4],'Monitor de NFS-e',,,,,CLR_BLACK,CLR_WHITE,,,.T.)

oLayer:Init( oDlgSE1, .F. )

oLayer:AddLine("CABEC"    	, 55, .F., )
oLayer:AddLine("ARRAY"    	, 20, .F., )
oLayer:AddLine("BOTOES" 	, 25, .F., )

oPanelCabec	:= oLayer:GetLinePanel( "CABEC" )
oPanelBrw 	:= oLayer:GetLinePanel( "ARRAY" )
oPanelBt  	:= oLayer:GetLinePanel( "BOTOES" )

oFolderMsg		:= TFolder():New(0,0,{'Dados Básicos','NFS-e: Incluir Mensagens','E-mail: Incluir Observações','Cobrança - Histórico'},,oPanelCabec,,,,.T.,.F.,0,0)
oFolderMsg:Align := CONTROL_ALIGN_ALLCLIENT

oPanelDados		:= TPanel():New(0, 0,'',oFolderMsg:aDialogs[1],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelDados:Align := CONTROL_ALIGN_ALLCLIENT

oPanelMsgNF		:= TPanel():New(0, 0,'',oFolderMsg:aDialogs[2],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelMsgNF:Align := CONTROL_ALIGN_ALLCLIENT

oPanelMsgMail	:= TPanel():New(0, 0,'',oFolderMsg:aDialogs[3],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelMsgMail:Align := CONTROL_ALIGN_ALLCLIENT

oPanelCobranca	:= TPanel():New(0, 0,'',oFolderMsg:aDialogs[4],Nil, .T., .F., Nil, Nil,0,0, .T. , .F.)
oPanelCobranca:Align := CONTROL_ALIGN_ALLCLIENT

oNomCli	:= TSay():New(005,005,{|| cNomCli }	,oPanelDados,,oFnt,,,,.T.,CLR_BLUE,CLR_WHITE,200,12)
oPropos	:= TSay():New(020,005,{|| cPropos }	,oPanelDados,,oFnt,,,,.T.,CLR_BLUE,CLR_WHITE,200,12)
oEmissao:= TSay():New(005,300,{|| cEmissao }	,oPanelDados,,oFnt,,,,.T.,CLR_BLUE,CLR_WHITE,200,12)
oVencRea:= TSay():New(020,300,{|| cVencRea }	,oPanelDados,,oFnt,,,,.T.,CLR_RED,CLR_WHITE,200,12)

oDesPro		:= TGet():New(030,005,bSetGet(cDesPro)		,oPanelDados,420,012,X3Picture('Z02_DESCRI'),,,,,,,!Empty(cPropos),,,,,,,,,,,,,,,,,"Descr.Proposta: ",2,,CLR_BLUE,"Digite...")
oDesPro:bChange := {|| AtuHist('Z02_DESCRI',cDesPro) } 

oContato	:= TGet():New(045,005,bSetGet(cContato)	,oPanelDados,420,012,X3Picture('A1_NOMENFS'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Contato NFS-e: ",2,,CLR_BLUE,"Digite...")
oContato:bChange := {|| AtuHist('A1_NOMENFS',cContato) } 

oEmail		:= TGet():New(060,005,bSetGet(cEmail)	,oPanelDados,420,012,X3Picture('A1_EMAILNF'),,,,,,,.T.,,,,,,,,,,,,,,,,,"E-mail da NFS-e: ",2,,CLR_BLUE,"Digite...")
oEmail:bChange := {|| AtuHist('A1_EMAILNF',cEmail) } 

oAssunto		:= TGet():New(075,005,bSetGet(cAssunto) ,oPanelDados,420,012,X3Picture('E1_HIST'),,,,,,,.T.,,,,,,,,,,,,,,,,,"Assunto do E-mail: ",2,,CLR_RED,"Digite...")
oAssunto:bChange := {|| AtuHist('E1_HIST',cAssunto) } 

oMsgNF 				:= TMultiGet():new(000,000, {| u | if( pCount() > 0, cMsgNF := u, cMsgNF ) }, oPanelMsgNF,000,000, , , , , , .T. )
oMsgNF:Align 		:= CONTROL_ALIGN_ALLCLIENT
oMsgNF:bChange		:= {|| AtuHist('E1_MSGNF',cMsgNF) }

oMsgMail 			:= TMultiGet():new(000,000, {| u | if( pCount() > 0, cMsgMail := u, cMsgMail ) }, oPanelMsgMail,000,000, , , , , , .T. )
oMsgMail:Align		:= CONTROL_ALIGN_ALLCLIENT
oMsgMail:bChange	:= {|| AtuHist('E1_MSGMAIL',cMsgMail) }

oCobranca 			:= TMultiGet():new(000,000, {| u | if( pCount() > 0, cCobranca := u, cCobranca ) }, oPanelCobranca,000,000, , , , , , .T. )
oCobranca:Align 	:= CONTROL_ALIGN_ALLCLIENT
oCobranca:bChange	:= {|| AtuHist('E1_OBSCOBR',cCobranca) }

@ 005,010 BITMAP oBmp RESNAME "BR_AZUL"			SIZE 16,16 NOBORDER OF oPanelBt PIXEL 
@ 015,010 BITMAP oBmp RESNAME "BR_AMARELO" 		SIZE 16,16 NOBORDER OF oPanelBt PIXEL 
@ 025,010 BITMAP oBmp RESNAME "BR_VERMELHO"		SIZE 16,16 NOBORDER OF oPanelBt PIXEL
@ 005,150 BITMAP oBmp RESNAME "BR_CINZA" 		SIZE 16,16 NOBORDER OF oPanelBt PIXEL
@ 015,150 BITMAP oBmp RESNAME "BR_VERDE"		SIZE 16,16 NOBORDER OF oPanelBt PIXEL
@ 025,150 BITMAP oBmp RESNAME "BR_LARANJA" 		SIZE 16,16 NOBORDER OF oPanelBt PIXEL
                              `
@ 005,020 SAY "Registro não transmitido"		OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
@ 015,020 SAY "Aguardando Retorno" 				OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
@ 025,020 SAY "Retornado com Inconsistência" 	OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
@ 005,160 SAY "Aguardando Autorização" 			OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
@ 015,160 SAY "Nota Fiscal Autorizada" 			OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15
@ 025,160 SAY "Nota Fiscal Cancelada"			OF oPanelBt FONT oFnt  COLOR CLR_BLACK 	Pixel SIZE 150,15

TButton():New( 005, 300, "Cancelar Nota"  	, oPanelBt, {|| U_ALNFSE04()		, AL03Refresh(.T.)	}, 80,12,,,.F.,.T.,.F.,,.F.,{ || SE1->E1_XSTNFS == "4"  	},,.F. )
TButton():New( 020, 300, "Enviar Boleto"  	, oPanelBt, {|| U_ALEnviaBoletos()	, AL03Refresh(.T.)	}, 80,12,,,.F.,.T.,.F.,,.F.,{ || .T. 						},,.F. )
TButton():New( 005, 400, "Transmitir Nota"	, oPanelBt, {|| U_ALNFSE01()		, AL03Refresh(.T.)	}, 80,12,,,.F.,.T.,.F.,,.F.,{ || SE1->E1_XSTNFS $ " |1|2"	},,.F. )
TButton():New( 020, 400, "Consultar Nota"  	, oPanelBt, {|| U_ALNFSE02()		, AL03Refresh(.T.)	}, 80,12,,,.F.,.T.,.F.,,.F.,{ || SE1->E1_XSTNFS $ "1|2|3|4"	},,.F. )
TButton():New( 035, 300, "Sair"    			, oPanelBt, {|| lSair := .T.		, oDlgSE1:End()		},180,20,,,.F.,.T.,.F.,,.F.,{ || .T.						},,.F. )

DEFINE FWBROWSE oBrwSE1 DATA ARRAY ARRAY aTitSE1 NO SEEK NO CONFIG NO REPORT NO LOCATE Of oPanelBrw

ADD LEGEND DATA {|| Empty( aTitSE1[ oBrwSE1:At(), 11 ] ) }	COLOR "BR_AZUL"    	TITLE "Registro não transmitido"	 Of oBrwSE1
ADD LEGEND DATA {|| aTitSE1[ oBrwSE1:At(), 11 ] == "1" }  	COLOR "BR_AMARELO"	TITLE "Aguardando Retorno"  		 Of oBrwSE1
ADD LEGEND DATA {|| aTitSE1[ oBrwSE1:At(), 11 ] == "2" }  	COLOR "BR_VERMELHO"	TITLE "Retornado com Inconsistência" Of oBrwSE1
ADD LEGEND DATA {|| aTitSE1[ oBrwSE1:At(), 11 ] == "3" }  	COLOR "BR_CINZA"   	TITLE "Aguardando Autorização"       Of oBrwSE1
ADD LEGEND DATA {|| aTitSE1[ oBrwSE1:At(), 11 ] == "4" }  	COLOR "BR_VERDE"   	TITLE "Nota Fiscal Autorizada"       Of oBrwSE1
ADD LEGEND DATA {|| aTitSE1[ oBrwSE1:At(), 11 ] == "5" }  	COLOR "BR_LARANJA" 	TITLE "Nota Fiscal Cancelada"        Of oBrwSE1

ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),1] 	} Title "Valor"            PICTURE PesqPict("SE1","E1_VALOR")   	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),2] 	} Title "Vlr.Liquido"      PICTURE PesqPict("SE1","E1_VALOR")   	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),3] 	} Title "ISS"              PICTURE PesqPict("SE1","E1_ISS")       	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),4] 	} Title "Pis"              PICTURE PesqPict("SE1","E1_PIS")       	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),5] 	} Title "Cofins"           PICTURE PesqPict("SE1","E1_COFINS")    	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),6] 	} Title "IRRF"             PICTURE PesqPict("SE1","E1_IRRF")      	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),7] 	} Title "CSLL"             PICTURE PesqPict("SE1","E1_CSLL")      	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),8] 	} Title "INSS"             PICTURE PesqPict("SE1","E1_INSS")      	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),9] 	} Title "Nota Fiscal"      PICTURE PesqPict("SE1","E1_XNUMNFS")   	SIZE 8  Of oBrwSE1
ADD COLUMN oColumn DATA { || aTitSE1[oBrwSE1:At(),10] 	} Title "Cód.Verificação"  PICTURE PesqPict("SE1","E1_XCODNFS")   	SIZE 8  Of oBrwSE1

ACTIVATE FWBrowse oBrwSE1

oDlgSE1:Activate(,,,.T.,{|| lSair } ,, {|| lSair } )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Atualiza os dados do array aTitSE1 e faz o refresh na tela
@author  Victor Andrade
@since   27/03/2018
@version 1
/*/
//-------------------------------------------------------------------

Static Function AL03Refresh(lRefresh)

Local aArea := GetArea()

aTitSE1 := {}

Aadd( aTitSE1, { 	SE1->E1_VALOR,;
					SE1->E1_VALOR - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA),;
                	SE1->E1_ISS,;
                	SE1->E1_PIS,;
                	SE1->E1_COFINS,;
                	SE1->E1_IRRF,;
                	SE1->E1_CSLL,;
                	SE1->E1_INSS,;
                	SE1->E1_XNUMNFS,;
                	SE1->E1_XCODNFS,;
                	SE1->E1_XSTNFS,;
                	SE1->E1_MSGNF,;
                	SE1->E1_PROPOS,;
                	SE1->E1_ADITIV,;
                	SE1->E1_CLIENTE+SE1->E1_LOJA,;
                	SE1->E1_EMISSAO,;
                	SE1->E1_VENCREA,;
                	SE1->E1_MSGMAIL,;
                	SE1->E1_OBSCOBR,;
                	SE1->E1_HIST} )

IF lRefresh
	oBrwSE1:Refresh()
	oDlgSE1:Refresh()
EndIF

RestArea( aArea )

Return

Static Function AtuHist(cOrig,cNew)

Local aArea := GetArea()

IF cOrig == 'Z02_DESCRI' .And. !Empty(aTitSE1[1,13])

	DbSelectArea('Z02')
	DbSetOrder(1)
	IF DbSeek( xFilial('Z02') + aTitSE1[1,13] + aTitSE1[1,14])
		RecLock('Z02',.F.)
		Z02_DESCRI := cNew
		MsUnlock()
    EndIF

ElseIF cOrig == 'A1_NOMENFS'

	DbSelectArea('SA1')
	DbSetOrder(1)
	IF DbSeek( xFilial('SA1') + aTitSE1[1,15] )
		RecLock('SA1',.F.)
		A1_NOMENFS := cNew
		MsUnlock()
    EndIF

ElseIF cOrig == 'A1_EMAILNF'

	DbSelectArea('SA1')
	DbSetOrder(1)
	IF DbSeek( xFilial('SA1') + aTitSE1[1,15] )
		RecLock('SA1',.F.)
		A1_EMAILNF := cNew
		MsUnlock()
    EndIF

ElseIF cOrig == 'E1_MSGMAIL'

	DbSelectArea('SE1')
	RecLock('SE1',.F.)
	E1_MSGMAIL := cNew
	MsUnlock()

ElseIF cOrig == 'E1_MSGNF'

	DbSelectArea('SE1')
	RecLock('SE1',.F.)
	E1_MSGNF := cNew
	MsUnlock()

ElseIF cOrig == 'E1_OBSCOBR'   

	DbSelectArea('SE1')
	RecLock('SE1',.F.)
	E1_OBSCOBR := cNew
	MsUnlock()

ElseIF cOrig == 'E1_HIST'   

	DbSelectArea('SE1')
	RecLock('SE1',.F.)
	E1_HIST := cNew
	MsUnlock()

EndIF

RestArea(aArea)

Return
