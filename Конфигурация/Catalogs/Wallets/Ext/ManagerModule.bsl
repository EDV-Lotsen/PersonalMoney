Procedure InitialFilltype() Export
	Selection = Catalogs.Wallets.Select();
	IF Not Selection.Next() Then
		El = Catalogs.Wallets.CreateItem();
		El.Description           = NStr("ru = 'Wallet'; en = 'Wallet'");
		El.Currency                 = Constants.MainCurrency.Get();
		El.Type                    = Enums.WalletType.Cash;
		El.QuickAccessToTheRemains = True;
		El.Write();
	EndIf;	
EndProcedure
