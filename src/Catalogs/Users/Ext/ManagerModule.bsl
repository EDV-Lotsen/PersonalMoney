Procedure InitialFilltype() Export
	Selection = Catalogs.Users.Select();
	IF Not Selection.Next() Then
		El = Catalogs.Users.CreateItem();
		El.Description = NStr("ru = 'User'; en = 'User'");
		El.Write();
	EndIf;	
EndProcedure
