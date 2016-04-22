unit Globals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, INIfiles;

var
	PathApp, SQLiteLibraryName, DatabaseName, DatabasePath: String;
  INIFile: TINIFile;
  AccessControl: Boolean;

const
  USERNAME_LENGHT= 12;
  PASSWORD_LENGHT= 12;
  SUPERUSER_NAME= 'SUPERUSER';
  SUPERUSER_PASSWORD= '1234';

implementation

end.

