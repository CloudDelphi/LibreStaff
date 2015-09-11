unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqlite3conn, sqldb;

type

  { TDataModule1 }

  TDataMod = class(TDataModule)
    DsoConfig: TDataSource;
    DsoTypeContracts: TDataSource;
    DsoSearch: TDataSource;
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    Connection: TSQLite3Connection;
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

