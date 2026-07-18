{
  lib,
  stdenv,
  fetchFromGitHub,
  libjack2,
  liblo,
  libsamplerate,
  libsndfile,
}:

stdenv.mkDerivation {
  pname = "dirt";
  version = "0-unstable-2025-03-30";

  src = fetchFromGitHub {
    owner = "tidalcycles";
    repo = "Dirt";
    rev = "4edc6192da3508fecb9f2e26bb0370cdeb6c4166";
    hash = "sha256-Zo1RzlfENnI2OmwPfO+O8u6Y1BToy911PYzdPQzK2sk=";
    fetchSubmodules = true;
  };

  postPatch = ''
    sed -i "s|./samples|$out/share/dirt/samples|" dirt.c
  '';

  buildInputs = [
    libsndfile
    libsamplerate
    liblo
    libjack2
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  # error: passing argument 4 of 'lo_server_thread_add_method' from incompatible pointer type
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  postInstall = ''
    mkdir -p $out/share/dirt/
    cp -r samples $out/share/dirt/
  '';

  meta = {
    description = "Unimpressive thingie for playing bits of samples with some level of accuracy";
    homepage = "https://github.com/tidalcycles/Dirt";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ anderspapitto ];
    platforms = lib.platforms.linux;
    mainProgram = "dirt";
  };
}
