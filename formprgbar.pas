unit FormPrgBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls;

type

  { TFrmPrgBar }

  TFrmPrgBar = class(TForm)
    LblPrg: TLabel;
    _PrgBar: TProgressBar;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmPrgBar: TFrmPrgBar;

implementation

{$R *.lfm}

{ TFrmPrgBar }

procedure TFrmPrgBar.FormCreate(Sender: TObject);
begin
	_PrgBar.Caption:= 'Loading/creating databases...';
end;

end.

