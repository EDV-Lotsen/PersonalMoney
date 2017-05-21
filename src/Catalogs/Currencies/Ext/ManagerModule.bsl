Procedure InitialFilltype() Export
	CodesMap = New Map;
	CodesMap.Insert("978","EUR");
	CodesMap.Insert("840","USD");
	CodesMap.Insert("643","RUR");
	
	For Each El In CodesMap Do
		IF Not ValueIsFilled(Catalogs.Currencies.FindByCode(El.Key)) Then
			Cat = Catalogs.Currencies.CreateItem();
			Cat.Code          = El.Key;
			Cat.Description = El.Value;
			Cat.Write();
		EndIf;	
	EndDo;	
	
	IF Not ValueIsFilled(Constants.MainCurrency.Get()) Then
		IF NStr("ru = 'Currency'; en = 'Currency'") = "Currency" Then
			Constants.MainCurrency.Set(Catalogs.Currencies.FindByCode("643"));
		Else
			Constants.MainCurrency.Set(Catalogs.Currencies.FindByCode("840"));
		EndIf;
	EndIf;	
EndProcedure
