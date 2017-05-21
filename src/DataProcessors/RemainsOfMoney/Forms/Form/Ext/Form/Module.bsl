&AtServer
Procedure RefreshBalance()
	RemainsOfMoney.Clear();
	VTable    = AccumulationRegisters.Cash.Balance();
	VTable.Sort("Wallet");
	Column = VTable.Columns.Add("Currency");
	Totals = 0;
	For Each TableRow In VTable Do
		NewRow = RemainsOfMoney.Add();
		TableRow.Currency = TableRow.Wallet.Currency;
		FillPropertyValues(NewRow,TableRow);
	EndDo;	
	
	VTable.GroupBy("Currency","Sum");
	VTable.Sort("Currency");
	Totals = "";
	For Each TableRow In VTable Do
		IF TableRow.Sum <> 0 Then
			Totals = Totals + ?(IsBlankString(Totals),"","; ") + Format(TableRow.Sum,"NFD=; NG=") + " " + ?(ValueIsFilled(TableRow.Currency),TableRow.Currency,"<>");
		EndIf;	
	EndDo;	
EndProcedure	

&AtClient
Procedure CommandRefreshBalanceДС(Command)
	RefreshBalance();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	RefreshBalance();
EndProcedure

&AtClient
Procedure BalanceChoice(Item, RowSelected, Field, StandardProcessing)
	CurRow = Items.Balance.CurrentData;
	IF CurRow <> Undefined Then
		OpenForm("DataProcessor.TransactionsJournal.Form.Form",New Structure("Wallet",CurRow.Wallet));
	EndIf;	
EndProcedure
