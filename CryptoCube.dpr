program CryptoCube;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {FrmPrincipal},
  Classe.CryptoCube in 'Classe.CryptoCube.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
