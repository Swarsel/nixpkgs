{
  lib,
  fetchFromGitHub,
  buildPackages,
  iucode-tool,
  libarchive,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "microcode-intel";
  version = "20260512";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "Intel-Linux-Processor-Microcode-Data-Files";
    tag = "microcode-${finalAttrs.version}";
    hash = "sha256-hJfuxnHxHAxoTFAdgzontCl2pl5ad222I8BGyHO+MxQ=";
  };

  nativeBuildInputs = [ libarchive ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out kernel/x86/microcode
    ${stdenvNoCC.hostPlatform.emulator buildPackages} ${lib.getExe iucode-tool} -w kernel/x86/microcode/GenuineIntel.bin intel-ucode/
    touch -d @$SOURCE_DATE_EPOCH kernel/x86/microcode/GenuineIntel.bin
    echo kernel/x86/microcode/GenuineIntel.bin | bsdtar --uid 0 --gid 0 -cnf - -T - | bsdtar --null -cf - --format=newc @- > $out/intel-ucode.img

    runHook postInstall
  '';

  meta = {
    description = "Microcode for Intel processors";
    homepage = "https://www.intel.com/";
    changelog = "https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.unfreeRedistributableFirmware;
    maintainers = with lib.maintainers; [ felixsinger ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
})
