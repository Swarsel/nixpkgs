{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openssl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "scrypt";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "holgern";
    repo = "py-scrypt";
    tag = "v${version}";
    hash = "sha256-4jVXaPD57RMe4ef1PVgZwPGAhEHL3RGlu2DSC6lGuR4=";
  };

  buildInputs = [ openssl ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "scrypt" ];

  meta = {
    description = "Python bindings for the scrypt key derivation function";
    homepage = "https://github.com/holgern/py-scrypt";
    changelog = "https://github.com/holgern/py-scrypt/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
