{
  lib,
  stdenv,
  fetchurl,
  argp-standalone,
  curl,
  glib,
  gmp,
  guile,
  jansson,
  libidn,
  libtool,
  libunwind,
  loudmouth,
  ncurses,
  pkg-config,
  readline,
  texinfo,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "freetalk";
  version = "4.2";

  src = fetchurl {
    url = "mirror://gnu/freetalk/freetalk-${finalAttrs.version}.tar.gz";
    hash = "sha256-u1tPKacGry+JGYeAIgDia3N7zs5EM4FyQZdV8e7htYA=";
  };

  nativeBuildInputs = [
    pkg-config
    texinfo
  ];

  buildInputs = [
    guile
    glib
    loudmouth
    gmp
    libidn
    readline
    libtool
    libunwind
    ncurses
    curl
    jansson
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    argp-standalone
  ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-largp";

  meta = {
    description = "Console XMPP client";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "freetalk";
    downloadPage = "https://www.gnu.org/software/freetalk/";
  };
})
