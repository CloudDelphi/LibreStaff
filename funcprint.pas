unit FuncPrint;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LR_Class;

procedure Print(TemplateFilename: String; Report: TfrReport; PrintCompanyName:Boolean; Var_1: Boolean=False; Var1: Integer=0; ValueVar1: String='';Var_2: Boolean=False; Var2:Integer=0;ValueVar2:String='');

resourcestring
  lg_MmoTitleDataOfEmployee= 'Data of the employee';
  lg_MmoTitleAddress= 'Address';
  lg_MmoTitleContact= 'Contact';
  lg_MmoTitleCurrentContract= 'Current Contract';
  lg_MmoNameEmployee= 'Name:';
  lg_MmoIDNEmployee= 'ID:';
  lg_MmoIDCardEmployee= 'ID Card:';
  lg_MmoSSNEmployee= 'SSN:';
  lg_MmoCityEmployee= 'City:';
  lg_MmoStateEmployee= 'State:';
  lg_MmoZipCodeEmployee= 'ZIP Code:';
  lg_MmoPhoneEmployee= 'Phone:';
  lg_MmoCellEmployee= 'Cell Phone:';
  lg_MmoEMailEmployee= 'E-Mail:';
  lg_MmoDateInitContract= 'Date Init:';
  lg_MmoDateEndContract= 'Date End:';
  lg_MmoTypeContract= 'Type of Contract:';
  lg_MmoWorkplace= 'Workplace:';

implementation

uses FormMain;

procedure Print(TemplateFilename: String; Report: TfrReport; PrintCompanyName:Boolean; Var_1: Boolean=False; Var1: Integer=0; ValueVar1: String='';Var_2: Boolean=False; Var2:Integer=0;ValueVar2:String='');
begin
  Report.LoadFromFile(PathApp+'templates\'+TemplateFilename);
	if PrintCompanyName= True then TfrMemoView(Report.FindObject('MmoCompanyName')).Memo.Strings[0]:= CompanyName;
  TfrMemoView(Report.FindObject('MmoTitleDataOfEmployee')).Memo.Strings[0]:= lg_MmoTitleDataOfEmployee;
  TfrMemoView(Report.FindObject('MmoTitleAddress')).Memo.Strings[0]:= lg_MmoTitleAddress;
  TfrMemoView(Report.FindObject('MmoTitleContact')).Memo.Strings[0]:= lg_MmoTitleContact;
  TfrMemoView(Report.FindObject('MmoTitleCurrentContract')).Memo.Strings[0]:= lg_MmoTitleCurrentContract;
  TfrMemoView(Report.FindObject('MmoNameEmployee')).Memo.Strings[0]:= lg_MmoNameEmployee;
  TfrMemoView(Report.FindObject('MmoIDNEmployee')).Memo.Strings[0]:= lg_MmoIDNEmployee;
  TfrMemoView(Report.FindObject('MmoIDCardEmployee')).Memo.Strings[0]:= lg_MmoIDCardEmployee;
  TfrMemoView(Report.FindObject('MmoSSNEmployee')).Memo.Strings[0]:= lg_MmoSSNEmployee;
  TfrMemoView(Report.FindObject('MmoCityEmployee')).Memo.Strings[0]:= lg_MmoCityEmployee;
  TfrMemoView(Report.FindObject('MmoStateEmployee')).Memo.Strings[0]:= lg_MmoStateEmployee;
  TfrMemoView(Report.FindObject('MmoZIPCodeEmployee')).Memo.Strings[0]:= lg_MmoZipCodeEmployee;
  TfrMemoView(Report.FindObject('MmoPhoneEmployee')).Memo.Strings[0]:= lg_MmoPhoneEmployee;
  TfrMemoView(Report.FindObject('MmoCellEmployee')).Memo.Strings[0]:= lg_MmoCellEmployee;
  TfrMemoView(Report.FindObject('MmoEMailEmployee')).Memo.Strings[0]:= lg_MmoEMailEmployee;
  TfrMemoView(Report.FindObject('MmoDateInitContract')).Memo.Strings[0]:= lg_MmoDateInitContract;
  TfrMemoView(Report.FindObject('MmoDateEndContract')).Memo.Strings[0]:= lg_MmoDateEndContract;
  TfrMemoView(Report.FindObject('MmoTypeContract')).Memo.Strings[0]:= lg_MmoTypeContract;
  TfrMemoView(Report.FindObject('MmoWorkplace')).Memo.Strings[0]:= lg_MmoWorkplace;
  if Var_1= True then Report.Variables[Var1]:= ''''+ValueVar1+'''';
  if Var_2= True then Report.Variables[Var2]:= ''''+ValueVar2+'''';
  if ReportPreview= True then
    Report.ShowReport
    else Report.PrepareReport;
end;

end.

