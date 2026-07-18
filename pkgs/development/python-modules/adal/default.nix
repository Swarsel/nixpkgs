{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpretty,
  pyjwt,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "adal";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "AzureAD";
    repo = "azure-activedirectory-library-for-python";
    rev = version;
    hash = "sha256-HE8/P0aohoZNeMdcQVKdz6M31FMrjsd7oVytiaD0idI=";
  };

  postPatch = ''
    sed -i '/cryptography/d' setup.py
  '';

  nativeCheckInputs = [
    httpretty
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyjwt
    python-dateutil
    requests
  ];

  disabledTests = [
    # AssertionError: 'Mex [23 chars]tp error:...
    "test_failed_request"
  ];

  pyproject = true;
  pythonImportsCheck = [ "adal" ];

  meta = {
    description = "Python module to authenticate to Azure Active Directory (AAD) in order to access AAD protected web resources";
    homepage = "https://github.com/AzureAD/azure-activedirectory-library-for-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
