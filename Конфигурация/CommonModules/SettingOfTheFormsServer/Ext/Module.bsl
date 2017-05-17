Procedure SettingWhenCreatingForms (Form,Object,TabName) Export
	AttributesToBeAdded = New Array;
	Attribute = New FormAttribute("UID",New TypeDescription("Row"),"Object." + TabName);
	AttributesToBeAdded.Add(Attribute);
	Attribute = New FormAttribute("FieldsCreated",New TypeDescription("Boolean"),"Object." + TabName);
	AttributesToBeAdded.Add(Attribute);
	Form.ChangeAttributes(AttributesToBeAdded);
	
	Command = Form.Commands.Add("AddRow");
	Command.Action    = "AddRow";
	Command.Representation = ButtonRepresentation.Picture;
	Command.Picture    = PictureLib.Insert;
	Command.Title   = "";
	
	IF Object[TabName].Count() = 0 Then
		NewRow = Object[TabName].Add();
	EndIf;	
	
	// Create identifiers for lines Table part
	For Each TableRow In Object[TabName] Do
		TableRow.UID = StrReplace(String(New UUID),"-","_");
	EndDo;	
	
	CreateRefreshItemsForms(Form,Object,TabName);
EndProcedure	

Procedure CreateRefreshItemsForms (Form,Object, TabName) Export
	Items = Form.Items;
	Commands  = Form.Commands;
	
	AttributesToBeAdded = New Array;
	
	ListDetailsTabPart = GetListDetailsPM(Form.FormName);
	
	For Each TableRow In Object[TabName] Do
		DescriptionOfFields = "";
	
		IF TableRow.FieldsCreated Then
			Continue;
		EndIf;
		UID = TableRow.UID;
		For Each Attribute In ListDetailsTabPart Do
			FieldName = Attribute.Key + "_" + UID;
			mField   = New FormAttribute(FieldName,Attribute.Value.ValueType,,NStr(Attribute.Value.Presentation));
			AttributesToBeAdded.Add(mField);
			DescriptionOfFields = DescriptionOfFields + ?(IsBlankString(DescriptionOfFields),"",", ") + NStr(Attribute.Value.Presentation);
		EndDo;
		Command = Commands.Add("Delete_" + UID);
		Command.Action    = "DeleteRow";
		Command.Representation = ButtonRepresentation.Picture;
		Command.Picture    = PictureLib.Delete;
		Command.Title   = "";
	EndDo;
	
	Form.ChangeAttributes(AttributesToBeAdded);
	
	For Each TableRow In Object[TabName] Do
		IF TableRow.FieldsCreated Then
			Continue;
		EndIf;
		
		UID = TableRow.UID;
		
		mGroup = Items.Add("Group_" + UID,Type("FormGroup"),Items.GroupRows);
		mGroup.Type = FormGroupType.UsualGroup;
		mGroup.Title           = DescriptionOfFields;
		mGroup.TitleTextColor = StyleColors.ButtonTextColor;
		mGroup.TitleFont      = StyleFonts.LargeTextFont;
		mGroup.Representation         = UsualGroupRepresentation.None;
		mGroup.ShowTitle = FALSE;
		mGroup.Group         = ChildFormItemsGroup.Horizontal;
		mGroup.Width              = 32;
		
		IF TableRow.LineNumber = 1 Then
			ButtonFace = Items.Add("Add_" + FieldName,Type("FormButton"),mGroup);
			ButtonFace.CommandName = "AddRow"; 
		Else	
			mGroup.Representation         = UsualGroupRepresentation.None;
			mGroup.ShowTitle = False;
			ButtonFace = Items.Add("Delete_" + FieldName,Type("FormButton"),mGroup);
			ButtonFace.CommandName = "Delete_" + UID; 
		EndIf;	
		
		ButtonFace.Width = 3;
		
		For Each Attribute In ListDetailsTabPart Do
			FieldName          = Attribute.Key + "_" + UID;
			
			Form[FieldName] = TableRow[Attribute.Key];
			
			Field             = Items.Add(FieldName,Type("FormField"),mGroup);
			Field.DataPath = FieldName;
			Field.Type         = FormFieldType.TextBox;
			Field.TitleLocation = FormItemTitleLocation.None;
			Field.Font              = StyleFonts.LargeTextFont;
			Field.OpenButton = False;
			Field.SetAction("OnChange","PropsOnChange");
			
			IF Attribute.Value.ValueType.ContainsType(Type("Number")) Then
				Field.ChoiceButton = False;
				Field.Width = 10;
			Else
				Field.Width         = 20;
				Field.InputHint = NStr(Attribute.Value.Presentation);
			EndIf;
		EndDo;
		
		TableRow.FieldsCreated = True;
	EndDo;
EndProcedure	

Procedure DeleteItemsStrings (Form, Object, TabName, UID)  Export
	Items = Form.Items;
	Commands  = Form.Commands;
	
	SelectedStrings = Object[TabName].FindRows(New Structure("UID",UID)); 
	For Each SelectedRow In SelectedStrings Do
		Object[TabName].Delete(SelectedRow);
	EndDo;	
	
	ListDetailsTabPart = GetListDetailsPM(Form.FormName);
	
	// Remove items
	Items.Delete(Items["Group_" + UID]);
	
	AttributesToBeDeleted = New Array;
	
	For Each Attribute In ListDetailsTabPart Do
		AttributesToBeDeleted.Add(Attribute.Key + "_" + UID);	
	EndDo;	
	
	Form.ChangeAttributes(,AttributesToBeDeleted);
	
	IF Object[TabName].Count() = 0 Then
		NewRow = Object[TabName].Add();
		NewRow.UID = StrReplace(String(New UUID),"-","_");
		CreateRefreshItemsForms(Form,Object,TabName);
	EndIf;	
EndProcedure	

Function GetListDetailsPM (FormName)
	mTypeNumber = New TypeDescription("Number",New NumberQualifiers(15,2));
	ListDetailsTabPart = New Structure;
	IF FormName = "Document.PlanRegisterrecordsDS.Form.DocumentForm" Then
		ListDetailsTabPart.Insert("ArticlePlan",New Structure("ValueType,Presentation",New TypeDescription("CatalogRef.PlanExpenitures"),"ru = 'Expenditure'; en = 'Item'"));
		ListDetailsTabPart.Insert("AmountReceipt",New Structure("ValueType,Presentation",mTypeNumber,"ru = 'Receipt'; en = 'Income'"));
		ListDetailsTabPart.Insert("SumExpense",New Structure("ValueType,Presentation",mTypeNumber,"ru = 'Expense'; en = 'Expence'"));
	ElsIf FormName = "Document.MoneyIncome.Form.DocumentForm" 
			Or FormName = "Document.ExpenseMoney.Form.DocumentForm" Then
		ListDetailsTabPart.Insert("Expenditure",New Structure("ValueType,Presentation",New TypeDescription("CatalogRef.Expenditures"),"ru = 'Expenditure'; en = 'Item'"));
		ListDetailsTabPart.Insert("Sum"    ,New Structure("ValueType,Presentation",mTypeNumber,"ru = 'Sum'; en = 'Amount'"));
	EndIf;
	Return ListDetailsTabPart;	
EndFunction