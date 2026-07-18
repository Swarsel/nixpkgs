{
  csu,
  include,
  mkDerivation,
  rpcgen,
}:

mkDerivation {
  buildInputs = [
    include
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${include}/include/rpcsvc"
  '';

  alwaysKeepStatic = true;

  extraNativeBuildInputs = [
    rpcgen
  ];

  extraPaths = [
    "sys/nlm"
    "include/rpcsvc"
  ];

  noLibc = true;
  path = "lib/librpcsvc";
}
