{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  mock,
  pip,
  pytestCheckHook,
  setuptools,
  testpath,
  tomli,
}:

buildPythonPackage rec {
  pname = "pep517";
  version = "0.13.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Gy+i/9OTi7S+/+XWFGy8sr2plqWk2p8xq//Ysk4Hsxc=";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    tomli
  ];

  nativeCheckInputs = [
    pytestCheckHook
    setuptools
    testpath
    mock
    pip
  ];

  preCheck = ''
    rm pytest.ini # wants flake8
    rm tests/test_meta.py # wants to run pip
  '';

  disabledTests = [
    "test_setup_py"
    "test_issue_104"
  ];

  pyproject = true;

  meta = {
    description = "Wrappers to build Python packages using PEP 517 hooks";
    homepage = "https://github.com/pypa/pep517";
    license = lib.licenses.mit;
  };
}
