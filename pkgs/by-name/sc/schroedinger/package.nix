{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  gtk-doc,
  orc,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "schroedinger";
  version = "1.0.11";

  src = fetchurl {
    url = "https://download.videolan.org/contrib/schroedinger-${finalAttrs.version}.tar.gz";
    sha256 = "04prr667l4sn4zx256v1z36a0nnkxfdqyln48rbwlamr6l3jlmqy";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    (fetchpatch {
      sha256 = "0cc8ymvgjgwy7ghca2dd8m8pxpinf27s2i8krf2m3fzv2ckq09v3";
      url = "https://raw.githubusercontent.com/macports/macports-ports/master/multimedia/schroedinger/files/patch-testsuite-Makefile.am.diff";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    gtk-doc
  ];

  buildInputs = [ orc ];
  doCheck = (!stdenv.hostPlatform.isDarwin);
  patchFlags = [ "-p0" ];

  meta = {
    description = "Implementation of the Dirac video codec in ANSI C";
    homepage = "https://sourceforge.net/projects/schrodinger/";

    license = [
      lib.licenses.mpl11
      lib.licenses.lgpl2
      lib.licenses.mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
