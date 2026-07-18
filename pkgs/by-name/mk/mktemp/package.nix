{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  groff,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mktemp";
  version = "1.7";

  src = fetchurl {
    url = "ftp://ftp.mktemp.org/pub/mktemp/mktemp-${finalAttrs.version}.tar.gz";
    sha256 = "0x969152znxxjbj7387xb38waslr4yv6bnj5jmhb4rpqxphvk54f";
  };

  patches = [
    # Pull upstream fix for parallel install failures.
    (fetchpatch {
      hash = "sha256-cJ/0pFj8tOkByUwhlMwLNSQgTHyAU8svEkjKWWwsNmY=";
      name = "parallel-install.patch";
      url = "https://www.mktemp.org/repos/mktemp/raw-rev/eb87d96ce8b7";
    })
  ];

  # Don't use "install -s"
  postPatch = ''
    substituteInPlace Makefile.in --replace " 0555 -s " " 0555 "
  '';

  # Have `configure' avoid `/usr/bin/nroff' in non-chroot builds.
  env.NROFF = "${groff}/bin/nroff";
  enableParallelBuilding = true;

  meta = {
    description = "Simple tool to make temporary file handling in shells scripts safe and simple";
    homepage = "https://www.mktemp.org";
    license = lib.licenses.isc;
    platforms = lib.platforms.unix;
    mainProgram = "mktemp";
  };
})
