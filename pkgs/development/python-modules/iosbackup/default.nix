{
  lib,
  buildPythonPackage,
  fetchPypi,
  nskeyedunarchiver,
  pycrypto,
  setuptools,
}:

buildPythonPackage rec {
  pname = "iosbackup";
  version = "0.9.925";

  src = fetchPypi {
    inherit version;
    hash = "sha256-M1Rakknls/qq3x7ngv5r3823D64N77oazuM2pl+T0co=";
    pname = "iOSbackup";
  };

  build-system = [ setuptools ];

  dependencies = [
    pycrypto
    nskeyedunarchiver
  ];

  pyproject = true;
  pythonImportsCheck = [ "iOSbackup" ];

  meta = {
    description = "Reads and extracts files from password-encrypted iOS backups";
    homepage = "https://github.com/avibrazil/iOSbackup";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ PapayaJackal ];
  };
}
