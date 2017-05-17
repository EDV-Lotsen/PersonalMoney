&AtServer
Procedure RefreshBalance()
	RemainsOfMoney.Clear();
	VTable = AccumulationRegisters.Cash.Balance();
	
	Selection = Catalogs.Wallets.Select();
	While Selection.Next() Do
		IF Not Selection.IsFolder AND Selection.QuickAccessToTheRemains AND VTable.Find(Selection.Ref,"Wallet") = Undefined Then
			NewRow         = VTable.Add();
			NewRow.Wallet = Selection.Ref;
		EndIf;	
	EndDo;
	
	VTable.Sort("Wallet");
	For Each TableRow In VTable Do
		IF TableRow.Wallet.QuickAccessToTheRemains Then
			NewRow = RemainsOfMoney.Add();
			FillPropertyValues(NewRow,TableRow);
			NewRow.Currency = NewRow.Wallet.Currency;
		EndIf;	
	EndDo;	
	Items.RemainsOfMoney.HeightInTableRows = RemainsOfMoney.Count();
EndProcedure	

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	// INSTEAD OF THE APPLICATION MODULE //
	CommonModuleServer.ValidateExecuteInitialFilltype();
	CommonModuleServer.ValidateExecuteRefreshenabled();
	// INSTEAD OF THE APPLICATION MODULE //
	RefreshBalance();
EndProcedure

// CLIENT  PROCEDURES AND FUNCTIONS //

// DOCUMENTS //

&AtClient
Procedure NewMoneyIncome(Command)
	OpenForm("Document.MoneyIncome.ObjectForm");
EndProcedure

&AtClient
Procedure NewMoneyExpense(Command)
	OpenForm("Document.ExpenseMoney.ObjectForm");
EndProcedure

&AtClient
Procedure NewMoneyTransfer(Command)
	OpenForm("Document.MoneyTransfer.ObjectForm");
EndProcedure

&AtClient
Procedure CommandDocuments(Command)
	OpenForm("CommonForm.Documents");
EndProcedure

// REPORTS //

&AtClient
Procedure CommandRefreshBalanceДС(Command)
	RefreshBalance();
EndProcedure

&AtClient
Procedure OpenReportBalance(Command)
	OpenForm("DataProcessor.RemainsOfMoney.Form.Form");
EndProcedure

&AtClient
Procedure OpenPanelReports(Command)
	OpenForm("CommonForm.PanelReport");
EndProcedure

&AtClient
Procedure OpenPlanning(Command)
	OpenForm("CommonForm.Planning");
EndProcedure

// Catalogs //

&AtClient
Procedure CommandCatalogs(Command)
	OpenForm("CommonForm.Catalogs");
EndProcedure

// DataProcessor alert //

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	IF EventName = "RecordDocument" Then
		RefreshBalance();
	EndIf;	
EndProcedure

// Help //

&AtClient
Procedure CommandHelp(Command)
	OpenForm("CommonForm.Help");
EndProcedure

&AtClient
Procedure CommandTools(Command)
	OpenForm("CommonForm.Tools");
EndProcedure

// Open journal transactions //

&AtClient
Procedure RemainsOfMoneySelect(Item, RowSelected, Field, StandardProcessing)
	CurRow = Items.RemainsOfMoney.CurrentData;
	IF CurRow <> Undefined Then
		OpenForm("DataProcessor.TransactionsJournal.Form.Form",New Structure("Wallet",CurRow.Wallet));
	EndIf;	
EndProcedure

// Check the required authentication //

&AtClient
Procedure OnOpen(Cancel)
	IF ValidateTheNeedForAuthorization() Then
		OpenFormModal("CommonForm.AuthorizationForm");	
	EndIf;	
EndProcedure

&AtServer
Function ValidateTheNeedForAuthorization ()
	Return Constants.UseAuthorization.Get();	
EndFunction	

