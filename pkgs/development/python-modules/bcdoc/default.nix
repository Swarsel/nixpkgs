{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "bcdoc";
  version = "0.16.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-9WjBguBog77PcZbyJwUkNc/9RWBHAMgjYsp300J7YgI=";
  };

  buildInputs = [
    docutils
    six
  ];

  # Tests fail due to nix file timestamp normalization.
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bcdoc" ];

  meta = {
    description = "ReST document generation tools for botocore";
    homepage = "https://github.com/boto/bcdoc";
    license = lib.licenses.asl20;
  };
})
