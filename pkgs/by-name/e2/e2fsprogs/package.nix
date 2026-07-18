{
  lib,
  stdenv,
  fetchurl,
  bash,
  bashNonInteractive,
  buildPackages,
  e2fsprogs,
  fuse3,
  gettext,
  libarchive,
  libuuid,
  pkg-config,
  runCommand,
  texinfo,
  shared ? !stdenv.hostPlatform.isStatic,
  withFuse ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation rec {
  pname = "e2fsprogs";
  version = "1.47.4";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/people/tytso/e2fsprogs/v${version}/e2fsprogs-${version}.tar.xz";
    hash = "sha256-/VvziMvb4Aaj07MY2YOylIOCRArMhah/Hn0QhlPo2ws=";
  };

  # fuse2fs adds 14mb of dependencies
  outputs = [
    "bin"
    "dev"
    "out"
    "man"
    "info"
    "scripts"
  ]
  ++ lib.optionals withFuse [ "fuse2fs" ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    texinfo
  ];

  buildInputs = [
    libuuid
    gettext
    libarchive
    bash
  ]
  ++ lib.optionals withFuse [ fuse3 ];

  configureFlags = [
    "--with-libarchive=direct"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # It seems that the e2fsprogs is one of the few packages that cannot be
    # build with shared and static libs.
    (if shared then "--enable-elf-shlibs" else "--disable-elf-shlibs")
    "--enable-symlink-install"
    "--enable-relative-symlinks"
    "--with-crond-dir=no"
    # fsck, libblkid, libuuid and uuidd are in util-linux-ng (the "libuuid" dependency)
    "--disable-fsck"
    "--disable-libblkid"
    "--disable-libuuid"
    "--disable-uuidd"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
    "--enable-libuuid"
    "--disable-e2initrd-helper"
  ];

  doCheck = true;
  nativeCheckInputs = [ buildPackages.perl ];

  postInstall = ''
    # avoid cycle between outputs
    if [ -f $out/lib/${pname}/e2scrub_all_cron ]; then
      mv $out/lib/${pname}/e2scrub_all_cron $bin/bin/
    fi

    moveToOutput bin/mk_cmds "$scripts"
    moveToOutput bin/compile_et "$scripts"
    moveToOutput sbin/e2scrub "$scripts"
    moveToOutput sbin/e2scrub_all "$scripts"
  ''
  + lib.optionalString withFuse ''
    mkdir -p $fuse2fs/bin
    mv $bin/bin/fuse2fs $fuse2fs/bin/fuse2fs
  '';

  __structuredAttrs = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  # non-glibc gettext has issues with this
  outputChecks = lib.optionalAttrs stdenv.hostPlatform.isGnu {
    bin.disallowedRequisites = [
      bash
      bashNonInteractive
    ];

    out.disallowedRequisites = [
      bash
      bashNonInteractive
    ];
  };

  passthru.tests = {
    simple-filesystem = runCommand "e2fsprogs-create-fs" { } ''
      mkdir -p $out
      truncate -s10M $out/disc
      ${e2fsprogs}/bin/mkfs.ext4 $out/disc | tee $out/success
      ${e2fsprogs}/bin/e2fsck -n $out/disc | tee $out/success
      [ -e $out/success ]
    '';
  };

  meta = {
    description = "Tools for creating and checking ext2/ext3/ext4 filesystems";
    homepage = "https://e2fsprogs.sourceforge.net/";
    changelog = "https://e2fsprogs.sourceforge.net/e2fsprogs-release.html#${version}";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus # lib/ext2fs, lib/e2p
      bsd3 # lib/uuid
      mit # lib/et, lib/ss
    ];

    maintainers = with lib.maintainers; [ usertam ];
    platforms = lib.platforms.unix;
  };
}
