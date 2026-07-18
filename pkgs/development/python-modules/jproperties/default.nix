{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytest-datadir,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  six,
}:

buildPythonPackage rec {
  pname = "jproperties";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "Tblue";
    repo = "python-jproperties";
    tag = "v${version}";
    hash = "sha256-wnhEcPWAFUXR741/LZT3TXqxrU70JZe+90AkVEA3A+k=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "setuptools_scm ~= 3.3" "setuptools_scm"
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-datadir
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ six ];

  disabledTestPaths = [
    # TypeError: 'PosixPath' object...
    "tests/test_simple_utf8.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jproperties" ];

  meta = {
    description = "Java Property file parser and writer for Python";
    homepage = "https://github.com/Tblue/python-jproperties";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "propconv";
  };
}
