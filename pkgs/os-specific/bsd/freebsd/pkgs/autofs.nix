{
  flex,
  mkDerivation,
}:
mkDerivation {
  outputs = [
    "out"
    "debug"
  ];

  extraNativeBuildInputs = [
    flex
  ];

  extraPaths = [
    "sys/fs/autofs"
  ];

  path = "usr.sbin/autofs";
}
