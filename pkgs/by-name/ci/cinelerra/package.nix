{
  lib,
  stdenv,
  fetchFromGitHub,
  a52dec,
  alsa-lib,
  autoconf,
  automake,
  faac,
  faad2,
  fftw,
  file,
  fontconfig,
  freetype,
  gettext,
  intltool,
  lame,
  libavc1394,
  libdv,
  libiec61883,
  libjpeg,
  libogg,
  libpng,
  libraw1394,
  libsndfile,
  libtheora,
  libtiff,
  libtool,
  libuuid,
  libvorbis,
  libx11,
  libxext,
  libxft,
  libxi,
  libxv,
  libxxf86vm,
  mjpegtools,
  nasm,
  openexr,
  perl,
  pkg-config,
  x264,
  xorgproto,
}:

stdenv.mkDerivation {
  pname = "cinelerra-cv";
  version = "2.3-unstable-2025-01-25";

  src = fetchFromGitHub {
    owner = "cinelerra-cv-team";
    repo = "cinelerra-cv";
    rev = "fb6eb391fe907d0f3b48b90f87e7a416408054f3";
    hash = "sha256-mu6yY44IlbmoBn1DUARQm5p16y6WShPc3gVML8+59xc=";
  };

  nativeBuildInputs = [
    automake
    autoconf
    libtool
    pkg-config
    file
    intltool
  ];

  buildInputs = [
    faad2
    faac
    a52dec
    alsa-lib
    fftw
    lame
    libavc1394
    libiec61883
    libraw1394
    libsndfile
    libvorbis
    libogg
    libjpeg
    libtiff
    freetype
    mjpegtools
    x264
    gettext
    openexr
    libxext
    libxxf86vm
    libxv
    libxi
    libx11
    libxft
    xorgproto
    libtheora
    libpng
    libdv
    libuuid
    nasm
    perl
    fontconfig
  ];

  preConfigure = ''
    find -type f -print0 | xargs --null sed -e "s@/usr/bin/perl@${perl}/bin/perl@" -i
    ./autogen.sh
    sed -i -e "s@/usr/bin/file@${file}/bin/file@" ./configure
  '';

  ## fix bug with parallel building
  preBuild = ''
    make -C cinelerra versioninfo.h
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Professional video editing and compositing environment (community version)";
    homepage = "http://cinelerra-cv.wikidot.com/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    # https://github.com/cinelerra-cv-team/cinelerra-cv/issues/3
    platforms = [ "x86_64-linux" ];
    mainProgram = "cinelerracv";
  };
}
