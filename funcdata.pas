unit FuncData;

{$mode objfpc}{$H+}

interface

uses
  Forms, Controls, Classes, SysUtils, Dialogs, DataModule,
  sqldb, LCLType, db, Globals;

type
	TIDTable= (wtConfig, wtContractsLog, wtEmployees, wtPicsEmployees, wtTypeContracts,
  wtPermissions, wtWorkplaces, wtUsers, wtUsergroups);

type
  TDBType= (dbtSQLite, dbtMySQL);

type
  TFKReferentialAction= (fkOnDelete, fkOnUpdate);

type
  TFKReferenceOption= (fkRestrict, fkCascade, fkSetNull, fkNoAction);

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
  PutCase: Boolean;
  	_Case: Boolean;
  IsForeignKey: Boolean;
  	FK_ParentTable: String;
  	FK_ParentField: String;
  	FK_ReferentialAction: TFKReferentialAction;
  	FK_ReferenceOption: TFKReferenceOption;
end;

type TTable = record
  ID: TIDTable;
	Name: String;
  Table: TSQLQuery;
  Datasource: TDatasource;
	Fields: array of TField;
  FieldsCount: Integer;
  FieldsToEdit: array of String;
  FieldsToEditCount: Integer;
  KeyField: String;
end;

type TDBEngine = class
  ID: Integer;
  DBType: TDBType;
  Connection: TSQLConnection;
  DatabasePath: String;
  DatabaseName: String;
  DatabaseVersion: String;
  Tables: array of TTable;
  TablesCount: Integer;
  HostName: String;
  UserName: String;
  Password: String;
  TrueValue: String;
  FalseValue: String;
  AutoIncrementKeyword: String;
end;

type TWriteField = record
	FieldName: String;
	Value: Variant;
  DataFormat: TDataFormat;
end;

var
  DBEngine: TDBEngine;
  WriteFields: array of TWriteField;

procedure AssignDatabase;
function CheckQueryEmpty(Query: TSQLQuery): Boolean;
procedure ConfigureDBEngine;
procedure ConnectDatabase(Databasename: String);
procedure DefineFields;
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
  lg_DatabaseNotExist= 'Database does not exist.';
  lg_CannotConnectDatabase= 'Database cannot be connected.';
  DelRec_Title= 'Deletion';
	DelRec_Msg_01= 'Are you sure you want to DELETE';
  DelRec_Msg_02= 'It cannot revert!';
  DelRec_Msg_03= 'There is not anything to eliminate.';
  Error_DatabaseName_Blank= 'Database name is blank!';


implementation

uses FormPreferences, FormPrgBar;

procedure ConfigureDBEngine;
begin
  FrmPreferences:= TFrmPreferences.Create(nil);
  FrmPreferences.LstTreePreferences.Visible:= False;
  FrmPreferences.Width:= FrmPreferences.Width-FrmPreferences.LstTreePreferences.Width;
  FrmPreferences.FraClose1.BtnClose.Left:= FrmPreferences.FraClose1.BtnClose.Left-Round(FrmPreferences.LstTreePreferences.Width/2);
  FrmPreferences.PagPreferences.TabIndex:= 2;
  FrmPreferences.DbLkCboAtomicCommit.Enabled:= False;
  FrmPreferences.ShowModal;
end;

procedure AssignDatabase;
var
  i: Integer;
begin
  for i:= (DataMod.ComponentCount - 1) downto 0 do
  begin
    if DataMod.Components[i] is TSQLQuery then
      TSQLQuery(DataMod.Components[i]).DataBase:= DBEngine.Connection;
  end;
end;

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
  ErrorMsg: String;
 	PrgBar: TFrmPrgBar;
