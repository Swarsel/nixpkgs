{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-auth,
  requests,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pyfcm";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "olucurious";
    repo = "pyfcm";
    tag = version;
    hash = "sha256-lpSbb0DDXLHne062s7g27zRpvTuOHiqQkqGOtWvuWdI=";
  };

  # pyfcm's unit testing suite requires network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    urllib3
    google-auth
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyfcm" ];

  meta = {
    description = "Python client for FCM - Firebase Cloud Messaging (Android, iOS and Web)";
    homepage = "https://github.com/olucurious/pyfcm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ldelelis ];
  };
}
