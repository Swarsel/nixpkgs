{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rpatool";
  version = "1.0.0";

  src = fetchFromCodeberg {
    owner = "shiz";
    repo = "rpatool";
    tag = "v${version}";
    hash = "sha256-AHFL0pahwS8/MH13NgPiKtKAP+nBqfbcUVWzV+Jdco0=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rpatool" ];

  meta = {
    description = "Simple tool allowing you to create, modify and extract Ren'Py Archive (.rpa/.rpi) files";
    homepage = "https://codeberg.org/shiz/rpatool";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    mainProgram = "rpatool";
  };
}
