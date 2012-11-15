unit sps_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Graphics;
type

{ TSpsPoint }

 TSpsPoint = class (TCollectionItem)
  public
     x: integer;
     y: integer;
      constructor Create(Col: TCollection); override;
      destructor Destroy; override;
    end;

 { TSpsPointList }

 TSpsPointList = class (TCollection)
  private
    function GetItems(Index: Integer): TSpsPoint;
  public
    function AddItem: TSpsPoint;

    constructor Create;

    property Items[Index: Integer]: TSpsPoint read GetItems; default;
 end;

 { TWaypoint }

 TWaypoint = class (TCollectionItem)
     public
      Name: string;
      Color: TColor;
  //    MapType: integer;//map type: 1 - global, 0 - custom.
      PointList: TSpsPointList;
      constructor Create(Col: TCollection); override;
      destructor Destroy; override;
    end;

 { TPath }

 TPath = class (TCollection)
  private
    function GetItems(Index: Integer): TWaypoint;
  public
    MapFile: string;
    MapType: integer;
    MapImg: string;

    function AddItem: TWaypoint;

    constructor Create;

   { function FindByName(aFileName: string): TWaypoint; }

    property Items[Index: Integer]: TWaypoint read GetItems; default;
 end;

implementation

{ TPath }

function TPath.GetItems(Index: Integer): TWaypoint;
begin
  Result := TWaypoint(inherited Items[Index]);
end;

function TPath.AddItem: TWaypoint;
begin
   Result := TWaypoint(inherited Add());
end;

constructor TPath.Create;
begin
  inherited Create(TWaypoint);
end;
{
function TPath.FindByName(aFileName: string): TWaypoint;
var I: Integer;
begin
 Result := nil;
  for I := 0 to Count - 1 do
    if AnsiCompareText(Trim(Items[i].Name),Trim(aFileName))=0 then
    begin
      Result := Items[i];
      Break;
    end;
end;  }

{ TWaypoint }

constructor TWaypoint.Create(Col: TCollection);
begin
  inherited Create(Col);
  PointList:=TSpsPointList.Create;
end;

destructor TWaypoint.Destroy;
begin
  inherited Destroy;
end;

{ TSpsPointList }

function TSpsPointList.GetItems(Index: Integer): TSpsPoint;
begin
  Result := TSpsPoint(inherited Items[Index]);
end;

function TSpsPointList.AddItem: TSpsPoint;
begin
  Result := TSpsPoint(inherited Add());
end;

constructor TSpsPointList.Create;
begin
  inherited Create(TSpsPoint);
end;

{ TSpsPoint }

constructor TSpsPoint.Create(Col: TCollection);
begin
  inherited Create(Col);
end;

destructor TSpsPoint.Destroy;
begin
  inherited Destroy;
end;

end.

