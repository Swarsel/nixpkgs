{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  pyspnego,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "requests-credssp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jborean93";
    repo = "requests-credssp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HHLEmQ+mNjMjpR6J+emrKFM+2PiYq32o7Gnoo0gUrNA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    pyspnego
    requests
  ];

  optional-dependencies = {
    kerberos = pyspnego.optional-dependencies.kerberos;
  };

  pyproject = true;
  pythonImportsCheck = [ "requests_credssp" ];

  meta = {
    description = "HTTPS CredSSP authentication with the requests library";
    homepage = "https://github.com/jborean93/requests-credssp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
