{
  lib,
  stdenv,
  fetchurl,
  apr,
  aprutil,
  brotli,
  buildPackages,
  fetchpatch2,
  libiconv,
  libxcrypt,
  libxml2,
  lua5,
  lynx,
  nghttp2,
  nixosTests,
  openldap,
  openssl,
  pcre2,
  perl,
  pkgsCross,
  runCommand,
  which,
  zlib,
  brotliSupport ? true,
  http2Support ? true,
  ldapSupport ? true,
  libxml2Support ? true,
  luaSupport ? false,
  proxySupport ? true,
  sslSupport ? true,
}:

stdenv.mkDerivation rec {
  pname = "apache-httpd";
  version = "2.4.68";

  src = fetchurl {
    url = "mirror://apache/httpd/httpd-${version}.tar.bz2";
    hash = "sha256-aMdNTfOMJr7U372487rx61MvOHI1e+zBu6XRNva2PAY=";
  };

  # FIXME: -dev depends on -doc
  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  patches = [
    # Fix cross-compilation by using CC_FOR_BUILD for generator program
    # https://issues.apache.org/bugzilla/show_bug.cgi?id=51257#c6
    (fetchpatch2 {
      hash = "sha256-KGnAa6euOt6dkZQwURyVITcfqTkDkSR8zpE97DywUUw=";
      name = "apache-httpd-cross-compile.patch";
      url = "https://gitlab.com/buildroot.org/buildroot/-/raw/5dae8cddeecf16c791f3c138542ec51c4e627d75/package/apache/0001-cross-compile.patch";
    })
  ];

  postPatch = ''
    sed -i config.layout -e "s|installbuilddir:.*|installbuilddir: $dev/share/build|"
    sed -i configure -e 's|perlbin=.*|perlbin="/usr/bin/env perl"|'
    sed -i support/apachectl.in -e 's|@LYNX_PATH@|${lynx}/bin/lynx|'
  '';

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    perl
    libxcrypt
    zlib
  ]
  ++ lib.optional brotliSupport brotli
  ++ lib.optional sslSupport openssl
  ++ lib.optional ldapSupport openldap
  # there is no --with-ldap flag
  ++ lib.optional libxml2Support libxml2
  ++ lib.optional http2Support nghttp2
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  configureFlags = [
    "--with-apr=${apr.dev}"
    "--with-apr-util=${aprutil.dev}"
    "--with-z=${zlib.dev}"
    "--with-pcre=${pcre2.dev}/bin/pcre2-config"
    "--disable-maintainer-mode"
    "--disable-debugger-mode"
    "--enable-mods-shared=all"
    "--enable-mpms-shared=all"
    "--enable-cern-meta"
    "--enable-imagemap"
    "--enable-cgi"
    "--includedir=${placeholder "dev"}/include"
    (lib.enableFeature proxySupport "proxy")
    (lib.enableFeature sslSupport "ssl")
    (lib.withFeatureAs libxml2Support "libxml2" "${libxml2.dev}/include/libxml2")
    "--docdir=$(doc)/share/doc"

    (lib.enableFeature brotliSupport "brotli")
    (lib.withFeatureAs brotliSupport "brotli" brotli)

    (lib.enableFeature http2Support "http2")
    (lib.withFeature http2Support "nghttp2")

    (lib.enableFeature luaSupport "lua")
    (lib.withFeatureAs luaSupport "lua" lua5)
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    # skip bad config check when cross compiling
    # https://gitlab.com/buildroot.org/buildroot/-/blob/5dae8cddeecf16c791f3c138542ec51c4e627d75/package/apache/apache.mk#L23
    "ap_cv_void_ptr_lt_long=no"
  ];

  # Required for ‘pthread_cancel’.
  env = lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
    NIX_LDFLAGS = "-lgcc_s";
  };

  postInstall = ''
    mkdir -p $doc/share/doc/httpd
    mv $out/manual $doc/share/doc/httpd
    mkdir -p $dev/bin
    mv $out/bin/apxs $dev/bin/apxs
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  setOutputFlags = false; # it would move $out/modules, etc.

  stripDebugList = [
    "lib"
    "modules"
    "bin"
  ];

  passthru = {
    inherit
      apr
      aprutil
      sslSupport
      proxySupport
      ldapSupport
      luaSupport
      lua5
      ;

    tests = {
      acme-integration = nixosTests.acme.httpd;

      cross = runCommand "apacheHttpd-test-cross" { } ''
        ${pkgsCross.aarch64-multiplatform.apacheHttpd.dev}/bin/apxs -q -n INCLUDE | grep CC=aarch64-unknown-linux-gnu-gcc > $out
        head -n1 ${pkgsCross.aarch64-multiplatform.apacheHttpd}/bin/dbmmanage | grep '^#!${pkgsCross.aarch64-multiplatform.perl}/bin/perl$' >> $out
      '';

      php = nixosTests.php.httpd;
      proxy = nixosTests.proxy;
    };
  };

  meta = {
    description = "Apache HTTPD, the world's most popular web server";
    homepage = "https://httpd.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arcayr ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
