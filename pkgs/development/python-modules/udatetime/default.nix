{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "udatetime";
  version = "0.0.17";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sQvFVwaZpDinLitaZOdr2MKO4779FvIJOHpVB/oLgwE=";
  };

  # tests not included on pypi
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "udatetime" ];

  meta = {
    description = "Fast RFC3339 compliant Python date-time library";
    homepage = "https://github.com/freach/udatetime";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "bench_udatetime.py";
  };
}
