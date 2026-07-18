{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "types-psutil";
  version = "7.2.1.20260116";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RmG+XV16zV2K+wKpLQUWCmy7LOdHIyRbUfe6ff25+YE=";
    pname = "types_psutil";
  };

  # Module doesn't have tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "psutil-stubs" ];

  meta = {
    description = "Typing stubs for psutil";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
