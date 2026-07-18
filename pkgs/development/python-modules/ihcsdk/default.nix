{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ihcsdk";
  version = "2.8.12";

  src = fetchFromGitHub {
    owner = "dingusdk";
    repo = "PythonIhcSdk";
    tag = "v${version}";
    hash = "sha256-k1WKfW/qweRdcaczqf47iNlqeOe7ULa57kqsTF4W2Zs=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "ihcsdk" ];

  meta = {
    description = "SDK for connection to the LK IHC Controller";
    homepage = "https://github.com/dingusdk/PythonIhcSdk";
    changelog = "https://github.com/dingusdk/PythonIhcSdk/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
