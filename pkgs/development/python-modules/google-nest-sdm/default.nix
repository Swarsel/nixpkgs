{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  coreutils,
  google-auth,
  google-auth-oauthlib,
  google-cloud-pubsub,
  mashumaro,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  requests-oauthlib,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "google-nest-sdm";
  version = "9.1.2";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "python-google-nest-sdm";
    tag = finalAttrs.version;
    hash = "sha256-yElmh+ajNVbjhsnNsUtQ3mJw9fvJtXqgS58iow+Nwi8=";
  };

  nativeCheckInputs = [
    coreutils
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    google-auth
    google-auth-oauthlib
    google-cloud-pubsub
    mashumaro
    pyyaml
    requests-oauthlib
  ];

  disabledTests = [
    "test_clip_preview_transcode"
    "test_event_manager_event_expiration_with_transcode"
  ];

  pyproject = true;
  pythonImportsCheck = [ "google_nest_sdm" ];

  meta = {
    description = "Module for Google Nest Device Access using the Smart Device Management API";
    homepage = "https://github.com/allenporter/python-google-nest-sdm";
    changelog = "https://github.com/allenporter/python-google-nest-sdm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "google_nest";
  };
})
