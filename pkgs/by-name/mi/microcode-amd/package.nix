{
  lib,
  stdenv,
  libarchive,
  linux-firmware,
}:

stdenv.mkDerivation {
  pname = "amd-ucode";
  version = linux-firmware.version;
  src = linux-firmware;
  nativeBuildInputs = [ libarchive ];

  buildPhase = ''
    mkdir -p kernel/x86/microcode
    find ${linux-firmware}/lib/firmware/amd-ucode -name \*.bin -print0 | sort -z |\
      xargs -0 -I{} sh -c 'cat {} >> kernel/x86/microcode/AuthenticAMD.bin'
  '';

  installPhase = ''
    mkdir -p $out
    touch -d @$SOURCE_DATE_EPOCH kernel/x86/microcode/AuthenticAMD.bin
    echo kernel/x86/microcode/AuthenticAMD.bin | bsdtar --uid 0 --gid 0 -cnf - -T - | bsdtar --null -cf - --format=newc @- > $out/amd-ucode.img
  '';

  sourceRoot = ".";

  meta = {
    description = "AMD Processor microcode patch";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = lib.licenses.unfreeRedistributableFirmware;

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
