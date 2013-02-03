unit sps_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Math,MufasaTypes,sps_types;
type
  TSPSWaypoint = record
  Name: string;
  PointList: TPointArray;
  end;
  TSPSPath = record
    Map: string;
    MapPaths: array of TSPSWaypoint;
  end;
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

procedure  ToArray(var V: TPointArray; const R: TPoint);

procedure ClearDoubleTPA(var TPA: TPointArray);


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
 s:='';
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
  i,j,d,l: integer;
  AreaTPA:TPointArray;
  s:string;
  XArea,YArea: integer;
begin
  SetLength(AreaTPA,0);
  s:= 'SPS_Setup(RUNESCAPE_SURFACE,[';
  for i:=0 to pth.Count-1 do
  begin
    wp:=pth[i];
     for d:=0 to wp.PointList.Count-1 do
      begin
        pt:=wp.PointList.Items[d];
        XArea:=floor(pt.x/400);
        YArea:=floor(pt.y/400);
        ToArray(AreaTPA,Point(XArea,YArea));
       end;
  end;
  ClearDoubleTPA(AreaTPA);
  l:=length(AreaTPA);
  for j:=0 to l-1 do
    begin
      s:=s+#39+IntToStr(AreaTPA[j].x)+'_'+IntToStr(AreaTPA[j].y)+#39+','
      end;
  if (S[Length(S)] in ['.',',']) then delete(s,length(s),1);
  S:=s+']);';
  AreaTPA:=nil;
  result:=s;
end;

procedure ToArray(var V: TPointArray; const R: TPoint);
var
  Len: integer;
begin
  Len := Length(V);
  SetLength(V, Len + 1);
  V[Len] := R;
end;

procedure ClearDoubleTPA(var TPA: TPointArray);
var
  i,j,k : integer;
  flag  : boolean;
  tmp     : TPointArray;
Begin
  i:=0;
  SetLength(tmp,0);
  while i < Length(TPA) do
  begin
    flag:=false;
    k:=0;
    while (k < Length(tmp)) and (not flag) do
    begin
      flag:=tmp[k]=TPA[i];
      Inc(k);
    end;
    if not flag then
    begin
      k:=Length(tmp);
      SetLength(tmp,k+1);
      tmp[k]:=TPA[i];
      Inc(i);
    end
    else
     begin
      j:=i;
      while j < length (TPA)-1 do
      begin
        TPA[j]:=TPA[j+1];
        inc(j);
      end;
      SetLength(TPA,Length(TPA)-1);
    end;
  end;
end;


end.

