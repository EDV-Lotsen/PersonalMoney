Procedure Posting(Cancel, Mode)
	// register Cash Expense
	RegisterRecords.Cash.Write = True;
	Record = RegisterRecords.Cash.Add();
	Record.RecordType = AccumulationRecordType.Expense;
	Record.Period      = Date;
	Record.Wallet     = Sender;
	Record.Sum       = SumOfWriteoff;
	Record.Expenditure   = Expenditure;

	// Cash register Receipt
	RegisterRecords.Cash.Write = True;
	Record = RegisterRecords.Cash.Add();
	Record.RecordType = AccumulationRecordType.Receipt;
	Record.Period      = Date;
	Record.Wallet     = Recipient;
	Record.Sum       = SumIncome;
	Record.Expenditure   = Expenditure;
EndProcedure
