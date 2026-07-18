{
  lib,
  buildPythonPackage,
  click,
  deezer-py,
  fetchPypi,
  mutagen,
  pycryptodomex,
  requests,
  spotipy,
}:

buildPythonPackage rec {
  pname = "deemix";
  version = "3.6.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xEahzA1PIrGPfnnOcuXQLVQpSVOUFk6/0v9ViLgWCwk=";
  };

  propagatedBuildInputs = [
    spotipy
    click
    pycryptodomex
    mutagen
    requests
    deezer-py
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "deezer" ];

  meta = {
    description = "Deezer downloader built from the ashes of Deezloader Remix";
    homepage = "https://gitlab.com/RemixDev/deemix-py";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ natto1784 ];
    mainProgram = "deemix";
  };
}
