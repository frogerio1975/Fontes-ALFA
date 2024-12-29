#Include "Protheus.ch"
#Include "MsOle.ch"

#Define VALORPARCELA  	 1
#Define DATAVENCIMENTO	 2
#Define FORMAPAGTO		 3
#Define MODALIDADE		 4
#Define QTDPARCELAS		 5
#Define TOTALCOMIMP		 6
#Define DESCONTO_PARCELA 7
#Define OLECREATELINK  400
#Define OLECLOSELINK   401
#Define OLEOPENFILE    403
#Define OLESAVEASFILE  405
#Define OLECLOSEFILE   406
#Define OLESETPROPERTY 412
#Define WDFORMATTEXT   '2' 
#Define WDFORMATPDF    '17'
#Define OLEWDVISIBLE   '206'
#Define cEOL			CHR(13) + CHR(10)

User Function SyImpProposta(cNumProposta,cAditivo,cRevisao,cTitulo,cTipoCli,cCliente,cContato,cGerente,cVendedor,cDataEmissao,cTpVenda,cTpFat,nTranslado,aEscopo,;
aVencimento,cCondPg,aHeadRes,aColsRes,nImpostos,nVlSMC,nDesconto,nDscTotal,cTituloExtra,cPremissas,cRestricao,cObjetivo,cCondGerais,cTipoContrato,lGCV,cPrazoMes,aDespAten,;
cSocio1,cCodVend,aSuporte,cHorasServico,cEmpFat,lPdf)

Local nPDescri  		:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_DESCRI"})
Local nPMod  			:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_MOD"})
Local nPPrcTab   		:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PRCTAB"})
Local nPQuant			:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_QUANT"})
Local nPPrcVen			:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_PRCVEN"})
Local nQtdHoraVen		:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_HORASA"})
Local nVlrHoraTab		:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_VLHORA"})
Local nVlrHoraVen		:= aScan(aHeadRes,{|x| AllTrim(x[2]) == "Z05_VLHRDE"})
Local cDataExtenso 		:= Alltrim(GetMv('MV_SYCIDAD',,'São Caetano do Sul')) +', '+ AllTrim(Str(Day(dDataBase),2)) +' de '+ Capital(AllTrim(MesExtenso(dDataBase))) +' de '+ AllTrim(Str(Year(dDataBase),4))
Local cDirServer	  	:= GetSrvProfString("StartPath","") + 'word\'
Local cArqModelo		:= ''
Local cPathLocal		:= IIf(GetRemoteType() == 1,'c:\Propostas\','/Documents/')
Local nY				:= 0
Local nX				:= 0
Local nE				:= 0
Local nDet				:= 0
Local nTotHrsProj		:= 0
Local nTotalHrs			:= 0
Local nFranquiaHrs		:= 0
Local nValorHora		:= 0
Local nSubtotal2		:= 0
Local nItens            := 0
Local nLinha			:= 0
Local nItem				:= 0
Local aDetalhes     	:= {}
Local cDescriParcelas	:= ''
Local cSetupCloud		:= ''
Local cModulo 			:= ''
Local cMemo				:= ''
Local cArqPDF			:= ''
Local cArqDOC			:= ''
Local cIndice           := ''
Local cNomeSocio		:= ''
Local cCpfSocio			:= ''
Local cCPFVendedor		:= ''
Local cRevendedor      	:= ''
Local cRevCNPJ          := ''
Local cRevEndereco      := ''
Private	oWord

DEFAULT lPdf := .T.

If alltrim(GetEnvServer()) <> 'PRODUCAO'
	cDirServer := GetSrvProfString("StartPath","") + 'word\compila\'
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Representante Legal.  	                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA3->(DbSetOrder(1))
If SA3->( DbSeek( xFilial('SA3')+cSocio1 ) )
	cNomeSocio:= Alltrim( SA3->A3_NOME )
	cCpfSocio := Alltrim( SA3->A3_CGC )
	cCpfSocio := StrTran( StrTran( cCpfSocio,'.','') ,'-','') 
	If Len(cCpfSocio) > 11
		cCpfSocio:= AllTrim(Transform( cCpfSocio, "@R 99.999.999/9999-99" ))
	Else
		cCpfSocio:= AllTrim(Transform( cCpfSocio, "@R 999.999.999-99" ))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Vendedor. 	                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA3->(DbSetOrder(1))
If SA3->( DbSeek( xFilial('SA3')+cCodVend ) )
	cCPFVendedor := Alltrim( SA3->A3_CGC )
	cCPFVendedor := StrTran( StrTran( cCPFVendedor,'.','') ,'-','') 
	If Len(cCPFVendedor) > 11
		cCPFVendedor:= AllTrim(Transform( cCPFVendedor, "@R 99.999.999/9999-99" ))
	Else
		cCPFVendedor:= AllTrim(Transform( cCPFVendedor, "@R 999.999.999-99" ))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Lead ou Cliente.   	                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cTipoCli == 'C'
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek(xFilial('SA1') + cCliente ) )
	cLicenciada 	:= SA1->A1_NOME
	cLicFantasia	:= SA1->A1_NREDUZ
	cLicCNPJ		:= SA1->A1_CGC
	cLicEndereco	:= Alltrim(SA1->A1_END) + ', ' + Alltrim(SA1->A1_MUN) + ', ' + Alltrim(SA1->A1_EST) + ', ' + Transform(SA1->A1_CEP,'@R 99999-999')

