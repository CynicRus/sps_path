unit sps_base;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Variants,Graphics,Math, XMLRead, XMLWrite, Dom, sps_types, sps_utils;

type

{ TWPContainer }

 TWPContainer = class(TPath)
  public
    procedure LoadFromFile(aFileName: string);
    procedure SaveToFile(aFileName: string);
    procedure Invert(aNodeIndex: integer;aColor: TColor);
    procedure GenerateScript(var st: TStringList;CodeType: integer);
    end;

implementation

{ TWPContainer }

procedure TWPContainer.LoadFromFile(aFileName: string);
  procedure DoLoadPoints(aParentNode: TDOMNode; Waypoint: TWaypoint);
   var
     I: Integer;
     oSpsPoint: TSpsPoint;
     oNode,oNode1: TDOMNode;
   begin
     for I := 0 to aParentNode.ChildNodes.Count - 1 do
     begin
       oSpsPoint:=Waypoint.PointList.AddItem;

       oNode:=aParentNode.ChildNodes[i];

       oSpsPoint.x:=StrToInt(VarToStr(oNode.Attributes.GetNamedItem('x').NodeValue));
       oSpsPoint.y:=StrToInt(VarToStr(oNode.Attributes.GetNamedItem('y').NodeValue));
     end;
   end;
   procedure DoLoadWaypoints(aParentNode: TDOMNode);
   var
     I: Integer;
     oNode: TDOMNode;
     Waypoint: TWaypoint;
   begin
     MapFile:=aParentNode.Attributes.GetNamedItem('mapfile').NodeValue;
     MapType:=StrToInt(VarToStr(aParentNode.Attributes.GetNamedItem('maptype').NodeValue));
     MapImg:=VarToStr(aParentNode.Attributes.GetNamedItem('mapimg').NodeValue);
     for I := 0 to aParentNode.ChildNodes.Count - 1 do
     begin
       Waypoint:=AddItem;
       oNode:=aParentNode.ChildNodes[i];
       Waypoint.Name:= oNode.Attributes.GetNamedItem('name').NodeValue;
       Waypoint.Color:= StringtoColor(VarToStr(oNode.Attributes.GetNamedItem('color').NodeValue));
      // Waypoint.MapType:= StrToInt(VarToStr(oNode.Attributes.GetNamedItem('maptype').NodeValue));
       DoLoadPoints(oNode, Waypoint);
     end;
   end;

 var
   oXmlDocument: TXmlDocument;
 begin
   ReadXMLFile(oXmlDocument,aFileName);

   DoLoadWaypoints (oXmlDocument.DocumentElement);

   FreeAndNil(oXmlDocument);
 end;

procedure TWPContainer.SaveToFile(aFileName: string);
var
  oXmlDocument: TXmlDocument;
  vRoot,WaypointNode,PointListNode: TDOMNode;
  i,d: integer;
  oSpsPoint: TSpsPoint;
begin
  oXmlDocument:=TXmlDocument.Create;
  oXmlDocument.Encoding:='UTF-8';
  vRoot:=oXmlDocument.CreateElement('spsmap');
   TDOMElement(vRoot).SetAttribute('maptype',inttostr(MapType));
   TDOMElement(vRoot).SetAttribute('mapfile',MapFile);
   TDOMElement(vRoot).SetAttribute('mapimg',MapImg);
  oXmlDocument.AppendChild(vroot);
  vRoot:=oXMLDocument.DocumentElement;
  for i:=0 to count - 1 do
     begin
       WaypointNode:=oXmlDocument.CreateElement('waypoint');
       TDOMElement(WaypointNode).SetAttribute('name',Items[i].Name);
       TDOMElement(WaypointNode).SetAttribute('color',ColorToString(Items[i].Color));
         for d:=0 to Items[i].PointList.Count - 1 do
            begin
              oSpsPoint:=Items[i].PointList.Items[d];
              PointListNode:=oXMLDocument.CreateElement('point');
              TDOMElement(PointListNode).SetAttribute('x',IntToStr(oSpsPoint.x));
              TDOMElement(PointListNode).SetAttribute('y',IntToStr(oSpsPoint.y));
             WaypointNode.AppendChild(PointListNode);
            end;
       vRoot.AppendChild(WaypointNode);
     end;
  WriteXMLFile (oXmlDocument,aFileName);
  FreeAndNil(oXmlDocument);
