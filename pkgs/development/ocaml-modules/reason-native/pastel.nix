{
  lib,
  buildDunePackage,
  re,
  reason,
  src,
}:

buildDunePackage {
  inherit src;
  pname = "pastel";
  version = "0.3.0-unstable-2024-05-07";

  nativeBuildInputs = [
    reason
  ];

  propagatedBuildInputs = [
    re
  ];

  minimalOCamlVersion = "4.05";

  meta = {
    description = "Text formatting library that harnesses Reason JSX to provide intuitive terminal output. Like React but for CLI";
    homepage = "https://reason-native.com/docs/pastel/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason-native/tree/master/src/pastel";
  };
}
