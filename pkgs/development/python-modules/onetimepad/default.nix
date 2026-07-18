{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "onetimepad";
  version = "1.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1eaade76d8036e1cb79e944b75874bfe5ee4046a571c0724564e1721565c73fd";
  };

  # upstream has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "onetimepad" ];

  meta = {
    description = "Hacky implementation of one-time pad";
    homepage = "https://jailuthra.in/onetimepad";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "onetimepad";
  };
}
