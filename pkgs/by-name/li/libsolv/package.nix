{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  db,
  expat,
  fetchpatch,
  ninja,
  pkg-config,
  rpm,
  xz,
  zchunk,
  zlib,
  zstd,
  withConda ? true,
  withRpm ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsolv";
  version = "0.7.37";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "libsolv";
    rev = finalAttrs.version;
    hash = "sha256-hiumMnTJ3eP+acH2V0eNTM71Fw//IWQPechCA0+kH1s=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-ju3xn78UGMR5usq1e1ovFTWnKW1TPDA77sNGx8yc8Z8=";
      name = "CVE-2026-9149";
      url = "https://github.com/openSUSE/libsolv/commit/210386037c892a720972ad35a3d8f7073b4d763b.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    zlib
    xz
    bzip2
    zchunk
    zstd
    expat
    db
  ]
  ++ lib.optional withRpm rpm;

  cmakeFlags = [
    "-DENABLE_COMPLEX_DEPS=true"
    (lib.cmakeBool "ENABLE_CONDA" withConda)
    "-DENABLE_LZMA_COMPRESSION=true"
    "-DENABLE_BZIP2_COMPRESSION=true"
    "-DENABLE_ZSTD_COMPRESSION=true"
    "-DENABLE_ZCHUNK_COMPRESSION=true"
    "-DWITH_SYSTEM_ZCHUNK=true"
  ]
  ++ lib.optionals withRpm [
    "-DENABLE_COMPS=true"
    "-DENABLE_PUBKEY=true"
    "-DENABLE_RPMDB=true"
    "-DENABLE_RPMDB_BYRPMHEADER=true"
    "-DENABLE_RPMMD=true"
  ];

  meta = {
    description = "Free package dependency solver";
    homepage = "https://github.com/openSUSE/libsolv";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
