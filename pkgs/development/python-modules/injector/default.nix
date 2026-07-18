{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "injector";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "python-injector";
    repo = "injector";
    tag = version;
    hash = "sha256-Pv+3D2eyZiposXMsfhVniGNvlNGb3xSZfjIQBLMcbLA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  format = "setuptools";
  pythonImportsCheck = [ "injector" ];

  meta = {
    description = "Python dependency injection framework, inspired by Guice";
    homepage = "https://github.com/alecthomas/injector";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
