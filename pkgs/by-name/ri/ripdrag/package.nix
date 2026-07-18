{
  lib,
  fetchFromGitHub,
  gtk4,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ripdrag";
  version = "0.4.12";

  src = fetchFromGitHub {
    owner = "nik012003";
    repo = "ripdrag";
    tag = "v${finalAttrs.version}";
    hash = "sha256-syirR3t3AxThwIPMviGaSeXpDz2ApDGZOozPJ5bGEt4=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [ gtk4 ];
  cargoHash = "sha256-/OczChiDDK6Y2CxpjfgWkTwweKe4FVpOMlsB+qMp/r8=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Application that lets you drag and drop files from and to the terminal";
    homepage = "https://github.com/nik012003/ripdrag";
    changelog = "https://github.com/nik012003/ripdrag/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "ripdrag";
  };
})
