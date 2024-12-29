#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFPMS99
Envio de Lembre de Vencimento aos Clientes.

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALFPMS07()

Local aArea := GetArea()

If _Opc == 3 .Or. _Opc == 4
    FWExecView('Inclusão',"ALFPMS07", 4,, { || .T. } )

    If __oRatAPag <> Nil
        M->E2_VALOR  := __oRatAPag['totalAPagar']
        M->E2_VLCRUZ := __oRatAPag['totalAPagar']
    EndIf
Else
    FWExecView('Visualização',"ALFPMS07", 1,, { || .T. } )
EndIf

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
Static Function ModelDef()

Local oStrField := FWFormModelStruct():New()
Local oStrGrid  := FWFormStruct( 1, 'ZZD' , )
Local oModel

oStrField:addTable("", {"C_STRING1"}, "Rateio Por empresa", {|| ""})
oStrField:addField("String 01", "Campo de texto", "C_STRING1", "C", 15)

// oStruZZD:SetProperty ( 'ZZD_MUSICA', MODEL_FIELD_VALID, FWBuildFeature( 1, '.T.' ) )
// oStruZZD:SetProperty ( 'ZZD_MUSICA', MODEL_FIELD_INIT , NIL )

oModel := MPFormModel():New("RATEMPPG", /*bPreVld*/, /*bPosVld*/, {|oModel| fCommit(oModel)}, /*bCancel*/)

oModel:AddFields( 'CABID', /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| loadHidFld()})

oModel:AddGrid( 'ZZDDETAIL', 'CABID', oStrGrid, /*bLinePre*/, {|oGrdZZD, nLinAtu| fLinePos(oGrdZZD, nLinAtu) }, /*bPre*/, , {|oSubMod| fLoadZZD(oSubMod)})

oModel:AddCalc( 'CALCULOS', 'CABID', 'ZZDDETAIL', 'ZZD_VALOR', 'VLRTOT', 'SUM', { | oFW | .T. }, , "Valor Título" )

oModel:SetDescription( 'Rateio Por Empresa' )
// oModel:GetModel( 'CABID' ):SetDescription( 'PARAMETROS' )
// oModel:GetModel( 'ZZDDETAIL' ):SetDescription( 'Rateio' )
// oModel:GetModel( 'ZA2DETAIL' ):SetDescription( 'Dados do Autor'  )

oModel:SetPrimaryKey( {} )

