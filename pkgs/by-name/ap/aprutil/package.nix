{
  lib,
  stdenv,
  fetchurl,
  apr,
  autoreconfHook,
  cyrus_sasl,
  db,
  expat,
  fetchpatch,
  gnused,
  libiconv,
  libxcrypt,
  makeWrapper,
  openldap,
  openssl,
  bdbSupport ? true,
  ldapSupport ? !stdenv.hostPlatform.isCygwin,
  sslSupport ? true,
}:

assert sslSupport -> openssl != null;
assert bdbSupport -> db != null;
assert ldapSupport -> openldap != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "apr-util";
  version = "1.6.3";

  src = fetchurl {
    url = "mirror://apache/apr/apr-util-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-pBB243EHRjJsOUUEKZStmk/KwM4Cd92P6gdv7DyXcrU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./fix-libxcrypt-build.patch
    # Fix incorrect Berkeley DB detection with newer versions of clang due to implicit `int` on main errors.
    (fetchpatch {
      excludes = [ "CHANGES" ];
      hash = "sha256-/N6V5D1d9R6AVjHUwy3Ne839D3ZSsF3Hpn8W9sx1sXM=";
      url = "https://github.com/apache/apr-util/commit/2d838ff7319bd384a0b177f40ac19c4b6c81436d.patch?full_index=1";
    })
    # Fix error with missing function prototype
    (fetchpatch {
      hash = "sha256-fwKT7mGPHIgJ5uG/KAOOE/38FSNfow+GJgHCxcp9mgI=";
      url = "https://github.com/apache/apr-util/commit/e67caa006c75181b45b761cd50294cb3c8e18f1a.patch?full_index=1";
    })
  ]
  ++ lib.optional stdenv.hostPlatform.isFreeBSD ./include-static-dependencies.patch;

  nativeBuildInputs = [
    makeWrapper
    autoreconfHook
  ];

  propagatedBuildInputs = [
    apr
    expat
    libiconv
    libxcrypt
  ]
  ++ lib.optional sslSupport openssl
  ++ lib.optional bdbSupport db
  ++ lib.optional ldapSupport openldap
  ++ lib.optional stdenv.hostPlatform.isFreeBSD cyrus_sasl;

  configureFlags = [
    "--with-apr=${apr.dev}"
    "--with-expat=${expat.dev}"
  ]
  ++ lib.optional (!stdenv.hostPlatform.isCygwin) "--with-crypto"
  ++ lib.optional sslSupport "--with-openssl=${openssl.dev}"
  ++ lib.optional bdbSupport "--with-berkeley-db=${db.dev}"
  ++ lib.optional ldapSupport "--with-ldap=ldap"
  ++ lib.optionals stdenv.hostPlatform.isCygwin [
    "--without-pgsql"
    "--without-sqlite2"
    "--without-sqlite3"
    "--without-freetds"
    "--without-berkeley-db"
    "--without-crypto"
  ];

  env.NIX_CFLAGS_LINK = toString [ "-lcrypt" ];

  postConfigure = ''
    echo '#define APR_HAVE_CRYPT_H 1' >> confdefs.h
  ''
  +
    # For some reason, db version 6.9 is selected when cross-compiling.
    # It's unclear as to why, it requires someone with more autotools / configure knowledge to go deeper into that.
    # Always replacing the link flag with a generic link flag seems to help though, so let's do that for now.
    lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
      substituteInPlace Makefile \
        --replace "-ldb-6.9" "-ldb"
      substituteInPlace apu-1-config \
        --replace "-ldb-6.9" "-ldb"
    '';

  postInstall = ''
    for f in $out/lib/*.la $out/lib/apr-util-1/*.la $dev/bin/apu-1-config; do
      substituteInPlace $f \
        --replace "${expat.dev}/lib" "${expat.out}/lib" \
        --replace "${db.dev}/lib" "${db.out}/lib" \
        --replace "${openssl.dev}/lib" "${lib.getLib openssl}/lib"
    done

    # Give apr1 access to sed for runtime invocations.
    wrapProgram $dev/bin/apu-1-config --prefix PATH : "${gnused}/bin"
  '';

  enableParallelBuilding = true;
  outputBin = "dev";

  passthru = {
    inherit sslSupport bdbSupport ldapSupport;
  };

  meta = {
    description = "Companion library to APR, the Apache Portable Runtime";
    homepage = "https://apr.apache.org/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "apu-1-config";
  };
})
