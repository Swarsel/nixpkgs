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
  python3,
  readline,
  talloc,
  wafHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tevent";
  version = "0.17.1";

  src = fetchurl {
    url = "mirror://samba/tevent/tevent-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-G+LepzfN4l/gZiH4SUXmPrcSWeDEPp+PXaSC2rGnvpI=";
  };

  nativeBuildInputs = [
    pkg-config
    which
    python3
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    wafHook
  ];

  buildInputs = [
    python3
    cmocka
    readline # required to build python
    talloc
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

  wafConfigureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--cross-compile"
    "--cross-execute=${stdenv.hostPlatform.emulator buildPackages}"
  ];

  wafPath = "buildtools/bin/waf";

  meta = {
    description = "Event system based on the talloc memory management library";
    homepage = "https://tevent.samba.org/";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.all;
  };
})
