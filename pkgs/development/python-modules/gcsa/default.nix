{
  lib,
  fetchFromGitHub,
  beautiful-date,
  buildPythonPackage,
  google-api-python-client,
  google-auth-httplib2,
  google-auth-oauthlib,
  pyfakefs,
  pytestCheckHook,
  python-dateutil,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "gcsa";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "kuzmoyev";
    repo = "google-calendar-simple-api";
    rev = "v${version}";
    hash = "sha256-I4IKuG9/4/JrEQ7PD1BwGFmCa1q3GOe4srHmpwt1OUU=";
  };

  propagatedBuildInputs = [
    tzlocal
    google-api-python-client
    google-auth-httplib2
    google-auth-oauthlib
    python-dateutil
    beautiful-date
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pyfakefs
  ];

  format = "setuptools";
  pythonImportsCheck = [ "gcsa" ];

  meta = {
    description = "Pythonic wrapper for the Google Calendar API";
    homepage = "https://github.com/kuzmoyev/google-calendar-simple-api";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
