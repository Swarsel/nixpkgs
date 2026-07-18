{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  mashumaro,
  # reverse dependencies
  music-assistant,
  music-assistant-client,
  orjson,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "music-assistant-models";
  # Must be compatible with music-assistant-client package
  # nixpkgs-update: no auto update
  version = "1.1.139";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "models";
    tag = finalAttrs.version;
    hash = "sha256-AT+R0Sor3aDqydGfT8gJfk9/rEpqEOad5ytnGnW7B1U=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "0.0.0" "${finalAttrs.version}"
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    mashumaro
    orjson
  ];

  pyproject = true;

  pythonImportsCheck = [
    "music_assistant_models"
  ];

  passthru.tests = {
    inherit music-assistant music-assistant-client;
  };

  meta = {
    description = "Models used by Music Assistant (shared by client and server)";
    homepage = "https://github.com/music-assistant/models";
    changelog = "https://github.com/music-assistant/models/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
