
&AtClient
Procedure CommandRefresh(Command)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure CommandRefreshOnTheServer()
	MyDebts.Clear();
	IHave.Clear();
	VTable = AccumulationRegisters.Debts.Balance();
	For Each TableRow In VTable Do
		IF TableRow.Sum > 0 Then
			NewRow = MyDebts.Add();
			FillPropertyValues(NewRow,TableRow);
		Else	
			NewRow = IHave.Add();
			FillPropertyValues(NewRow,TableRow);
			NewRow.Sum = - NewRow.Sum;
		EndIf;
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

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CommandRefreshOnTheServer();
EndProcedure
