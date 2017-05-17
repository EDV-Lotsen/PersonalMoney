Procedure Posting(Cancel, Mode)
	// register PlanRegisterrecordsDS
	RegisterRecords.PlanRegisterrecordsDS.Write = True;
	RegisterRecords.PlanRegisterrecordsDS.Clear();
	
	mStartDate = GetBeginningOfPeriod(BeginOfPeriod,Periodicity);
	mEndDate = GetEndOfPeriod(EndOfPeriod,Periodicity);
	
	mDate = mStartDate;
	While mDate < mEndDate Do
		For Each CurRowPlan In Plan Do
			Record = RegisterRecords.PlanRegisterrecordsDS.Add();
			Record.Period        = mDate;
			Record.ArticlePlan   = CurRowPlan.ArticlePlan;
			Record.Periodicity = Periodicity;
			Record.AmountReceipt   = CurRowPlan.AmountReceipt;
			Record.SumExpense   = CurRowPlan.SumExpense;
		EndDo;
		mDate = GetEndOfPeriod(mDate,Periodicity) + 1;
	EndDo; 
EndProcedure

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

