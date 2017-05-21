// COMMON PROCEDURES AND FUNCTIONS //

&AtServer
Procedure PostDocumentsServer () Export
	For Each DocumentManager In Documents Do
		Selection = DocumentManager.Select();
		While Selection.Next() Do
			IF Selection.Posted Then
				Selection.Ref.GetObject().Write(DocumentWriteMode.Posting,DocumentPostingMode.Regular);
			EndIf;
		EndDo;	
	EndDo;
EndProcedure	

&AtServer
Procedure DeleteMarkedServer () Export
	Marked = FindMarkedForDeletion();
	Res = FindByRef(Marked);
	
	For Each El In Marked Do
		TheStructureOfTheSearch = New Structure("Ref",El);
		Ct = 0;
		IF Res.FindRows(TheStructureOfTheSearch).Count() <= 1 Then
			Ct = Ct + 1;
			El.GetObject().Delete();
		EndIf;	
		//MessageText = "ru = 'Deleted:'; en = 'Deleted:'" + Ct + "ru = ' objects'; en = ' objects'";
		//Message(NStr(MessageText));
	EndDo; 
EndProcedure	

// DOWNLOAD CURRENCY EXCHANGE RATES //

&AtServer
Function GetRateRepetitionCurrencies (Currency, Date = '00010101') Export
	Return InformationRegisters.CurrencyRates.GetLast(Date,New Structure("Currency",Currency));
EndFunction	

// FILLING OF DOCUMENTS //

&AtServer
Function GetDefaultValues (ObjectTypeName,FieldsList) Export
	mList = DecomposeStringIntoArrayOfSubstrings(FieldsList);
	
	VTable = New ValueTable;
	VTable.Columns.Add("Name");
	VTable.Columns.Add("Value");
	VTable.Columns.Add("Count", New TypeDescription("Number"));
	
	Res = DecomposeStringIntoArrayOfSubstrings(ObjectTypeName,".");
	IF Res[0] = "Document" Then
		Selection = Documents[Res[1]].Select(,,,"Date Desc");
		Ct = 0;
		While Selection.Next() Do
			Ct = Ct + 1;
			
			Meta = Selection.Ref.Metadata();
			
			For Each El In mList Do
				IF Meta.Attributes.Find(El) = Undefined Then
					Continue;
				EndIf;	
				
				TheStructureOfTheSearch = New Structure("Name,Value",El,Selection[El]); 
				SelectedStrings   = VTable.FindRows(TheStructureOfTheSearch);
				IF SelectedStrings.Count() = 0 Then
					SelectedRow = VTable.Add();
					FillPropertyValues(SelectedRow,TheStructureOfTheSearch); 
				Else	
					SelectedRow = SelectedStrings[0];	
				EndIf;	
				SelectedRow.Count = SelectedRow.Count + 1;
			EndDo;
			
			For Each El In mList Do
				For Each Tab In Meta.TabularSections Do
					IF Tab.Attributes.Find(El) = Undefined Then
						Continue;
					EndIf;	
				
					For Each TableRow In Selection.Ref[Tab.Name] Do
						TheStructureOfTheSearch = New Structure("Name,Value",El,TableRow[El]); 
						SelectedStrings   = VTable.FindRows(TheStructureOfTheSearch);
						IF SelectedStrings.Count() = 0 Then
							SelectedRow = VTable.Add();
							FillPropertyValues(SelectedRow,TheStructureOfTheSearch); 
						Else	
							SelectedRow = SelectedStrings[0];	
						EndIf;	
					EndDo;	
				EndDo;	
			EndDo;	
			
			IF Ct = 5 Then
				Break;
			EndIf;	
		EndDo;	
		
	EndIf;	
	
	StructureToReturn = New Structure;
	
	VTable.Sort("Name DESC, Count DESC");
	
	For Each TableRow In VTable Do
		IF StructureToReturn.Property(TableRow.Name) Then
			Continue;
		EndIf;
		StructureToReturn.Insert(TableRow.Name,TableRow.Value);
	EndDo;		
	
	StructureToReturn.Insert("User",Constants.LastAuthorizedUser.Get());
	
	Return StructureToReturn;
