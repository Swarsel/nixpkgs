{
  mkDerivation,
}:
mkDerivation {
  patches = [ ./no-perms.patch ];
  path = "sbin/sysctl";
  meta.mainProgram = "sysctl";
}
