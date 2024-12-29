//-------------------------------------------------------------------
/*/{Protheus.doc} FI040ROT
Adiciona novas opções no "Outras Ações" do Contas à Receber
@author  Victor Andrade
@since   02/01/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function FI040ROT()

Local aNewRot := ParamIXB

Aadd( aNewRot, { "Monitor NFS-e"		, "U_ALNFSE03"  		, 0 , 6} )
Aadd( aNewRot, { "Enviar NF e Boleto" 	, "U_ALEnviaBoletos"	, 0 , 6} )
Aadd( aNewRot, { "Cancela Boleto" 	    , "U_ALFINM08"	        , 0 , 6} )
Aadd( aNewRot, { "Enviar Lembretes" 	, "U_ALFPMS06"	        , 0 , 6} )
Aadd( aNewRot, { "Rateio Título"        , "U_PMS20ALT"	        , 0 , 4} )
Aadd( aNewRot, { "Rateio Proposta"      , "U_ALFPMS40"	        , 0 , 6} )
Aadd( aNewRot, { "Rel.Contas Receber"   , "U_ALFREL01"	        , 0 , 6} )
Aadd( aNewRot, { "Rel.Faturamento"      , "U_ALFREL03"	        , 0 , 6} )
Aadd( aNewRot, { "Rel.Fluxo Caixa"      , "U_ALFREL05"	        , 0 , 6} )
Aadd( aNewRot, { "Rel. DRE"             , "U_ALFREL06"	        , 0 , 6} )
Aadd( aNewRot, { "Renovar Contrato"     , "U_ALFFIN01"	        , 0 , 6} )

Return(aNewRot)
