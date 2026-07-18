{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  impacket,
  lxml,
  poetry-core,
  pyasn1,
}:

buildPythonPackage rec {
  pname = "dploot";
  version = "3.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-P2rPkBE60Ha+m1nqQULQ3k2RDUro+Zp0TUfPAQNS06g=";
  };

  # No tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    impacket
    cryptography
    pyasn1
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "dploot" ];

  pythonRelaxDeps = [
    "cryptography"
    "lxml"
    "pyasn1"
  ];

  meta = {
    description = "DPAPI looting remotely in Python";
    homepage = "https://github.com/zblurx/dploot";
    changelog = "https://github.com/zblurx/dploot/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vncsb ];
    mainProgram = "dploot";
  };
}
