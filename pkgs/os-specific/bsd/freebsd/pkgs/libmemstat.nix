{
  csu,
  include,
  libcMinimal,
  libgcc,
  libkvm,
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
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  noLibc = true;
  path = "lib/libmemstat";
}
