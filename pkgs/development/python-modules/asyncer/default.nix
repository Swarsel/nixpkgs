{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  pdm-backend,
  pytestCheckHook,
  sniffio,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "fastapi";
    repo = "asyncer";
    tag = version;
    hash = "sha256-4h6s0jsAzTT6LbsvfQGkc7qNCcPgoyR9Qr/yro1ukbg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];

  dependencies = [
    anyio
    sniffio
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyncer" ];

  meta = {
    description = "Asyncer, async and await, focused on developer experience";
    homepage = "https://github.com/fastapi/asyncer";
    changelog = "https://github.com/fastapi/asyncer/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
