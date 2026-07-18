{
  lib,
  stdenv,
  compatIfNeeded,
  compatIsNeeded,
  libmd,
  libnetbsd,
  mkDerivation,
}:

let
  libmd' = libmd.override {
    bootstrapInstallation = true;
  };

in
mkDerivation {
  postPatch = ''
    ln -s $BSDSRCDIR/contrib/mknod/*.c $BSDSRCDIR/contrib/mknod/*.h $BSDSRCDIR/contrib/mtree
  '';

  buildInputs =
    compatIfNeeded
    ++ lib.optionals (!stdenv.hostPlatform.isFreeBSD) [
      libmd'
    ]
    ++ [
      libnetbsd
    ];

  preBuild = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS ${
      toString (
        [
          "-lmd"
          "-lnetbsd"
        ]
        ++ lib.optional compatIsNeeded "-legacy"
        ++ lib.optional stdenv.hostPlatform.isFreeBSD "-lutil"
      )
    }"
  '';

  extraPaths = [ "contrib/mknod" ];
  path = "contrib/mtree";
}
