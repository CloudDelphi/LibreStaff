program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Classes, DataModule, DefaultTranslator, Controls, sqldb,
  FormLogin, FormPrgBar, FormMain, FuncData, SysUtils, INIfiles,
  Globals;

{$R *.res}

var
  LoginOK: Integer;
  Login: TFrmLogin;
  DBEngineID: Integer;

procedure CreateMainForm;
	begin
  Screen.Cursor:= crHourglass;
	//The progress bar to show the database load:
	FrmPrgBar:= TFrmPrgBar.Create(Application);
	FrmPrgBar.ShowOnTop;
	Application.CreateForm(TFrmMain, FrmMain);
	Application.Run;
  end;

begin
  RequireDerivedFormResource:= True;
  Application.Title:= 'LibreStaff';
	Application.Initialize;
  Application.CreateForm(TDataMod, DataMod);
  PathApp:= ExtractFilePath(Paramstr(0));
  //INI File Section:
  INIFile:= TINIFile.Create(PathApp+'config.ini', True);
  //Connect & Load to database
  DBEngineID:= INIFile.ReadInteger('Database', 'DBEngine', 0);
  DBEngine:= TDBEngine.Create;
  case DBEngineID of
  	0:	begin
	      //Set some paths
    		if not FileExists(PathApp+'config.ini') then
					INIFile.WriteString('Database', 'Path', QuotedStr(PathApp+'data\'));
 	      DBEngine.DBType:= dbtSQLite;
        DBEngine.Connection:= DataMod.SQLiteConnection;
			  DBEngine.DatabasePath:= INIFile.ReadString('Database', 'Path', PathApp+'data\');
			  DBEngine.DatabaseName:= DBEngine.DatabasePath + DATABASE_NAME+'.db';
        DBEngine.HostName:= '';
        DataMod.Transaction.DataBase:= DataMod.SQLiteConnection;
        SQLiteLibraryName:= PathApp+'sqlite3.dll';
        DBEngine.TrueValue:= '1';
        DBEngine.FalseValue:= '0';
        DBEngine.AutoIncrementKeyword:= 'AUTOINCREMENT';
      	end;
    1:	begin
 	      DBEngine.DBType:= dbtMySQL;
        DBEngine.Connection:= DataMod.MySQLConnection;
        DBEngine.DatabaseName:= DATABASE_NAME;
        //DBEngine.HostName:= INIFile.ReadString('Database', 'MySQLHostName', '');
        DBEngine.HostName:= 'localhost';
        DBEngine.UserName:= 'root';
        //DBEngine.UserName:= INIFile.ReadString('Database', 'MySQLUserName', '');
        //DBEngine.Password:= INIFile.ReadString('Database', 'MySQLPassword', '');
        DataMod.Transaction.DataBase:= DataMod.MySQLConnection;
        DBEngine.TrueValue:= 'TRUE';
        DBEngine.FalseValue:= 'FALSE';
        DBEngine.AutoIncrementKeyword:= 'AUTO_INCREMENT';
      	end;
  end;
  DBEngine.Connection.Transaction:= DataMod.Transaction;
  //The mode of database Atomic Commit
  AtomicCommmit:= INIFile.ReadInteger('Database', 'AtomicCommit', 1);
  FuncData.ConnectDatabase(DBEngine.Databasename);
  FuncData.ExecSQL(DataMod.QueConfig, 'SELECT * from Config LIMIT 1;');
  AccessControl:= DataMod.QueConfig.FieldByName('AccessControl').AsBoolean;
  if (AccessControl= TRUE) then
  	begin
	  Login:= TFrmLogin.Create(nil); //Create Login Form not owned by object
  	LoginOK:= Login.ShowModal;
	  if (LoginOK= mrOK) then
  		begin
      CreateMainForm;
    	end;
		Login.Free; //Free the login form
    end
  else
  	begin
    CreateMainForm;
    end;
end.

