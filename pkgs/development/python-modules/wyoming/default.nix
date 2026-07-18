{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  flask,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
  swagger-ui-py,
  wyoming-faster-whisper,
  wyoming-openwakeword,
  wyoming-piper,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "wyoming";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "wyoming";
    tag = "v${version}";
    hash = "sha256-bjte8CNqNYyEW0WeB8QTAsJJoXmZj/VQlt6ZbY2r5pI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  optional-dependencies = {
    http = [
      flask
      swagger-ui-py
    ]
    ++ flask.optional-dependencies.async;

    zeroconf = [ zeroconf ];
  };

  pyproject = true;
  pythonImportsCheck = [ "wyoming" ];

  passthru.tests = {
    inherit wyoming-faster-whisper wyoming-openwakeword wyoming-piper;
  };

  meta = {
    description = "Protocol for Rhasspy Voice Assistant";
    homepage = "https://github.com/OHF-Voice/wyoming";
    changelog = "https://github.com/OHF-Voice/wyoming/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
