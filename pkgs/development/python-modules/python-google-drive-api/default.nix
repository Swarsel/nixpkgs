{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-google-drive-api";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tronikos";
    repo = "python-google-drive-api";
    tag = "v${version}";
    hash = "sha256-3es2rmndahH+DMEEwjBxyZKd27qDZIocPbzScF7B5fA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_drive_api" ];

  meta = {
    description = "Python client library for Google Drive API";
    homepage = "https://github.com/tronikos/python-google-drive-api";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
