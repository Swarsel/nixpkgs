{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
  waitress,
}:

buildPythonPackage rec {
  pname = "requests-unixsocket";
  version = "0.4.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-sllhWMNW7O5o0nukaaUiESMKxvsM3otmr7GfDtR6GZU=";
    pname = "requests_unixsocket";
  };

  nativeCheckInputs = [
    pytestCheckHook
    waitress
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "requests_unixsocket" ];

  meta = {
    description = "Use requests to talk HTTP via a UNIX domain socket";
    homepage = "https://github.com/msabramo/requests-unixsocket";
    changelog = "https://github.com/msabramo/requests-unixsocket/releases/tag/v${version}";
    license = lib.licenses.asl20;
  };
}
