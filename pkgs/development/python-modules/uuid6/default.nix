{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "uuid6";
  version = "2025.0.1";

  src = fetchFromGitHub {
    owner = "oittaa";
    repo = "uuid6-python";
    tag = version;
    hash = "sha256-E8oBbD52zTDcpRCBsJXfSgpF7FPNSVB43uxvsA62XHU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "uuid6"
  ];

  meta = {
    description = "New time-based UUID formats which are suited for use as a database key";
    homepage = "https://github.com/oittaa/uuid6-python";
    changelog = "https://github.com/oittaa/uuid6-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
  };
}
