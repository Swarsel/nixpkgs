{
  lib,
  buildPythonPackage,
  decorator,
  fetchPypi,
  isPyPy,
  ply,
  six,
}:

buildPythonPackage rec {
  pname = "jsonpath-rw";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "05c471281c45ae113f6103d1268ec7a4831a2e96aa80de45edc89b11fac4fbec";
  };

  propagatedBuildInputs = [
    ply
    six
    decorator
  ];

  # ImportError: No module named tests
  doCheck = false;
  disabled = isPyPy;
  format = "setuptools";

  meta = {
    description = "Robust and significantly extended implementation of JSONPath for Python, with a clear AST for metaprogramming";
    homepage = "https://github.com/kennknowles/python-jsonpath-rw";
    license = lib.licenses.asl20;
    mainProgram = "jsonpath.py";
  };
}
