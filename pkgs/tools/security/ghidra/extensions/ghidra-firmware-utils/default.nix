{
  lib,
  fetchFromGitHub,
  buildGhidraExtension,
}:
buildGhidraExtension (finalAttrs: {
  pname = "ghidra-firmware-utils";
  version = "2026.01.14";

  src = fetchFromGitHub {
    owner = "al3xtjames";
    repo = "ghidra-firmware-utils";
    rev = finalAttrs.version;
    hash = "sha256-FEjcqsisMvmNCQikon/3EEkLEtgKmGRBl/WwZebP+/A=";
  };

  meta = {
    description = "Ghidra utilities for analyzing PC firmware";
    homepage = "https://github.com/al3xtjames/ghidra-firmware-utils";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ timschumi ];
    downloadPage = "https://github.com/al3xtjames/ghidra-firmware-utils/releases/tag/${finalAttrs.version}";
  };
})
