{
  lib,
  buildPythonPackage,
  fetchPypi,
  gobject-introspection,
  gtk3,
  poetry-core,
  pycairo,
  pygobject3,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "gaphas";
  version = "5.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XdawWTHzhWqWtiMmm1AYcjG0q/e5hJ9I9+7FKJhWNpY=";
  };

  nativeBuildInputs = [
    poetry-core
    gobject-introspection
  ];

  buildInputs = [ gtk3 ];

  propagatedBuildInputs = [
    pycairo
    pygobject3
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "gaphas" ];

  meta = {
    description = "GTK+ based diagramming widget";
    homepage = "https://github.com/gaphor/gaphas";
    changelog = "https://github.com/gaphor/gaphas/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
