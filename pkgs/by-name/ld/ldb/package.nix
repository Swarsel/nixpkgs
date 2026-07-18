{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  cmocka,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  libxcrypt,
  libxslt,
  pkg-config,
  popt,
  python3,
  readline,
  talloc,
  tdb,
  testers,
  tevent,
  wafHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ldb";
  version = "2.9.2";

  src = fetchurl {
    url = "mirror://samba/ldb/ldb-${finalAttrs.version}.tar.gz";
    hash = "sha256-0VWIQALHnbscPYZC+LEBPy5SCzru/W6WQSrexbjWy8A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    python3
    wafHook
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    tdb
    tevent
  ];

  buildInputs = [
    python3
    readline # required to build python
    tdb
    talloc
    tevent
    popt
    cmocka
    libxcrypt
  ];

  env = {
    # python-config from build Python gives incorrect values when cross-compiling.
    # If python-config is not found, the build falls back to using the sysconfig
    # module, which works correctly in all cases.
    PYTHON_CONFIG = "/invalid";
  }
  //
    lib.optionalAttrs (stdenv.cc.bintools.isLLVM && lib.versionAtLeast stdenv.cc.bintools.version "17")
      {
        # https://reviews.llvm.org/D135402
        NIX_LDFLAGS = "--undefined-version";
      };

  # otherwise the configure script fails with
  # PYTHONHASHSEED=1 missing! Don't use waf directly, use ./configure and make!
  preConfigure = ''
    export PKGCONFIG="$PKG_CONFIG"
    export PYTHONHASHSEED=1
  '';

  stripDebugList = [
    "bin"
    "lib"
    "modules"
  ];

  wafConfigureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
    "--without-ldb-lmdb"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--cross-compile"
    "--cross-execute=${stdenv.hostPlatform.emulator buildPackages}"
  ];

  wafPath = "buildtools/bin/waf";

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "LDAP-like embedded database";
    homepage = "https://ldb.samba.org/";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
    pkgConfigModules = [ "ldb" ];
  };
})
