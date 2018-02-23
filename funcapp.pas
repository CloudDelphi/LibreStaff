unit FuncApp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, resource, versiontypes, versionresource, Controls, Forms,
  PopupNotifier, ExtCtrls;

type
  TAutoclosePopupNotifier= class(TPopupNotifier)
  private
	  Timer: TTimer;
		procedure OnTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent);override;
	end;

 var
	PopNotifierObj: TAutoclosePopupNotifier;

function CheckIfDatabaseNeedUpdate: Boolean;
procedure FreeAndInvalidate(var obj);
function GetAppVersion: String;
procedure PopNotifier(AOwner:TComponent; Title: string; Text: string; Point: TPoint);
function SplitDatabaseVersion(DatabaseVersion: string): TStrings;

implementation

uses
  FuncData, Globals;

{TAutoclosePopupNotifier}
constructor TAutoclosePopupNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
 	Timer:= TTimer.Create(Self);
  Timer.Interval:= AUTOCLOSE_POPUPNOTIFIER_TIME;
  Timer.OnTimer:= @OnTimer;
  Timer.Enabled:= True;
end;

procedure TAutoclosePopupNotifier.OnTimer(Sender: TObject);
begin
	self.Hide;
end;

function GetAppVersion: String;  //For FPC 2.6.X
var
	Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;
begin
  Result:= '';
	try
    Stream:= TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
    try
      vr:= TVersionResource.Create;
      try
        vr.SetCustomRawDataStream(Stream);
        fi:= vr.FixedInfo;
        Result:= ' ' + IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1])+
               '.'+IntToStr(fi.FileVersion[2]) + '.' + IntToStr(fi.FileVersion[3]);
        vr.SetCustomRawDataStream(nil)
      finally
        vr.Free
      end;
    finally
      Stream.Free
    end
  except
  end
end;

function CheckIfDatabaseNeedUpdate: Boolean;
var
  SubstringsList_DatabaseVersion, SubstringsList_DatabaseDefaultVersion: TStrings;
  i: Integer;
begin
  SubstringsList_DatabaseVersion:= SplitDatabaseVersion(DBEngine.DatabaseVersion);
  SubstringsList_DatabaseDefaultVersion:= SplitDatabaseVersion(DATABASE_DEFAULT_VERSION);
  //Now compare->
 	Result:= FALSE; //By default is FALSE
  for i:=0 to (DATABASE_VERSION_SUBSTRINGS_COUNT-1) do
		begin
    if (SubstringsList_DatabaseDefaultVersion[i]>SubstringsList_DatabaseVersion[i]) then
    	begin
    	Result:= TRUE;
	  	Break;
      end;
    end;
end;

function SplitDatabaseVersion(DatabaseVersion: string): TStrings;
begin
	ExtractStrings([DATABASE_VERSION_SEPARATOR], [], PChar(DatabaseVersion), Result);
end;

//Use the next procedure instead of Free and Nil
procedure FreeAndInvalidate(var obj);
var
   temp : TObject;
begin
   temp:= TObject(obj);
   Pointer(obj):= Pointer(1);
   temp.Free;
end;

procedure PopNotifier(AOwner:TComponent; Title: string; Text: string; Point: TPoint);
begin
 	if Assigned(PopNotifierObj) then
		FreeAndNil(PopNotifierObj);
  PopNotifierObj:= TAutoclosePopupNotifier.Create(AOwner);
  PopNotifierObj.Title:= Title;
 	PopNotifierObj.Text:= Text;
  PopNotifierObj.ShowAtPos(Point.x, Point.y);
end;

end.

