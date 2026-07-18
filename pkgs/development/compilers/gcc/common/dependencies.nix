{
  lib,
  stdenv,
  autoconf269,
  buildIsHost,
  buildPackages,
  cargo,
  gettext,
  gmp,
  gnused,
  hostIsTarget,
  is13,
  libmpc,
  mpfr,
  patchelf,
  targetPackages,
  texinfo,
  version,
  which,
  flex ? null,
  gnat-bootstrap ? null,
  isSnapshot ? false,
  isl ? null,
  langAda ? false,
  langGo ? false,
  langRust ? false,
  libucontext ? null,
  libxcrypt ? null,
  perl ? null,
  threadsCross ? null,
  withoutTargetLibc ? null,
  zlib ? null,
}:

let
  inherit (lib) optionals;
  inherit (stdenv) buildPlatform targetPlatform;
in

{
  nativeBuildInputs = [
    texinfo
    which
    autoconf269
  ]
  ++ optionals (!is13) [ gettext ]
  ++ optionals (perl != null) [ perl ]
  ++ optionals (with stdenv.targetPlatform; isVc4 || isRedox || isSnapshot && flex != null) [ flex ]
  ++ optionals langAda [ gnat-bootstrap ]
  ++ optionals langRust [ cargo ]
  # The builder relies on GNU sed (for instance, Darwin's `sed' fails with
  # "-i may not be used with stdin"), and `stdenvNative' doesn't provide it.
  ++ optionals buildPlatform.isDarwin [ gnused ];

  buildInputs = [
    gmp
    mpfr
    libmpc
    libxcrypt
  ]
  ++ [
    targetPackages.stdenv.cc.bintools # For linking code at run-time
  ]
  ++ optionals (isl != null) [ isl ]
  ++ optionals (zlib != null) [ zlib ]
  ++ optionals (langGo && stdenv.hostPlatform.isMusl) [ libucontext ];

  # same for all gcc's
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  # For building runtime libs
  # same for all gcc's
  depsBuildTarget =
    (
      if buildIsHost then
        [
          targetPackages.stdenv.cc.bintools # newly-built gcc will be used
        ]
      else
        assert hostIsTarget;
        [
          # build != host == target
          stdenv.cc
        ]
    )
    ++ optionals targetPlatform.isLinux [ patchelf ];

  depsTargetTarget = optionals (
    !withoutTargetLibc && threadsCross != { } && threadsCross.package != null
  ) [ threadsCross.package ];
}
