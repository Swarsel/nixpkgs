{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wolfstoneextract";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "ECWolfEngine";
    repo = "WolfstoneExtract";
    tag = finalAttrs.version;
    hash = "sha256-yrYLP2ewOtiry+EgH1IEaxz2Q55mqQ6mRGSxzVUnJ8Q=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  versionCheckProgramArg = [ "--help" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility to extract Wolfstone data from Wolfenstein II";
    homepage = "https://github.com/ECWolfEngine/WolfstoneExtract";
    changelog = "https://github.com/ECWolfEngine/WolfstoneExtract/blob/${finalAttrs.src.rev}/changelog";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wolfstoneextract";
  };
})
