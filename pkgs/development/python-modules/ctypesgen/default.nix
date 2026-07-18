{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  toml,
  wheel,
}:

buildPythonPackage rec {
  pname = "ctypesgen";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ctypesgen";
    repo = "ctypesgen";
    tag = version;
    hash = "sha256-TwIWPellmjMpTGQ+adJBLNMdAqB0kLOMl4YAubvXKqo=";
  };

  # Various compiler errors
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
    toml
    wheel
  ];

  pyproject = true;
  pythonImportsCheck = [ "ctypesgen" ];

  meta = {
    description = "Pure-python wrapper generator for ctypes";
    homepage = "https://github.com/ctypesgen/ctypesgen";
    changelog = "https://github.com/ctypesgen/ctypesgen/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
