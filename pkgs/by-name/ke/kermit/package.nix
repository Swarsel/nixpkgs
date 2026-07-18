{
  lib,
  stdenv,
  fetchurl,
  libxcrypt,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "kermit";
  version = "9.0.302";

  src = fetchurl {
    url = "ftp://ftp.kermitproject.org/kermit/archives/cku302.tar.gz";
    sha256 = "0487mh6s99ijqf1pfmbm302pa5i4pzmm8s439hdl1ffs5g8jqpqd";
  };

  postPatch = ''
    sed -i -e 's@-I/usr/include/ncurses@@' \
      -e 's@/usr/local@'"$out"@ makefile
  '';

  buildInputs = [
    ncurses
    libxcrypt
  ];

  # Old K&R C sources fail under GCC 14+ default C standard (e.g. dosexp prototypes).
  env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-implicit-function-declaration -Wno-implicit-int";
  buildPhase = "make -f makefile linux KFLAGS='-D_IO_file_flags' LNKFLAGS='-lcrypt -lresolv'";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/man/man1
    make -f makefile install
  '';

  unpackPhase = ''
    mkdir -p src
    pushd src
    tar xvzf $src
  '';

  meta = {
    description = "Portable Scriptable Network and Serial Communication Software";
    homepage = "https://www.kermitproject.org/ck90.html";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = with lib.platforms; linux;
  };
}
