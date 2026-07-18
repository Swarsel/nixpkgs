{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ebusdpy";
  version = "0.0.17";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-t6O/fOBrJuDYpCVnkL+hUzyqMoGKFj5UYNoD6ExikNM=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ebusdpy" ];

  meta = {
    description = "eBusd python integration library";
    homepage = "https://github.com/CrazYoshi/ebusdpy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
