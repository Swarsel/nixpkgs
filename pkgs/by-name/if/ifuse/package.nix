{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fuse3,
  libimobiledevice,
  pkg-config,
  usbmuxd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ifuse";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "libimobiledevice";
    repo = "ifuse";
    tag = finalAttrs.version;
    hash = "sha256-STMELfxbWf2W6NKKqBxgbQLZpYXv9N0cDLgHho5PRYM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    fuse3
    usbmuxd
    libimobiledevice
  ];

  env = {
    VER = finalAttrs.version;
  };

  meta = {
    description = "Fuse filesystem implementation to access the contents of iOS devices";

    longDescription = ''
      Mount directories of an iOS device locally using fuse. By default the media
      directory is mounted, options allow to also mount the sandbox container of an
      app, an app's documents folder or even the root filesystem on jailbroken
      devices.
    '';

    homepage = "https://github.com/libimobiledevice/ifuse";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ifuse";
  };
})
