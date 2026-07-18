{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  # only build for dovecot 2.3 as the package is part of dovecot since 2.4
  dovecot_2_3,
  pkg-config,
  xapian,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dovecot-fts-flatcurve";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "slusarz";
    repo = "dovecot-fts-flatcurve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-96sR/pl0G0sSjh/YrXdgVgASJPhrL32xHCbBGrDxzoU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    xapian
  ];

  configureFlags = [
    "--with-dovecot=${lib.getLib dovecot_2_3}/lib/dovecot"
    "--with-moduledir=${placeholder "out"}/lib/dovecot/modules"
  ];

  meta = {
    description = "Dovecot FTS Flatcurve plugin (Xapian)";
    homepage = "https://slusarz.github.io/dovecot-fts-flatcurve/";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ euxane ];
    platforms = lib.platforms.unix;
  };
})
