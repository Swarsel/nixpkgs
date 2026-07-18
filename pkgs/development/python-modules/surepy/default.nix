{
  lib,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  async-timeout,
  attrs,
  brotlipy,
  buildPythonPackage,
  click,
  colorama,
  faust-cchardet,
  halo,
  poetry-core,
  requests,
  rich,
}:

buildPythonPackage rec {
  pname = "surepy";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "benleb";
    repo = "surepy";
    tag = "v${version}";
    hash = "sha256-ETgpXSUUsV1xoZjdnL2bzn4HwDjKC2t13yXwf28OBqI=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiodns
    aiohttp
    async-timeout
    attrs
    brotlipy
    click
    colorama
    faust-cchardet
    halo
    requests
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "surepy" ];

  pythonRelaxDeps = [
    "aiohttp"
    "async-timeout"
    "rich"
  ];

  meta = {
    description = "Python library to interact with the Sure Petcare API";
    homepage = "https://github.com/benleb/surepy";
    changelog = "https://github.com/benleb/surepy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "surepy";
  };
}
