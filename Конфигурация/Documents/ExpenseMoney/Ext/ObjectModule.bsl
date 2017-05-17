Procedure Posting(Cancel, Mode)
	RegisterRecords.Cash.Write = True;
	RegisterRecords.RecordCash.Write = True;
	RegisterRecords.Debts.Write = True;
	
	For Each TableRow In Amounts Do
		// register Cash Expense
		Record             = RegisterRecords.Cash.Add();
		Record.RecordType = AccumulationRecordType.Expense;
		Record.Period      = Date;
		Record.Wallet     = Wallet;
		Record.Sum       = TableRow.Sum;
		Record.Expenditure   = TableRow.Expenditure;
		
		// register RecordCash
		Record             = RegisterRecords.RecordCash.Add();
		Record.Period      = Date;
		Record.Wallet     = Wallet;
		Record.Expenditure   = TableRow.Expenditure;
		Record.SumExpense = TableRow.Sum * Rate / Repetition;
		Record.Details = Details;
		
		IF Debt Then
			Record = RegisterRecords.Debts.AddExpense();
			Record.Period     = Date;
			Record.Counterparty = Counterparty;
			Record.Sum      = TableRow.Sum;
			Record.Currency     = Wallet.Currency;
		EndIf;	
	EndDo;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	MainCurrency = Constants.MainCurrency.Get();
	CurrencyWallet = Wallet.Currency;
	
	IF Rate = 0 Or CurrencyWallet = MainCurrency Or NOT ValueIsFilled(CurrencyWallet) Then
		Rate = 1;
	EndIf;
	
	IF Repetition = 0 Or CurrencyWallet = MainCurrency Or NOT ValueIsFilled(CurrencyWallet) Then
		Repetition = 1;
	EndIf;	
	
	SumOfDocument = Amounts.Total("Sum");
	
	PresentationArticle = "";
	For Each TableRow In Amounts Do
		PresentationArticle = PresentationArticle + ?(IsBlankString(PresentationArticle),"",", ") + TableRow.Expenditure;
	EndDo;	
EndProcedure
