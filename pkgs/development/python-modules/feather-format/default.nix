{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyarrow,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "feather-format";
  version = "0.4.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-RfZ+N0XTlNTxYMptY2u/1Pi2jQEZncFkm25IfT6HiQM=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ pyarrow ];
  pyproject = true;
  pythonImportsCheck = [ "feather" ];

  meta = {
    description = "Simple wrapper library to the Apache Arrow-based Feather File Format";
    homepage = "https://github.com/wesm/feather";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
