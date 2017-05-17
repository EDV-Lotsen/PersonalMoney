
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	FormParameters = New Structure("Document",CommandParameter);
	OpenForm("DataProcessor.DocumentRegisterRecords.Form", FormParameters, CommandExecuteParameters.Source, CommandExecuteParameters.Unique, CommandExecuteParameters.Window, CommandExecuteParameters.URL);
EndProcedure
