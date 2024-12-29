#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ASOpenEnv
Efetua a abertura do Ambiente
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
User Function ASOpenEnv(cCodEmp, cCodFil)

Default cCodEmp := "01"
Default cCodFil := "01"

ConOut(Replicate("-", 80))
ConOut("ABRINDO AMBIENTE")
ConOut(Replicate("-", 80))

RPCClearEnv()
RpcSetType( 3 )
RpcSetEnv( cCodEmp, cCodFil )

Return

/*/{Protheus.doc} ASCloseEnv
Efetua o Encerramento do Ambiente
@author Victor A. Barbosa
@since 14/10/2022
@version 1
/*/
User Function ASCloseEnv()

RPCClearEnv()

Return

/*/{Protheus.doc} VerErro
Pega a linha do MostraErro que possui a palavra "INVALIDO"
@author Victor Andrade
@since 14/10/2022
@version 1
@type function
/*/
User Function VerErro(cErroAuto)

Local nLines  := MLCount(cErroAuto)
Local nErr	  := 0
Local cErrRet := ""

For nErr := 1 To nLines
	cErrRet += AllTrim(MemoLine( cErroAuto, , nErr ))
Next nErr

Return( AllTrim(cErrRet) )
