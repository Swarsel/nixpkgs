{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  pyprojectVersionPatchHook,
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiohasupervisor";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "python-supervisor-client";
    tag = version;
    hash = "sha256-qIj3kiKSo0aUj7b250c39FqxU3jV6uegmBlxR6wOkQ8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=68.0,<82.1" "setuptools"
  '';

  nativeBuildInputs = [
    pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohasupervisor" ];

  meta = {
    description = "Client for Home Assistant Supervisor";
    homepage = "https://github.com/home-assistant-libs/python-supervisor-client";
    changelog = "https://github.com/home-assistant-libs/python-supervisor-client/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
