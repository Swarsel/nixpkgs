{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  numpy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "array-api-strict";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "data-apis";
    repo = "array-api-strict";
    tag = version;
    hash = "sha256-jDigE1bCx2JbthIPuVd3dX1tdvGqcZVOR3opJwlTme4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools >= 61.0,<=75" "setuptools"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];

  disabledTests = [
    "test_disabled_extensions"
    "test_environment_variables"
  ];

  pyproject = true;

  pytestFlags = [
    # NumPy warning suppression and assertion utilities are deprecated.
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "array_api_strict" ];

  meta = {
    description = "Strict, minimal implementation of the Python array API";
    homepage = "https://data-apis.org/array-api-strict";
    changelog = "https://github.com/data-apis/array-api-strict/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ berquist ];
  };
}
