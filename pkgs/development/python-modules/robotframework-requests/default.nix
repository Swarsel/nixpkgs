{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pytestCheckHook,
  requests,
  robotframework,
}:

buildPythonPackage rec {
  pname = "robotframework-requests";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "MarketSquare";
    repo = "robotframework-requests";
    tag = "v${version}";
    hash = "sha256-NRhf3delcqUw9vWRPL6pJzpcmRMDou2pHmUHMstF8hw=";
  };

  buildInputs = [ pytestCheckHook ];

  propagatedBuildInputs = [
    lxml
    requests
    robotframework
  ];

  enabledTestPaths = [ "utests" ];
  format = "setuptools";
  pythonImportsCheck = [ "RequestsLibrary" ];

  meta = {
    description = "Robot Framework keyword library wrapper around the HTTP client library requests";
    homepage = "https://github.com/bulkan/robotframework-requests";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
