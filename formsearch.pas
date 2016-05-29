unit FormSearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, ExtCtrls, Buttons, CheckLst, PopupNotifier, FormMain, db,
  sqldb, Globals, FuncData, ZDataset;

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
    CboFilter: TComboBox;
    ChkCaseSensitive: TCheckBox;
    ChkClose: TCheckBox;
    ChkLstBoxSearch: TCheckListBox;
    DBGridSearchResult: TDBGrid;
    EdiSearch: TEdit;
    Label1: TLabel;
    LblFilter: TLabel;
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
    procedure ChkCloseChange(Sender: TObject);
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
    function Search(What: TIDTable): Boolean;
  end;

var
  FrmSearch: TFrmSearch;
  WhatSearch: TIDTable;
  SearchCriteria: array of TSearchCriteria;

resourcestring
  lg_BlankSearchTitle= 'Error!';
  lg_BlankSearchText= 'Search string must be not blank.';
  lg_NoCriteriaTitle= 'Error!';
  lg_NoCriteriaText= 'One criteria must be selected at least.';
  lg_ResultCountText= 'result/s';
	lg_CriteriaEmployeeName= 'Name';
  lg_CriteriaSurname1Name= 'Surname 1';
  lg_CriteriaSurname2Name= 'Surname 2';

implementation

{$R *.lfm}

uses
  DataModule;

{ TFrmSearch }

function TFrmSearch.Search(What: TIDTable): Boolean;
var
  i, CriteriaCount: Integer;
begin
  with TFrmSearch.Create(Application) do
  try
  WhatSearch:= What;
   case What of
 	 	wtEmployees:	begin
    							LblFilter.Visible:= True;
     							CboFilter.Visible:= True;
    							CboFilter.ItemIndex:= FrmMain.CboFilter.ItemIndex;
							    end;
   end; //case
  case What of
 		wtEmployees: 	begin
    							CriteriaCount:= 3;
    							SetLength(SearchCriteria, CriteriaCount);
                  SearchCriteria[0].Name:= lg_CriteriaEmployeeName;
                  SearchCriteria[0].FieldName:= 'Name_Employee';
                  SearchCriteria[0].DataFormat:= dtString;
                  SearchCriteria[0].Fixed:= True;
                  SearchCriteria[1].Name:= lg_CriteriaSurname1Name;
                  SearchCriteria[1].FieldName:= 'Surname1_Employee';
                  SearchCriteria[1].DataFormat:= dtString;
                  SearchCriteria[1].Fixed:= True;
                  SearchCriteria[2].Name:= lg_CriteriaSurname2Name;
                  SearchCriteria[2].FieldName:= 'Surname2_Employee';
                  SearchCriteria[2].DataFormat:= dtString;
                  SearchCriteria[2].Fixed:= False;
                  for i:= Low(SearchCriteria) to High(SearchCriteria) do
                  	begin
                  	ChkLstBoxSearch.Items.Add(SearchCriteria[i].Name);
                    ChkLstBoxSearch.Checked[i]:= SearchCriteria[i].Fixed;
                    end;
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[0].Title.Caption:= lg_CriteriaEmployeeName;
                  DBGridSearchResult.Columns[0].FieldName:= 'Name_Employee';
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[1].Title.Caption:= lg_CriteriaSurname1Name;
                  DBGridSearchResult.Columns[1].FieldName:= 'Surname1_Employee';
                 	DBGridSearchResult.Columns.Add;
                 	DBGridSearchResult.Columns[2].Title.Caption:= lg_CriteriaSurname2Name;
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
  ResultCount: Integer;
  CriteriaSelectedCount: Integer;