begin
  AssignDatabase;
  DefineTables;
	DefineFields;
	DBEngine.Connection.DatabaseName:= Databasename;
  DBEngine.Connection.HostName:= DBEngine.HostName;
  DBEngine.Connection.UserName:= DBEngine.UserName;
  //Check whether the database already exists or not
  case DBEngine.DBType of
    dbtSQLite: newDatabase:= not FileExists(Databasename);
  end; //case
  //The progress bar to show the database creation or load:
  Screen.Cursor:= crHourglass;
	PrgBar:= TFrmPrgBar.Create(nil);
	PrgBar.ShowOnTop;
  PrgBar.LblPrg.Caption:= 'Connecting database...';
  PrgBar._PrgBar.Position:= 50;
  try
  	DBEngine.Connection.Open;
  except
  	on E: ESQLDatabaseError do
    	begin
      i:= E.ErrorCode;
      case E.ErrorCode of
        2003: Errormsg:= lg_CannotConnectDatabase+': '+E.Message;
        1049:	Errormsg:= lg_DatabaseNotExist+': '+E.Message;
        end; //case
      ShowMessage(ErrorMsg);
      ConfigureDBEngine;
   	  Application.Terminate;
      Exit;
      end;
  end;
	if newDatabase then begin //Create the database and the tables
  	try
    //Connect & Load to database
		//Announce the Database creation
 		//Define Fields
    PrgBar.LblPrg.Caption:= 'Creating databases...';
    PrgBar._PrgBar.Position:= 50;
    for i:=0 to (DBEngine.TablesCount-1) do
    	begin
      SQL:= '';
      SQL:= 'CREATE TABLE '+DBEngine.Tables[i].Name+'(';
      for j:= 0 to ((Length(DBEngine.Tables[i].Fields))-1) do
        begin
        if (j>0) then
        	SQL:= SQL+', ';
        SQL:= SQL + DBEngine.Tables[i].Fields[j].Name + ' ';
        case DBEngine.Tables[i].Fields[j].DataFormat of
          dtInteger:	SQL:= SQL + 'INTEGER';
          dtChar:	SQL:= SQL + 'CHAR';
          dtBoolean:	SQL:= SQL + 'BOOLEAN';
          dtDate:	SQL:= SQL + 'DATE';
          dtText:	SQL:= SQL + 'TEXT';
          dtBlob:	SQL:= SQL + 'BLOB';
        end; //case
        if NOT(DBEngine.Tables[i].Fields[j].DataLength= 0) then
        	begin
          SQL:= SQL+'('+IntToStr(DBEngine.Tables[i].Fields[j].DataLength)+')';
          end;
        if (DBEngine.Tables[i].Fields[j].PutNull= TRUE) then
          begin
          if (DBEngine.Tables[i].Fields[j].IsNotNull= TRUE) then
            SQL:= SQL + ' NOT NULL';
          end;
        if (DBEngine.Tables[i].Fields[j].HasDefaultValue= TRUE) then
          begin
          SQL:= SQL + ' DEFAULT ';
          if (DBEngine.Tables[i].Fields[j].DefaultValueQuoted= TRUE) then
          	SQL:= SQL + QuotedStr(DBEngine.Tables[i].Fields[j].DefaultValue)
          	else
            SQL:= SQL + DBEngine.Tables[i].Fields[j].DefaultValue;
          end;
        if (DBEngine.Tables[i].Fields[j].PutCase= TRUE) then
        	begin
          case (DBEngine.Tables[i].Fields[j]._Case) of
            FALSE:	begin
				      	  	case DBEngine.DBType of
    	  				    	dbtSQLite:	SQL:= SQL + ' COLLATE NOCASE';
					          end; //case
                    end;
            TRUE:	begin
          					case DBEngine.DBType of
    	  				    	dbtSQLite:	SQL:= SQL + ' COLLATE BINARY';
                      dbtMYSQL:	SQL:= SQL + ' COLLATE '+MYSQL_COLLATION;
					          end; //case
            			end;
          end; //case
          end;
        if (DBEngine.Tables[i].Fields[j].IsPrimaryKey= TRUE) then
           SQL:= SQL + ' PRIMARY KEY'
        else if (DBEngine.Tables[i].Fields[j].IsForeignKey= TRUE) then
          begin
          SQL:= SQL + ' REFERENCES '+DBEngine.Tables[i].Fields[j].FK_ParentTable+'('+DBEngine.Tables[i].Fields[j].FK_ParentField+')';
        	case DBEngine.Tables[i].Fields[j].FK_ReferentialAction of
           	fkOnDelete:	SQL:= SQL + ' ON DELETE';
            fkOnUpdate:	SQL:= SQL + ' ON UPDATE';
          end; //case
          case DBEngine.Tables[i].Fields[j].FK_ReferenceOption of
           	fkCascade:	SQL:= SQL + ' CASCADE';
          end; //case
          end;
        if (DBEngine.Tables[i].Fields[j].Autoincrement= TRUE) then
        	begin
          SQL:= SQL + ' '+ DBEngine.AutoIncrementKeyword;
          end;
        end; //for 'j'
      SQL:= SQL+');';
      DBEngine.Connection.ExecuteDirect(SQL);
	  	end; //for 'i'
    PrgBar.LblPrg.Caption:= 'Populating databases...';
    PrgBar._PrgBar.Position:= 90;
    DBEngine.Connection.ExecuteDirect('INSERT INTO Config ('+
          ' DatabaseVersion, CompanyName, AccessControl)'+
      	  ' VALUES('+QuotedStr(DATABASE_DEFAULT_VERSION)+', '+QuotedStr('My Company')+', '+DBEngine.FalseValue+
          ');');
    DBEngine.Connection.ExecuteDirect('INSERT INTO Usergroups ('+
    			' Name_Usergroup)'+
    			' VALUES('+QuotedStr(SUPERUSER_GROUP)+
    			');');
    DBEngine.Connection.ExecuteDirect('INSERT INTO Users ('+
          ' Name_User, Hash_User, Salt_User, Usergroup_ID)'+
      	  ' VALUES('+QuotedStr(SUPERUSER_NAME)+', '+QuotedStr(SUPERUSER_PASSWORD)+', '+QuotedStr(SUPERUSER_SALT)+', '+QuotedStr('1')+
          ');');
    DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX Perm_id_idx ON Permissions(ID_Permission);');
    DBEngine.Connection.ExecuteDirect('INSERT INTO Permissions ('+
    			' Usergroup_ID, EditEmployee_Permission, AddEmployee_Permission, DeleteEmployee_Permission, ShowTabAddress_Permission, AdminControlAccess_Permission, AdminDatabase_Permission)'+
    			' VALUES('+QuotedStr('1')+', '+DBEngine.TrueValue+', '+DBEngine.TrueValue+', '+DBEngine.TrueValue+', '+DBEngine.TrueValue+', '+DBEngine.TrueValue+', '+DBEngine.TrueValue+
    			');');
    DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX Pic_id_idx ON PicsEmployees(ID_PicEmployee);');
    DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX TypeContracts_id_idx ON TypeContracts(ID_TypeContract);');
    DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX Workplaces_id_idx ON Workplaces(ID_Workplace);');
    DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX ContractsLog_id_idx ON ContractsLog(ID_Contract);');
		DBEngine.Connection.ExecuteDirect('CREATE UNIQUE INDEX Employee_id_idx ON Employees(ID_Employee);');
	  DataMod.Transaction.Commit;
    except
    ShowMessage('Unable to create new database');
    end;
  end;
	FreeAndNil(PrgBar);
  Screen.Cursor:= crDefault;