EndFunction	

// Linesу splits into multiple lines by delimiter. Separator may be of any length.
//
// Parameters:
//  Row - Row - text delimited;
//  Separator - Row - separator lines of text minimum 1 char;
//  SkipEmptyStrings - Boolean - flag whether a result is empty lines.
//     IF param is not specified the function works in compatibility mode with the previous version:
//       - for separator blank empty strings are not included in the result for
//     the rest of the delimiters empty strings are included in the result.
//       - perevod
//       
//Return
//value:
// Array - array lines.
//  
//Examples:
// _DecomposeStringIntoArrayOfSubstrings(",one,,two,", ",") - returns array of 5 elements three of which - empty strings;
//  _DecomposeStringIntoArrayOfSubstrings(",One,,two,", ",", True) - returns array of two elements;
//  _DecomposeStringIntoArrayOfSubstrings(" one two  ", " ") - returns array of two elements;
//  _DecomposeStringIntoArrayOfSubstrings("") - returns empty array;
//  _DecomposeStringIntoArrayOfSubstrings("",,False) - will return array with one element "" empty string);
//  _DecomposeStringIntoArrayOfSubstrings("", " ") - will return array with one element "" empty string);
//
&AtServer
Function DecomposeStringIntoArrayOfSubstrings(Val Row, Val Separator = ",", Val SkipEmptyStrings = Undefined) Export
	
	Result = New Array;
	
	// for backward compatibility
	IF SkipEmptyStrings = Undefined Then
		SkipEmptyStrings = ?(Separator = " ", True, False);
		IF IsBlankString(Row) Then 
			IF Separator = " " Then
				Result.Add("");
			EndIf;
			Return Result;
		EndIf;
	EndIf;
	//
	
	Position = Find(Row, Separator);
	While Position > 0 Do
		Substring = Left(Row, Position - 1);
		IF Not SkipEmptyStrings Or Not IsBlankString(Substring) Then
			Result.Add(Substring);
		EndIf;
		Row = Mid(Row, Position + StrLen(Separator));
		Position = Find(Row, Separator);
	EndDo;
	
	IF Not SkipEmptyStrings Or Not IsBlankString(Row) Then
		Result.Add(Row);
	EndIf;
	
	Return Result;
	
EndFunction 

// Performs unloading objects //
&AtServer
Function UnloadData() Export
	MetadataObjects = New Array;
	MetadataObjects.Add(Catalogs);
	MetadataObjects.Add(Documents);
	
	UploadedFileName = GetTempFileName("xml");
	
	mTextXML = New XMLWriter;
	mTextXML.OpenFile(UploadedFileName, "UTF-8");
	
	mTextXML.WriteXMLDeclaration();
	
	mTextXML.WriteStartElement("Title");
	mTextXML.WriteAttribute("Source","PersonalMoney");
	mTextXML.WriteAttribute("Version"  ,Metadata.Version);
	mTextXML.WriteEndElement();
	
	For Each MD In MetadataObjects Do
		For Each El In MD Do 
			Selection = El.Select();
			While Selection.Next() Do
				UnloadTheLink(mTextXML,Selection.Ref);
			EndDo;	
		EndDo;	
	EndDo;	
	
	mTextXML.Close();
	
	Read = New TextReader();
	Read.Open(UploadedFileName);
	Text = Read.Read();
	Read.Close();
	
	DeleteFiles(UploadedFileName);
EndFunction	

