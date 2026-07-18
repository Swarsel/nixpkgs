{
  lib,
  bsdSetupHook,
  byacc,
  install,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  netbsdSetupHook,
  statHook,
  stdenvLibcMinimal,
  tsort,
}:

mkDerivation {
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    byacc
    install
    tsort
    lorder
    mandoc
    statHook
  ];

  # Hack around GCC's limits.h missing the include_next we want See
  # https://gcc.gnu.org/legacy-ml/gcc/2003-10/msg01278.html
  NIX_CFLAGS_COMPILE_BEFORE = "-isystem ${stdenvLibcMinimal.cc.libc.dev}/include";
  SHLIBINSTALLDIR = "$(out)/lib";

  extraPaths = [
    "common"
    "lib/libc"
    "sys"
  ];

  libcMinimal = true;
  path = "lib/libutil";
  meta.platforms = lib.platforms.netbsd;
}
