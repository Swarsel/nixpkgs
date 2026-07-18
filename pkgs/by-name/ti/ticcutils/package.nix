{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bzip2,
  frog,
  gitUpdater,
  icu,
  libtar,
  libtool,
  libxml2,
  pkg-config,
  timblserver,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ticcutils";
  version = "0.37";

  src = fetchFromGitHub {
    owner = "LanguageMachines";
    repo = "ticcutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jpwiRVpzALBUf4DxpRblEPLgXXOh2luHnTQg8nuQAwo=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libtool
    autoconf-archive
    libxml2
    icu
    # optional:
    zlib
    bzip2
    libtar
    # broken but optional: boost
  ];

  passthru = {
    tests = {
      /**
        Reverse dependencies. Does not respect overrides.
      */
      reverseDependencies = lib.recurseIntoAttrs {
        inherit frog timblserver;
      };
    };

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "This module contains useful functions for general use in the TiCC software stack and beyond";
    homepage = "https://github.com/LanguageMachines/ticcutils";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ roberth ];
    platforms = lib.platforms.all;
  };

})
