unit FuncData;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, Classes, SysUtils, FormMain, Dialogs, DataModule,
  sqldb, LCLType, db, Globals;

type TWriteField = record
    FieldName: String;
    Value: Variant;
    DataFormat: TDataFormat;
end;
var
  WriteFields: array of TWriteField;

function CheckQueryEmpty(Query: TSQLQuery): Boolean;
procedure ConnectDatabase(Databasename: String);
function DeleteTableRecord(Query: TSQLQuery; Confirm: Boolean=False;
         Target: String=''): Boolean;
function DeleteRecordSQL(Table: TSQLQuery; TableName, KeyField, KeyValue: String; Target: String='';Confirm: Boolean=False): Boolean;
procedure ExecSQL(Query: TSQLQuery; SQL: String; IsStrLst: Boolean=False; StrLst: TStringList=nil);
function AppendTableRecord(Query: TSQLQuery; WriteFields: array of TWriteField): Boolean;
function EditTableRecord(Query: TSQLQuery; WriteFields: array of TWriteField): Boolean;
function InsertSQL(Table: TSQLQuery; TableName: String; WriteFields: array of TWriteField): Boolean;
procedure SaveTable(Query: TSQLQuery);
procedure UpdateRecord(Query: TSQLQuery; FieldName, Value: Variant; DataFormat: TDataFormat);
function UpdateSQL(Table: TSQLQuery; TableName, KeyField, KeyValue: String; WriteFields: array of TWriteField; BookmarkPos: Boolean): Boolean;
function CheckValueExists(Table, Field, Value: String; NoCase: Boolean=FALSE;
         FieldNoThis: String=''; ValueNoThis: String=''): Boolean;

resourcestring
  DelRec_Title= 'Deletion';
	DelRec_Msg_01= 'Are you sure you want to DELETE';
  DelRec_Msg_02= 'It cannot revert!';
  DelRec_Msg_03= 'There is not anything to eliminate.';

implementation

function CheckQueryEmpty(Query: TSQLQuery): Boolean;
begin
	if Query.Eof then
    begin
    Result:= True; //No records
    end
    else
    begin
    Result:= False; //It has results
    end;
end;

procedure ConnectDatabase(Databasename: String);
var
  newDatabase: Boolean;
