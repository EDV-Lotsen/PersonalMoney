&AtClient
Procedure UnloadData(Command)
	UnloadDataServer();
EndProcedure

&AtServer
Procedure UnloadDataServer()
	UnloadDataToFile();
EndProcedure 	

// Performs unloading objects //
&AtServer
Function UnloadDataToFile() Export
	MetadataObjects = New Array;
	MetadataObjects.Add(Catalogs);
	MetadataObjects.Add(Documents);
	
	mTextXML = New XMLWriter;
	mTextXML.OpenFile(PathToFile, "UTF-8");
	
	mTextXML.WriteXMLDeclaration();

	mTextXML.WriteStartElement("Data");    // ++ Data
	
	mTextXML.WriteStartElement("Title"); // ++ Title
	mTextXML.WriteAttribute("Source","PersonalMoney");
	mTextXML.WriteAttribute("Version"  ,Metadata.Version);
	mTextXML.WriteEndElement();             // -- Title
	
	For Each Constant In Constants Do 
		ValueManager = Constant.CreateValueManager();
		ValueManager.Read();
		WriteXML(mTextXML,ValueManager);
	EndDo;
	
	For Each MD In MetadataObjects Do
		For Each El In MD Do 
			Selection = El.Select();
			While Selection.Next() Do
				UnloadTheLink(mTextXML,Selection.Ref.GetObject());
			EndDo;	
		EndDo;	
	EndDo;	
	
	mTextXML.WriteEndElement();             // --Data
	mTextXML.Close();
	
	Message(NStr("ru = 'Data successfully uploaded!'; en = 'Backup succesfully created!'"));
EndFunction	

&AtServer
Function UnloadTheLink (XMLWriter, Item)
	WriteXML(XMLWriter,Item);
	
	IF Documents.AllRefsType().ContainsType(TypeOf(Item.Ref)) Then
		For Each Set In Item.RegisterRecords Do
			Set.Read();
			IF Set.Count() > 0 Then
				WriteXML(XMLWriter,Set);
			EndIf;
		EndDo;	
	EndIf;
EndFunction	

&AtClient
Procedure PathToFileOnStartSelection(Item, ChoiceData, StandardProcessing)
	Res = OpenFormModal("CommonForm.FileDialog",New Structure("InitialDirectory,FileName",PathToFile,"Data.xml"));
	IF Res <> Undefined Then
		PathToFile = Res;
	EndIf;	
EndProcedure

// Downloads objects //
&AtClient
Procedure ReadDataFromFile(Command)
	ReadDataFromFileServer();
EndProcedure

&AtServer
Procedure ReadDataFromFileServer ()
	File = New File(PathToFile);
	
	IF Not File.Exist() Then
		Raise("File not found!");
	EndIf;	
	
	File = Undefined;
	
	StructureDetails = New Structure;
	StructureDetails.Insert("Ref","");
	StructureDetails.Insert("IsFolder","");
	StructureDetails.Insert("DeletionMark","");
	StructureDetails.Insert("Parent","");
	StructureDetails.Insert("Description","");
	StructureDetails.Insert("Code","");
	
	XMLReader = New XMLReader;
	XMLReader.OpenFile(PathToFile);
	XMLReader.Read(); // Area - Title file
	XMLReader.Read(); // Area - Data
	XMLReader.Read(); // Area - Title - Begin
	XMLReader.Read(); // Area - Title - End
	While True Do
		IF XMLReader.LocalName = "Data" Then
			Break;
		EndIf;	
		Try
			// IF all is well and the data structure has not changed - reading
			Data = ReadXML(XMLReader);
			Data.DataExchange.Load = True;
			Data.Write();
		Except
			LocName = XMLReader.LocalName;
			XMLReader.Read();
		EndTry;
	EndDo;	
	
	Message(NStr("ru = 'Data successfully restored!'; en = 'Backup succesfully restored!'"));
EndProcedure	
