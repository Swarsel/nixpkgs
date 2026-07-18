{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typer,
}:

buildPythonPackage rec {
  pname = "pycrashreport";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "pycrashreport";
    tag = "v${version}";
    hash = "sha256-huiPTpcNwRY8IMHe4y4H/OBCdlDWhBiU9u1xTvLSDQk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycrashreport" ];

  meta = {
    description = "Python3 parser for Apple's crash reports";
    homepage = "https://github.com/doronz88/pycrashreport";
    changelog = "https://github.com/doronz88/pycrashreport/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "pycrashreport";
  };
}
