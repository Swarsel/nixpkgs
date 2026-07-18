{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyfiglet";
  version = "1.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-25yZQO0b8wSN7/U07VL/La+7ws12ELF7teyh321CeO8=";
  };

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "FIGlet in pure Python";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    mainProgram = "pyfiglet";
  };
}
