{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httmock,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "irisclient";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "houqp";
    repo = "iris-python-client";
    tag = "v${version}";
    hash = "sha256-fXMw2BopkEqjklR6jr7QQIZyxLq6NHKm2rHwTCbtxR0=";
  };

  checkInputs = [
    httmock
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "irisclient" ];

  meta = {
    description = "Python client for Iris REST api";
    homepage = "https://github.com/houqp/iris-python-client";
    changelog = "https://github.com/houqp/iris-python-client/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ onny ];
  };
}
