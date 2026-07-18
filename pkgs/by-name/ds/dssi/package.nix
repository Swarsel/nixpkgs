{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoconf,
  automake,
  ladspa-header,
  libice,
  libjack2,
  liblo,
  libsamplerate,
  libsm,
  libsndfile,
  libtool,
  libx11,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dssi";
  version = "1.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/project/dssi/dssi/${finalAttrs.version}/dssi-${finalAttrs.version}.tar.gz";
    sha256 = "0kl1hzhb7cykzkrqcqgq1dk4xcgrcxv0jja251aq4z4l783jpj7j";
  };

  patches = [
    ./dssi-liblo.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    ladspa-header
    libjack2
    liblo
    alsa-lib
    libx11
    libsndfile
    libsm
    libsamplerate
    libtool
    xorgproto
    libice
  ];

  meta = {
    description = "Plugin SDK for virtual instruments";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.linux;
    downloadPage = "https://sourceforge.net/projects/dssi/files/dssi/";
  };
})
