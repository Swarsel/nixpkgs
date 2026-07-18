{
  lib,
  fetchFromGitHub,
  aiofiles,
  apify-fingerprint-datapoints,
  buildPythonPackage,
  click,
  httpx,
  orjson,
  poetry-core,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "browserforge";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "daijro";
    repo = "browserforge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8mh1Wok96rwUNAdnaoI1VYkyNr50JX/K7o04n/epuMo=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiofiles
    apify-fingerprint-datapoints
    click
    httpx
    orjson
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "browserforge" ];

  meta = {
    description = "Intelligent browser header & fingerprint generator";
    homepage = "https://github.com/daijro/browserforge";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
