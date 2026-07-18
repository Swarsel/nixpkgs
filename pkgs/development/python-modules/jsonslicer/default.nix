{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  pkg-config,
  pytestCheckHook,
  setuptools,
  unittestCheckHook,
  yajl,
}:

buildPythonPackage rec {
  pname = "jsonslicer";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "AMDmi3";
    repo = "jsonslicer";
    tag = version;
    hash = "sha256-nPifyqr+MaFqoCYFbFSSBDjvifpX0CFnHCdMCvhwYTA=";
  };

  buildInputs = [ yajl ];

  nativeCheckInputs = [
    pytestCheckHook
    unittestCheckHook
  ];

  build-system = [
    setuptools
    pkg-config
  ];

  pyproject = true;
  pythonImportsCheck = [ "jsonslicer" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Stream JSON parser for Python";
    homepage = "https://github.com/AMDmi3/jsonslicer";
    changelog = "https://github.com/AMDmi3/jsonslicer/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
}
