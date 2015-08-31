unit DataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, sqlite3conn, sqldb;

type

  { TDataModule1 }

  TDataMod = class(TDataModule)
    DsoPicsEmployees: TDataSource;
    DsoEmployees: TDataSource;
    Connection: TSQLite3Connection;
    QueEmployees: TSQLQuery;
    QuePicsEmployees: TSQLQuery;
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

