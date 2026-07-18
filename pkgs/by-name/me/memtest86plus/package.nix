{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "memtest86+";
  version = "8.00";

  src = fetchFromGitHub {
    owner = "memtest86plus";
    repo = "memtest86plus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7oOe35TI+H8Nox2VJMrdoMGyTxzrJzebBH+DLanXtpo=";
  };

  preBuild = ''
    cd build/${if stdenv.hostPlatform.isi686 then "i586" else "x86_64"}
  '';

  installPhase = ''
    install -Dm0444 mt86plus $out/mt86plus.efi
  '';

  # Binaries are booted directly by BIOS/UEFI or bootloader
  # and should not be patched/stripped
  dontPatchELF = true;
  dontStrip = true;
  passthru.efi = "${finalAttrs.finalPackage}/mt86plus.efi";
  passthru.tests.systemd-boot-memtest = nixosTests.systemd-boot.memtest86;

  meta = {
    description = "Tool to detect memory errors";
    homepage = "https://www.memtest.org/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.LunNova ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
})
