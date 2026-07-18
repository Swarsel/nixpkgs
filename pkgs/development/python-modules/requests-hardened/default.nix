{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pproxy,
  pysocks,
  pytest-socket,
  pytestCheckHook,
  requests,
  trustme,
}:
buildPythonPackage rec {
  pname = "requests-hardened";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "saleor";
    repo = "requests-hardened";
    tag = "v${version}";
    hash = "sha256-tvSS3z1fhQdcxvsj5vK//mr5xYeIrLl+6/gtnWsiETk=";
  };

  nativeCheckInputs = [
    pproxy
    pytest-socket
    pysocks
    trustme
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "requests_hardened" ];

  meta = {
    description = "Library that adds hardened behavior to python requests";
    homepage = "https://github.com/saleor/requests-hardened";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ryand56 ];
  };
}
