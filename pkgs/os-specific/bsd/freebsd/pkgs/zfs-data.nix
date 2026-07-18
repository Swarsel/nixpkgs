{ lib, mkDerivation }:
mkDerivation {
  extraPaths = [ "sys/contrib/openzfs/cmd/zpool/compatibility.d" ];
  path = "cddl/share/zfs/compatibility.d";

  meta = {
    license = lib.licenses.cddl;
  };
}
