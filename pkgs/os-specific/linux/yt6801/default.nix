{
  lib,
  stdenv,
  fetchzip,
  kernel,
  kmod,
}:

let
  modDestDir = "$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/ethernet/motorcomm";

in
stdenv.mkDerivation (finalAttrs: {
  pname = "yt6801";
  version = "1.0.30-20250430";

  src =
    let
      version-split = lib.strings.splitString "-" finalAttrs.version;
      versionName = builtins.elemAt version-split 0;
      uploadDate = builtins.elemAt version-split 1;
    in
    fetchzip {
      url = "https://www.motor-comm.com/Public/Uploads/uploadfile/files/${uploadDate}/yt6801-linux-driver-${versionName}.zip";
      sha256 = "sha256-6HeU3bbTaKOCy3X+nMpC9/bBc+0c4Ip5TdG+LGUGTKk=";
      stripRoot = false;
    };

  patches =
    lib.optionals (lib.versionAtLeast kernel.version "6.15") [
      ./kernel_6.15_fix.patch
    ]
    ++ lib.optionals (lib.versionAtLeast kernel.version "6.16") [
      ./kernel_6_16_fix.patch
    ];

  postPatch = ''
    substituteInPlace src/Makefile \
      --replace-fail "sudo ls -l" "ls -l" \
      --replace-fail 'depmod $(shell uname -r)' "" \
      --replace-fail 'modprobe $(KFILE)' ""
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ kmod ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KSRC_BASE="
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KDST=kernel/drivers/net/ethernet/motorcomm"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "ko_dir=${modDestDir}"
    "ko_full=${modDestDir}/yt6801.ko.xz"
  ];

  meta = {
    description = "YT6801 Gigabit PCIe Ethernet controller chip";
    homepage = "https://www.motor-comm.com/product/ethernet-control-chip";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ indexyz ];
    platforms = lib.platforms.linux;
  };
})
