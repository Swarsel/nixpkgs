{
  lib,
  fetchFromGitHub,
  aiohttp,
  anyio,
  buildPythonPackage,
  oauthlib,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  requests,
  requests-mock,
  requests-oauthlib,
  setuptools-scm,
  time-machine,
}:

buildPythonPackage rec {
  pname = "pyatmo";
  version = "9.4.0";

  src = fetchFromGitHub {
    owner = "jabesq";
    repo = "pyatmo";
    tag = "v${version}";
    hash = "sha256-VW4whif1l7nY1Ifwn/NHJrDbYNeroJRWQtO47dOfEAo=";
  };

  nativeCheckInputs = [
    anyio
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    requests-mock
    time-machine
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    aiohttp
    oauthlib
    requests
    requests-oauthlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyatmo" ];

  pythonRelaxDeps = [
    "oauthlib"
    "requests-oauthlib"
    "requests"
  ];

  meta = {
    description = "Simple API to access Netatmo weather station data";
    homepage = "https://github.com/jabesq/pyatmo";
    changelog = "https://github.com/jabesq/pyatmo/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
