User Function F040FCR()
Local cBuscaSe1:= ""
Local cTitPai  := ""
Local aArea    := GetArea()

//Ajusta a gravacao do campo Titulo Pai que apresenta problema com o IR
cBuscaSe1 := xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)

//Identifica qual é o titulo PAI
dbSelectArea("SE1")	
dbSetOrder(1)
dbGoTop()
dbSeek(cBuscaSe1)
Do While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cBuscaSe1
	If !(SE1->E1_TIPO $ "IR-|PI-|CS-|CF-") .and. Empty(SE1->E1_TITPAI) // Achou o titulo principal
        cTitPai		:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) 
	   Exit
	Endif
	dbSkip()	
Enddo

//Acerta os titulos das retencoes
dbSelectArea("SE1")	
dbSetOrder(1)
dbGoTop()
dbSeek(cBuscaSe1)
Do While !Eof() .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cBuscaSe1
    If ("-" $ SE1->E1_TIPO) .and. Empty(SE1->E1_TITPAI) 
        RecLock("SE1", .F.)
        Replace E1_TITPAI With cTitPai 
        MsUnlock()
    Endif
    dbSkip()	
Enddo

RestArea(aArea)

Return(.T.)

User Function F040ALTR()

U_F040FCR()

Return(.T.)
