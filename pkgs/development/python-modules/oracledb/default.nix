{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  cython,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "oracledb";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "python-oracledb";
    tag = "v${version}";
    hash = "sha256-Pwbb+/vzNnliBpcDmOpkkNMVI/cPbJY+yMIKKR6m01w=";
    fetchSubmodules = true;
  };

  # Checks need an Oracle database
  doCheck = false;

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    cryptography
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "oracledb" ];

  meta = {
    description = "Python driver for Oracle Database";
    homepage = "https://oracle.github.io/python-oracledb";
    changelog = "https://github.com/oracle/python-oracledb/blob/${src.tag}/doc/src/release_notes.rst";

    license = with lib.licenses; [
      asl20 # and or
      upl
    ];

    maintainers = with lib.maintainers; [ harvidsen ];
  };
}
