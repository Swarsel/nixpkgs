{
  csu,
  include,
  libcMinimal,
  libgcc,
  libmd,
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
    libmd
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "sys/kern"
    "sys/crypto"
    "lib/libmd"
    "secure/lib/libcrypt"
  ];

  noLibc = true;
  path = "lib/libcrypt";
}
