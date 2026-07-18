{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  protobuf,
  pycryptodomex,
  pyogg,
  requests,
  setuptools,
  websocket-client,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "librespot";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "kokarare1212";
    repo = "librespot-python";
    tag = "v${version}";
    hash = "sha256-VjVPrWttOYfWsxzZpRgpZVenmP0y9Fea6Bhv9U8BO9U=";
  };

  env.PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  # Doesn't include any tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    defusedxml
    protobuf
    pycryptodomex
    pyogg
    requests
    websocket-client
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "librespot" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Open Source Spotify Client";
    homepage = "https://github.com/kokarare1212/librespot-python";
    changelog = "https://github.com/kokarare1212/librespot-python/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ onny ];
  };
}
