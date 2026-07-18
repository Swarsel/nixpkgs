{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse3,
  pcre,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "rewritefs";
  version = "0-unstable-2021-10-03";

  src = fetchFromGitHub {
    owner = "sloonz";
    repo = "rewritefs";
    rev = "3a56de8b5a2d44968b8bc3885c7d661d46367306";
    sha256 = "1w2rik0lhqm3wr68x51zs45gqfx79l7fi4p0sqznlfq7sz5s8xxn";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fuse3
    pcre
  ];

  preConfigure = "substituteInPlace Makefile --replace /usr/local $out";

  prePatch = ''
    # do not set sticky bit in nix store
    substituteInPlace Makefile --replace 6755 0755
  '';

  meta = {
    description = "FUSE filesystem intended to be used like Apache mod_rewrite";
    homepage = "https://github.com/sloonz/rewritefs";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.linux;
  };
}