Else
	SUS->( DbSetOrder(1) )
	SUS->( DbSeek(xFilial('SUS') + cCliente ) )
	cLicenciada 	:= SUS->US_NOME
	cLicFantasia	:= SUS->US_NREDUZ
	cLicCNPJ		:= SUS->US_CGC
	cLicEndereco	:= Alltrim(SUS->US_END) + ', ' + Alltrim(SUS->US_MUN) + ', ' + Alltrim(SUS->US_EST) + ', ' + Transform(SUS->US_CEP,'@R 99999-999')
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faturar por SCS ou Campinas.   	                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (cEmpFat == '2') //Moove
	cRevendedor     := 'MOOVE CONSULTORIA LTDA'
	cRevCNPJ     	:= '13.400.708/0001-81'
	cRevEndereco	:= 'Rua Pará, 139 - 6º Andar, Centro, São Caetano do Sul, SP, 09510-130'

ElseIF (cEmpFat == '5') //Campinas
	cRevendedor     := 'ALFA SERVIÇOS EMPRESARIAIS LTDA'
	cRevCNPJ     	:= '47.841.289/0001-35'
	cRevEndereco  	:= 'Av. Doutor José Bonifácio Coutinho Nogueira, 214 Sala 524, Jardim Madalena, Campinas, SP, 13091-611'

Else
	cRevendedor     := 'ALFA SISTEMAS DE GESTÃO LTDA'
	cRevCNPJ     	:= '07.640.028/0001-32'
	cRevEndereco	:= 'Rua Pará, 139 - 6º Andar, Centro, São Caetano do Sul, SP, 09510-130'
EndIf

Z02->( DbSetOrder(1) )
IF Z02->( DbSeek(xFilial('Z02') + cNumProposta ) )
	nValorHora := Z02->Z02_VLHORA
	cIndice    := FwGetSX5("Z9",Z02->Z02_INDICE)[1,4]
EndIF 

IF nValorHora <= 0
	Aviso("Atencao","Informar o Valor/Hora da Proposta.",{"Ok"})
	Return(.T.)
EndIF

cPathLocal += Alltrim( Lower( Subst( cLicFantasia , 1 , 3 ) + Subst( cLicFantasia , 4 , At( ' ' , Subst( cLicFantasia , 4 , Len(cLicFantasia) ) ) ) ) ) + '\'

FwMakeDir(cPathLocal)
IF !ExistDir(cPathLocal)
	FwMakeDir(cPathLocal)
	IF MakeDir(cPathLocal) != 0 
		Aviso( "Atencao" , "Não foi possível criar o diretório: " +cPathLocal , {"Ok"} )
    	Return(.T.)
	EndIF
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Propostas.                 	                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (cTpVenda == '1') .And. (cTipoContrato == '1')	// Servicos - Novo Contrato
	cArqModelo := 'moove_servicos_proposta.dotm'

ElseIF (cTpVenda $ '1') .And. (cTipoContrato == '2')	// Servicos - Aditivo de Contrato
	cArqModelo := 'moove_servicos_aditivo.dotm'

ElseIF (cTpVenda == '8') .And. (cTipoContrato == '1')	// SaaS - Novo Contrato
	cArqModelo := 'moove_saas_proposta.dotm'

ElseIF (cTpVenda == '8') .And. (cTipoContrato == '2')	// SaaS - Aditivo de Contrato
	cArqModelo := 'moove_saas_aditivo.dotm'

ElseIF (cTpVenda == '2')	// Service Desk
	cArqModelo := 'moove_servicos_proposta_servicedesk.dotm'

ElseIF (cTpVenda == '3') .And. (cTipoContrato == '1')	// SaaS - Novo Contrato
	cArqModelo := 'alfa_saas_proposta.dotm'

ElseIF (cTpVenda == '3') .And. (cTipoContrato == '2')	// SaaS - Aditivo de Contrato
	cArqModelo := 'alfa_saas_aditivo.dotm'

ElseIF (cTpVenda == '5') .And. (cTipoContrato == '1')	// Servicos - Novo Contrato
	cArqModelo := 'alfa_servicos_proposta.dotm'

ElseIF (cTpVenda == '5') .And. (cTipoContrato == '2')	// Servicos - Aditivo de Contrato
	cArqModelo := 'alfa_servicos_aditivo.dotm'

ElseIF (cTpVenda == '7') // Servicos - Aditivo de Contrato
	cArqModelo := 'alfa_servicos_aditivo.dotm'


ElseIF (cTpVenda == '6')	// Service Desk
	cArqModelo := 'alfa_servicos_proposta_servicedesk.dotm'

Else
	Aviso( "Atencao" , "Não existe um Modelo de Proposta para esse tipo de Contrato: " + cTpVenda, {"Ok"} )
	Return(.T.)

EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conecta ao Word.							                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !__CopyFile( cDirServer + cArqModelo , cPathLocal + cArqModelo )
	Aviso( "Atencao" , "Não foi possível copiar o modelo para o diretório: " +cPathLocal+cArqModelo , {"Ok"} )
	Return(.T.)
EndIF

BeginMsOle()

oWord := OLE_CreateLink()
If (Val(oWord) < 0)
	Aviso( "Atencao" , "Não foi possível abrir o arquivo no Word: " +cPathLocal+cArqModelo , {"Ok"} )
	Return(.T.)
EndIf

