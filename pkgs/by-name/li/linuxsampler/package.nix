{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  asio,
  autoconf,
  automake,
  bison,
  libgig,
  libjack2,
  libsndfile,
  libtool,
  lv2,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "linuxsampler";
  version = "2.3.1";

  src = fetchurl {
    url = "https://download.linuxsampler.org/packages/linuxsampler-${finalAttrs.version}.tar.bz2";
    hash = "sha256-T7quk5N5JBiPqIziQd0vaCr8tLDbwS6otz6egY01OTE=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    libtool
    pkg-config
    which
  ];

  buildInputs = [
    alsa-lib
    asio
    libjack2
    libgig
    libsndfile
    lv2
  ];

  env.HAVE_UNIX98 = "1";

  preConfigure = ''
    make -f Makefile.svn
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Sampler backend";

    longDescription = ''
      Includes sampler engine, audio and MIDI drivers, network layer
      (LSCP) API and native C++ API.

      LinuxSampler is licensed under the GNU GPL with the exception
      that USAGE of the source code, libraries and applications FOR
      COMMERCIAL HARDWARE OR SOFTWARE PRODUCTS IS NOT ALLOWED without
      prior written permission by the LinuxSampler authors. If you
      have questions on the subject, that are not yet covered by the
      FAQ, please contact us.
    '';

    homepage = "http://www.linuxsampler.org";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
