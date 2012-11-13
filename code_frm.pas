unit code_frm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, SynEdit,
  SynHighlighterPas;

type

  { TCodeForm }

  TCodeForm = class(TForm)
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
  private
    { private declarations }
  public
    procedure DrawCode(st: TStringList);
    { public declarations }
  end; 

var
  CodeForm: TCodeForm;

implementation

{$R *.lfm}

{ TCodeForm }

procedure TCodeForm.DrawCode(st: TStringList);
begin
  Synedit1.Lines.Clear;
  Synedit1.Text:=st.Text;
end;

end.

