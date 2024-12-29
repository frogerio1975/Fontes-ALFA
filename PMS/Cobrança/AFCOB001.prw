#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
STATIC nSel01 := 1 
//-------------------------------------------------------------------
/*/{Protheus.doc} AFCOB001
Descricao: Exibe tela para analise de solicitação de transferencia

@author Pedro Oliveira
@since 20/01/2023
@version 1.0
/*/
//-------------------------------------------------------------------

User Function AFCOB001()

Local cIniCpos      := ''
Local xOption       := 0
Local aCposAlt      := {}
Local nOpcA         := 0
Local bVldAll	    := {|| AtuObs( .t. )  }
Local bOk		    := {|| IIf(Eval(bVldAll), (nOpcA := 1,aColsE1 :=oGdNNT:aCols  , oDlgPro:End()), nOpcA := 0) }
Local bCancel	    := {|| AtuObs( .t. ),oDlgPro:End() }
Local aButtons      := {}

Private aSize       := MsAdvSize( .T. )
Private oDlgPro     := nil

Private aHdSE1 := FCriaHeader( {'E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_XNUMNFS','E1_HIST','E1_VENCREA','E1_VALOR','E1_VALLIQ','E1_XATRASO','A1_XMULTA','A1_XJUROS','D2_TOTAL'})
Private aColsE1   := {{'','','','','',ctod(''),0,0,0,0,0,0,0,.f.}}//{ {  _oOk ,'','','','',0,0, '','','', .f.} }

Private oGdTop := nil
Private oGdNNT := nil


