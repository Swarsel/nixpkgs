{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "aiosqlite";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "omnilib";
    repo = "aiosqlite";
    tag = "v${version}";
    hash = "sha256-3l/uR97WuLlkAEdogL9iYoXp89bsAcpH6XEtMELsX9o=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ typing-extensions ];
  # Tests are not pick-up automatically by the hook
  enabledTestPaths = [ "aiosqlite/tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "aiosqlite" ];

  meta = {
    description = "Asyncio bridge to the standard sqlite3 module";
    homepage = "https://github.com/jreese/aiosqlite";
    changelog = "https://github.com/omnilib/aiosqlite/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
