{
  lib,
  stdenv,
  boost,
  brotli,
  libarchive,
  libblake3,
  libcpuid,
  libsodium,
  mkMesonLibrary,
  nlohmann_json,
  openssl,
  # Configuration Options
  version,
  zstd,
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-util";

  buildInputs = [
    brotli
  ]
  ++ lib.optional (lib.versionAtLeast version "2.27") libblake3
  ++ lib.optional (lib.versionAtLeast version "2.35pre") zstd
  ++ [
    libsodium
    openssl
  ]
  ++ lib.optional stdenv.hostPlatform.isx86_64 libcpuid;

  propagatedBuildInputs = [
    boost
    libarchive
    nlohmann_json
  ];

  mesonFlags = [
    (lib.mesonEnable "cpuid" stdenv.hostPlatform.isx86_64)
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
