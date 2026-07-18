{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsodium,
  lz4,
  nix-update-script,
  python3,
  snappy,
  swig,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wiredtiger";
  version = "11.3.1";

  src = fetchFromGitHub {
    owner = "wiredtiger";
    repo = "wiredtiger";
    tag = finalAttrs.version;
    hash = "sha256-K5cZZTvZaWR6gVXF+mHNh7nHxMqi9XaEpB2qsd/pay8=";
  };

  nativeBuildInputs = [
    cmake
    python3
    swig
  ];

  buildInputs = [
    libsodium
    lz4
    snappy
    zlib
    zstd
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_STRICT" false)
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-array-bounds";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High performance, scalable, NoSQL, extensible platform for data management";
    homepage = "https://source.wiredtiger.com";

    license = with lib.licenses; [
      gpl2Only
      gpl3Only
    ];

    platforms = lib.intersectLists lib.platforms.unix lib.platforms.x86_64;
    mainProgram = "wt";
  };
})