&AtServer
Function UnloadTheLink (XMLWriter, Item)
	MD        = Item.Metadata();
	XMLWriter = New XMLWriter;
	XMLWriter.WriteStartElement(MD.FullName());
	
	XMLWriter.WriteStartElement("Ref");
	XMLWriter.WriteAttribute("Type"     ,"Row");
	XMLWriter.WriteAttribute("Value",String(Item.UUID()));
	XMLWriter.WriteEndElement();	
	
	For Each Attribute In MD.StandardAttributes Do
		UnloadAttribute(XMLWriter,Attribute.Name,Item[Attribute.Name]);
	EndDo;	
	
	For Each Attribute In MD.Attributes Do
		UnloadAttribute(XMLWriter,Attribute.Name,Item[Attribute.Name]);
	EndDo;	
	
	XMLWriter.WriteStartElement("TabularSections");
	For Each TabData In MD.TabularSections Do 
		XMLWriter.WriteStartElement(TabData.Name);
		For Each TableRow In Item[TabData.Name] Do
			XMLWriter.WriteStartElement("Record");
			For Each Attribute In TabData.Attributes Do
				UnloadAttribute(XMLWriter,Attribute,TableRow[Attribute.Name]);
			EndDo;	
			XMLWriter.WriteEndElement();	
		EndDo;	
		XMLWriter.WriteEndElement();	
	EndDo;	
	XMLWriter.WriteEndElement();	
	
	XMLWriter.WriteEndElement();	
EndFunction	

&AtServer
Function UnloadAttribute (XMLWriter,AttributeName,Value)
	XMLWriter.WriteStartElement(AttributeName);
	XMLWriter.WriteAttribute("Type",GetType(Value));
	XMLWriter.WriteAttribute("Value",Value);
	XMLWriter.WriteEndElement();	
EndFunction	

&AtServer
Function GetType (Value)
	IF TypeOf(Value) = Type ("Number") Then
		Return "Number";
	ElsIf TypeOf(Value) = Type ("Row") Then
		Return "Row";
	ElsIf TypeOf(Value) = Type ("Date") Then
		Return "Date";
	ElsIf TypeOf(Value) = Type ("Boolean") Then
		Return "Boolean";
	ElsIf TypeOf(Value) = Type ("Undefined") Then
		Return "Undefined";
	ElsIf Catalogs.AllRefsType().ContainsType(TypeOf(Value)) Then	
		Return Value.Metadata().FullName();
	ElsIf Documents.AllRefsType().ContainsType(TypeOf(Value)) Then	
		Return Value.Metadata().FullName();
	ElsIf Enums.AllRefsType().ContainsType(TypeOf(Value)) Then	
		Return Value.Metadata().FullName();
	EndIf;	
EndFunction

// Hashing strings //

&AtServer
Function HashString (Row) Export
	mHash = "";
	For mSymbolNumber = 1 To StrLen(Row) Do 
		HashPart = "";
		mCode   = CharCode(Row,mSymbolNumber);
		mNumber = Format(mCode * mCode,"NG=0"); 
		IF StrLen(mNumber) <= 3 Then
			HashPart = Left(mNumber,2);
		Else
			MiddleChar = Int(StrLen(mNumber) / 2);
			HashPart = Mid(mNumber,MiddleChar - 1,2);
		EndIf;	
		mHash = mHash + HashPart;
	EndDo;	
	Return mHash;
EndFunction	

// UPDATE DB //

&AtServer
Procedure ValidateExecuteInitialFilltype () Export
	IF Not Constants.InitialFilltypeProduced.Get() Then
		Catalogs.Currencies.InitialFilltype();
		Catalogs.Wallets.InitialFilltype();
		Catalogs.Expenditures.InitialFilltype();
		Catalogs.Users.InitialFilltype();
		Constants.InitialFilltypeProduced.Set(True);
	EndIf;	
EndProcedure	

