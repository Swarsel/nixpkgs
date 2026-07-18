{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  ptyprocess,
  pytest-timeout,
  pytestCheckHook,
  tornado,
}:

buildPythonPackage rec {
  pname = "terminado";
  version = "0.18.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3gnyxLhd5HZfdxRoj/9X0+dbrR+Qm1if3ogEYMdT/S4=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    ptyprocess
    tornado
  ];

  nativeCheckInputs = [
    pytest-timeout
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;
  pytestFlags = [ "-Wignore::pytest.PytestUnraisableExceptionWarning" ];
  pythonImportsCheck = [ "terminado" ];

  meta = {
    description = "Terminals served by Tornado websockets";
    homepage = "https://github.com/jupyter/terminado";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
