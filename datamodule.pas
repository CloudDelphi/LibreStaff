unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqlite3conn, sqldb, IBConnection;

type
  TSQLite3Connection = class(sqlite3conn.TSQLite3Connection)
  protected
    procedure DoInternalConnect; override;
  end;

type
  { TDataModule1 }
  TDataMod = class(TDataModule)
    DsoConfig: TDataSource;
    DsoTypeContracts: TDataSource;
    DsoSearch: TDataSource;
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    DsoPrint: TDataSource;
    DsoWorkplaces: TDataSource;
    DsoContractsLog: TDataSource;
    QueConfig: TSQLQuery;
    QuePrint: TSQLQuery;
    QueVirtual: TSQLQuery;
    QueEmployees: TSQLQuery;
    QuePicsEmployees: TSQLQuery;
    QueSearch: TSQLQuery;
    QueTypeContracts: TSQLQuery;
    QueWorkplaces: TSQLQuery;
    QueContractsLog: TSQLQuery;
    Connection: TSQLite3Connection;
    Transaction: TSQLTransaction;
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

procedure TSQLite3Connection.DoInternalConnect;
begin
  inherited;
  execsql('PRAGMA journal_mode = WAL');
end;

end.

