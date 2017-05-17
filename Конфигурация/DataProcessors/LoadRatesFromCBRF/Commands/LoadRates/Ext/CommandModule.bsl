
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	FormParameters = New Structure("", );
	OpenForm("DataProcessor.LoadRatesFromCBRF.Form", FormParameters, CommandExecuteParameters.Source, CommandExecuteParameters.Unique, CommandExecuteParameters.Window, CommandExecuteParameters.URL);
EndProcedure
