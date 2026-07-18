{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pandas,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "prometheus-pandas";
  version = "0.3.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-1eaTmNui3cAisKEhBMEpOv+UndJZwb4GGK2M76xiy7k=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    pandas
  ];

  # There are no tests. :(
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "prometheus_pandas" ];

  meta = {
    description = "Pandas integration for Prometheus";
    homepage = "https://github.com/dcoles/prometheus-pandas";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viktornordling ];
  };
})
