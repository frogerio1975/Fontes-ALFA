#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F580MNBR
O ponto de entrada F580MNBR tem como finalidade habilitar os campos 
apresentados no browse de marcacao.
@author  Pedro Oliveira
@since   22/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F580MNBR()
Local aCampos := aClone(ParamIxb)
Local nCampo := 0
Local aRetCpo := {}
Local cCpo := 'E2_OK/E2_EMPFAT/E2_PREFIXO/E2_NUM/E2_PARCELA/E2_TIPO/E2_NUMNOTA/E2_FORNECE/E2_LOJA/E2_NOMFOR/E2_HIST/E2_VALOR/E2_EMISSAO/E2_VENCTO'
    For nCampo := 1 To Len(aCampos)
        IF ALLTRIM(aCampos[nCampo][1] ) $ cCpo
            AADD( aRetCpo,aCampos[nCampo] )
        END
       //aCampos[nCampo][3] := GetSx3Cache(aCampos[nCampo][1],"X3_TITSPA")
    Next nCampo
//aClone(aCampos)
Return aClone(aRetCpo) 
