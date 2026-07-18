{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gogdl";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "Heroic-Games-Launcher";
    repo = "heroic-gogdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gXAlZa4rml8fH54jpOIXZN0/1iieLpZwpii5ICHQ2Sc=";
    fetchSubmodules = true;
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "gogdl" ];

  meta = {
    description = "GOG Downloading module for Heroic Games Launcher";
    homepage = "https://github.com/Heroic-Games-Launcher/heroic-gogdl";
    license = with lib.licenses; [ gpl3 ];
    maintainers = [ ];
    mainProgram = "gogdl";
  };
})
