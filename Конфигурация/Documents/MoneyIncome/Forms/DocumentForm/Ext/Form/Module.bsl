// CLIENT PROCEDURES AND FUNCTIONS //

&AtClient
Procedure AfterWrite(WriteParameters)
	Notify("RecordDocument");
EndProcedure

&AtClient
Procedure WalletOnChange(Item)
	WalletOnChangeServer();
EndProcedure

&AtClient
Procedure DebtOnChange(Item)
	IF Not Object.Debt Then
		Object.Counterparty = Undefined;
	EndIf;
	RefreshTheView();
EndProcedure

// SERVER PROCEDURES AND FUNCTIONS //

&AtServer
Procedure WalletOnChangeServer ()
	CurrencyWallet = Object.Wallet.Currency;
	RefreshTheView();
EndProcedure	

&AtServer
Procedure RefreshTheView ()
	IF MainCurrency <> CurrencyWallet Then
		Items.GroupRateRepetition.Visible = True;
		RateRepetition = CommonModuleServer.GetRateRepetitionCurrencies(Object.Wallet.Currency, Object.Date); 
		FillPropertyValues(Object,RateRepetition);
	Else
		Rate      = 1;
		Repetition = 1;
		Items.GroupRateRepetition.Visible = False;
	EndIf;	
	Items.Counterparty.Enabled = Object.Debt;
EndProcedure	

// INITIALIZATION OF THE DOCUMENT //

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing) 
	IF Not ValueIsFilled(Object.Ref) Then
		RES = CommonModuleServer.GetDefaultValues(FormAttributeToValue("Object").Metadata().FullName(),"Wallet,Expenditure");
		FillPropertyValues(Object,Res);
		WalletOnChangeServer();
		NewRow = Object.Amounts.Add();
		FillPropertyValues(NewRow,Res);	
	EndIf;
	MainCurrency = Constants.MainCurrency.Get();
	CurrencyWallet = Object.Wallet.Currency;
	RefreshTheView();
	
	SettingOfTheFormsServer.SettingWhenCreatingForms(ThisForm,Object,"Amounts");

EndProcedure

// FORM MANAGEMENT //

// CLIENT PROCEDURES //

&AtClient
Procedure AddString(Command)
	NewRow     = Object.Amounts.Add();
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
	SettingFormsClient.PropsOnChange(ThisForm,Object,"Amounts",Item);
EndProcedure	

// SERVER PROCEDURES //

&AtServer
Procedure CreateRefreshItemsForms ()
	SettingOfTheFormsServer.CreateRefreshItemsForms(ThisForm,Object,"Amounts");
EndProcedure	

&AtServer
Procedure DeleteItemsStrings (UID)
	SettingOfTheFormsServer.DeleteItemsStrings(ThisForm,Object,"Amounts",UID);
EndProcedure	
