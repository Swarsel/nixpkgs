{
  lib,
  stdenv,
  config,
  fetchzip,
  # update script dependencies
  gitUpdater,
  libx11,
  libxcrypt,
  libxext,
  libxrandr,
  writeText,
  xorgproto,
  conf ? config.slock.conf or null,
  extraLibs ? config.slock.extraLibs or [ ],
  patches ? config.slock.patches or [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "slock";
  version = "1.6";

  src = fetchzip {
    url = "https://dl.suckless.org/tools/slock-${finalAttrs.version}.tar.gz";
    hash = "sha256-EIzLEIGd631dwYoAe7PXNoki9iaQPP3Y0S5H80aY+l8=";
  };

  postPatch = "sed -i '/chmod u+s/d' Makefile";

  buildInputs = [
    xorgproto
    libx11
    libxext
    libxrandr
    libxcrypt
  ]
  ++ extraLibs;

  makeFlags = [ "CC:=$(CC)" ];

  preBuild = lib.optionalString (conf != null) ''
    cp ${writeText "config.def.h" conf} config.def.h
  '';

  installFlags = [ "PREFIX=$(out)" ];

  passthru.updateScript = gitUpdater {
    url = "git://git.suckless.org/slock";
  };

  meta = {
    description = "Simple X display locker";

    longDescription = ''
      Simple X display locker. This is the simplest X screen locker.
    '';

    homepage = "https://tools.suckless.org/slock";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      qusic
    ];

    platforms = lib.platforms.linux;
    mainProgram = "slock";
  };
})
