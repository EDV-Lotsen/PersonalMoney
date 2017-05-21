
&AtClient
Procedure SynchronizationTest(Command)
	TestDataExchange();
EndProcedure

&AtClient
Procedure ExecuteSynchronization(Command)
	// Insert content.
EndProcedure

&AtServer
Procedure TestDataExchange ()
	Set = FormAttributeToValue("ConstantsSet");
	Set.Write();
	
	ErrorText  = "";
	User = "";
	Password       = "";
    
	Address = Constants.AddressOfDataExchangeService.Get();
  	Address = Address + "/ws/moneyexchange.1cws?wsdl";
    
	//Адрес = 'http://localhost/PesonalMoney/ws/moneyexchange.1cws?wsdl' 
	Try
        Definitions = New WSDefinitions(Address,User,Password, 60);
		URI = "http://www.play.google.com/evgeniy.v.bystrov.money/exchange";
		Proxy = New WSProxy(Definitions, URI, "PersonalMoneyExchange", "PersonalMoneyExchangeSoap");
		Proxy.User = User;
		Proxy.Password       = Password;
		Res = Proxy.GetFreeNodeNumber();
		Message(NStr("ru = 'Connected successfully!'; en = 'Success!'"));
    Except
 		Message(NStr("ru = 'Logon failed!'; en = 'Connection failed!'"));
	EndTry;
EndProcedure	
