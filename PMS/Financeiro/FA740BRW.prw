//-------------------------------------------------------------------
/*/{Protheus.doc} FA740BRW
Adiciona novas opções no "Outras Ações" do Contas à Receber
@author  Victor Andrade
@since   02/01/2018
@version 1
/*/
//-------------------------------------------------------------------
User Function FA740BRW()

Local aNewRot := {}

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

Aadd( aNewRot, { "Rel. Baixas"             , "U_ALFREL08"	        , 0 , 6} )


Aadd( aNewRot, { "Renovar Contrato"     , "U_ALFFIN01"	        , 0 , 6} )
Aadd( aNewRot, { "Alt./Exc. Titulos"    , "U_SYALTFIN(1)"	        , 0 , 6} )


Aadd( aNewRot, { "Alt.Valores Titulos"    , "U_SYALTFIN(3)"	        , 0 , 6} )

Aadd( aNewRot, { "Alt.Natureza Titulos"   , "U_SYALTFIN(4)"	        , 0 , 6} )


Aadd( aNewRot, { "Bx.Lote Custon"   , "u_ALFPMS61()"	        , 0 , 6} )

Return(aNewRot)
