{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  audiofile,
  fetchpatch,
  libjack2,
  liblo,
  liboil,
  libsamplerate,
  libsndfile,
  lilv,
  lv2,
  ncurses,
  pkg-config,
  readline,
}:

# TODO: fix python. See configure log.

stdenv.mkDerivation (finalAttrs: {
  pname = "ecasound";
  version = "2.9.3";

  src = fetchurl {
    url = "https://ecasound.seul.org/download/ecasound-${finalAttrs.version}.tar.gz";
    sha256 = "1m7njfjdb7sqf0lhgc4swihgdr4snkg8v02wcly08wb5ar2fr2s6";
  };

  patches = [
    # Pull patch pending upstream inclusion for ncurses-6.3:
    #  https://sourceforge.net/p/ecasound/bugs/54/
    (fetchpatch {
      name = "ncursdes-6.3.patch";
      sha256 = "1x1gsjzd43lh19mhpmwrbq269h56s8bxgyv0yfi5yf0sqjf9vaq0";
      url = "https://sourceforge.net/p/ecasound/bugs/54/attachment/0001-ecasignalview.cpp-always-use-s-style-format-for-prin.patch";
    })
  ];

  postPatch = ''
    sed -i -e '
      s@^#include <readline.h>@#include <readline/readline.h>@
      s@^#include <history.h>@#include <readline/history.h>@
      ' ecasound/eca-curses.cpp
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    audiofile
    libjack2
    liblo
    liboil
    libsamplerate
    libsndfile
    lilv
    lv2
    ncurses
    readline
  ];

  configureFlags = [
    "--enable-liblilv"
  ];

  env.CXXFLAGS = "-std=c++11";

  meta = {
    description = "Software package designed for multitrack audio processing";
    homepage = "http://nosignal.fi/ecasound/";

    license = with lib.licenses; [
      gpl2
      lgpl21
    ];
  };
})
