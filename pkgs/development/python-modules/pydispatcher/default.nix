{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pydispatcher";
  version = "2.0.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-t3fGrQgNwbrXSkwp1qRpFPpnAaxw+UsNZvvP3mL1vjE=";
    pname = "PyDispatcher";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Signal-registration and routing infrastructure for use in multiple contexts";
    homepage = "https://pydispatcher.sourceforge.net/";
    license = lib.licenses.bsd3;
  };
}
