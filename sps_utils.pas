unit sps_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Math,sps_types;
//
function Eq(aValue1, aValue2: string): boolean;

function PointToSpsPoint(pt: TPoint): TSpsPoint;

function CreateSpsPoint(x,y: integer): TSpsPoint;

function SpsPointToPoint(pt: TSpsPoint): TPoint;
//
function GenSpaces(cnt: integer): string;
//
function GetFileName(fname : String) : String;

function GetAreaCodes(const pth: TPath): string;
implementation

function Eq(aValue1, aValue2: string): boolean;
//--------------------------------------------------------
begin
  Result := AnsiCompareText(Trim(aValue1),Trim(aValue2))=0;
end;

function PointToSpsPoint(pt: TPoint): TSpsPoint;
begin
  result.x:=pt.x;
  result.y:=pt.y;
end;

function CreateSpsPoint(x, y: integer): TSpsPoint;
begin
  result.x:=x;
  result.y:=y;
end;

function SpsPointToPoint(pt: TSpsPoint): TPoint;
begin
  result.x:=pt.x;
  result.y:=pt.y;
end;

function GenSpaces(cnt: integer): string;
var
  i: integer;
  s: string;
begin
 s:=#32;
 for i := 0 to cnt -1 do
  begin
     s:=s+#32;
    end;
  result:=s;
end;

function GetFileName(fname: String): String;
begin
  result:=StringReplace(ExtractFileName(fname),ExtractFileExt(fname),'',[]);
end;

function GetAreaCodes(const pth: TPath): string;
var
  pt: TSpsPoint;
  wp: TWaypoint;
  i,j,d: integer;
  st: TStringList;
  s:string;
  XArea,YArea: integer;
begin
  st:=TStringList.Create;
  st.Duplicates:=dupIgnore;
  st.Sorted:=true;
  s:= 'SPS_Setup(RUNESCAPE_SURFACE,[';
  for i:=0 to pth.Count-1 do
  begin
    wp:=pth[i];
     for d:=0 to wp.PointList.Count-1 do
      begin
        pt:=wp.PointList[i];
        XArea:=floor(pt.x/400);
        YArea:=floor(pt.y/400);
        if j = 0 then
        begin
         St.Add(#39+IntToStr(XArea)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea)+'_'+IntToStr(YArea+1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea+1)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea+1)+#39);
         end;
        if (j > 0) then
        begin
         St.Add(','+#39+IntToStr(XArea)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea)+#39);
         St.Add(','+#39+IntToStr(XArea)+'_'+IntToStr(YArea+1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea+1)+#39);
         St.Add(','+#39+IntToStr(XArea+1)+'_'+IntToStr(YArea-1)+#39);
         St.Add(','+#39+IntToStr(XArea-1)+'_'+IntToStr(YArea+1)+#39);
         end;
        if (j = wp.PointList.Count-1) then
          St.Add('];');
      end;
  end;
  for i:=0 to st.Count-1 do
   begin
     s:=s+st.Strings[i];
   end;
  st.Free;
  result:=s;
end;

end.

