{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gmp,
  libiconv,
  libidn2,
  libunistring,
  openssl,
  pkg-config,
  readline,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "lftp";
  version = "4.9.3";

  src = fetchurl {
    sha256 = "sha256-lucZnXk1vjPPaxFh6VWyqrQKt37N8qGc6k/BGT9Fftw=";

    urls = [
      "https://lftp.yar.ru/ftp/${pname}-${version}.tar.xz"
      "https://ftp.st.ryukoku.ac.jp/pub/network/ftp/lftp/${pname}-${version}.tar.xz"
    ];
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    readline
    zlib
    libidn2
    gmp
    libiconv
    libunistring
    gettext
  ];

  configureFlags = [
    "--with-openssl"
    "--with-readline=${readline.dev}"
    "--with-zlib=${zlib.dev}"
    "--without-expat"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Required to build with clang 16 or `configure` will fail to detect several standard functions.
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  enableParallelBuilding = true;
  hardeningDisable = lib.optional stdenv.hostPlatform.isDarwin "format";
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "File transfer program supporting a number of network protocols";
    homepage = "https://lftp.yar.ru/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
  };
}