begin
  if (EdiSearch.Text='') AND (ViewAll= False) then
    begin
   	p:= FrmMain.ScreenToClient(Mouse.CursorPos);
    FrmMain.PopNot.Title:= lg_BlankSearchTitle;
    FrmMain.PopNot.Text:= lg_BlankSearchText;
    FrmMain.PopNot.ShowAtPos(p.x, p.y);
    Exit;
    end
  else
  	begin
    CriteriaSelectedCount:= 0;
	  for i:=0 to ChkLstBoxSearch.Items.Count-1 do
	    begin
      if ChkLstBoxSearch.Checked[i]= True then
        Inc(CriteriaSelectedCount);
  	  end;
    if CriteriaSelectedCount=0 then
      begin
	    p:= FrmMain.ScreenToClient(Mouse.CursorPos);
  	  FrmMain.PopNot.Title:= lg_NoCriteriaTitle;
    	FrmMain.PopNot.Text:= lg_NoCriteriaText;
	    FrmMain.PopNot.ShowAtPos(p.x, p.y);
	    Exit;
      end;
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
	    	  SQLSearch.Add('OR ')
        	else
	    	  SQLSearch.Add('(');
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
	      LastStrIdx:= SQLSearch.Count-1;
  	    SQLSearch.Strings[LastStrIdx]:= SQLSearch.Strings[LastStrIdx]+'('+SearchField+CompareOperator+SearchStr+')';
    	  ConcatenateWhere:= True;
      	end;
		  end; //for
    if WhereInserted= True then
      SQLSearch.Add(')');
    case WhatSearch of
		wtEmployees:	begin
        	  			if WhereInserted= False then
      							begin
				        		SQLSearch.Add('WHERE ');
	      				  	WhereInserted:= True;
				  	      	end;
    							if (ConcatenateWhere= True) AND (CboFilter.ItemIndex<2) then
					    		  SQLSearch.Add('AND ');
    							case CboFilter.ItemIndex of
                    0: SQLSearch.Add('(Active_Employee="'+DBEngine.TrueValue+'")');
                    1: SQLSearch.Add('(Active_Employee="'+DBEngine.FalseValue+'")');
    							end; //case
                  end;
  	end; //case
  end;
  if ChkCaseSensitive.Checked= False then
    //SQLSearch.Add('COLLATE NOCASE');
  //SQLSearch.Strings[LastStrIdx]:=  SQLSearch.Strings[LastStrIdx]+';';
	FuncData.ExecSQL(DataMod.QueSearch, '', True, SQLSearch);
  ResultCount:= DataMod.QueSearch.RecordCount;
  LblResult.Caption:= ' ' + IntToStr(ResultCount)+ ' ' + lg_ResultCountText + ' ';
  if ResultCount>0 then
    LblResult.Color:= clMoneyGreen
    else
    LblResult.Color:= StringToColor('$AEAEE9');
end;

procedure TFrmSearch.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSearch.Search(ViewAll: Boolean);
begin
  case WhatSearch of
    wtEmployees: ExecSearch('Employees', 'ID_Employee, Name_Employee, Surname1_Employee, Surname2_Employee, Active_Employee', ViewAll);
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

procedure TFrmSearch.ChkCloseChange(Sender: TObject);
begin
	INIFile.WriteString('Search', 'CloseOnSelect', BoolToStr(ChkClose.Checked));
end;

procedure TFrmSearch.DBGridSearchResultCellClick(Column: TColumn);
var
  Query: TZQuery;
  IDField: String;
  RecordIDSelec: Variant;
  IsEmployeeActive: Boolean;
  CboFilterIndex: Integer;
begin
  case WhatSearch of
    wtEmployees:	begin
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
    case WhatSearch of
      wtEmployees:  begin;
                    IsEmployeeActive:= DBGridSearchResult.DataSource.DataSet.FieldByName('Active_Employee').AsBoolean;
                    case ISEmployeeActive of
                      False:  CboFilterIndex:= 1;
                      True:   CboFilterIndex:= 0;
                    end; //case
                    if FrmMain.CboFilter.ItemIndex<>CboFilterIndex then
                      if FrmMain.CboFilter.ItemIndex<2 then
                        begin
                        FrmMain.CboFilter.ItemIndex:= CboFilterIndex;
                        FrmMain.CboFilterChange(nil);
                        end;
                    end;
    end; //case
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
  //Load the Filter Items
  CboFilter.Items.Clear;
  CboFilter.Items.Add(lg_Filter_Active);
  CboFilter.Items.Add(lg_Filter_Inactive);
  CboFilter.Items.Add(lg_Filter_All);
  FrmMain.ImgLstBtn.GetBitmap(8, BtnSearch.Glyph);
	FrmMain.ImgLstBtn.GetBitmap(2, BtnClose.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(9, BtnViewAll.Glyph);
  ChkClose.Checked:= StrToBool(INIFile.ReadString('Search', 'CloseOnSelect', 'True'));
end;

end.