OLE_NewFile( oWord , cPathLocal + cArqModelo )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da Proposta.              			                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(oWord, 'cNumProposta'	,cNumProposta)
OLE_SetDocumentVar(oWord, 'cRevisao'		,cRevisao)
OLE_SetDocumentVar(oWord, 'cAditivo'		,cAditivo)
OLE_SetDocumentVar(oWord, 'cDataEmissao'	,cDataEmissao)
OLE_SetDocumentVar(oWord, 'cTitulo'			,Upper(IIF(Empty(cTituloExtra),cTitulo,cTituloExtra)))
OLE_SetDocumentVar(oWord, 'cNomeSocio'		,cNomeSocio)
OLE_SetDocumentVar(oWord, 'cCPFSocio'		,cCpfSocio)
OLE_SetDocumentVar(oWord, 'cVendedor'		,cVendedor)
OLE_SetDocumentVar(oWord, 'cCPFVendedor'	,cCPFVendedor)
OLE_SetDocumentVar(oWord, 'nMesesDeContrato',cPrazoMes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Revendedor (ALFA/MOOVE).			                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(oWord, 'cRevendedor'		,cRevendedor)
OLE_SetDocumentVar(oWord, 'cRevCNPJ'		,cRevCNPJ)
OLE_SetDocumentVar(oWord, 'cRevEndereco'	,Upper(cRevEndereco))
OLE_SetDocumentVar(oWord, 'cGerente'		,cGerente)
OLE_SetDocumentVar(oWord, 'cVendedor'		,cVendedor)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Lead/Cliente.          			                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(oWord, 'cLicenciada'		,cLicenciada)
OLE_SetDocumentVar(oWord, 'cLicFantasia'	,cLicFantasia)
OLE_SetDocumentVar(oWord, 'cLicCNPJ'		,Transform(cLicCNPJ,'@R 99.999.999/9999-99'))
OLE_SetDocumentVar(oWord, 'cLicEndereco'	,cLicEndereco)
OLE_SetDocumentVar(oWord, 'cLicContato'		,Upper(cContato))

OLE_SetDocumentVar(oWord, 'cPagtoServicos' 	,cDescriParcelas )

OLE_SetDocumentVar(oWord, 'cPremissas'		,cPremissas)
OLE_SetDocumentVar(oWord, 'cRestricao'		,cRestricao)
OLE_SetDocumentVar(oWord, 'cObjetivo'		,cObjetivo)
OLE_SetDocumentVar(oWord, 'cCondGerais'		,cCondGerais)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o nome do Indice de Reajuste no Contrato.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(oWord, 'cIndice' , cIndice )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui Data do Contrato.						                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_SetDocumentVar(oWord, 'cDataExtenso' , cDataExtenso )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime propostas de Servicos.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cTpVenda $ '1/2/5/6/7'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para MACRO o total de linhas do ESCOPO. Esta variavel sera utilizada para criar os CAMPOS ³
	//³ dentro do WORD.                        															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_SetDocumentVar( oWord , 'Prt_ItensEscopo'	, Alltrim( Str( Len(aEscopo) ) ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem das variaveis dos itens. No documento word estas variaveis serao criadas dinamicamente ³
	//³  da seguinte forma: Prt_Modulo1, Prt_Modulo2 ... Prt_Modulo10.  							    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aEscopo)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma total de horas do escopo.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotHrsProj += aEscopo[nX,2]
		
		cModulo 	:= ''
		cMemo		:= ''
		aDetalhes	:= {}
		nItem 		:= 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sub-Item do Escopo.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY:= 1 To Len(aEscopo[nX,4])
			
			cModulo := Upper(Alltrim(aEscopo[nX,1]))
			cMemo	:= Alltrim(aEscopo[nX,3])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o Array for maior que 1 entende-se que e para imprimir o escopo. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF Len(aEscopo[nX,4,nY][4]) > 0 .And. aEscopo[nX,6] == '1'
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclui os Itens do SubMenu.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDet 	:= ''
				
				For nE := 1 To Len(aEscopo[nX,4,nY,4])
					
					nItem++
					
					cDet := ''
					
					IF Empty(aEscopo[nX,4,nY,4,nE,4]) // Memo
						
						cDet += StrZero(nItem,2) + ' - ' + Alltrim(aEscopo[nX,4,nY,4,nE,1])
						
					Else
						
						cDet += StrZero(nItem,2) + ' - ' + Upper(Alltrim(aEscopo[nX,4,nY,4,nE,1]))
						
						
						cDet += aEscopo[nX,4,nY,4,nE,4]
						
					EndIF
					
					Aadd(aDetalhes,{cDet,''})
					
				Next
				
			EndIF
			
		Next nY
		
		nLinha += 1
		OLE_SetDocumentVar(oWord,"Prt_Modulo"	+ AllTrim(Str(nLinha)) , cModulo 	)
		OLE_SetDocumentVar(oWord,"Prt_Memo"		+ AllTrim(Str(nLinha)) , cMemo		)
		OLE_SetDocumentVar(oWord,'Prt_Detalhes'	+ AllTrim(Str(nLinha)), Alltrim( Str( Len(aDetalhes) ) ) )
		
		For nDet := 1 To Len(aDetalhes)
			OLE_SetDocumentVar(oWord,"Prt_Item"		+ AllTrim(Str(nLinha)) + "_" + AllTrim(Str(nDet)) , aDetalhes[nDet,1] )
		Next nDet
		
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui as linhas/itens do escopo.                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_ExecuteMacro(oWord,"TabItensEscopo")
	
	cTexto 				:= ''
	nSubTotal			:= 0
	nTotalProjeto		:= 0
	nDesconto			:= 0
	nValImpostos		:= 0
	
	For nX := 1 To Len(aColsRes)
		
		IF nX > 1
			cTexto += cEOL
		EndIF
		
		cTexto += StrZero(nX,2) + ' - ' + Alltrim(aColsRes[nX,nPDescri]) + cEOL

		// Iguala os precos caso o preco de Tabela seja menor que o preco de venda.
		// Necessario tratar aqui, pois as vezes o vendedor deixa o preco de Tabela menor.
		IF aColsRes[nX,nVlrHoraTab] < aColsRes[nX,nVlrHoraVen]
			aColsRes[nX,nVlrHoraTab] := aColsRes[nX,nVlrHoraVen]
		EndIF
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma valores do escopo.		                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotalHrs 	+= aColsRes[nX,nQtdHoraVen]
		nSubTotal	+= aColsRes[nX,nVlrHoraTab] * aColsRes[nX,nQtdHoraVen]
		nDesconto	+= ( aColsRes[nX,nVlrHoraTab] - aColsRes[nX,nVlrHoraVen] ) * aColsRes[nX,nQtdHoraVen]

	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui Parcelas.																				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nX := 1 To Len(aVencimento)
		
		cDescriParcelas += AllTrim(Str(nX)) + 'ª Parcela: ' + Dtoc(aVencimento[nX,DATAVENCIMENTO])
		cDescriParcelas += ' - R$ ' + Alltrim(Transform(aVencimento[nX,VALORPARCELA],"@E 999,999.99"))
		
		IF !Empty(aVencimento[nX,FORMAPAGTO])
			cDescriParcelas += ' - ' + aVencimento[nX,FORMAPAGTO]
		EndIF
		
		cDescriParcelas += + cEOL
		
		//Valor do Desconto (Sem Imposto)
		nDesconto   += Round( aVencimento[nX,DESCONTO_PARCELA] , 2 )

	Next
	
	OLE_SetDocumentVar( oWord , 'MacroEscopo' , Upper(cTexto) )

	nTotalProjeto	:= (nSubTotal - nDesconto) / nImpostos
	nValImpostos	:= nTotalProjeto - (nSubTotal - nDesconto)
	nSubtotal2		:= nSubTotal - nDesconto

	OLE_SetDocumentVar( oWord , 'nSubtotal'		, Alltrim(Transform(nSubTotal,"@E 999,999.99")) )	
	
	IF nDesconto > 0
		OLE_SetDocumentVar( oWord , 'cDesconto'		, 'Descontos (' + Alltrim(Transform(Round( (nDesconto / nSubTotal) * 100, 2),"@E 999,999.99"))  + '%)' )
		OLE_SetDocumentVar( oWord , 'nDesconto'		, '- ' + Alltrim(Transform(nDesconto,"@E 999,999.99")) )
		OLE_SetDocumentVar( oWord , 'cSubtotal2'	, 'Subtotal' )
		OLE_SetDocumentVar( oWord , 'nSubtotal2'	,  Alltrim(Transform(nSubtotal2,"@E 999,999.99")) )
	Else
		OLE_SetDocumentVar( oWord , 'cDesconto'		, '' )
		OLE_SetDocumentVar( oWord , 'nDesconto'		, '' )
		OLE_SetDocumentVar( oWord , 'cSubtotal2'	, '' )
		OLE_SetDocumentVar( oWord , 'nSubtotal2'	, '' )
	EndIf
	
	OLE_SetDocumentVar( oWord , 'nImpostos'		, Alltrim(Transform(nValImpostos,"@E 999,999.99")) )
	OLE_SetDocumentVar( oWord , 'nTotalProjeto'	, Alltrim(Transform(nTotalProjeto,"@E 999,999.99")) )
	
	OLE_SetDocumentVar( oWord , 'cPagtoServicos' 	, cDescriParcelas )
	OLE_SetDocumentVar( oWord , 'cHorasServico' 	, Alltrim(Transform(cHorasServico,"@E 999,999,999")))
	OLE_SetDocumentVar( oWord , 'nHorasEstimadas' 	, Alltrim(Transform(nTotalHrs,"@E 999,999,999")))
	OLE_SetDocumentVar( oWord , 'ValorHora' 		, Alltrim(Transform(nValorHora,"@E 999,999.99")))
	
	OLE_SetDocumentVar( oWord , 'cValDia' 			, Alltrim(Transform( aDespAten[1],"@E 999,999.99")))
	OLE_SetDocumentVar( oWord , 'cValNoite' 		, Alltrim(Transform( aDespAten[2],"@E 999,999.99")))
	OLE_SetDocumentVar( oWord , 'cEstacionamento' 	, Alltrim(Transform( aDespAten[3],"@E 999,999.99")))
	OLE_SetDocumentVar( oWord , 'cKmDia' 			, Alltrim(Transform( aDespAten[4],"@E 999,999.99")))

Else // SaaS
	
	nItens:= Len(aColsRes)
	
	OLE_SetDocumentVar( oWord , 'Prt_ItensValores'	, Alltrim( Str( nItens ) ) )
	
	nSubTotal			:= 0
	nMensal				:= 0
	nDesconto			:= 0
	nValImpostos		:= 0
	cPrimeiroVencimento	:= ''
	cSetupCloud			:= ''

	For nX := 1 To Len(aColsRes)

		// Iguala os precos caso o preco de Tabela seja menor que o preco de venda.
		// Necessario tratar aqui, pois as vezes o vendedor deixa o preco de Tabela menor.

		IF aColsRes[nX,nPPrcTab] < aColsRes[nX,nPPrcVen]
			aColsRes[nX,nPPrcTab] := aColsRes[nX,nPPrcVen]
		EndIF

		//Verifica se o item é o produto de Suporte para exibir o total no quadro da franquia de atendimento
		If (AllTrim(aColsRes[nX,nPMod]) == '5')
			
			nFranquiaHrs += aColsRes[nX,nPQuant]
			
			IF aColsRes[nX,nPPrcTab] > nValorHora
		
				nValorHora := aColsRes[nX,nPPrcTab]
		
			EndIF
		
		EndIf

		OLE_SetDocumentVar(oWord,"Prt_Descricao"	+ AllTrim(Str(nX))	, aColsRes[nX,nPDescri] )
		OLE_SetDocumentVar(oWord,"Prt_Qtd"			+ AllTrim(Str(nX))	, Alltrim(TransForm(aColsRes[nX,nPQuant] ,'@E 9999')) )
		OLE_SetDocumentVar(oWord,"Prt_Tabela"		+ AllTrim(Str(nX))	, Alltrim(TransForm(aColsRes[nX,nPPrcTab],'@E 999,999.99')) )
		OLE_SetDocumentVar(oWord,"Prt_VlrMensal"	+ AllTrim(Str(nX))	, Alltrim(TransForm(aColsRes[nX,nPQuant] * aColsRes[nX,nPPrcTab],'@E 999,999.99')) )

		nSubTotal	+= aColsRes[nX,nPPrcTab] * aColsRes[nX,nPQuant]
		nDesconto	+= ( aColsRes[nX,nPPrcTab] - aColsRes[nX,nPPrcVen] ) * aColsRes[nX,nPQuant]

	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parcelas da Proposta.																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aVencimento)

		IF aVencimento[nX,MODALIDADE] == '2'
			Loop
		EndIF
		
		IF aVencimento[nX,MODALIDADE] == '3' .And. aVencimento[nX,VALORPARCELA] > 0 // 3-Setup do Cloud

			cSetupCloud += 'Parcela Única de R$ ' + Alltrim(Transform(aVencimento[nX,VALORPARCELA],"@E 999,999.99"))
			cSetupCloud += ' com Vencimento em ' + Dtoc(aVencimento[nX,DATAVENCIMENTO])

			Loop

		ENDIF
		
		IF Empty(cPrimeiroVencimento)
			cPrimeiroVencimento  := Dtoc(aVencimento[nX,DATAVENCIMENTO])
		EndIF
		
		//Soma o Desconto na Parcela (Sem Imposto)
		nDesconto += Round( aVencimento[nX,DESCONTO_PARCELA] , 2 )

	Next nX
	
	OLE_ExecuteMacro(oWord,"TabItensValores")

	nMensal		:= (nSubTotal - nDesconto) / nImpostos
	nValImpostos:= nMensal - (nSubTotal - nDesconto)
	nSubtotal2	:= nSubTotal - nDesconto

	OLE_SetDocumentVar( oWord , 'nSubtotal'		, Alltrim(Transform(nSubTotal,"@E 999,999.99")) )	
	
	IF nDesconto > 0
		OLE_SetDocumentVar( oWord , 'cDesconto'		, 'Descontos (' + Alltrim(Transform(Round( (nDesconto / nSubTotal) * 100, 2),"@E 999,999.99"))  + '%)' )
		OLE_SetDocumentVar( oWord , 'nDesconto'		, '- ' + Alltrim(Transform(nDesconto,"@E 999,999.99")) )
		OLE_SetDocumentVar( oWord , 'cSubtotal2'	, 'Subtotal' )
		OLE_SetDocumentVar( oWord , 'nSubtotal2'	, Alltrim(Transform(nSubtotal2,"@E 999,999.99")) )
	Else
		OLE_SetDocumentVar( oWord , 'cDesconto'		, '' )
		OLE_SetDocumentVar( oWord , 'nDesconto'		, '' )
		OLE_SetDocumentVar( oWord , 'cSubtotal2'	, '' )
		OLE_SetDocumentVar( oWord , 'nSubtotal2'	, '' )
	EndIf
	
	OLE_SetDocumentVar( oWord , 'nImpostos'	, Alltrim(Transform(nValImpostos,"@E 999,999.99")) )
	OLE_SetDocumentVar( oWord , 'nMensal'	, Alltrim(Transform(nMensal,"@E 999,999.99")) )

	OLE_SetDocumentVar( oWord , 'nValorMensal'			, 	'R$ ' + Alltrim(Transform(nMensal,"@E 999,999.99")) )
	OLE_SetDocumentVar( oWord , 'cPrimeiroVencimento'	,	cPrimeiroVencimento )

	OLE_SetDocumentVar( oWord , 'cSetupCloud' , cSetupCloud )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a Franquia de Atendimento de Suporte.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OLE_SetDocumentVar( oWord ,	'nFranquiaHrs'	, 	Alltrim(Transform(nFranquiaHrs,"@E 999,999,999")) )
	OLE_SetDocumentVar( oWord ,	'nVLrHrFranquia', 	Alltrim(Transform(nValorHora,"@E 999,999.99")) )
	
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizando as variaveis do documento do Word.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OLE_UpdateFields(oWord)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o nome da proposta.					                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq	:= 'Contrato No ' + cNumProposta +' - '+ AllTrim(cLicFantasia) +' - '+ AllTrim(cTitulo)
cArqPDF		:= cPathLocal + cNomeArq + '.pdf'
cArqDOC		:= cPathLocal + cNomeArq + '.doc'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime proposta.							                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lPDF

	// Ativa ou desativa impressao em segundo plano. 
	OLE_SetProperty( oWord, oleWdPrintBack, .F. )		
	
	// Salva o documento como PDF
	ExecInClient(OLESAVEASFILE, { oWord	, cArqPDF , '', '', '0', WDFORMATPDF } )
	
	OLE_SaveAsFile( oWord , cArqPDF )

	Ferase(cArqDOC)

