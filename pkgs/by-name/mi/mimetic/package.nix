{
  lib,
  stdenv,
  fetchurl,
  cutee,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mimetic";
  version = "0.9.8";

  src = fetchurl {
    url = "https://www.codesink.org/download/mimetic-${finalAttrs.version}.tar.gz";
    sha256 = "003715lvj4nx23arn1s9ss6hgc2yblkwfy5h94li6pjz2a6xc1rs";
  };

  patches = [
    # Fix build with gcc11
    (fetchpatch {
      sha256 = "sha256-1JW9zPg67BgNsdIjK/jp9j7QMg50eRMz5FsDsbbzBlI=";
      url = "https://github.com/tat/mimetic/commit/bf84940f9021950c80846e6b1a5f8b0b55991b00.patch";
    })
  ]
  ++ lib.optional stdenv.hostPlatform.isAarch64 ./narrowing.patch;

  buildInputs = [ cutee ];

  meta = {
    description = "MIME handling library";
    homepage = "https://www.codesink.org/mimetic_mime_library.html";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
