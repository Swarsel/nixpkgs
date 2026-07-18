{
  lib,
  csu,
  include,
  libcMinimal,
  libgcc,
  mkDerivation,
  withPwdMkdb ? null,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  # XXX mass rebuild moment
  postPatch =
    if withPwdMkdb == null then
      null
    else
      ''
        substituteInPlace lib/libutil/pw_util.c --replace-fail _PATH_PWD_MKDB '"${lib.getExe withPwdMkdb}"'
      '';

  buildInputs = [
    include
    libgcc
    libcMinimal
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  extraPaths = [
    "lib/libc/gen"
    "lib/libc/Versions.def"
  ];

  noLibc = true;
  path = "lib/libutil";
}
