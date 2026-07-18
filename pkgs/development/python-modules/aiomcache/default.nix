{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  python-memcached,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiomcache";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiomcache";
    rev = "v${version}";
    hash = "sha256-+rlKHDop0kNxJ0HoXROs/oyI4zE3MDyxXXhWZtVDMj4=";
  };

  doCheck = false; # executes memcached in docker
  build-system = [ setuptools ];
  dependencies = [ python-memcached ];
  pyproject = true;
  pythonImportsCheck = [ "aiomcache" ];

  meta = {
    description = "Minimal asyncio memcached client";
    homepage = "https://github.com/aio-libs/aiomcache/";
    changelog = "https://github.com/aio-libs/aiomcache/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
