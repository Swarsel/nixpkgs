{
  byacc,
  mkDerivation,
}:
mkDerivation {
  extraNativeBuildInputs = [
    byacc
  ];

  extraPaths = [
    "sys/net"
  ];

  path = "sbin/pfctl";
  meta.mainProgram = "pfctl";
}
