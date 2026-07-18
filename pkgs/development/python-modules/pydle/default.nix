{
  lib,
  buildPythonPackage,
  fetchFromCodeberg,
  nix-update-script,
  poetry-core,
  pure-sasl,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pydle";
  version = "1.1.0";

  src = fetchFromCodeberg {
    owner = "shiz";
    repo = "pydle";
    tag = "v${version}";
    hash = "sha256-LxlE0JVKgwDcPB7QuKkmfBWG33pDzG0F9qaL88xF8r4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    pure-sasl
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pydle"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "IRCv3-compliant Python 3 IRC library";
    homepage = "https://codeberg.org/shiz/pydle";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ polyfloyd ];
  };
}
