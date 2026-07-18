{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dataclasses-json,
  isodate,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  requests-oauthlib,
  responses,
}:

buildPythonPackage rec {
  pname = "python-youtube";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "sns-sdks";
    repo = "python-youtube";
    tag = "v${version}";
    hash = "sha256-80iGKxz3rwxuYB1bqEEMxMKogiiNK43tNrVnOiVPwWU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    dataclasses-json
    isodate
    requests
    requests-oauthlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyyoutube" ];

  pythonRelaxDeps = [
    "requests-oauthlib"
  ];

  meta = {
    description = "Simple Python wrapper around for YouTube Data API";
    homepage = "https://github.com/sns-sdks/python-youtube";
    changelog = "https://github.com/sns-sdks/python-youtube/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
