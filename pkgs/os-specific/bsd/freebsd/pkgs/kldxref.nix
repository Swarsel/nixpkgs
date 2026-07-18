{
  lib,
  stdenv,
  compatIfNeeded,
  elfcopy,
  libelf,
  mkDerivation,
}:
mkDerivation {
  # We symlink in our modules, make it follow symlinks
  postPatch = ''
    sed -i 's/FTS_PHYSICAL/FTS_LOGICAL/' $BSDSRCDIR/usr.sbin/kldxref/kldxref.c
  '';

  buildInputs = lib.optionals (!stdenv.hostPlatform.isFreeBSD) [ libelf ] ++ compatIfNeeded;

  preBuild = ''
    make -C $BSDSRCDIR/lib/libkldelf $makeFlags
  '';

  extraNativeBuildInputs = [
    elfcopy
  ];

  extraPaths = [
    "lib/libkldelf"
  ];

  path = "usr.sbin/kldxref";
}
