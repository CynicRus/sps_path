program sps_path;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, sps_main, sps_types, sps_utils, sps_base, code_frm, bitmaps,
  mufasatypes, colour_conv, imagesforlazarus,
  lazmouseandkeyinput, GR32_PNG
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TSps_Editor, Sps_Editor);
  Application.Run;
end.

