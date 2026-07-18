{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  rapidjson,
  rocksdb_8_3,
  zlib,
}:

let
  rocksdb = rocksdb_8_3;
  concurrentqueue = fetchFromGitHub {
    hash = "sha256-MkhlDme6ZwKPuRINhfpv7cxliI2GU3RmTfC6O0ke/IQ=";
    owner = "cameron314";
    repo = "concurrentqueue";
    tag = "v1.0.4";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sortmerna";
  version = "4.3.7";

  src = fetchFromGitHub {
    owner = "sortmerna";
    repo = "sortmerna";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oxwZBkeW3usEcJE1XLu1UigKsgOsljwGFTpb7U3845I=";
  };

  patches = [
    ./ssw-stdbool.patch
  ];

  postPatch = ''
    # Fix missing pthread dependency for the main binary.
    substituteInPlace src/sortmerna/CMakeLists.txt \
      --replace-fail "target_link_libraries(sortmerna" \
        "target_link_libraries(sortmerna Threads::Threads"

    # Fix gcc-13 build by adding missing <cstdint> includes:
    #   https://github.com/sortmerna/sortmerna/issues/412
    sed -e '1i #include <cstdint>' -i include/kseq_load.hpp
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    zlib
    rocksdb
    rapidjson
  ];

  cmakeFlags = [
    "-DPORTABLE=off"
    "-DRAPIDJSON_HOME=${rapidjson}"
    "-DROCKSDB_HOME=${rocksdb}"
    "-DCONCURRENTQUEUE_HOME=${concurrentqueue}"
    "-DROCKSDB_STATIC=off"
    "-DZLIB_STATIC=off"
  ];

  meta = {
    description = "Tools for filtering, mapping, and OTU-picking from shotgun genomics data";
    homepage = "https://bioinfo.lifl.fr/RNA/sortmerna/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ luispedro ];
    platforms = lib.platforms.x86_64;
    mainProgram = "sortmerna";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
