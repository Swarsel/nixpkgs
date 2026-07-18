{
  lib,
  stdenv,
  compatIfNeeded,
  csu,
  include,
  libcMinimal,
  libgcc,
  m4,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isFreeBSD [
      include
      libcMinimal
      libgcc
    ]
    ++ compatIfNeeded;

  preBuild = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraNativeBuildInputs = [
    m4
  ];

  extraPaths = [
    "lib/libc"
    "contrib/elftoolchain"
    "sys/sys"
  ];

  noLibc = stdenv.hostPlatform.isFreeBSD;
  path = "lib/libelf";
}
