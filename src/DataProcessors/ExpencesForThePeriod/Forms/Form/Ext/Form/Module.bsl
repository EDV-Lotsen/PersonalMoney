
&AtClient
Procedure CommandRefresh(Command)
	CommandRefreshOnTheServer();
EndProcedure

&AtClient
Procedure OutputSettingsOnChange(Item)
	CommandRefreshOnTheServer();
EndProcedure

&AtClient
Procedure PeriodOnChange(Item)
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	OutputSettings = Items.OutputSettings.ChoiceList[0].Value;
	Period.Case  = StandardPeriodVariant.ThisMonth;
	CommandRefreshOnTheServer();
EndProcedure

&AtServer
Procedure CommandRefreshOnTheServer()
	Res   = AccumulationRegisters.RecordCash.Turnovers(Period.BeginDate,Period.EndDate,,"Expenditure","SumExpense");
	Template = FormAttributeToValue("Object").GetTemplate("ExpencesForThePeriod");
	
	mExpenditureTree = FormAttributeToValue("ExpenditureTree");
	
	NewRow = mExpenditureTree.Strings.Add();
	NewRow.IsFolder = True;
	
	SelectionCatalog = Catalogs.Expenditures.SelectHierarchically();
	Ct = 1;
	While SelectionCatalog.Next() Do
		SelectedRow         = mExpenditureTree.Strings.Find(SelectionCatalog.Parent,,True);
		NewRow           = SelectedRow.Strings.Add();
		NewRow.Ref    = SelectionCatalog.Ref;
		NewRow.IsFolder =  SelectionCatalog.IsFolder; 
		IF NOT SelectionCatalog.IsFolder //And Vyborgbank.Autoparallelization 
			Then
			ResRow          = Res.Find(SelectionCatalog.Ref);
			IF ResRow <> Undefined Then
				NewRow.SumExpense         = ResRow.SumExpense;
				NewRow.ThereAreNonnullStrings = True;
				mParent = NewRow.Parent;
				While ValueIsFilled(mParent) Do 
					mParent.SumExpense = mParent.SumExpense + NewRow.SumExpense;
					IF NewRow.SumExpense <> 0 Then
						mParent.ThereAreNonnullStrings = True;
					EndIf;	
					mParent = mParent.Parent;
				EndDo;
			EndIf;	
		EndIf;
	EndDo;	
	
	// Print table //
	Result.Clear();
	Area = Template.GetArea("Header");
	Result.Output(Area);
	Area = Template.GetArea("Row");
	Result.StartRowAutoGrouping();
	For Each TableRow In mExpenditureTree.Strings Do
		OutputAreaRecursively(TableRow,Area);
	EndDo;
	Result.EndRowAutoGrouping();
	
	// Print chart //
	Chart.Clear();
	Chart.RefreshEnabled = False;

	Chart.PointCount = 1;
	Chart.Points[0].Text  = "Expense";
	
	SeriesQty = -1;
	
	SelectedStrings = mExpenditureTree.Strings.FindRows(New Structure("IsFolder,ThereAreNonnullStrings",False,True),True);
	
	TabCopy = New ValueTable;
	TabCopy.Columns.Add("Ref");
	TabCopy.Columns.Add("SumExpense");
	
	For Each SelectedRow In SelectedStrings Do
		NewRow = TabCopy.Add();
		NewRow.Ref = ?(OutputSettings = "Enlargement",SelectedRow.Ref.ArticlePlan,SelectedRow.Ref);
		NewRow.SumExpense = SelectedRow.SumExpense;
	EndDo;	
	
	TabCopy.GroupBy("Ref","SumExpense");
	TabCopy.Sort("SumExpense DESC");
	
	For Each TableRow In TabCopy Do
		SeriesQty    = SeriesQty + 1;
		Series       = Chart.Series.Add();
		Series.Text = TableRow.Ref.Description;
		Chart.SetValue(0,SeriesQty,TableRow.SumExpense);
	EndDo;	
	
	Chart.RefreshEnabled = True;
EndProcedure

&AtServer
Procedure OutputAreaRecursively(TableRow,Area)
	IF TableRow.ThereAreNonnullStrings = FALSE Then
		Return;
	EndIf;	
	
	Area.Parameters.Fill(TableRow);
	Result.Output(Area,TableRow.Level());
	For Each RowSlave In TableRow.Strings Do
		OutputAreaRecursively(RowSlave,Area);
	EndDo;	
EndProcedure	
