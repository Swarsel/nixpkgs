{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  faust-cchardet,
  orjson,
  packaging,
  pythonOlder,
  setuptools,
  tomli,
  tomli-w,
  xmltodict,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "axis";
  version = "74";

  src = fetchFromGitHub {
    owner = "Kane610";
    repo = "axis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fWhQe4NklAva4znXUwYhrMdC/VCu4oZgwsyGuGd9csk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==82.0.1" "setuptools" \
      --replace-fail "wheel==0.47.0" "wheel"
  '';

  # Tests requires a server on localhost
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    faust-cchardet
    orjson
    packaging
    tomli
    tomli-w
    xmltodict
    zeroconf
  ];

  disabled = pythonOlder "3.14";
  pyproject = true;
  pythonImportsCheck = [ "axis" ];

  meta = {
    description = "Python library for communicating with devices from Axis Communications";
    homepage = "https://github.com/Kane610/axis";
    changelog = "https://github.com/Kane610/axis/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "axis";
  };
})
