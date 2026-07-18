{
  lib,
  libcMinimal,
  mkDerivation,
}:

mkDerivation {
  outputs = [
    "out"
    "dev"
  ];

  makeFlags = [ "LIBCSRCDIR=../libc" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  extraPaths = [
    "lib/libpthread"
    libcMinimal.path
    #"sys"
  ];

  libcMinimal = true;
  path = "lib/librthread";
  meta.platforms = lib.platforms.openbsd;
}
