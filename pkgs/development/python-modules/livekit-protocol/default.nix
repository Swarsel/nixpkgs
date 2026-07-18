{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  hatchling,
  protobuf,
}:

buildPythonPackage rec {
  pname = "livekit-protocol";
  version = "1.1.17";

  src = fetchFromGitHub {
    owner = "livekit";
    repo = "python-sdks";
    tag = "protocol-v${version}";
    hash = "sha256-XTBQi1ckwHw7bpd2jQWqwhDXO0iHQRirc2GjfDtYILA=";
  };

  doCheck = false; # no tests
  build-system = [ hatchling ];

  dependencies = [
    protobuf
  ];

  pypaBuildFlags = [ "livekit-protocol" ];
  pyproject = true;
  pythonImportsCheck = [ "livekit" ];
  pythonRemoveDeps = [ "types-protobuf" ];
  passthru.updateScript = gitUpdater { rev-prefix = "protocol-v"; };

  meta = {
    description = "LiveKit real-time and server SDKs for Python";
    homepage = "https://github.com/livekit/python-sdks/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ soyouzpanda ];
    platforms = lib.platforms.all;
  };
}
