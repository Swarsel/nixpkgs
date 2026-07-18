{ lib, mkDerivation }:

mkDerivation {
  # Without a prefix it will try to put object files in nonexistent directories
  preBuild = ''
    export MAKEOBJDIRPREFIX=$TMP/obj
  '';

  alwaysKeepStatic = true;

  extraPaths = [
    "cddl/compat/opensolaris/include"
    "sys/contrib/openzfs/include"
    "sys/contrib/openzfs/lib/libspl"
    "sys/contrib/openzfs/module/icp/include"
    "sys/modules/zfs/zfs_config.h"
  ];

  path = "cddl/lib/libspl";

  meta = {
    license = lib.licenses.cddl;
  };
}
