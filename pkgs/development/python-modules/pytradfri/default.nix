{
  lib,
  fetchFromGitHub,
  aiocoap,
  buildPythonPackage,
  dtlssocket,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytradfri";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "pytradfri";
    tag = version;
    hash = "sha256-oYYi1P0Zu9PLsacUW//BlJlLmeOVvHgb/lR52KwZ7N8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ optional-dependencies.async;

  build-system = [ setuptools ];
  dependencies = [ pydantic ];

  optional-dependencies = {
    async = [
      aiocoap
      dtlssocket
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pytradfri" ];

  meta = {
    description = "Python package to communicate with the IKEA Trådfri ZigBee Gateway";
    homepage = "https://github.com/home-assistant-libs/pytradfri";
    changelog = "https://github.com/home-assistant-libs/pytradfri/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
