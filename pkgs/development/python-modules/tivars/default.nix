{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tivars";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "TI-Toolkit";
    repo = "tivars_lib_py";
    tag = "v${version}";
    hash = "sha256-mVMrOZIkqHlEUDSxBEMyhFTTiFyrTxz9K2SlH3WtVS0=";
    fetchSubmodules = true;
  };

  # no upstream tests exist
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "tivars" ];

  meta = {
    description = "Python library for interacting with TI-(e)z80 (82/83/84 series) calculator files";
    homepage = "https://ti-toolkit.github.io/tivars_lib_py/";
    changelog = "https://github.com/TI-Toolkit/tivars_lib_py/releases/tag/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
