{
  csu,
  include,
  libcMinimal,
  libelf,
  libgcc,
  libkvm,
  libprocstat,
  libutil,
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
    libkvm
    libprocstat
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
  ];

  noLibc = true;
  path = "lib/libdevstat";
}
