{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  libsndfile,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libinstpatch";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "swami";
    repo = "libinstpatch";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-y3rmCQk3homgnWT/i/qhKJ6gRO8opMFnaC0T8d5UN48=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  propagatedBuildInputs = [
    glib
    libsndfile
  ]; # Both are needed for includes.

  cmakeFlags = [
    "-DLIB_SUFFIX=" # Install in $out/lib.
  ];

  meta = {
    description = "MIDI instrument patch files support library";
    homepage = "http://www.swamiproject.org/";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
