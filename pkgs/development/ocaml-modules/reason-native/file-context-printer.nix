{
  lib,
  buildDunePackage,
  pastel,
  re,
  reason,
  src,
}:

buildDunePackage {
  inherit src;
  pname = "file-context-printer";
  version = "0.0.3-unstable-2024-05-07";

  nativeBuildInputs = [
    reason
  ];

  propagatedBuildInputs = [
    re
    pastel
  ];

  meta = {
    description = "Utility for displaying snippets of files on the command line";
    homepage = "https://reason-native.com/docs/file-context-printer/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason-native/tree/master/src/file-context-printer";
  };
}
