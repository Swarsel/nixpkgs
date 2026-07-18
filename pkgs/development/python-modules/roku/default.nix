{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytest,
  requests,
}:

buildPythonPackage rec {
  pname = "roku";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "jcarbaugh";
    repo = "python-roku";
    rev = "v${version}";
    sha256 = "09mq59kjll7gj1srw4qc921ncsm7cld95sbz5v3p2bwmgckpqza7";
  };

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytest
    flask
  ];

  format = "setuptools";
  pythonImportsCheck = [ "roku" ];

  meta = {
    description = "Screw remotes. Control your Roku with Python";
    homepage = "https://github.com/jcarbaugh/python-roku";
    license = lib.licenses.bsd3;
  };
}
