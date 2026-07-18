{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  isort,
  pycodestyle,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "avro-python3";
  version = "1.10.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-O2PyTmsENow+Sm+SP0hL4CMNghqtZaw2EI7b/ynpqqs=";
  };

  buildInputs = [
    pycodestyle
    isort
  ];

  doCheck = false; # No such file or directory: './run_tests.py
  build-system = [ setuptools ];
  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Serialization and RPC framework";
    homepage = "https://pypi.org/project/avro-python3/";
    license = lib.licenses.asl20;

    maintainers = [
      lib.maintainers.shlevy
      lib.maintainers.timma
    ];

    mainProgram = "avro";
  };
})
