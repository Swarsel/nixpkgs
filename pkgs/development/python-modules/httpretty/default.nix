{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  freezegun,
  mock,
  pytestCheckHook,
  setuptools,
  sure,
}:

buildPythonPackage rec {
  pname = "httpretty";
  version = "1.1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "20de0e5dd5a18292d36d928cc3d6e52f8b2ac73daec40d41eb62dee154933b68";
  };

  patches = [
    # https://github.com/gabrielfalcao/HTTPretty/pull/485
    # https://github.com/gabrielfalcao/HTTPretty/pull/485
    ./urllib-2.3.0-compat.patch
  ];

  nativeCheckInputs = [
    freezegun
    mock
    pytestCheckHook
    sure
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTestPaths = [
    "tests/bugfixes"
    "tests/functional"
    "tests/pyopenssl"
  ];

  pyproject = true;

  meta = {
    description = "HTTP client request mocking tool";
    homepage = "https://httpretty.readthedocs.org/";
    license = lib.licenses.mit;
  };
}