end;

procedure DefineFields;
begin
  //Table 'Config'
  //ID_Config INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
   DBEngine.Tables[0].Fields[0].Name:= 'ID_Config';
   	DBEngine.Tables[0].Fields[0].DataFormat:= dtInteger;
     DBEngine.Tables[0].Fields[0].PutNull:= TRUE;
 	    DBEngine.Tables[0].Fields[0].IsNotNull:= TRUE;
   	DBEngine.Tables[0].Fields[0].IsPrimaryKey:= TRUE;
     DBEngine.Tables[0].Fields[0].Autoincrement:= TRUE;
   //DatabaseVersion CHAR(20) DEFAULT DATABASE_DEFAULT_VERSION
   DBEngine.Tables[0].Fields[1].Name:= 'DatabaseVersion';
    DBEngine.Tables[0].Fields[1].DataFormat:= dtChar;
 	  	DBEngine.Tables[0].Fields[1].DataLength:= 20;
   	DBEngine.Tables[0].Fields[1].HasDefaultValue:= TRUE;
  		DBEngine.Tables[0].Fields[1].DefaultValueQuoted:= TRUE;
 		  DBEngine.Tables[0].Fields[1].DefaultValue:= DATABASE_DEFAULT_VERSION;
   //CompanyName CHAR(255) DEFAULT ""
   DBEngine.Tables[0].Fields[2].Name:= 'CompanyName';
     DBEngine.Tables[0].Fields[2].DataFormat:= dtChar;
 	  	DBEngine.Tables[0].Fields[2].DataLength:= 255;
     DBEngine.Tables[0].Fields[2].HasDefaultValue:=	TRUE;
 	 	  DBEngine.Tables[0].Fields[2].DefaultValueQuoted:= TRUE;
 		  DBEngine.Tables[0].Fields[2].DefaultValue:= '';
   //DBEngine INTEGER NOT NULL DEFAULT "0"
   DBEngine.Tables[0].Fields[3].Name:= 'DBEngine';
   	DBEngine.Tables[0].Fields[3].DataFormat:= dtInteger;
    DBEngine.Tables[0].Fields[3].HasDefaultValue:=	TRUE;
     	DBEngine.Tables[0].Fields[3].DefaultValueQuoted:= TRUE;
     	DBEngine.Tables[0].Fields[3].DefaultValue:= '0';
    DBEngine.Tables[0].Fields[3].PutNull:= TRUE;
     	DBEngine.Tables[0].Fields[3].IsNotNull:= TRUE;
   //AtomicCommit INTEGER NOT NULL DEFAULT "1"
   DBEngine.Tables[0].Fields[4].Name:= 'AtomicCommit';
   	DBEngine.Tables[0].Fields[4].DataFormat:= dtInteger;
     DBEngine.Tables[0].Fields[4].HasDefaultValue:=	TRUE;
     	DBEngine.Tables[0].Fields[4].DefaultValueQuoted:= TRUE;
     	DBEngine.Tables[0].Fields[4].DefaultValue:= '1';
     DBEngine.Tables[0].Fields[4].PutNull:= TRUE;
     	DBEngine.Tables[0].Fields[4].IsNotNull:= TRUE;
   //AccessControl BOOLEAN DEFAULT 0
   DBEngine.Tables[0].Fields[5].Name:= 'AccessControl';
   	DBEngine.Tables[0].Fields[5].DataFormat:= dtBoolean;
     DBEngine.Tables[0].Fields[5].HasDefaultValue:=	TRUE;
     	DBEngine.Tables[0].Fields[5].DefaultValueQuoted:= FALSE;
      DBEngine.Tables[0].Fields[5].DefaultValue:= DBEngine.FalseValue;
  //Table 'Usergroups'
  //ID_Usergroup INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[1].Fields[0].Name:= 'ID_Usergroup';
   	DBEngine.Tables[1].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[1].Fields[0].PutNull:= TRUE;
      DBEngine.Tables[1].Fields[0].IsNotNull:= TRUE;
   	DBEngine.Tables[1].Fields[0].IsPrimaryKey:= TRUE;
     DBEngine.Tables[1].Fields[0].Autoincrement:= TRUE;
	//Name_Usergroup CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[1].Fields[1].Name:= 'Name_Usergroup';
    DBEngine.Tables[1].Fields[1].DataFormat:= dtChar;
  		DBEngine.Tables[1].Fields[1].DataLength:= 255;
  	DBEngine.Tables[1].Fields[1].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[1].Fields[1].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[1].Fields[1].DefaultValue:= '';
    DBEngine.Tables[1].Fields[1].PutCase:= TRUE;
    	DBEngine.Tables[1].Fields[1]._Case:= FALSE;
	//Table 'Users'
  //ID_User INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[2].Fields[0].Name:= 'ID_User';
   	DBEngine.Tables[2].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[2].Fields[0].PutNull:= TRUE;
      DBEngine.Tables[2].Fields[0].IsNotNull:= TRUE;
   	DBEngine.Tables[2].Fields[0].IsPrimaryKey:= TRUE;
      DBEngine.Tables[1].Fields[0].Autoincrement:= TRUE;
	//Name_User CHAR('+IntToStr(USERNAME_LENGTH)+') COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[2].Fields[1].Name:= 'Name_User';
    DBEngine.Tables[2].Fields[1].DataFormat:= dtChar;
  		DBEngine.Tables[2].Fields[1].DataLength:= USERNAME_LENGTH;
  	DBEngine.Tables[2].Fields[1].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[2].Fields[1].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[2].Fields[1].DefaultValue:= '';
    DBEngine.Tables[2].Fields[1].PutCase:= TRUE;
    	DBEngine.Tables[2].Fields[1]._Case:= FALSE;
	//Hash_User CHAR(255) DEFAULT ""
  DBEngine.Tables[2].Fields[2].Name:= 'Hash_User';
  	DBEngine.Tables[2].Fields[2].DataFormat:= dtChar;
   		DBEngine.Tables[2].Fields[2].DataLength:= 255;
    DBEngine.Tables[2].Fields[2].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[2].Fields[2].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[2].Fields[2].DefaultValue:= '';
	//Salt_User CHAR(255) DEFAULT ""
  DBEngine.Tables[2].Fields[3].Name:= 'Salt_User';
  	DBEngine.Tables[2].Fields[3].DataFormat:= dtChar;
    	DBEngine.Tables[2].Fields[3].DataLength:= 255;
    DBEngine.Tables[2].Fields[3].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[2].Fields[3].DefaultValueQuoted:= TRUE;
      DBEngine.Tables[2].Fields[3].DefaultValue:= '';
	//Usergroup_ID INTEGER FOREIGN KEY REFERENCES Usergroups(ID_Usergroup)
  DBEngine.Tables[2].Fields[4].Name:= 'Usergroup_ID';
  	DBEngine.Tables[2].Fields[4].DataFormat:= dtInteger;
   	DBEngine.Tables[2].Fields[4].IsForeignKey:= TRUE;
    	DBEngine.Tables[2].Fields[4].FK_ParentTable:= 'Usergroups';
      DBEngine.Tables[2].Fields[4].FK_ParentField:= 'ID_Usergroup';
      DBEngine.Tables[2].Fields[4].FK_ReferentialAction:= fkOnUpdate;
      DBEngine.Tables[2].Fields[4].FK_ReferenceOption:= fkCascade;
  //Table 'Permissions'
  //ID_Permissions INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[3].Fields[0].Name:= 'ID_Permission';
   	DBEngine.Tables[3].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[3].Fields[0].PutNull:= TRUE;
      DBEngine.Tables[3].Fields[0].IsNotNull:= TRUE;
   	DBEngine.Tables[3].Fields[0].IsPrimaryKey:= TRUE;
      DBEngine.Tables[3].Fields[0].Autoincrement:= TRUE;
	//Usergroup_ID INTEGER REFERENCES Usergroups(ID_Usergroup) ON DELETE CASCADE
  DBEngine.Tables[3].Fields[1].Name:= 'Usergroup_ID';
    DBEngine.Tables[3].Fields[1].DataFormat:= dtInteger;
   	DBEngine.Tables[3].Fields[1].IsForeignKey:= TRUE;
    	DBEngine.Tables[3].Fields[1].FK_ParentTable:= 'Usergroups';
      DBEngine.Tables[3].Fields[1].FK_ParentField:= 'ID_Usergroup';
      DBEngine.Tables[3].Fields[1].FK_ReferentialAction:= fkOnDelete;
      DBEngine.Tables[3].Fields[1].FK_ReferenceOption:= fkCascade;
  //EditEmployee_Permission BOOLEAN NOT NULL DEFAULT 1
  DBEngine.Tables[3].Fields[2].Name:= 'EditEmployee_Permission';
  	DBEngine.Tables[3].Fields[2].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[2].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[3].Fields[2].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[3].Fields[2].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[3].Fields[2].PutNull:= TRUE;
    	DBEngine.Tables[3].Fields[2].IsNotNull:= TRUE;
	//AddEmployee_Permission BOOLEAN NOT NULL DEFAULT 1
  DBEngine.Tables[3].Fields[3].Name:= 'AddEmployee_Permission';
  	DBEngine.Tables[3].Fields[3].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[3].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[3].Fields[3].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[3].Fields[3].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[3].Fields[3].PutNull:= TRUE;
    	DBEngine.Tables[3].Fields[3].IsNotNull:= TRUE;
	//DeleteEmployee_Permission BOOLEAN NOT NULL DEFAULT 0
  DBEngine.Tables[3].Fields[4].Name:= 'DeleteEmployee_Permission';
  	DBEngine.Tables[3].Fields[4].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[4].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[3].Fields[4].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[3].Fields[4].DefaultValue:= DBEngine.FalseValue;
    DBEngine.Tables[3].Fields[4].PutNull:= TRUE;
    	DBEngine.Tables[3].Fields[4].IsNotNull:= TRUE;
	//ShowTabAddress_Permission BOOLEAN NOT NULL DEFAULT 1
  DBEngine.Tables[3].Fields[5].Name:= 'ShowTabAddress_Permission';
  	DBEngine.Tables[3].Fields[5].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[5].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[3].Fields[5].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[3].Fields[5].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[3].Fields[5].PutNull:= TRUE;
    	DBEngine.Tables[3].Fields[5].IsNotNull:= TRUE;
 	//AdminControlAccess_Permission BOOLEAN NOT NULL DEFAULT 1
  DBEngine.Tables[3].Fields[6].Name:= 'AdminControlAccess_Permission';
   	DBEngine.Tables[3].Fields[6].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[6].HasDefaultValue:=	TRUE;
     	DBEngine.Tables[3].Fields[6].DefaultValueQuoted:= FALSE;
     	DBEngine.Tables[3].Fields[6].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[3].Fields[6].PutNull:= TRUE;
     	DBEngine.Tables[3].Fields[6].IsNotNull:= TRUE;
 	//AdminControlAccess_Permission BOOLEAN NOT NULL DEFAULT 1
  DBEngine.Tables[3].Fields[7].Name:= 'AdminDatabase_Permission';
   	DBEngine.Tables[3].Fields[7].DataFormat:= dtBoolean;
    DBEngine.Tables[3].Fields[7].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[3].Fields[7].DefaultValueQuoted:= FALSE;
      DBEngine.Tables[3].Fields[7].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[3].Fields[7].PutNull:= TRUE;
     	DBEngine.Tables[3].Fields[7].IsNotNull:= TRUE;
  //Table 'Employees'
  //ID_Employee INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[4].Fields[0].Name:= 'ID_Employee';
  	DBEngine.Tables[4].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[4].Fields[0].PutNull:= TRUE;
	    DBEngine.Tables[4].Fields[0].IsNotNull:= TRUE;
  	DBEngine.Tables[4].Fields[0].IsPrimaryKey:= TRUE;
    DBEngine.Tables[4].Fields[0].Autoincrement:= TRUE;
  //Active_Employee BOOLEAN NOT NULL DEFAULT TRUE
  DBEngine.Tables[4].Fields[1].Name:= 'Active_Employee';
  	DBEngine.Tables[4].Fields[1].DataFormat:= dtBoolean;
    DBEngine.Tables[4].Fields[1].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[4].Fields[1].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[4].Fields[1].DefaultValue:= DBEngine.TrueValue;
    DBEngine.Tables[4].Fields[1].PutNull:= TRUE;
    	DBEngine.Tables[4].Fields[1].IsNotNull:= TRUE;
  //IDN_Employee CHAR(255) NOT NULL DEFAULT ""
  DBEngine.Tables[4].Fields[2].Name:= 'IDN_Employee';
  	DBEngine.Tables[4].Fields[2].DataFormat:= dtChar;
    	DBEngine.Tables[4].Fields[2].DataLength:= 255;
    DBEngine.Tables[4].Fields[2].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[4].Fields[2].DefaultValueQuoted:= TRUE;
    	DBEngine.Tables[4].Fields[2].DefaultValue:= '';
    DBEngine.Tables[4].Fields[2].PutNull:= TRUE;
    	DBEngine.Tables[4].Fields[2].IsNotNull:= TRUE;
  //Name_Employee CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[3].Name:= 'Name_Employee';
    DBEngine.Tables[4].Fields[3].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[3].DataLength:= 255;
  	DBEngine.Tables[4].Fields[3].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[3].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[3].DefaultValue:= '';
    DBEngine.Tables[4].Fields[3].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[3]._Case:= FALSE;
  //Surname1_Employee CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[4].Name:= 'Surname1_Employee';
    DBEngine.Tables[4].Fields[4].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[4].DataLength:= 255;
  	DBEngine.Tables[4].Fields[4].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[4].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[4].DefaultValue:= '';
    DBEngine.Tables[4].Fields[4].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[4]._Case:= FALSE;
  //Surname2_Employee CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[5].Name:= 'Surname2_Employee';
    DBEngine.Tables[4].Fields[5].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[5].DataLength:= 255;
  	DBEngine.Tables[4].Fields[5].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[5].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[5].DefaultValue:= '';
    DBEngine.Tables[4].Fields[5].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[5]._Case:= FALSE;
  //IDCard_Employee CHAR(255) DEFAULT ""
  DBEngine.Tables[4].Fields[6].Name:= 'IDCard_Employee';
    DBEngine.Tables[4].Fields[6].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[6].DataLength:= 255;
  	DBEngine.Tables[4].Fields[6].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[6].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[6].DefaultValue:= '';
  //SSN_Employee CHAR(25) DEFAULT ""
  DBEngine.Tables[4].Fields[7].Name:= 'SSN_Employee';
    DBEngine.Tables[4].Fields[7].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[7].DataLength:= 25;
  	DBEngine.Tables[4].Fields[7].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[7].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[7].DefaultValue:= '';
  //Address_Employee MEMO(8192) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[8].Name:= 'Address_Employee';
    DBEngine.Tables[4].Fields[8].DataFormat:= dtText;
  		DBEngine.Tables[4].Fields[8].DataLength:= 8192;
  	DBEngine.Tables[4].Fields[8].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[8].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[8].DefaultValue:= '';
    DBEngine.Tables[4].Fields[8].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[8]._Case:= FALSE;
	//City_Employee CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[9].Name:= 'City_Employee';
    DBEngine.Tables[4].Fields[9].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[9].DataLength:= 255;
  	DBEngine.Tables[4].Fields[9].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[9].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[9].DefaultValue:= '';
    DBEngine.Tables[4].Fields[9].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[9]._Case:= FALSE;
	//State_Employee CHAR(255) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[10].Name:= 'State_Employee';
    DBEngine.Tables[4].Fields[10].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[10].DataLength:= 255;
  	DBEngine.Tables[4].Fields[10].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[10].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[10].DefaultValue:= '';
    DBEngine.Tables[4].Fields[10].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[10]._Case:= FALSE;
  //ZIPCode_Employee CHAR(255) DEFAULT ""
  DBEngine.Tables[4].Fields[11].Name:= 'ZIPCode_Employee';
    DBEngine.Tables[4].Fields[11].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[11].DataLength:= 255;
  	DBEngine.Tables[4].Fields[11].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[11].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[11].DefaultValue:= '';
	//Phone_Employee CHAR(255) DEFAULT ""
  DBEngine.Tables[4].Fields[12].Name:= 'Phone_Employee';
    DBEngine.Tables[4].Fields[12].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[12].DataLength:= 255;
  	DBEngine.Tables[4].Fields[12].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[12].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[12].DefaultValue:= '';
	//Cell_Employee CHAR(255) DEFAULT ""
  DBEngine.Tables[4].Fields[13].Name:= 'Cell_Employee';
    DBEngine.Tables[4].Fields[13].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[13].DataLength:= 255;
  	DBEngine.Tables[4].Fields[13].HasDefaultValue:= TRUE;
   		DBEngine.Tables[4].Fields[13].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[13].DefaultValue:= '';
	//EMail_Employee CHAR(255) DEFAULT ""
  DBEngine.Tables[4].Fields[14].Name:= 'EMail_Employee';
    DBEngine.Tables[4].Fields[14].DataFormat:= dtChar;
  		DBEngine.Tables[4].Fields[14].DataLength:= 255;
  	DBEngine.Tables[4].Fields[14].HasDefaultValue:= TRUE;
   		DBEngine.Tables[4].Fields[14].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[14].DefaultValue:= '';
	//DateBirth_Employee DATE DEFAULT NULL
  DBEngine.Tables[4].Fields[15].Name:= 'DateBirth_Employee';
  	DBEngine.Tables[4].Fields[15].DataFormat:= dtDate;
   	DBEngine.Tables[4].Fields[15].HasDefaultValue:= TRUE;
    		DBEngine.Tables[4].Fields[15].DefaultValueQuoted:= FALSE;
    		DBEngine.Tables[4].Fields[15].DefaultValue:= 'NULL';
	//Genre_Employee BOOLEAN DEFAULT NULL
  DBEngine.Tables[4].Fields[16].Name:= 'Genre_Employee';
  	DBEngine.Tables[4].Fields[16].DataFormat:= dtBoolean;
   	DBEngine.Tables[4].Fields[16].HasDefaultValue:= TRUE;
    		DBEngine.Tables[4].Fields[16].DefaultValueQuoted:= FALSE;
    		DBEngine.Tables[4].Fields[16].DefaultValue:= 'NULL';
	//MaritalStatus_Employee BOOLEAN DEFAULT NULL
  DBEngine.Tables[4].Fields[17].Name:= 'MaritalStatus_Employee';
  	DBEngine.Tables[4].Fields[17].DataFormat:= dtBoolean;
   	DBEngine.Tables[4].Fields[17].HasDefaultValue:= TRUE;
    		DBEngine.Tables[4].Fields[17].DefaultValueQuoted:= FALSE;
    		DBEngine.Tables[4].Fields[17].DefaultValue:= 'NULL';
	//Remarks_Employee MEMO(8192) COLLATE NOCASE DEFAULT ""
  DBEngine.Tables[4].Fields[18].Name:= 'Remarks_Employee';
    DBEngine.Tables[4].Fields[18].DataFormat:= dtText;
  		DBEngine.Tables[4].Fields[18].DataLength:= 8192;
  	DBEngine.Tables[4].Fields[18].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[4].Fields[18].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[4].Fields[18].DefaultValue:= '';
    DBEngine.Tables[4].Fields[18].PutCase:= TRUE;
    	DBEngine.Tables[4].Fields[18]._Case:= FALSE;
	//DateInit_Contract DATE DEFAULT NULL
  DBEngine.Tables[4].Fields[19].Name:= 'DateInit_Contract';
  	DBEngine.Tables[4].Fields[19].DataFormat:= dtDate;
   	DBEngine.Tables[4].Fields[19].HasDefaultValue:= TRUE;
    		DBEngine.Tables[4].Fields[19].DefaultValueQuoted:= FALSE;
    		DBEngine.Tables[4].Fields[19].DefaultValue:= 'NULL';
	//DateEnd_Contract DATE DEFAULT NULL
  DBEngine.Tables[4].Fields[20].Name:= 'DateEnd_Contract';
  	DBEngine.Tables[4].Fields[20].DataFormat:= dtDate;
   	DBEngine.Tables[4].Fields[20].HasDefaultValue:= TRUE;
    		DBEngine.Tables[4].Fields[20].DefaultValueQuoted:= FALSE;
    		DBEngine.Tables[4].Fields[20].DefaultValue:= 'NULL';
	//TypeContract_ID INTEGER COLLATE NOCASE DEFAULT NULL
  DBEngine.Tables[4].Fields[21].Name:= 'TypeContract_ID';
  	DBEngine.Tables[4].Fields[21].DataFormat:= dtInteger;
    DBEngine.Tables[4].Fields[21].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[4].Fields[21].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[4].Fields[21].DefaultValue:= 'NULL';
    DBEngine.Tables[4].Fields[21].PutCase:= TRUE;
     	DBEngine.Tables[4].Fields[21]._Case:= FALSE;
	//Workplace_ID INTEGER COLLATE NOCASE DEFAULT NULL
  DBEngine.Tables[4].Fields[22].Name:= 'Workplace_ID';
  	DBEngine.Tables[4].Fields[22].DataFormat:= dtInteger;
    DBEngine.Tables[4].Fields[22].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[4].Fields[22].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[4].Fields[22].DefaultValue:= 'NULL';
    DBEngine.Tables[4].Fields[22].PutCase:= TRUE;
     	DBEngine.Tables[4].Fields[22]._Case:= FALSE;
  //Table 'PicsEmployees'
  //ID_PicEmployee INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[5].Fields[0].Name:= 'ID_PicEmployee';
  	DBEngine.Tables[5].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[5].Fields[0].PutNull:= TRUE;
	    DBEngine.Tables[5].Fields[0].IsNotNull:= TRUE;
  	DBEngine.Tables[5].Fields[0].IsPrimaryKey:= TRUE;
    DBEngine.Tables[5].Fields[0].Autoincrement:= TRUE;
	//Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE
  DBEngine.Tables[5].Fields[1].Name:= 'Employee_ID';
    DBEngine.Tables[5].Fields[1].DataFormat:= dtInteger;
   	DBEngine.Tables[5].Fields[1].IsForeignKey:= TRUE;
    	DBEngine.Tables[5].Fields[1].FK_ParentTable:= 'Employees';
      DBEngine.Tables[5].Fields[1].FK_ParentField:= 'ID_Employee';
      DBEngine.Tables[5].Fields[1].FK_ReferentialAction:= fkOnDelete;
      DBEngine.Tables[5].Fields[1].FK_ReferenceOption:= fkCascade;
	//Pic_Employee BLOB)
  DBEngine.Tables[5].Fields[2].Name:= 'Pic_Employee';
    DBEngine.Tables[5].Fields[2].DataFormat:= dtBlob;
  //Table 'TypeContracts'
  //ID_TypeContract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[6].Fields[0].Name:= 'ID_TypeContract';
  	DBEngine.Tables[6].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[6].Fields[0].PutNull:= TRUE;
	    DBEngine.Tables[6].Fields[0].IsNotNull:= TRUE;
  	DBEngine.Tables[6].Fields[0].IsPrimaryKey:= TRUE;
    DBEngine.Tables[6].Fields[0].Autoincrement:= TRUE;
  //Name_TypeContract CHAR(255) DEFAULT ""
  DBEngine.Tables[6].Fields[1].Name:= 'Name_TypeContract';
  	DBEngine.Tables[6].Fields[1].DataFormat:= dtChar;
   		DBEngine.Tables[6].Fields[1].DataLength:= 255;
    DBEngine.Tables[6].Fields[1].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[6].Fields[1].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[6].Fields[1].DefaultValue:= '';
  //Table 'Workplaces'
	//ID_Workplace INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[7].Fields[0].Name:= 'ID_Workplace';
  	DBEngine.Tables[7].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[7].Fields[0].PutNull:= TRUE;
	    DBEngine.Tables[7].Fields[0].IsNotNull:= TRUE;
  	DBEngine.Tables[7].Fields[0].IsPrimaryKey:= TRUE;
    DBEngine.Tables[7].Fields[0].Autoincrement:= TRUE;
	//Name_Workplace CHAR(256) DEFAULT ""
  DBEngine.Tables[7].Fields[1].Name:= 'Name_Workplace';
  	DBEngine.Tables[7].Fields[1].DataFormat:= dtChar;
   		DBEngine.Tables[7].Fields[1].DataLength:= 255;
    DBEngine.Tables[7].Fields[1].HasDefaultValue:=	TRUE;
   		DBEngine.Tables[7].Fields[1].DefaultValueQuoted:= TRUE;
   		DBEngine.Tables[7].Fields[1].DefaultValue:= '';
	//Table 'ContractLog'
	//ID_Contract INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
  DBEngine.Tables[8].Fields[0].Name:= 'ID_Contract';
  	DBEngine.Tables[8].Fields[0].DataFormat:= dtInteger;
    DBEngine.Tables[8].Fields[0].PutNull:= TRUE;
	    DBEngine.Tables[8].Fields[0].IsNotNull:= TRUE;
  	DBEngine.Tables[8].Fields[0].IsPrimaryKey:= TRUE;
    DBEngine.Tables[8].Fields[0].Autoincrement:= TRUE;
  //Employee_ID INTEGER REFERENCES Employees(ID_Employee) ON DELETE CASCADE
  DBEngine.Tables[8].Fields[1].Name:= 'Employee_ID';
    DBEngine.Tables[8].Fields[1].DataFormat:= dtInteger;
   	DBEngine.Tables[8].Fields[1].IsForeignKey:= TRUE;
    	DBEngine.Tables[8].Fields[1].FK_ParentTable:= 'Employees';
      DBEngine.Tables[8].Fields[1].FK_ParentField:= 'ID_Employee';
      DBEngine.Tables[8].Fields[1].FK_ReferentialAction:= fkOnDelete;
      DBEngine.Tables[8].Fields[1].FK_ReferenceOption:= fkCascade;
  //DateInit_Contract DATE
  DBEngine.Tables[8].Fields[2].Name:= 'DateInit_Contract';
  	DBEngine.Tables[8].Fields[2].DataFormat:= dtDate;
	//DateEnd_Contract DATE
  DBEngine.Tables[8].Fields[3].Name:= 'DateEnd_Contract';
  	DBEngine.Tables[8].Fields[3].DataFormat:= dtDate;
	//TypeContract_ID INTEGER DEFAULT NULL
  DBEngine.Tables[8].Fields[4].Name:= 'TypeContract_ID';
  	DBEngine.Tables[8].Fields[4].DataFormat:= dtInteger;
    DBEngine.Tables[8].Fields[4].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[8].Fields[4].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[8].Fields[4].DefaultValue:= 'NULL';
	//Workplace_ID INTEGER DEFAULT NULL
  DBEngine.Tables[8].Fields[5].Name:= 'Workplace_ID';
  	DBEngine.Tables[8].Fields[5].DataFormat:= dtInteger;
    DBEngine.Tables[8].Fields[5].HasDefaultValue:=	TRUE;
    	DBEngine.Tables[8].Fields[5].DefaultValueQuoted:= FALSE;
    	DBEngine.Tables[8].Fields[5].DefaultValue:= 'NULL';
