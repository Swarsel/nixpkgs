{
  lib,
  buildPythonPackage,
  fetchPypi,
  gitMinimal,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pdm-pep517";
  version = "1.1.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-f0kSHnC0Lcopb6yWIhDdLaB6OVdfxWcxN61mFjOyzz8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    gitMinimal
    setuptools
  ];

  preCheck = ''
    HOME=$TMPDIR

    git config --global user.name nobody
    git config --global user.email nobody@example.com
  '';

  pyproject = true;

  meta = {
    description = "Yet another PEP 517 backend";
    homepage = "https://github.com/pdm-project/pdm-pep517";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
})
