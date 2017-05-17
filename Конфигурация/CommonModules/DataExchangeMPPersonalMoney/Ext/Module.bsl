
/// COMMON PROCEDURES AND FUNCTIONS ///

// Procedure contributes to the information base data which are sent from node "Salobrena"
//
// Parameters:
//  NodeExchange	– node plan of exchange "mobile"
//  with whom you exchange DataExchange - package exchange is derived from the node Salobrena
//placed in ValueStorage
Procedure AcceptExchangePackage(NodeExchange, DataExchange) Export
	
	XMLReader = New XMLReader;
	XMLReader.SetString(DataExchange.Get());
	ReadMessages = ExchangePlans.CreateMessageReader();
	ReadMessages.BeginRead(XMLReader);
	ExchangePlans.DeleteChangeRecords(ReadMessages.Sender,ReadMessages.ReceivedNo);
	
	BeginTransaction();
	While CanReadXML(XMLReader) Do
		
		Data = ReadXML(XMLReader);
		
		IF Not Data = Undefined Then
			
			Data.DataExchange.Sender = ReadMessages.Sender;
			Data.DataExchange.Load = True;
			
			Data.Write();
			
		EndIf;
		
	EndDo;
	CommitTransaction();
	
	ReadMessages.EndRead();
	XMLReader.Close();
	
EndProcedure

// Procedure logs changes for all data included in the content
// plan of exchange Parameters:
//  NodeExchange - node of the exchange plan for which changes are logged
Procedure ToRegisterDataChanges(NodeExchange) Export
	//While the exchange goes in oneway mode with the MP on local computer - no data registration
	Return;
	
	ExchangePlanContent = NodeExchange.Metadata().Content;
	For Each ExchangePlanContentItem In ExchangePlanContent Do
		ExchangePlans.RecordChanges(NodeExchange,ExchangePlanContentItem.Metadata);
	EndDo;
	
EndProcedure

// Reads all changes from the information database and returns them in the form of store values //
Function GetDataExchange (NodeExchange) Export
	TempFileName = GetTempFileName("xml");
	XMLWriter       = New XMLWriter;
	XMLWriter.OpenFile(TempFileName);	
	RecordChanges = ExchangePlans.CreateMessageWriter();
	RecordChanges.BeginWrite(XMLWriter,NodeExchange);
 	ExchangePlans.WriteChanges(RecordChanges);
	RecordChanges.EndWrite();
	XMLWriter.Close();
	
 	Read = New TextReader(TempFileName);
	Read.Open(TempFileName);
	Text  = Read.Read();	
	Read.Close();
	
	DeleteFiles(TempFileName);
	
	StructureOfTheResponse = New Structure;
	StructureOfTheResponse.Insert("SentNo", NodeExchange.SentNo);
	StructureOfTheResponse.Insert("Text",Text);
	
	Return New ValueStorage(StructureOfTheResponse, New Deflation(9));
EndFunction	