begin
  DataMod.Connection.DatabaseName:= Databasename;
  //DataMod.Connection.Transaction:= DataMod.Transaction;
  //DataMod.Transaction.DataBase:= DataMod.Connection;
  //check whether the database already exists
  newDatabase:= not FileExists(Databasename);
	if newDatabase then begin //Create the database and the tables
  	try
    DataMod.Connection.Open;
    DataMod.Transaction.Active:= TRUE;
    // Here we're setting up a table named "DATA" in the new database
    DataMod.Connection.ExecuteDirect('CREATE TABLE Config('+
          ' ID_Config INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' DatabaseVersion CHAR(20) DEFAULT "",'+
          ' CompanyName CHAR(256) DEFAULT "",'+
          ' AtomicCommit INTEGER NOT NULL DEFAULT "1",'+
          ' AccessControl BOOLEAN DEFAULT FALSE'+
          ');');
    DataMod.Connection.ExecuteDirect('INSERT INTO Config ('+
          ' DatabaseVersion, CompanyName, AccessControl)'+
      	  ' VALUES('+QuotedStr(DATABASEVERSION)+', ''My Company'''+', ''0'''+
          ');');
    DataMod.Connection.ExecuteDirect('CREATE TABLE Users('+
          ' ID_User INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_User CHAR('+IntToStr(USERNAME_LENGTH)+') COLLATE NOCASE DEFAULT "",'+
          ' Hash_User CHAR(256) DEFAULT "",'+
          ' Salt_User CHAR(256) DEFAULT "",'+
          ' Usergroup_ID INTEGER DEFAULT NULL'+
          ');');
    DataMod.Connection.ExecuteDirect('INSERT INTO Users ('+
          ' Name_User, Hash_User, Salt_User, Usergroup_ID)'+
      	  ' VALUES('+QuotedStr(SUPERUSER_NAME)+', '+QuotedStr(SUPERUSER_PASSWORD)+', '+QuotedStr(SUPERUSER_SALT)+', '+QuotedStr('1')+
          ');');
    DataMod.Connection.ExecuteDirect('CREATE TABLE Usergroups('+
    			' ID_Usergroup INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_Usergroup CHAR(256) COLLATE NOCASE DEFAULT ""'+
          ');');
    DataMod.Connection.ExecuteDirect('INSERT INTO Usergroups ('+
    			' Name_Usergroup)'+
    			' VALUES('+QuotedStr(SUPERUSER_GROUP)+
    			');');
    DataMod.Connection.ExecuteDirect('CREATE TABLE Permissions('+
    			' ID_Permission INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Usergroup_ID INTEGER REFERENCES Usergroups(ID_Usergroup) ON DELETE CASCADE,'+
          ' EditEmployee_Permission BOOLEAN NOT NULL DEFAULT FALSE,'+
          ' AddEmployee_Permission BOOLEAN NOT NULL DEFAULT FALSE,'+
          ' DeleteEmployee_Permission BOOLEAN NOT NULL DEFAULT FALSE,'+
          ' ShowTabAddress_Permission BOOLEAN NOT NULL DEFAULT FALSE'+
          ');');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Perm_id_idx" ON "Permissions"("ID_Permission");');
    DataMod.Connection.ExecuteDirect('INSERT INTO Permissions ('+
    			' Usergroup_ID, EditEmployee_Permission)'+
    			' VALUES('+QuotedStr('1')+', ''1'''+
    			');');
    DataMod.Connection.ExecuteDirect('CREATE TABLE PicsEmployees('+
          ' ID_PicEmployee INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE,'+
          ' Pic_Employee BLOB);');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Pic_id_idx" ON "PicsEmployees"("ID_PicEmployee");');
		DataMod.Connection.ExecuteDirect('CREATE TABLE TypeContracts('+
          ' ID_TypeContract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_TypeContract CHAR(256) DEFAULT "");');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "TypeContracts_id_idx" ON "TypeContracts"("ID_TypeContract");');
   	DataMod.Connection.ExecuteDirect('CREATE TABLE Workplaces('+
          ' ID_Workplace INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_Workplace CHAR(256) DEFAULT "");');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Workplaces_id_idx" ON "Workplaces"("ID_Workplace");');
   	DataMod.Connection.ExecuteDirect('CREATE TABLE ContractsLog('+
          ' ID_Contract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE,'+
          ' DateInit_Contract DATE,'+
          ' DateEnd_Contract DATE,'+
          ' TypeContract_ID INTEGER DEFAULT NULL,'+
          ' Workplace_ID INTEGER DEFAULT NULL'+
          ' );');
    DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "ContractsLog_id_idx" ON "ContractsLog"("ID_Contract");');
    DataMod.Connection.ExecuteDirect('CREATE TABLE Employees('+
          ' ID_Employee INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Active_Employee BOOLEAN NOT NULL DEFAULT TRUE,'+
          ' IDN_Employee CHAR(256) NOT NULL DEFAULT "",'+
          ' Name_Employee CHAR(256) COLLATE NOCASE DEFAULT "",'+
          ' Surname1_Employee CHAR(256) COLLATE NOCASE DEFAULT "",'+
          ' Surname2_Employee CHAR(256) COLLATE NOCASE DEFAULT "",'+
          ' IDCard_Employee CHAR(256) DEFAULT "",'+
          ' SSN_Employee CHAR(256) DEFAULT "",'+
    	    ' Address_Employee MEMO(8192) COLLATE NOCASE DEFAULT "",'+
       	  ' City_Employee CHAR(256) COLLATE NOCASE DEFAULT "",'+
       	  ' State_Employee CHAR(256) COLLATE NOCASE DEFAULT "",'+
       	  ' ZIPCode_Employee CHAR(256) DEFAULT "",'+
       	  ' Phone_Employee CHAR(256) DEFAULT "",'+
       	  ' Cell_Employee CHAR(256) DEFAULT "",'+
          ' EMail_Employee CHAR(256) DEFAULT "",'+
          ' DateBirth_Employee DATE DEFAULT NULL,'+
          ' Genre_Employee BOOLEAN DEFAULT NULL,'+
          ' MaritalStatus_Employee BOOLEAN DEFAULT NULL,'+
          ' Remarks_Employee MEMO(8152) COLLATE NOCASE DEFAULT "",'+
          ' DateInit_Contract DATE DEFAULT NULL,'+
          ' DateEnd_Contract DATE DEFAULT NULL,'+
          ' TypeContract_ID INTEGER COLLATE NOCASE DEFAULT NULL,'+
          ' Workplace_ID INTEGER COLLATE NOCASE DEFAULT NULL'+
          ' );');
    //Creating an index based upon id in the DATA Table
		DataMod.Connection.ExecuteDirect('CREATE UNIQUE INDEX "Employee_id_idx" ON "Employees"("ID_Employee");');
	  DataMod.Transaction.Commit;
    except
    ShowMessage('Unable to create new database');
    end;
  end;