&AtServer
Procedure ValidateExecuteRefreshenabled () Export
	mCurVersion =  Constants.VersionNumber.Get(); 
	IF Metadata.Version <> mCurVersion Then
		VersionCodes = DecomposeStringIntoArrayOfSubstrings(mCurVersion,".");
		mCurVersion = "";
		For Each VersionCode In VersionCodes Do
			mCurVersion = mCurVersion + ?(mCurVersion = "","",".") + Format(Number(VersionCode),"ЧЦ=2; ЧДЦ=; ЧН=00; ЧВН=");	
		EndDo;
		
		IF mCurVersion < "01.08.01" Then
			RefreshEnabled_1_8_1();
		EndIf;	
		
		IF mCurVersion < "01.08.02" Then
			RefreshEnabled_1_8_2();
		EndIf;		
		
		IF mCurVersion < "01.08.03" Then
			RefreshEnabled_1_8_3();
		EndIf;		
		
		IF mCurVersion < "01.09.02" Then
			RefreshEnabled_1_9_2();
		EndIf;	
		
		IF mCurVersion < "01.10.06" Then
			RefreshEnabled_1_10_6();
		EndIf;	
		
		IF mCurVersion < "01.11.02" Then
			RefreshEnabled_1_11_2();
		EndIf;	
		
		Constants.VersionNumber.Set(Metadata.Version);
	EndIf;	
EndProcedure

// PROCEDURES AND FUNCTIONS OF SECURITY UPDATES //

&AtServer
Procedure RefreshEnabled_1_8_1 ()
	Selection = Catalogs.Wallets.Select();
	While Selection.Next() Do
		IF Not Selection.IsFolder AND NOT ValueIsFilled(Selection.Type) Then
			El     = Selection.Ref.GetObject();
			El.Type = Enums.WalletType.Cash;
			El.Write();
		EndIf;	
	EndDo;	
EndProcedure	

&AtServer
Procedure RefreshEnabled_1_8_2 ()
	Selection = Catalogs.Expenditures.Select();
	While Selection.Next() Do
		IF Not Selection.IsFolder AND Not ValueIsFilled(Selection.ArticlePlan) Then
			El             = Selection.Ref.GetObject();
			El.ArticlePlan = Catalogs.PlanExpenitures.Others;
			El.Write();
		EndIf;	
	EndDo;	
EndProcedure

&AtServer
Procedure RefreshEnabled_1_8_3 ()
EndProcedure

&AtServer
Procedure RefreshEnabled_1_9_2 ()
	Managers = New Array;
	Managers.Add(Documents.MoneyIncome);
	Managers.Add(Documents.ExpenseMoney);
	Managers.Add(Documents.MoneyTransfer);
	
	For Each Manager In Managers Do
		Selection = Manager.Select();
		While Selection.Next() Do
			Set = AccumulationRegisters.Cash.CreateRecordSet();
			Set.Filter.Recorder.Set(Selection.Ref);
			Set.Read();
			IF Set.Count() > 0 Then
				For Each Record In Set Do
					Record.Expenditure = Selection.Expenditure;
				EndDo;	
				Set.Write();
			EndIf;
		EndDo;	
	EndDo;
EndProcedure

&AtServer
Procedure RefreshEnabled_1_10_6 ()
EndProcedure

&AtServer
Procedure RefreshEnabled_1_11_2 ()
	Catalogs.Users.InitialFilltype();
	
	Selection = Documents.MoneyIncome.Select();
	While Selection.Next() Do
		Set = AccumulationRegisters.Cash.CreateRecordSet();
		Set.Filter.Recorder.Set(Selection.Ref);
		Set.Read();
		Doc = Selection.Ref.GetObject();
		IF Set.Count() > 0 Then
			For Each TableRow In Set Do
				NewRow = Doc.Amounts.Add();
				NewRow.Expenditure = TableRow.Expenditure;
				NewRow.Sum     = TableRow.Sum;
			EndDo;	
		EndIf;	
		Doc.DataExchange.Load = True;
		Doc.Write();
	EndDo;
	
	Selection = Documents.ExpenseMoney.Select();
	While Selection.Next() Do
		Set = AccumulationRegisters.Cash.CreateRecordSet();
		Set.Filter.Recorder.Set(Selection.Ref);
		Set.Read();
		Doc = Selection.Ref.GetObject();
		IF Set.Count() > 0 Then
			For Each TableRow In Set Do
				NewRow = Doc.Amounts.Add();
				NewRow.Expenditure = TableRow.Expenditure;
				NewRow.Sum     = TableRow.Sum;
			EndDo;	
		EndIf;	
		Doc.DataExchange.Load = True;
		Doc.Write();
	EndDo;
EndProcedure