Else 

	OLE_SaveAsFile( oWord , cArqDOC )

EndIF

// Fecha conexão com objeto OLE
OLE_CloseFile( oWord )
EndMsOle()
OLE_CloseLink( oWord )

Ferase( cPathLocal + cArqModelo)

Aviso('Atencao','Arquivo criando em: ' +cEOL+cEOL+ IIF ( lPDF , cArqPDF , cArqDOC ) ,{'Ok'})

ShellExecute('open',IIF ( lPDF , cArqPDF , cArqDOC ),'','',5) 

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EmailIncProº Autor ³Alexandro          º Data ³  05/18/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EmailIncPro(cOrig,cProposta,cAditivo)

Local nX			:= ''
Local cHtmlProdutos	:= ''
Local cHtmlParcelas	:= ''
Local cHtmlComissao	:= ''
local cHtmlPMO		:= ''
Local cAssunto 		:= ''
Local cDadosProposta:= ''
Local nTotal 		:= 0
Local nCusTotal		:= 0
Local aPara 		:= {}
Local aParcelas		:= {}
Local aComissao		:= {}
Local aProdutos 	:= {}
Local aParaPMO 		:= {}

DbSelectArea("Z02")
DbOrderNickName("Z02PROPOS")
IF !DbSeek(xFilial("Z02")+cProposta+cAditivo)
	Return(.T.)
