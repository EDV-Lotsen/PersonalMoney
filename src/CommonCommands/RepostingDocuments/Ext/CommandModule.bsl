
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	PostDocumentsServer();
	Message("All documents are posted!");
EndProcedure

&AtServer
Procedure PostDocumentsServer () 
	CommonModuleServer.PostDocumentsServer();
EndProcedure	