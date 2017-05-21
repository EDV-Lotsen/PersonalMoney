
&AtClient
Procedure CommandFillByDefault(Command)
	InitialFilltype();
	Items.List.Refresh();
EndProcedure

&AtServer
Procedure InitialFilltype ()
	Catalogs.Currencies.InitialFilltype();
EndProcedure	

