{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  gotify-server,
  httpx,
  nix-update-script,
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  typeguard,
  websockets,
}:

buildPythonPackage rec {
  pname = "gotify";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "d-k-bo";
    repo = "python-gotify";
    tag = "v${version}";
    hash = "sha256-epm8m2W+ChOvWHZi2ruAD+HJGj+V7NfhmFLKeeqcpoI=";
  };

  # tests require gotify-server to be located in ./tests/test-server/gotify-linux-{arch}
  postPatch = ''
    ln -s "${gotify-server}/bin/server" ./tests/test-server/gotify-linux-386
    ln -s "${gotify-server}/bin/server" ./tests/test-server/gotify-linux-amd64
    ln -s "${gotify-server}/bin/server" ./tests/test-server/gotify-linux-arm-7
    ln -s "${gotify-server}/bin/server" ./tests/test-server/gotify-linux-arm64
  '';

  # tests raise an exception if the system is not Linux or Windows
  doCheck = !stdenv.buildPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    typeguard
    gotify-server
  ];

  build-system = [ flit-core ];

  dependencies = [
    httpx
    websockets
  ];

  disabled = pythonAtLeast "3.14";
  pyproject = true;

  pythonImportsCheck = [
    "gotify"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python library to access your gotify server";
    homepage = "https://github.com/d-k-bo/python-gotify";
    changelog = "https://github.com/d-k-bo/python-gotify/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.joblade
    ];

    # https://github.com/d-k-bo/python-gotify/issues/6
    broken = lib.versionAtLeast gotify-server.version "2.9.0";
  };
}
