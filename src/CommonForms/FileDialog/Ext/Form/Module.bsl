&AtServer
Procedure RefreshListTheServerFiles (DirectoryName)
	DirectoryName = TrimAll(DirectoryName);
	
	IF StrOccurrenceCount(DirectoryName,Separator) > 1 AND Right(DirectoryName,1) = Separator Then
		DirectoryName = Left(DirectoryName,StrLen(DirectoryName) - 1);
	EndIf;
	
	mCatalog = New File(DirectoryName);
	
	IF DirectoryName <> Disk AND Not mCatalog.Exist() Then
		
		mParent = New File(mCatalog.Path);
		IF mParent.Exist() Then
			Path = mParent.Path;
		Else
			Path = Disk;
		EndIf;
		
		RefreshListTheServerFiles(Path);
		Return;
		
	ElsIf mCatalog.IsDirectory() Or DirectoryName = Disk Then
		Directory  = DirectoryName;
		ValueTableFiles.Clear();
		VTable       = ValueTableFiles.Unload();
	
		mParentName = mCatalog.Path;
		IF Not IsBlankString(mParentName) Then
			NewRow  = ValueTableFiles.Add();
			Parent     = New File(mParentName);
			IF Parent.Exist() Then
				NewRow.Name       = "..";
				NewRow.FullName = Parent.FullName;
				NewRow.Path      = Parent.Path;
				NewRow.Directory   = Parent.IsDirectory();
				NewRow.Picture  = PictureLib.LevelUp;
			EndIf;
		EndIf;
		
		Files = FindFiles(DirectoryName,"*");
		For Each File In Files Do
			IF NOT ShowHiddenFiles AND (File.GetHidden() Or Left(File.Name,1) = ".") Then
				Continue;
			EndIf;	
			NewRow = VTable.Add();
			NewRow.Name       = File.Name;
			NewRow.FullName = File.FullName;
			NewRow.Path      = File.Path;
			NewRow.Directory   = File.IsDirectory();
		EndDo;	
		
	ElsIf mCatalog.IsFile Then
		
		// Well little if..
		RefreshListTheServerFiles(mCatalog.Path);
		Return;
	EndIf;	
	
	VTable.Sort("Directory DESC Name ASC");
	
	For Each TableRow In VTable Do
		NewRow = ValueTableFiles.Add();
		FillPropertyValues(NewRow,TableRow);
		IF NewRow.Directory Then
			NewRow.Picture = PictureLib.Folder;
		Else
			NewRow.Picture = PictureLib.Document;
		EndIf;	
	EndDo;	
EndProcedure	

&AtClient
Procedure ValueTableFilesChoice(Item, RowSelected, Field, StandardProcessing)
	CurRow = Item.CurrentData;
	IF CurRow = Undefined Then 
		Return;
	EndIf;	
	
	IF CurRow.Directory Then
		mCatalog   = CurRow.FullName;
		RefreshListTheServerFiles(mCatalog);
	Else
		SelectedFileName  = CurRow.Name;
		SelectedFilePath = CurRow.Path;
	EndIf;
EndProcedure

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	SelectedFileName = Parameters.FileName;
	mList          = Items.Disk.ChoiceList;
	
	Information = New SystemInfo();
	IF Information.PlatformType = PlatformType.Windows_x86 OR Information.PlatformType = PlatformType.Windows_x86_64 Then
		Separator = "\";
		Execute("
		|fso = New COMObject (""Scripting.FileSystemObject"");
		|For Each mDisk In fso.Drives Do
		|	IF mDisk.IsReady Then
		|		mList.Add(mDisk.Path);
		|	EndIf;
		|EndDo;
		|");	
		Disk     = mList[0]; 
		mCatalog = mList[0]; 
	Else 
		Separator = "/";
		mCatalogs   = FindFiles("/mnt","*");
		For Each mCatalog In mCatalogs Do
			IF Not mCatalog.Exist() Or Not mCatalog.IsDirectory() Or mCatalog.GetHidden() Then
				Continue;
			EndIf;
			mFullName = Lower(mCatalog.FullName);
			IF Find(mFullName,"sdcard") > 0 Or Find(mFullName,"usbdrive") > 0 Then 
				mList.Add(mCatalog.FullName);
			EndIf;
		EndDo;	
		mList.SortByValue(SortDirection.Asc);
		IF mList.FindByValue("/mnt/sdcard") = Undefined Then
			Disk     = mList[0]; 
			mCatalog = mList[0]; 
		Else	
			Disk     = "/mnt/sdcard"; 
			mCatalog = "/mnt/sdcard";
		EndIf;	
		//Items.Disk.ChoiceList.Add("/mnt");
	EndIf;	
	
	IF Items.Disk.ChoiceList.Count() = 0 Then
		Return;
	EndIf;
	
	RefreshListTheServerFiles(mCatalog);
EndProcedure

// Choose file

&AtClient
Procedure SelectFile(Command)
	IF NOT ValueIsFilled(SelectedFileName) Then
		Return;
	EndIf;	
	Close(Directory + Separator + SelectedFileName);
EndProcedure

&AtClient
Procedure CommandGoto(Command)
	RefreshListTheServerFiles(Directory);
EndProcedure

&AtClient
Procedure DiskOnChange(Item)
	IF ValueIsFilled(Disk) Then
		RefreshListTheServerFiles(Disk);
	EndIf;	
EndProcedure

&AtClient
Procedure ShowHiddenFilesWhenYouChange(Item)
	RefreshListTheServerFiles(Directory);
EndProcedure
