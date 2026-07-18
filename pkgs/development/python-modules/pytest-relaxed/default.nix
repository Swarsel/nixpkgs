{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
  invoke,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-relaxed";
  version = "2.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lW6gKOww27+2gN2Oe0p/uPgKI5WV6Ius4Bi/LA1xgkg=";
  };

  patches = [
    # https://github.com/bitprophet/pytest-relaxed/issues/28
    # https://github.com/bitprophet/pytest-relaxed/pull/29
    ./fix-oldstyle-hookimpl-setup.patch
  ];

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ decorator ];

  nativeCheckInputs = [
    invoke
    pytestCheckHook
  ];

  disabledTests = [
    "test_skips_pytest_fixtures"
  ];

  enabledTestPaths = [ "tests" ];
  format = "setuptools";
  pythonImportsCheck = [ "pytest_relaxed" ];

  meta = {
    description = "Relaxed test discovery/organization for pytest";
    homepage = "https://pytest-relaxed.readthedocs.io/";
    changelog = "https://github.com/bitprophet/pytest-relaxed/blob/${version}/docs/changelog.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
