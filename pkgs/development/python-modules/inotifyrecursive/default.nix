{
  lib,
  buildPythonPackage,
  fetchPypi,
  inotify-simple,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "inotifyrecursive";
  version = "0.3.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-osRQsxdpPkU4QW+Q6x14WFBtr+a4uIUDe9LdmuLa+h4=";
  };

  # No tests included
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ inotify-simple ];
  pyproject = true;
  pythonImportsCheck = [ "inotifyrecursive" ];

  meta = {
    description = "Simple recursive inotify watches for Python";
    homepage = "https://github.com/letorbi/inotifyrecursive";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ Flakebi ];
  };
})
