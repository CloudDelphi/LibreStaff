unit FrameSaveCancel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons;

type

  { TFraSaveCancel }

  TFraSaveCancel = class(TFrame)
    BtnCancel: TBitBtn;
    BtnSave: TBitBtn;
    PanSaveCancel: TPanel;
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

procedure TFraSaveCancel.Loaded;
begin
  inherited;
  DataMod.ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
  DataMod.ImgLstBtn.GetBitmap(2, BtnCancel.Glyph);
end;

end.

