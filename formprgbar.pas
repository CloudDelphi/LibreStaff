unit FormPrgBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TFrmPrgBar }

  TFrmPrgBar = class(TForm)
    PrgBar: TProgressBar;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmPrgBar: TFrmPrgBar;

implementation

{$R *.lfm}

end.

