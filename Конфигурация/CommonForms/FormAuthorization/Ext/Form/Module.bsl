
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	User = Constants.LastAuthorizedUser.Get();
EndProcedure

&AtClient
Procedure CommandCancel(Command)
EndProcedure

&AtClient
Procedure CommandOK(Command)
	IF ValidatePassword() Then
		YouCanClose = True;
		Close();
	Else
		Message("Wrong password!");
	EndIf;	
EndProcedure

&AtServer
Function ValidatePassword () 
	IF Not ValueIsFilled(User) Then
		Return False;
	EndIf;
	
	Constants.LastAuthorizedUser.Set(User);
	
	Return User.PasswordHash = CommonModuleServer.HashString(Password);
EndFunction	

&AtClient
Procedure BeforeClose(Cancel, StandardProcessing)
	IF Not YouCanClose Then 
		Cancel = True;
	EndIf;	
EndProcedure
