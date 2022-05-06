program Downloads;

uses
  Vcl.Forms,
  u_admPrincipal in 'View\u_admPrincipal.pas' {admPrincipal},
  RegrasNegocio in 'Classes\RegrasNegocio.pas',
  u_frmHistorico in 'View\u_frmHistorico.pas' {frmHistorico},
  u_dmConection in 'View\u_dmConection.pas' {dmConection: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TadmPrincipal, admPrincipal);
  Application.Run;
end.
