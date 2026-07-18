{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  fixDarwinDylibNames,
  libxcrypt,
  libxslt,
  pkg-config,
  python3,
  readline,
  wafHook,
}:

stdenv.mkDerivation rec {
  pname = "talloc";
  version = "2.4.4";

  src = fetchurl {
    url = "mirror://samba/talloc/talloc-${version}.tar.gz";
    sha256 = "sha256-VeR5lAGME3Q0hVROcgZ4D/uzyElecEqZY2UD5ud6v1k=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
    wafHook
    docbook-xsl-nons
    docbook_xml_dtd_42
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    python3
    readline
    libxslt
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

  # this must not be exported before the ConfigurePhase otherwise waf whines
  preBuild = lib.optionalString stdenv.hostPlatform.isMusl ''
    export NIX_CFLAGS_LINK="-no-pie -shared";
  '';

  postInstall = ''
    ${stdenv.cc.targetPrefix}ar q $out/lib/libtalloc.a bin/default/talloc.c.[0-9]*.o
  '';

  wafConfigureFlags = [
    "--enable-talloc-compat1"
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--cross-compile"
    "--cross-execute=${stdenv.hostPlatform.emulator buildPackages}"
  ];

  wafPath = "buildtools/bin/waf";

  meta = {
    description = "Hierarchical pool based memory allocator with destructors";
    homepage = "https://tdb.samba.org/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.all;
  };
}
