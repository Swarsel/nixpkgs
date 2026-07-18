{
  lib,
  stdenv,
  fetchurl,
  # pin Boost 1.86 due to use of boost/asio/io_service.hpp
  boost186,
  expat,
  fetchpatch,
  libidn,
  lua,
  miniupnpc,
  openssl,
  python312,
  scons,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swiften";
  version = "4.0.3";

  src = fetchurl {
    url = "https://swift.im/git/swift/snapshot/swift-${finalAttrs.version}.tar.bz2";
    hash = "sha256-aj+T6AevtR8birbsj+83nfzFC6cf72q+7nwSM0jaZrA=";
  };

  patches = [
    ./scons.patch
    ./build-fix.patch

    # Fix build with latest boost
    # https://swift.im/git/swift/commit/Swiften/Base/Platform.h?id=3666cbbe30e4d4e25401a5902ae359bc2c24248b
    (fetchpatch {
      name = "3666cbbe30e4d4e25401a5902ae359bc2c24248b.patch";
      sha256 = "Wh8Nnfm0/EppSJ7aH2vTNObHtodE5tM19kV1oDfm70w=";
      url = "https://swift.im/git/swift/patch/Swiften/Base/Platform.h?id=3666cbbe30e4d4e25401a5902ae359bc2c24248b";
    })

    ./gcc14-fix.patch
  ];

  postPatch = ''
    # Ensure bundled dependencies cannot be used.
    rm -rf 3rdParty

    find . \( \
      -name '*.py' -o -name SConscript -o -name SConstruct \
      \) -exec 2to3 -w {} +
  '';

  nativeBuildInputs = [
    python312 # 2to3
    scons
  ];

  buildInputs = [
    libidn
    lua
    miniupnpc
    expat
    zlib
  ];

  propagatedBuildInputs = [
    openssl
    boost186
  ];

  enableParallelBuilding = true;

  installFlags = [
    "SWIFTEN_INSTALLDIR=${placeholder "out"}"
  ];

  installTargets = "${placeholder "out"}";

  sconsFlags = [
    "openssl=${openssl.dev}"
    "boost_includedir=${lib.getDev boost186}/include"
    "boost_libdir=${boost186.out}/lib"
    "boost_bundled_enable=false"
    "max_jobs=1"
    "optimize=1"
    "debug=0"
    "swiften_dll=1"
  ];

  meta = {
    description = "XMPP library for C++, used by the Swift client";
    homepage = "http://swift.im/swiften.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.twey ];
    platforms = lib.platforms.linux;
    mainProgram = "swiften-config";
  };
})
