User Function PMA200DEL()
Local aArea:= GetArea()

DbSelectArea("Z02")
DbSetOrder(1)
If DbSeek(xFilial("Z02")+AF8->AF8_PROPOS) .And. !Empty(AF8->AF8_PROPOS)
    RecLock("Z02", .F.)
    Replace Z02_PROJET With ""
    Replace Z02_STATUS With '5'
    MsUnlock()
EndIf

RestArea(aArea)

Return(.T.)