EndIF

cDadosProposta := Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV + ' - Cliente: ' + Alltrim( Subst( Z02->Z02_RAZAO , 1 , At( ' ' , Z02->Z02_RAZAO ) ) )

IF cOrig == "APROVA"

	cAssunto := "Proposta Aprovada - Numero: " + cDadosProposta

	IF Z02->Z02_TIPO $ '128' // TOTVS

		Aadd( aPara   , SuperGetMv("MV_MOVMAIL",.F.,"") )
		Aadd( aParaPMO, "pmo@mooveconsultoria.com.br")
		Aadd( aParaPMO, "cs@mooveconsultoria.com.br")

	Else // ALFA
		
		Aadd( aPara   , SuperGetMv("MV_ALFMAIL",.F.,"") )
		Aadd( aParaPMO, "pmo@alfaerp.com.br")
		Aadd( aParaPMO, "cs@alfaerp.com.br")
		
	EndIF

Else

	cAssunto := "Validar Proposta - Numero: " + cDadosProposta

	IF Z02->Z02_TIPO $ '128' // TOTVS

		Aadd( aPara   , SuperGetMv("MV_MOVMAIL",.F.,"") )

	Else // ALFA
		
		Aadd( aPara   , SuperGetMv("MV_ALFMAIL",.F.,"") )
		
	EndIF

