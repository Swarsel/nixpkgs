{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  openssl,
  pytestCheckHook,
  setuptools,
  srtp,
}:

buildPythonPackage rec {
  pname = "pylibsrtp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "aiortc";
    repo = "pylibsrtp";
    tag = version;
    hash = "sha256-Q8EyGAJKkq14sqSEMWLB8arKvj/wuALK/XwOZ27F1nQ=";
  };

  doCheck = true;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cffi
    srtp
    openssl
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pylibsrtp"
  ];

  meta = {
    description = "Python bindings for libsrtp";
    homepage = "https://github.com/aiortc/pylibsrtp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gesperon ];
  };
}
