Procedure InitialFilltype() Export
	Selection = Catalogs.Expenditures.Select();
	IF Not Selection.Next() Then
		Names = New Array;
		Names.Add(NStr("ru = 'Other expences'; en = 'Other'"));
		Names.Add(NStr("ru = 'Adjustment balance'; en = 'Balance correction'"));
		
		For Each Description In Names Do
			IF Not ValueIsFilled(Catalogs.Expenditures.FindByDescription(Description)) Then
				El = Catalogs.Expenditures.CreateItem();
				El.Description                = Description;
				El.ShowInExpenseReport = True;
				El.ArticlePlan                 = Catalogs.PlanExpenitures.Others;
				El.Write();
			EndIf;
		EndDo;	
	EndIf;	
EndProcedure
