{
  csu,
  include,
  libcMinimal,
  libelf,
  libgcc,
  libkvm,
  libutil,
  mkDerivation,
  extraSrc ? [ ],
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
    libkvm
    libutil
    libelf
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "lib/libc/Versions.def"
    "sys/contrib/openzfs"
    "sys/contrib/pcg-c"
    "sys/opencrypto"
    "sys/crypto"
    "sys/modules/zfs"
  ]
  ++ extraSrc;

  noLibc = true;
  path = "lib/libprocstat";
}
