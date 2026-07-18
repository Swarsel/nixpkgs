{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  buildPackages,
  bzip2,
  cyrus_sasl,
  file,
  libdbi,
  libmysqlclient,
  libuuid,
  libxml2,
  linux-pam,
  lua5_1,
  nixosTests,
  openldap,
  openssl,
  pcre2,
  perl,
  pkg-config,
  sqlite,
  which,
  zlib,
  enableDbi ? false,
  enableExtendedAttrs ? false,
  enableLdap ? false,
  enableMagnet ? false,
  enableMysql ? false,
  enablePam ? false,
  enableSasl ? false,
  enableWebDAV ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lighttpd";
  version = "1.4.85";

  src = fetchurl {
    url = "https://download.lighttpd.net/lighttpd/releases-${lib.versions.majorMinor finalAttrs.version}.x/lighttpd-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-GN5Rs5O6xKaCeHnhp/83fBaeQUuuks0kUJHYD8JgHRM=";
  };

  postPatch = ''
    patchShebangs tests
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    pcre2
    pcre2.dev
    libxml2
    zlib
    bzip2
    which
    file
    openssl
  ]
  ++ lib.optional enableDbi libdbi
  ++ lib.optional enableMagnet lua5_1
  ++ lib.optional enableMysql libmysqlclient
  ++ lib.optional enableLdap openldap
  ++ lib.optional enablePam linux-pam
  ++ lib.optional enableSasl cyrus_sasl
  ++ lib.optional enableWebDAV sqlite
  ++ lib.optional enableWebDAV libuuid;

  configureFlags = [
    "--with-openssl"
  ]
  ++ lib.optional enableDbi "--with-dbi"
  ++ lib.optional enableMagnet "--with-lua"
  ++ lib.optional enableMysql "--with-mysql"
  ++ lib.optional enableLdap "--with-ldap"
  ++ lib.optional enablePam "--with-pam"
  ++ lib.optional enableSasl "--with-sasl"
  ++ lib.optional enableWebDAV "--with-webdav-props"
  ++ lib.optional enableWebDAV "--with-webdav-locks"
  ++ lib.optional enableExtendedAttrs "--with-attr";

  preConfigure = ''
    export PATH=$PATH:${pcre2.dev}/bin
    sed -i "s:/usr/bin/file:${file}/bin/file:g" configure
  '';

  doCheck = true;
  nativeCheckInputs = [ perl ];

  postInstall = ''
    mkdir -p "$out/share/lighttpd/doc/config"
    cp -vr doc/config "$out/share/lighttpd/doc/"
    # Remove files that references needless store paths (dependency bloat)
    rm "$out/share/lighttpd/doc/config/Makefile"*
    rm "$out/share/lighttpd/doc/config/conf.d/Makefile"*
    rm "$out/share/lighttpd/doc/config/vhosts.d/Makefile"*
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  separateDebugInfo = true;

  passthru.tests = {
    inherit (nixosTests) lighttpd;
  };

  meta = {
    description = "Lightweight high-performance web server";
    homepage = "http://www.lighttpd.net/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      bjornfor
      brecht
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "lighttpd";
  };
})
