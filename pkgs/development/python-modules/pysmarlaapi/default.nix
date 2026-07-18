{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  flit-core,
  jsonpickle,
  pysignalr,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysmarlaapi";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "Explicatis-GmbH";
    repo = "pysmarlaapi";
    tag = finalAttrs.version;
    hash = "sha256-teRdxYe9thM22tZ09FHxOxxzy4gcfJBAylgpk34ISTk=";
  };

  build-system = [ flit-core ];

  dependencies = [
    aiohttp
    jsonpickle
    pysignalr
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysmarlaapi" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Swing2Sleep Smarla API";
    homepage = "https://github.com/Explicatis-GmbH/pysmarlaapi";
    changelog = "https://github.com/Explicatis-GmbH/pysmarlaapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
