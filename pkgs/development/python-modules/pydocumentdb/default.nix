{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  six,
}:

buildPythonPackage rec {
  pname = "pydocumentdb";
  version = "2.3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1e6f072ae516fc061c9442f8ca470463b53dc626f0f6a86ff3a803293f4b50dd";
  };

  propagatedBuildInputs = [
    six
    requests
  ];

  # https://github.com/Azure/azure-cosmos-python/issues/183
  preBuild = ''
    touch changelog.md
  '';

  # requires an active Azure Cosmos service
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Azure Cosmos DB API";
    homepage = "https://github.com/Azure/azure-cosmos-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
