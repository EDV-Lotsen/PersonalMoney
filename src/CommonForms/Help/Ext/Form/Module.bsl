&AtClient
Procedure CommandMail(Command)
	SendMail("Opinion");
EndProcedure

&AtClient
Procedure CommandSentence(Command)
	SendMail("Sentence");
EndProcedure

&AtClient
Procedure CommandError(Command)
	SendMail("Error");
EndProcedure

&AtClient
Procedure SendMail (MessageType) 
	RunApp("mailto:evgeniy.v.bystrov@gmail.com?subject=Mobile package ""Personal money""" + " " + MessageType);
EndProcedure 	

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	//ElementsHelpDocument = "Mobile package created for to keep records of personal income and expenses.
	//|
	//|Future versions are planned to extension of functionality planning and reporting as well as integration with standard solutions 1C translate interface to english.
	//|
	//|Before starting click on the ""Catalogs"" and fill in the catalog ""Currencies"" ""Article"" ""Wallets"".
	//|
	//|In the ""Currencies"" required to fill a full description and description cents for beautiful display in.
	//|
	//|On
	//|the main page are buttons for quick access to document creation:
	//|
	//|- income - increases balance in the selected purse.
	//|
	//|- Money expence - reduces balance.
	//|
	//|- transfer - moves cash from a purse in the other for example removal from the card convert currencies etc.) ";
	//
EndProcedure


