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
    libelf
    libcMinimal
    libgcc
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "contrib/libexecinfo"
  ];

  noLibc = true;
  path = "lib/libexecinfo";
}
