{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "ttls";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "jschlyter";
    repo = "ttls";
    tag = "v${version}";
    hash = "sha256-ETqjL7pl/FekzMusBtq8jMr72/j7Dy/zadcObSNaKqU=";
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "ttls" ];

  meta = {
    description = "Module to interact with Twinkly LEDs";
    homepage = "https://github.com/jschlyter/ttls";
    changelog = "https://github.com/jschlyter/ttls/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ttls";
  };
}
