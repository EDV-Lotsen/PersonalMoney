
&AtClient
Procedure CommandRefresh(Command)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure CommandRefreshOnTheServer()
	ValueTablePlanReal.Clear();
	Filter = New Structure;
	IF ValueIsFilled(Periodicity) Then
		Filter.Insert("Periodicity",Periodicity);
	EndIf;	
	TabFact = AccumulationRegisters.PlanRegisterrecordsDS.Turnovers(Period.BeginDate,Period.EndDate,Filter,"ArticlePlan","SumExpense");
	TabFact.Sort("SumExpense DESC");
	For Each TableRow In TabFact Do 
		NewRow = ValueTablePlanReal.Add();
		NewRow.ArticlePlan  = TableRow.ArticlePlan;
		NewRow.PlanExpense = TableRow.SumExpense; 
	EndDo;	
	
	TabPlan = AccumulationRegisters.RecordCash.Turnovers(Period.BeginDate,Period.EndDate,,"Expenditure","SumExpense");
	For Each TableRow In TabPlan Do 
		IF NOT TableRow.Expenditure.ShowInExpenseReport Then
			Continue;
		EndIf;	
		SelectedStrings = ValueTablePlanReal.FindRows(New Structure("ArticlePlan",TableRow.Expenditure.ArticlePlan));
		IF SelectedStrings.Count() > 0 Then
			SelectedStrings[0].FactExpence = SelectedStrings[0].FactExpence + TableRow.SumExpense;
		Else
			NewRow = ValueTablePlanReal.Add();
			NewRow.ArticlePlan = TableRow.Expenditure.ArticlePlan;
			NewRow.FactExpence  = TableRow.SumExpense; 
		EndIf;	
	EndDo;	
	
	// UPDATE CHART //
	Chart.Clear();
	Series = Chart.Series.Add("Plan");
	Series.Color = New Color(,255,0);
	
	Series = Chart.Series.Add("Real");
	Series.Color = New Color(255,255,0);
	
	For Each TableRow In ValueTablePlanReal Do
		Point = Chart.Points.Add(TableRow.ArticlePlan.Description);
		Chart.SetValue(Point,0,TableRow.PlanExpense);
		Chart.SetValue(Point,1,TableRow.FactExpence);
	EndDo;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period.Case = StandardPeriodVariant.ThisMonth;
	CommandRefreshOnTheServer();
EndProcedure
