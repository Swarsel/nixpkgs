{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # tests
  pandas,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyfakefs";
  version = "6.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BZ/QshdL/u1JnssKWbzP9VfyZ8xtiFr8Dlt254ttUNo=";
  };

  nativeCheckInputs = [
    pandas
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    "test_expand_root"
  ]
  ++ (lib.optionals stdenv.hostPlatform.isDarwin [
    # this test fails on darwin due to case-insensitive file system
    "test_rename_dir_to_existing_dir"
  ]);

  enabledTestPaths = [
    "pyfakefs/tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfakefs" ];

  meta = {
    description = "Fake file system that mocks the Python file system modules";
    homepage = "https://pyfakefs.org/";
    changelog = "https://github.com/jmcgeheeiv/pyfakefs/blob/v${version}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
