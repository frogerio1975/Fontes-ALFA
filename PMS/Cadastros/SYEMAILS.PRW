#Include "Protheus.ch"
#include "ap5mail.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOPCONN.CH"

#DEFINE CLRF CHR(13)+CHR(10)

/*
Job para monitorar o envio de emails
  */
User Function SYMNTEMAILS()

Local nHdlSemaf := 0 
Local aPar   := {"01","01"}                         


If File("MNTEMAIL"+Dtos(Date())+'.LCK')
    Return(.F.)
Else    
	nHdlSemaf := MSFCreate("MNTEMAIL"+Dtos(Date())+'.LCK')
	IF nHdlSemaf < 0                           
		lRet := .F.
	Endif       
EndIf
	
RPCSETTYPE(3)
WfPrepENV(aPar[1], aPar[2])

//U_SemAgenda()
	
//U_SemApontamento()

//U_ContratosaVencer()

Return

User Function SemAgenda()
Local nX		:= ''
Local nY		:= ''
Local cHtml 	:= ''
Local cHtmlVlr 	:= ''
Local cAssunto 	:= ''
Local cTipoPro	:= ''
Local cDias     := ''
Local nValor	:= 0
Local aPara 	:= {}
Local aAgendas	:= {}
Local lSemAgenda:= .F.

lSemAgenda:= CalcAgendas(@aAgendas)

