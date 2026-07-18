{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  legacy-cgi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydal";
  version = "20260313.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LfjeQV3aiCHwopHNZkWfuImyhFjuZQF3j2guVVMIR+k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ legacy-cgi ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # these tests already seem to be broken on the upstream
    "tests/nosql.py::TestFields::testRun"
    "tests/nosql.py::TestSelect::testGroupByAndDistinct"
    "tests/nosql.py::TestExpressions::testOps"
    "tests/nosql.py::TestExpressions::testRun"
    "tests/nosql.py::TestImportExportUuidFields::testRun"
    "tests/nosql.py::TestConnection::testRun"
    "tests/restapi.py::TestRestAPI::test_search"
    "tests/validation.py::TestValidateAndInsert::testRun"
    "tests/validation.py::TestValidateUpdateInsert::testRun"
    "tests/validators.py::TestValidators::test_IS_IN_DB"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # socket.gaierror: [Errno 8] nodename nor servname provided, or not known
    "test_scheduler"
  ];

  enabledTestPaths = [
    "tests/*.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydal" ];

  meta = {
    description = "Python Database Abstraction Layer";
    homepage = "https://github.com/web2py/pydal";
    changelog = "https://github.com/web2py/pydal/commits/v${version}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ wamserma ];
  };
}
