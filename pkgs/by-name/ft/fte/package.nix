{
  lib,
  stdenv,
  fetchurl,
  gpm,
  libx11,
  libxpm,
  ncurses,
  perl,
  slang,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fte";
  version = "0.50.02";

  src = [
    finalAttrs.ftesrc
    finalAttrs.ftecommon
  ];

  nativeBuildInputs = [ unzip ];

  buildInputs = [
    perl
    libx11
    libxpm
    gpm
    ncurses
    slang
  ];

  # not setting it cause fte to not find xfte
  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  env.NIX_CFLAGS_COMPILE = "-DHAVE_STRLCAT -DHAVE_STRLCPY";
  enableParallelBuilding = true;

  ftecommon = fetchurl {
    hash = "sha256-WEEVeLMZWHZfQtK/Kbeu3Z+RaVXCwZyWkJocA+Akavc=";
    url = "mirror://sourceforge/fte/fte-20110708-common.zip";
  };

  ftesrc = fetchurl {
    hash = "sha256-1jEcVC0/DyiQpUpmHDtnIo4nuJS0Fk6frynwFPJUSZ4=";
    url = "mirror://sourceforge/fte/fte-20110708-src.zip";
  };

  hardeningDisable = [ "all" ];
  installFlags = [ "INSTALL_NONROOT=1" ];

  meta = {
    description = "Free text editor for developers";
    homepage = "https://fte.sourceforge.net/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.all;
  };
})
