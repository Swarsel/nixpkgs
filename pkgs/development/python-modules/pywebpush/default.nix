{
  lib,
  aiohttp,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  http-ece,
  mock,
  py-vapid,
  pytestCheckHook,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pywebpush";
  version = "2.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0eJ9uN6eZ1fBh19nKSVUvVTEGHTDb0tcTrtUQtziBPI=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    cryptography
    http-ece
    py-vapid
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywebpush" ];

  meta = {
    description = "Webpush Data encryption library for Python";
    homepage = "https://github.com/web-push-libs/pywebpush";
    changelog = "https://github.com/web-push-libs/pywebpush/releases/tag/${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "pywebpush";
  };
}
