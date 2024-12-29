User Function SIGAFRT()

Local nI   := 0
Local aGrp := {}   
Private dDtbase:= Date()         

//X31UPDTABLE('Z02')
//If(__GetX31Error(), ALERT(__GetX31Trace()), ALERT("Correto"))

If Type("nEPCount") == "U"
	Public nEPCount:= 1
ElseIf Type("nEPCount") == "N"
	If nEPCount >= 2	

		dDatabase:= U_SyDate()

		//Executa o envio de emails
		//LjMsgRun("Enviando emails de Auditoria...",,{|| U_SyMntEmails() })

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              	
		//³Verifica se o usuario pertence ao grupo de administradores.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Alltrim(Upper(UsrRetName(__cUserID))) == "ADMINISTRADOR" ) 

			//Executa a tela do painel financeiro
			U_PAINELFIN("ADMINISTRADOR")
		
		Else
			
			aGrp := UsrRetGrp(UsrRetName(__cUserID))

			For nI:= 1 To Len(aGrp)
				
				IF aGrp[nI] $ "000000/000001/000006" // Admin e Financeiro				

					//Executa a tela do painel financeiro
					U_PAINELFIN("ADMINISTRADOR")

				ElseIf aGrp[nI] == "000007" // RH
				
					//Executa a tela do painel financeiro
					U_PAINELFIN("RH")
					Exit

				ElseIf aGrp[nI] $ "000004/000005" // PMO e Coordenacao Tecnica
					
					//Executa a tela de painel de projetos
					U_AFPMSC110()
		
					//Executa a tela de aprovacao de OS automaticamente
					LjMsgRun("Bloqueando Projetos para Auditoria...",,{|| U_SyPrjAudit() })

					//Executa a tela de aprovacao de OS automaticamente                                                      
					//U_SYPMSA02()
					Exit
					
				ElseIf aGrp[nI] $ "000002/000003" // Coordenacao Comercial e Vendedor
				
					//Chama o painel de propostas
					U_ShowGrfVda()   
					Exit

				EndIf
			
			Next nI
		
		EndIf
		
		nEPCount:= 1
		Final()
	Else
		nEPCount++
	EndIf	
EndIf
	
Return
