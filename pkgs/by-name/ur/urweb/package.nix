{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  file,
  gcc,
  icu,
  libmysqlclient,
  libpq,
  mlton,
  openssl,
  sqlite,
}:

stdenv.mkDerivation rec {
  pname = "urweb";
  version = "20200209";

  src = fetchurl {
    url = "https://github.com/urweb/urweb/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "0qh6wcxfk5kf735i5gqwnkdirnnmqhnnpkfz96gz144dgz2i0c5c";
  };

  patches = [
    (fetchpatch {
      sha256 = "TQFD9Y8OEOSFv6cqpHQ4WSNAPzl82MmVCAxLR4F4Uxc=";
      url = "https://github.com/urweb/urweb/commit/f7a38a95bee9d1aaf7ed83a651cfbce8da96ed44.patch";
    })
  ];

  buildInputs = [
    openssl
    mlton
    libmysqlclient
    libpq
    sqlite
    icu
  ];

  configureFlags = [ "--with-openssl=${openssl.dev}" ];

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=use-after-free"
  ];

  preConfigure = ''
    export MSHEADER="${libmysqlclient}/include/mysql/mysql.h";
    export SQHEADER="${sqlite.dev}/include/sqlite3.h";
    export ICU_INCLUDES="-I${icu.dev}/include";

    export CC="${gcc}/bin/gcc";
    export CCARGS="-I$out/include \
                   -L${lib.getLib openssl}/lib \
                   -L${libmysqlclient}/lib \
                   -L${libpq}/lib \
                   -L${sqlite.out}/lib";
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # unresolved reference when linking liburweb.1.dylib
    export LDFLAGS="-Wl,-undefined,dynamic_lookup";
  '';

  # Be sure to keep the statically linked libraries
  dontDisableStatic = true;

  prePatch = ''
    sed -e 's@/usr/bin/file@${file}/bin/file@g' -i configure
  '';

  meta = {
    description = "Advanced purely-functional web programming language";
    homepage = "http://www.impredicative.com/ur/";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.buggymcbugfix
      lib.maintainers.thoughtpolice
      lib.maintainers.sheganinans
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "urweb";
  };
}
