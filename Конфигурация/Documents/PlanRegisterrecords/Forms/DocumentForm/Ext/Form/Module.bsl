
&AtClient
Procedure BeginThePeriodONChange(Item)
	Object.BeginOfPeriod = GetBeginningOfPeriod(Object.BeginOfPeriod,Object.Periodicity); 
EndProcedure

&AtClient
Procedure EndOfThePeriodOnChange(Item)
	Object.EndOfPeriod = GetEndOfPeriod(Object.EndOfPeriod,Object.Periodicity);
EndProcedure

&AtServerNoContext
Function GetBeginningOfPeriod(Date,Periodicity)
	IF Periodicity = Enums.Periodicity.Quarter Then
		Return BegOfQuarter(Date);
	ElsIf Periodicity = Enums.Periodicity.Month Then
		Return BegOfMonth(Date);
	ElsIf Periodicity = Enums.Periodicity.Week Then
		Return BegOfWeek(Date);
	Else
		Return BegOfDay(Date);
	EndIf;	
EndFunction	

&AtServerNoContext
Function GetEndOfPeriod(Date,Periodicity)
	IF Periodicity = Enums.Periodicity.Quarter Then
		Return EndOfQuarter(Date);
	ElsIf Periodicity = Enums.Periodicity.Month Then
		Return EndOfMonth(Date);
	ElsIf Periodicity = Enums.Periodicity.Week Then
		Return EndOfWeek(Date);
	Else
		Return EndOfDay(Date);
	EndIf;	
EndFunction	

&AtClient
Procedure PeriodicityWhenChanging(Item)
	Object.BeginOfPeriod = GetBeginningOfPeriod(Object.BeginOfPeriod,Object.Periodicity); 
	Object.EndOfPeriod  = GetEndOfPeriod(Object.EndOfPeriod,Object.Periodicity);
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SettingOfTheFormsServer.SettingWhenCreatingForms(ThisForm,Object,"Plan");
EndProcedure

// FORM MANAGEMENT //

// CLIENT PROCEDURES //

&AtClient
Procedure AddString(Command)
	NewRow     = Object.Plan.Add();
	NewRow.UID = StrReplace(String(New UUID),"-","_");
	CreateRefreshItemsForms();
EndProcedure

&AtClient
Procedure DeleteString(Command)
	UID = StrReplace(Command.Name,"Delete_","");
	DeleteItemsStrings(UID);
EndProcedure

&AtClient
Procedure PropsOnChange (Item)
	SettingFormsClient.PropsOnChange(ThisForm,Object,"Plan",Item);
EndProcedure	

// SERVER PROCEDURES //

&AtServer
Procedure CreateRefreshItemsForms ()
	SettingOfTheFormsServer.CreateRefreshItemsForms(ThisForm,Object,"Plan");
EndProcedure	

&AtServer
Procedure DeleteItemsStrings (UID)
	SettingOfTheFormsServer.DeleteItemsStrings(ThisForm,Object,"Plan",UID);
EndProcedure	
