{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  inflection,
  # build-system
  pbr,
  pytest-mock,
  # checks
  pytestCheckHook,
  setuptools,
  tinycss2,
}:

buildPythonPackage rec {
  pname = "qstylizer";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "blambright";
    repo = "qstylizer";
    tag = version;
    hash = "sha256-Is/kYkSX9fOX+pLv5g1ns2OxeLpSkaCfO2jPIbiuIxA=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    inflection
    tinycss2
  ];

  pyproject = true;
  pythonImportsCheck = [ "qstylizer" ];

  meta = {
    description = "Qt stylesheet generation utility for PyQt/PySide";
    homepage = "https://github.com/blambright/qstylizer";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
