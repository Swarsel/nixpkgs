{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  perl,
  popt,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librsync";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "librsync";
    repo = "librsync";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fiOby8tOhv0KJ+ZwAWfh/ynqHlYC9kNqKfxNl3IhzR8=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ]
  # Avoid cycle dependence between out and lib outputs on Darwin, by using bin
  # instead of lib
  ++ (if stdenv.hostPlatform.isDarwin then [ "bin" ] else [ "lib" ]);

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    perl
    zlib
    bzip2
    popt
  ];

  meta = {
    description = "Implementation of the rsync remote-delta algorithm";
    homepage = "https://librsync.sourceforge.net/";
    changelog = "https://github.com/librsync/librsync/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "rdiff";
  };
})
