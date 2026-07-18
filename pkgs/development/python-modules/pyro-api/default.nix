{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyro-api";
  version = "0.1.2";

  src = fetchPypi {
    inherit version pname;
    sha256 = "a1b900d9580aa1c2fab3b123ab7ff33413744da7c5f440bd4aadc4d40d14d920";
  };

  # tests require pyro-ppl which depends on this package
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyroapi" ];

  meta = {
    description = "Generic API for dispatch to Pyro backends";
    homepage = "http://pyro.ai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ georgewhewell ];
  };
}
