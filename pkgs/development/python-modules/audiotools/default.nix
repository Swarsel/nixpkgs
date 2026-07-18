{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lame,
  libcdio,
  libcdio-paranoia,
  libmpg123,
  libopus,
  libvorbis,
  opusfile,
  pkg-config,
  setuptools,
  twolame,
}:

buildPythonPackage {
  pname = "audiotools";
  version = "3.1.1-unstable-2020-07-29";

  # the python code contains #variant formats, PY_SSIZE_T_CLEAN must be defined
  # before including Python.h for 3.10 or newer
  # the last released version does not contain the required fix for python 3.10
  src = fetchFromGitHub {
    owner = "tuffy";
    repo = "python-audio-tools";
    rev = "de55488dc982e3f6375cde2d0c2ea6aad1b1c31c";
    hash = "sha256-iRakeV4Sg4oU0JtiA0O3jnmLJt99d89Hg6v9onUaSnw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libmpg123 # MP2/MP3 decoding
    lame # MP3 encoding
    twolame # MP2 encoding
    opusfile # opus decoding
    libopus # opus encoding
    libvorbis # ogg encoding/decoding
    libcdio # CD reading
    libcdio-paranoia # CD reading
  ];

  preConfigure = ''
    # need to change probe to yes because mp3lame is not reported in pkg-config
    substituteInPlace setup.cfg \
      --replace-fail "mp3lame:           probe" "mp3lame:           yes"
  '';

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Utilities and Python modules for handling audio";
    homepage = "https://audiotools.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
