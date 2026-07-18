{
  buildPythonPackage,
  # pkgs dependencies
  check,
  cppunit,
  # python dependencies
  fixtures,
  hypothesis,
  iso8601,
  pkg-config,
  pytestCheckHook,
  pyyaml,
  setuptools,
  subunit,
  testscenarios,
  testtools,
}:

buildPythonPackage {
  inherit (subunit)
    version
    src
    meta
    ;

  pname = "python-subunit";

  postPatch = ''
    substituteInPlace setup.py \
      --replace "version=VERSION" 'version="${subunit.version}"'
  '';

  nativeBuildInputs = [
    pkg-config
    setuptools
  ];

  buildInputs = [
    check
    cppunit
  ];

  propagatedBuildInputs = [
    iso8601
    testtools
  ];

  nativeCheckInputs = [
    testscenarios
    hypothesis
    fixtures
    pytestCheckHook
    pyyaml
  ];

  disabledTestPaths = [
    # these tests require testtools and don't work with pytest
    "python/tests/test_output_filter.py"
    "python/tests/test_test_protocol.py"
    "python/tests/test_test_protocol2.py"
  ];

  enabledTestPaths = [ "python/tests" ];
  pyproject = true;
}
