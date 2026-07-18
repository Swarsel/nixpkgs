{
  lib,
  stdenv,
  fetchurl,
  cmake,
  glib,
  libgsf,
  libiconvReal,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wv2";
  version = "0.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/wvware/wv2-${finalAttrs.version}.tar.bz2";
    sha256 = "1p1qxr8z5bsiq8pvlina3c8c1vjcb5d96bs3zz4jj3nb20wnsawz";
  };

  patches = [
    ./fix-include.patch
    ./fix-libtool-location.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libgsf
    glib
    libxml2
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconvReal;

  # Newer versions of clang default to C++17, which removes some deprecated APIs such as bind1st.
  # Setting the language version to C++14 makes them available again.
  cmakeFlags = lib.optionals stdenv.cc.isClang [ (lib.cmakeFeature "CMAKE_CXX_STANDARD" "14") ];
  env.NIX_CFLAGS_COMPILE = "-I${libxml2.dev}/include/libxml2";

  # Linking gobject explicitly fixes missing symbols (such as missing `_g_object_unref`) on Darwin.
  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export NIX_LDFLAGS+=" $(pkg-config gobject-2.0 --libs)"
  '';

  meta = {
    description = "Excellent MS Word filter lib, used in most Office suites";
    homepage = "https://wvware.sourceforge.net";
    license = lib.licenses.lgpl2;
    mainProgram = "wv2-config";
  };
})
