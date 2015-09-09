unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqlite3conn, sqldb;

type

  { TDataModule1 }

  TDataMod = class(TDataModule)
    DsoTypeContracts: TDataSource;
    DsoSearch: TDataSource;
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    Connection: TSQLite3Connection;
    DsoWorkplaces: TDataSource;
    DsoContractsLog: TDataSource;
    QueEmployees: TSQLQuery;
    QuePicsEmployees: TSQLQuery;
    QueSearch: TSQLQuery;
    QueTypeContracts: TSQLQuery;
    QueWorkplaces: TSQLQuery;
    QueContractsLog: TSQLQuery;
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


end.

