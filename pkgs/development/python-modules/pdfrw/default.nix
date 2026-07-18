{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pdfrw";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1x1yp63lg3jxpg9igw8lh5rc51q353ifsa1bailb4qb51r54kh0d";
  };

  # tests require the extra download of github.com/pmaupin/static_pdfs
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Pure Python library that reads and writes PDFs";
    homepage = "https://github.com/pmaupin/pdfrw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teto ];
  };
}
