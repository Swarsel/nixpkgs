{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-resources,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "typeshed-client";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "JelleZijlstra";
    repo = "typeshed_client";
    tag = "v${version}";
    hash = "sha256-hSyhGn+xEUjZVrYUYaxZ/3CwNXy4EJ2TG73S9o3o0gw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    importlib-resources
    typing-extensions
  ];

  enabledTestPaths = [ "tests/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "typeshed_client" ];

  meta = {
    description = "Retrieve information from typeshed and other typing stubs";
    homepage = "https://github.com/JelleZijlstra/typeshed_client";
    changelog = "https://github.com/JelleZijlstra/typeshed_client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
