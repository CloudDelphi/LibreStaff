unit FormMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, DbCtrls, StdCtrls, DBGrids, Buttons,
  DataModule, types, FormPicEmployee;

type
  { TFrmMain }
  TFrmMain = class(TForm)
    BtnSave: TBitBtn;
    BtnDelete: TBitBtn;
    BtnNew: TBitBtn;
    DBENameEmployee: TDBEdit;
    DBNav: TDBNavigator;
    ImgLstBtn: TImageList;
    ImgExit: TImage;
    LblNameEmployee: TLabel;
    LblNavRec: TLabel;
    OpenDlg: TOpenDialog;
    PagMain: TPageControl;
    PagEmployees: TPageControl;
    Panel1: TPanel;
    Pan: TPanel;
    PanPicEmployee: TPanel;
    PanNavRec: TPanel;
    PanMain: TPanel;
    PicEmployee: TDBImage;
    SaveDlg: TSaveDialog;
    StatusBar1: TStatusBar;
    TabEmployees: TTabSheet;
    TabSheet1: TTabSheet;
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure DBNavClick(Sender: TObject; Button: TDBNavButtonType);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ImgExitClick(Sender: TObject);
    procedure PanClick(Sender: TObject);
    procedure PicEmployeeClick(Sender: TObject);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    procedure UpdateNavRec;
  public
    { public declarations }
  end;

var
  FrmMain: TFrmMain;
  PathApp: String;
  SentenceSQL: TStringList;

resourcestring
	LblNavRecOf= 'of';

implementation

{$R *.lfm}

{ TFrmMain }

uses
    FuncData;
//------------------------------------------------------------------------------
//Private functions & procedures
//------------------------------------------------------------------------------
procedure TFrmMain.UpdateNavRec;
begin
  CurrentRec:= DataMod.DsoEmployees.DataSet.RecNo;
  LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+LblNavRecOf +' '+ IntToStr(TotalRecs);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TFrmMain.FormCreate(Sender: TObject);
begin
     PathApp:= ExtractFilePath(Paramstr(0));
     SQLiteLibraryName:= PathApp+'sqlite3.dll';
     FuncData.ConnectDatabase;
     SentenceSQL:= TStringList.Create;
     DataMod.Connection.Databasename:= PathApp + 'data/data.db';
     FuncData.ExecSQL(DataMod.QueEmployees, 'SELECT * from Employees;');
     if (DataMod.QueEmployees.IsEmpty= True) then
        begin
        BtnSave.Enabled:= False;
        BtnDelete.Enabled:= False;
        end;
     FuncData.ExecSQL(DataMod.QuePicsEmployees, 'SELECT * from PicsEmployees WHERE PicsEmployees.Employee_ID=:ID_Employee;');
     ImgLstBtn.GetBitmap(0, BtnNew.Glyph);
     ImgLstBtn.GetBitmap(2, BtnDelete.Glyph);
     ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
     TotalRecs:= DataMod.QueEmployees.RecordCount;
		 UpdateNavRec;
end;
procedure TFrmMain.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QueEmployees);
end;

procedure TFrmMain.DBNavClick(Sender: TObject; Button: TDBNavButtonType);
begin
  inherited; //<-- to execute the default onclick event
	UpdateNavRec;
end;
procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DataMod.Transaction.Active:= False;
  DataMod.Connection.Connected:= False;
end;
procedure TFrmMain.BtnNewClick(Sender: TObject);
begin
   if FuncData.AppendTableRecord(DataMod.QueEmployees)= True then
	   begin
		 Inc(TotalRecs, 1);
     UpdateNavRec;
  	 if (BtnSave.Enabled= False) then
         begin
         BtnSave.Enabled:= True;
         BtnDelete.Enabled:= True;
         end;
	   end;
end;
procedure TFrmMain.BtnDeleteClick(Sender: TObject);
var
  NameEmployee: String;
begin
  NameEmployee:= DataMod.QueEmployees.FieldByName('Name_employee').AsString;
	if FuncData.DeleteTableRecord(DataMod.QueEmployees, True, NameEmployee)= True then
  	begin
    Dec(TotalRecs, 1);
    UpdateNavRec;
    if (DataMod.QueEmployees.IsEmpty= True) then
    	begin
      BtnSave.Enabled:= False;
      BtnDelete.Enabled:= False;
      end;
    end;
end;
procedure TFrmMain.ImgExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMain.PanClick(Sender: TObject);
begin

end;

procedure TFrmMain.PicEmployeeClick(Sender: TObject);
begin
     if (DataMod.QueEmployees.IsEmpty= False) then
          begin
          Application.CreateForm(TFrmPicEmployee, FrmPicEmployee);
          FrmPicEmployee.ShowModal;
          end;
end;

end.
