{
  lib,
  stdenv,
  fetchurl,
  ctags,
  libretls,
  ncurses,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "catgirl";
  version = "2.2a";

  src = fetchurl {
    url = "https://git.causal.agency/catgirl/snapshot/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-xtdgqu4TTgUlht73qRA1Q/coH95lMfvLQQhkcHlCl8I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ctags
    pkg-config
  ];

  buildInputs = [
    libretls
    openssl
    ncurses
  ];

  # catgirl's configure script uses pkg-config --variable exec_prefix openssl
  # to discover the install location of the openssl(1) utility. exec_prefix
  # is the "out" output of openssl in our case (where the libraries are
  # installed), so we need to fix this up.
  postConfigure = ''
    substituteInPlace config.mk --replace-fail \
      "$($PKG_CONFIG --variable exec_prefix openssl)" \
      "${lib.getBin openssl}"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "TLS-only terminal IRC client";
    homepage = "https://git.causal.agency/catgirl/about/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xfnw ];
    platforms = lib.platforms.unix;
    mainProgram = "catgirl";
  };
})
