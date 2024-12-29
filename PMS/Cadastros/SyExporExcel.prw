#Include "Protheus.ch"      

User Function SyExporExcel(cStatus,aCabExcel,aItensExcel,lDiretoria)

Local nX
Local nX2

IF Len(aItensExcel) <= 0                        

	MsgAlert('Esta pasta ' +Alltrim(cStatus)+ ' não possui dados.')

Else

	IF Alltrim(Upper(cStatus)) == "PROJETOS" .And. !lDiretoria
		
		For nX := 1 To Len(aCabExcel)
			
			IF aCabExcel[nX,2] == "LUCRO"
			
				For nX2 := 1 To Len(aItensExcel)
					aItensExcel[nX2,nX] := 0 
				Next
						
			ElseIF aCabExcel[nX,2] == "RECEITA"
				
				For nX2 := 1 To Len(aItensExcel)
					aItensExcel[nX2,nX] := 0 
				Next
	
			ElseIF aCabExcel[nX,2] == "CUSTO"
				
				For nX2 := 1 To Len(aItensExcel)
					aItensExcel[nX2,nX] := 0 
				Next
					    	
	    	EndIF
	    	
		Next
	
	EndIF
	/*
	MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
	{||DlgToExcel({{"GETDADOS",;
	cStatus,;
	aCabExcel,aItensExcel}})})
	*/
	MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel",;
	{|| GDToExcel( aCabExcel,aItensExcel,"GETDADOS" ) } ) 

EndIF

Return(.T.)

/*/
    Funcao:     GDToExcel
    Autor:      Marinaldo de Jesus 
    Data:       01/06/2013
    Descricao:  Mostrar os Dados no Excel
    Sintaxe:    StaticCall(NDJLIB001,GDToExcel,aHeader,aCols,cWorkSheet,cTable,lTotalize,lPicture)
/*/
Static Function GDToExcel(aHeader,aCols,cWorkSheet,cTable,lTotalize,lPicture)

    
    Local oFWMSExcel := FWMSExcel():New()
    
    Local oMsExcel

    Local aCells

    Local cType
    Local cColumn

    Local cFile
    Local cFileTMP
    
    Local cPicture

    Local lTotal

    Local nRow
    Local nRows
    Local nField
    Local nFields
    
    Local nAlign
    Local nFormat
    
    Local uCell
        
    DEFAULT cWorkSheet := "GETDADOS"
    DEFAULT cTable     := cWorkSheet
    DEFAULT lTotalize  := .T.
    DEFAULT lPicture   := .F.
    
    BEGIN SEQUENCE
    
        oFWMSExcel:AddworkSheet(cWorkSheet)
        oFWMSExcel:AddTable(cWorkSheet,cTable)
        

		__AHEADER_TYPE__ 	:= 8
		__AHEADER_TITLE__	:= 1
		__AHEADER_PICTURE__	:= 3

        nFields := Len( aHeader )
        For nField := 1 To nFields
            cType   := aHeader[nField][8]
            nAlign  := IF(cType=="C",1,IF(cType=="N",3,2))
            nFormat := IF(cType=="D",4,IF(cType=="N",2,1))        
            cColumn := aHeader[nField][1]
            lTotal  := ( lTotalize .and. cType == "N" )
            oFWMSExcel:AddColumn(@cWorkSheet,@cTable,@cColumn,@nAlign,@nFormat,@lTotal)
        Next nField
        
        aCells := Array(nFields)
    
        nRows := Len( aCols )
        For nRow := 1 To nRows
            For nField := 1 To nFields
                uCell    := aCols[nRow][nField]
				IF valtype(aCols[nRow][nField])=='O'
					uCell    := aCols[nRow][nField]:CNAME
				END
				if !empty(aHeader[nField][11])
                    //ALERT(uCell)
                    //ALERT(aHeader[nField][11])
					xaux2:= separa(aHeader[nField][11],';')
					nscan:= Ascan( xaux2 ,{|x| substr(x,1,1) == uCell })
					if nscan <> 0
						uCell:= xaux2[nscan]
					end
				end
                IF ( lPicture )
                    cPicture  := aHeader[nField][3]
                    IF .NOT.( Empty(cPicture) )
                        uCell := Transform(uCell,cPicture)
                    EndIF
                EndIF
                aCells[nField] := uCell
            Next nField
            oFWMSExcel:AddRow(@cWorkSheet,@cTable,aClone(aCells))
        Next nRow
    
        oFWMSExcel:Activate()
        
        cFile := ( CriaTrab( NIL, .F. ) + ".xml" )
        
        While File( cFile )
            cFile := ( CriaTrab( NIL, .F. ) + ".xml" )
        End While
        
        oFWMSExcel:GetXMLFile( cFile )
        oFWMSExcel:DeActivate()
                
        IF .NOT.( File( cFile ) )
            cFile := ""
            BREAK
        EndIF
        
        cFileTMP := ( GetTempPath() + cFile )
        IF .NOT.( __CopyFile( cFile , cFileTMP ) )
            fErase( cFile )
            cFile := ""
            BREAK
        EndIF
        
        fErase( cFile )
        
        cFile := cFileTMP
        
        IF .NOT.( File( cFile ) )
            cFile := ""
            BREAK
        EndIF
        
        IF .NOT.( ApOleClient("MsExcel") )
            BREAK
        EndIF
        
        oMsExcel := MsExcel():New()
        oMsExcel:WorkBooks:Open( cFile )
        oMsExcel:SetVisible( .T. )
        oMsExcel := oMsExcel:Destroy()
        
    END SEQUENCE
        
    oFWMSExcel := FreeObj( oFWMSExcel )
        
Return( cFile )
