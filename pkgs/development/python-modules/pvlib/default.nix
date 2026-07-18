{
  lib,
  buildPythonPackage,
  fetchPypi,
  h5py,
  numpy,
  pandas,
  pytest-mock,
  pytest-remotedata,
  pytest-rerunfailures,
  pytest-timeout,
  pytestCheckHook,
  pytz,
  requests,
  requests-mock,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pvlib";
  version = "0.14.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-nmpmhlJAzk4xy+nTYKKNbreVO6u2KsQDry+QrtFqRQk=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-remotedata
    pytest-rerunfailures
    pytest-timeout
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    h5py
    numpy
    pandas
    pytz
    requests
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pvlib" ];

  meta = {
    description = "Simulate the performance of photovoltaic energy systems";
    homepage = "https://pvlib-python.readthedocs.io";
    changelog = "https://pvlib-python.readthedocs.io/en/v${finalAttrs.version}/whatsnew.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jluttine ];
  };
})
