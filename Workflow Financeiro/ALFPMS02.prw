#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS02
Tela de parametros

@author  Felipe Canaveze Soares
@since   26/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS02()

Local aAreaAtu  := GetArea()
Local aBoxParam := {}
Local aRetParam := {}
Local cBanco    := GetMV("MV_XBANCO",.F.,"")
Local cAgencia  := GetMV("MV_XAGENCI",.F.,"")
Local cConta    := GetMV("MV_XCONTA",.F.,"")
Local cFavorec  := GetMV("MV_XFAVORE",.F.,"")
Local cCNPJ     := GetMV("MV_XCNPJFA",.F.,"")
Local cOpcao    := GetMV("MV_XOPWFFI",.F.,"")
Local cEmailTST := GetMV("MV_XEMATST",.F.,"")
Local cTitulo   := GetMV("MV_XTITEMA",.F.,"")
Local nQtdPos   := GetMV("MV_XDAPOS",.F.,0)
Local nQtdAntes := GetMV("MV_XDANTES",.F.,0)
Local cServer   := GetMV("AL_MAILSRV",.F.,"email-ssl.com.br")
Local cUser     := GetMV("AL_MAILUSR",.F.,"adm@alfaerp.com.br")
Local cPass     := GetMV("AL_MAILPSW",.F.,"240820@Alfa")
Local cMailFrom := GetMV("AL_MAILFRO",.F.,"adm@alfaerp.com.br")
Local nPorta    := GetMV("AL_MAILPOR",.F.,587)
Local lUseAuth 	:= GetMV("AL_MAILAUT",.F.,.T.) 
Local lTLS	    := GetMV("AL_MAILTLS",.F.,.F.)
Local lSSL   	:= GetMV("AL_MAILSSL",.F.,.F.) 
Local nTimeOut 	:= GetMV("AL_MAILTIM",.F.,30)
Local cCopia    := GetMV("AL_XCOPFAT",.F.,"")
Local cMsgLog   := ""

AADD( aBoxParam, {1,"Banco"                         ,PadR(cBanco,50)    ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Agencia"                       ,PadR(cAgencia,50)  ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Conta"                         ,PadR(cConta,50)    ,"","","","",50,.F.} )
AADD( aBoxParam, {1,"Favorecido"                    ,PadR(cFavorec,70)  ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"CNPJ"                          ,PadR(cCNPJ,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {2,"Opcao"                         ,cOpcao             ,{"1=Ativo","2=Homologacao","3=Inativo"},60,,.F.} )
AADD( aBoxParam, {1,"E-mail"                        ,PadR(cEmailTST,50) ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Título e-mail"                 ,PadR(cTitulo,50)   ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Qtd. dias após vencimento"     ,nQtdPos            ,"@R 999","","","",100,.F.} )
AADD( aBoxParam, {1,"Qtd. dias antes vencimento"    ,nQtdAntes          ,"@R 999","","","",100,.F.} )
AADD( aBoxParam, {1,"Servidor SMTP"                 ,PadR(cServer,50)   ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Usuario E-mail"                ,PadR(cUser,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Senha E-mail"                  ,PadR(cPass,50)     ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"E-mail DE"                     ,PadR(cMailFrom,50) ,"","","","",100,.F.} )
AADD( aBoxParam, {1,"Porta SMTP"                    ,nPorta             ,"@R 999","","","",50,.F.} )
AADD( aBoxParam, {4,"Autentica"                     ,lUseAuth           ,"",50,"",.F.} )
AADD( aBoxParam, {4,"TLS"                           ,lTLS               ,"",50,"",.F.} )
AADD( aBoxParam, {4,"SSL"                           ,lSSL               ,"",50,"",.F.} )
AADD( aBoxParam, {1,"TimeOut"                       ,nTimeOut           ,"@R 999","","","",50,.F.} )
AADD( aBoxParam, {1,"Copia Para"                    ,PadR(cCopia,50)    ,"","","","",100,.F.} )

If ParamBox(aBoxParam,"Parâmetros WorkFlow Financeiro.",@aRetParam,,,,,,,,.F.)

    PutMV("MV_XBANCO"  , aRetParam[01])
    PutMV("MV_XAGENCI" , aRetParam[02])
    PutMV("MV_XCONTA"  , aRetParam[03])
    PutMV("MV_XFAVORE" , aRetParam[04])
    PutMV("MV_XCNPJFA" , aRetParam[05])
    PutMV("MV_XOPWFFI" , aRetParam[06])
    PutMV("MV_XEMATST" , aRetParam[07])
    PutMV("MV_XTITEMA" , aRetParam[08])
    PutMV("MV_XDAPOS"  , aRetParam[09])
    PutMV("MV_XDANTES" , aRetParam[10])
    PutMV("AL_MAILSRV" , aRetParam[11])
    PutMV("AL_MAILUSR" , aRetParam[12])
    PutMV("AL_MAILPSW" , aRetParam[13])
    PutMV("AL_MAILROM" , aRetParam[14])
    PutMV("AL_MAILPOR" , aRetParam[15])
    PutMV("AL_MAILAUT" , aRetParam[16])
    PutMV("AL_MAILTLS" , aRetParam[17])
    PutMV("AL_MAILSSL" , aRetParam[18])
    PutMV("AL_MAILTIM" , aRetParam[19])
    PutMV("AL_XCOPFAT" , aRetParam[20])

    U_FstMail(aRetParam[07], aRetParam[20], "Teste Lembrete Fatura", "Teste Lembrete Fatura", cMsgLog)

    If !Empty(cMsgLog)
        MsgInfo(cMsgLog, "Teste E-mail")
    EndIf
EndIf

RestArea(aAreaAtu)

Return .T.


user function s02tst()

// Comando para nao consumir licencas. 
RpcSetType(3)

// Inicializa ambiente.
PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO "FRT" FUNNAME "SIGAFRT"

U_ALFPMS02()

RESET ENVIRONMENT   

Return .T.
