{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
  setuptools-scm,
  ujson,
}:

buildPythonPackage rec {
  pname = "enterpriseattack";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "xakepnz";
    repo = "enterpriseattack";
    tag = "v${version}";
    hash = "sha256-OZ/nao2oiXzzWl/zQA5A3GpsRNobnHb4ubAsZvVITj0=";
  };

  # Tests require network access
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    requests
    ujson
  ];

  pyproject = true;
  pythonImportsCheck = [ "enterpriseattack" ];

  meta = {
    description = "Module to interact with the Mitre Att&ck Enterprise dataset";
    homepage = "https://github.com/xakepnz/enterpriseattack";
    changelog = "https://github.com/xakepnz/enterpriseattack/releases/tag/v.${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
