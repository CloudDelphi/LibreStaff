unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, db, sqlite3conn, sqldb,
  IBConnection;

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
    DsoUsers: TDataSource;
    DsoTypeContracts: TDataSource;
    DsoSearch: TDataSource;
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    DsoPrint: TDataSource;
    DsoWorkplaces: TDataSource;
    DsoContractsLog: TDataSource;
    DsoUsergroups: TDataSource;
    QuePermissions: TZQuery;
    QueContractsLog: TZQuery;
    QuePrint: TZQuery;
    QueVirtual: TZQuery;
    QueWorkplaces: TZQuery;
    QueUsers: TZQuery;
    QueTypeContracts: TZQuery;
    QuePicsEmployees: TZQuery;
    QueUsergroups: TZQuery;
    QueSearch: TZQuery;
    Connection: TZConnection;
    QueConfig: TZQuery;
    QueEmployees: TZQuery;
    procedure ConnectionAfterConnect(Sender: TObject);
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
uses FormMain;

procedure TDataMod.ConnectionAfterConnect(Sender: TObject);
begin
  Connection.ExecuteDirect('PRAGMA busy_timeout = 1000');
end;

{ TDataMod }

procedure TSQLite3Connection.DoInternalConnect;
begin
  inherited;
  if AtomicCommmit=1 then
    begin
    execsql('PRAGMA journal_mode = WAL');
    end;
end;

end.

