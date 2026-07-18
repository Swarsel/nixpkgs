{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-auth,
  google-auth-oauthlib,
  setuptools,
  versioneer,
}:

buildPythonPackage rec {
  pname = "pydata-google-auth";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "pydata";
    repo = "pydata-google-auth";
    tag = version;
    hash = "sha256-NxEpwCkjNWao2bnKOsDgw93N+cVqwM12VfoEu8CyWUU=";
  };

  postPatch = ''
    # Remove vendorized versioneer.py
    rm versioneer.py
  '';

  # tests require network access
  doCheck = false;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    google-auth
    google-auth-oauthlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydata_google_auth" ];

  meta = {
    description = "Helpers for authenticating to Google APIs";
    homepage = "https://github.com/pydata/pydata-google-auth";
    changelog = "https://github.com/pydata/pydata-google-auth/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
