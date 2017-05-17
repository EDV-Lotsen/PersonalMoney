Procedure PropsOnChange (Form,Object,TabName,Item) Export
	ElementName  = Item.Name;
	AttributeName = Left(ElementName,Find(ElementName,"_") - 1);
	UID = Right(ElementName,StrLen(ElementName) - Find(ElementName,"_"));
	
	SelectedStrings = Object[TabName].FindRows(New Structure("UID",UID));
	For Each SelectedRow In SelectedStrings Do
		SelectedRow[AttributeName] = Form[ElementName];
	EndDo;	
EndProcedure	
