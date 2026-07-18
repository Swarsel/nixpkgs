{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  setuptools,
}:
let
  version = "1.1.2";
in
buildPythonPackage {
  inherit version;
  pname = "fortune";

  src = fetchFromCodeberg {
    owner = "jamesansley";
    repo = "fortune";
    tag = "v${version}";
    hash = "sha256-XEWO1B+o0p7mpHprvbdBgfSQrqPuUTaotulcP3FS/Mg=";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "A rewrite of fortune in python";
    homepage = "https://codeberg.org/jamesansley/fortune";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "fortune";
  };
}
