{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  iso4217,
  poetry-core,
  poetry-dynamic-versioning,
  pytz,
}:

buildPythonPackage rec {
  pname = "pyefergy";
  version = "22.5.0";

  src = fetchFromGitHub {
    owner = "tkdrob";
    repo = "pyefergy";
    tag = "v${version}";
    hash = "sha256-4M3r/+C42X95/7BGZAJbkXKKFEkGzLlvX0Ynv+eL8qc=";
  };

  # Tests require network access
  doCheck = false;

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    aiohttp
    iso4217
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyefergy" ];

  pythonRemoveDeps = [
    "codecov"
    "types-pytz"
  ];

  meta = {
    description = "Python API library for Efergy energy meters";
    homepage = "https://github.com/tkdrob/pyefergy";
    changelog = "https://github.com/tkdrob/pyefergy/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
