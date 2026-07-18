{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  pydbus,
  pygobject3,
  setuptools,
  strenum,
}:
buildPythonPackage rec {
  pname = "mprisify";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "zehkira";
    repo = "mprisify";
    tag = "v${version}";
    hash = "sha256-ir/zv6GGU1TMPoUB05oqWUNt4eEcFzfQ9gShlKYdUfc=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pydbus
    pygobject3
    strenum
  ];

  pyproject = true;
  pythonImportsCheck = [ "mprisify" ];

  meta = {
    description = "Python MPRIS server library for Linux media player apps";
    homepage = "https://gitlab.com/zehkira/mprisify";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ quadradical ];
  };
}
