{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  pydicom,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  versionCheckHook,
}:

let
  deid-data = buildPythonPackage {
    pname = "deid-data";
    version = "unstable-2022-12-06";

    src = fetchFromGitHub {
      owner = "pydicom";
      repo = "deid-data";
      rev = "5750d25a5048fba429b857c16bf48b0139759644";
      hash = "sha256-c8NBAN53NyF9dPB7txqYtM0ac0Y+Ch06fMA1LrIUkbc=";
    };

    build-system = [ setuptools ];
    dependencies = [ pydicom ];
    pyproject = true;

    meta = {
      description = "Supplementary data for deid package";
      homepage = "https://github.com/pydicom/deid-data";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.bcdarwin ];
    };
  };
in
buildPythonPackage rec {
  pname = "deid";
  version = "0.4.6";

  # Pypi version has no tests
  src = fetchFromGitHub {
    owner = "pydicom";
    repo = "deid";
    # the github repo does not contain Pypi version tags:
    rev = "f2e125e5a13ae1c3ccfeb55d9431d3a627a4d0db";
    hash = "sha256-Vk6MD3MNf1JejqACxjjHkFniK7YDgmdH7k1iQi+enEY=";
  };

  nativeCheckInputs = [
    deid-data
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    pydicom
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "deid" ];

  meta = {
    description = "Best-effort anonymization for medical images";
    homepage = "https://pydicom.github.io/deid";
    changelog = "https://github.com/pydicom/deid/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "deid";
  };
}
