unit FuncData;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, Classes, SysUtils, FormMain, Dialogs, DataModule,
  sqldb, LCLType, db, Globals;

type
  TDBType= (dbtSQLite, dbtMySQL);

type TDBEngine = class
  DBType: TDBType;
  Connection: TSQLConnection;
  DatabasePath: String;
  DatabaseName: String;
  HostName: String;
  UserName: String;
  Password: String;
  TrueValue: String;
  FalseValue: String;
  AutoIncrementKeyword: String;
end;

type
	TIDTable= (wtConfig, wtContractsLog, wtEmployees, wtPicsEmployees, wtTypeContracts, wtPermissions, wtWorkplaces, wtUsers,
  	wtUsergroups);

type TField= record
  Name: String;
  DataFormat: TDataFormat; DataLength: Integer;
  HasDefaultValue: Boolean;
  	DefaultValueQuoted: Boolean;
  	DefaultValue: String;
  PutNull: Boolean;
  	IsNotNull: Boolean;
  IsPrimaryKey: Boolean;
  Autoincrement: Boolean;
  PutNocase: Boolean;
  	Nocase: Boolean;
  IsReferenced: Boolean;
  	ReferenceTable: String;
  	ReferenceField: String;
end;

type TTable = record
  ID: TIDTable;
	Name: String;
  Table: TSQLQuery;
  Datasource: TDatasource;
  FieldsCount: Integer;
	Fields: array of TField;
  FieldsToEditCount: Integer;
  FieldsToEdit: array of String;
  KeyField: String;
end;

type TWriteField = record
	FieldName: String;
	Value: Variant;
  DataFormat: TDataFormat;
end;

var
  DBEngine: TDBEngine;
  Tables: array of TTable;
  WriteFields: array of TWriteField;

function CheckQueryEmpty(Query: TSQLQuery): Boolean;
procedure ConnectDatabase(Databasename: String);
procedure DefineTables;
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
    Result:= True //No records
  else
    Result:= False; //It has results
end;

procedure ConnectDatabase(Databasename: String);
var
  newDatabase: Boolean;
  i, j: Integer;
  SQL: String;
