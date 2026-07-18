{
  csu,
  include,
  libcMinimal,
  libgcc,
  libsys,
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
    libsys
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "libexec/rtld-elf"
    "lib/libc/gen"
    "lib/libc/include"
    "lib/libc/Versions.def"
  ];

  noLibc = true;
  path = "lib/libdl";
}