end;
function DeleteTableRecord(Query: TSQLQuery; Confirm: Boolean=False; Target: String=''): Boolean;
var
  ConfirmDel, Style: Integer;
  Msg: PChar;
begin
  if Confirm= True then
    begin
    Style:= MB_OKCANCEL + MB_ICONEXCLAMATION;
    Msg:= PChar(DelRec_Msg_01+' '+Target+'?'#13+DelRec_Msg_02);
    ConfirmDel:= Application.MessageBox(Msg, PChar(DelRec_Title), Style);
    end
  	else ConfirmDel:= IDOK;
  case ConfirmDel of
   	IDOK: begin
    			try
   				Query.Delete;
       	  Query.ApplyUpdates;
         	DataMod.Transaction.CommitRetaining;
					Result:= True;
          except
					Result:= False;
          end;
          end;
    IDCANCEL: begin
     					Result:= False;
          		Exit;
              end;
  end; //case
end;
function DeleteRecordSQL(Table: TSQLQuery; TableName, KeyField, KeyValue: String; Target: String='';Confirm: Boolean=False): Boolean;
var
	SQLSentence: TStringList;
  ConfirmDel, Style, Bookmark: Integer;
  Msg: PChar;
begin
	if (CheckQueryEmpty(Table)= True) then
		begin
		Style:= MB_OK + MB_ICONERROR;
		Application.MessageBox(PChar(DelRec_Msg_03), PChar(DelRec_Title), Style);
		Result:= False;
		Exit;
		end;
  if Confirm= True then
    begin
    Style:= MB_OKCANCEL + MB_ICONEXCLAMATION;
    Msg:= PChar(DelRec_Msg_01+' '+Target+'?'#13+DelRec_Msg_02);
    ConfirmDel:= Application.MessageBox(Msg, PChar(DelRec_Title), Style);
    end
  	else ConfirmDel:= IDOK;
  case ConfirmDel of
   	IDOK: begin
      			try
            DataMod.QueVirtual.Close;
            DataMod.QueVirtual.SQL.Clear;
            SQLSentence:= TStringList.Create;
            SQLSentence.Add('DELETE FROM '+ TableName);
            SQLSentence.Add('WHERE ('+KeyField+'="'+KeyValue+'");');
            DataMod.QueVirtual.SQL.Assign(SQLSentence);
            Bookmark:= Table.RecNo;
            DataMod.QueVirtual.ExecSQL;
            DataMod.Transaction.CommitRetaining;
          	SQLSentence.Free;
            Table.Refresh;
            Table.RecNo:= Bookmark-1;
  					Result:= True;
            except
  					Result:= False;
            end;
            end;
      IDCANCEL: begin
       					Result:= False;
            		Exit;
                end;
    end; //case
end;

function EditTableRecord(Query: TSQLQuery; WriteFields: array of TWriteField): Boolean;
var
  i: Integer;
begin
  Query.Edit;
  for i:= Low(WriteFields) to High(WriteFields) do
  	begin
    case WriteFields[i].DataFormat of
			dtString: Query.FieldByName(WriteFields[i].FieldName).AsString:= WriteFields[i].Value;
 			dtInteger: Query.FieldByName(WriteFields[i].FieldName).AsInteger:= WriteFields[i].Value;
      dtDate: Query.FieldByName(WriteFields[i].FieldName).AsDateTime:= WriteFields[i].Value;
      dtBoolean: Query.FieldByName(WriteFields[i].FieldName).AsBoolean:= WriteFields[i].Value;
    end; //case
    end;
  Query.Post;
  Query.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  Result:= True;
end;

procedure ExecSQL(Query: TSQLQuery; SQL: String; IsStrLst: Boolean=False; StrLst: TStringList=nil);
begin
  Query.Close;
  Query.SQL.Clear;
  if IsStrLst= False then
	  Query.SQL.Add(SQL)
	else
    begin
    Query.SQL.Assign(StrLst);
    StrLst.Free;
    end;
	Query.Open;
  DataMod.Transaction.CommitRetaining;
end;

function AppendTableRecord(Query: TSQLQuery; WriteFields: array of TWriteField): Boolean;
var
  i: Integer;
begin
  Query.Append;
  for i:= Low(WriteFields) to High(WriteFields) do
  	begin
    case WriteFields[i].DataFormat of
			dtString: Query.FieldByName(WriteFields[i].FieldName).AsString:= WriteFields[i].Value;
 			dtInteger: Query.FieldByName(WriteFields[i].FieldName).AsInteger:= WriteFields[i].Value;
 			dtBoolean: Query.FieldByName(WriteFields[i].FieldName).AsBoolean:= WriteFields[i].Value;
      dtDate: Query.FieldByName(WriteFields[i].FieldName).AsDateTime:= WriteFields[i].Value;
    end; //case
    end;
  Query.Post;
  Query.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  //Query.Refresh;
  //DataMod.Transaction.CommitRetaining;
  Query.Last;
  Result:= True;
end;

function InsertSQL(Table: TSQLQuery; TableName: String; WriteFields: array of TWriteField): Boolean;
var
  i, Bookmark: Integer;
	SQLSentence: TStringList;
  ValueStr: String;
begin
  DataMod.QueVirtual.Close;
  DataMod.QueVirtual.SQL.Clear;
 	SQLSentence:= TStringList.Create;
  SQLSentence.Add('INSERT INTO '+ TableName);
  SQLSentence.Add('(');
  for i:= Low(WriteFields) to High(WriteFields) do
   	begin
    SQLSentence.Strings[1]:= SQLSentence.Strings[1]+WriteFields[i].FieldName;
    if i<High(WriteFields) then
    	SQLSentence.Strings[1]:= SQLSentence.Strings[1]+','
    else
      SQLSentence.Strings[1]:= SQLSentence.Strings[1]+')';
    end; //for
  SQLSentence.Add('VALUES(');
  for i:= Low(WriteFields) to High(WriteFields) do
   	begin
    case WriteFields[i].DataFormat of
      dtString: ValueStr:= WriteFields[i].Value;
      dtInteger: ValueStr:= IntToStr(WriteFields[i].Value);
      dtDate: ValueStr:= FormatDateTime('yyyy"-"mm"-"dd"',WriteFields[i].Value);
      dtBoolean: ValueStr:= BoolToStr(WriteFields[i].Value);
      dtNull: ValueStr:= 'NULL';
    end; //case
    SQLSentence.Strings[2]:= SQLSentence.Strings[2]+'"'+ValueStr+'"';
    if i<High(WriteFields) then
    	SQLSentence.Strings[2]:= SQLSentence.Strings[2]+','
    else
      SQLSentence.Strings[2]:= SQLSentence.Strings[2]+')';
    end; //for
  DataMod.QueVirtual.SQL.Assign(SQLSentence);
  DataMod.QueVirtual.ExecSQL;
  Table.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  SQLSentence.Free;
  Table.Last;
  Bookmark:= Table.RecNo;
  Table.Refresh;
  Table.RecNo:= Bookmark+1;
  Result:= TRUE;
end;

procedure SaveTable(Query: TSQLQuery);
var
	SubstringPos: Integer;
begin
  Screen.Cursor:= crHourGlass;
  try
  Query.ApplyUpdates;
  except
  on E: EUpdateError do
  	begin
    SubstringPos:= Pos('UNIQUE constraint failed', E.Message);
    if SubstringPos>0 then
      ShowMessage('The ID# of an employee is not unique.')
    else
	  	ShowMessage('Exception class name = '+E.ClassName);
  	  ShowMessage('Exception message = '+E.Message);
    end;
  end;
  DataMod.Transaction.CommitRetaining;
  Screen.Cursor:= crDefault;
end;

procedure UpdateRecord(Query: TSQLQuery; FieldName, Value: Variant; DataFormat: TDataFormat);
begin
  Query.Edit;
  case DataFormat of
		dtString: Query.FieldByName(FieldName).AsString:= Value;
 		dtInteger: Query.FieldByName(FieldName).AsInteger:= StrToInt(Value);
 		dtBoolean: Query.FieldByName(FieldName).AsBoolean:= StrToBool(Value);
		dtDate: Query.FieldByName(FieldName).AsDateTime:= StrToDate(Value);
  end;
  Query.Post;
  Query.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  Query.Refresh;
  DataMod.Transaction.CommitRetaining;
end;

function UpdateSQL(Table: TSQLQuery; TableName, KeyField, KeyValue: String; WriteFields: array of TWriteField; BookmarkPos: Boolean): Boolean;
var
  i, Bookmark: Integer;
	SQLSentence: TStringList;
  ValueStr: String;
begin
  DataMod.QueVirtual.Close;
  DataMod.QueVirtual.SQL.Clear;
 	SQLSentence:= TStringList.Create;
  SQLSentence.Add('UPDATE '+ TableName);
  SQLSentence.Add('SET ');
  for i:= Low(WriteFields) to High(WriteFields) do
   	begin
    case WriteFields[i].DataFormat of
      dtString: ValueStr:= WriteFields[i].Value;
      dtInteger: ValueStr:= IntToStr(WriteFields[i].Value);
      dtDate: ValueStr:= FormatDateTime('yyyy"-"mm"-"dd"',WriteFields[i].Value);
      dtBoolean: ValueStr:= BoolToStr(WriteFields[i].Value);
      dtNull: ValueStr:= 'NULL';
    end; //case
    SQLSentence.Strings[1]:= SQLSentence.Strings[1]+WriteFields[i].FieldName+'='+
    	'"'+ValueStr+'"';
    if i<High(WriteFields) then
    	SQLSentence.Strings[1]:= SQLSentence.Strings[1]+',';
  	end; //for
  SQLSentence.Add('WHERE ('+KeyField+'="'+KeyValue+'");');
  if (BookmarkPos= TRUE) then Bookmark:= Table.RecNo;
  DataMod.QueVirtual.SQL.Assign(SQLSentence);
  DataMod.QueVirtual.ExecSQL;
  Table.ApplyUpdates;
  DataMod.Transaction.CommitRetaining;
  Table.Refresh;
 	if (BookmarkPos= TRUE) then Table.RecNo:= Bookmark;
  SQLSentence.Free;
  Result:= True;
end;

function CheckValueExists(Table, Field, Value: String; NoCase: Boolean=FALSE;
         FieldNoThis: String=''; ValueNoThis: String=''): Boolean;
var
	Query: TSQLQuery;
begin
  Query:= TSQLQuery.Create(nil);
  Query.DataBase:= DataMod.Connection;
  try
    Query.SQL.Add('SELECT 1 FROM '+Table+' WHERE ('+Field+'= '+ QuotedStr(Value)+')');
		if FieldNoThis<>'' then
      begin
	    Query.SQL.Add('AND NOT ('+FieldNoThis+'='+ValueNoThis+')');
      end;
    if NoCase= TRUE then
      begin
			Query.SQL.Add('COLLATE NOCASE');
      end;
    Query.Active:= True;
    Result:= not Query.IsEmpty;
    Query.Active:= False;
  finally
  	FreeAndNil(Query);
  end;
end;
end.

