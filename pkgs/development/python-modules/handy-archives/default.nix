{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:
buildPythonPackage rec {
  pname = "handy-archives";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+6IRAf2eKdXjtygjJhqq4GuTUGhvDSBneG1k3Oc+s/Y=";
    pname = "handy_archives";
  };

  build-system = [ flit-core ];

  dependencies = [
  ];

  pyproject = true;

  meta = {
    description = "Some handy archive helpers for Python";
    homepage = "https://github.com/domdfcoding/handy-archives";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tyberius-prime ];
  };
}
