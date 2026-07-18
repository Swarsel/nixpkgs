{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  orjson,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "steamloop";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "hvaclibs";
    repo = "steamloop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7AxUEe57OpDi2ofbKWvdcFCoq7ARXtlKpiJQyQX891c=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ orjson ];
  pyproject = true;
  pythonImportsCheck = [ "steamloop" ];

  meta = {
    description = "Local control for choochoo based thermostats";
    homepage = "https://github.com/hvaclibs/steamloop";
    changelog = "https://github.com/hvaclibs/steamloop/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
