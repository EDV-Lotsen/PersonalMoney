// CLIENT PROCEDURES AND FUNCTIONS //

&AtClient
Procedure SumOfWriteoffOnChange(Item)
	CalculateTheAmountOfCapitalization();
EndProcedure

&AtClient
Procedure CalculateTheAmountOfCapitalization ()
	IF CurrencyReceipt <> CurrencyExpense Then
    Else 
		Object.SumIncome = Object.SumOfWriteoff;
	EndIf;
EndProcedure	

&AtClient
Procedure RecipientOnChange(Item)
	RefreshVisible();
EndProcedure

&AtClient
Procedure SenderOnChange(Item)
	RefreshVisible();
EndProcedure

// SERVER PROCEDURES AND FUNCTIONS //

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	IF Not ValueIsFilled(Object.Ref) Then
		RES = CommonModuleServer.GetDefaultValues(FormAttributeToValue("Object").Metadata().FullName(),"Sender,Recipient,Expenditure");
		FillPropertyValues(Object,Res);
	EndIf;
	RefreshVisible();
EndProcedure

&AtServer
Procedure RefreshVisible ()
	RefreshLabelsExpense();
	RefreshLabelsReceipt();
	//IF ValueIsFilled(Object.Sender.Currency) AND ValueIsFilled(Object.Recipient.Currency)
	//	Then Items.GroupAmountOfCapitalization.Enabled = Object.Sender.Currency <> Object.Recipient.Currency;
	//Else
	//	ElementsGruppoambienteAccessibility = True;
	//EndIF;
EndProcedure	

&AtClient
Procedure AfterWrite(WriteParameters)
	Notify("RecordDocument");
EndProcedure

// EXPENCE //

&AtServer
Procedure RefreshLabelsExpense ()
	CurrencyExpense    = Object.Sender.Currency;
	IF Not ValueIsFilled(CurrencyExpense) Then
		CurrencyExpense = Constants.MainCurrency.Get();
	EndIf;	
EndProcedure	

// INCOME //

&AtServer
Procedure RefreshLabelsReceipt ()
	CurrencyReceipt    = Object.Recipient.Currency;
	IF Not ValueIsFilled(CurrencyReceipt) Then
		CurrencyReceipt = Constants.MainCurrency.Get();
	EndIf;	
EndProcedure	


