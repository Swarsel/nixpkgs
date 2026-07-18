{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  poetry-dynamic-versioning,
  pyjwt,
  pythonOlder,
  requests,
  requests-toolbelt,
}:

buildPythonPackage rec {
  pname = "webexpythonsdk";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "WebexCommunity";
    repo = "WebexPythonSDK";
    tag = "v${version}";
    hash = "sha256-2yyGR5gCJVRsEnoPAr8tkMeG19vTfATl/ybuMydnplU=";
  };

  # Tests require a Webex Teams test domain
  doCheck = false;

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    pyjwt
    requests
    requests-toolbelt
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "webexpythonsdk" ];

  meta = {
    description = "Python module for Webex Teams APIs";
    homepage = "https://github.com/WebexCommunity/WebexPythonSDK";
    changelog = "https://github.com/WebexCommunity/WebexPythonSDK/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
