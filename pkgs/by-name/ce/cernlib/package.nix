{
  lib,
  stdenv,
  fetchurl,
  cmake,
  freetype,
  gfortran,
  libnsl,
  libx11,
  libxaw,
  libxcrypt,
  libxft,
  libxt,
  motif,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "cernlib";
  version = "2025.09.18.4";

  src = fetchurl {
    hash = "sha256-zhLZlR0CUtPPYr+99JpFnJ1er+L7YcoRLi5hKLERqR4=";

    urls = [
      "https://ftp.riken.jp/cernlib/download/${year}_source/tar/cernlib-cernlib-${version}-free.tar.gz"
      "https://cernlib.web.cern.ch/download/${year}_source/tar/cernlib-cernlib-${version}-free.tar.gz"
    ];
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "find_program ( SED NAMES gsed" "find_program ( SED NAMES sed"

    # termio.h is not found. Use the POSIX header
    substituteInPlace packlib/cspack/tcpaw/tcpaw.c \
      --replace-fail "#include <termio.h>" "#include <termios.h>" \
      --replace-fail "struct termio" "struct termios"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    freetype
    gfortran
    openssl
    libx11
    libxaw
    libxft
    libxt
    libxcrypt
    motif
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libnsl;

  # gfortran warning's on iframework messes with CMake's check_fortran_compiler_flag
  # see also https://github.com/NixOS/nixpkgs/issues/27218
  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$(echo $NIX_CFLAGS_COMPILE | sed 's|-iframework [^ ]*||g')"
  '';

  setupHook = ./setup-hook.sh;
  year = lib.versions.major version;

  meta = {
    description = "Legacy collection of libraries and modules for data analysis in high energy physics";
    homepage = "http://cernlib.web.cern.ch";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ veprbl ];

    platforms = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