end;

procedure DefineTables;
var
	i: Integer;
begin
  i:= 0;
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Config';
  DBEngine.Tables[i].ID:= wtConfig;
  DBEngine.Tables[i].Table:= DataMod.QueConfig;
  DBEngine.Tables[i].Datasource:= DataMod.DsoConfig;
  DBEngine.Tables[i].FieldsCount:= 6;
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Usergroups';
  DBEngine.Tables[i].Table:= DataMod.QueUsergroups;
  DBEngine.Tables[i].Datasource:= DataMod.DsoUsergroups;
  DBEngine.Tables[i].ID:= wtUsergroups;
  DBEngine.Tables[i].FieldsCount:= 2;
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Users';
  DBEngine.Tables[i].ID:= wtUsers;
  DBEngine.Tables[i].Table:= DataMod.QueUsers;
  DBEngine.Tables[i].Datasource:= DataMod.DsoUsers;
  DBEngine.Tables[i].FieldsCount:= 5;
  DBEngine.Tables[i].KeyField:= 'ID_User';
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Permissions';
  DBEngine.Tables[i].ID:= wtPermissions;
  DBEngine.Tables[i].Table:= DataMod.QuePermissions;
  DBEngine.Tables[i].Datasource:= DataMod.DsoPermissions;
  //If you add a new permission:
	  //1: Inc the following number in DBEngine.Tables[i].FieldsCount
  	//2: Add a field and change the query when adding the default SUPERUSER in FuncData
	  //3: Add the field in the event BtnAddClick() in FormPremissions
  	//4: Add the new permission to User in FormLogin
	  //5: Add new the permission to TPermission in Globals
  DBEngine.Tables[i].FieldsCount:= 8;
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Employees';
  DBEngine.Tables[i].ID:= wtEmployees;
  DBEngine.Tables[i].Table:= DataMod.QueEmployees;
  DBEngine.Tables[i].Datasource:= DataMod.DsoEmployees;
  DBEngine.Tables[i].FieldsCount:= 23;
  DBEngine.Tables[i].KeyField:= 'ID_Employee';
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'PicsEmployees';
  DBEngine.Tables[i].ID:= wtPicsEmployees;
  DBEngine.Tables[i].Table:= DataMod.QuePicsEmployees;
  DBEngine.Tables[i].Datasource:= DataMod.DsoPicsEmployees;
  DBEngine.Tables[i].FieldsCount:= 3;
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'TypeContracts';
  DBEngine.Tables[i].ID:= wtTypeContracts;
  DBEngine.Tables[i].Table:= DataMod.QueTypeContracts;
  DBEngine.Tables[i].Datasource:= DataMod.DsoTypeContracts;
  DBEngine.Tables[i].KeyField:= 'ID_TypeContract';
  DBEngine.Tables[i].FieldsCount:= 2;
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'Workplaces';
  DBEngine.Tables[i].Table:= DataMod.QueWorkplaces;
  DBEngine.Tables[i].Datasource:= DataMod.DsoWorkplaces;
  DBEngine.Tables[i].ID:= wtWorkplaces;
  DBEngine.Tables[i].FieldsCount:= 2;
  DBEngine.Tables[i].KeyField:= 'ID_Workplace';
  Inc(i);
  SetLength(DBEngine.Tables, i+1);
  DBEngine.Tables[i].Name:= 'ContractsLog';
  DBEngine.Tables[i].Table:= DataMod.QueContractsLog;
  DBEngine.Tables[i].Datasource:= DataMod.DsoContractsLog;
  DBEngine.Tables[i].ID:= wtContractsLog;
  DBEngine.Tables[i].FieldsCount:= 6;
  DBEngine.TablesCount:= i+1;
  for i:= 0 to ((Length(DBEngine.Tables))-1) do
  	SetLength(DBEngine.Tables[i].Fields, DBEngine.Tables[i].FieldsCount);
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

