{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  mutagen,
  prettytable,
  pycrypto,
  pydub,
  requests,
}:

buildPythonPackage rec {
  pname = "aigpy";
  version = "2022.7.8.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1kQced6YdC/wvegqFVhZfej4+4aemGXvKysKjejP13w=";
  };

  propagatedBuildInputs = [
    mutagen
    requests
    colorama
    prettytable
    pycrypto
    pydub
  ];

  format = "setuptools";

  meta = {
    description = "Python library with miscellaneous tools";
    homepage = "https://github.com/AIGMix/AIGPY";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.misterio77 ];
    platforms = lib.platforms.all;
  };
}