EndIF

cHtml := '<HTML>'
cHtml += '<HEAD>'
cHtml += '<TITLE>ALFA Sistemas de Gestão</TITLE>'
cHtml += '<STYLE>'
cHtml += 'BODY	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
cHtml += 'DIV 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
cHtml += 'TABLE	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
cHtml += 'TD 	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
cHtml += '.Mini	{FONT-FAMILY:Arial, Helvetica, sans-serif; FONT-SIZE: 08pt}'
cHtml += 'FORM	{MARGIN: 0pt}'
cHtml += '.S_A 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #FFFFFF; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #0000FF; TEXT-ALIGN: left}  '
cHtml += '.S_A2	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #FFFFFF; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFA500; TEXT-ALIGN: left}  '
cHtml += '.S_B 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFFFF; TEXT-ALIGN: left}  '
cHtml += '.S_C 	{FONT-SIZE: 08pt; VERTICAL-ALIGN: top; WIDTH: 100% ; COLOR: #000000; FONT-FAMILY: Arial, Helvetica, sans-serif; BACKGROUND-COLOR: #FFFFFF; TEXT-ALIGN: Right} '
cHtml += '</STYLE>'
cHtml += '</HEAD>'
cHtml += '<BODY>'

cHtml += '<P><B>PROPOSTA (CONTRATO):</B></P>'

cHtml += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

cHtml += '<TR>'
cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">Cliente</TD> '
cHtml += '	<TD Class=S_B	Style="WIDTH: 85%">' + Alltrim(Z02->Z02_RAZAO) +  '</TD> '
cHtml += '</TR>'

cHtml += '<TR>'
cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">Indice</TD>'
cHtml += '	<TD Class=S_B	Style="WIDTH: 85%">' + Z02->Z02_INDICE+  '</TD>'
cHtml += '</TR>'

cHtml += '<TR>'
cHtml += '	<TD Class=S_A	Style="WIDTH: 15%">Data Reajuste</TD>'
cHtml += '	<TD Class=S_B	Style="WIDTH: 85%">' + Dtoc(Z02->Z02_VIGENC) +  '</TD>'
cHtml += '</TR>'

cHtml += '<TR>'
cHtml += '	<TD Class=S_A2	Style="WIDTH: 15%">EAR</TD>'
cHtml += '	<TD Class=S_B 	Style="WIDTH: 85%">' + Alltrim(Posicione('SA3',1,xFilial('SA3')+Z02->Z02_VEND2,'A3_NREDUZ')) +  '</TD>'
cHtml += '</TR>'

