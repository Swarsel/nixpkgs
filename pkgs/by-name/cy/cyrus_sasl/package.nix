{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  buildPackages,
  db,
  fetchpatch,
  fixDarwinDylibNames,
  gettext,
  libkrb5,
  libmysqlclient,
  libxcrypt,
  nixosTests,
  openldap,
  openssl,
  pam,
  pruneLibtoolFiles,
  enableLdap ? false,
  enableMySQL ? false,
}:

stdenv.mkDerivation rec {
  pname = "cyrus-sasl";
  version = "2.1.28";

  src = fetchurl {
    sha256 = "sha256-fM/Gq9Ae1nwaCSSzU+Um8bdmsh9C1FYu5jWo6/xbs4w=";

    urls = [
      "https://github.com/cyrusimap/${pname}/releases/download/${pname}-${version}/${pname}-${version}.tar.gz"
      "http://www.cyrusimap.org/releases/${pname}-${version}.tar.gz"
      "http://www.cyrusimap.org/releases/old/${pname}-${version}.tar.gz"
    ];
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
    "devdoc"
  ];

  patches = [
    # Fix cross-compilation
    ./cyrus-sasl-ac-try-run-fix.patch
    # make compatible with openssl3. can probably be dropped with any release after 2.1.28
    (fetchpatch {
      hash = "sha256-pc0cZqj1QoxDqgd/j/5q3vWONEPrTm4Pr6MzHlfjRCc=";
      url = "https://github.com/cyrusimap/cyrus-sasl/compare/cb549ef71c5bb646fe583697ebdcaba93267a237...dfaa62392e7caecc6ecf0097b4d73738ec4fc0a8.patch";
    })
    # Fix build with gcc15
    (fetchpatch {
      hash = "sha256-AfSQXFtVh0IHG8Uw9nWMWlkQnyaX3ZMsdZLd7hTru7Q=";
      url = "https://src.fedoraproject.org/rpms/cyrus-sasl/raw/388b80c6a8f93667587b4ac2e7992d0aa1c431f9/f/cyrus-sasl-2.1.28-gcc15.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pruneLibtoolFiles
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    openssl
    db
    gettext
    libkrb5
    libxcrypt
  ]
  ++ lib.optional enableLdap openldap
  ++ lib.optional enableMySQL libmysqlclient
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform pam) pam;

  configureFlags = [
    "--with-openssl=${openssl.dev}"
    "--with-plugindir=${placeholder "out"}/lib/sasl2"
    "--with-saslauthd=/run/saslauthd"
    "--enable-login"
    "--enable-shared"
  ]
  ++ lib.optional stdenv.cc.isClang "CFLAGS=-std=gnu17"
  ++ lib.optional enableLdap "--with-ldap=${openldap.dev}"
  ++ lib.optionals enableMySQL [
    # https://github.com/cyrusimap/cyrus-sasl/blob/ac0c278817a082c625c496ec812318c019e0b96f/docsrc/sasl/installation.rst#build-configuration
    # https://gitlab.alpinelinux.org/alpine/aports/-/blob/fa9312c830bfabbf3280248682650245a5b37205/main/cyrus-sasl/APKBUILD#L82-86
    "--enable-sql"
    "--with-mysql=${libmysqlclient}"
    "--without-pgsql"
  ]
  ++ lib.optionals (stdenv.targetPlatform.useLLVM or false) [
    "--disable-sample"
    "CFLAGS=-DTIME_WITH_SYS_TIME"
  ];

  makeFlags = lib.optionals enableMySQL [ "CFLAGS=-I${libmysqlclient.dev}/include/mysql" ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  installFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "framedir=$(out)/Library/Frameworks/SASL2.framework"
  ];

  passthru.tests = {
    inherit (nixosTests) parsedmarc postfix;
  };

  meta = {
    description = "Library for adding authentication support to connection-based protocols";
    homepage = "https://www.cyrusimap.org/sasl";
    license = lib.licenses.bsdOriginal;
    platforms = lib.platforms.unix;
  };
}
