{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  docutils,
  pygments,
  pytest,
  pytest-asyncio,
  pytest-rerunfailures,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-subprocess";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "aklajnert";
    repo = "pytest-subprocess";
    tag = version;
    hash = "sha256-zPKExIrCt8ZwhKGU0l3tyTcDhRIGPSiM8OWy5cpmsuE=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
    docutils
    pygments
    pytest-rerunfailures
    pytest-asyncio
    anyio
    typing-extensions
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Plugin to fake subprocess for pytest";
    homepage = "https://github.com/aklajnert/pytest-subprocess";
    changelog = "https://github.com/aklajnert/pytest-subprocess/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
