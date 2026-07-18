{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  requests-oauthlib,
  responses,
  six,
}:

buildPythonPackage rec {
  pname = "mwclient";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "mwclient";
    repo = "mwclient";
    tag = "v${version}";
    sha256 = "sha256-qnWVQEG1Ri0z4RYmmG/fxYrlIFFf/6PnP5Dnv0cZb5I=";
  };

  propagatedBuildInputs = [
    requests
    requests-oauthlib
    six
  ];

  nativeCheckInputs = [
    mock
    pytest-cov-stub
    pytestCheckHook
    responses
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mwclient" ];

  meta = {
    description = "Python client library to the MediaWiki API";
    homepage = "https://github.com/mwclient/mwclient";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
