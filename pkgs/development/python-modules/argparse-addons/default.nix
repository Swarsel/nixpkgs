{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "argparse-addons";
  version = "0.12.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-YyKg3NcGiH52MI0jE21bhtoOq3WigtxklnAdEhC0YK8=";
    pname = "argparse_addons";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "argparse_addons" ];

  meta = {
    description = "Additional Python argparse types and actions";
    homepage = "https://github.com/eerimoq/argparse_addons";
    license = lib.licenses.mit;

    maintainers = [
    ];
  };
})
