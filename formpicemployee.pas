unit FormPicEmployee;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  FrameSaveCancel, LCLType, Buttons, DbCtrls, DataModule, db;

type

  { TFrmPicEmployee }

  TFrmPicEmployee = class(TForm)
    BtnPasteFromClipboard: TBitBtn;
    BtnCopyToClipboard: TBitBtn;
    BtnClearPic: TBitBtn;
    BtnExportPic: TBitBtn;
    BtnLoadPic: TBitBtn;
    FraSaveCancel01: TFraSaveCancel;
    ImgEmployee: TImage;
    PanPicEmployee: TPanel;
    procedure BtnCopyToClipboardClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnClearPicClick(Sender: TObject);
    procedure BtnPasteFromClipboardClick(Sender: TObject);
    procedure BtnLoadPicClick(Sender: TObject);
    procedure BtnExportPicClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    procedure ActivateSavePic;
  public
    { public declarations }
  end;

var
  FrmPicEmployee: TFrmPicEmployee;
  Stream: TStream;
	EmployeeHasPic: Boolean;

resourcestring
	OpenDlg_Title= 'Select a photo';
	OpenDlg_Filter= 'All image files';
	OpenDlg_Error_Msg_01= 'Photo not loaded.';
	OpenDlg_Error_Msg_02= 'Possible cause: Photo format not valid';
  OpenDlg_Error_Msg_03= 'Please, check if photo format is jpg.';
	SaveDlg_Title= 'Save the photo';
	SaveDlg_Filter= 'All image files';
implementation

{$R *.lfm}

{ TFrmPicEmployee }
uses
  FormMain, FuncDlgs, Clipbrd, FuncData;

procedure TFrmPicEmployee.ActivateSavePic;
begin
  if FraSaveCancel01.BtnSave.Enabled= False then FraSaveCancel01.BtnSave.Enabled:= True;
end;

procedure TFrmPicEmployee.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPicEmployee.BtnCopyToClipboardClick(Sender: TObject);
begin
  if not(ImgEmployee.Picture.Bitmap= nil) then
		Clipboard.Assign(ImgEmployee.Picture);
end;

procedure TFrmPicEmployee.BtnSaveClick(Sender: TObject);
begin
	if not(ImgEmployee.Picture.Graphic= nil) then
    begin {save the pic-->}
    DataMod.QuePicsEmployees.Edit;
    if EmployeeHasPic= False then
    	begin
    	DataMod.QuePicsEmployees.Insert; {Creo una nueva entrada en el registro}
      DataMod.QuePicsEmployees.FieldValues['Employee_ID']:= DataMod.QueEmployees.FieldValues['ID_Employee'];
      end;
    Stream:= DataMod.QuePicsEmployees.CreateBlobStream(DataMod.QuePicsEmployees.FieldByName('Pic_Employee'), bmWrite);
    ImgEmployee.Picture.Graphic.SaveToStream(Stream);
    DataMod.QuePicsEmployees.Post;
    DataMod.QuePicsEmployees.ApplyUpdates;
	  DataMod.Transaction.CommitRetaining;
   	DataMod.QuePicsEmployees.Refresh;
 	  DataMod.Transaction.CommitRetaining;
    Stream.Free;
    end
  else
  	begin
  	if EmployeeHasPic= True then
      FuncData.DeleteTableRecord(DataMod.QuePicsEmployees);
    end;
	Close;

end;

procedure TFrmPicEmployee.BtnClearPicClick(Sender: TObject);
begin
  ImgEmployee.Picture:= nil;
  BtnExportPic.Enabled:= False;
  ActivateSavePic;
end;

procedure TFrmPicEmployee.BtnPasteFromClipboardClick(Sender: TObject);
begin
	if Clipboard.HasFormat(CF_Picture) then
		begin
    imgEmployee.Picture.LoadFromClipboardFormat(cf_Bitmap);
    if BtnExportPic.Enabled= False then
    	BtnExportPic.Enabled:= True;
    ActivateSavePic;
    end;
end;

procedure TFrmPicEmployee.BtnLoadPicClick(Sender: TObject);
var
  ChangePic: Boolean;
begin
  ChangePic:= FuncDlgs.OpenDlg(OpenDlg_Title,OpenDlg_Filter+' (*.jpg)|*.jpg|JPG (*.jpg)|*.jpg', PathApp,'');
  if ChangePic=True then
    begin
    try
    	ImgEmployee.Picture.LoadFromFile(FrmMain.OpenDlg.Files[0]);
	    BtnExportPic.Enabled:= True;
      ActivateSavePic;
    except
  	  on Error: Exception do
    	   if Error.ClassName= 'EInvalidGraphic' then
      			Application.MessageBox(PChar(OpenDlg_Error_Msg_01+#13#10+ OpenDlg_Error_Msg_02+#13#10 +OpenDlg_Error_Msg_03),'Error',MB_OK + MB_ICONERROR);
	    end;
    end;
end;

procedure TFrmPicEmployee.BtnExportPicClick(Sender: TObject);
var
  Change: Boolean;
begin
  Change:= FuncDlgs.SaveDlg(SaveDlg_Title,SaveDlg_Filter+' (*.jpg)|*.jpg|JPG (*.jpg)|*.jpg', PathApp,'foto.jpg');
  if Change= True then
     ImgEmployee.Picture.SaveToFile(FrmMain.SaveDlg.Files[0]);
end;

procedure TFrmPicEmployee.FormCreate(Sender: TObject);
begin
  FrmMain.ImgLstBtn.GetBitmap(1, BtnLoadPic.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(3, BtnExportPic.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(5, BtnCopyToClipboard.Glyph);
  FrmMain.ImgLstBtn.GetBitmap(6, BtnPasteFromClipboard.Glyph);
  //Load the current pic of the employee
  Stream:= DataMod.QueEmployees.CreateBlobStream(DataMod.QuePicsEmployees.FieldByName('Pic_Employee'), bmRead);
  if not(Stream= nil) then //If there is a pic for the employee
	   begin
     ImgEmployee.Picture.LoadFromStream(Stream);
     EmployeeHasPic:= True;
     end
     else
     begin
     BtnExportPic.Enabled:= False;
     EmployeeHasPic:= False;
     end;
  Stream.Free;
end;

end.

