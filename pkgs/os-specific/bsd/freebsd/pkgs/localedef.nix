{
  lib,
  stdenv,
  bsdSetupHook,
  byacc,
  compat,
  freebsdSetupHook,
  install,
  makeMinimal,
  mkDerivation,
}:
mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    byacc
    freebsdSetupHook
    makeMinimal
    install
  ];

  buildInputs = [ ];

  preBuild = lib.optionalString (!stdenv.hostPlatform.isFreeBSD) ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${compat}/include -D__unused= -D__pure= -Wno-strict-aliasing"
    export NIX_LDFLAGS="$NIX_LDFLAGS -L${compat}/lib"
  '';

  MK_TESTS = "no";

  extraPaths = [
    "lib/libc/locale"
    "lib/libc/stdtime"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isFreeBSD) [ "." ];

  path = "usr.bin/localedef";
}