end;

procedure TWPContainer.Invert(aNodeIndex: integer;aColor: TColor);
var
 Inverted: TWaypoint;
 Normal: TWaypoint;
 i: integer;
 oSpsPoint: TSpsPoint;
begin
  Inverted:=Additem;
  Normal:=Items[aNodeIndex];
  Inverted.Name:='Inverted'+Normal.Name;
  Inverted.Color:=aColor;
 // Inverted.MapType:=Normal.MapType;
  for i:=normal.PointList.Count - 1 downto 0 do
     begin
       oSpsPoint:=Inverted.PointList.AddItem;
       oSpsPoint.x:=normal.PointList[i].x;
       oSpsPoint.y:=normal.PointList[i].y;
     end;
end;

procedure TWPContainer.GenerateScript(var st: TStringList;CodeType: integer);
var
 i,j: integer;
 wp: TWaypoint;
 pt: TSpsPoint;
 s: string;
begin
  case CodeType of
  0:
    begin
      st.Clear;
      st.Add(GenSpaces(2)+'program Walker;');
      st.Add(GenSpaces(2)+'//The code was generated with the path generator for SPS version 2 by Cynic');
      st.Add(GenSpaces(2)+'{$DEFINE SMART}');
      st.Add(GenSpaces(2)+'{$i SRL/srl.simba}');
      st.Add(GenSpaces(2)+'{$i sps/sps.simba}');
      st.Add('');
      st.Add('');
      st.Add('');
      st.Add(GenSpaces(2)+'var');
      s:=GenSpaces(4);
      st.Add(s+'//place your variables here');
      st.Add(s+'Status: string;');
      s:=GenSpaces(2);
      st.Add('');
      st.Add('');
      st.Add('');
      st.Add(GenSpaces(1)+'procedure DeclarePlayers;');
      st.Add(s+'begin');
      st.Add(s+s+'HowManyPlayers:=1;');
      st.Add(s+s+'NumberOfPlayers(HowManyPlayers);');
      st.Add(s+s+'CurrentPlayer:=0;');
      st.Add(s+s+'with Players[0] do');
      st.Add(s+s+'begin');
      st.Add(s+s+s+'Name:='+#39+#39+';');
      st.Add(s+s+s+'Pass:='+#39+#39+';');
      st.Add(s+s+s+'BoxRewards:=['+#39+#39+'];');
      st.Add(s+s+s+'LampSkill:=SKILL_PRAYER;');
      st.Add(s+s+s+'Pin:='+#39+#39+';');
      st.Add(s+s+s+'Active:=true;');
      st.Add(s+s+'end;');
      st.Add(#32+'end;');
       for i:=0 to count -1 do
          begin
            wp:=items[i];
            st.Add('');
            st.Add('');
            st.Add('');
            st.Add(genspaces(1)+'procedure'+genspaces(1)+wp.Name+';');
            st.Add(genspaces(2)+'var');
            st.Add(genspaces(4)+Wp.Name+'Var: TPointArray;');
            st.Add(genspaces(2)+'begin');
            for j:=0 to wp.PointList.Count-1 do
               begin
                  pt:=wp.PointList[j];
                 if j = 0 then
                   s:=GenSpaces(4)+Wp.Name+'Var:=[Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                 if (j > 0) and (j< wp.PointList.Count) then
                   s:=s+',Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                 if j = wp.PointList.Count-1 then
                   s:=s+'];';
               end;
            st.Add(s);
           st.Add(GenSpaces(4)+'if SPS_WalkPath('+Wp.Name+'Var'+') then');
           st.Add(GenSpaces(5)+'Status := '+#39+Wp.Name+#39+'');
           st.Add(GenSpaces(6)+'else begin');
           st.Add(GenSpaces(7)+'Status :='+#39+'Failed '+wp.Name+#39';');
           st.Add(GenSpaces(7)+'WriteLn(status + '+#39+'#Time Running:'+#39+' +TimeRunning);');
           st.Add(GenSpaces(7)+'Logout;');
           st.Add(GenSpaces(7)+'TerminateScript;');
           st.Add(GenSpaces(6)+'end;');
           st.Add(GenSpaces(5)+'WriteLn(status + '+#39+'#Time Running:'+#39+' +TimeRunning);');
           st.Add(GenSpaces(4)+'end;');
          end;
         st.Add(genspaces(1)+'procedure SetupWalker;');
         st.Add(GenSpaces(2)+'begin');
         st.Add(GenSpaces(4)+'SRL_SIXHOURFIX := TRUE;');
         st.Add(GenSpaces(4)+'SMART_FIXSPEED := TRUE;');
         st.Add(GenSpaces(4)+'SetupSRL;');
         st.Add(GenSpaces(4)+'DeclarePlayers;');
         st.Add(GenSpaces(4)+'LoginPlayer;');
         st.Add(GenSpaces(4)+' Wait('+IntToStr(RandomRange(500,1000))+'+ '+'Random('+IntToStr(RandomRange(100,400))+'));');
         st.Add(GenSpaces(4)+'ClickNorth(SRL_ANGLE_HIGH);');
         if (MapType>0) then
           st.Add(GenSpaces(4)+GetAreaCodes(Self))
         else
           st.Add(GenSpaces(4)+'SPS_Setup(RUNESCAPE_OTHER,['+#39+GetFileName(MapFile)+#39+']);');
         st.Add(genspaces(1)+'end;');
    end;
  1:
    begin
         st:=TStringList.Create;
          for i:=0 to count-1 do
            begin
             wp:=items[i];
              for j:=0 to wp.PointList.Count - 1 do
                begin
                 pt:=wp.PointList[j];
                  if j = 0 then
                     s:=GenSpaces(4)+wp.Name+'Var:=[Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                  if (j > 0) and (j< wp.PointList.Count) then
                     s:=s+',Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                  if j = wp.PointList.Count -1 then
                     s:=s+']);';
                 end;
            St.Add(s);
          end;
        if (MapType>0) then
           st.Add(GenSpaces(4)+GetAreaCodes(Self))
         else
           st.Add(GenSpaces(4)+'SPS_Setup(RUNESCAPE_OTHER,['+#39+GetFileName(MapFile)+#39+']);');
         end;
  2:
    begin
      st.Clear;
      st.Add(GenSpaces(2)+'program Walker;');
      st.Add(GenSpaces(2)+'//The code was generated with the path generator for SPS version 2 by Cynic');
      st.Add(GenSpaces(2)+'//In that code uses the BlindWalk snippet by litoris.');
      st.Add(GenSpaces(2)+'{$DEFINE SMART}');
      st.Add(GenSpaces(2)+'{$i SRL/srl.simba}');
      st.Add(GenSpaces(2)+'{$i sps/sps.simba}');
      st.Add('');
      st.Add('');
      st.Add('');
      st.Add(GenSpaces(2)+'var');
      s:=GenSpaces(4);
      st.Add(s+'//place your variables here');
      st.Add(s+'Status: string;');
      s:=GenSpaces(2);
      st.Add('');
      st.Add('');
      st.Add('');
      st.Add(GenSpaces(1)+'procedure DeclarePlayers;');
      st.Add(s+'begin');
      st.Add(s+s+'HowManyPlayers:=1;');
      st.Add(s+s+'NumberOfPlayers(HowManyPlayers);');
      st.Add(s+s+'CurrentPlayer:=0;');
      st.Add(s+s+'with Players[0] do');
      st.Add(s+s+'begin');
      st.Add(s+s+s+'Name:='+#39+#39+';');
      st.Add(s+s+s+'Pass:='+#39+#39+';');
      st.Add(s+s+s+'BoxRewards:=['+#39+#39+'];');
      st.Add(s+s+s+'LampSkill:=SKILL_PRAYER;');
      st.Add(s+s+s+'Pin:='+#39+#39+';');
      st.Add(s+s+s+'Active:=true;');
      st.Add(s+s+'end;');
      st.Add(#32+'end;');
       for i:=0 to count -1 do
          begin
            wp:=items[i];
            st.Add('');
            st.Add('');
            st.Add('');
            st.Add(genspaces(1)+'procedure'+genspaces(1)+wp.Name+';');
            st.Add(genspaces(2)+'var');
            st.Add(genspaces(4)+Wp.Name+'Var: TPointArray;');
            st.Add(genspaces(4)+'I: integer;');
            st.Add(genspaces(2)+'begin');
            for j:=0 to wp.PointList.Count-1 do
               begin
                  pt:=wp.PointList[j];
                 if j = 0 then
                   s:=GenSpaces(4)+Wp.Name+'Var:=[Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                 if (j > 0) and (j< wp.PointList.Count) then
                   s:=s+',Point('+IntToStr(pt.x)+','+IntToStr(pt.y)+')';
                 if j = wp.PointList.Count -1 then
                   s:=s+'];';
               end;
           st.Add(s);
           st.Add(GenSpaces(4)+'for i:=0 to High('+Wp.Name+'Var'+') do');
           st.Add(GenSpaces(5)+'repeat');
           st.Add(GenSpaces(6)+'wait(RandomRange(500,800));');
           st.Add(GenSpaces(5)+'until (SPS_BlindWalk('+Wp.Name+'Var[i]));');
         //  st.Add(GenSpaces(5)+'Status := '+#39+Wp.Name+#39+'');
         //  st.Add(GenSpaces(6)+'else begin');
         //  st.Add(GenSpaces(7)+'Status :='+#39+'Failed '+wp.Name+#39';');
         //  st.Add(GenSpaces(7)+'WriteLn(status + '+#39+'#Time Running:'+#39+' +TimeRunning);');
         //  st.Add(GenSpaces(7)+'Logout;');
        //   st.Add(GenSpaces(7)+'TerminateScript;');
        //   st.Add(GenSpaces(6)+'end;');
        //   st.Add(GenSpaces(5)+'WriteLn(status + '+#39+'#Time Running:'+#39+' +TimeRunning);');
           st.Add(GenSpaces(4)+'end;');
           st.Add('');
           st.Add('');
           st.Add('');
          end;
         st.Add(genspaces(1)+'procedure SetupWalker;');
         st.Add(GenSpaces(2)+'begin');
         st.Add(GenSpaces(4)+'SRL_SIXHOURFIX := TRUE;');
         st.Add(GenSpaces(4)+'SMART_FIXSPEED := TRUE;');
         st.Add(GenSpaces(4)+'SetupSRL;');
         st.Add(GenSpaces(4)+'DeclarePlayers;');
         st.Add(GenSpaces(4)+'LoginPlayer;');
         st.Add(GenSpaces(4)+' Wait('+IntToStr(RandomRange(500,1000))+'+ '+'Random('+IntToStr(RandomRange(100,400))+'));');
         st.Add(GenSpaces(4)+'ClickNorth(SRL_ANGLE_HIGH);');
         if (MapType>0) then
           st.Add(GenSpaces(4)+GetAreaCodes(Self))
         else
           st.Add(GenSpaces(4)+'SPS_Setup(RUNESCAPE_OTHER,['+#39+GetFileName(MapFile)+#39+']);');
         st.Add(genspaces(1)+'end;');
    end;
  end;
end;

end.

