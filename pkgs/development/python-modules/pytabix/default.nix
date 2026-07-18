{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  zlib,
}:

buildPythonPackage rec {
  pname = "pytabix";
  version = "0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ldp5r4ggskji6qx4bp2qxy2vrvb3fam03ksn0gq2hdxgrlg2x07";
  };

  buildInputs = [ zlib ];
  doCheck = !isPy3k;

  preCheck = ''
    substituteInPlace test/test.py \
      --replace 'test_remote_file' 'dont_test_remote_file'
  '';

  format = "setuptools";
  pythonImportsCheck = [ "tabix" ];

  meta = {
    description = "Python interface for tabix";
    homepage = "https://github.com/slowkow/pytabix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ris ];
  };
}
