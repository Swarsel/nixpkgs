{
  lib,
  fetchFromGitHub,
  asgiref,
  buildPythonPackage,
  channels,
  cryptography,
  msgpack,
  redis,
  setuptools,
}:

buildPythonPackage rec {
  pname = "channels-redis";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "django";
    repo = "channels_redis";
    tag = version;
    hash = "sha256-zn313s1rzypSR5D3iE/05PeBQkx/Se/yaA3NS9BY//Y=";
  };

  # Fails with : ConnectionRefusedError: [Errno 111] Connect call failed ('127.0.0.1', 6379)
  # (even with a local Redis instance running)
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    redis
    asgiref
    channels
    msgpack
  ];

  optional-dependencies = {
    cryptography = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "channels_redis" ];

  meta = {
    description = "Redis-backed ASGI channel layer implementation";
    homepage = "https://github.com/django/channels_redis/";
    changelog = "https://github.com/django/channels_redis/blob/${src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
