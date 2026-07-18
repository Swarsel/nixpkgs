{
  csu,
  include,
  libcMinimal,
  libelf,
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
    libelf
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "sys" # wants sys/${arch}
  ];

  noLibc = true;
  path = "lib/libkvm";
}
