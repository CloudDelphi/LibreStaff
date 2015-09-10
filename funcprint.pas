unit FuncPrint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LR_Class;

procedure Print(TemplateFilename: String; Report: TfrReport; PrintCompanyName:Boolean; Var_1: Boolean=False; Var1: Integer=0; ValueVar1: String='';Var_2: Boolean=False; Var2:Integer=0;ValueVar2:String='');

implementation

uses FormMain;

procedure Print(TemplateFilename: String; Report: TfrReport; PrintCompanyName:Boolean; Var_1: Boolean=False; Var1: Integer=0; ValueVar1: String='';Var_2: Boolean=False; Var2:Integer=0;ValueVar2:String='');
begin
  Report.LoadFromFile(PathApp+'templates\'+TemplateFilename);
	if PrintCompanyName= True then TfrMemoView(Report.FindObject('MmoCompanyName')).Memo.Strings[0]:= CompanyName;
  if Var_1= True then Report.Variables[Var1]:= ''''+ValueVar1+'''';
  if Var_2= True then Report.Variables[Var2]:= ''''+ValueVar2+'''';
  if ReportPreview= True then
    Report.ShowReport
    else Report.PrepareReport;
end;

end.

