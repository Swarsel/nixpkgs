{
  lib,
  fetchFromGitHub,
  asyncclick,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  tzlocal,
}:

buildPythonPackage (finalAttrs: {
  pname = "gardena-bluetooth";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "elupus";
    repo = "gardena-bluetooth";
    tag = finalAttrs.version;
    hash = "sha256-yl1I36p21lemKigijqks7cwOxWej+35bDB2D0KO3pa0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
    tzlocal
  ];

  optional-dependencies = {
    cli = [ asyncclick ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gardena_bluetooth" ];

  meta = {
    description = "Module for interacting with Gardena Bluetooth";
    homepage = "https://github.com/elupus/gardena-bluetooth";
    changelog = "https://github.com/elupus/gardena-bluetooth/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
