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
  USERNAME_LENGTH= 12;
  PASSWORD_LENGTH= 12;
  SALT_LENGTH= 3;
  SUPERUSER_NAME= 'SUPERUSER';
  SUPERUSER_PASSWORD= '7110EDA4D09E';
  SUPERUSER_SALT= '4hT';

implementation

end.

