{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "toposort";
  version = "1.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v7tHnFPQppbqdAJgH05pPJewNng3yImLxkca38o3pr0=";
  };

  nativeBuildInputs = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "toposort" ];

  meta = {
    description = "Topological sort algorithm";
    homepage = "https://pypi.org/project/toposort/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
