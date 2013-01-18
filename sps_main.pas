unit sps_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, GR32, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ComCtrls, ExtCtrls, GR32_PNG, GR32_Resamplers,
  GR32_Backends_Generic, GR32_Image, LCLIntf, LCLType, sps_types, sps_base,
  sps_utils, Bitmaps;

type

  { TSps_Editor }

  TSps_Editor = class(TForm)
    ImageList1: TImageList;
    Label2: TLabel;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    odlg: TOpenDialog;
    JumpMenu: TPopupMenu;
    MapRender: TPaintBox;
    PaintBox32_1: TPaintBox32;
    pBoxMenu: TPopupMenu;
    sdlg: TSaveDialog;
    DrawTimer: TTimer;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    wpList: TListView;
    pBox: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    procedure DrawTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MapRenderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapRenderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MapRenderPaint(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure pBoxChange(Sender: TObject);
    procedure pBoxSelect(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure wpListClick(Sender: TObject);
    procedure wpListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure wpListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
    procedure SetPen(aColor: TColor);
  public
    //jump menu
    procedure FillAreaList;
    procedure FillColor;
    procedure SetScrollPos(pt: TPoint);
    procedure GoToArea(index: integer);
    procedure JumpTo(Sender: TObject);
    procedure CreateJumpMenu;
    procedure ToComboBox;
    procedure ToListView(wp: TWaypoint);
    procedure DrawPath();
  end;
const
  MaxPath = 16;
var
  Sps_Editor: TSps_Editor;
  //path colors
  co:array [0..15] of Tcolor;
  //Drawing routine
  Bground,PathBuffer: TBitmap32;//for drawing routines
  //Jump Town menu
  JumpMenu: TPopupMenu;
  AreaPoint: array[0..18] of TPoint;
  AreaName: array[0..18] of string;
  //
  sps_path: TWPContainer;
  //
  CurrIndex,CurrSubIndex: integer;
  //
  CodeType: integer;
  //


implementation
uses Code_Frm, GR32_Polygons;
{$R *.lfm}

{ TSps_Editor }
function toFixedPoint(pt: TPoint):TFixedPoint;
begin
  result:=TFixedPoint(pt);
end;

function TPAToFPA(TPA: TArrayOfPoint):TArrayOfFixedPoint;
var
  i: integer;
begin
  for i:=0 to length(tpa) -1 do
     begin
       setlength(result,i+1);
       result[i]:=toFixedPoint(TPA[i]);
     end;
end;

procedure DrawSrcToDst(Src, Dst: TBitmap32);
var
  R: TKernelResampler;
begin
  R := TKernelResampler.Create(Src);
  R.Kernel := TLanczosKernel.Create;
  Dst.Draw(Dst.BoundsRect, Src.BoundsRect, Src);
end;

procedure LoadPng(Filename: string;Src: TBitmap32);
begin
   with TPortableNetworkGraphic32.Create do
   try
    LoadFromFile(FileName);
    AssignTo(Src);
   finally
    Free;
   end
end;


procedure TSps_Editor.MenuItem2Click(Sender: TObject);
begin
  sps_path:=TWPContainer.Create;
  odlg.Filter:='RS map files|*.png';
  if odlg.Execute then
   sps_path.MapFile:=odlg.FileName else exit;
  // Bmp.LoadFromFile(sps_path.MapFile);
  LoadPng(sps_path.MapFile,bground);
  if (bground.Width<500) or (bground.Height<500) then
   begin
    ShowMessage('Not correct rs map file');
    exit;
   end;
  sps_path.MapType:=0;
  if (bground.Width=7271) and (bground.Height=6630) then
   begin
   sps_path.MapType:=1;
   JumpMenu:=TPopupMenu.Create(Self);
   FillAreaList;
   end;
  if not (sps_path.MapType = 1) then
   JumpMenu.Free;
  // Bground.Assign(bmp.Bitmap);
  // Bground.BitmapHandle:=Bmp.Bitmap.Handle;
 {  PathBuffer.Width:=Bground.Width;
   PathBuffer.Height:=Bground.Height;}
   PathBuffer.SetSize(Bground.Width,Bground.Height);
   //Pathbuffer.Canvas.Draw(0,0,Bground);
  // Bground.DrawTo(PathBuffer.Canvas.Handle,0,0);
   DrawSrcToDst(Bground,PathBuffer);
   MapRender.Width:=Bground.Width;
   MapRender.Height:=Bground.Height;
  PathBuffer.DrawTo(MapRender.Canvas.Handle,0,0);
  PBox.Items.Clear;
  wpList.Items.Clear;
  //bmp.Bitmap.SaveToFile('C:/Test.bmp');
 // bmp.Free;
 // Bmp.Draw(MapRender.Canvas,0,0);
end;

procedure TSps_Editor.MenuItem3Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TSps_Editor.MenuItem5Click(Sender: TObject);
begin
  CodeType:=0;
  MenuItem6.Checked:=false;
  MenuItem12.Checked:=false;
  MenuItem5.Checked:=true;
end;

procedure TSps_Editor.MenuItem6Click(Sender: TObject);
begin
  CodeType:=2;
  MenuItem6.Checked:=true;
  MenuItem12.Checked:=false;
  MenuItem5.Checked:=false;
end;

procedure TSps_Editor.pBoxChange(Sender: TObject);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  ToListView(sps_path.Items[CurrIndex]);
end;

procedure TSps_Editor.pBoxSelect(Sender: TObject);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  CurrIndex:=Pbox.ItemIndex;
end;

procedure TSps_Editor.ToolButton10Click(Sender: TObject);
var
  bmp: TMufasaBitmap;
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  if not (sps_path.MapType = 0) then exit;
  if not FileExists(sps_path.MapFile) then
   begin
   ShowMessage('File not exists:'+#32+sps_path.MapFile);
   exit;
   end;
  Bmp:=TMufasaBitmap.Create;
  Bmp.LoadFromFile(sps_path.MapFile);
  sps_path.MapImg:=bmp.ToString;
  sdlg.Filter:='SPS map files|*.spm';
  if sdlg.Execute then sps_path.SaveToFile(sdlg.FileName);
  Bmp.Free;
end;
function SPS_FillPath(aFileName: String;var Path: TSPSPath):boolean;
var
  Storage:TWPContainer;
  i,j: integer;
  Len: integer;
begin
  result:=false;
 // if not eq(ExtractFormat(aFileName),'spm') then exit;
  try
  Storage:=TWPContainer.Create;
  Storage.LoadFromFile(aFileName);
  SetLength(path.MapPaths,Storage.Count);
  Path.Map:=Storage.MapImg;
  for i:=0 to Storage.Count - 1 do
   begin
  //   mDebug('First stage: OK;');
     Path.MapPaths[i].Name:=Storage.Items[i].Name;
     Len:= Storage.Items[i].PointList.Count;
     SetLength(Path.MapPaths[i].PointList,len);
   //  Path.MapPaths[i].Name:=Storage.Items[i].Name;
      for j:=0 to Storage.Items[i].PointList.Count - 1 do
        begin
          Path.MapPaths[i].PointList[j].x:=Storage.Items[i].PointList[j].x;
          Path.MapPaths[i].PointList[j].y:=Storage.Items[i].PointList[j].y;
         // mDebug('Second stage: OK;');
        end;
   end;

  except
   // Raise Exceprion
  end;
  result:=true;
end;

procedure TSps_Editor.ToolButton11Click(Sender: TObject);
var
  mbmp: TMufasaBitmap;
  Bitmaps: TMBitmaps;
  sps: TSPSPath;
  s: string;
  i: integer;
begin
  drawtimer.Enabled:=false;
 // bmp:= TBGRABitmap.Create;
  mbmp:= TMufasaBitmap.Create;
  sps_path:=TWPContainer.Create;
  pbox.Items.Clear;
  wplist.Items.Clear;
  currindex:=0;
  CurrSubIndex:=0;
  odlg.Filter:='SPS map files|*.spm';
  if odlg.Execute then s:=odlg.FileName else exit;
   sps_path.LoadFromFile(s);
   Bitmaps:=TMBitmaps.Create(self);
   Bitmaps.CreateBMPFromString(500,500,sps_path.MapImg);
   MBmp:=Bitmaps.GetBMP(0);
  // bground.BitmapHandle:=mbmp.ToTBitmap.Handle;
   bground.Assign(mbmp.ToTBitmap);
   SPS_FillPath(s,sps);
  if not (sps_path.MapType = 1) then
   JumpMenu.Free;
  //Bground.Assign(bmp);
   PathBuffer.SetSize(Bground.Width,Bground.Height);
 // Pathbuffer.Canvas.Draw(0,0,Bground);
 // Bground.DrawTo(PathBuffer.Canvas.Handle,0,0);
  DrawSrcToDst(Bground,PathBuffer);
  MapRender.Width:=Bground.Width;
  MapRender.Height:=Bground.Height;
 // MapRender.Canvas.Draw(0,0,PathBuffer);
  PathBuffer.DrawTo(MapRender.Canvas.Handle,0,0);
  ToComboBox;
  DrawPath;
  DrawTimer.Enabled:=true;
 // Bitmaps.Free;
 // mbmp.Free;
 // bmp.Free;
end;

procedure TSps_Editor.ToolButton3Click(Sender: TObject);
begin
  MenuItem10.Click;
end;

procedure TSps_Editor.ToolButton4Click(Sender: TObject);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  if (CurrIndex = MaxPath) then exit;
  sps_path.Invert(CurrIndex,co[CurrIndex+1]);
  toComboBox;
end;

procedure TSps_Editor.ToolButton5Click(Sender: TObject);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  sdlg.Filter:='SPS editor map files|*.sps';
  if sdlg.Execute then sps_path.SaveToFile(sdlg.FileName);
end;

procedure TSps_Editor.ToolButton6Click(Sender: TObject);
//var
 // bmp:TBGRABitmap;
begin
  {drawtimer.Enabled:=false;
 // bmp:= TBGRABitmap.Create;
  sps_path:=TWPContainer.Create;
  pbox.Items.Clear;
  wplist.Items.Clear;
  currindex:=0;
  CurrSubIndex:=0;
  odlg.Filter:='SPS editor map files|*.sps';
  if odlg.Execute then sps_path.LoadFromFile(odlg.FileName) else exit;
  bground.LoadFromFile(sps_path.MapFile);
  if (bground.Width<500) or (bground.Height<500) and (sps_path.MapType = 0) then
   begin
    ShowMessage('Not correct map image file');
    exit;
   end;
  if (bground.Width=7271) and (bground.Height=6630) and (sps_path.MapType = 1)  then
   begin
   JumpMenu:=TPopupMenu.Create(Self);
   FillAreaList;
   end;
  if not (sps_path.MapType = 1) then
   JumpMenu.Free;
  PathBuffer.SetSize(Bground.Width,Bground.Height);
  PathBuffer.CanvasBGRA.Draw(0,0,Bground);
  MapRender.Width:=Bground.Width;
  MapRender.Height:=Bground.Height;
  //MapRender.Canvas.Draw(0,0,PathBuffer);
  PathBuffer.Draw(MapRender.Canvas,0,0,true);
  ToComboBox;
  DrawPath;
  DrawTimer.Enabled:=true;
  //bmp.Free; }
end;

procedure TSps_Editor.ToolButton9Click(Sender: TObject);
var
  st: TStringList;
  f: TCodeForm;
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  st:=TStringList.Create;
  sps_path.GenerateScript(st,CodeType);
  f:=TCodeForm.Create(nil);
  f.DrawCode(st);
  f.Show;
end;

procedure TSps_Editor.wpListClick(Sender: TObject);
begin

end;

procedure TSps_Editor.wpListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  if not assigned(wpList.Selected) then  exit;
  if Key = VK_DELETE then
    begin
     sps_path.Items[CurrIndex].PointList.Delete(CurrSubIndex);
    end;
  toListView(sps_path.Items[CurrIndex]);
end;

procedure TSps_Editor.wpListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  if not assigned(wpList.Selected) then  exit;
  CurrSubIndex:=wpList.Selected.Index;
end;

procedure TSps_Editor.SetPen(aColor: TColor);
var
  MyPen: TPen;
  MyBrush: TBrush;
begin
  MyPen:=TPen.Create;
  MyBrush:=TBrush.Create;
  MyPen.Style:=psDash;
  MyPen.Width:=1;
  MyPen.Color:=aColor;
  MyBrush.Color:=aColor;
  PathBuffer.Canvas.Pen:=MyPen;
  PathBuffer.Canvas.Brush:=MyBrush;
  MyPen.Free;
  MyBrush.Free;
end;

procedure TSps_Editor.FormCreate(Sender: TObject);
begin
  Bground:=TBitmap32.Create;
  PathBuffer:=TBitmap32.Create;
  FillColor;
  CodeType:=0;
  MenuItem6.Checked:=false;
  MenuItem5.Checked:=true;
  pBox.ItemIndex:=0;
  CurrIndex:=0;
  CurrSubIndex:=0;
  self.Caption:='Path maker for SPS v. 2.5.2 by Cynic' + {$IFDEF WINDOWS}'[WIN]'{$ELSE}'[LIN]'{$ENDIF};
end;

procedure TSps_Editor.FormDestroy(Sender: TObject);
begin
  DrawTimer.Enabled:=false;
  Bground.Free;
  PathBuffer.Free;
end;

procedure TSps_Editor.DrawTimerTimer(Sender: TObject);
begin
  DrawPath;
  MapRender.Refresh;
end;

procedure TSps_Editor.MapRenderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  oSpsPoint: TSpsPoint;
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  if (CurrIndex = MaxPath) then exit;
   if (ssShift in Shift)=true then
   begin
     sps_path.Items[CurrIndex].PointList[CurrSubIndex].x:=X;
     sps_path.Items[CurrIndex].PointList[CurrSubIndex].y:=Y;
     ToListView(sps_path.Items[CurrIndex]);
   end else begin
   if (Button = mbLeft)=true then begin
      oSpsPoint:=sps_path.Items[CurrIndex].PointList.AddItem;
      oSpsPoint.x:=x;
      oSpsPoint.y:=y;
      ToListView(sps_path.Items[CurrIndex]);
  end;
   end;
end;

procedure TSps_Editor.MapRenderMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  With StatusBar1 do
   begin
     Panels[0].Text:='X coord:'+#32+IntToStr(X);
     Panels[1].Text:='Y coord:'+#32+IntToStr(Y);
   end;
end;

procedure TSps_Editor.MapRenderPaint(Sender: TObject);
begin
  //MapRender.Canvas.Draw(0,0,PathBuffer);
  PathBuffer.DrawTo(MapRender.Canvas.Handle,0,0);
end;

procedure TSps_Editor.MenuItem10Click(Sender: TObject);
var
 WP: TWaypoint;
 UserString: string;
begin
 if not assigned(sps_path) then exit;
 if InputQuery('Add new path:', 'Type in new path name', UserString)
  then
   begin
    WP:=sps_path.AddItem;
    wp.Name:=UserString;
    ToComboBox;
    WP.Color:=co[CurrIndex];
   end
 else exit;
end;

procedure TSps_Editor.MenuItem11Click(Sender: TObject);
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  sps_path.Delete(CurrIndex);
  if not (sps_path.Count > 0) then begin wpList.Clear; {PathBuffer.Canvas.Draw(0,0,bground);}Bground.DrawTo(PathBuffer.Canvas.Handle,0,0); end;
  ToComboBox;
end;

procedure TSps_Editor.MenuItem12Click(Sender: TObject);
begin
  CodeType:=1;
  MenuItem6.Checked:=false;
  MenuItem12.Checked:=true;
  MenuItem5.Checked:=false;
end;


procedure TSps_Editor.FillAreaList;
begin
  AreaPoint[0]:=Point(5010,3896);//Al-Kharid
  AreaName[0]:='Al-Kharid';
  AreaPoint[1]:=Point(2922,5546);//Ape Atoll
  AreaName[1]:='Ape Atoll';
  AreaPoint[2]:=Point(2008,2386);//Barbarian outpost
  AreaName[2]:='Barbarian outpost';
  AreaPoint[3]:=Point(4162,2962);//Barbarian village
  AreaName[3]:='Barbarian village';
  AreaPoint[4]:=Point(3466,2668);//Burthorpe
  AreaName[4]:='Burthorpe';
  AreaPoint[5]:=Point(3122,2895);//Catherby
  AreaName[5]:='Catherby';
  AreaPoint[6]:=Point(4207,3616);//Draynor Village
  AreaName[6]:='Draynor Village';
  AreaPoint[7]:=Point(2419,3435);//East Ardougne
  AreaName[7]:='East Ardougne';
  AreaPoint[8]:=Point(4234,2673);//Egeville
  AreaName[8]:='Egeville';
  AreaPoint[9]:=Point(3856,3236);//Falador
  AreaName[9]:='Falador';
  AreaPoint[10]:=Point(4765,3710);//Lumbridge
  AreaName[10]:='Lumbridge';
  AreaPoint[11]:=Point(199,978);//Lunar Isle
  AreaName[11]:='Lunar Isle';
  AreaPoint[12]:=Point(1661,3699);//Ourania
  AreaName[12]:='Ourania';
  AreaPoint[13]:=Point(1175,1901);//Piscatoris
  AreaName[13]:='Piscatoris';
  AreaPoint[14]:=Point(2450,1901);//Rellekka
  AreaName[14]:='Rellekka';
  AreaPoint[15]:=Point(2687,2709);//Seers Village
  AreaName[15]:='Seers Village';
  AreaPoint[16]:=Point(1956,4000);//Tree Gnome Village
  AreaName[16]:='Tree Gnome Village';
  AreaPoint[17]:=Point(4687,2935);//Varrock
  AreaName[17]:='Varrock';
  AreaPoint[18]:=Point(2164,4300);//Yanille
  AreaName[18]:='Yanille';
  CreateJumpMenu;
end;

procedure TSps_Editor.FillColor;
begin
  co[0]:=clWhite;
  co[1]:=clRed;
  co[2]:=clBlue;
  co[3]:=clYellow;
  co[4]:=clGreen;
  co[5]:=clBlack;
  co[6]:=clLime;
  co[7]:=clAqua;
  co[8]:=clFuchsia;
  co[9]:=clMaroon;
  co[10]:=clTeal;
  co[11]:=clNavy;
  co[12]:=clSilver;
  co[13]:=clPurple;
  co[14]:=clSkyBlue;
  co[15]:=clCream;
end;

procedure TSps_Editor.SetScrollPos(pt: TPoint);
begin
  ScrollBox1.HorzScrollBar.Position:=pt.x-250;
  ScrollBox1.VertScrollBar.Position:=pt.y-250;
end;

procedure TSps_Editor.GoToArea(index: integer);
var
  pt: TPoint;
begin
  case index of
  0: pt:=AreaPoint[0];
  1: pt:=AreaPoint[1];
  2: pt:=AreaPoint[2];
  3: pt:=AreaPoint[3];
  4: pt:=AreaPoint[4];
  5: pt:=AreaPoint[5];
  6: pt:=AreaPoint[6];
  7: pt:=AreaPoint[7];
  8: pt:=AreaPoint[8];
  9: pt:=AreaPoint[9];
  10: pt:=AreaPoint[10];
  11: pt:=AreaPoint[11];
  12: pt:=AreaPoint[12];
  13: pt:=AreaPoint[13];
  14: pt:=AreaPoint[14];
  15: pt:=AreaPoint[15];
  16: pt:=AreaPoint[16];
  17: pt:=AreaPoint[17];
  18: pt:=AreaPoint[18];
  end;
 SetScrollPos(pt);
end;

procedure TSps_Editor.JumpTo(Sender: TObject);
var
  i: integer;
begin
  i:=TMenuItem(Sender).Tag;
  GoToArea(i);
end;

procedure TSps_Editor.CreateJumpMenu;
var
  jump: array of TMenuItem;
  i: integer;
begin
  SetLength(jump,19);
  for i:=0 to Length(AreaName)-1 do
     begin
        jump[i]:=TMenuItem.Create(self);
        jump[i].Caption:=AreaName[i];
        jump[i].OnClick:=@JumpTo;
        jump[i].Tag:=i;
       end;
 for i:=0 to Length(jump)-1 do
    begin
      JumpMenu.Items.Insert(i,jump[i]);
    end;
 //MapRender.PopupMenu:=JumpMenu;
 Sps_Editor.PopupMenu:=JumpMenu;
end;

procedure TSps_Editor.ToComboBox;
var
  i: integer;
begin
  Pbox.Items.Clear;
  if not (sps_path.Count > 0) then exit;
  for i:=0 to sps_path.Count -1 do
     begin
       pbox.Items.Add(sps_path.Items[i].Name);
       ToListView(sps_path.Items[i]);
     end;
  pBox.ItemIndex:=i;
  CurrIndex:=i;
end;

procedure TSps_Editor.ToListView(wp: TWaypoint);
var
  i: integer;
  oListItem: TListItem;
begin
 wpList.Items.Clear;
 if not (sps_path.Count > 0) then exit;
 for i:=0 to wp.PointList.Count - 1 do
    begin
      oListItem:=wpList.Items.Add;
      oListItem.Caption:=IntToStr(i);
      oListItem.SubItems.Add(IntToStr(wp.PointList[i].x));
      oListItem.SubItems.Add(IntToStr(wp.PointList[i].y));
    end;
end;

procedure TSps_Editor.DrawPath();
 procedure DrawSpsPoint(SpsPoint: TSpsPoint);
  begin
   PathBuffer.Canvas.Ellipse( SpsPoint.x - 3, SpsPoint.y - 3, SpsPoint.x + 3, SpsPoint.y + 3 );
  end;
 procedure DrawWaypoint(wp: TWaypoint);
 var
   TPA: TArrayOfPoint;
   i,t: integer;
  begin
   SetPen(wp.Color);
   SetLength(TPA,wp.PointList.Count);
   for i:=0 to wp.PointList.Count - 1 do
      begin
        TPA[i]:=SpsPointToPoint(wp.PointList[i]);
        DrawSpsPoint(wp.PointList[i]);
      end;
    PathBuffer.Canvas.Polyline(TPA);
    TPA:=nil;
  end;
var
  i: integer;
begin
  if not assigned(sps_path) then exit;
  if not (sps_path.Count > 0) then exit;
  DrawSrcToDst(bground,pathbuffer);
  for i:=0 to sps_path.Count - 1 do
     begin
       DrawWaypoint(sps_path.Items[i]);
     end;
end;

end.

