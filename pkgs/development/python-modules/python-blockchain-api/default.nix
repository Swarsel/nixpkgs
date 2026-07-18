{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-blockchain-api";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JC/FWkSq+Rc/XX39RQgLBnlncuRRumFNArODNJDzAHw=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pyblockchain" ];

  meta = {
    description = "Python API for interacting with blockchain.info";
    homepage = "https://github.com/nkgilley/python-blockchain-api";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
