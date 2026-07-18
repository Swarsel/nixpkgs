{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  numpy,
  pytestCheckHook,
  pytools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "cgen";
  version = "2025.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-efAeAQ1JwT5YtMqPLUmWprcXiWj18tkGJiczSArnotQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    pytools
    numpy
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "C/C++ source generation from an AST";
    homepage = "https://github.com/inducer/cgen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
