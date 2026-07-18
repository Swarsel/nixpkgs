{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  gitUpdater,
  livekit-protocol,
  protobuf,
  pyjwt,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "livekit-api";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "livekit";
    repo = "python-sdks";
    tag = "api-v${version}";
    hash = "sha256-Z9ZyzESPUR+j9s9LXSTDx3pB+bltbqTeb8WVKaKk80A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyjwt
    aiohttp
    protobuf
    livekit-protocol
  ];

  enabledTestPaths = [ "livekit-api/tests" ];
  pypaBuildFlags = [ "livekit-api" ];
  pyproject = true;
  pythonImportsCheck = [ "livekit" ];
  pythonRemoveDeps = [ "types-protobuf" ];
  passthru.updateScript = gitUpdater { rev-prefix = "api-v"; };

  meta = {
    description = "LiveKit real-time and server SDKs for Python";
    homepage = "https://github.com/livekit/python-sdks/";
    changelog = "https://github.com/livekit/python-sdks/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ soyouzpanda ];
    platforms = lib.platforms.all;
  };
}
