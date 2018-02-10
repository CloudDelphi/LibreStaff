unit Globals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, INIfiles, PopupNotifier, ExtCtrls, Graphics;

//Custom PopupNotifier with a autoclose delay
type TCustomPopupNotifier= class(TPopupNotifier)
		private
    Counter, Seconds: Integer;
		procedure OnPopupTimer(Sender: TObject);
    public
 		PopupTimer: TTimer;
		constructor Create(Delay: Integer=0); overload;
  end;

type
	TDataFormat= (dtNull, dtString, dtInteger, dtBoolean, dtDate, dtChar, dtText,
  							dtBlob);

type
	TAction= (acEdit, acAdd);

type TPermission= record
  //Edit employees
  EditEmployee, AddEmployee, DeleteEmployee: Boolean;
	//Show Tabs
  ShowTabAddress: Boolean;
  //Admin
  AdminControlAccess, AdminDatabase: Boolean;
  end;

type TUser= class(TObject)
  var
    Permissions: TPermission;
  public
    Name: String;
  end;

var
	PathApp, PathIni, SQLiteLibraryName: String;
  INIFile: TINIFile;
  Lang, FallBacklang: String;
  AccessControl, RememberUsername: Boolean;
  User: TUser;

const
  AVATARS_COUNT= 399;
  DATABASE_NAME= 'librestaff';
  DATABASE_EXTENSION= '.db';
  EDIT_ERROR_COLOR= clRed;
  MYSQL_COLLATION= 'utf8_unicode_ci';
  MYSQL_ENGINE_VERSION= '5.6.27.0';
  PASSWORD_LENGTH= 12;
  PATH_SEPARATOR=
  {$ifdef Win32}
    '\';
  {$else}
		'/';
  {$endif}
  RANDOMIDLENGHT= 9;
  SALT_LENGTH= 3;
  SQLITE_ENGINE_VERSION= '3.13.0.0';
  SUPERUSER_GROUP= 'SUPERUSERS';
  SUPERUSER_NAME= 'SUPERUSER';
  SUPERUSER_PASSWORD= 'B887275D13AA5DB8FBDFF89576D245F03B7E9C48';
  SUPERUSER_SALT= 'zYJ';
  TABLES_COUNT= 9;
  USERNAME_LENGTH= 12;

implementation

//Custom Popup Notifier procedures
constructor TCustomPopupNotifier.Create(Delay: Integer=0);
begin
  inherited create(nil);
 	if (Delay>0) then
	  begin
	  PopupTimer:= TTimer.Create(Self);
  	with PopupTimer do
	  	begin
      Counter:= 0;
      Seconds:= Delay;
      Interval:= 1000;
  		Enabled:= TRUE;
  		OnTimer:= @OnPopupTimer; //The @ avoid parameters
	    end;
  	end;
end;

procedure TCustomPopupNotifier.OnPopupTimer(Sender: TObject);
begin
  Inc(Counter, 1); //Increase the counter
  if (Counter>= Seconds) then //If counter equal to delay in seconds...
  	begin
    Free; //...then free the popup
    end;
end;

end.

