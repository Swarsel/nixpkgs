{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  http-message-signatures,
  http-sfv,
  pytestCheckHook,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "requests-http-signature";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "pyauth";
    repo = "requests-http-signature";
    rev = "v${version}";
    hash = "sha256-sW2vYqT/nY27DvEKHdptc3dUpuqKmD7PLMs+Xp+cpeU=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    http-message-signatures
    http-sfv
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Test require network access
    "test_readme_example"
  ];

  enabledTestPaths = [ "test/test.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "requests_http_signature" ];

  meta = {
    description = "Requests authentication module for HTTP Signature";
    homepage = "https://github.com/kislyuk/requests-http-signature";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
