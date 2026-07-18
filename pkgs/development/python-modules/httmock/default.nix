{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "httmock";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "patrys";
    repo = "httmock";
    rev = version;
    hash = "sha256-yid4vh1do0zqVzd1VV7gc+Du4VPrkeGFsDHqNbHL28I=";
  };

  nativeCheckInputs = [
    requests
    pytestCheckHook
  ];

  enabledTestPaths = [ "tests.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "httmock" ];

  meta = {
    description = "Mocking library for requests";
    homepage = "https://github.com/patrys/httmock";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nyanloutre ];
  };
}
