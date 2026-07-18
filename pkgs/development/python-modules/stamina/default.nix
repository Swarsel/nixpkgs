{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  dirty-equals,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  tenacity,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "stamina";
  version = "25.2.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "stamina";
    tag = version;
    hash = "sha256-PsoEo53JeD9zrqRmvPotTiX4lM16aJXB3Gr1+mFTEYA=";
  };

  nativeCheckInputs = [
    anyio
    dirty-equals
    pytestCheckHook
  ];

  build-system = [
    hatch-fancy-pypi-readme
    hatch-vcs
    hatchling
  ];

  dependencies = [
    tenacity
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "stamina" ];

  meta = {
    description = "Production-grade retries for Python";
    homepage = "https://github.com/hynek/stamina";
    changelog = "https://github.com/hynek/stamina/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
