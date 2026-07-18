{
  bintrans,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  postPatch = ''
    substituteInPlace usr.sbin/uathload/uathload.c --replace-fail _PATH_FIRMWARE '"${builtins.placeholder "out"}/share/firmware"'
  '';

  extraNativeBuildInputs = [
    bintrans
  ];

  extraPaths = [
    "sys/contrib/dev/uath"
  ];

  path = "usr.sbin/uathload";
}
