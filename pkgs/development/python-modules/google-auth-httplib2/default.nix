{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  google-auth,
  httplib2,
  mock,
  pytest-localserver,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-auth-httplib2";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-auth-library-python-httplib2";
    tag = "v${version}";
    sha256 = "sha256-NXz2oqbNVGTWOECH+Ly9v/CMxbhygFZhlHRHrnYLhCg=";
  };

  nativeCheckInputs = [
    flask
    mock
    pytestCheckHook
    pytest-localserver
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    google-auth
    httplib2
  ];

  pyproject = true;

  meta = {
    description = "Google Authentication Library: httplib2 transport";
    homepage = "https://github.com/GoogleCloudPlatform/google-auth-library-python-httplib2";
    changelog = "https://github.com/googleapis/google-auth-library-python-httplib2/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
