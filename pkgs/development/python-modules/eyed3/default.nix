{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  filetype,
  isPyPy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eyed3";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "nicfit";
    repo = "eyeD3";
    tag = "v${version}";
    hash = "sha256-Brtxi0B52kvSU12va5X+KNtNV9cyK2TUefyZYZI87JQ=";
  };

  # requires special test data:
  # https://github.com/nicfit/eyeD3/blob/103198e265e3279384f35304e8218be6717c2976/Makefile#L97
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    deprecation
    filetype
  ];

  disabled = isPyPy;
  pyproject = true;

  meta = {
    description = "Python module and command line program for processing ID3 tags";

    longDescription = ''
      eyeD3 is a Python module and command line program for processing ID3
      tags. Information about mp3 files (i.e bit rate, sample frequency, play
      time, etc.) is also provided. The formats supported are ID3 v1.0/v1.1
      and v2.3/v2.4.
    '';

    homepage = "https://eyed3.nicfit.net/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "eyeD3";
    downloadPage = "https://github.com/nicfit/eyeD3";
  };
}
