{
  lib,
  stdenv,
  autoreconfHook,
  mingw_w64_headers,
  windows,
  crt ? stdenv.hostPlatform.libc,
}:

stdenv.mkDerivation {
  inherit (mingw_w64_headers) version src meta;
  pname = "mingw-w64";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ mingw_w64_headers ];

  configureFlags = [
    (lib.enableFeature true "idl")
    (lib.enableFeature true "secure-api")
    (lib.withFeatureAs true "default-msvcrt" crt)

    # Including other architectures causes errors with invalid asm
    (lib.enableFeature stdenv.hostPlatform.isi686 "lib32")
    (lib.enableFeature stdenv.hostPlatform.isx86_64 "lib64")
    (lib.enableFeature stdenv.hostPlatform.isAarch64 "libarm64")
  ];

  enableParallelBuilding = true;

  hardeningDisable = [
    "stackprotector"
    "fortify"
  ];
}
