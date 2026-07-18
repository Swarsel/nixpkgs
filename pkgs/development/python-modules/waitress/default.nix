{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "waitress";
  version = "3.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aCqq8q8MRK2kq/tw3tNjk/DjB/SrlFaiFc4AILrvwx8=";
  };

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  # Tests use sockets
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTests = [
    # access to socket
    "test_service_port"
  ];

  pyproject = true;
  pythonImportsCheck = [ "waitress" ];

  meta = {
    description = "Waitress WSGI server";
    homepage = "https://github.com/Pylons/waitress";
    license = lib.licenses.zpl21;
    maintainers = [ ];
    mainProgram = "waitress-serve";
  };
}
