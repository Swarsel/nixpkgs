{
  lib,
  fetchFromGitHub,
  aiohttp,
  anyio,
  buildPythonPackage,
  distro,
  google-auth,
  httpx,
  packaging,
  pkginfo,
  pydantic,
  pytestCheckHook,
  requests,
  setuptools,
  sniffio,
  tenacity,
  twine,
  typing-extensions,
  websockets,
}:

buildPythonPackage rec {
  pname = "google-genai";
  version = "1.67.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "python-genai";
    tag = "v${version}";
    hash = "sha256-1ewVg271kooPkCEtmDm1HHnJY3MkomrXKp1dK9J0RXI=";
  };

  # ValueError: GOOGLE_GENAI_REPLAYS_DIRECTORY environment variable is not set
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    packaging
    pkginfo
    setuptools
    twine
  ];

  dependencies = [
    anyio
    distro
    google-auth
    httpx
    pydantic
    requests
    sniffio
    tenacity
    typing-extensions
    websockets
  ]
  ++ google-auth.optional-dependencies.requests;

  optional-dependencies = {
    aiohttp = [ aiohttp ];
  };

  pyproject = true;
  pythonImportsCheck = [ "google.genai" ];

  pythonRelaxDeps = [
    "tenacity"
    "websockets"
  ];

  meta = {
    description = "Google Generative AI Python SDK";
    homepage = "https://github.com/googleapis/python-genai";
    changelog = "https://github.com/googleapis/python-genai/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
