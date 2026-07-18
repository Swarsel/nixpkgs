{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pypemicro";
  version = "0.1.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KE085u9yIPsuEr41GNWwHFm6KAHggvqGqP9ChGRoLE0=";
  };

  # tests are neither pytest nor unittest compatible and require a device
  # connected via USB
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pypemicro" ];

  meta = {
    description = "Python interface for PEMicro debug probes";
    homepage = "https://github.com/NXPmicro/pypemicro";

    license = with lib.licenses; [
      bsd3
      unfree
    ]; # it includes shared libraries for which no license is available (https://github.com/NXPmicro/pypemicro/issues/10)

    maintainers = [
    ];
  };
}
