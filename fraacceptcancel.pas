unit FraAcceptCancel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons;

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
  DataModule;

procedure TFraAcceptCancel.Loaded;
begin
  inherited;
  DataMod.ImgLstBtn.GetBitmap(4, BtnAccept.Glyph);
  DataMod.ImgLstBtn.GetBitmap(2, BtnCancel.Glyph);
end;

end.

