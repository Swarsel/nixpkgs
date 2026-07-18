{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "matrix-client";
  version = "0.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BnivQPLLLwkoqQikEMApdH1Ay5YaxaPxvQWqNVY8MVY=";
    pname = "matrix_client";
  };

  postPatch = ''
    substituteInPlace setup.py --replace \
      "pytest-runner~=5.1" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "matrix_client" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Python Matrix Client-Server SDK";
    homepage = "https://github.com/matrix-org/matrix-python-sdk";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ olejorgenb ];
  };
}
