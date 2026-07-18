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
  pname = "cli";
  version = "0.0.1-alpha-unstable-2024-05-07";

  nativeBuildInputs = [
    reason
  ];

  buildInputs = [
    re
    pastel
  ];

  meta = {
    homepage = "https://reason-native.com/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason-native";
  };
}
