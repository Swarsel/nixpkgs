{ mkDerivation, ... }:
mkDerivation {
  extraPaths = [ "lib/libc/gen" ];
  path = "usr.sbin/pwd_mkdb";
  meta.mainProgram = "pwd_mkdb";
}
