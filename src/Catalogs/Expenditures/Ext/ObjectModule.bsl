Procedure BeforeWrite(Cancel)
	IF DataExchange.Load Then
		Return;
	EndIf;
	
	IF NOT IsFolder AND Not ValueIsFilled(ArticlePlan) Then
		ArticlePlan = Catalogs.PlanExpenitures.Others;
	EndIf;	
EndProcedure
