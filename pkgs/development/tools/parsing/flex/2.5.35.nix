{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bison,
  flex,
  help2man,
  m4,
  texinfo,
}:

stdenv.mkDerivation rec {
  pname = "flex";
  version = "2.5.35";

  src = fetchurl {
    url = "https://github.com/westes/flex/archive/flex-${
      lib.replaceStrings [ "." ] [ "-" ] version
    }.tar.gz";

    sha256 = "0wh06nix8bd4w1aq4k2fbbkdq5i30a9lxz3xczf3ff28yy0kfwzm";
  };

  postPatch = ''
    patchShebangs tests
  '';

  nativeBuildInputs = [
    flex
    bison
    texinfo
    help2man
    autoreconfHook
  ];

  propagatedBuildInputs = [ m4 ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_COMPILE = "-std=gnu17";
  };

  preConfigure = lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
    ac_cv_func_malloc_0_nonnull=yes
    ac_cv_func_realloc_0_nonnull=yes
  '';

  doCheck = false; # fails 2 out of 46 tests

  meta = {
    description = "Fast lexical analyser generator";
    homepage = "https://flex.sourceforge.net/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    mainProgram = "flex";
    branch = "2.5.35";
  };
}
