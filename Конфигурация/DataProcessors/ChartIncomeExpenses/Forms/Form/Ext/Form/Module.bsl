
&AtClient
Procedure CommandRefresh(Command)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period.Case = StandardPeriodVariant.ThisMonth;
	Periodicity  = Enums.Periodicity.Week;
	OutputSettings = "Expences";
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure CommandRefreshOnTheServer()
	mStartDate = GetBeginningOfPeriod(Period.BeginDate, Periodicity);
	mEndDate = GetEndOfPeriod(Period.EndDate, Periodicity);
	Ct = 0;
	ChartOfExpenditures.Clear();
	
	ChartOfExpenditures.RefreshEnabled = FALSE;
	
	OutputIncome  = OutputSettings = "Income"  Or OutputSettings = "All";
	OutputExpences = OutputSettings = "Expences" Or OutputSettings = "All";
	
	IF OutputIncome Then
		Series = ChartOfExpenditures.Series.Add("Receipt");
		Series.Color = New Color(,255,0);
	EndIf;
	IF OutputExpences Then
		Series = ChartOfExpenditures.Series.Add("Expense");
		Series.Color = New Color(255,0,0);
	EndIf;
	
	While mStartDate < mEndDate - 1 Do
		Ct  = Ct + 1;
		Res = AccumulationRegisters.RecordCash.Turnovers(mStartDate,GetEndOfPeriod(mStartDate,Periodicity),,"Expenditure","AmountReceipt,SumExpense");
		For Each TableRow In Res Do 
			IF TableRow.AmountReceipt <> 0 AND TableRow.SumExpense <> 0 Then
				Difference = TableRow.AmountReceipt - TableRow.SumExpense;
				TableRow.AmountReceipt = ?(Difference > 0,Difference,0);
				TableRow.SumExpense = ?(Difference < 0,-Difference,0);
			EndIf;	
		EndDo;	
		Res.GroupBy(,"AmountReceipt,SumExpense");
		Point = ChartOfExpenditures.Points.Add(Format(mStartDate,"DF=dd.MM.yy"));
		IF Res.Count() > 0 Then
			StepsCount = -1;
			IF OutputIncome Then
				StepsCount = StepsCount + 1;
				ChartOfExpenditures.SetValue(Point,StepsCount,Res[0].AmountReceipt);
			EndIf;
			IF OutputExpences Then
				StepsCount = StepsCount + 1;
				ChartOfExpenditures.SetValue(Point,StepsCount,Res[0].SumExpense);
			EndIf;
		EndIf;
		mStartDate = GetEndOfPeriod(mStartDate,Periodicity) + 1;
	EndDo;	
	
	ChartOfExpenditures.RefreshEnabled = True;
EndProcedure

&AtClient
Procedure CommandSettings(Command)
	// Insert content.
EndProcedure

&AtServerNoContext
Function GetBeginningOfPeriod(Date,Periodicity)
	IF Periodicity = Enums.Periodicity.Quarter Then
		Return BegOfQuarter(Date);
	ElsIf Periodicity = Enums.Periodicity.Month Then
		Return BegOfMonth(Date);
	ElsIf Periodicity = Enums.Periodicity.Week Then
		Return BegOfWeek(Date);
	Else
		Return BegOfDay(Date);
	EndIf;	
EndFunction	

&AtServerNoContext
Function GetEndOfPeriod(Date,Periodicity)
	IF Periodicity = Enums.Periodicity.Quarter Then
		Return EndOfQuarter(Date);
	ElsIf Periodicity = Enums.Periodicity.Month Then
		Return EndOfMonth(Date);
	ElsIf Periodicity = Enums.Periodicity.Week Then
		Return EndOfWeek(Date);
	Else
		Return EndOfDay(Date);
	EndIf;	
EndFunction	
