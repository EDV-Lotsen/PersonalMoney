Procedure Posting(Cancel, Mode)
	RegisterRecords.Debts.Clear();
	RegisterRecords.Debts.Write = True;
	Record             = RegisterRecords.Debts.Add();
	IF Operation = Enums.OperationTypeDebt.IGotInDebt Then
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Sum       = Sum;
	ElsIf Operation = Enums.OperationTypeDebt.IReturnedDebt Then
		Record.RecordType = AccumulationRecordType.Expense;
		Record.Sum       = Sum;
	ElsIf Operation = Enums.OperationTypeDebt.IAmInDebt Then
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Sum       = -Sum;
	ElsIf Operation = Enums.OperationTypeDebt.IReturnedTheDebt Then
		Record.RecordType = AccumulationRecordType.Expense;
		Record.Sum       = -Sum;
	EndIf;
	Record.Period      = Date;
	Record.Counterparty  = Counterparty;
	Record.Currency      = Currency;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	IF Not ValueIsFilled(Currency) Then
		Currency = Constants.MainCurrency.Get();
	EndIf;	
EndProcedure
