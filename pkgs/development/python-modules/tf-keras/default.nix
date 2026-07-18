{
  lib,
  buildPythonPackage,
  distutils,
  fetchPypi,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
  tensorflow,
}:

buildPythonPackage (finalAttrs: {
  inherit (tensorflow) version;
  pname = "tf-keras";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-+a8PJUbNVTLeD656SB80ocoiU3N9TNEAD2txPccz93A=";
    pname = "tf_keras";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    tensorflow
  ]
  ++ lib.optionals (pythonAtLeast "3.12") [ distutils ];

  pyproject = true;
  pythonImportsCheck = [ "tf_keras" ];

  meta = {
    description = "Deep learning for humans";
    homepage = "https://pypi.org/project/tf-keras/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
