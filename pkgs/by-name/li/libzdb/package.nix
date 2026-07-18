{
  lib,
  stdenv,
  autoconf,
  automake,
  fetchFromBitbucket,
  libtool,
  nix-update-script,
  re2c,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzdb";
  version = "3.5.0";

  src = fetchFromBitbucket {
    owner = "tildeslash";
    repo = "libzdb";
    tag = "release-${lib.replaceString "." "-" finalAttrs.version}";
    hash = "sha256-fZSTu/BGIFsbEHSB/+2SObb9myg+Iyc1IDxnpv/EEhU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    re2c
  ];

  buildInputs = [ sqlite ];
  preConfigure = "sh ./bootstrap";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "release-(\\d+)-(\\d+)-(\\d+)"
    ];
  };

  meta = {
    description = "Small, easy to use Open Source Database Connection Pool Library";
    homepage = "http://www.tildeslash.com/libzdb/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ maevii ];
    platforms = lib.platforms.linux;
    downloadPage = "https://bitbucket.org/tildeslash/libzdb/";
  };
})
