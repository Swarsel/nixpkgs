{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachetools,
  gevent,
  gevent-eventemitter,
  protobuf,
  pycryptodomex,
  requests,
  setuptools,
  six,
  urllib3,
  vdf,
}:
buildPythonPackage rec {
  pname = "steam";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = "steam";
    rev = "v${version}";
    hash = "sha256-OY04GsX3KMPvpsQl8sUurzFyJu+JKpES8B0iD6Z5uyw=";
  };

  build-system = [ setuptools ];

  dependencies = [
    six
    pycryptodomex
    requests
    urllib3
    vdf
    gevent
    protobuf
    gevent-eventemitter
    cachetools
  ];

  pyproject = true;

  meta = {
    description = "Python package for interacting with Steam";
    homepage = "https://github.com/ValvePython/steam";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ weirdrock ];
    platforms = lib.platforms.linux;
  };
}