begin
	DBEngine.Connection.DatabaseName:= Databasename;
  DBEngine.Connection.HostName:= DBEngine.HostName;
  DBEngine.Connection.UserName:= DBEngine.UserName;
  //check whether the database already exists
  DefineTables;
  newDatabase:= not FileExists(Databasename);
	if newDatabase then begin //Create the database and the tables
  	try
		DBEngine.Connection.Open;
    //ID_Config INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
    Tables[0].Fields[0].Name:= 'IDConfig';
    	Tables[0].Fields[0].DataFormat:= dtInteger;
		  	Tables[0].Fields[0].DataLength:= 0;
	    Tables[0].Fields[0].HasDefaultValue:=	FALSE;
	    Tables[0].Fields[0].PutNull:= TRUE;
		    Tables[0].Fields[0].IsNotNull:= TRUE;
    	Tables[0].Fields[0].IsPrimaryKey:= TRUE;
	    Tables[0].Fields[0].Autoincrement:= TRUE;
  	  Tables[0].Fields[0].PutNoCase:= FALSE;
  		  Tables[0].Fields[0].NoCase:= FALSE;
	    Tables[0].Fields[0].IsReferenced:= FALSE;
    //DatabaseVersion CHAR(20) DEFAULT ""
    Tables[0].Fields[1].Name:= 'DatabaseVersion';
	    Tables[0].Fields[1].DataFormat:= dtChar;
		  	Tables[0].Fields[1].DataLength:= 20;
    	Tables[0].Fields[1].HasDefaultValue:=	TRUE;
	 	  	Tables[0].Fields[1].DefaultValueQuoted:= TRUE;
			  Tables[0].Fields[1].DefaultValue:= '';
  	  Tables[0].Fields[1].PutNull:= FALSE;
   	 	Tables[0].Fields[1].IsPrimaryKey:= FALSE;
    	Tables[0].Fields[1].Autoincrement:= FALSE;
    	Tables[0].Fields[1].PutNoCase:= FALSE;
    	Tables[0].Fields[1].IsReferenced:= FALSE;
    //CompanyName CHAR(256) DEFAULT ""
    Tables[0].Fields[2].Name:= 'CompanyName';
      Tables[0].Fields[2].DataFormat:= dtChar;
  	  	Tables[0].Fields[2].DataLength:= 255;
      Tables[0].Fields[2].HasDefaultValue:=	TRUE;
  	 	  Tables[0].Fields[2].DefaultValueQuoted:= TRUE;
  		  Tables[0].Fields[2].DefaultValue:= '';
      Tables[0].Fields[2].PutNull:= FALSE;
      Tables[0].Fields[2].IsPrimaryKey:= FALSE;
      Tables[0].Fields[2].Autoincrement:= FALSE;
      Tables[0].Fields[2].PutNoCase:= FALSE;
      Tables[0].Fields[2].IsReferenced:= FALSE;
    //DBEngine INTEGER NOT NULL DEFAULT "0"
    Tables[0].Fields[3].Name:= 'DBEngine';
    	Tables[0].Fields[3].DataFormat:= dtInteger;
      	Tables[0].Fields[3].DataLength:= 0;
      Tables[0].Fields[3].HasDefaultValue:=	TRUE;
      	Tables[0].Fields[3].DefaultValueQuoted:= TRUE;
      	Tables[0].Fields[3].DefaultValue:= '0';
      Tables[0].Fields[3].PutNull:= TRUE;
      	Tables[0].Fields[3].IsNotNull:= TRUE;
      Tables[0].Fields[3].IsPrimaryKey:= FALSE;
      Tables[0].Fields[3].Autoincrement:= FALSE;
      Tables[0].Fields[3].PutNoCase:= FALSE;
      Tables[0].Fields[3].IsReferenced:= FALSE;
    //AtomicCommit INTEGER NOT NULL DEFAULT "1"
    Tables[0].Fields[4].Name:= 'AtomicCommit';
    	Tables[0].Fields[4].DataFormat:= dtInteger;
      	Tables[0].Fields[4].DataLength:= 0;
      Tables[0].Fields[4].HasDefaultValue:=	TRUE;
      	Tables[0].Fields[4].DefaultValueQuoted:= TRUE;
      	Tables[0].Fields[4].DefaultValue:= '1';
      Tables[0].Fields[4].PutNull:= TRUE;
      	Tables[0].Fields[4].IsNotNull:= TRUE;
      Tables[0].Fields[4].IsPrimaryKey:= FALSE;
      Tables[0].Fields[4].Autoincrement:= FALSE;
      Tables[0].Fields[4].PutNoCase:= FALSE;
      Tables[0].Fields[4].IsReferenced:= FALSE;
    //AccessControl BOOLEAN DEFAULT 0
    Tables[0].Fields[5].Name:= 'AccessControl';
    	Tables[0].Fields[5].DataFormat:= dtBoolean;
      	Tables[0].Fields[5].DataLength:= 0;
      Tables[0].Fields[5].HasDefaultValue:=	TRUE;
      	Tables[0].Fields[5].DefaultValueQuoted:= FALSE;
        Tables[0].Fields[5].DefaultValue:= DBEngine.FalseValue;
      Tables[0].Fields[5].PutNull:= FALSE;
      Tables[0].Fields[5].IsPrimaryKey:= FALSE;
      Tables[0].Fields[5].Autoincrement:= FALSE;
      Tables[0].Fields[5].PutNoCase:= FALSE;
      Tables[0].Fields[5].IsReferenced:= FALSE;
    for i:=0 to (0) do //change the second 0 to Length(Tables)-1
    	begin
      SQL:= '';
      SQL:= 'CREATE TABLE '+Tables[i].Name+'(';
      for j:= 0 to (Tables[i].FieldsCount-1) do
        begin
        if (j>0) then
        	SQL:= SQL+', ';
        SQL:= SQL+Tables[i].Fields[j].Name + ' ';
        case Tables[i].Fields[j].DataFormat of
          dtInteger:	SQL:= SQL + 'INTEGER';
          dtChar:	SQL:= SQL + 'CHAR';
          dtBoolean:	SQL:= SQL + 'BOOLEAN';
        end; //case
        if NOT(Tables[i].Fields[j].DataLength= 0) then
        	begin
          SQL:= SQL+'('+IntToStr(Tables[i].Fields[j].DataLength)+')';
          end;
        if (Tables[i].Fields[j].PutNull= TRUE) then
          begin
          if (Tables[i].Fields[j].IsNotNull= TRUE) then
            SQL:= SQL + ' NOT NULL';
          end;
        if (Tables[i].Fields[j].HasDefaultValue= TRUE) then
          begin
          SQL:= SQL + ' DEFAULT ';
          if (Tables[i].Fields[j].DefaultValueQuoted= TRUE) then
          	SQL:= SQL + QuotedStr(Tables[i].Fields[j].DefaultValue)
          	else
            SQL:= SQL + Tables[i].Fields[j].DefaultValue;
          end;
         if (Tables[i].Fields[j].IsPrimaryKey= TRUE) then
           SQL:= SQL + ' PRIMARY KEY';
         if (Tables[i].Fields[j].Autoincrement= TRUE) then
           begin
           SQL:= SQL + ' '+ DBEngine.AutoIncrementKeyword;
           end;
        end; //for 'j'
      SQL:= SQL+');';
      DBEngine.Connection.ExecuteDirect(SQL);
	  	end; //for 'i'
    DBEngine.Connection.ExecuteDirect('INSERT INTO Config ('+
          ' DatabaseVersion, CompanyName, AccessControl)'+
      	  ' VALUES('+QuotedStr(DATABASEVERSION)+', '+QuotedStr('My Company')+', '+DBEngine.FalseValue+
          ');');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE Users('+
          ' ID_User INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_User CHAR('+IntToStr(USERNAME_LENGTH)+') COLLATE NOCASE DEFAULT "",'+
          ' Hash_User CHAR(256) DEFAULT "",'+
          ' Salt_User CHAR(256) DEFAULT "",'+
          ' Usergroup_ID INTEGER DEFAULT NULL'+
          ');');
    DataMod.SQLiteConnection.ExecuteDirect('INSERT INTO Users ('+
          ' Name_User, Hash_User, Salt_User, Usergroup_ID)'+
      	  ' VALUES('+QuotedStr(SUPERUSER_NAME)+', '+QuotedStr(SUPERUSER_PASSWORD)+', '+QuotedStr(SUPERUSER_SALT)+', '+QuotedStr('1')+
          ');');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE Usergroups('+
    			' ID_Usergroup INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_Usergroup CHAR(256) COLLATE NOCASE DEFAULT ""'+
          ');');
    DataMod.SQLiteConnection.ExecuteDirect('INSERT INTO Usergroups ('+
    			' Name_Usergroup)'+
    			' VALUES('+QuotedStr(SUPERUSER_GROUP)+
    			');');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE Permissions('+
    			' ID_Permission INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Usergroup_ID INTEGER REFERENCES Usergroups(ID_Usergroup) ON DELETE CASCADE,'+
          ' EditEmployee_Permission BOOLEAN NOT NULL DEFAULT 1,'+
          ' AddEmployee_Permission BOOLEAN NOT NULL DEFAULT 1,'+
          ' DeleteEmployee_Permission BOOLEAN NOT NULL DEFAULT 0,'+
          ' ShowTabAddress_Permission BOOLEAN NOT NULL DEFAULT 1'+
          ');');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "Perm_id_idx" ON "Permissions"("ID_Permission");');
    DataMod.SQLiteConnection.ExecuteDirect('INSERT INTO Permissions ('+
    			' Usergroup_ID, DeleteEmployee_Permission)'+
    			' VALUES('+QuotedStr('1')+', 1'+
    			');');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE PicsEmployees('+
          ' ID_PicEmployee INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE,'+
          ' Pic_Employee BLOB);');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "Pic_id_idx" ON "PicsEmployees"("ID_PicEmployee");');
		DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE TypeContracts('+
          ' ID_TypeContract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_TypeContract CHAR(256) DEFAULT "");');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "TypeContracts_id_idx" ON "TypeContracts"("ID_TypeContract");');
   	DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE Workplaces('+
          ' ID_Workplace INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Name_Workplace CHAR(256) DEFAULT "");');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "Workplaces_id_idx" ON "Workplaces"("ID_Workplace");');
   	DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE ContractsLog('+
          ' ID_Contract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
          ' Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE,'+
          ' DateInit_Contract DATE,'+
          ' DateEnd_Contract DATE,'+
          ' TypeContract_ID INTEGER DEFAULT NULL,'+
          ' Workplace_ID INTEGER DEFAULT NULL'+
          ' );');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "ContractsLog_id_idx" ON "ContractsLog"("ID_Contract");');
    DataMod.SQLiteConnection.ExecuteDirect('CREATE TABLE Employees('+
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
		DataMod.SQLiteConnection.ExecuteDirect('CREATE UNIQUE INDEX "Employee_id_idx" ON "Employees"("ID_Employee");');
	  DataMod.Transaction.Commit;
    except
    ShowMessage('Unable to create new database');
    end;
  end;
end;

procedure DefineTables;
var
	i: Integer;
begin
  //Amount of Tables
  SetLength(Tables, TABLES_COUNT);
  Tables[0].Name:= 'Config';
  Tables[0].ID:= wtConfig;
  Tables[0].Table:= DataMod.QueConfig;
  Tables[0].Datasource:= DataMod.DsoConfig;
  Tables[0].FieldsCount:= 6;
  Tables[1].Name:= 'Users';
  Tables[1].ID:= wtUsers;
  Tables[1].Table:= DataMod.QueUsers;
  Tables[1].Datasource:= DataMod.DsoUsers;
  Tables[1].FieldsCount:= 5;
  Tables[1].KeyField:= 'ID_User';
  Tables[2].Name:= 'Usersgroups';
  Tables[2].Table:= DataMod.QueUsergroups;
  Tables[2].Datasource:= DataMod.DsoUsergroups;
  Tables[2].ID:= wtUsergroups;
  Tables[2].FieldsCount:= 2;
  Tables[3].Name:= 'Permissions';
  Tables[3].ID:= wtPermissions;
  Tables[3].Table:= DataMod.QuePermissions;
  Tables[3].Datasource:= DataMod.DsoPermissions;
  Tables[3].FieldsCount:= 6;
  Tables[4].Name:= 'PicsEmployees';
  Tables[4].ID:= wtPicsEmployees;
  Tables[4].Table:= DataMod.QuePicsEmployees;
  Tables[4].Datasource:= DataMod.DsoPicsEmployees;
  Tables[4].FieldsCount:= 3;
  Tables[5].Name:= 'TypeContracts';
  Tables[5].ID:= wtTypeContracts;
  Tables[5].Table:= DataMod.QueTypeContracts;
  Tables[5].Datasource:= DataMod.DsoTypeContracts;
  Tables[5].KeyField:= 'ID_TypeContract';
  Tables[5].FieldsCount:= 2;
  Tables[6].Name:= 'Workplaces';
  Tables[6].Table:= DataMod.QueWorkplaces;
  Tables[6].Datasource:= DataMod.DsoWorkplaces;
  Tables[6].ID:= wtWorkplaces;
  Tables[6].FieldsCount:= 2;
  Tables[6].KeyField:= 'ID_Workplace';
  Tables[7].Name:= 'ContractsLog';
  Tables[7].Table:= DataMod.QueContractsLog;
  Tables[7].Datasource:= DataMod.DsoContractsLog;
  Tables[7].ID:= wtContractsLog;
  Tables[7].FieldsCount:= 6;
  Tables[8].Name:= 'Employees';
  Tables[8].ID:= wtEmployees;
  Tables[8].Table:= DataMod.QueEmployees;
  Tables[8].Datasource:= DataMod.DsoEmployees;
  Tables[8].FieldsCount:= 6;
  Tables[8].KeyField:= 'ID_Employee';
  for i:= 0 to (TABLES_COUNT-1) do
  	SetLength(Tables[0].Fields, Tables[0].FieldsCount);
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
 	if (BookmarkPos= TRUE) then
    Table.RecNo:= Bookmark;
  SQLSentence.Free;
  Result:= True;
end;

function CheckValueExists(Table, Field, Value: String; NoCase: Boolean=FALSE;
         FieldNoThis: String=''; ValueNoThis: String=''): Boolean;
var
	Query: TSQLQuery;
begin
  Query:= TSQLQuery.Create(nil);
  Query.DataBase:= DataMod.SQLiteConnection;
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

