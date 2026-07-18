{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fetchpatch,
  lua,
  pkg-config,
  ragel,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpick";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "thezbyg";
    repo = "gpick";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z17YpdAAr2wvDFkrAosyCN6Y/wsFVkiB9IDvXuP9lYo=";
  };

  patches = [
    # gpick/cmake/Version.cmake
    ./dot-version.patch

    (fetchpatch {
      hash = "sha256-qYspUctvlPMEK/c2hMUxYc5EYdG//CBcN2PluTtXiFc=";
      url = "https://patch-diff.githubusercontent.com/raw/thezbyg/gpick/pull/227.patch";
    })

    (fetchpatch {
      hash = "sha256-DnRU90VPyFhLYTk4GPJoiVYadJgtYgjMS4MLgmpYLP0=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/gpick/-/raw/0.3-2/buildfix.diff";
    })
  ];

  # https://github.com/thezbyg/gpick/pull/227
  postPatch = ''
    sed '1i#include <boost/version.hpp>' -i source/dynv/Types.cpp
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    boost
    ragel
    lua
  ];

  meta = {
    description = "Advanced color picker written in C++ using GTK+ toolkit";
    homepage = "https://www.gpick.org/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vanilla ];
    platforms = lib.platforms.linux;
    mainProgram = "gpick";
  };
})
