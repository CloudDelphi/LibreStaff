unit FormInputBox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FraAcceptCancel;

type

  { TFrmInputBox }

  TFrmInputBox = class(TForm)
    EdiInput: TEdit;
    FraAcceptCancel1: TFraAcceptCancel;
    LblPrompt: TLabel;
    LblCaption: TLabel;
    procedure EdiInputKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
    function CustomInputBox(IptCaption, IptPrompt:String; Default: String='';
      MaxLength:Integer=255): String;
  end;

var
  FrmInputBox: TFrmInputBox;

implementation

{$R *.lfm}

procedure TFrmInputBox.EdiInputKeyPress(Sender: TObject; var Key: char);
begin
  if (Key= #13) then //if ENTER key pressed, close modal
    begin
    FraAcceptCancel1.BtnAccept.Click;
    end
  else if (Key= #27) then //if ESC key pressed, cancel modal
    begin
     FraAcceptCancel1.BtnCancel.Click;
    end;
end;

function TFrmInputBox.CustomInputBox(IptCaption, IptPrompt:String; Default: String='';
  MaxLength:Integer=255): String;
var
  i: Integer;
begin
  with TFrmInputBox.Create(Application) do
  try
    LblCaption.Caption:= IptCaption;
    LblPrompt.Caption:= IptPrompt;
    EdiInput.Text:= Default;
    EdiInput.MaxLength:= MaxLength;
    ShowModal;
    Result:= EdiInput.Text;
  finally
    FrmInputBox.Free;
    FrmInputBox:= nil;
  end;
end;

end.

