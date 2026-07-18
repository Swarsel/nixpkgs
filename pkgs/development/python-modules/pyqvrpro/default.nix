{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-vcr,
  pytestCheckHook,
  pyyaml,
  requests,
  untangle,
}:

buildPythonPackage rec {
  pname = "pyqvrpro";
  version = "0.52";

  src = fetchFromGitHub {
    owner = "oblogic7";
    repo = "pyqvrpro";
    rev = "v${version}";
    hash = "sha256-lOd2AqnrkexNqT/usmJts5NW7vJtV8CRsliYgkhgRaU=";
  };

  propagatedBuildInputs = [
    pyyaml
    requests
    untangle
  ];

  nativeCheckInputs = [
    pytest-vcr
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pyqvrpro" ];

  meta = {
    description = "Module for interfacing with QVR Pro API";
    homepage = "https://github.com/oblogic7/pyqvrpro";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
