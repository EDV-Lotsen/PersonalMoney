Function GetSetup (NameSettings) Export
	Record = InformationRegisters.SettingsStorage.CreateRecordManager();
	Record.NameSettings = Upper(NameSettings);
	Record.Read();
	IF Record.Selected() Then
		Return Record.Setting.Get();
	Else
		Return Undefined;
	EndIf;	
EndFunction

Function SaveTheSetting (NameSettings,ContentSettings) Export
	Record = InformationRegisters.SettingsStorage.CreateRecordManager();
	Record.NameSettings = Upper(NameSettings);
	Record.Setting = New ValueStorage(ContentSettings);
	Try
		Record.Write(True);
		Return True;
	Except
		Return FALSE;
	EndTry;	
EndFunction	