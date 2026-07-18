{
  lib,
  stdenv,
  fetchurl,
  libressl,
  ncurses,
  patches ? [ ], # allow users to easily override config.def.h
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "sacc";
  version = "1.07";

  src = fetchurl {
    url = "ftp://bitreich.org/releases/sacc/sacc-${finalAttrs.version}.tar.gz";
    hash = "sha256-LdEeZH+JWb7iEEzikAXaxG0N5GMPxjgTId4THLgdU2w=";
  };

  postPatch = ''
    substituteInPlace config.mk \
      --replace curses ncurses \
      --replace "/usr/local" "$out"
  '';

  buildInputs = [
    ncurses
    libressl
  ];

  makeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "OSCFLAGS=-D_DARWIN_C_SOURCE"
  ];

  meta = {
    description = "Terminal gopher client";
    homepage = "gopher://bitreich.org/1/scm/sacc";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
    mainProgram = "sacc";
  };
})
