{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  ciso8601,
  mashumaro,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  typer,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiortm";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "MartinHjelmare";
    repo = "aiortm";
    tag = "v${version}";
    hash = "sha256-6idPxFW1h9kyeivBdZ8tEznPCmZLK7Uno+ZKP21WoeA=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    ciso8601
    mashumaro
    yarl
  ];

  disabled = pythonOlder "3.12";

  optional-dependencies = {
    cli = [ typer ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiortm" ];
  pythonRelaxDeps = [ "typer" ];

  meta = {
    description = "Library for the Remember the Milk API";
    homepage = "https://github.com/MartinHjelmare/aiortm";
    changelog = "https://github.com/MartinHjelmare/aiortm/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aiortm";
  };
}
