{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyfdt";
  version = "0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256:1w7lp421pssfgv901103521qigwb12i6sk68lqjllfgz0lh1qq31";
    pname = "pyfdt";
  };

  doCheck = false; # tests do not compile, see https://github.com/superna9999/pyfdt/issues/21
  format = "setuptools";
  pythonImportsCheck = [ "pyfdt" ];

  meta = {
    description = "Flattened device tree parser";
    homepage = "https://github.com/superna9999/pyfdt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ralismark ];
  };
}
