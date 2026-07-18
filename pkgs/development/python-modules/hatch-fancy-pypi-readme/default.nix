{
  lib,
  build,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hatch-fancy-pypi-readme";
  version = "25.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nFjtPf+Q1R9DQUzjcAmtHVsPCP/J/CFpmKBjgPAcAEU=";
    pname = "hatch_fancy_pypi_readme";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    hatchling
  ];

  nativeCheckInputs = [
    build
    pytestCheckHook
  ];

  # Requires network connection
  disabledTests = [
    "test_build" # Requires internet
    "test_invalid_config"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hatch_fancy_pypi_readme" ];

  meta = {
    description = "Fancy PyPI READMEs with Hatch";
    homepage = "https://github.com/hynek/hatch-fancy-pypi-readme";
    license = lib.licenses.mit;
    mainProgram = "hatch-fancy-pypi-readme";
  };
}
