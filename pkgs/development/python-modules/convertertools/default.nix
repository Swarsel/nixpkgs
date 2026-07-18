{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  poetry-core,
  pytest-codspeed,
  pytest-cov-stub,
  # checks
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "convertertools";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "convertertools";
    tag = "v${version}";
    hash = "sha256-YLEZGTq3wtiLsqQkdxcdM4moUEYPN29Uai5o81FUtVc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-codspeed
    pytest-cov-stub
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "convertertools" ];

  meta = {
    description = "Tools for converting python data types";
    homepage = "https://github.com/bluetooth-devices/convertertools";
    changelog = "https://github.com/bluetooth-devices/convertertools/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
