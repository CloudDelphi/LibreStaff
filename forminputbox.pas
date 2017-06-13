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
    procedure BtnAcceptClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure EdiInputKeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    { public declarations }
    function CustomInputBox(IptCaption, IptPrompt, DefaultValue: String;
      MaxLength:Integer; out OutValue:String): Boolean;
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

procedure TFrmInputBox.BtnAcceptClick(Sender: TObject);
begin
  ModalResult:= mrOK;
end;

procedure TFrmInputBox.BtnCancelClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

function TFrmInputBox.CustomInputBox(IptCaption, IptPrompt, DefaultValue: String;
      MaxLength:Integer; out OutValue:String): Boolean;
begin
  with TFrmInputBox.Create(Application) do
  try
    LblCaption.Caption:= IptCaption;
    LblPrompt.Caption:= IptPrompt;
    EdiInput.Text:= DefaultValue;
    EdiInput.MaxLength:= MaxLength;
    if ShowModal= mrOk then
      begin
      Result:= True;
      OutValue:= EdiInput.Text;
      end
    else
      begin
      Result:= False;
      OutValue:= '';
      end;
  finally
    FrmInputBox.Free;
    FrmInputBox:= nil;
  end;
end;

end.

