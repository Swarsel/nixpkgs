{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  keyring,
  proton-core,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "proton-keyring-linux";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "python-proton-keyring-linux";
    tag = "v${version}";
    hash = "sha256-deld1MjuTjgjXBCUuDzYABRjN4gT1mz+duV0Qj4IWCg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    keyring
    proton-core
  ];

  pyproject = true;

  pythonImportsCheck = [
    "proton.keyring_linux.core"
    "proton.keyring_linux"
  ];

  meta = {
    description = "ProtonVPN core component to access Linux's keyring";
    homepage = "https://github.com/ProtonVPN/python-proton-keyring-linux";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
