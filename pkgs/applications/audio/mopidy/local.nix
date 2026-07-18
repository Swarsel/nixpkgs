{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-local";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-y6btbGk5UiVan178x7d9jq5OTnKMbuliHv0aRxuZK3o=";
    pname = "mopidy_local";
  };

  nativeCheckInputs = [
    pythonPackages.pytestCheckHook
  ];

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.uritools
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_local" ];

  meta = {
    description = "Mopidy extension for playing music from your local music archive";
    homepage = "https://github.com/mopidy/mopidy-local";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ruuda ];
  };
})
