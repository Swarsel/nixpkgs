{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pluginbase";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/2wzqY/OIy6cc4QdeHpkPeV0k3Bp8NGBRwKNcNfe4oc=";
  };

  # https://github.com/mitsuhiko/pluginbase/issues/24
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pluginbase" ];

  meta = {
    description = "Support library for building plugins systems in Python";
    homepage = "https://github.com/mitsuhiko/pluginbase";
    changelog = "https://github.com/mitsuhiko/pluginbase/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
