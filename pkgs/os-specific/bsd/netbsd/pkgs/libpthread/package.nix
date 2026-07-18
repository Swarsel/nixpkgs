{
  lib,
  libcMinimal,
  librt,
  mkDerivation,
  stdenvLibcMinimal,
}:

mkDerivation {
  outputs = [
    "out"
    "dev"
    "man"
  ];

  # Hack around GCC's limits.h missing the include_next we want See
  # https://gcc.gnu.org/legacy-ml/gcc/2003-10/msg01278.html
  NIX_CFLAGS_COMPILE_BEFORE = "-isystem ${stdenvLibcMinimal.cc.libc.dev}/include";
  SHLIBINSTALLDIR = "$(out)/lib";

  extraPaths = [
    "common"
    libcMinimal.path
    librt.path
    "sys"
  ];

  libcMinimal = true;
  path = "lib/libpthread";
  meta.platforms = lib.platforms.netbsd;
}
