{
  lib,
  fetchzip,
  libx11,
  tcl,
  tcllib,
  tk,
  zlib,
}:

tcl.mkTclDerivation rec {
  pname = "tkimg";
  version = "2.1.1";

  src = fetchzip {
    url = "mirror://sourceforge/tkimg/tkimg/Img-${version}.tar.gz";
    hash = "sha256-TRtE2/BVrYgkdKtbF06UjLvokokgLGQ/EKDLxhz2Ckw=";
  };

  buildInputs = [
    libx11
    tcllib
    zlib
  ];

  configureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
    "--with-tkinclude=${tk.dev}/include"
  ];

  meta = {
    description = "Img package adds several image formats to Tcl/Tk";
    homepage = "https://sourceforge.net/projects/tkimg/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
  };
}
