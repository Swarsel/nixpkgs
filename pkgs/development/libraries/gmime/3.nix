{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnupg,
  gobject-introspection,
  gpgme,
  libidn2,
  libunistring,
  pkg-config,
  vala,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "gmime";
  version = "3.2.15";

  src = fetchurl {
    # https://github.com/jstedfast/gmime/releases
    url = "https://github.com/jstedfast/gmime/releases/download/${version}/gmime-${version}.tar.xz";
    sha256 = "sha256-hM0qSBonlw7Dm1yV9y2wJnIpBKLM8/29V7KAzy0CtcQ=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace tests/testsuite.c \
      --replace /bin/rm rm
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # This specific test fails on darwin for some unknown reason
    substituteInPlace tests/test-filters.c \
      --replace-fail 'test_charset_conversion (datadir, "japanese", "utf-8", "iso-2022-jp");' ""
  '';

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    vala
  ];

  buildInputs = [
    zlib
    gpgme
    libidn2
    libunistring
    vala # for share/vala/Makefile.vapigen
  ];

  propagatedBuildInputs = [ glib ];

  configureFlags = [
    "--enable-introspection=yes"
    "--enable-vala=yes"
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [ "ac_cv_have_iconv_detect_h=yes" ];

  preConfigure = ''
    PKG_CONFIG_VAPIGEN_VAPIGEN="$(type -p vapigen)"
    export PKG_CONFIG_VAPIGEN_VAPIGEN
  ''
  + lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
    cp ${
      if stdenv.hostPlatform.isMusl then ./musl-iconv-detect.h else ./iconv-detect.h
    } ./iconv-detect.h
  '';

  doCheck = true;
  nativeCheckInputs = [ gnupg ];
  enableParallelBuilding = true;

  meta = {
    description = "C/C++ library for creating, editing and parsing MIME messages and structures";
    homepage = "https://github.com/jstedfast/gmime/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
