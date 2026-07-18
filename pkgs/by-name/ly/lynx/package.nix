{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  gzip,
  ncurses,
  nukeReferences,
  openssl,
  pkg-config,
  sslSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lynx";
  version = "2.9.3";

  src = fetchurl {
    hash = "sha256-F0t/KGamDzJHunX1x9uxCxJK7eShNZMS3hXzv+vSBQ8=";

    urls = [
      "https://invisible-island.net/archives/lynx/tarballs/lynx${finalAttrs.version}.tar.bz2"
      "https://invisible-mirror.net/archives/lynx/tarballs/lynx${finalAttrs.version}.tar.bz2"
    ];
  };

  nativeBuildInputs = [ nukeReferences ] ++ lib.optional sslSupport pkg-config;

  buildInputs = [
    ncurses
    gzip
  ]
  ++ lib.optional sslSupport openssl;

  configureFlags = [
    "--enable-default-colors"
    "--enable-widec"
    "--enable-ipv6"
  ]
  ++ lib.optional sslSupport "--with-ssl";

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  # cfg_defs.h captures lots of references to build-only dependencies, derived
  # from config.cache.
  postConfigure = ''
    make cfg_defs.h
    nuke-refs cfg_defs.h
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  meta = {
    description = "Text-mode web browser";
    homepage = "https://lynx.invisible-island.net/";
    changelog = "https://lynx.invisible-island.net/lynx${finalAttrs.version}/CHANGES.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lynx";
  };
})
