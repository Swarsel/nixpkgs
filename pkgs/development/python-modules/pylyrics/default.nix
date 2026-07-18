{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylyrics";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-xfNujvDtO0h6kkLONMGfloTkGKW7/9XTZ9wdFgS0zQs=";
    extension = "zip";
    pname = "PyLyrics";
  };

  propagatedBuildInputs = [
    beautifulsoup4
    requests
  ];

  # tries to connect to lyrics.wikia.com
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "PyLyrics" ];

  meta = {
    description = "Pythonic Implementation of lyrics.wikia.com for getting lyrics of songs";
    homepage = "https://github.com/geekpradd/PyLyrics";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
