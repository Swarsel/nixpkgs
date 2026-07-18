{
  lib,
  fetchFromGitHub,
  aiohttp,
  backoff,
  buildPythonPackage,
  fetchpatch,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "toonapi";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-toonapi";
    tag = "v${version}";
    hash = "sha256-RaN9ppqJbTik1/vNX0/YLoBawrqjyQWU6+FLTspIxug=";
  };

  patches = [
    # https://github.com/frenck/python-toonapi/pull/15
    (fetchpatch {
      hash = "sha256-EMK11M+2OTnIB7oWavpQKNQq0ZLuSxYQlC6On7ob1xU=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/frenck/python-toonapi/commit/a04f1d8bcbcf48889dae49219d2edadbeb2dfa01.patch";
    })
  ];

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    backoff
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "toonapi" ];

  meta = {
    description = "Python client for the Quby ToonAPI";
    homepage = "https://github.com/frenck/python-toonapi";
    changelog = "https://github.com/frenck/python-toonapi/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
