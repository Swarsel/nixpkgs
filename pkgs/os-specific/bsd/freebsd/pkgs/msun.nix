{
  lib,
  stdenv,
  csu,
  include,
  libcMinimal,
  libgcc,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    include
    libcMinimal
    libgcc
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "lib/libc" # wants arch headers
  ]
  ++ lib.optionals (stdenv.hostPlatform.isAarch32 || stdenv.hostPlatform.isAarch64) [
    "contrib/arm-optimized-routines"
  ];

  noLibc = true;
  path = "lib/msun";
}
