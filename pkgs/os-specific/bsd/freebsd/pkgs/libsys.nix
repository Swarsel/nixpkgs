{
  csu,
  include,
  libcompiler_rt,
  mkDerivation,
}:

mkDerivation {
  pname = "libsys";

  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    include
    csu
    libcompiler_rt
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I. -B${csu}/lib"
  '';

  alwaysKeepStatic = true;

  extraPaths = [
    "sys/sys"
    "lib/libc/string"
    "lib/libc/include"
    "lib/libc/Versions.def"
    "lib/libcompat"
  ];

  noLibc = true;
  path = "lib/libsys";
}
