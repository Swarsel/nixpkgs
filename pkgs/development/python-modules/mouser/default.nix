{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "mouser";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "sparkmicro";
    repo = "mouser-api";
    tag = finalAttrs.version;
    hash = "sha256-E8RYtuY4OONl9fI25I2utk3JfElVJHlpfCuOPvHo5Dg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    click
    requests
  ];

  disabledTests = [
    # Search tests require an API key and network access
    "search"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mouser" ];

  meta = {
    description = "Mouser Python API";
    homepage = "https://github.com/sparkmicro/mouser-api";
    changelog = "https://github.com/sparkmicro/mouser-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gigahawk
    ];
  };
})
