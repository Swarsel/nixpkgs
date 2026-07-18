{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-resources,
  pdm-backend,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "acres";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "nipreps";
    repo = "acres";
    tag = version;
    hash = "sha256-D2w/xGlt0ApQ1Il9pzHPcL1s3CmCCOdgRpvUw/LI3gA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    pdm-backend
  ];

  dependencies = [
    importlib-resources
  ];

  pyproject = true;

  pythonImportsCheck = [
    "acres"
  ];

  meta = {
    description = "Data-loading utility for Python";
    homepage = "https://github.com/nipreps/acres";
    changelog = "https://github.com/nipreps/acres/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
