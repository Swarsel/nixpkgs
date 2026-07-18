{
  lib,
  fetchFromGitHub,
  aresponses,
  async-modbus,
  async-timeout,
  asyncclick,
  buildPythonPackage,
  construct,
  exceptiongroup,
  pandas,
  pytest-asyncio,
  pytestCheckHook,
  python-slugify,
  setuptools,
  tenacity,
}:

buildPythonPackage (finalAttrs: {
  pname = "nibe";
  version = "2.23.0";

  src = fetchFromGitHub {
    owner = "yozik04";
    repo = "nibe";
    tag = finalAttrs.version;
    hash = "sha256-jBLsddnhUKdIntKmux6N/J07fnoVCBq0IbWyiWGKvlw=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ setuptools ];

  dependencies = [
    async-modbus
    async-timeout
    construct
    exceptiongroup
    tenacity
  ];

  optional-dependencies = {
    cli = [ asyncclick ];

    convert = [
      pandas
      python-slugify
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nibe" ];
  pythonRelaxDeps = [ "async-modbus" ];

  meta = {
    description = "Library for the communication with Nibe heatpumps";
    homepage = "https://github.com/yozik04/nibe";
    changelog = "https://github.com/yozik04/nibe/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
