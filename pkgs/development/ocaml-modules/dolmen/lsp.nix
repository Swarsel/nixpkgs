{
  lib,
  buildDunePackage,
  dolmen,
  dolmen_loop,
  dolmen_type,
  linol,
  linol-lwt,
  logs,
  lsp,
}:

buildDunePackage {
  inherit (dolmen) src version;
  pname = "dolmen_lsp";
  patches = [ ./linol-common-migration.patch ];

  buildInputs = [
    dolmen
    dolmen_loop
    dolmen_type
    linol
    linol-lwt
    logs
    lsp
  ];

  meta = dolmen.meta // {
    description = "LSP server for automated deduction languages";
    maintainers = [ lib.maintainers.stepbrobd ];
    mainProgram = "dolmenls";
  };
}
