#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINM05
Inclui ações na fila de integração com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFINM05(cMsgErro)

Local _aArea     := GetArea()
Local lRetorno   := .T.

Default cMsgErro := ""

_cFilial    := XTM->XTM_FILIAL
_cTitulo    := XTM->XTM_NUMTIT
_cPrefixo   := XTM->XTM_PREFIX
_cParcela   := XTM->XTM_PARCEL
_cTipo      := XTM->XTM_TIPO

lRetorno := GeraPDF(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, @cMsgErro)

If lRetorno
    lRetorno := EnviaEmail(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, @cMsgErro)
EndIf

cStatus := IIF(lRetorno,"2","3") // 1=Pendente, 2=Processado, 3=Erro

BEGIN TRANSACTION

    // Registra Retorno do Processamento 
    RecLock("XTM",.F.)
        REPLACE XTM_STATUS  WITH cStatus
        REPLACE XTM_DTPROC  WITH DATE()
        REPLACE XTM_HRPROC  WITH TIME()
        REPLACE XTM_REQUES  WITH ""
        REPLACE XTM_RESPON  WITH ""
        REPLACE XTM_MSGERR  WITH cMsgErro
    MsUnlock()

    // Caso erro, Inclui nova tentativa de envio de boleto por e-mail ao cliente
    If !lRetorno
        DbSelectArea("SE1")
        DbSetOrder(1)
        If DbSeek(_cFilial + _cPrefixo + _cTitulo + _cParcela + _cTipo)
            lRetorno := U_ALFINM01("4")
        EndIf
    EndIf
    
END TRANSACTION

RestArea(_aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraPDF
Inclui ações na fila de integração com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraPDF(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, cMsgErro)

Local aAreaAtu   := GetArea()
Local lRetorno   := .T.
Local _cDirPDF   := "\boletos\"
Local _cFilePrt  := ""
Local cFilePrint := ""

FWMakeDir(_cDirPDF)

DbSelectArea("SE1")
DbSetOrder(1)
If !DbSeek(_cFilial + _cPrefixo + _cTitulo + _cParcela + _cTipo)
    cMsgErro := "Título não localizado."
    lRetorno := .F.
EndIf

If lRetorno
    // Nome do arquivo
    _cFilePrt  := SE1->E1_CLIENTE +'-'+ Alltrim(SE1->E1_XNUMNFS) + '-' + StrZero(Day(dDataBase),2) + StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4)
    cFilePrint := _cDirPDF + _cFilePrt +".pdf"

    If FILE(cFilePrint)
        If FERASE(cFilePrint) < 0
            cMsgErro := "Arquivo já existente, não foi possível apagar."
            lRetorno := .F.
        EndIf
    EndIf
EndIf

If lRetorno
    _lAdjust := .F.
    _lServer := .T.
    _ViewPDF := .F.
    _lDisabeSetup := .T.
    _oPrint := FwMSPrinter():New(_cFilePrt,6,_lAdjust,_cDirPDF,_lDisabeSetup,,,,_lServer,,,_ViewPDF)
    _oPrint:SetPortrait()
    _oPrint:SetResolution(78)
    _oPrint:cPathPDF := _cDirPDF

    lRetorno := U_ALFINR01(_oPrint, @cMsgErro)

    If lRetorno
        cFilePrint := _cDirPDF + _cFilePrt +".pdf"
        File2Printer( cFilePrint, "PDF" )      
        _oPrint:Preview()

        If !FILE(cFilePrint)
            cMsgErro := "Erro na geração do boleto em PDF."
            lRetorno := .F.
        EndIf
    EndIf
EndIf

RestArea(aAreaAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaEmail
Inclui ações na fila de integração com o banco Itau.

@author  Wilson A. Silva Jr
@since   15/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EnviaEmail(_cFilial, _cTitulo, _cPrefixo, _cParcela, _cTipo, cMsgErro)

Local aAreaAtu   := GetArea()
Local lRetorno   := .T.

DbSelectArea("SE1")
DbSetOrder(1)
If !DbSeek(_cFilial + _cPrefixo + _cTitulo + _cParcela + _cTipo)
    cMsgErro := "Título não localizado."
    lRetorno := .F.
EndIf

lRetorno := U_ALEnvNFBol(.T., @cMsgErro)

RestArea(aAreaAtu)

Return lRetorno
