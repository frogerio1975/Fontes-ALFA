#Include "Protheus.ch"
#Include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFFIN01

Renovar contrato

@author  Pedro Oliveira
@since   26/01/2022
@version 1
/*/
//-------------------------------------------------------------------
User Function ALFFIN01()

Local aArea         := GetArea()
Local nRecnoSE1     := SE1->( Recno() )
Local aSize     	:= MsAdvSize( .T. )
Local cCadastro     := "Renovar contrato" 
Local dDtVecto      := MonthSum(SE1->E1_VENCREA,1)
Local nValor        := SE1->E1_VALOR
Local cParcelas     := Space(TAMSX3('Z02_DURAC')[1])

Local cNature     := Space(TAMSX3('E1_NATUREZ')[1])

Local oDlgAcao      := nil
Local oFont2 	    := TFont():New('Tahoma',,18,.T.)
Local oTFont3 	    := TFont():New('Tahoma',,15,.T.)
Local oGrp2         := Nil
Local oSay          := nil
Local lGrava        := .F.
Local cStyle	    := 	"QGroupBox { "+;                                            
			"   background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, "+;
			"   stop: 0 #b3ccff, stop: 1 #FFFFFF); "+;
			"    border: 0px solid gray; "+;
			"    border-radius: 0px; "+;
			"    margin-top: 1ex; }"	

Private _aTpData		:= { '1=1.01/3360300','2=1.06/3360500','3=1.07/3360490','4=1.05/3610291' }
PRIVATE _cTpData := '4'
PRIVATE _oTpData := NIL
oTFont3:Bold := .T.
//cNature:= Padr( '' , TAMSX3('E1_NATUREZ')[1] )
oDlgAcao := TDialog():New(aSize[7],0,aSize[6]/3,aSize[5]/2.5,cCadastro,,,,,,,,,.T.)                  

	oSay1:= TSay():New(010,010,{||'Cliente/Loja: '+SE1->E1_CLIENTE+'/'+SE1->E1_LOJA},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)	
	//oSay1:= TSay():New(025,010,{||'Loja: '+SE1->E1_LOJA},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	//oSay1:= TSay():New(040,010,{||'Nome: '+SE1->E1_NOMCLI},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
    //oSay1:= TSay():New(055,010,{||'Vencimento: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
    //oSay1:= TSay():New(070,010,{||'Valor: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
    //oSay1:= TSay():New(085,010,{||'Parcelas: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
    //oSay4:= TSay():New(100,010,{||'Natureza: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oSay1:= TSay():New(025,010,{||'Nome: '+SE1->E1_NOMCLI},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oSay1:= TSay():New(040,010,{||'Vencimento: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oSay1:= TSay():New(055,010,{||'Valor: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oSay1:= TSay():New(070,010,{||'Parcelas: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)
	oSay4:= TSay():New(085,010,{||'Natureza: '},oGrp2,,oTFont3,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)

    oGrp2:= TGroup():New(00,01,200,aSize[3]-10,,oDlgAcao,,,.T.)

    //oGet1:= TGet():New(053,100 , { |u| Iif( PCount() > 0, dDtVecto:=u, dDtVecto ) },oGrp2,080, 010, "@D",{|| dDtVecto>date() },,,oFont2  ,,,.T.,,,,,,,,,,"dDtVecto")
    //oGet2:= TGet():New(068,100 , { |u| Iif( PCount() > 0, nValor:=u, nValor ) },oGrp2,080, 010, "@E 99,999,999,999.99",{|| nValor > 0 },,,oFont2  ,,,.T.,,,,,,,,,,"nValor")
    //oGet3:= TGet():New(083,100 , { |u| Iif( PCount() > 0, cParcelas:=u, cParcelas ) },oGrp2,080, 010, "@!",{|| ExistCpo("SX5","Z3" + cParcelas ) },,,oFont2  ,,,.T.,,,,,,,,,,"cParcelas")
	oGet1:= TGet():New(038,100 , { |u| Iif( PCount() > 0, dDtVecto:=u, dDtVecto ) },oGrp2,080, 010, "@D",{|| dDtVecto>date() },,,oFont2  ,,,.T.,,,,,,,,,,"dDtVecto")
	oGet2:= TGet():New(053,100 , { |u| Iif( PCount() > 0, nValor:=u, nValor ) },oGrp2,080, 010, "@E 99,999,999,999.99",{|| nValor > 0 },,,oFont2  ,,,.T.,,,,,,,,,,"nValor")
	oGet3:= TGet():New(068,100 , { |u| Iif( PCount() > 0, cParcelas:=u, cParcelas ) },oGrp2,080, 010, "@!",{|| ExistCpo("SX5","Z3" + cParcelas ) },,,oFont2  ,,,.T.,,,,,,,,,,"cParcelas")    
	oGet3:cF3 := "Z3"

	
	@ 083,100 COMBOBOX _oTpData VAR _cTpData ITEMS _aTpData	OF oGrp2 SIZE 73,09 PIXEL 		
    //oGet4:= TGet():New(98,100 , { |u| Iif( PCount() > 0, cNature:=u, cNature ) },oGrp2,080, 010, "@!",{|| ExistCpo("SED",cNature ) },,,oFont2  ,,,.T.,,,,,,,,,,"cNature")
    //oGet4:cF3 := "SED"

    oBt1:= TButton():New( 100, 010, "Confirmar",oDlgAcao,{|| lGrava:=.t., Iif(lGrava,oDlgAcao:End(),) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )				
    oBt2:= TButton():New( 100, 100, "Sair",oDlgAcao,{|| lGrava:=.F., oDlgAcao:End() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
    oGrp2:SetCss(cStyle)

oDlgAcao:Activate(,,,.T.,,, )	

If lGrava .And. ;
    MsgYesNo("Confirma a renova豫o do contrato para o cliente "+SE1->E1_CLIENTE+'/'+SE1->E1_LOJA+'-'+Alltrim(SE1->E1_NOMCLI)+" no valor R$ "+;
    Alltrim(TRANSFORM( nValor,"@E 99,999,999,999.99" ))+" x "+Alltrim(cParcelas)+" com inicio da parcela "+dtoc(dDtVecto)+" ?", "A L F A - ALFFIN01")

    
    //LjMsgRun("Gerando titulos ..." ,,{|| AfGerFin(nRecnoSE1,nValor,Val(cParcelas),dDtVecto) } )
    FWMsgRun(, {|oSay|  AfGerFin(nRecnoSE1,nValor,Val(cParcelas),dDtVecto,osay,_cTpData)  }, "Gerando titulos ...", "Processando a rotina...")
EndIf

RestArea(aArea)

Return

//Gera financeiro
Static Function AfGerFin(nRecnoSE1,nValor,nParcelas,dDtVecto,oSay,_cTpData)

Local nI        := 0
Local cNumTit   := ""
Local cPrefixo	:= 'PRO'
Local aTitulo   := {}
Local cDiaFixo  := Alltrim(Str(Day(dDtVecto))) //'05'
Local lRet      := .t.
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Cria numero do titulo.                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNumTit := GetSxeNum("SE1","E1_NUM")

SE1->(DbSetOrder(1))
While .T.
	IF SE1->(DbSeek(xFilial('SE1') + cPrefixo + cNumTit))
		cNumTit := GetSxeNum("SE1","E1_NUM")
		ConfirmSx8()
	Else
		Exit
	EndIF
EndDo


Begin Transaction
    For nI:= 1 To nParcelas
            oSay:cCaption := "Gerando parcela ..."+StrZero( nI , TamSx3("E1_PARCELA")[1] )
            If nI > 1
                nMesAtual	:= Month(dDtVecto)
                nAno		:= Year(dDtVecto)
                    
                nMesAtual++
                IF nMesAtual > 12
                    nMesAtual := 1
                    nAno += 1
                EndIF
                dDtVecto := DataValida( Ctod( cDiaFixo + '/' + StrZero(nMesAtual,2) + '/' + StrZero(nAno,4) ) , .f. )
            EndIf
                        
            aTitulo:= aClone({})

            SE1->( DbGoto(nRecnoSE1) )
			Aadd( aTitulo ,	{"E1_FILIAL" 	,xFilial("SE1")									,Nil})
			Aadd( aTitulo ,	{"E1_PREFIXO" 	,cPrefixo 										,Nil})
			Aadd( aTitulo ,	{"E1_NUM"	   	,cNumTit					       				,Nil})
			Aadd( aTitulo ,	{"E1_PARCELA" 	,StrZero( nI , TamSx3("E1_PARCELA")[1] )	 ,Nil})
			Aadd( aTitulo ,	{"E1_TIPO"		,SE1->E1_TIPO									,Nil})
			Aadd( aTitulo ,	{"E1_EMPFAT" 	,SE1->E1_EMPFAT                                 ,Nil})
			Aadd( aTitulo ,	{"E1_NATUREZ" 	,SE1->E1_NATUREZ   								,Nil})
			Aadd( aTitulo ,	{"E1_CLIENTE" 	,SE1->E1_CLIENTE 	  							,Nil})
			Aadd( aTitulo ,	{"E1_LOJA"	   	,SE1->E1_LOJA   								,Nil})
			Aadd( aTitulo ,	{"E1_EMISSAO" 	,date()              							,Nil})
			Aadd( aTitulo ,	{"E1_VENCTO"	,dDtVecto  									,Nil})
			Aadd( aTitulo ,	{"E1_VENCREA" 	,DataValida(dDtVecto,.T.)					,Nil}) 
			Aadd( aTitulo ,	{"E1_HIST" 		,SE1->E1_HIST ,Nil})
			Aadd( aTitulo ,	{"E1_PROPOS" 	,SE1->E1_PROPOS							    	,Nil})
			Aadd( aTitulo ,	{"E1_ADITIV" 	,SE1->E1_ADITIV							    	,Nil})
			Aadd( aTitulo ,	{"E1_XTIPO" 	,SE1->E1_XTIPO									,Nil})
			Aadd( aTitulo ,	{"E1_VALOR"		,nValor						                    ,Nil})
			Aadd( aTitulo ,	{"E1_XTPSRV"	,_cTpData						 					,Nil})
			//Aadd( aTitulo ,	{"E1_XTPSRV"	,'3'						 					,Nil})
			Aadd( aTitulo ,	{"E1_XINDICE"	,SE1->E1_XINDICE			 					,Nil})
			Aadd( aTitulo ,	{"E1_ORIGEM"	,'FINA040'					 					,Nil})
			Aadd( aTitulo ,	{"E1_VEND1"		,SE1->E1_VEND1									,Nil})
			Aadd( aTitulo ,	{"E1_COMIS1"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS2"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS3"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS4"	,0									 			,Nil})
			Aadd( aTitulo ,	{"E1_COMIS5"	,0									 			,Nil})									
			Aadd( aTitulo ,	{"E1_BASCOM1"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM2"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM3"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM4"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_BASCOM5"	,0								 				,Nil})
			Aadd( aTitulo ,	{"E1_MSGNF"	    ,SE1->E1_MSGNF , Nil })        
            Aadd( aTitulo ,	{"E1_SITUACA" 	,SE1->E1_SITUACA								,Nil})
            Aadd( aTitulo ,	{"E1_PORTADO" 	,SE1->E1_PORTADO			   					,Nil})
            Aadd( aTitulo ,	{"E1_AGEDEP" 	,SE1->E1_AGEDEP	,Nil})
            Aadd( aTitulo ,	{"E1_CONTA"	   	,SE1->E1_CONTA	,Nil})
            Aadd( aTitulo ,	{"E1_XPROD" 	,SE1->E1_XPROD				 						,Nil})
            Aadd( aTitulo ,	{"E1_XTPPARC" 	,SE1->E1_XTPPARC ,Nil})
            lMsErroAuto := .F.
            lMsHelpAuto := .F.
            
            MSExecAuto({|x,y| FINA040(x,y)},aTitulo,3)
			IF lMsErroAuto
				lRet := .F.
				MostraErro()
				IF ( __lSX8)
					RollBackSX8()
				EndIF
				DisarmTransaction()
				Break
				Exit
			EndIF

    Next nI
End Transaction

If lRet
    MsgInfo("Contrato renovado com sucesso! "+CRLF+"Titulo: "+ cNumTit+CRLF+"Prefixo:"+cPrefixo+CRLF+"Parcelas: 1/"+Alltrim(Str(nParcelas)), "A L F A ")
EndIf

Return 