Private aEmpFat  := { "1=ALFA(07)", "2=MOOVE", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
Private cEmpfat	 := aEmpFat[1]

private oTpData  := nil
private oDataDE  := nil
private oDataATE := nil
private oclide   := nil
private ocliate  := nil

private dDataDE  := dDataBase
private dDataATE := dDataBase
private cclide   := space(TamSx3("A1_COD")[1])
private ccliate  := Replicate('Z',TamSx3("A1_COD")[1]) 

private ovaltot := nil
private nvaltot := 0

private oTFont        := TFont():New('Verdana',,-15,.T.)

private oTMultiget1 := nil 
private cTexto1 := ''
private nPosRec       := 0 
Private nposcli       := 0
Private nposloja      := 0

oTFont:bold:= .t.
DEFINE FONT _oFont  NAME "Arial" SIZE 0,15  BOLD

aAdd(aHdSE1, {'RECNO','XX_RECNO' ,"@E 9999999999",10,0,,,"N",,} )      

nPosRec := aScan(aHdSE1,{|x| AllTrim(x[2]) == "XX_RECNO"})
nposcli := aScan(aHdSE1,{|x| AllTrim(x[2]) == "E1_CLIENTE"})
nposloja:= aScan(aHdSE1,{|x| AllTrim(x[2]) == "E1_LOJA"})

Aadd( aButtons, {"MDIEXCEL", {|| ExpTela()    }, "Exp.Excel", "Exp.Excel"   , {|| .T.}} )
Aadd( aButtons, {"MDIEXCEL", {|| SyAltCli(.t.)   }, "Visualizar CLiente"	, "Visualizar CLiente"   , {|| .T.}} )
Aadd( aButtons, {"MDIEXCEL", {|| SyAltCli(.f.)   }, "Alterar CLiente"	, "Alterar CLiente"   , {|| .T.}} )
  
lxWhen:= .f.

oDlgPro := TDialog():New(0,0,aSize[6]  ,aSize[5]  ,'Painel de Cobranças',,,,,,,,,.T.)
    oDlgPro:lMaximized := .T.
    oFWLayer := FWLayer():New()  
    oFWLayer:Init(oDlgPro,.F.)

	oFWLayer:addLine("TITULO", 045, .F.)
	oFWLayer:addLine("CORPO",  050, .F.)
	oFWLayer:addLine("RODAPE", 005, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("HEADERTEXT",   040, .T., "TITULO")
	oFWLayer:addCollumn("BLANKBTN",     060, .T., "TITULO")

	oFWLayer:addCollumn("COLGRID",      100, .T., "CORPO")
	
	//Criando os paineis
	oFWLayer:addWindow( "HEADERTEXT" , "WIN01", "Filtros"		,100 , .F., .F., ,"TITULO" )
	oFWLayer:addWindow( "BLANKBTN"   , "WIN02", "Observação cobrança"	,100 , .F., .F., ,"TITULO" )
	oFWLayer:addWindow( "COLGRID"    , "WIN03", "Titulos"	,095 , .F., .F., ,"CORPO" )
	
	oPanel2:= oFWLayer:getWinPanel( "HEADERTEXT", "WIN01" , "TITULO" )
	oPanel4:= oFWLayer:getWinPanel( "BLANKBTN"	, "WIN02" , "TITULO" )
	oPanel3:= oFWLayer:getWinPanel( "COLGRID"	, "WIN03" , "CORPO" )
    
    //FILTROS
    //oPanel2
    //@ 05,02 SAY "Empresa"  OF oPanel2 PIXEL FONT _oFont COLOR CLR_WHITE
    //@ 05,070 COMBOBOX oTpData VAR cEmpfat ITEMS aEmpFat	OF oPanel2 SIZE 73,09 PIXEL 		

    oSay01  := TSay():New( 05,010 ,{||'Empresa'},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    oTpData := TComboBox():New(05, 080, {|u| Iif(PCount() > 0 , cEmpfat := u, cEmpfat)}, aEmpFat , 70, 10, oPanel2, , {|| .t. }, /*bValid*/, /*nClrText*/, /*nClrBack*/, .t., oTFont)

    oSay01 := TSay():New(20,010 ,{||'Dt.Vencto de: 		 '},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    //oDataDE:= TGet():New(20,080, { | u | If( PCount() == 0, dDataDE, dDataDE := u ) },oPanel2,100, 010, "",/*Bvalid*/, 0, 16777215,oTFont   ,.F.,,.T.,,.F.,{|| .T. } ,.F.,.F.,,.T.,.F. ,,"dDataDE",,,,.T.)

    oDataDE := TGet():New( 20, 080, { | u | If( PCount() == 0, dDataDE, dDataDE := u ) },oPanel2, ;
     100, 010, "@D",, 0, 16777215,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataDE",,,,.T.  )

    oSay01 := TSay():New(35,010 ,{||'Dt.Vencto até: 		 '},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    //oDataATE:= TGet():New(35,080, { | u | If( PCount() == 0, dDataATE, dDataATE := u ) },oPanel2,100, 010, "",/*Bvalid*/, 0, 16777215,oTFont   ,.F.,,.T.,,.F.,{|| .T. } ,.F.,.F.,,.T.,.F. ,,"dDataATE",,,,.T.)
    oDataATE := TGet():New( 35, 080, { | u | If( PCount() == 0, dDataATE, dDataATE := u ) },oPanel2, ;
     100, 010, "@D",, 0, 16777215,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataATE",,,,.T.  )

    oSay01 := TSay():New(50,010 ,{||'Cliente de: 		 '},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    //oclide:= TGet():New(50,080, { | u | If( PCount() == 0, cclide, cclide := u ) },oPanel2,100, 010, "@!",/*Bvalid*/, 0, 16777215,oTFont   ,.F.,,.T.,,.F.,{|| .T. } ,.F.,.F.,,.T.,.F. ,,"cclide",,,,.T.)

    oclide := TGet():New( 50, 080, { | u | If( PCount() == 0, cclide, cclide := u ) },oPanel2, ;
     100, 010, "!@",, 0, 16777215,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cclide",,,,.T.  )

    oSay01 := TSay():New(65,010 ,{||'Cliente até: 		 '},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    //ocliate:= TGet():New(65,080, { | u | If( PCount() == 0, ccliate, ccliate := u ) },oPanel2,100, 010, "@!",/*Bvalid*/, 0, 16777215,oTFont   ,.F.,,.T.,,.F.,{|| .T. } ,.F.,.F.,,.T.,.F. ,,"ccliate",,,,.T.)
    ocliate := TGet():New( 65, 080, { | u | If( PCount() == 0, ccliate, ccliate := u ) },oPanel2, ;
     100, 010, "!@",, 0, 16777215,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ccliate",,,,.T.  )

    oSay12:= TSay():New(80,010 ,{||'Vlr.Total: '},oPanel2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,20)		
    ovaltot:= TGet():New(80,080, { | u | If( PCount() == 0, nvaltot, nvaltot := u ) },oPanel2,100, 010, PesqPict("SD2","D2_TOTAL"),/*Bvalid*/, 0, 16777215,oTFont   ,.F.,,.T.,,.F.,{|| lxWhen } ,.F.,.F.,,.T.,.F. ,,"nvaltot",,,,.T.)

    oclide:cF3  := "SA1"
    ocliate:cF3 := "SA1"

    oBntListar := TButton():New(100,080," Consultar",oPanel2,{||  LjMsgRun("Atualizando Registros ...",,{ || EtFilPed() })    }	,084,015,,,,.T.) 

    oGdNNT:= MsNewGetDados():New(0,0,0,0,xOption,"Allwaystrue","Allwaystrue"	,cIniCpos,aCposAlt,000,9999,"Allwaystrue","Allwaystrue","Allwaystrue",oPanel3,@aHdSE1,@aColsE1,)
    //oGdNNT:bLinhaOk := {|| AtuObs( .t. )  }
    oGdNNT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    oGdNNT:oBrowse:bChange:= {|| AtuObs( .t. ),nSel01 := oGdNNT:oBrowse:nAt,AtuObs(.f.), oGdNNT:oBrowse:Refresh()  }
    oGdNNT:oBrowse:SetBlkBackColor({||   Iif( oGdNNT:nAt == nSel01, GETDCLR(oGdNNT:nAt,1,.F.) ,)    })
	oGdNNT:oBrowse:Refresh()
    

	oGdNNT:Refresh()
    
    

    //OBSERVAÇÃO
    //oPanel4
    oTMultiget1 := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) }, oPanel4, 500, 100, oTFont, , , , , .T. )
    //oLista := tMultiget():new( 010, ((aSize[3]/2)-2) * 1 +3, {| u | if( pCount() > 0, cLista := u, cLista ) }, oDlgNew, (aSize[3]/2)-4, 270,oMaFnt03,.T.,,,,.T.,,,,,,.T.,,,,.F.,.F.)
    //oTMultiget1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

oDlgPro:Activate(,,,.T.,,,EnchoiceBar(oDlgPro, bOK, bCancel,, aButtons ))

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaHeader

Cria aheader

@author Pedro H. Oliveira
@since 21/05/2019
@version P11
/*/
//-------------------------------------------------------------------
Static Function FCriaHeader( aCposPar )

Local nX := 1
Local aRetorno := {}
Local aAuxRet := {}
Local cVldSys := ""
Local cVldUsu := ""
Local cVldAll := ""

SX3->(dbSetOrder(2))
For nX := 1 To Len(aCposPar)
    cCampo_ := aCposPar[nX]
    if 'E1_XATRASO'$cCampo_    
        Aadd(aRetorno,{ 'Dias Atraso',cCampo_,'@E 999999',6,0,'',"AllwaysTrue()",'N','',''})
    else
        If SX3->(dbSeek( cCampo_ ))
            cVldAll:=''
            aAuxRet := {} 
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_TITULO') )		
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_CAMPO' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_PICTURE' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_TAMANHO' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_DECIMAL' ))
            Aadd( aAuxRet , cVldAll )
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_USADO' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_TIPO' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_F3' ))
            Aadd( aAuxRet , GetSX3Cache(cCampo_,'X3_CONTEXT' ))
            Aadd( aRetorno, ACLONE(aAuxRet) )
            
        EndIf
    end
    npos:=len(aRetorno)
    if 'E1_VALOR'$cCampo_          
        aRetorno[npos][1]  := 'Valor NF'
    ElseIf 'E1_VALLIQ'$cCampo_ 
        aRetorno[npos][1]  := 'Vl.Liq Retenções'
    ElseIf 'D2_TOTAL'$cCampo_         
        aRetorno[npos][1]  := 'Tot.Liq. Juros+Multa'
    end
//'E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_XNUMNFS','E1_HIST','E1_VENCREA','E1_VALOR','E1_VALLIQ','E1_XATRASO','A1_XMULTA','A1_XJUROS','D2_TOTAL'})    
Next ni

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GETDCLR 

Muda a cor da getdados.

@author Pedro Henrique Oliveira
@since 21/05/2019
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
/*/{Protheus.doc} EtFilPed
Descricao: carrega tela acols

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EtFilPed()
    Local cQuery := ''
    Local cTmpE2 := ''
    Local lDados := .f.

    nvaltot := 0
    aColsE1:= {}
    //Monta a consulta
//    cQuery+=" SELECT R_E_C_N_O_ RECZ42 , Z42_FILSOL"+CRLF 
//    cQuery+=" FROM "+RetSqlName("Z42")+" Z42"+CRLF
//    cQuery+=" WHERE Z42_FILIAL = '"+xFilial('Z42')+"' "+CRLF
//    cQuery+=" AND Z42_OP = '"+cCodOP+"' "+CRLF
//    cQuery+=" AND Z42.D_E_L_E_T_ <> '*' "+CRLF
//    //cQuery+=" ORDER BY 1 "+CRLF        
//	cQuery+=" ORDER BY Z42_PRODUT "+CRLF  

    //'E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_XNUMNFS','E1_HIST','E1_VENCTO','E1_VALOR','E1_VALLIQ','E1_XATRASO','A1_XMULTA','A1_XJUROS','D2_TOTAL'
    cQuery+=" SELECT "+CRLF
    cQuery+=" E1_CLIENTE"+CRLF
    cQuery+=" ,E1_LOJA"+CRLF
    cQuery+=" ,E1_NOMCLI"+CRLF
    cQuery+=" ,E1_XNUMNFS"+CRLF
    cQuery+=" ,E1_HIST"+CRLF
    cQuery+=" ,E1_VENCREA"+CRLF
    cQuery+=" ,E1_VALOR"+CRLF
    cQuery+=" ,E1_VALOR - (E1_ISS + E1_PIS + E1_COFINS + E1_IRRF + E1_CSLL) E1_VALLIQ"+CRLF
    cQuery+=" ,A1_XMULTA"+CRLF
    cQuery+=" ,A1_XJUROS"+CRLF
    cQuery+=" ,SE1.R_E_C_N_O_ RECE1     "+CRLF
    cQuery+=" FROM SE1010 SE1"+CRLF
    cQuery+=" INNER JOIN SA1010 SA1 "+CRLF
    cQuery+=" ON A1_FILIAL = '"+xFilial('SA1')+"' "+CRLF
    cQuery+=" AND A1_COD = E1_CLIENTE"+CRLF
    cQuery+=" AND A1_LOJA = E1_LOJA"+CRLF
    cQuery+=" AND SA1.D_E_L_E_T_<>'*'"+CRLF
    cQuery+=" WHERE E1_FILIAL='"+xFilial('SE1')+"' "+CRLF
    cQuery+=" AND SE1.D_E_L_E_T_<>'*'"+CRLF
    cQuery+=" AND E1_EMPFAT = '"+cEmpfat+"' "+CRLF
    cQuery+=" AND E1_CLIENTE BETWEEN '"+cclide+"' AND '"+ccliate+"' "+CRLF 
    cQuery+=" AND E1_VENCREA BETWEEN '"+DTOS(dDataDE)+"' AND '"+DTOS(dDataATE)+"' "+CRLF
    
    cQuery+=" AND E1_VENCREA < '"+DTOS(dDataBase)+"'  "+CRLF
    cQuery+=" AND E1_SALDO > 0 "+CRLF
    cQuery+=" AND E1_FATURA IN ('','NOTFAT')"+CRLF
    cQuery+=" AND E1_TIPO = 'DP' "+CRLF
    cQuery+=" AND E1_XNUMNFS <> '' "+CRLF
    cQuery+=" AND E1_XENTREG <> 'S' "+CRLF
    
    cTmpE2:= MPSysOpenQuery(cQuery)
    
    //Enquanto houver registros, adiciona na temporária
    While ! (cTmpE2)->(EoF())
        
        SE1->( DbGoTo((cTmpE2)->RECE1))
        natraso:= dDataBase-SE1->E1_VENCREA
        
        nMulta := (cTmpE2)->E1_VALLIQ * ( natraso * ( (cTmpE2)->A1_XMULTA/100 ) )
        nJuros := (cTmpE2)->E1_VALLIQ * ( natraso * ( (cTmpE2)->A1_XJUROS/100 ) )
        nTotLiq:= (cTmpE2)->E1_VALLIQ + nMulta + nJuros         
		aAdd(aColsE1,{;
                    SE1->E1_CLIENTE		,;
                    SE1->E1_LOJA	,;
                    SE1->E1_NOMCLI  ,;	
                    SE1->E1_XNUMNFS  ,;	
					SE1->E1_HIST ,; 
                    SE1->E1_VENCREA	,;
                    SE1->E1_VALOR	,;
                    (cTmpE2)->E1_VALLIQ,;
                    natraso,;
                    (cTmpE2)->A1_XMULTA,;
                    (cTmpE2)->A1_XJUROS,;
                    nTotLiq,;
                    (cTmpE2)->RECE1,;
                     .F.})		
        nvaltot+=nTotLiq
        lDados := .t.
        (cTmpE2)->(DbSkip())
    EndDo
    (cTmpE2)->(DbCloseArea())

    if len(aColsE1)==0
        aColsE1   := {{'','','','','',ctod(''),0,0,0,0,0,0,0,.f.}}
    end
	If ValType(oGdNNT) == 'O'
		oGdNNT:aCols := aColsE1
		if oGdNNT:oBrowse:nAt > len(aColsE1)
			oGdNNT:oBrowse:nAt := 1
		end
        
        if aColsE1[oGdNNT:oBrowse:nAt][nPosRec] <> 0
            SE1->( DbGoTo( aColsE1[oGdNNT:oBrowse:nAt][nPosRec] ) )
            cTexto1:= SE1->E1_OBSCOBR
            oTMultiget1:Refresh()
            oPanel4:Refresh()
        end
		oGdNNT:Refresh()		
	EndIf
    
    ovaltot:settext(  nvaltot )
    ovaltot:Refresh()

Return lDados


Static Function AtuObs( lgrava )

local npos:= nSel01//oGdNNT:oBrowse:nAt
Default lgrava := .f.
if aColsE1[ npos ][nPosRec] <> 0
    SE1->( DbGoTo( aColsE1[ npos ][nPosRec] ) )
    if lgrava
        SE1->(RecLock('SE1',.F.))
            SE1->E1_OBSCOBR:= cTexto1
        SE1->( MsUnLock() )
    end
    cTexto1:= SE1->E1_OBSCOBR
    oTMultiget1:Refresh()
    oPanel4:Refresh()
end

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExpTela
Exporta tela para excel

@author PEDRO OLIVEIRA
@since 03/05/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ExpTela()    

Local cArquivo  := ''
//Private oXML := nil
Private oFWMsExcel := Nil

//Criando o objeto que irá gerar o conteúdo do Excel
oFWMsExcel := FWMSExcel():New()	
FWMsgRun(, {|oSay| GeraExcel(oSay,cArquivo) }, "Gerando arquivo Excel", "Processando a rotina...")

FWMsgRun(, {|| AbreExcel(1) }, "Abrindo Excel", "Processando a rotina...")

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GERAEXCEL
Exporta tela para excel

@author PEDRO OLIVEIRA
@since 03/05/2018
@version P11
/*/
//-------------------------------------------------------------------
Static Function GERAEXCEL(oSay,cArquivo)

Local aExcel := oGdNNT:aCols
Local nI     := 0
Local cPlan := "AFCOB001 - PAINEL DE COBRANÇAS"
Local aAux	:={}
Local nCol  := 1 
Local nC    := 1 
Local cQuery:= '' 

oSay:cCaption := "Gerando dados..."
     
//Aba 01 - Teste           ABA
oFWMsExcel:AddworkSheet(cPlan) //Não utilizar número junto com sinal de menos. Ex.: 1- 
//Criando a Tabela     ABA             TABELA
oFWMsExcel:AddTable(cPlan,cPlan)
     
    
//Criando Colunas         	ABA,TABELA,NomeColuna,alinhamento,tipo de dados
For nCol:=1 To Len(aHdSE1)
	Do Case
		Case aHdSE1[nCol][8] == "N"
			oFWMsExcel:AddColumn(cPlan, cPlan, aHdSE1[nCol][1] ,3,2) // direita - numero        		
		
		Case aHdSE1[nCol][8] == "D" 
        	oFWMsExcel:AddColumn(cPlan, cPlan, aHdSE1[nCol][1] ,2,4) // centro - data
        
        OtherWise
        	oFWMsExcel:AddColumn(cPlan, cPlan, aHdSE1[nCol][1],1,1) // esquerda - texto
    EndCase
Next nCol 

//Criando as Linhas
For nCol:=1 To Len(aExcel)
    aAux :={}
	For nC:=1 To Len(aExcel[nCol])-1
        AADD(aAux, aExcel[nCol][nC] )
    Next nC
    // Cria Linha
    oFWMsExcel:AddRow(cPlan,cPlan,aAux)
   	
Next nCol

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} AbreExcel

Abre relatório - EXCEL

@author Pedro Henrique Oliveira
@since 15/05/2018
@version P12
/*/ 
//-------------------------------------------------------------------
Static Function AbreExcel(nTipo)

Local cDir	:= "C:\TEMP\"
Local cArq	:= cDir+"BTSTRF01-"+Alltrim(DtoS(dDataBase))+"-"+Alltrim(STRTRAN(TIME(),":",""))+".xls"

If nTipo == 2
	cArq	:= cDir+"BTSTRF01-"+Alltrim(DtoS(dDataBase))+"-"+Alltrim(STRTRAN(TIME(),":",""))+".xls"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Veriifica se a pasta existe.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cDir)    
	MakeDir(cDir)
EndIf

//Ativando o arquivo e gerando o xml
oFWMsExcel:Activate()
oFWMsExcel:GetXMLFile(cArq)
    
If ! ApOleClient( 'MsExcel' )
	MsgStop('MsExcel nao instalado') 	
	Return
EndIf

//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()             	//Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArq)     	//Abre uma planilha
oExcel:SetVisible(.T.)                 	//Visualiza a planilha
oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
 
MsgInfo("Relatório gerado!","Atenção")                          

Return

Static Function SyAltCli(lvisual)

local npos:= oGdNNT:oBrowse:nAt
private cCadastro := 'Cliente'
SA1->( dbSetOrder(1) )
SA1->( MsSeek( xFilial('SA1') +aColsE1[ npos ][nposcli] +aColsE1[ npos ][nposloja]   ) )

L030AUTO :=  .F.
nRec:= SA1->(Recno())

if !lvisual
    INCLUI:= .F.
    ALTERA:= .T.
    A030Altera("SA1",nRec,4)
    LjMsgRun("Atualizando Registros ...",,{ || EtFilPed() })
else
    A030Visual("SA1",0,2)     
end

return
