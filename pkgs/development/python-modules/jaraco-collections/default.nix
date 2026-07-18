{
  lib,
  buildPythonPackage,
  fetchPypi,
  jaraco-classes,
  jaraco-text,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-collections";
  version = "5.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2rgZcLrW8KtTsgdF8bAdo3km5MD81CUEaqReDY76GO0=";
    pname = "jaraco_collections";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    jaraco-classes
    jaraco-text
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.collections" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Models and classes to supplement the stdlib 'collections' module";
    homepage = "https://github.com/jaraco/jaraco.collections";
    changelog = "https://github.com/jaraco/jaraco.collections/blob/v${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
