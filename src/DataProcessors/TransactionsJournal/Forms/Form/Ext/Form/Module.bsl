
&AtClient
Procedure TransactionsJournalSelection(Item, RowSelected, Field, StandardProcessing)
	OpenValue(Items.TransactionsJournal.CurrentData.Recorder);
EndProcedure

&AtClient
Procedure CommandRefresh(Command)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure CommandRefreshOnTheServer()
	TransactionsJournal.Clear();
	Selection = AccumulationRegisters.Cash.Select(Period.BeginDate,Period.EndDate,New Structure("Wallet",Parameters.Wallet));
	While Selection.Next() Do
		NewRow = TransactionsJournal.Add();
		FillPropertyValues(NewRow,Selection);
		NewRow.Sum    = ?(Selection.RecordType = AccumulationRecordType.Receipt,1,-1) * NewRow.Sum;
		NewRow.Operation = Selection.Recorder.Metadata().Synonym;
	EndDo;	
	
	OpeningBalance = 0;
	ClosingBalance  = 0;
	
	DataOnTheBalances = AccumulationRegisters.Cash.Balance(New Boundary(Period.BeginDate,BoundaryType.Excluding),New Structure("Wallet",Parameters.Wallet));
	For Each TableRow IN DataOnTheBalances Do
		OpeningBalance = TableRow.Sum;
	EndDo;	
	
	DataOnTheBalances = AccumulationRegisters.Cash.Balance(New Boundary(Period.EndDate,BoundaryType.Including),New Structure("Wallet",Parameters.Wallet));
	For Each TableRow IN DataOnTheBalances Do
		ClosingBalance = TableRow.Sum;
	EndDo;	       	
EndProcedure

&AtClient
Procedure PeriodOnChange(Item)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period.Case = StandardPeriodVariant.Last7Days;
	CommandRefreshOnTheServer();
EndProcedure
