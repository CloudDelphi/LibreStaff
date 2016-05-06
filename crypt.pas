unit Crypt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DCPsha1;

function GenerateSalt(SaltLength: Integer): String;
function HashString(StringToHash: String): String;

implementation

function HashString(StringToHash: String): String;
var
  Hash: TDCP_sha1;
  Digest: array [1..20] of byte;
  ResultStr: String;
  i: Integer;
begin
  Hash:= TDCP_sha1.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(StringToHash); //calculate the hesh-sum
    Hash.Final(Digest);
    for i:=1 to 20 do
      begin
      ResultStr:=ResultStr+inttohex(Digest[i],1);
      end;
    Result:= ResultStr;
  finally
    Hash.Free;
  end;
 end;

function GenerateSalt(SaltLength: Integer): String;
var
  Chars: string;
begin
  Randomize;
  //string with all possible chars
  Chars:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&/()=?#@,;:.-_{}[]';
  Result:= '';
  repeat
    Result:= Result + Chars[Random(Length(Chars)) + 1];
  until (Length(Result)= SaltLength)
end;

end.

