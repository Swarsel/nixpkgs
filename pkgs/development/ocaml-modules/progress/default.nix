{
  lib,
  alcotest,
  astring,
  buildDunePackage,
  fmt,
  logs,
  mtime,
  optint,
  terminal,
  vector,
}:

buildDunePackage {
  inherit (terminal) version src;
  pname = "progress";

  propagatedBuildInputs = [
    fmt
    logs
    mtime
    optint
    terminal
    vector
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    astring
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Progress bar library for OCaml";
    homepage = "https://github.com/CraigFe/progress";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
