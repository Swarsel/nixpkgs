{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  gitpython,
  joblib,
  pyasn1,
  pyasn1-modules,
  pygount,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "edk2-pytool-library";
  version = "0.23.15";

  src = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-pytool-library";
    tag = "v${version}";
    hash = "sha256-ZWQvqhQb9mjvShWVER7iS5vTI8KUn7RefqyGhjpO9NI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyasn1
    pyasn1-modules
    cryptography
    joblib
    gitpython
    sqlalchemy
    pygount
  ];

  disabledTests = [
    # requires network access
    "test_basic_parse"
  ];

  pyproject = true;
  pythonImportsCheck = [ "edk2toollib" ];

  meta = {
    description = "Python library package that supports UEFI development";
    homepage = "https://github.com/tianocore/edk2-pytool-library";
    changelog = "https://github.com/tianocore/edk2-pytool-library/releases/tag/${src.tag}";
    license = lib.licenses.bsd2Patent;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.linux;
  };
}
