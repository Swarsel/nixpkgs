{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  mock,
  pbr,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  six,
}:
buildPythonPackage rec {
  pname = "pymaven-patch";
  version = "0.3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DPfJPonwHwQI62Vu7FjLSiKMleA7PUfLc9MfiZBVzVA=";
  };

  propagatedBuildInputs = [
    pbr
    requests
    six
    lxml
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    mock
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pymaven" ];

  meta = {
    description = "Python access to maven";
    homepage = "https://github.com/nexB/pymaven";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
