{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pybind11,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "binary2strings";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "glmcdona";
    repo = "binary2strings";
    tag = "v${version}";
    hash = "sha256-3UPT0PdnPAhOu3J2vU5NxE3f4Nb1zwuX3hJiy87nLD0=";
  };

  nativeBuildInputs = [
    pybind11
    setuptools
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "tests/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "binary2strings" ];

  meta = {
    description = "Module to extract Ascii, Utf8, and Unicode strings from binary data";
    homepage = "https://github.com/glmcdona/binary2strings";
    changelog = "https://github.com/glmcdona/binary2strings/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
