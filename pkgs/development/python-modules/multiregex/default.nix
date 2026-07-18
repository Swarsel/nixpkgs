{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyahocorasick,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "multiregex";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "quantco";
    repo = "multiregex";
    tag = finalAttrs.version;
    hash = "sha256-BWADzarhnzcz2ZvD33XcQpQIIJ0hmhUT33HyUbB1wH0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyahocorasick ];
  pyproject = true;
  pythonImportsCheck = [ "multiregex" ];

  meta = {
    description = "Quickly match many regexes against a string";
    homepage = "https://github.com/quantco/multiregex";
    changelog = "https://github.com/quantco/multiregex/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
