program librestaff;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, //this includes the LCL widgetset
  Forms, Classes, DataModule, DefaultTranslator, Controls, sqldb,
  FormLogin, FormMain, FuncData, SysUtils, INIfiles,
  Globals, FormPreferences, FormprgBar, Dialogs, StrUtils;

{$R *.res}

var
  LoginOK: Integer;
  Login: TFrmLogin;
  _DatabasePath: String;

procedure CreateMainForm;
	begin
 	Application.CreateForm(TFrmMain, FrmMain);
 	Application.Run;
  end;

begin
  RequireDerivedFormResource:= True;
  Application.Title:= 'LibreStaff';
	Application.Initialize;
  Application.CreateForm(TDataMod, DataMod);
  PathApp:= ExtractFilePath(Paramstr(0));
	//WriteLn('GTK2_RC_FILES='+PathApp+'themes\MS-Windows\gtk-2.0\gtkrc librestaff', ParamStr(1));
  {$IFDEF DEBUG}
  	// Assuming your build mode sets -dDEBUG in Project Options/Other when defining -gh
		// This avoids interference when running a production/default build without -gh
		// Set up -gh output for the Leakview package:
	  if FileExists(PathApp+'heap.trc') then
  	  DeleteFile(PathApp+'heap.trc');
		SetHeapTraceOutput(PathApp+'heap.trc');
  {$ENDIF DEBUG}
  //INI File Section:
  PathIni:=
  	{$ifdef Win32}
    	PathApp+'config.ini'; //Windows
	  {$else}
			GetUserDir+'.config/librestaff/config.ini'; //Linux
	  {$endif}
  INIFile:= TINIFile.Create(PathIni, True);
  //Connect & Load to database
  //Firstly I create the DBEngine Object (Defined in the FuncData unit)->
  DBEngine:= TDBEngine.Create;
  //Set some paths
  if not FileExists(PathIni) then //First time or 'config.ini' deleted
    begin
    _DatabasePath:=
  		{$ifdef Win32}
		    PathApp+'data'+PATH_SEPARATOR;  //Windows
		  {$else}
		    '/opt/librestaff/data'+PATH_SEPARATOR;  //Linux
	  	{$endif}
   	INIFile.WriteString('Database', 'Path', QuotedStr(_DatabasePath));  //Windows
    INIFile.WriteString('Database', 'DBEngine', '0');
    INIFile.WriteString('SQLite', 'AtomicCommmit', '1');
    FuncData.ConfigureDBEngine;
    end;
  //What type of database (DBEngine.ID) is defined (saved in config.ini)
  DBEngine.ID:= INIFile.ReadInteger('Database', 'DBEngine', 0);
  case (DBEngine.ID) of
  	0:	begin
    		//In the following lines the DBEngine Object is defined->
        DBEngine.DBType:= dbtSQLite;
        DBEngine.Connection:= DataMod.SQLiteConnection;
			  DBEngine.DatabasePath:= ReplaceStr(INIFile.ReadString('Database', 'Path', PathApp+'data'+PATH_SEPARATOR),'''','');
			  DBEngine.DatabaseName:= DBEngine.DatabasePath + DATABASE_NAME + DATABASE_EXTENSION;
        DBEngine.HostName:= '';
        DataMod.Transaction.DataBase:= DataMod.SQLiteConnection;
        SQLiteLibraryName:= PathApp+'sqlite3.dll';
        //Values for Booleans (True/False) to this database type
        DBEngine.TrueValue:= '1';
        DBEngine.FalseValue:= '0';
        //SQL Keyword for AUTOINCREMENT to this database type
        DBEngine.AutoIncrementKeyword:= 'AUTOINCREMENT';
      	end;
    1:	begin
 	      DBEngine.DBType:= dbtMySQL;
        DBEngine.Connection:= DataMod.MySQLConnection;
        DBEngine.DatabaseName:= INIFile.ReadString('MySQL', 'DatabaseName', '');
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
  AtomicCommmit:= INIFile.ReadInteger('SQLite', 'AtomicCommit', 1);
  //Check if Databasename is set
  if (DBEngine.DatabaseName='') then
    begin
    ShowMessage('Error: '+Error_DatabaseName_Blank);
    //Call the ConfigureDBEngine procedure to open a form (FrmPreferences:TabDatabase) to configure the database engine
    FuncData.ConfigureDBEngine;
    end;
  //Try to connect to database->
  FuncData.ConnectDatabase(DBEngine.Databasename);
  //Open the Config Table of the database
  FuncData.ExecSQL(DataMod.QueConfig, 'SELECT * from Config LIMIT 1;');
  //Read the database version->
  DBEngine.DatabaseVersion:= DataMod.QueConfig.FieldByName('DatabaseVersion').AsString;
  //Read if the Access Control (asking for username & password at start) is activated->
  AccessControl:= DataMod.QueConfig.FieldByName('AccessControl').AsBoolean;
  if (AccessControl= TRUE) then
  	begin
    //If AccessControl activated, then create the FrmLogin
	  Login:= TFrmLogin.Create(nil); //Create Login Form not owned by object
  	LoginOK:= Login.ShowModal;
	  if (LoginOK= mrOK) then
  		begin
      FreeAndNil(Login); //Free the login form
      //Now the Main Form is created and the application starts->
      CreateMainForm;
    	end
    else
    	begin
      FreeAndNil(Login); //Free the login form
			FreeAndNil(DBEngine); //Free DBEngine
      FreeAndNil(User);
      FreeAndNil(DataMod);
      Application.Terminate;
      Application.Run; //Aplication should must initiated -without forms- to be capable of a cool destroying
      end;
    end
  else
  	//If not Access Control activated
    //Then the Main Form is created and the application starts->
    CreateMainForm;
end.

