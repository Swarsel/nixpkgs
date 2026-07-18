{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hurry-filesize";
  version = "0.9";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9TaDKa2++GrM07yUkFIjQLt5JgRVromxpCwQ9jgBuaY=";
    pname = "hurry.filesize";
  };

  # project has no repo...
  # fix implicit namespaces (PEP 420) warning
  patches = [ ./use-pep-420-implicit-namespace-package.patch ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hurry.filesize" ];

  meta = {
    description = "Simple Python library for human readable file sizes (or anything sized in bytes)";
    homepage = "https://pypi.org/project/hurry.filesize/";
    license = lib.licenses.zpl21;
    maintainers = with lib.maintainers; [ vizid ];
  };
})
