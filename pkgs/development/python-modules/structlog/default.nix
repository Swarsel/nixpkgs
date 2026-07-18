{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  time-machine,
}:

buildPythonPackage (finalAttrs: {
  pname = "structlog";
  version = "26.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "structlog";
    tag = finalAttrs.version;
    hash = "sha256-Q31eqeRYAbwn6Cj3hkXfy3udeBHHglEk5/qTjKbBbL8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    time-machine
  ];

  build-system = [
    hatch-fancy-pypi-readme
    hatch-vcs
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "structlog" ];

  meta = {
    description = "Painless structural logging";
    homepage = "https://github.com/hynek/structlog";
    changelog = "https://github.com/hynek/structlog/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
