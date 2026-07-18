{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  formencode,
  paste,
  pastedeploy,
  pydispatcher,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sqlobject";
  version = "3.13.1";

  src = fetchFromGitHub {
    owner = "sqlobject";
    repo = "sqlobject";
    tag = version;
    hash = "sha256-Qbb48z4DrD/M8e26+5NjPcA0b3gxHeAxj1X/jSrTwx0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    formencode
    paste
    pastedeploy
    pydispatcher
  ];

  disabledTests = [
    # https://github.com/sqlobject/sqlobject/issues/179
    "test_fail"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlobject" ];

  meta = {
    description = "Object Relational Manager for providing an object interface to your database";
    homepage = "https://www.sqlobject.org/";
    changelog = "https://github.com/sqlobject/sqlobject/blob/${src.tag}/docs/News.rst";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
  };
}
