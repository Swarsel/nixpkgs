{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  # build-system
  hatchling,
  # dependencies
  httpx,
  pydantic,
  truststore,
}:

buildPythonPackage (finalAttrs: {
  pname = "atopile-easyeda2kicad";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "atopile";
    repo = "easyeda2kicad.py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l5ecNNu9vu073aK85F+tOSodEHk2wso95RYXk9DyTFo=";
  };

  doCheck = false; # no tests

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    httpx
    pydantic
    truststore
  ];

  pyproject = true;
  pythonImportsCheck = [ "easyeda2kicad" ];

  meta = {
    description = "Convert any LCSC components (including EasyEDA) to KiCad library";
    homepage = "https://github.com/atopile/easyeda2kicad.py";
    changelog = "https://github.com/atopile/easyeda2kicad.py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "easyeda2kicad";
  };
})
