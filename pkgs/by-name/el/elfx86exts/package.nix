{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elfx86exts";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "pkgw";
    repo = "elfx86exts";
    tag = "elfx86exts@${finalAttrs.version}";
    hash = "sha256-lqaOnZxuiip1HPDpQraXlpUBYeJuBCRTaNARZVEV5UY=";
  };

  cargoHash = "sha256-7FVcLvbZQK5M90ofoBpK2V/1+vWlBI/Z2x3ydbCwVbM=";

  meta = {
    description = "Decode x86 binaries and print out which instruction set extensions they use";

    longDescription = ''
      Disassemble a binary containing x86 instructions and print out which extensions it uses.
      Despite the utterly misleading name, this tool supports ELF and MachO binaries, and
      perhaps PE-format ones as well. (It used to be more limited.)
    '';

    homepage = "https://github.com/pkgw/elfx86exts";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ rmcgibbo ];
    mainProgram = "elfx86exts";
  };
})
