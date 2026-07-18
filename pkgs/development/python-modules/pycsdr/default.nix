{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  csdr,
}:

buildPythonPackage rec {
  pname = "pycsdr";
  version = "0.18.2";

  src = fetchFromGitHub {
    owner = "jketterl";
    repo = "pycsdr";
    rev = version;
    hash = "sha256-OzkH1L9bFXf+kK8OPjRXpGz+fPCs67spJfXyV28NWWQ=";
  };

  propagatedBuildInputs = [ csdr ];
  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pycsdr" ];

  meta = {
    description = "Bindings for the csdr library";
    homepage = "https://github.com/jketterl/pycsdr";
    license = lib.licenses.gpl3Only;
  };
}
