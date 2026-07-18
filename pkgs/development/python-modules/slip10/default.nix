{
  lib,
  base58,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "slip10";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0kjT3ybxI/CEdDOcRfDyZCVPdK6aVlcjSh1euR8MTVQ=";
  };

  propagatedBuildInputs = [
    base58
    cryptography
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "slip10" ];

  meta = {
    description = "Minimalistic implementation of SLIP109";
    homepage = "https://github.com/trezor/python-slip10";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      prusnak
    ];
  };
}