If Len(aAgendas) > 0 .And. lSemAgenda

    cAssunto := 'URGENTE - Recursos SEM AGENDA - Data de Emissao: ' + Dtoc(dDatabase) 

    dbSelectArea("AE8")
    dbSetOrder(1)
    dbSeek(xFilial("AE8"),.T.)
    While !Eof() 
        If (AE8->AE8_EQUIPE == "4") .And. (AE8->AE8_ATIVO <> '2')//Coordenadores
            Aadd( aPara , AllTrim(AE8->AE8_EMAIL ))
        EndIf
        dbSkip()
    End

    //Aadd( aPara , 'alexandro.dias@alfaerp.com.br' )
    Aadd( aPara , 'fabio.pereira@alfaerp.com.br' )
    Aadd( aPara , 'servicos@alfaerp.com.br' )

    cHtml:= '<HTML>'
    cHtml+= '<HEAD>'
    cHtml+= '<TITLE>URGENTE - Recursos SEM AGENDA</TITLE>'
    cHtml+= '<STYLE>'
    cHtml+= 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
    cHtml+= 'FORM {MARGIN: 0px}'
    cHtml+= '.S_A  {FONT-SIZE: 16px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left} '
    cHtml+= '.S_B  {FONT-SIZE: 16px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif;                            TEXT-ALIGN: left} '
    cHtml+= '.S_B2 {FONT-SIZE: 24px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ff0000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF00; TEXT-ALIGN: Left} '
    cHtml+= '.S_C  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left} ' 			 
    cHtml+= '.S_D  {FONT-SIZE: 14px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left} ' 			 
    cHtml+= '.S_O  {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 100% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
    cHtml+= '</STYLE>'
    cHtml+= '</HEAD>'   
    cHtml+= '<BODY>'   
    cHtml+= '<P class=S_B> ATENCAO!!!<br><br>'  				
    cHtml+= 'Os Consultores abaixo estao SEM AGENDA definida para os dias abaixo. <br><br>'  				
    cHtml+= 'E URGENTE alocar todos os Consultores para que possamos saber a real necessidade de alocacao.. <br><br>'  				
    cHtml+= 'Favor providenciar o cadastramento das OSs <br><br></P>'  				
    cHtml+= '<TABLE style="WIDTH: 100%; HEIGHT: 26px" cellSpacing=0 border=1>' 			
    cHtml+= '<TBODY>'  				

    cHtml+= '<TR>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 45%"><B>Recurso</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 55%"><B>Datas SEM AGENDA</B></TD>'  					
    cHtml+= '</TR>'

    For nX := 1 To Len(aAgendas)
        If Len(aAgendas[nX,2]) > 0
            cHtmlVlr+= '<TR>'  					
            cHtmlVlr+= '	<TD class=S_D style="WIDTH: 45%"><B>' + Alltrim(aAgendas[nX,1]) + '-' + Alltrim(aAgendas[nX,3]) + '</B></TD>'  					
            
            cDias:= ''
            For nY:= 1 To Len(aAgendas[nX,2])
                If !Empty(cDias)
                    cDias+= ','
                EndIf          

                cDias+= StrZero(Day(aAgendas[nX,2,nY]),2) //+ '/' + StrZero(Month(aAgendas[nX,2,nY]),2)          
            nExt nY
            cHtmlVlr+= '	<TD class=S_D style="WIDTH: 55%"><B>Dias: ' + cDias + ' </B></TD>'
            cHtmlVlr+= '</TR>'
        EndIf    
    Next

    cHtml+= cHtmlVlr
    cHtml+= '</TBODY>'  		
    cHtml+= '</TABLE>'
    cHtml+= '</BODY>'
    cHtml+= '</HTML>'

    //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
    //� Enviar e-mail informando aprovacao da proposta.    �
    //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸		
    LjMsgRun("Aguarde, enviando informa寤es para o Gestores de Projetos...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cHtml,.F.,'') } )
EndIf

Return

User Function SemApontamento()
Return

Static Function CalcAgendas(aAgendas)
Local cQuery  := ""
Local nData   := dDatabase      
Local aAloc   := {}
Local nPos    := 0
Local nRec    := 0
Local lTemAgenda:= .F.
Local lRet    := .F.
DEFAULT aAgendas:= {}

//Pega os recursos ativos 
dbSelectArea("AE8")
dbSetOrder( 2 )
dbSeek(xFilial("AE8"),.T.)
While !Eof()
    If AE8->AE8_EQUIPE $ '124' .And. AE8->AE8_ATIVO <> '2'
        aAdd(aAgendas,{AE8->AE8_RECURS,{},AE8->AE8_DESCRI})
    EndIF

    dbskip()
End

//Verifica a alocacao da agenda
cQuery:= " SELECT DISTINCT AE8_RECURS, Z2_DATA"
cQuery+= " FROM " + RetSqlName("AE8") + " AE8 "
cQuery+= " INNER JOIN " + RetSqlName("SZ2") + " SZ2 ON SZ2.D_E_L_E_T_ = '' AND (SZ2.Z2_RECURSO = AE8.AE8_RECURS) AND (SZ2.Z2_DATA BETWEEN '" + Dtos(FirstDay(dDatabase)) + "' AND '" + Dtos(LastDay(dDatabase)) + "')"
cQuery+= " WHERE AE8.D_E_L_E_T_ = ''"
cQuery+= " AND AE8.AE8_EQUIPE IN ('1','2','4')"
cQuery+= " ORDER BY Z2_DATA"

If Select("TMP") > 0
    TMP->(dbCloseArea())
EndIf
	
TcQuery cQuery new Alias "TMP"
TcSetField("TMP", "Z2_DATA"	, "D" , 10 , 0 )

While TMP->( !Eof() )
    
    nPos:= aScan(aAloc,{|x| x[1] == TMP->AE8_RECURS .And. x[2]== TMP->Z2_DATA})
    If (nPos == 0)
        aAdd(aAloc,{TMP->AE8_RECURS,TMP->Z2_DATA})
    EndIf            

    dbSkip()
End		
TMP->(dbCloseArea())

//Verifica quem est'a sem agenda
//Monta vetor com as datas
For nRec:= 1 To Len(aAgendas)
    For nPos:= nData to nData+30
        lTemAgenda:= aScan(aAloc,{|x| x[1] == aAgendas[nRec,1] .And. x[2] == nPos}) > 0
        If !lTemAgenda .And. (cValToChar(DOW( nPos )) $ '23456' )
            aAdd(aAgendas[nRec,2],nPos)
            lRet:= .T.
        EndIf
    Next nPos    
Next nRec


Return(lRet)

User Function ContratosaVencer()
Local nX		:= ''
Local cHtml 	:= ''
Local cHtmlVlr 	:= ''
Local cAssunto 	:= ''
Local cTipoPro	:= ''
Local cDias     := ''
Local nValor	:= 0
Local aPara 	:= {}
Local aContratos:= {}
Local lContrato := .F.

lContrato:= BuscaContrato(@aContratos)

If lContrato
    cAssunto := 'URGENTE - CONTRATOS A VENCER NOS PROXIMOS 30 DIAS - Data de Emissao: ' + Dtoc(dDatabase) 

   // Aadd( aPara , 'alexandro.dias@alfaerp.com.br' )
    Aadd( aPara , 'fabio.pereira@alfaerp.com.br' )
   // Aadd( aPara , 'adm@alfaerp.com.br' )

    cHtml:= '<HTML>'
    cHtml+= '<HEAD>'
    cHtml+= '<TITLE>URGENTE - CONTRATOS A VENCER NOS PROXIMOS 30 DIAS</TITLE>'
    cHtml+= '<STYLE>'
    cHtml+= 'BODY {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'DIV {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'TABLE {FONT-FAMILY: Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= 'TD {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10pt}'
    cHtml+= '.Mini {FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 10px}'
    cHtml+= 'FORM {MARGIN: 0px}'
    cHtml+= '.S_A  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left} '
    cHtml+= '.S_B  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif;                            TEXT-ALIGN: left} '
    cHtml+= '.S_B2 {FONT-SIZE: 12px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ff0000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFF00; TEXT-ALIGN: Left} '
    cHtml+= '.S_C  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #ffffff; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #6baccf; TEXT-ALIGN: left} ' 			 
    cHtml+= '.S_D  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: right} ' 			 
    cHtml+= '.S_E  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #E8E8E8; TEXT-ALIGN: left} ' 			 
    cHtml+= '.S_O  {FONT-SIZE: 10px; VERTICAL-ALIGN: top; WIDTH: 100% ; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-ALIGN: left}   '
    cHtml+= '</STYLE>'
    cHtml+= '</HEAD>'   
    cHtml+= '<BODY>'   
    cHtml+= '<TABLE style="WIDTH: 100%; HEIGHT: 26px" cellSpacing=0 border=1>' 			
    cHtml+= '<TBODY>'  				

    cHtml+= '<TR>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Contrato</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Data da Vigencia</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 20%"><B>Cliente</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Contato</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 20%"><B>Descricao do Contrato</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Valor (SaaS)</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Valor (Cloud)</B></TD>'  					
    cHtml+= '	<TD class=S_B2 style="WIDTH: 10%"><B>Valor (CDU)</B></TD>'  					
    cHtml+= '</TR>'


    For nX := 1 To Len(aContratos)
        cHtmlVlr+= '<TR>'  					
        cHtmlVlr+= '	<TD class=S_E style="WIDTH: 10%"><B>' + aContratos[nX,1] + '</B></TD>'  					
        cHtmlVlr+= '	<TD class=S_E style="WIDTH: 10%"><B>' + Dtoc(aContratos[nX,2]) + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_E style="WIDTH: 20%"><B>' + aContratos[nX,3] + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_E style="WIDTH: 10%"><B>' + aContratos[nX,5] + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_E style="WIDTH: 20%"><B>' + aContratos[nX,4] + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_D style="WIDTH: 10%"><B>' + Transform(aContratos[nX,6],PesqPict("Z02","Z02_VLSAAS")) + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_D style="WIDTH: 10%"><B>' + Transform(aContratos[nX,7],PesqPict("Z02","Z02_CLOUD")) + '</B></TD>'
        cHtmlVlr+= '	<TD class=S_D style="WIDTH: 10%"><B>' + Transform(aContratos[nX,8],PesqPict("Z02","Z02_VLRCDU")) + '</B></TD>'
        cHtmlVlr+= '</TR>'
    Next

    cHtml+= cHtmlVlr
    cHtml+= '</TBODY>'  		
    cHtml+= '</TABLE>'
    cHtml+= '</BODY>'
    cHtml+= '</HTML>'

    //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
    //� Enviar e-mail informando aprovacao da proposta.    �
    //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸		
    LjMsgRun("Aguarde, verificando vigencia dos contratos...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cHtml,.F.,'') } )
    Sleep(3000)
EndIf
Return

Static Function BuscaContrato(aContratos)
Local cQuery  := ""
Local nPos    := 0
Local nRec    := 0
Local lRet    := .F.
DEFAULT aContratos:= {}

//Verifica a alocacao da agenda
cQuery:= " SELECT * "
cQuery+= " FROM " + RetSqlName("Z02") + " Z02 "
cQuery+= " WHERE Z02.D_E_L_E_T_ = ''"
cQuery+= " AND Z02.Z02_VIGENC <= '" + Dtos(dDatabase +30) + "'"
cQuery+= " AND Z02.Z02_VIGENC <> '' "
cQuery+= " AND Z02.Z02_DTAPRO <> '' "
cQuery+= " AND Z02.Z02_ATIVO  = '1' "
cQuery+= " ORDER BY Z02_VIGENC"

If Select("TMP") > 0
    TMP->(dbCloseArea())
EndIf
	
TcQuery cQuery new Alias "TMP"
TcSetField("TMP", "Z02_VIGENC"	, "D" , 10 , 0 )

While TMP->( !Eof() )
    
    nPos:= aScan(aContratos,{|x| x[1] == TMP->Z02_PROPOS .And. x[2] == TMP->Z02_ADITIV .And. x[3]== TMP->Z02_VIGENC})
    If (nPos == 0)
        aAdd(aContratos,{TMP->Z02_PROPOS,TMP->Z02_ADITIV,TMP->Z02_VIGENC,TMP->Z02_RAZAO,TMP->Z02_DESCRI,TMP->Z02_CONTATO,TMP->Z02_VLSAAS,TMP->Z02_CLOUD,TMP->Z02_VLRCDU})
        lRet:= .T.
    EndIf            

    dbSkip()
End		
TMP->(dbCloseArea())

Return(lRet)
