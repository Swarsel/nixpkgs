{
  lib,
  cdparanoia,
  cdrdao,
  cdrtools,
  dvdplusrwtools,
  flac,
  lame,
  libburn,
  libdvdcss,
  libdvdread,
  libmad,
  libsamplerate,
  libsndfile,
  libvorbis,
  mkKdeDerivation,
  normalize,
  pkg-config,
  qtwebengine,
  shared-mime-info,
  sox,
  vcdimager,
}:
mkKdeDerivation {
  pname = "k3b";

  # FIXME: Musicbrainz 2.x???, musepack
  extraBuildInputs = [
    qtwebengine
    libdvdread
    flac
    libmad
    libsndfile
    lame
    libvorbis
    libsamplerate
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        cdrdao
        cdrtools
        dvdplusrwtools
        libburn
        normalize
        sox
        vcdimager
        flac
      ]
    }"

    # FIXME: this should really be done with patchelf --add-rpath, but it breaks the binary somehow
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        cdparanoia
        libdvdcss
      ]
    }"
  ];

  meta.mainProgram = "k3b";
}
