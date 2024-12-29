#Include "Protheus.ch"
#Include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} F070OWN

Filtra baixa a receber em lote

@author  Pedro Oliveira
@since   26/01/2022
@version 1
/*/
//-------------------------------------------------------------------
User Function F070OWN()
	Local aArea   := GetArea()
	Local cFiltro := ""
    Local aBoxParam	:= {}
    Local aRetParam	:= {}
    Private aEmpFat  := { "1=ALFA", "2=MOOVE", "3=GNP", "4=ALFA","5=Campinas","6=Colaboração" }
    Private cEmpFat  := "1"
    Private dVencIni := dDataBase
    Private dVencFim := dDataBase

    AADD( aBoxParam, {2,"Empresa"         , cEmpFat   , aEmpFat, 50, ".F.", .T.} )
    //AADD( aBoxParam, {1,"Período DE"      , dVencIni   , "@!", "", "", "", 50, .T.} )
    //AADD( aBoxParam, {1,"Período ATE"     , dVencFim   , "@!", "", "", "", 50, .T.} )

    If ParamBox(aBoxParam,"Parametros - Contas a Pagar",@aRetParam,,,,,,,,.F.)

        cEmpFat  := aRetParam[1]
        //dVencIni  := aRetParam[2]
        //dVencFim  := aRetParam[3]

    End    

	//Montando o filtro
	If IsInCallStack("FA070ChecF")
		//cFiltro += 'E1_FILIAL+E1_PORTADO+E1_AGEDEP+E1_CONTA=="'+xFilial("SE1")+cBancoLt+cAgenciaLt+cContaLt+'".And.'
		//cFiltro += 'DTOS(E1_VENCREA)>="'+DTOS(dVencDe) + '".And.'
		//cFiltro += 'DTOS(E1_VENCREA)<="'+DTOS(dVencAte)+ '".And.'
		//cFiltro += 'E1_NATUREZ>="'      +cNatDe       + '".And.'
		//cFiltro += 'E1_NATUREZ<="'      +cNatAte      + '".and.'
        
        cFiltro += 'E1_FILIAL =="'+xFilial("SE1")+'".And.'
		cFiltro += 'DTOS(E1_VENCREA)>="'+DTOS(dVencDe) + '".And.'
		cFiltro += 'DTOS(E1_VENCREA)<="'+DTOS(dVencAte)+ '".And.'
		//cFiltro += 'E1_NATUREZ>="'      +cNatDe       + '".And.'
		//cFiltro += 'E1_NATUREZ<="'      +cNatAte      + '".and.'        
		cFiltro += '!(E1_TIPO$"'+MVPROVIS+"/"+MVRECANT+"/"+MVIRABT+"/"+MVINABT+"/"+MV_CRNEG

		//Destarcar Abatimentos
		If mv_par06 == 2
			cFiltro += "/"+MVABATIM+"/"+MVFUABT +'")' //adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		Else
			cFiltro += '")'
		Endif

		// Verifica integracao com TMS e nao permite baixar titulos que tenham solicitacoes
		// de transferencias em aberto.
		cFiltro += ' .And. Empty(E1_NUMSOL)'
		cFiltro += ' .And. (E1_SALDO>0 .OR. E1_OK="xx")'
        
        cFiltro += ' .And. E1_EMPFAT == "'+cEmpFat+'"' 
    
		cFiltro += ' .And. !EMPTY(E1_XNUMNFS) '  
		//Montando o filtro
	ElseIf IsInCallStack("FA070Chec0")
		cFiltro += 'E1_FILIAL=="' + xFilial("SE1") + '".And.'
		cFiltro += 'DTOS(E1_VENCREA)>="' + DTOS(dVencDe)  + '".And.'
		cFiltro += 'DTOS(E1_VENCREA)<="' + DTOS(dVencAte) + '".And.'
		//cFiltro += 'E1_NATUREZ>="'       + cNatDe         + '".And.'
		//cFiltro += 'E1_NATUREZ<="'       + cNatAte        + '".And.'
		//cFiltro += '(E1_PORTADO="'       + cBancolt         + '".OR.'
		//cFiltro += 'E1_PORTADO=="'+ space(Len(E1_PORTADO)) + '").AND.'
		cFiltro += '!(E1_TIPO$"'+MVPROVIS+"/"+MVRECANT+"/"+MVIRABT+"/"+MVINABT+"/"+MV_CRNEG

		//Destacar Abatimentos
		If mv_par06 == 2
			cFiltro += "/"+MVABATIM+"/"+MVFUABT +'")'//adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		Else
			cFiltro += '")'
		Endif

		// Verifica integracao com TMS e nao permite baixar titulos que tenham solicitacoes
		// de transferencias em aberto.
		cFiltro += ' .And. Empty(E1_NUMSOL)'
		cFiltro += ' .And. (E1_SALDO>0 .OR. E1_OK="xx")'
        cFiltro += ' .And. E1_EMPFAT == "'+cEmpFat+'"' 
	EndIf

    

	//cFiltro += Iif(!Empty(cFiltro), " .And. ", "")+" E1_X_CAMPO = 'XXX' "

	RestArea(aArea)
Return cFiltro
