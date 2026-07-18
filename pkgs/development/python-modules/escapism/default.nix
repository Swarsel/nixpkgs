{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "escapism";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-rdEw5IqFuxquo+dPsDH1AzxwVa7bOaMmX5I9X0DD+XQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  meta = {
    description = "Simple, generic API for escaping strings";
    homepage = "https://github.com/minrk/escapism";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bzizou ];
  };
})
