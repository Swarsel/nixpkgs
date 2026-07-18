{
  lib,
  buildDunePackage,
  console,
  pastel,
  reason,
  src,
}:

buildDunePackage {
  inherit src;
  pname = "pastel-console";
  version = "0.0.0-unstable-2024-05-07";

  nativeBuildInputs = [
    reason
  ];

  propagatedBuildInputs = [
    console
    pastel
  ];

  meta = {
    description = "Small library for pretty coloring to Console output";
    homepage = "https://reason-native.com/docs/pastel/console";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason-native/tree/master/src/pastel-console";
  };
}
