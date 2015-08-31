unit FormPreferences;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, frameclose, LCLType;

type

  { TFrmPreferences }

  TFrmPreferences = class(TForm)
    BtnChangeDtbPath: TBitBtn;
    EdiDtbPath: TEdit;
    FraClose1: TFraClose;
    ImgLstPreferences: TImageList;
    LblDatabasePath: TLabel;
    LstViewPreferences: TListView;
    PagPreferences: TPageControl;
    Splitter1: TSplitter;
    TabDatabase: TTabSheet;
    procedure BtnChangeDtbPathClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LstViewPreferencesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure TabDatabaseShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmPreferences: TFrmPreferences;

resourcestring
  LstView_Caption_Item_0= 'Database';
	SelectDirDlg_Title= 'Select the path for the database (data.db)';
  SelectDirDlg_Error_Title= 'ERROR!';
  SelectDirDlg_Error_Msg= 'The file "data.db" does not exist in this path.';

implementation

{$R *.lfm}

{ TFrmPreferences }
uses
    FormMain, FuncDlgs;

procedure TFrmPreferences.LstViewPreferencesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
	Case Item.Index of
  	0: 	PagPreferences.ActivePageIndex:= Item.Index;
  end;
end;

procedure TFrmPreferences.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPreferences.FormCreate(Sender: TObject);
begin
  LstViewPreferences.Items[0].Caption:= LstView_Caption_Item_0;
end;

procedure TFrmPreferences.BtnChangeDtbPathClick(Sender: TObject);
var
  ChangePath: Boolean;
  NewPath: String;
begin
  ChangePath:= FuncDlgs.SelectDirDlg(SelectDirDlg_Title, EdiDtbPath.Text);
  if ChangePath=True then
    begin
    NewPath:= FrmMain.SelectDirDlg.FileName+'\';
    if FileExists(NewPath+'data.db') then
    	begin
	    INIFile.WriteString('Database','Path',FrmMain.SelectDirDlg.FileName);
  	  EdiDtbPath.Text:= NewPath;
      end
    	else Application.MessageBox(PChar(SelectDirDlg_Error_Msg), PChar(SelectDirDlg_Error_Title), MB_OK + MB_ICONERROR);
    end;
  FrmPreferences.Show;
end;

procedure TFrmPreferences.TabDatabaseShow(Sender: TObject);
begin
   EdiDtbPath.Text:= INIFile.ReadString('Database','Path',PathApp+'data\');
end;

end.

