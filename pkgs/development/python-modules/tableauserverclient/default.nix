{
  lib,
  buildPythonPackage,
  defusedxml,
  fetchPypi,
  packaging,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  typing-extensions,
  versioneer,
}:

buildPythonPackage rec {
  pname = "tableauserverclient";
  version = "0.38";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Td2QW10vsKojhk9eeO90QbArdIuNn+hbNk9LvCYwgyo=";
  };

  # Tests attempt to create some file artifacts and fails
  doCheck = false;

  nativeCheckInputs = [
    requests-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    defusedxml
    requests
    packaging
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "tableauserverclient" ];

  pythonRelaxDeps = [
    "defusedxml"
    "urllib3"
  ];

  meta = {
    description = "Module for working with the Tableau Server REST API";
    homepage = "https://github.com/tableau/server-client-python";
    changelog = "https://github.com/tableau/server-client-python/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
