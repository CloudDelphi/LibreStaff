unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Dialogs, db, sqlite3conn, sqldb, mysql56conn;

type
  TSQLite3Connection = class(sqlite3conn.TSQLite3Connection)
  protected
    procedure DoInternalConnect; override;
	end;

type
  { TDataModule1 }
  TDataMod = class(TDataModule)
    DsoConfig: TDataSource;
    DsoPermissions: TDataSource;
    DsoQuery: TDataSource;
    DsoUsers: TDataSource;
    DsoTypeContracts: TDataSource;
    DsoSearch: TDataSource;
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    DsoPrint: TDataSource;
    DsoWorkplaces: TDataSource;
    DsoContractsLog: TDataSource;
    DsoUsergroups: TDataSource;
    Img16: TImageList;
    ImgLstBtn: TImageList;
    MySQLConnection: TMySQL56Connection;
    OpenDlg: TOpenDialog;
    QueConfig: TSQLQuery;
    QuePrint: TSQLQuery;
    QuePermissions: TSQLQuery;
    QueQuery: TSQLQuery;
    QueUsers: TSQLQuery;
    QueVirtual: TSQLQuery;
    QueEmployees: TSQLQuery;
    QuePicsEmployees: TSQLQuery;
    QueSearch: TSQLQuery;
    QueTypeContracts: TSQLQuery;
    QueWorkplaces: TSQLQuery;
    QueContractsLog: TSQLQuery;
    SaveDlg: TSaveDialog;
    SelectDirDlg: TSelectDirectoryDialog;
    SQLiteConnection: TSQLite3Connection;
    QueUsergroups: TSQLQuery;
    Transaction: TSQLTransaction;
    procedure SQLiteConnectionAfterConnect(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataMod: TDataMod;

implementation

{$R *.lfm}

{ TDataMod }
uses FormMain, FuncData;

procedure TDataMod.SQLiteConnectionAfterConnect(Sender: TObject);
begin
  if (DBEngine.DBType= dbtSQLite) then
	  SQLiteConnection.ExecuteDirect('PRAGMA busy_timeout = 1000;');

end;

{ TDataMod }

procedure TSQLite3Connection.DoInternalConnect;
begin
  inherited;
  if (DBEngine.DBType= dbtSQLite) AND (AtomicCommmit=1) then
    begin
    execsql('PRAGMA journal_mode = WAL;');
    end;
end;

end.

