{
  lib,
  stdenv,
  config,
  fetchzip,
  fontconfig,
  freetype,
  # update script dependencies
  gitUpdater,
  libx11,
  libxft,
  ncurses,
  nixosTests,
  pkg-config,
  writeText,
  conf ? config.st.conf or null,
  extraLibs ? config.st.extraLibs or [ ],
  patches ? config.st.patches or [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "st";
  version = "0.9.3";

  src = fetchzip {
    url = "https://dl.suckless.org/st/st-${finalAttrs.version}.tar.gz";
    hash = "sha256-Xr1JtaOMVgn+zsD39LFjP/0dkYkvaAXbEcYb3ptgYLA=";
  };

  outputs = [
    "out"
    "terminfo"
  ];

  postPatch =
    lib.optionalString (conf != null) "cp ${finalAttrs.configFile} config.def.h"
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace config.mk --replace "-lrt" ""
    '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    ncurses
    fontconfig
    freetype
  ];

  buildInputs = [
    libx11
    libxft
  ]
  ++ extraLibs;

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
  ];

  preInstall = ''
    export TERMINFO=$terminfo/share/terminfo
    mkdir -p $TERMINFO $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
  '';

  configFile = lib.optionalString (conf != null) (writeText "config.def.h" conf);
  installFlags = [ "PREFIX=$(out)" ];

  passthru = {
    tests.test = nixosTests.terminal-emulators.st;

    updateScript = gitUpdater {
      url = "git://git.suckless.org/st";
    };
  };

  meta = {
    description = "Simple Terminal for X from Suckless.org Community";
    homepage = "https://st.suckless.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qusic ];
    platforms = lib.platforms.unix;
    mainProgram = "st";
  };
})
