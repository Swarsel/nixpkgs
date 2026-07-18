{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  httpx,
}:

buildPythonPackage rec {
  pname = "httpx-aiohttp";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "karpetrosyan";
    repo = "httpx-aiohttp";
    tag = version;
    hash = "sha256-5k/+oEsW2oPN2OM0jXU/+FcsWQLvSdYgM8AuzTU9XrI=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "requires = [\"hatchling\", \"hatch-fancy-pypi-readme\"]" \
      "requires = [\"hatchling\"]"
  '';

  build-system = [
    hatchling
  ];

  dependencies = [
    aiohttp
    httpx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "httpx_aiohttp"
  ];

  meta = {
    description = "Transports for httpx to work atop aiohttp";
    homepage = "https://github.com/karpetrosyan/httpx-aiohttp/";
    changelog = "https://github.com/karpetrosyan/httpx-aiohttp/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
