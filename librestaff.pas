program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Classes, DataModule, DefaultTranslator, Controls, sqldb,
  FormLogin, FormPrgBar, FormMain, FuncData, SysUtils, INIfiles,
  Globals, FormPreferences;

{$R *.res}

var
  LoginOK: Integer;
  Login: TFrmLogin;

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
  DBEngine:= TDBEngine.Create;
  //Set some paths
  if not FileExists(PathApp+'config.ini') then //First time or 'config.ini' deleted
    begin
		INIFile.WriteString('Database', 'Path', QuotedStr(PathApp+'data\'));
    INIFile.WriteString('Database', 'DBEngine', '0');
    INIFile.WriteString('Database', 'AtomicCommmit', '1');
    FrmPreferences:= TFrmPreferences.Create(nil);
    FrmPreferences.LstViewPreferences.Visible:= False;
    FrmPreferences.Width:= FrmPreferences.Width-FrmPreferences.LstViewPreferences.Width;
    FrmPreferences.FraClose1.BtnClose.Left:= FrmPreferences.FraClose1.BtnClose.Left-Round(FrmPreferences.LstViewPreferences.Width/2);
    FrmPreferences.PagPreferences.TabIndex:= 2;
    FrmPreferences.DbLkCboAtomicCommit.Enabled:= False;
  	FrmPreferences.ShowModal;
    end;
  DBEngine.ID:= INIFile.ReadInteger('Database', 'DBEngine', 0);
  case (DBEngine.ID) of
  	0:	begin
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
        DBEngine.DatabaseName:= INIFile.ReadString('MySQL', 'DatabaseName', '');;
        DBEngine.HostName:= INIFile.ReadString('MySQL', 'HostName', '');
        DBEngine.HostName:= 'localhost';
        DBEngine.UserName:= 'root';
        DBEngine.UserName:= INIFile.ReadString('MySQL', 'UserName', '');
        DBEngine.Password:= INIFile.ReadString('MySQL', 'Password', '');
        DataMod.Transaction.DataBase:= DataMod.MySQLConnection;
        DBEngine.TrueValue:= '1';
        DBEngine.FalseValue:= '0';
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

