{
  lib,
  aesedb,
  aiosmb,
  aiowinreg,
  buildPythonPackage,
  fetchPypi,
  minidump,
  minikerberos,
  msldap,
  setuptools,
  winsspi,
}:

buildPythonPackage rec {
  pname = "pypykatz";
  version = "0.6.13";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+T1E/Dk4OcXa8vBhspuB/8V23TORsXXetZpylW25SJM=";
  };

  # Project doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aesedb
    aiosmb
    aiowinreg
    minikerberos
    msldap
    winsspi
    minidump
  ];

  pyproject = true;
  pythonImportsCheck = [ "pypykatz" ];

  meta = {
    description = "Mimikatz implementation in Python";
    homepage = "https://github.com/skelsec/pypykatz";
    changelog = "https://github.com/skelsec/pypykatz/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pypykatz";
  };
}
