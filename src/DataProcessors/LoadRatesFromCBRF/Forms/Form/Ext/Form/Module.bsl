
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period.Case = StandardPeriodVariant.FromBeginningOfThisMonth;
	Selection        = Catalogs.Currencies.Select();
	While Selection.Next() Do
		NewRow = Currencies.Add();
		NewRow.Currency = Selection.Ref;
		NewRow.Selected = True;
		NewRow.Code    = Selection.Code;
	EndDo;	
EndProcedure

&AtClient
Procedure CommandLoad(Command)
	CommandLoadOnTheServer();
EndProcedure

&AtServer
Procedure CommandLoadOnTheServer()
  	Address = "http://www.cbr.ru/DailyInfoWebServ/DailyInfo.asmx?WSDL";
    
	Try
        Definitions = New WSDefinitions(Address,"","", 60);
		URI         = "http://web.cbr.ru/";
		Proxy      = New WSProxy(Definitions, URI, "DailyInfo", "DailyInfoSoap");
    Except
 		Message(NStr("ru = 'Logon failed!'; en = 'Connection failed!'"));
		Return;
	EndTry;
	
	Try
		//Get the type parameter that is passed to method GetCursOnDate.
		TypeWSParameter = Proxy.XDTOFactory.Packages.Get("http://web.cbr.ru/").Get("GetCursOnDate");
		//Create a param based on the type and fill in value ragama On_Date.
		WSParameter	       = Proxy.XDTOFactory.Create(TypeWSParameter);
		
		mDate = Period.BeginDate;
		
		While mDate <= Period.EndDate Do
			WSParameter.On_Date = mDate;
			CurrencyRates         = Proxy.GetCursOnDate(WSParameter);
			For Each Item In CurrencyRates.GetCursOnDateResult.diffgram.ValuteData.ValuteCursOnDate Do 
				mCode = Format(Number(Item.Vcode),"ND=3");
				SelectedStrings = Currencies.FindRows(New Structure("Code,Selected",mCode,True));
				For Each SelectedRow In SelectedStrings Do
					Record = InformationRegisters.CurrencyRates.CreateRecordManager();
					Record.Currency    = SelectedRow.Currency;
					Record.Period    = BegOfDay(mDate);
					Record.Rate      = Item.Vcurs;
					Record.Repetition = Item.Vnom;
					Record.Write();
				EndDo;	
			EndDo;
			mDate = EndOfDay(mDate) + 1;
		EndDo;
 		Message(NStr("ru = 'Rates uploaded!'; en = 'Rates loaded!'"));
	Except
	 	Message(NStr("ru = 'An error occurred when loaing rates!'; en = 'Error loading rates!'"));
	EndTry;
EndProcedure
