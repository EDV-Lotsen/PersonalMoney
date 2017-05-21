
&AtClient
Procedure OpenJournal(Command)
	OpenForm("DocumentJournal.DocumentJounalMoney.ListForm");
EndProcedure

// INCOMES //

&AtClient
Procedure CommandIncomesMoney(Command)
	OpenForm("Document.MoneyIncome.ListForm");
EndProcedure
&AtClient
Procedure NewMoneyIncome(Command)
	OpenForm("Document.MoneyIncome.ObjectForm");
EndProcedure

// EXPENCES //

&AtClient
Procedure CommandExpencesMoney(Command)
	OpenForm("Document.ExpenseMoney.ListForm");
EndProcedure

&AtClient
Procedure NewMoneyExpense(Command)
	OpenForm("Document.ExpenseMoney.ObjectForm");
EndProcedure

// MOVE //

&AtClient
Procedure CommandMoveMoney(Command)
	OpenForm("Document.MoneyTransfer.ListForm");
EndProcedure

&AtClient
Procedure NewMoneyTransfer(Command)
	OpenForm("Document.MoneyTransfer.ObjectForm");
EndProcedure

// DEBTS //

&AtClient
Procedure CommandDebts(Command)
	OpenForm("Document.Debt.ListForm");
EndProcedure

&AtClient
Procedure NewDebt(Command)
	OpenForm("Document.Debt.ObjectForm");
EndProcedure

