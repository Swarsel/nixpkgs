{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  librsync,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "btar";
  version = "1.1.1";

  src = fetchurl {
    url = "https://vicerveza.homeunix.net/~viric/soft/btar/btar-${finalAttrs.version}.tar.gz";
    sha256 = "0miklk4bqblpyzh1bni4x6lqn88fa8fjn15x1k1n8bxkx60nlymd";
  };

  patches = [
    (fetchpatch {
      sha256 = "1awqny9489vsfffav19s73xxg26m7zrhvsgf1wxb8c2izazwr785";
      url = "https://build.opensuse.org/public/source/openSUSE:Factory/btar/btar-librsync.patch?rev=2";
    })
  ];

  buildInputs = [ librsync ];
  makeFlags = [ "PREFIX=$(out)" ];
  # Workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: listindex.o:/build/btar-1.1.1/loadindex.h:12: multiple definition of
  #     `ptr'; main.o:/build/btar-1.1.1/loadindex.h:12: first defined here
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  meta = {
    description = "Tar-compatible block-based archiver";
    homepage = "https://briantracy.xyz/writing/btar.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "btar";
  };
})
