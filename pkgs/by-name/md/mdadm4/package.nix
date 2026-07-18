{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  fetchgit,
  gitUpdater,
  groff,
  nixosTests,
  system-sendmail,
  udev,
  udevCheckHook,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mdadm";
  version = "4.6";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git";
    tag = "mdadm-${finalAttrs.version}";
    hash = "sha256-jFsVPJC4lcShkSwQCGjVdVkvk4q4weM7i5DzrLgpuSM=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./fix-hardcoded-mapdir.patch
  ];

  postPatch = ''
    sed -e 's@/lib/udev@''${out}/lib/udev@' \
        -e 's@ -Werror @ @' \
        -e 's@/usr/sbin/sendmail@${system-sendmail}/bin/sendmail@' -i Makefile
    sed -i \
        -e 's@/usr/bin/basename@${coreutils}/bin/basename@g' \
        -e 's@BINDIR/blkid@${util-linux}/bin/blkid@g' \
        *.rules
  '';

  nativeBuildInputs = [
    groff
    udevCheckHook
  ];

  buildInputs = [ udev ];

  makeFlags = [
    "NIXOS=1"
    "INSTALL=install"
    "BINDIR=$(out)/sbin"
    "SYSTEMD_DIR=$(out)/lib/systemd/system"
    "MANDIR=$(man)/share/man"
    "RUN_DIR=/dev/.mdadm"
    "STRIP="
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  doInstallCheck = true;

  # This is to avoid self-references, which causes the initrd to explode
  # in size and in turn prevents mdraid systems from booting.
  postFixup = ''
    grep -r $out $out/bin && false || true
  '';

  enableParallelBuilding = true;
  installFlags = [ "install-systemd" ];

  passthru = {
    tests = {
      inherit (nixosTests) systemd-initrd-swraid;
      installer-swraid = nixosTests.installer.swraid;
    };

    updateScript = gitUpdater {
      rev-prefix = "mdadm-";
      url = "https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git";
    };
  };

  meta = {
    description = "Programs for managing RAID arrays under Linux";
    homepage = "https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git";
    changelog = "https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git/tree/CHANGELOG.md?h=${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "mdadm";
  };
})