// É necessário que haja alguma alteração na estrutura Field
oModel:setActivate({ |oModel| onActivate(oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} onActivate
Função estática para o activate do model

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function onActivate(oModel)
 
//Só efetua a alteração do campo para inserção
If oModel:GetOperation() == MODEL_OPERATION_INSERT
    FwFldPut("C_STRING1", "FAKE" , /*nLinha*/, oModel)
EndIf
 
Return

//-------------------------------------------------------------------
Static Function ViewDef()

Local oView     as object
Local oModel    as object
Local oStrCab   as object
Local oStrGrid  as object
Local oCalc1    as object

// Estrutura Fake de Field
oStrCab := FWFormViewStruct():New()
oStrCab:addField("C_STRING1", "01" , "String 01", "Campo de texto", , "C" )

oStrGrid := FWFormStruct( 2, 'ZZD' , )
oModel   := FWLoadModel( 'ALFPMS07' )

oView := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAB'  , oStrCab , 'CABID'     )
oView:AddGrid(  'VIEW_GRID' , oStrGrid, 'ZZDDETAIL' )

oCalc1 := FWCalcStruct( oModel:GetModel( 'CALCULOS') )
oView:AddField( 'VIEW_CALC', oCalc1, 'CALCULOS' )

oView:CreateHorizontalBox( "BOX1",  00 )
oView:CreateHorizontalBox( "BOX2",  88 )
oView:CreateHorizontalBox( "BOX3",  12 )

oView:CreateVerticalBox( 'BOX3_LEFT' , 60, 'BOX3' )
oView:CreateVerticalBox( 'BOX3_RIGHT' , 40, 'BOX3' )

oView:SetOwnerView( 'VIEW_CAB'  , "BOX1" )
oView:SetOwnerView( 'VIEW_GRID' , "BOX2" )
oView:SetOwnerView( 'VIEW_CALC' , "BOX3_RIGHT" )

// oView:EnableTitleView('VIEW_CALC','TOTAIS')

oView:setDescription( 'Rateio Por Empresa' )

Return oView

Static Function loadHidFld()

Return {""}

//-------------------------------------------------------------------
/*/{Protheus.doc} fCommit
Gravacao dos Dados do Model

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fLoadZZD(oSubMod)

Local aFields   := oSubMod:GetStruct():GetFields()
Local aRetorno  := {}
Local aItens    := {}
Local nField    := 0
Local nX

If ValType(__oRatAPag) == "J" .And. ValType(__oRatAPag['itens']) == "A"
    aItens := __oRatAPag['itens']
EndIf

If Len(aItens) == 0
    //Se não houver dados retorna um Array vazio
    aAux := Array(Len(aFields))

    For nField := 1 to Len(aFields)
        DO CASE
            CASE aFields[nField][04] == "C"
                aAux[nField] := Space(aFields[nField][05])
            CASE aFields[nField][04] == "N"
                aAux[nField] := 0
            CASE aFields[nField][04] == "L"
                aAux[nField] := .F.
            CASE aFields[nField][04] == "D"
                aAux[nField] := CtoD("")
        ENDCASE
    Next nField

    Aadd(aRetorno, {0 , aAux})
    aAux := {}
Else
    For nX := 1 To Len(aItens)
        aAux := Array(Len(aFields))

        For nField := 1 to Len(aFields)

            cCampo := AllTrim(aFields[nField][3])

            DO CASE
                CASE cCampo == "ZZD_DESCC"
                    aAux[nField] := POSICIONE("CTT",1,xFilial("CTT")+aItens[nX]['ZZD_CCUSTO'],"CTT_DESC01")
                CASE cCampo == "ZZD_DESNAT"
                    aAux[nField] := POSICIONE("SED",1,xFilial("SED")+aItens[nX]['ZZD_NATURE'],"ED_DESCRIC")
                OTHERWISE
                    aAux[nField] := aItens[nX][cCampo]
            ENDCASE

        Next nField

        Aadd(aRetorno, {aItens[nX]['RECNO'], aAux})
        aAux := {}
    Next nX
EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadZZD
Gravacao dos Dados do Model

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fLinePos(oGrdZZD, nLinAtu)

Local cEmpFat  := oGrdZZD:GetValue("ZZD_EMPFAT")
Local cCCusto  := oGrdZZD:GetValue("ZZD_CCUSTO")
Local cCodNat  := oGrdZZD:GetValue("ZZD_NATURE")
Local lRetorno := .T.
Local nX

For nX := 1 to oGrdZZD:Length()

    oGrdZZD:GoLine(nX)

    If nX != nLinAtu .AND. !oGrdZZD:IsDeleted()
        If oGrdZZD:GetValue("ZZD_EMPFAT") == cEmpFat;
            .AND. oGrdZZD:GetValue("ZZD_CCUSTO") == cCCusto;
            .AND. oGrdZZD:GetValue("ZZD_NATURE") == cCodNat

            lRetorno := .F.
            Help( ,, 'HELP',, 'Rateio já informado na linha: ' + cValToChar(nX), 1, 0)
            EXIT
        EndIf
    EndIf

Next nX

oGrdZZD:GoLine(nLinAtu)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fCommit
Gravacao dos Dados do Model

@author  Wilson A. Silva Jr
@since   18/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fCommit(oModel)

Local aArea		:= GetArea()
Local oGrdZZD	:= oModel:GetModel("ZZDDETAIL")
Local oCalcTot  := oModel:GetModel("CALCULOS")
Local nBkpZZD	:= oGrdZZD:GetLine()
Local lRetorno 	:= .T.
Local cMsgErro	:= ""
Local aItens    := {}
Local nX as numeric

If ValType(__oRatAPag) != "J"
    __oRatAPag := JsonObject():New()
EndIf

__oRatAPag['totalAPagar'] := oCalcTot:GetValue("VLRTOT")

For nX := 1 to oGrdZZD:Length()

    oGrdZZD:GoLine(nX)

    oItem := JsonObject():New()

    oItem['ZZD_EMPFAT'] := oGrdZZD:GetValue("ZZD_EMPFAT")
    oItem['ZZD_CCUSTO'] := oGrdZZD:GetValue("ZZD_CCUSTO")
    oItem['ZZD_NATURE'] := oGrdZZD:GetValue("ZZD_NATURE")
    oItem['ZZD_VALOR']  := oGrdZZD:GetValue("ZZD_VALOR")
    oItem['ZZD_PERC']   := (oGrdZZD:GetValue("ZZD_VALOR") / oCalcTot:GetValue("VLRTOT")) * 100
    oItem['ZZD_HIST']   := oGrdZZD:GetValue("ZZD_HIST")
    oItem['IsInserted'] := oGrdZZD:IsInserted()
    oItem['IsUpdated']  := oGrdZZD:IsUpdated()
    oItem['IsDeleted']  := oGrdZZD:IsDeleted()
    
    // __oRatAPag['totalAPagar'] += oItem['ZZD_VALOR']

    AADD( aItens, oItem )

Next nX

__oRatAPag['itens'] := aItens

oGrdZZD:GoLine(nBkpZZD)

If lRetorno .AND. Len(__oRatAPag['itens']) == 0
    lRetorno := .F.
    cMsgErro := "Rateio não preenchido."
EndIf

If !lRetorno
    Aviso("fCommit", cMsgErro, {"Fechar"})
EndIf

RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadZZD
Rotina para carregar rateios do título.

@author  Wilson A. Silva Jr
@since   27/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function LoadZZD(cPrefixo, cNumTit, cParcela, cTipo, cCliFor, cLoja, cRecPag)

Local aArea   := GetArea()
Local cTMP1   := ""
Local cQuery  := ""
Local aItens  := {}
Local oRateio := Nil

cQuery := " SELECT "+ CRLF
cQuery += "     ZZD.R_E_C_N_O_ AS RECZZD "+ CRLF
cQuery += " FROM "+RetSqlName("ZZD")+" ZZD (NOLOCK) "+ CRLF
cQuery += " WHERE "+ CRLF
cQuery += "     ZZD.ZZD_FILIAL = '"+xFilial("ZZD")+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_PREFIX = '"+cPrefixo+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_NUM = '"+cNumTit+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_PARCEL = '"+cParcela+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_TIPO = '"+cTipo+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_CLIFOR = '"+cCliFor+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_LOJA = '"+cLoja+"' "+ CRLF
cQuery += "     AND ZZD.ZZD_RECPAG = '"+cRecPag+"' "+ CRLF
cQuery += "     AND ZZD.D_E_L_E_T_ = ' ' "+ CRLF

cTMP1 := MPSysOpenQuery(cQuery)

If (cTMP1)->(!EOF())

    oRateio := JsonObject():New()
    oRateio['ZZD_PREFIX'] := cPrefixo
    oRateio['ZZD_NUM']    := cNumTit
    oRateio['ZZD_PARCEL'] := cParcela
    oRateio['ZZD_TIPO']   := cTipo
    oRateio['ZZD_CLIFOR'] := cCliFor
    oRateio['ZZD_LOJA']   := cLoja
    oRateio['ZZD_RECPAG'] := cRecPag

    While (cTMP1)->(!EOF())

        DbSelectArea("ZZD")
        DbSetOrder(1)
        DbGoTo((cTMP1)->RECZZD)

        oItem := JsonObject():New()

        oItem['ZZD_EMPFAT'] := ZZD->ZZD_EMPFAT
        oItem['ZZD_CCUSTO'] := ZZD->ZZD_CCUSTO
        oItem['ZZD_NATURE'] := ZZD->ZZD_NATURE
        oItem['ZZD_VALOR']  := ZZD->ZZD_VALOR
        oItem['ZZD_PERC']   := ZZD->ZZD_PERC
        oItem['ZZD_HIST']   := ZZD->ZZD_HIST
        oItem['RECNO']      := (cTMP1)->RECZZD

        AADD( aItens, oItem )

        (cTMP1)->(DbSkip())
    EndDo

    oRateio['itens'] := aItens
EndIf

(cTMP1)->(DbCloseArea())

RestArea(aArea)

Return oRateio

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaZZD
Grava rateio de títulos.

@author  Wilson A. Silva Jr
@since   27/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GravaZZD(oRateio)

Local aArea := GetArea()

Local cPrefix
Local cNumTit
Local cParcel
Local cTipo 
Local cCodFor
Local cLojFor
Local cRecPag
Local cChvSE2
Local aItens
Local lAchou
Local oItem
Local lIncluir
Local nX

If ValType(oRateio) == "J" .And. ValType(oRateio['itens']) == "A"

    cPrefix := oRateio['ZZD_PREFIX']
    cNumTit := oRateio['ZZD_NUM']
    cParcel := oRateio['ZZD_PARCEL']
    cTipo   := oRateio['ZZD_TIPO']
    cCodFor := oRateio['ZZD_CLIFOR']
    cLojFor := oRateio['ZZD_LOJA']
    cRecPag := oRateio['ZZD_RECPAG']

    cChvSE2 := cPrefix+cNumTit+cParcel+cTipo+cCodFor+cLojFor

    aItens := oRateio['itens']

    For nX := 1 To Len(aItens)

        oItem := aItens[nX]

        cEmpFat := oItem['ZZD_EMPFAT']
        cCCusto := oItem['ZZD_CCUSTO']
        cCodNat := oItem['ZZD_NATURE']

        DbSelectArea("ZZD")
        DbSetOrder(1) // ZZD_FILIAL+ZZD_PREFIX+ZZD_NUM+ZZD_PARCEL+ZZD_TIPO+ZZD_CLIFOR+ZZD_LOJA+ZZD_EMPFAT+ZZD_CCUSTO+ZZD_NATURE
        lAchou := DbSeek(xFilial("ZZD")+cChvSE2+cEmpFat+cCCusto+cCodNat)

        If oItem['IsDeleted']
            If lAchou
                RecLock("ZZD", .F.)
                    DbDelete()
                MsUnlock()
            EndIf
        Else
            lIncluir := !lAchou
            RecLock("ZZD", lIncluir)
                REPLACE ZZD_FILIAL  WITH xFilial("ZZD")
                REPLACE ZZD_PREFIX  WITH cPrefix
                REPLACE ZZD_NUM     WITH cNumTit
                REPLACE ZZD_PARCEL  WITH cParcel
                REPLACE ZZD_TIPO    WITH cTipo
                REPLACE ZZD_CLIFOR  WITH cCodFor
                REPLACE ZZD_LOJA    WITH cLojFor
                REPLACE ZZD_EMPFAT  WITH oItem['ZZD_EMPFAT']
                REPLACE ZZD_CCUSTO  WITH oItem['ZZD_CCUSTO']
                REPLACE ZZD_NATURE  WITH oItem['ZZD_NATURE']
                REPLACE ZZD_VALOR   WITH oItem['ZZD_VALOR']
                REPLACE ZZD_PERC    WITH oItem['ZZD_PERC']
                REPLACE ZZD_HIST    WITH oItem['ZZD_HIST']
                REPLACE ZZD_RECPAG  WITH cRecPag
            MsUnlock()
        EndIf

    Next nX
EndIf

RestArea(aArea)

Return .T.
