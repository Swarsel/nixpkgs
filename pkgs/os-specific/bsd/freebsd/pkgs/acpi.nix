{
  byacc,
  flex,
  mkDerivation,
}:
mkDerivation {
  extraNativeBuildInputs = [
    flex
    byacc
  ];

  extraPaths = [ "sys/contrib/dev/acpica" ];
  path = "usr.sbin/acpi";
}
