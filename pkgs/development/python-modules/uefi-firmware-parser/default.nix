{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "uefi-firmware-parser";
  version = "1.16";

  src = fetchFromGitHub {
    owner = "theopolis";
    repo = "uefi-firmware-parser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2vYTOC7cOiQXPMhYM+hqmFyCJeXCkx6RSxgaTIZqbds=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "uefi_firmware" ];
  pythonRemoveDeps = [ "future" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for parsing, extracting, and recreating UEFI firmware volumes";
    homepage = "https://github.com/theopolis/uefi-firmware-parser";
    changelog = "https://github.com/theopolis/uefi-firmware-parser/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.elliotberman ];
    platforms = lib.platforms.unix;
    mainProgram = "uefi-firmware-parser";
  };
})
