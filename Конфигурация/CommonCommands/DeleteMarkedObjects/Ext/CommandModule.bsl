
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	DeleteMarkedServer();
EndProcedure

&AtServer
Procedure DeleteMarkedServer ()
	CommonModuleServer.DeleteMarkedServer();
EndProcedure 	
