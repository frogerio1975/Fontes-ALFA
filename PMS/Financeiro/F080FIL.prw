#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} F080FIL
Baixas contas a Pagar
Faz o filtro conforme um grupo de Perguntas:

@author  Pedro Oliveira
@since   13/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F080FIL()
    //Variaveis 
    Local aArea     := GetArea()
    Local cFilRet   := ""
    Local cPrefDe   := ""
    Local cPrefAt   := ""
    Local cTipoDe   := ""
    Local cTipoAt   := ""
    Local dEmiDe    := sToD("")
    Local dEmiAt    := sToD("")
    Local cFornDe   := ""
    Local cFornAt   := ""
    Local cPerg     := PadR("XF080FIL", 10)
    Local _mv_par01 := mv_par02
    Local _mv_par02 := mv_par01
    Local _mv_par03 := mv_par03
    Local _mv_par04 := mv_par04
      
    ValidPerg(cPerg)

    //Se o usuário confimar o Pergunte
    If Pergunte(cPerg,.T.)
        //Obtendo o conteúdo dos parâmetros
        cPrefDe := mv_par01
        cPrefAt := mv_par02
        cTipoDe := mv_par03
        cTipoAt := mv_par04
        dEmiDe  := mv_par05
        dEmiAt  := mv_par06
        cFornDe := mv_par07
        cFornAt := mv_par08
 
        //Montando o filtro para exibição dos registros
        cFilRet := "SE2->E2_PREFIXO >= '"+cPrefDe+"' .AND. SE2->E2_PREFIXO <= '"+cPrefAt+"' .AND. "
        cFilRet += "SE2->E2_TIPO >= '"+cTipoDe+"' .AND. SE2->E2_TIPO <= '"+cTipoAt+"' .AND. "
        cFilRet += 'SE2->E2_EMISSAO >= sToD("'+dToS(dEmiDe)+'") .AND. SE2->E2_EMISSAO <= sToD("'+dToS(dEmiAt)+'") .AND. '
        cFilRet += "SE2->E2_FORNECE >= '"+cFornDe+"' .AND. SE2->E2_FORNECE <= '"+cFornAt+"' "
    EndIf
     
    //Recuperando o conteudo dos mv_par da rotina padrão
    mv_par01 := _mv_par01
    mv_par02 := _mv_par02  
    mv_par03 := _mv_par03
    mv_par04 := _mv_par04
     
    Pergunte("FIN080",.F.)
     
    //Restaura a area
    RestArea(aArea)
     
Return cFilRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
CRIA SX1
@author		Pedro H. Oliveira 
@since 25/11/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValidPerg(cPerg)

Local aArea  := SX1->(GetArea())
Local aRegs := {}
Local i,j


aAdd(aRegs,{cPerg,"01","Prefixo de ?","",""             ,"mv_ch1","C", TAMSX3('E2_PREFIXO')[1]  ,0,0,"G",""		,"mv_par01",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
aAdd(aRegs,{cPerg,"02","Prefixo ate ?","",""            ,"mv_ch2","C", TAMSX3('E2_PREFIXO')[1]  ,0,0,"G",""		,"mv_par02",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )

aAdd(aRegs,{cPerg,"03","Tipo de ?","",""                ,"mv_ch3","C", TAMSX3('E2_TIPO')[1]     ,0,0,"G",""		,"mv_par03",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","05" } )
aAdd(aRegs,{cPerg,"04","Tipo ate ?","",""               ,"mv_ch4","C", TAMSX3('E2_TIPO')[1]     ,0,0,"G",""		,"mv_par04",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","05" } )

aAdd(aRegs,{cPerg,"05","Emissão de ?","",""             ,"mv_ch5","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par05",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )
aAdd(aRegs,{cPerg,"06","Emissão ate ?","",""            ,"mv_ch6","D", TAMSX3('E1_EMISSAO')[1]  ,0,0,"G",""		,"mv_par06",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","" } )

aAdd(aRegs,{cPerg,"07","Fornecedor de ?","",""          ,"mv_ch7","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""		,"mv_par07",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )
aAdd(aRegs,{cPerg,"08","Fornecedor ate ?","",""         ,"mv_ch8","C", TAMSX3('E2_FORNECE')[1]  ,0,0,"G",""		,"mv_par08",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","","","","","","","","","","","SA2" } )

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
