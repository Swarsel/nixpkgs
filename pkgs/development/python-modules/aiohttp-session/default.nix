{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # optional-dependencies
  aiomcache,
  buildPythonPackage,
  cryptography,
  pynacl,
  redis,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiohttp-session";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp-session";
    tag = "v${version}";
    hash = "sha256-mGWtHo/+jdCmv3TmUUv42hWSiLzPiP5ytB25pVyvZig=";
  };

  doCheck = false; # runs redis in docker
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];

  optional-dependencies = {
    aiomcache = [ aiomcache ];
    aioredis = [ redis ];
    pycrypto = [ cryptography ];
    pynacl = [ pynacl ];
    secure = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_session" ];

  meta = {
    description = "Web sessions for aiohttp.web";
    homepage = "https://github.com/aio-libs/aiohttp-session";
    changelog = "https://github.com/aio-libs/aiohttp-session/blob/${src.rev}/CHANGES.txt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
