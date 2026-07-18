{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
}:

stdenv.mkDerivation {
  pname = "enhanced-ctorrent-dhn";
  version = "3.3.2";

  src = fetchurl {
    url = "http://www.rahul.net/dholmes/ctorrent/ctorrent-dnh3.3.2.tar.gz";
    sha256 = "0qs8waqwllk56i3yy3zhncy7nsnhmf09a494p5siz4vm2k4ncwy8";
  };

  # These patches come from Debian and fix CVE-2009-1759.
  patches = [
    (fetchpatch {
      sha256 = "1qkzzm8sfspbcs10azmmif4qcr7pr8r38dsa2py84lsjm1yi3kls";
      url = "https://sources.debian.org/data/main/c/ctorrent/1.3.4.dnh3.3.2-5/debian/patches/cve-security-fix.diff";
    })
    (fetchpatch {
      sha256 = "1m3zh96xwqjjzsbg62f7kx0miams58nys1f484qhdn870b5x9p06";
      url = "https://sources.debian.org/data/main/c/ctorrent/1.3.4.dnh3.3.2-5/debian/patches/FTBFS-fix.diff";
    })
  ];

  meta = {
    description = "BitTorrent client written in C++";

    longDescription = ''
      CTorrent, a BitTorrent client implemented in C++, with bugfixes and
      performance enhancements.
    '';

    homepage = "http://www.rahul.net/dholmes/ctorrent/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.devhell ];
    platforms = lib.platforms.unix;
    mainProgram = "ctorrent";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
