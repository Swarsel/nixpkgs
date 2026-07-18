{
  lib,
  buildPythonPackage,
  execnet,
  isPyPy,
  # runtime
  pytest,
  pytest-fixture-config,
  # tests
  pytestCheckHook,
  # build-time
  setuptools,
  six,
  termcolor,
}:

buildPythonPackage {
  inherit (pytest-fixture-config) version src patches;
  pname = "pytest-shutil";

  postPatch = ''
    cd pytest-shutil
  '';

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    execnet
    termcolor
    six
  ];

  disabledTests = lib.optionals isPyPy [
    "test_run"
    "test_run_integration"
  ];

  pyproject = true;

  meta = {
    description = "Goodie-bag of unix shell and environment tools for py.test";
    homepage = "https://github.com/manahl/pytest-plugins";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryansydnor ];
  };
}
