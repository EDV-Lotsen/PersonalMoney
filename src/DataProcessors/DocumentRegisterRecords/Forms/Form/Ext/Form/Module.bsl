
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Document = Parameters.Document;
	IF Not ValueIsFilled(Document) Then
		Cancel = True;
		Return;
	EndIf;
	
	ListOfFieldTypes = New Array;
	ListOfFieldTypes.Add("StandardAttributes");
	ListOfFieldTypes.Add("Dimensions");
	ListOfFieldTypes.Add("Resources");
	ListOfFieldTypes.Add("Attributes");
		
	Meta = Document.Metadata();
	AttributesToBeAdded = New Array;
	For Each Record In Meta.RegisterRecords Do
		RegisterType = Left(Record.FullName(),Find(Record.FullName(),".") - 1);
		mField       = New FormAttribute(Record.Name,New TypeDescription(StrReplace(Record.FullName(),RegisterType,RegisterType + "RecordSet")),,Record.Synonym);
		AttributesToBeAdded.Add(mField);
	EndDo;	
	
	ThisForm.ChangeAttributes(AttributesToBeAdded);
	
	For Each Record In Meta.RegisterRecords Do
		mSet = FormAttributeToValue(Record.Name);
        mSet.Filter.Recorder.Set(Document);
		mSet.Read();
		ValueToFormAttribute(mSet,Record.Name);
		
		Group                 = Items.Add("Page_" + Record.Name,Type("FormGroup"),Items.GroupPages);
		Group.Title       = Record.Synonym;
		ValueTable                = Items.Add(Record.Name,Type("FormTable"),Group);
		ValueTable.DataPath    = Record.Name;
		ValueTable.ReadOnly = True;
		For Each FieldType In ListOfFieldTypes Do
			For Each FieldMeta In Record[FieldType] Do
				Field = Items.Add(Record.Name + "_" + FieldMeta.Name,Type("FormField"),ValueTable);
				Field.DataPath = Record.Name + "." + FieldMeta.Name;
				IF FieldType = "StandardAttributes" Then
					IF FieldMeta.Name = "RecordType" Then
						Field.Width    = 5;
					Else
						Field.Visible = False;
					EndIf;	
				Else
					Field.Width = 8;
				EndIf;	
			EndDo;	
		EndDo;	
	EndDo;	
EndProcedure

