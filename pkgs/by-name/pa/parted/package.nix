{
  lib,
  stdenv,
  fetchurl,
  check,
  dosfstools,
  e2fsprogs,
  gettext,
  libuuid,
  lvm2,
  perl,
  pkg-config,
  python3,
  readline,
  util-linux,
  enableStatic ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "parted";
  version = "3.7";

  src = fetchurl {
    url = "mirror://gnu/parted/parted-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-AI3ldWGk88JaBkjmbtEeezC+STiJtkM0ptcPLBlR73s=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "info"
  ];

  postPatch = ''
    patchShebangs tests
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libuuid
    readline
    gettext
    lvm2
  ];

  configureFlags = lib.optional enableStatic "--enable-static";
  doCheck = !stdenv.hostPlatform.isMusl; # translation test

  nativeCheckInputs = [
    check
    dosfstools
    e2fsprogs
    perl
    python3
    util-linux
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Create, destroy, resize, check, and copy partitions";

    longDescription = ''
      GNU Parted is an industrial-strength package for creating, destroying,
      resizing, checking and copying partitions, and the file systems on
      them.  This is useful for creating space for new operating systems,
      reorganising disk usage, copying data on hard disks and disk imaging.

      It contains a library, libparted, and a command-line frontend, parted,
      which also serves as a sample implementation and script backend.
    '';

    homepage = "https://www.gnu.org/software/parted/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      kybe236
    ];

    # GNU Parted requires libuuid, which is part of util-linux-ng.
    platforms = lib.platforms.linux;
  };
})
