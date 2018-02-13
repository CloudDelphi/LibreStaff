unit FuncApp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, resource, versiontypes, versionresource;

procedure FreeAndInvalidate(var obj);
function GetAppVersion: String;

implementation

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
//Use the next procedure instead of Free and Nil
procedure FreeAndInvalidate(var obj);
var
   temp : TObject;
begin
   temp := TObject(obj);
   Pointer(obj) := Pointer(1);
   temp.Free;
end;

end.

