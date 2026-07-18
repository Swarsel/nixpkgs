{
  lib,
  buildDunePackage,
  cli,
  file-context-printer,
  pastel,
  re,
  reason,
  src,
}:

buildDunePackage {
  inherit src;
  pname = "rely";
  version = "4.0.0-unstable-2024-05-07";

  nativeBuildInputs = [
    reason
  ];

  propagatedBuildInputs = [
    re
    cli
    file-context-printer
    pastel
  ];

  meta = {
    description = "Jest-inspired testing framework for native OCaml/Reason";
    homepage = "https://reason-native.com/docs/rely/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason-native/tree/master/src/rely";
  };
}
