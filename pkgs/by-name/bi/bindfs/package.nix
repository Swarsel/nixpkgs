{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  fuse3,
  macfuse-stubs,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bindfs";
  version = "1.18.1";

  src = fetchurl {
    url = "https://bindfs.org/downloads/bindfs-${finalAttrs.version}.tar.gz";
    hash = "sha256-KnBk2ZOl8lXFLXI4XvFONJwTG8RBlXZuIXNCjgbSef0=";
  };

  patches = [
    # This commit fixes macfuse support but breaks fuse support
    # The condition to include `uint32_t position` in bindfs_setxattr and bindfs_getxattr
    # is wrong, leading to -Wincompatible-function-pointer-types
    # https://github.com/mpartel/bindfs/issues/169
    (fetchpatch {
      hash = "sha256-dtjvSJTS81R+sksl7n1QiyssseMQXPlm+LJYZ8/CESQ=";
      revert = true;
      url = "https://github.com/mpartel/bindfs/commit/3293dc98e37eed0fb0cbfcbd40434d3c37c69480.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = if stdenv.hostPlatform.isDarwin then [ macfuse-stubs ] else [ fuse3 ];
  configureFlags = lib.optional stdenv.hostPlatform.isDarwin "--disable-macos-fs-link";

  postFixup = ''
    ln -s $out/bin/bindfs $out/bin/mount.fuse.bindfs
  '';

  meta = {
    description = "FUSE filesystem for mounting a directory to another location";
    homepage = "https://bindfs.org";
    changelog = "https://github.com/mpartel/bindfs/raw/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      lovesegfault
    ];

    platforms = lib.platforms.unix;
  };
})
