{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "spark-parser";
  version = "1.9.0";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-3GbUjEJlxBM9tBqcX+nBxQKzsgFn3xWKDyNM0xcSz2Q=";
    pname = "spark_parser";
  };

  propagatedBuildInputs = [ click ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "test"
    "-v"
  ];

  meta = {
    description = "Early-Algorithm Context-free grammar Parser";
    homepage = "https://github.com/rocky/python-spark";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ raskin ];
    mainProgram = "spark-parser-coverage";
  };
}
