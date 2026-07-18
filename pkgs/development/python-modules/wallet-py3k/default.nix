{
  lib,
  buildPythonPackage,
  fetchPypi,
  openssl,
  replaceVars,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "wallet-py3k";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kyHSh8qHbzK6gFLGnL6dUJ/GLJHTNC86jjXa/APqIzI=";
  };

  patches = [
    (replaceVars ./openssl-path.patch {
      openssl = lib.getExe openssl;
    })
  ];

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "wallet" ];

  meta = {
    description = "Passbook file generator";
    homepage = "https://pypi.org/project/wallet-py3k";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