cHtml += '<TR>'  					
cHtml += '	<TD Class=S_B 	Style="WIDTH: 15%">Aprovador</TD>'
cHtml += '	<TD Class=S_B 	Style="WIDTH: 85%">'+Alltrim(SubStr(cUsuario,7,15))+ '</TD>'
cHtml += '</TR>'

cHtml += '<TR>'
cHtml += '	<TD Class=S_B 	Style="WIDTH: 15%">Proposta</TD>'
cHtml += '	<TD Class=S_B 	Style="WIDTH: 85%">' + Z02->Z02_PROPOS + '/' + Z02->Z02_ADITIV +' - '+  Alltrim(Z02->Z02_DESCRI) +  '</TD>'
cHtml += '</TR>'

cHtml += '</TABLE>'

cHtmlPMO := cHtml

DbSelectArea("Z05")
DbOrderNickName("Z05SEQ")
DbSeek(xFilial("Z05")+cProposta+cAditivo)
While !Eof() .And. ( xFilial("Z05")+cProposta+cAditivo == Z05->Z05_FILIAL+Z05->Z05_PROPOS + Z05->Z05_ADITIV )

	IF Z05_PRCVEN > 0 
		Aadd( aProdutos , { Z05_DESCRI, Z05_QUANT	, Z05_PRCTAB , Z05_PERDES , Z05_PRCVEN	, Round(Z05_QUANT * Z05_PRCVEN,2)	, Z05_CUSTO , Z05_MARGEM } )
	Else 
		Aadd( aProdutos , { Z05_DESCRI, Z05_HORASA	, Z05_PRCTAB , Z05_PERDES ,	Z05_VLHRDE	, Round(Z05_HORASA * Z05_VLHRDE,2)	, Z05_CUSTO , Z05_MARGEM } )
	EndIF	
	
	DbSelectArea("Z05")
	DbSkip()

EndDo

IF Len(aProdutos) > 0

	IF Len(aParaPMO) > 0

		cHtmlPMO += '<P><B>PRODUTOS E SERVIÇOS:</B></P>'

		cHtmlPMO += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

		cHtmlPMO += '<TR>'
		cHtmlPMO += '	<TD Class=S_A Style="WIDTH: 80%">Descrição</TD>'
		cHtmlPMO += '	<TD Class=S_A Style="WIDTH: 20%">Quantidade</TD>'
		cHtmlPMO += '</TR>'
	
	EndIF

	cHtmlProdutos := '<P><B>PRODUTOS E SERVIÇOS:</B></P>'

	cHtmlProdutos += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtmlProdutos += '<TR>' 					
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 58%">Descrição</TD>'
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 06%">Qtd</TD>'
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 06%">Tabela</TD>'
	cHtmlProdutos += '	<TD Class=S_A2 Style="WIDTH: 06%">%Desconto</TD>'
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 06%">Preço</TD>'
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 06%">Total</TD>'
	cHtmlProdutos += '	<TD Class=S_A  Style="WIDTH: 06%">Custo</TD>'
	cHtmlProdutos += '	<TD Class=S_A2 Style="WIDTH: 06%">%Margem</TD>'

	cHtmlProdutos += '</TR>'

	For nX := 1 To Len(aProdutos)

		IF Len(aParaPMO) > 0
			cHtmlPMO += '<TR>'
			cHtmlPMO += '	<TD Class=S_B Style="WIDTH: 80%">' + Alltrim(aProdutos[nX,1]) + '</TD>'
			cHtmlPMO += '	<TD Class=S_C Style="WIDTH: 20%">' + Alltrim(Transform(aProdutos[nX,2],'@E 999,999')) + '</TD>'
			cHtmlPMO += '</TR>'
		EndIF

		cHtmlProdutos += '<TR>'
		cHtmlProdutos += '	<TD Class=S_B Style="WIDTH: 65%">' + Alltrim(aProdutos[nX,1]) 								+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,2],'@E 999,999')) 		+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,3],'@E 99,999,999')) 	+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,4],'@E 99,999.99')) 	+ '%</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,5],'@E 99,999,999')) 	+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,6],'@E 99,999,999')) 	+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,7],'@E 99,999,999')) 	+ '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(aProdutos[nX,8],'@E 99,999.99')) 	+ '%</TD>'
		cHtmlProdutos += '</TR>'
			
		nTotal 		+= aProdutos[nX,6]
		nCusTotal	+= Round(aProdutos[nX,2] * aProdutos[nX,7],2)

	Next

	IF Len(aParaPMO) > 0

		cHtmlPMO += '</TABLE>'

	EndIF
	
	IF nTotal > 0
		cHtmlProdutos += '<TR>'
		cHtmlProdutos += '	<TD Class=S_B Style="WIDTH: 65%"></TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%"></TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%"></TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">TOTAL</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(nTotal,'@E 99,999,999')) + '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">CUSTO</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%">' + Alltrim(Transform(nCusTotal,'@E 99,999,999')) + '</TD>'
		cHtmlProdutos += '	<TD Class=S_C Style="WIDTH: 05%"></TD>'
		cHtmlProdutos += '</TR>'
	EndIF

	cHtmlProdutos += '</TABLE>'

EndIF

