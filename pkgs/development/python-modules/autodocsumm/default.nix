{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  sphinx,
  versioneer,
}:
buildPythonPackage rec {
  pname = "autodocsumm";
  version = "0.2.15";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6vQx56WjnkGiFTERc8i5XoOFkFnfHM87ecZL89VYKzw=";
    pname = "autodocsumm";
  };

  build-system = [ setuptools ];

  dependencies = [
    versioneer
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "autodocsumm" ];

  meta = {
    description = "Extended sphinx autodoc including automatic autosummaries";
    homepage = "https://github.com/Chilipp/autodocsumm";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
