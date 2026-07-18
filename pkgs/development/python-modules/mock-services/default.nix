{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  fetchpatch,
  funcsigs,
  pytestCheckHook,
  requests-mock,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "mock-services";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "peopledoc";
    repo = "mock-services";
    rev = version;
    sha256 = "1rqyyfwngi1xsd9a81irjxacinkj1zf6nqfvfxhi55ky34x5phf9";
  };

  patches = [
    # Fix issues due to internal API breaking in latest versions of requests-mock
    (fetchpatch {
      sha256 = "0a4pwxr33kr525sp8q4mb4cr3n2b51mj2a3052lhg6brdbi4gnms";
      url = "https://github.com/peopledoc/mock-services/commit/88d3a0c9ef4dd7d5e011068ed2fdbbecc4a1a03a.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];

  dependencies = [
    attrs
    funcsigs
    requests-mock
  ];

  disabledTests = [
    # require networking
    "test_real_http_1"
    "test_restart_http_mock"
    "test_start_http_mock"
    "test_stop_http_mock"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mock_services" ];

  meta = {
    description = "Mock an entire service API based on requests-mock";
    homepage = "https://github.com/peopledoc/mock-services";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
