{
  lib,
  fetchurl,
  buildPythonPackage,
  isPy3k,
  isPyPy,
}:

buildPythonPackage rec {
  pname = "mmpython";
  version = "0.4.10";

  src = fetchurl {
    url = "https://sourceforge.net/projects/mmpython/files/latest/download";
    sha256 = "1b7qfad3shgakj37gcj1b9h78j1hxlz6wp9k7h76pb4sq4bfyihy";
    name = "${pname}-${version}.tar.gz";
  };

  disabled = isPyPy || isPy3k;
  format = "setuptools";

  meta = {
    description = "Media Meta Data retrieval framework";
    homepage = "https://sourceforge.net/projects/mmpython/";
    license = lib.licenses.gpl2;
  };
}
