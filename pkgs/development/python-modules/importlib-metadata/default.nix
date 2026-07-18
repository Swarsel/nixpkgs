{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Reverse dependency
  sage,
  setuptools,
  setuptools-scm,
  toml,
  zipp,
}:

buildPythonPackage rec {
  pname = "importlib-metadata";
  version = "9.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-pPV6tZnmouMBbXWVz9cutGYaUQbnh6lbzJDHEFuDHvw=";
    pname = "importlib_metadata";
  };

  postPatch = ''
    sed -i "/coherent.licensed/d" pyproject.toml
  '';

  # Cyclic dependencies due to pyflakefs
  doCheck = false;

  build-system = [
    setuptools # otherwise cross build fails
    setuptools-scm
  ];

  dependencies = [
    toml
    zipp
  ];

  pyproject = true;
  pythonImportsCheck = [ "importlib_metadata" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Read metadata from Python packages";
    homepage = "https://importlib-metadata.readthedocs.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      fab
    ];
  };
}
