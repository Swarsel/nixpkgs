{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypercorn,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
  starlette,
  uvloop,
}:

buildPythonPackage rec {
  pname = "openapi3";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "Dorthu";
    repo = "openapi3";
    rev = version;
    hash = "sha256-Crn+nRbptRycnWJzH8Tm/BBLcBSRCcNtLX8NoKnSDdA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pydantic
    uvloop
    hypercorn
    starlette
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    pyyaml
  ];

  disabledTestPaths = [
    # tests old fastapi behaviour
    "tests/fastapi_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "openapi3" ];
  # pydantic==1.10.2 only affects checks
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Python3 OpenAPI 3 Spec Parser";
    homepage = "https://github.com/Dorthu/openapi3";
    changelog = "https://github.com/Dorthu/openapi3/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ techknowlogick ];
  };
}
