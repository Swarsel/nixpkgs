{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  httpcore,
  httpx,
  packaging,
  # build-system
  poetry-core,
  protobuf,
  python-dateutil,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "e2b";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "e2b-dev";
    repo = "E2B";
    tag = "@e2b/python-sdk@${version}";
    hash = "sha256-6THRc4rv/mzOWbsN1FpUu56kjvHvVBssK2glNoGdSzI=";
  };

  # Tests require an API key
  # e2b.exceptions.AuthenticationException: API key is required, please visit the Team tab at https://e2b.dev/dashboard to get your API key.
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    attrs
    httpcore
    httpx
    packaging
    protobuf
    python-dateutil
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "e2b" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  sourceRoot = "${src.name}/packages/python-sdk";

  meta = {
    description = "E2B SDK that give agents cloud environments";
    homepage = "https://github.com/e2b-dev/E2B/blob/main/packages/python-sdk";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
