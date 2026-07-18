{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pysecuritas";
  version = "0.1.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W3DLZCXUH9y5NPipFEu6URmKN+oVXMgeDF1rfKtxRng=";
  };

  # Project doesn't ship tests with PyPI releases
  # https://github.com/Cebeerre/pysecuritas/issues/13
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    xmltodict
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysecuritas" ];

  meta = {
    description = "Python client to access Securitas Direct Mobile API";
    homepage = "https://github.com/Cebeerre/pysecuritas";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pysecuritas";
  };
}
