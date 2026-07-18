{
  lib,
  absl-py,
  buildPythonPackage,
  dm-tree,
  fetchPypi,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "dm-env";
  version = "1.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pDbrHGVMOeDJhqUWzuIYvqcUC1EPzv9j+X60/P89k94=";
  };

  buildInputs = [
    absl-py
    dm-tree
    numpy
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "dm_env" ];

  meta = {
    description = "Pure Python client for Apache Kafka";
    homepage = "https://github.com/dpkp/kafka-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ onny ];
  };
}
