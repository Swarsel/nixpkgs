{
  lib,
  fetchFromGitHub,
  aioboto3,
  buildPythonPackage,
  orjson,
  redis,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "karton-core";
  version = "5.9.1";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b/wOkOk6LB8uTDsXJrNQ2iru2H6mgaMhIyWSU5y2mx0=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aioboto3
    orjson
    redis
  ];

  pyproject = true;
  pythonImportsCheck = [ "karton.core" ];

  pythonRelaxDeps = [
    "aioboto3"
    "boto3"
  ];

  meta = {
    description = "Distributed malware processing framework";
    homepage = "https://karton-core.readthedocs.io/";
    changelog = "https://github.com/CERT-Polska/karton/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      chivay
      fab
    ];
  };
})
