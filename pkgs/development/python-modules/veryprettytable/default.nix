{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  setuptools,
  termcolor,
}:

buildPythonPackage (finalAttrs: {
  pname = "veryprettytable";
  version = "0.8.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-bkym/Iisrl3hPzf/fYsTCwPJ+ttJR9Eriwybjr6LOcw=";
  };

  build-system = [ setuptools ];

  dependencies = [
    termcolor
    colorama
  ];

  pyproject = true;
  pythonImportsCheck = [ "veryprettytable" ];

  meta = {
    description = "Simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
    homepage = "https://github.com/smeggingsmegger/VeryPrettyTable";
    license = lib.licenses.free;
  };
})
