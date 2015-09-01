unit FormSearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, ExtCtrls, Buttons, CheckLst, PopupNotifier, ComCtrls, FormMain, db,
  sqldb;

type TSearchCriteria = record
    Name: String;
    FieldName: String;
    DataFormat: TDataFormat;
    Fixed: Boolean;
end;
type
  { TFrmSearch }
  TFrmSearch = class(TForm)
    BtnClose: TBitBtn;
    BtnViewAll: TBitBtn;
    BtnSearch: TBitBtn;
    ChkCaseSensitive: TCheckBox;
    ChkClose: TCheckBox;
    ChkLstBoxSearch: TCheckListBox;
    DBGridSearchResult: TDBGrid;
    EdiSearch: TEdit;
    Label1: TLabel;
    LblResult: TLabel;
    LblSearchCriteria: TLabel;
    PanOptions: TPanel;
    PanLeft: TPanel;
    PanRight: TPanel;
    PopupNotifier1: TPopupNotifier;
    Splitter: TSplitter;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure BtnViewAllClick(Sender: TObject);
    procedure DBGridSearchResultCellClick(Column: TColumn);
    procedure EdiSearchKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    procedure ExecSearch(Table: String; SelectFields: String; ViewAll: Boolean=False);
    procedure Search(ViewAll: Boolean);
  public
    { public declarations }
    function Search(What: TWhatSearch): Boolean;
  end;

var
  FrmSearch: TFrmSearch;
  WhatSearch: TWhatSearch;
  SearchCriteria: array of TSearchCriteria;

resourcestring
	CriteriaEmployeeName= 'Name';
  CriteriaSurname1Name= 'Surname 1';
  CriteriaSurname2Name= 'Surname 2';

implementation

{$R *.lfm}


uses
  FuncData, DataModule;

{ TFrmSearch }

function TFrmSearch.Search(What: TWhatSearch): Boolean;
var
  i, CriteriaCount: Integer;
begin
  with TFrmSearch.Create(Application) do
  try
  WhatSearch:= What;
  case What of
 		wsEmployees: 	begin
    							CriteriaCount:= 3;
    							SetLength(SearchCriteria, CriteriaCount);
                  SearchCriteria[0].Name:= CriteriaEmployeeName;
                  SearchCriteria[0].FieldName:= 'Name_Employee';
                  SearchCriteria[0].DataFormat:= dtString;
                  SearchCriteria[0].Fixed:= True;
                  SearchCriteria[1].Name:= CriteriaSurname1Name;
                  SearchCriteria[1].FieldName:= 'Surname1_Employee';
                  SearchCriteria[1].DataFormat:= dtString;
                  SearchCriteria[1].Fixed:= True;
                  SearchCriteria[2].Name:= CriteriaSurname2Name;
                  SearchCriteria[2].FieldName:= 'Surname2_Employee';
                  SearchCriteria[2].DataFormat:= dtString;
                  SearchCriteria[2].Fixed:= False;
                  for i:= Low(SearchCriteria) to High(SearchCriteria) do
                  	begin
                  	ChkLstBoxSearch.Items.Add(SearchCriteria[i].Name);
                    ChkLstBoxSearch.Checked[i]:= SearchCriteria[i].Fixed;
                    end;
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[0].Title.Caption:= CriteriaEmployeeName;
                  DBGridSearchResult.Columns[0].FieldName:= 'Name_Employee';
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[1].Title.Caption:= CriteriaSurname1Name;
                  DBGridSearchResult.Columns[1].FieldName:= 'Surname1_Employee';
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[2].Title.Caption:= CriteriaSurname2Name;
                  DBGridSearchResult.Columns[2].FieldName:= 'Surname2_Employee';
						     	end;
  end; //case
  Result:= ShowModal = mrOK;
  finally
  FrmSearch.Free;
  FrmSearch:= nil;
  end;
end;
procedure TFrmSearch.ExecSearch(Table: String; SelectFields: String; ViewAll: Boolean=False);
var
  SQLSearch: TStringList;
  i, LastStrIdx: Integer;
  WhereInserted, ConcatenateWhere: Boolean;
  SearchStr, SearchField: String;
  p: TPoint;
  CompareOperator, Wildcard: String;
