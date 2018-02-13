unit FormReports;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DBDateTimePicker, DateTimePicker, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, Buttons, ComCtrls, StdCtrls, DBGrids,
  CheckLst, ValEdit, Globals, FuncData;

type

	TQueryCriteria = record
  	FieldName: String;
	  Criteria: String;
  	DataFormat: TDataFormat;
	end;

	TReportField= class(TObject)
    private
 			fName, fTitle: String;
    public
      property Name: string read fName write fName;
			property Title: string read fTitle write fTitle;
      constructor Create(stName : string; stTitle: string);
  end;

type
	TReport= class(TObject)
    private
      fTable: TTable;
 			fReportFieldsList, fAvailableReportFieldsList: TList;
    public
      property Table: TTable read fTable write fTable;
      property ReportFieldsList: TList read fReportFieldsList write fReportFieldsList;
			property AvailableReportFieldsList: TList read fAvailableReportFieldsList write fAvailableReportFieldsList;
      constructor Create(tbTable: TTable; lsReportFieldsList: TList; lsAvailableReportFieldsList: TList);
      destructor Destroy; override;
  end;

  { TFrmReports }

  TFrmReports = class(TForm)
    BtnClose: TBitBtn;
    BtnQuery: TBitBtn;
    BtnAddField: TBitBtn;
    BtnRemoveField: TBitBtn;
    BtnUpField: TBitBtn;
    BtnDownField: TBitBtn;
    ChkActByName: TCheckBox;
    ChkActByBirthday: TCheckBox;
    ChkActBySurname1: TCheckBox;
    DatDateBirthEnd: TDateTimePicker;
    DBGridQueryResult: TDBGrid;
    EdiNameEmployee: TEdit;
    EdiSurname1Employee: TEdit;
    GroupBox1: TGroupBox;
    LblDateBirthEnd: TLabel;
    LblDateBirthInit: TDateTimePicker;
    LblNameEmployee: TLabel;
    LblSurname1Employee1: TLabel;
    LstBoxFields: TListBox;
    LstBoxAvailableFields: TListBox;
    LLblDateBirthInit: TLabel;
    PagCriterion: TPageControl;
    PanBottom2: TPanel;
    PanTop: TPanel;
    TabCriterionPersonalData: TTabSheet;
    TabeCriterionContract: TTabSheet;
    TabFields: TTabSheet;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnQueryClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    Report: TReport;
		Criteria: array of TQueryCriteria;
    procedure AddCriteria(FieldName: String; CriteriaStr: String; DataFormat: TDataFormat);
  public

  end;

var
  FrmReports: TFrmReports;

implementation

{$R *.lfm}

uses
  DataModule;

constructor TReportField.Create(stName: String; stTitle: String);
begin
	self.Name:= stName;
	self.Title:= stTitle;
end;

constructor TReport.Create(tbTable: TTable; lsReportFieldsList: TList; lsAvailableReportFieldsList: TList);
begin
  self.Table:= tbTable;
	self.ReportFieldsList:= lsReportFieldsList;
	self.AvailableReportFieldsList:= lsAvailableReportFieldsList;
end;

destructor TReport.Destroy;
begin
  FreeAndNil(fReportFieldsList);
  FreeAndNil(fAvailableReportFieldsList);
  inherited;
end;

{ TFrmReports }

procedure TFrmReports.FormCreate(Sender: TObject);
var
  i: Integer;
  ReportFieldsStrings: TStringList;
begin
	DataMod.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
  DataMod.ImgLstBtn.GetBitmap(16, BtnQuery.Glyph);
  Report:= TReport.Create(Tables[4], TList.Create, TList.Create);
  Report.ReportFieldsList.Add(TReportField.Create('Name_Employee', 'Name of Employee'));
  Report.ReportFieldsList.Add(TReportField.Create('Surname1_Employee', 'Surname 1 of Employee'));
  Report.ReportFieldsList.Add(TReportField.Create('Surname2_Employee', 'Surname 2 of Employee'));
  ReportFieldsStrings:= TStringList.Create;
  for i:=0 to (Report.ReportFieldsList.Count-1) do
   	begin
		ReportFieldsStrings.Add(TReportField(Report.ReportFieldsList.Items[i]).Title);
  	end;
  LstBoxFields.Items.Assign(ReportFieldsStrings);
  FreeAndNil(ReportFieldsStrings);
end;

procedure TFrmReports.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmReports.BtnQueryClick(Sender: TObject);
var
  SQLQuery: TStringList;
  i: Integer;
	SelectFields: String;
  HighCriteria: Integer;
begin
  for i:=0 to (Report.ReportFieldsList.Count-1) do
  	begin
    SelectFields:= SelectFields + ' ' + TReportField(Report.ReportFieldsList.Items[i]).Name;
    if (i<Report.ReportFieldsList.Count-1) then
    	begin
    	SelectFields:= SelectFields + ',';
      end;
    end;
  SetLength(Criteria,0);
  SQLQuery:= TStringList.Create;
  SQLQuery.Add('SELECT '+ SelectFields + ' FROM ' + Report.Table.Name);
  if ChkActByName.Checked= True then
    begin
    AddCriteria('Name_Employee', EdiNameEmployee.Text, dtString);
    end;
  if ChkActBySurname1.Checked= True then
    begin
    AddCriteria('Surname1_Employee', EdiSurname1Employee.Text, dtString);
    end;
  if (Criteria<>nil) then
    begin
	  SQLQuery.Add('WHERE');
    HighCriteria:= High(Criteria);
  	for i:= 0 to HighCriteria do
    	begin
      if (i>0) then
        begin
        SQLQuery.Add('AND');
        end;
      SQLQuery.Add('('+Criteria[i].FieldName+'='+'"'+Criteria[i].Criteria+'")');
  	  end;
    end;
  FuncData.ExecSQL(DataMod.QueQuery, '', True, SQLQuery);
  SQLQuery.Free;
end;

procedure TFrmReports.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: Integer;
begin
  //Before delete Report, It's mandatory to Free the ReportFields objects
  for i := 0 to Report.ReportFieldsList.Count - 1 do
		begin;
	  TReportField(Report.ReportFieldsList[i]).Free
		end;
  FreeAndNil(Report);
  DataMod.QueQuery.Close;
  CloseAction:= caFree;
end;

procedure TFrmReports.AddCriteria(FieldName: String; CriteriaStr: String; DataFormat: TDataFormat);
var
  LenghtCriteria: Integer;
begin
  SetLength(Criteria, Length(Criteria)+1);
  LenghtCriteria:= Length(Criteria);
	Criteria[LenghtCriteria-1].FieldName:= FieldName;
	Criteria[LenghtCriteria-1].Criteria:= CriteriaStr;
	Criteria[LenghtCriteria-1].DataFormat:= DataFormat;
end;

end.

