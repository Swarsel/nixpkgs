{
  lib,
  fetchFromGitHub,
  astral,
  buildPythonPackage,
  hypothesis,
  num2words,
  pdm-backend,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage rec {
  pname = "hdate";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "py-libhdate";
    repo = "py-libhdate";
    tag = "v${version}";
    hash = "sha256-6CCaHnpZEU7krLzkRKRF4Iui7Vd7AOfIn1fTzIdxPtw=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    syrupy
  ];

  build-system = [
    pdm-backend
  ];

  dependencies = [
    num2words
  ];

  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    astral = [ astral ];
  };

  pyproject = true;
  pythonImportsCheck = [ "hdate" ];

  pythonRelaxDeps = [
    "astral"
  ];

  meta = {
    description = "Python module for Jewish/Hebrew date and Zmanim";
    homepage = "https://github.com/py-libhdate/py-libhdate";
    changelog = "https://github.com/py-libhdate/py-libhdate/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