begin
  If (EdiSearch.Text='') and (ViewAll= False) then
    begin
   	p:= FrmMain.ScreenToClient(Mouse.CursorPos);
    FrmMain.PopNot.Title:= 'Error.';
    FrmMain.PopNot.Text:= 'Search string must be not blank.';
    FrmMain.PopNot.ShowAtPos(p.x, p.y);
    Exit;
    end;
	SQLSearch:= TStringList.Create;
  SQLSearch.Add('SELECT '+ SelectFields + ' FROM ' + Table);
  LastStrIdx:= 0;
  if ViewAll= False then
    begin
  	WhereInserted:= False;
	  ConcatenateWhere:= False;
  	for i:=0 to ChkLstBoxSearch.Items.Count-1 do
  		begin
	    if ChkLstBoxSearch.Checked[i]= True then
  	  	begin
    	  if WhereInserted= False then
      		begin
        	SQLSearch.Add('WHERE ');
	        WhereInserted:= True;
  	      end;
				if ConcatenateWhere= True then
	    	  SQLSearch.Add('OR ');
	      SearchField:= SearchCriteria[i].FieldName;
  	    case SearchCriteria[i].DataFormat of
    			dtString:	begin
      	  					CompareOperator:= ' LIKE ';
        	          Wildcard:= '%';
          	        end;
        	dtInteger:	begin
        							CompareOperator:= '=';
            	        Wildcard:= '';
        							end;
	      end; //case
  	    SearchStr:= '"'+EdiSearch.Text+Wildcard+'"';
    	  if ChkCaseSensitive.Checked= False then
      	  begin
        	SearchStr:= 'LOWER('+SearchStr+')';
        	SearchField:= 'LOWER('+SearchField+')';
        	end;
	      LastStrIdx:= SQLSearch.Count-1;
  	    SQLSearch.Strings[LastStrIdx]:= SQLSearch.Strings[LastStrIdx]+'('+SearchField+CompareOperator+SearchStr+')';
    	  ConcatenateWhere:= True;
      	end;
		  end; //for
  end;
  SQLSearch.Strings[LastStrIdx]:=  SQLSearch.Strings[LastStrIdx]+';';
  //Memo1.Lines.Assign(SQLSearch);
	FuncData.ExecSQL(DataMod.QueSearch, '', True, SQLSearch);
  LblResult.Caption:= IntToStr(DataMod.QueSearch.RecordCount)+ ' result/s';
end;

procedure TFrmSearch.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSearch.Search(ViewAll: Boolean);
begin
  case WhatSearch of
    wsEmployees: ExecSearch('Employees', 'ID_Employee, Name_Employee, Surname1_Employee, Surname2_Employee', ViewAll);
  end;
end;

procedure TFrmSearch.BtnSearchClick(Sender: TObject);
begin
  Search(False);
end;

procedure TFrmSearch.BtnViewAllClick(Sender: TObject);
begin
	Search(True);
end;

procedure TFrmSearch.DBGridSearchResultCellClick(Column: TColumn);
var
  Query: TSQLQuery;
  IDField: String;
  RecordIDSelec: variant;
begin
  case WhatSearch of
    wsEmployees:	begin
    							Query:= DataMod.QueEmployees;
                  IDField:= 'ID_Employee';
    							end;
  end; //case
	if DBGridSearchResult.DataSource.DataSet.State= dsInactive then exit;
  if Query.IsEmpty= True then Exit;
  with DBGridSearchResult.DataSource.DataSet do
  	begin
    RecordIDSelec:= FieldValues[IDField];
    if RecordIDSelec= Null then Exit;
    Query.Locate(IDField,RecordIDSelec,[loCaseInsensitive,loPartialKey]);
    FrmMain.UpdateNavRec;
    end;
  if ChkClose.Checked= True then Close;
end;

procedure TFrmSearch.EdiSearchKeyPress(Sender: TObject; var Key: char);
begin
	if Key= #13 then {if key is Enter}
  	begin
    Key:= #0; {eat the key}
    BtnSearchClick(Application); {execute the search}
   	end
end;

procedure TFrmSearch.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DataMod.QueSearch.Close;
  FrmMain.PopNot.Hide;
	CloseAction:= caFree;
end;

procedure TFrmSearch.FormCreate(Sender: TObject);
begin
  FrmMain.ImgLstBtn.GetBitmap(8, BtnSearch.Glyph);
	FrmMain.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(9, BtnViewAll.Glyph);
end;

end.

