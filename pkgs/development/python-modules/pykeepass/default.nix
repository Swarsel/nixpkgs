{
  lib,
  fetchFromGitHub,
  argon2-cffi,
  buildPythonPackage,
  construct,
  lxml,
  pycryptodomex,
  pyotp,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pykeepass";
  version = "4.1.1.post1";

  src = fetchFromGitHub {
    owner = "libkeepass";
    repo = "pykeepass";
    tag = "v${version}";
    hash = "sha256-DeEz3zrUK3cXIvMK/32Zn3FPiNsenhpAb17Zgel826s=";
  };

  nativeCheckInputs = [
    pyotp
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    argon2-cffi
    construct
    lxml
    pycryptodomex
  ];

  propagatedNativeBuildInputs = [ argon2-cffi ];
  pyproject = true;
  pythonImportsCheck = [ "pykeepass" ];

  meta = {
    description = "Python library to interact with keepass databases (supports KDBX3 and KDBX4)";
    homepage = "https://github.com/libkeepass/pykeepass";
    changelog = "https://github.com/libkeepass/pykeepass/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
