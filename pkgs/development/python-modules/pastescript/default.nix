{
  lib,
  buildPythonPackage,
  fetchPypi,
  paste,
  pastedeploy,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pastescript";
  version = "3.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-U28CjftuUynGezIpnhyTA/kSZOSXk8xpFusKc+tKJSE=";
  };

  propagatedBuildInputs = [
    paste
    pastedeploy
    six
  ];

  # test suite seems to unset PYTHONPATH
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabledTestPaths = [ "appsetup/testfiles" ];
  pyproject = true;

  pythonImportsCheck = [
    "paste.script"
    "paste.deploy"
    "paste.util"
  ];

  meta = {
    description = "Pluggable command-line frontend, including commands to setup package file layouts";
    homepage = "https://github.com/cdent/pastescript/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "paster";
  };
}
