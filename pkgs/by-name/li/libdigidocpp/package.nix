{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libtool,
  libxml2,
  minizip,
  opensc,
  openssl,
  pcsclite,
  pkg-config,
  xmlsec,
  xxd,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdigidocpp";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "open-eid";
    repo = "libdigidocpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rf4ex9UT+Bspkf+WNNpYpdIt7y+QjAZ+eg786FZ0ZsA=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "bin"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    xxd
  ];

  buildInputs = [
    libxml2
    minizip
    pcsclite
    opensc
    openssl
    zlib
    xmlsec
  ];

  cmakeFlags = [
    (lib.cmakeFeature "PKCS11_MODULE" "${lib.getLib opensc}/lib/opensc-pkcs11.so")
  ];

  # This wants to link to ${CMAKE_DL_LIBS} (ltdl), and there doesn't seem to be
  # a way to tell CMake where this should be pulled from.
  # A cleaner fix would probably be to patch cmake to use
  # `-L${libtool.lib}/lib -ltdl` for `CMAKE_DL_LIBS`, but that's a world rebuild.
  env.NIX_LDFLAGS = "-L${libtool.lib}/lib";

  # Prevent cmake from creating a file that sets INTERFACE_INCLUDE_DIRECTORIES to the wrong location,
  # causing downstream build failures.
  postFixup = ''
    sed '/^  INTERFACE_INCLUDE_DIRECTORIES/s|"[^"]*/include"|"${placeholder "dev"}/include"|' \
      -i "$dev"/lib/cmake/libdigidocpp/libdigidocpp-config.cmake
  '';

  meta = {
    description = "Library for creating DigiDoc signature files";
    homepage = "https://www.id.ee/";
    license = lib.licenses.lgpl21Plus;

    maintainers = [
      lib.maintainers.flokli
    ];

    platforms = lib.platforms.linux;
    mainProgram = "digidoc-tool";
  };
})
