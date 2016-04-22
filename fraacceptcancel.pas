unit FraAcceptCancel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, StdCtrls, Buttons;

type

  { TFraAcceptCancel }

  TFraAcceptCancel = class(TFrame)
    BtnCancel: TBitBtn;
    BtnAccept: TBitBtn;
    PanBottom: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  protected
    procedure Loaded; override;
  end;

implementation

{$R *.lfm}


uses
  FormMain;

procedure TFraAcceptCancel.Loaded;
begin
  inherited;
  FrmMain.ImgLstBtn.GetBitmap(4, BtnAccept.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(2, BtnCancel.Glyph);
end;

end.

