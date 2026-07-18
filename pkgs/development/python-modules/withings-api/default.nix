{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  poetry-core,
  pydantic,
  pytest-cov-stub,
  pytestCheckHook,
  requests-oauthlib,
  responses,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "withings-api";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "vangorra";
    repo = "python_withings_api";
    tag = version;
    hash = "sha256-8cOLHYnodPGk1b1n6xbVyW2iju3cG6MgnzYTKDsP/nw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requests-oauth = ">=0.4.1"' '''
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    responses
  ];

  build-system = [ poetry-core ];

  dependencies = [
    arrow
    requests-oauthlib
    typing-extensions
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "withings_api" ];

  meta = {
    description = "Library for the Withings Health API";
    homepage = "https://github.com/vangorra/python_withings_api";
    changelog = "https://github.com/vangorra/python_withings_api/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kittywitch ];
    broken = lib.versionAtLeast pydantic.version "2";
  };
}
