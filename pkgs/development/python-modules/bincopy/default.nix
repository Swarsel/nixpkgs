{
  lib,
  argparse-addons,
  buildPythonPackage,
  fetchPypi,
  humanfriendly,
  pyelftools,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bincopy";
  version = "20.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-6UpJi5pKvnZwPDdyqtRm8VY7T8mAnaeWXxG8dwlAk7k=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    argparse-addons
    humanfriendly
    pyelftools
  ];

  pyproject = true;
  pythonImportsCheck = [ "bincopy" ];

  meta = {
    description = "Mangling of various file formats that conveys binary information (Motorola S-Record, Intel HEX, TI-TXT, ELF and binary files)";
    homepage = "https://github.com/eerimoq/bincopy";
    license = lib.licenses.mit;

    maintainers = [
    ];

    mainProgram = "bincopy";
  };
})
