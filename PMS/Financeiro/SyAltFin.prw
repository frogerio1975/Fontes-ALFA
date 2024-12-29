#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
STATIC nSel01 := 1 
STATIC n_xQtd := 0

//------------------------------------------------------------------- 
/*/{Protheus.doc} SyAltFin
Realiza ajuste data de vencimento no contas a pagar ou receber

@author		Pedro H. Oliveira 
@since 		24/07/2020
@version 	P11
/*/
//-------------------------------------------------------------------
User Function SyAltFin( nOpc )

Local cPerg     := PADR('SYALTFIN00',10)
Local aRegs     := {}
Private c_xAlias:= 'SE1'
//Private c_xTab  := 'E2_'
Private cTmp 	:= ''

Private lValor := nOpc==3
Private lNaturez := nOpc==4
Private cServi :=  '1'

c_xAlias:= 'SE1'
cPerg     := PADR('SYALTFIN00',10)    
aRegs     := {}
If nOpc == 2
    c_xAlias:= 'SE2'
    cPerg     := PADR('SYALTFIN01',10)
    aAdd(aRegs,{cPerg,"01","Tipo de ?","",""             ,"mv_ch1","C", TAMSX3('E2_TIPO')[1]  ,0,0,"G",""		    ,"mv_par01",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","05" } )
    aAdd(aRegs,{cPerg,"02","Tipo ate ?","",""            ,"mv_ch2","C", TAMSX3('E2_TIPO')[1]  ,0,0,"G",""		    ,"mv_par02",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","05" } )
    aAdd(aRegs,{cPerg,"03","Numero de ?","",""              ,"mv_ch3","C", TAMSX3('E2_NUM')[1]      ,0,0,"G",""		,"mv_par03",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"04","Numero ate ?","",""             ,"mv_ch4","C", TAMSX3('E2_NUM')[1]      ,0,0,"G",""		,"mv_par04",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"05","Parcela de ?","",""             ,"mv_ch5","C", TAMSX3('E2_PARCELA')[1]  ,0,0,"G",""		,"mv_par05",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"06","Parcela ate ?","",""            ,"mv_ch6","C", TAMSX3('E2_PARCELA')[1]  ,0,0,"G",""		,"mv_par06",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"07","Fornecedor de ?","",""             ,"mv_ch7","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""	,"mv_par07",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )
    aAdd(aRegs,{cPerg,"08","Loja de ?","",""                ,"mv_ch8","C", TAMSX3('E2_LOJA')[1]     ,0,0,"G",""		,"mv_par08",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"09","Fornecedor ate ?","",""            ,"mv_ch9","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""	,"mv_par09",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )
    aAdd(aRegs,{cPerg,"10","Loja ate ?","",""               ,"mv_cha","C", TAMSX3('E2_LOJA')[1]     ,0,0,"G",""		,"mv_par10",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"11","Emissão de ?","",""             ,"mv_chb","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par11",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"12","Emissão ate ?","",""            ,"mv_chc","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par12",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"13","Vencimento de ?","",""          ,"mv_chd","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par13",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"14","Vencimento ate ?","",""         ,"mv_che","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par14",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"15","Vencto real de ?","",""         ,"mv_chf","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par15",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"16","Vencto real ate ?","",""        ,"mv_chg","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par16",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
Else
    aAdd(aRegs,{cPerg,"01","Prefixo de ?","",""             ,"mv_ch1","C", TAMSX3('E2_PREFIXO')[1]  ,0,0,"G",""		,"mv_par01",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"02","Prefixo ate ?","",""            ,"mv_ch2","C", TAMSX3('E2_PREFIXO')[1]  ,0,0,"G",""		,"mv_par02",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"03","Numero de ?","",""              ,"mv_ch3","C", TAMSX3('E2_NUM')[1]      ,0,0,"G",""		,"mv_par03",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"04","Numero ate ?","",""             ,"mv_ch4","C", TAMSX3('E2_NUM')[1]      ,0,0,"G",""		,"mv_par04",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"05","Parcela de ?","",""             ,"mv_ch5","C", TAMSX3('E2_PARCELA')[1]  ,0,0,"G",""		,"mv_par05",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"06","Parcela ate ?","",""            ,"mv_ch6","C", TAMSX3('E2_PARCELA')[1]  ,0,0,"G",""		,"mv_par06",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"07","Cliente de ?","",""             ,"mv_ch7","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""		,"mv_par07",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA1" } )
    aAdd(aRegs,{cPerg,"08","Loja de ?","",""                ,"mv_ch8","C", TAMSX3('E2_LOJA')[1]     ,0,0,"G",""		,"mv_par08",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"09","Cliente ate ?","",""            ,"mv_ch9","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""		,"mv_par09",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA1" } )
    aAdd(aRegs,{cPerg,"10","Loja ate ?","",""               ,"mv_cha","C", TAMSX3('E2_LOJA')[1]     ,0,0,"G",""		,"mv_par10",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"11","Emissão de ?","",""             ,"mv_chb","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par11",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"12","Emissão ate ?","",""            ,"mv_chc","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par12",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"13","Vencimento de ?","",""          ,"mv_chd","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par13",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"14","Vencimento ate ?","",""         ,"mv_che","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par14",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"15","Vencto real de ?","",""         ,"mv_chf","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par15",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"16","Vencto real ate ?","",""        ,"mv_chg","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par16",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )

    aAdd(aRegs,{cPerg,"17","Proposta de ?","",""             ,"mv_chh","C", TAMSX3('E1_PROPOS')[1]  ,0,0,"G",""		,"mv_par17",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    aAdd(aRegs,{cPerg,"18","Proposta ate ?","",""            ,"mv_chi","C", TAMSX3('E1_PROPOS')[1]  ,0,0,"G",""		,"mv_par18",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
    
EndIf

ValidPerg(cPerg,aRegs)

If !Pergunte(cPerg,.T.)
    Return
EndIf

If lNaturez
    aServ := {'1=1.01/3360300','2=1.06/3360500','3=1.07/3360490','4=1.05/3610291'}
    aRetParam:= {}
    aBoxParam:={}
    AADD( aBoxParam, {2,"Tipo de serviço"   ,cServi    ,aServ,050,".F.",.T.} )

    If ParamBox(aBoxParam,"Informe os Parametros",@aRetParam,,,,,,,,.F.)
        cServi:= substr(aRetParam[01],1,1)
    Else
        Return
    End


End

FWMsgRun(, {|oSay| FilSyRel() }, "Filtrando a rotina...", "Filtrando a rotina...")

If (cTmp)->(eof())
    MSGINFO( 'sem dados para exibir', 'atenção' )
Else
    SyTelaFin()
EndIf

(cTmp)->(DBCLOSEAREA(  ))

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} FilSyRel
CRIA SX1
@author		Pedro H. Oliveira 
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function FilSyRel()

Local cQuery := ''
Local cCond  := SUBSTR(c_xAlias,2,2)
Local ni := 0 
cQuery+= " SELECT "+c_xAlias+".R_E_C_N_O_ "+c_xAlias+"REC ,* FROM "+RETSQLNAME( c_xAlias )+" "+c_xAlias +CRLF
cQuery+= " WHERE"+CRLF
cQuery+= cCond+"_FILIAL = '"+XFILIAL(c_xAlias)+"' "+CRLF
If c_xAlias == 'SE2'
    cQuery+= " AND E2_TIPO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
Else
    cQuery+= " AND "+cCond+"_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
end
cQuery+= " AND "+cCond+"_NUM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery+= " AND "+cCond+"_PARCELA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
If c_xAlias == 'SE2'
    cQuery+= " AND E2_FORNECE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR09+"' "+CRLF
    cQuery+= " AND E2_LOJA BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR10+"' "+CRLF
Else
    cQuery+= " AND E1_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR09+"' "+CRLF
    cQuery+= " AND E1_LOJA BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR10+"' "    +CRLF

    cQuery+= " AND E1_PROPOS BETWEEN '"+MV_PAR17+"' AND '"+MV_PAR18+"' "    +CRLF

EndIf

cQuery+= " AND "+cCond+"_EMISSAO BETWEEN '"+DTOS(MV_PAR11)+"' AND '"+DTOS(MV_PAR12)+"' "+CRLF
cQuery+= " AND "+cCond+"_VENCTO BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"' "+CRLF
cQuery+= " AND "+cCond+"_VENCREA BETWEEN '"+DTOS(MV_PAR15)+"' AND '"+DTOS(MV_PAR16)+"' "+CRLF
cQuery+= " AND "+cCond+"_SALDO > 0 "+CRLF

cQuery+= " AND "+c_xAlias+".D_E_L_E_T_ = ''  "+CRLF   

If lNaturez 
    cQuery+= " AND E1_XTPSRV = '"+cServi+"'  "    +CRLF   
End
ctmp:= MPSysOpenQuery(cQuery)


aStru := (c_xAlias)->(dbStruct())


For nI := 1 to len(aStru)
    If ( aStru[nI][2] $ 'DNL')
        TCSetField(ctmp,aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
    Endif
Next

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
CRIA SX1
@author		Pedro H. Oliveira 
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValidPerg(cPerg,aRegs)

Local aArea  := SX1->(GetArea())
//Local aRegs := {}
Local i,j


DbselectArea('SX1')
SX1->(DBSETORDER(1))
For i:= 1 To Len(aRegs)
    If ! SX1->(DBSEEK( AvKey(cPerg,"X1_GRUPO") +aRegs[i,2]) )
        Reclock('SX1', .T.)

		FOR j:= 1 to SX1->( FCOUNT() )
			IF j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			ENDIF
		Next j

        SX1->(MsUnlock())
    Endif

Next i

RestArea(aArea)
Return(cPerg)

//-------------------------------------------------------------------
/*/{Protheus.doc} SyTelaFin
cria tela
@author		Pedro H. Oliveira 
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function SyTelaFin()


Local aArea    := GetArea()
Local aCposAlt:= {} 
Local cIniCpos      := ''
Local aButtons := {}	
Local aSize     := MsAdvSize( .T. )
Local oDlgPrev := nil

Local oTFont        := TFont():New('Verdana',,-15,.T.)
Local aCampos   := {}
Local aHeaFin:= {}
Local aColsFin:= {}
Local nCntFor := 0
Local nOpcA         := 0
Local bVldAll	    := {|| NfVldTdOk( xGetDados:aCols , aHeaFin )  }
Local bOk		    := {|| IIf(Eval(bVldAll), (nOpcA := 1,aColsFin :=xGetDados:aCols  , oDlgPrev:End()), nOpcA := 0) }
Local bCancel	    := {|| oDlgPrev:End() }

Private xGetDados := nil

Private nVlr1 := 0

Private c_Nature := space( TamSx3("E2_NATUREZ")[1]) 

If c_xAlias == 'SE2'
    aCampos   := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_NUMNOTA","E2_FORNECE","E2_LOJA","E2_NOMFOR","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_VALOR","E2_SALDO","E2_HIST"}
Else    
    aCampos   := {"E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_XNUMNFS","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_EMISSAO","E1_VENCTO","E1_VENCREA","E1_VALOR","E1_SALDO","E1_HIST"}
EndIf
aHeaFin:= FCriaHeader(aCampos)

aAdd(aHeaFin, {'RECNO','XX_RECNO' ,"@E 9999999999",10,0,,,"N",,} )  
While (cTmp)->( !eof()) 
    Aadd(aColsFin,Array(Len(aHeaFin)+1))
    aColsFin[Len(aColsFin)][Len(aHeaFin)+1] := .F.
    For nCntFor := 1 To Len(aHeaFin)
        If  AllTrim(aHeaFin[nCntFor,2]) == 'AY_MARK'
            aColsFin[Len(aColsFin)][nCntFor] := 'LBNO'
        ElseIf AllTrim(aHeaFin[nCntFor,2]) == 'XX_RECNO'
            aColsFin[Len(aColsFin)][nCntFor] := (cTmp)->&(c_xAlias+"REC")
        Else
        
            aColsFin[Len(aColsFin)][nCntFor] := (cTmp)->&(AllTrim(aHeaFin[nCntFor,2]))

        EndIf
    Next nCntFor             

    (cTmp)->( DbSkip() )
EndDo	 
dDtVencto:= 1//ctod('')
dDtReal  := ctod('')
oTFont:bold:= .t.
//oDlgPrev := TDialog():New(0,0,aSize[6]/1.5,aSize[5]/1.5,"Financeiro",,,,,,,,,.T.)
oDlgPrev := TDialog():New(0,0,aSize[6] ,aSize[5]  ,"Financeiro",,,,,,,,,.T.)
    oLayer := FWLayer():New()  
    oLayer:Init(oDlgPrev,.F.,.F.)  

    oLayer:addLine('Linha1',95,.T.)
    oLayer:addCollumn( "Col01", 100, .F.,"Linha1")	                                                                
    //oLayer:addLine('Linha2',98,.T.)
    oLayer:addWindow( "Col01" , "Win01", "DATA "	,30, .F., .F., ,"Linha1" )
    oLayer:addWindow( "Col01" , "Win02", "TITULOS"	,70, .F., .F., ,"Linha1" )

    oPanel1:= oLayer:getWinPanel( "Col01", "Win01" , "Linha1" )
    oPanel2:= oLayer:getWinPanel( "Col01", "Win02" , "Linha1" )

    oDados  := TPanel():New(0,0,"",oPanel1,oTFont ,.T.,,CLR_WHITE,RGB(132,172,196),aSize[3]-5,17 , .T. )
    oDados:Align := CONTROL_ALIGN_ALLCLIENT

    //oSay01:= TSay():New(010,010 ,{||'Data Vencimento: 		 '},oDados,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    //oGet01:= TGet():New(008,0110 , { |u| Iif( PCount() > 0, dDtVencto:=u, dDtVencto ) },oDados,070, 010, "@D",{|| VldDtLimite(dDtVencto) },,,oTFont  ,,,.T.,,,,,,,,,,"dDtVencto")
    //if c_xAlias == 'SE1'
    IF lNaturez
        oSay01:= TSay():New(010,010 ,{||'Natureza : 		 '},oDados,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
        //oGet01:= TGet():New(008,0110 , { |u| Iif( PCount() > 0, nVlr1:=u, nVlr1 ) },oDados,070, 010, PesqPict("SE1","E1_VALOR"),{|| nVlr1>0 },,,oTFont  ,,,.T.,,,,,,,,,,"nVlr1")                
        oGet01:= TGet():New(008,0110 , { |u| Iif( PCount() > 0, c_Nature:=u, c_Nature ) },oDados,080, 010, "@!",{|| ExistCpo("SED", c_Nature ) },,,oTFont  ,,,.T.,,,,,,,,,,"c_Nature")

        oBntAlt     := TButton():New( 010, 190, "Alterar Titulos" , oDados, {|| aColsFin:= xGetDados:aCOLS ,nOpcA:= 4 , oDlgPrev:End()  } ,50,10,,,,.T.)        
    ElseIf !lValor    
        oSay01:= TSay():New(010,010 ,{||'Dia Vencimento: 		 '},oDados,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
        oGet01:= TGet():New(008,0110 , { |u| Iif( PCount() > 0, dDtVencto:=u, dDtVencto ) },oDados,070, 010, "@E 99",{|| VldDtLimite(dDtVencto) },,,oTFont  ,,,.T.,,,,,,,,,,"dDtVencto")

        oBntAlt     := TButton():New( 010, 190, "Alterar Titulos" , oDados, {|| aColsFin:= xGetDados:aCOLS ,nOpcA:= 1 , oDlgPrev:End()  } ,50,10,,,,.T.)
        //end
        oBtnExc     := TButton():New( 025, 190, "Excluir Titulos" , oDados, {|| aColsFin:= xGetDados:aCOLS ,nOpcA:= 2 , oDlgPrev:End()  } ,50,10,,,,.T.)
    Else
        oSay01:= TSay():New(010,010 ,{||'Valor : 		 '},oDados,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
        oGet01:= TGet():New(008,0110 , { |u| Iif( PCount() > 0, nVlr1:=u, nVlr1 ) },oDados,070, 010, PesqPict("SE1","E1_VALOR"),{|| nVlr1>0 },,,oTFont  ,,,.T.,,,,,,,,,,"nVlr1")                

        oBntAlt     := TButton():New( 010, 190, "Alterar Titulos" , oDados, {|| aColsFin:= xGetDados:aCOLS ,nOpcA:= 3 , oDlgPrev:End()  } ,50,10,,,,.T.)

    End
    oBtnSair    := TButton():New( 040, 190, "Sair"            , oDados, {|| oDlgPrev:End()              } ,50,10,,,,.T.)

/*
    oSay02:= TSay():New(27,010 ,{||'Data Vencimento Real: 		 '},oDados,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    oGet02:= TGet():New(25,0110 , { |u| Iif( PCount() > 0, dDtReal:=u, dDtReal ) },oDados,070, 010, "@D",{|| .t. },,,oTFont   ,.F.,,.T.,,.F.,{|| .f. } ,.F.,.F.,,.T.,.F. ,,"dDtReal",,,,.T.)//  ,,,.T.,,,,,,,,,,"dDtReal")
*/

	//oDlgPrev:lMaximized := .T.
	xGetDados:= MsNewGetDados():New(0,0,0,0,0,"Allwaystrue","Allwaystrue"	,cIniCpos,aCposAlt,000,9999,"Allwaystrue","Allwaystrue","Allwaystrue",oPanel2,@aHeaFin,@aColsFin,)
	xGetDados:oBrowse:Refresh()
	xGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 		

	xGetDados:oBrowse:bChange:= {|| nSel01 := xGetDados:oBrowse:nAt, xGetDados:oBrowse:Refresh()  } 
	xGetDados:oBrowse:SetBlkBackColor({||   Iif( xGetDados:nAt == nSel01, GETDCLR(xGetDados:nAt,1,.F.) ,)            })
    xGetDados:oBrowse:bLDblClick := {|| xGetDados:EditCell(),  xGetDados:aCOLS[ xGetDados:oBrowse:nAt ,1]:=Iif(xGetDados:aCOLS[xGetDados:oBrowse:nAt,1]=='LBOK','LBNO','LBOK')		 }	
    xGetDados:oBrowse:bHeaderClick := {|| xGetDados:EditCell(),MarcGrid( xGetDados:oBrowse:nColPos ) }
    //xGetDados:oBrowse:bHeaderClick := {|| xGetDados:EditCell(),_OrdGrid(xGetDados:oBrowse:nColPos ) }
    xGetDados:Refresh()

	//EnchoiceBar(oDlgPrev,{|| aColsFin:= xGetDados:aCOLS,oDlgPrev:End()  },;
	//					{||oDlgPrev:End()},,@aButtons)

//oDlgPrev:Activate(,,,.T.,,,EnchoiceBar(oDlgPrev, bOK, bCancel,, aButtons ) )

//oDlgPrev:Activate(,,,.T.,,,EnchoiceBar(oDlgPrev, bOK, bCancel,, aButtons ) )

oDlgPrev:Activate(,,,.T.,,, )

If nOpcA == 1 .and. MSGYESNO( 'Deseja alterar a data de vencimento para todos os titulos marcados ?', 'Atenção [SYALTFIN]' )
    MsgRun( 'Aguarde','Alterando Titulos  ... ',{ || GrvFin( aColsFin,aHeaFin,nOpcA  ) } )
ElseIf nOpcA == 2 .and. MSGYESNO( 'Deseja excluir os titulos marcados ?', 'Atenção [SYALTFIN]' )
    MsgRun( 'Aguarde','Excluindo Titulos  ... ',{ || GrvFin( aColsFin,aHeaFin,nOpcA  ) } )
ElseIf nOpcA == 3 .and. MSGYESNO( 'Deseja alterar os valores dos titulos marcados ?', 'Atenção [SYALTFIN]' )    
    MsgRun( 'Aguarde','Alterando Titulos  ... ',{ || GrvFin( aColsFin,aHeaFin,nOpcA  ) } )
ElseIf nOpcA == 4 .and. MSGYESNO( 'Deseja alterar as naturezas dos titulos marcados ?', 'Atenção [SYALTFIN]' )    
    MsgRun( 'Aguarde','Alterando Titulos  ... ',{ || GrvFin( aColsFin,aHeaFin,nOpcA  ) } )    
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaHeader

Cria aheader

@author PEDRO OLIVEIRA
@since 03/05/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function FCriaHeader( aCposPar )

Local nX := 1
Local aRetorno := {}
Local aAuxRet := {}
Local cVldSys := ""
Local cVldUsu := ""
Local cVldAll := ""

aAdd(aRetorno,{'','AY_MARK','@BMP',10,0,,,"C",,} )

SX3->(dbSetOrder(2))
For nX := 1 To Len(aCposPar)
	If SX3->(dbSeek( aCposPar[nX] ))
		cVldSys := SX3->X3_VALID
		cVldUsu := SX3->X3_VLDUSER
		cVldAll := Alltrim(Iif(!Empty(cVldSys),cVldSys,".T.")) + " .AND. " + Alltrim(Iif(!Empty(cVldUsu),cVldUsu,".T."))
		cVldAll:=''
		aAuxRet := {}
		Aadd( aAuxRet , SX3->X3_TITULO )
		Aadd( aAuxRet , SX3->X3_CAMPO )
		Aadd( aAuxRet , SX3->X3_PICTURE )
		Aadd( aAuxRet , SX3->X3_TAMANHO )
		Aadd( aAuxRet , SX3->X3_DECIMAL )
		Aadd( aAuxRet , cVldAll )
		Aadd( aAuxRet , SX3->X3_USADO )
		Aadd( aAuxRet , SX3->X3_TIPO )
		Aadd( aAuxRet , SX3->X3_F3 )
		Aadd( aAuxRet , SX3->X3_CONTEXT )
		Aadd( aRetorno , ACLONE(aAuxRet) )
	EndIf
Next nX

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GETDCLR 

Muda a cor da getdados.

@author CMJ
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------
Static Function GETDCLR(nLinha,nOpc,lTotal)
 
Local nCor1 := CLR_YELLOW
Local nRet  := Rgb(202,225,255)//CLR_WHITE
Local nSelec:= nSel01
 
If nLinha == nSelec
	nRet := nCor1
EndIf

 
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtLimite
  
Valida a data digitada

@author PEDRO OLIVEIRA
@since 10/05/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldDtLimite(dDtAlt)

Local lRet := .T.
Local dRet:= ''

If !(dDtAlt >= 1 .and. dDtAlt <= 31)
    MsgInfo("Vencimento deve ser entre os dias 1 e 31 !","Atenção") 
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} NfVldTdOk

valida tudo ok

@author Pedro H. Oliveira
@since 15/10/2022
@version P11
/*/
//-------------------------------------------------------------------
Static Function NfVldTdOk( aColsZ3 , aHdZ3 )

Local lret          := .t.
/*
If Empty(dDtReal)
    MSGINFO( 'Informar data de vencimento', 'Atenção' )
    lRet    := .f.    
Else
    If !MSGYESNO( 'Deseja alterar a data de vencimento para todos os titulos marcados ?', 'Atenção [SYALTFIN]' )
        lRet    := .f.    
    EndIf    
EndIf
*/
Return lret
//-------------------------------------------------------------------
/*/{Protheus.doc} GrvFin

grava SE1 OU SE2

@author Pedro H. Oliveira
@since 15/10/2022
@version P11
/*/
//-------------------------------------------------------------------
Static Function GrvFin( aColsFin,aHeaFin,nOpcA  )

Local nx      := 0
Local nPosRec := aScan(aHeaFin,{|x| AllTrim(x[2]) == "XX_RECNO"})
Local cCond  := SUBSTR(c_xAlias,2,2)
Local dDtAux := ''
Local dDt1 := ''
Local dDt2 := ''

Private lMsErroAuto := .F.                                                                                    	
Private lMsHelpAuto := .F.

for nx := 1 to len(aColsFin)
    If aColsFin[nx][1] == 'LBOK'
        (c_xAlias)->( DBGOTO( aColsFin[nx][ nPosRec ] ))        
            If nOpcA == 1   
                (c_xAlias)->( RECLOCK( c_xAlias , .f. ))
                dDtAux := day( lastdate( SE1->E1_VENCTO ) )
                If dDtVencto > dDtAux
                    dDt1 := ctod( strzero(dDtAux,2)+'/'+ substr( dtos(SE1->E1_VENCTO),5,2)+'/'+ substr(dtos(SE1->E1_VENCTO),1,4) ) 
                    dDt2 := datavalida(dDt1,.t.)
                Else
                    dDtAux:= dtos(SE1->E1_VENCTO) // 20230101
                    dDtAux := ctod( strzero(dDtVencto,2)+'/'+ substr(dDtAux,5,2)+'/'+ substr(dDtAux,1,4) )
                    dDt1 := dDtAux
                    dDt2 := datavalida(dDtAux,.t.)                
                EndIf
                (c_xAlias)->&(cCond+"_VENCTO")  := dDt1//dDtVencto 
                (c_xAlias)->&(cCond+"_VENCREA") := dDt2//dDtReal

                (c_xAlias)->( MSUNLOCK(  )) 
            elseif nOpcA == 2
                (c_xAlias)->( RECLOCK( c_xAlias , .f. ))
                (c_xAlias)->( DBDELETE(  ) )         
                (c_xAlias)->( MSUNLOCK(  )) 
            Else
                lMsErroAuto := .F.//231117//000043681
                lMsHelpAuto := .F.
                If nOpcA == 4
                    nVlr1   := SE1->E1_VALOR
                Else
                    c_Nature := SE1->E1_NATUREZ        
                End
				aVetor := { {"E1_FILIAL", 	SE1->E1_FILIAL, 	NIL},;			
                            {"E1_PREFIXO", 	SE1->E1_PREFIXO, 	NIL},;
                            {"E1_NUM", 		SE1->E1_NUM, 		NIL},;
                            {"E1_PARCELA", 	SE1->E1_PARCELA,	NIL},;
                            {"E1_TIPO", 	SE1->E1_TIPO, 	NIL},;
                            {"E1_CLIENTE", 	SE1->E1_CLIENTE, 	NIL},;
                            {"E1_LOJA", 	SE1->E1_LOJA, 	NIL},;
                            {"E1_VALOR", 	nVlr1, 	NIL}   ,;
                            {"E1_NATUREZ", 	c_Nature, 	NIL}   }                        

                MSExecAuto({|x,y| FINA040(x,y)},aVetor,4)                            
                IF lMsErroAuto
                    lRet := .F.
                    MostraErro()                    
                Else
                    lRet := .T.                    
                EndIF
                
            End  
        

    EndIf
//dDtVencto:= ctod('')
//dDtReal  := ctod('')
//cQuery+= " AND "+cCond+"_VENCTO BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"' "+CRLF
//cQuery+= " AND "+cCond+"_VENCREA BETWEEN '"+DTOS(MV_PAR15)+"' AND '"+DTOS(MV_PAR16)+"' "+CRLF

next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcGrid

Ordena

@author PEDRO OLIVEIRA
@since 18/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function MarcGrid(nPosCol)

Local nI		:= 0
If !Alltrim(Str(nPosCol)) $ '1/'
    Return
EndIf

aCols := xGetDados:aCols
If nPosCol == 1
    For nI:= 1 To Len(aCols)
        aCols[nI][1]	:= Iif( aCols[nI][1]  =='LBOK','LBNO','LBOK')
    Next nI

    n_xQtd:= n_xQtd+1

EndIf

xGetDados:aCols:=  aCols
xGetDados:Refresh()

Return