DbSelectArea("Z04")
DbOrderNickName("Z04PARCEL")
DbSeek(xFilial("Z04")+cProposta+cAditivo)
While !Eof() .And. (xFilial("Z04")+cProposta+cAditivo == Z04->Z04_FILIAL + Z04->Z04_PROPOS + Z04->Z04_ADITIV )
	
	IF Z04_VALOR > 0 
		Aadd( aParcelas , { Z04->Z04_HIST, Z04->Z04_QTDPAR, Z04->Z04_VALOR, Z04->Z04_TOTAL, Z04->Z04_DATA } )
	EndIF
	
	DbSelectArea("Z04")
	DbSkip()

EndDo

IF Len(aParcelas) > 0
	
	cHtmlParcelas := '<P><B>CONDIÇÕES DE PAGAMENTO:<B></P>'

	cHtmlParcelas += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtmlParcelas += '<TR>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 60%">Descrição</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Parcelas</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Valor</TD>'
	cHtmlParcelas += '	<TD Class=S_A  Style="WIDTH: 10%">Total</TD>'
	cHtmlParcelas += '	<TD Class=S_A2 Style="WIDTH: 10%">1º Vencimento</TD>'
	cHtmlParcelas += '</TR>'

	For nX := 1 To Len(aParcelas)
	
		cHtmlParcelas += '<TR>'  					
		cHtmlParcelas += '	<TD Class=S_B Style="WIDTH: 60%">' + Alltrim(aParcelas[nX,1]) + '</TD>'  					
		cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aParcelas[nX,2],'@E 9,999')) 		+ '</TD>'
		cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aParcelas[nX,3],'@E 99,999,999')) 	+ '</TD>'
		cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aParcelas[nX,4],'@E 99,999,999')) 	+ '</TD>'
		cHtmlParcelas += '	<TD Class=S_C Style="WIDTH: 10%">' + Dtoc(aParcelas[nX,5])									+ '</TD>'
		cHtmlParcelas += '</TR>'
	
	Next
	
	cHtmlParcelas += '</TABLE>'

EndIF

DbSelectArea("Z08")
DBSetOrder(1)
DbSeek(xFilial("Z08")+cProposta+cAditivo)
While !Eof() .And. (xFilial("Z08")+cProposta+cAditivo == Z08->Z08_FILIAL + Z08->Z08_PROPOS + Z08->Z08_ADITIV)

	Aadd( aComissao , { Posicione("SA2",1,xFilial("SA2")+Z08->Z08_FORNEC,"A2_NOME") , Z08->Z08_BASE , Z08->Z08_PERC , Z08->Z08_VALOR , Z08->Z08_PARC , Z08->Z08_VLRPAR } )

	DbSelectArea("Z08")
	DbSkip()

EndDo

IF Len(aComissao) > 0
	
	cHtmlComissao := '<P><B>COMISSÕES:</B></P>'

	cHtmlComissao += '<TABLE style="WIDTH: 100%; HEIGHT: 100pt" cellSpacing=0 border=1>'

	cHtmlComissao += '<TR>'
	cHtmlComissao += '	<TD Class=S_A  Style="WIDTH: 50%">Fornecedor</TD>'
	cHtmlComissao += '	<TD Class=S_A  Style="WIDTH: 10%">Valor Base</TD>'
	cHtmlComissao += '	<TD Class=S_A2 Style="WIDTH: 10%">%</TD>'
	cHtmlComissao += '	<TD Class=S_A2 Style="WIDTH: 10%">Comissão</TD>'
	cHtmlComissao += '	<TD Class=S_A  Style="WIDTH: 10%">Parcelas</TD>'
	cHtmlComissao += '	<TD Class=S_A  Style="WIDTH: 10%">Valor Parcela</TD>'
	cHtmlComissao += '</TR>'

	For nX := 1 To Len(aComissao)
	
		cHtmlComissao += '<TR>'  					
		cHtmlComissao += '	<TD Class=S_B Style="WIDTH: 50%">' + Alltrim(aComissao[nX,1]) + '</TD>'  					
		cHtmlComissao += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aComissao[nX,2],'@E 99,999,999'))	+ '</TD>'
		cHtmlComissao += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aComissao[nX,3],'@E 99,999.99')) 	+ '</TD>'
		cHtmlComissao += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aComissao[nX,4],'@E 99,999,999')) 	+ '</TD>'
		cHtmlComissao += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aComissao[nX,5],'@E 99,999,999')) 	+ '</TD>'
		cHtmlComissao += '	<TD Class=S_C Style="WIDTH: 10%">' + Alltrim(Transform(aComissao[nX,6],'@E 99,999,999')) 	+ '</TD>'
		cHtmlComissao += '</TR>'
	
	Next
	
	cHtmlComissao += '</TABLE>'

EndIF

IF Len(aParaPMO) > 0
	cHtmlPMO += '</BODY>'
	cHtmlPMO += '</HTML>'
EndIF

cHtml += cHtmlProdutos + cHtmlParcelas + cHtmlComissao
cHtml += '</BODY>'
cHtml += '</HTML>'

MemoWrite('C:\Propostas\Exemplo-Pro.html',cHtml)

LjMsgRun("Aguarde, enviando informações para Diretoria...",,{|| lOk := U_SyCRMMail(aPara,cAssunto,cHtml,.F.,'') } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enviar e-mail para PMO informando aprovacao da proposta, sem valores e somente quando for proposta de SERVICOS.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
IF ( Z02->Z02_STATUS $ '59' ) .And. (Len(aParaPMO) > 0)
	LjMsgRun("Aguarde, enviando informações para Gestão de Projetos...",,{|| lOk := U_SyCRMMail(aParaPMO,cAssunto,cHtmlPMO,.F.,'') } )
EndIF

Return(.T.)
