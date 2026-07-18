{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyrsistent";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "tobgu";
    repo = "pyrsistent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8fLyz8ELOg5GCrBHLSl4iiCgEZ6MuFoBwNKns5AI5Ps=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    typing-extensions
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyrsistent" ];

  meta = {
    description = "Persistent/Functional/Immutable data structures";
    homepage = "https://github.com/tobgu/pyrsistent/";
    changelog = "https://github.com/tobgu/pyrsistent/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.mit;
  };
})
