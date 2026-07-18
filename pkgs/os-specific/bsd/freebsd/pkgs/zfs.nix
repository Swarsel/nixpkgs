{
  lib,
  libgeom,
  libjail,
  libzfs,
  mkDerivation,
  openssl,
  zfs-data,
}:
mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  postPatch = ''
    sed -i 's|/usr/share/zfs|${zfs-data}/share/zfs|' $BSDSRCDIR/cddl/sbin/zpool/Makefile
  '';

  buildInputs = [
    libgeom
    libjail
    libzfs
    openssl
  ];

  # I lied, this is both zpool and zfs
  preBuild = ''
    make -C $BSDSRCDIR/cddl/sbin/zpool $makeFlags
    make -C $BSDSRCDIR/cddl/sbin/zpool $makeFlags install
  '';

  extraPaths = [
    "cddl/compat/opensolaris"
    "cddl/sbin/zpool"
    "sys/contrib/openzfs"
    "sys/modules/zfs"
  ];

  path = "cddl/sbin/zfs";

  meta = {
    license = with lib.licenses; [
      cddl
      bsd2
    ];

    platforms = lib.platforms.freebsd;
  };
}
