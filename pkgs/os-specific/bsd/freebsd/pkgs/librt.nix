{
  csu,
  include,
  libcMinimal,
  libgcc,
  libsys,
  libthr,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  buildInputs = [
    include
    libcMinimal
    libgcc
    libthr
    libsys
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "lib/libc/include" # private headers
    "lib/libc/Versions.def"
  ];

  noLibc = true;
  path = "lib/librt";
}
