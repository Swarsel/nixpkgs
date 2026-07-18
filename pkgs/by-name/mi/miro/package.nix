{
  lib,
  fetchFromGitHub,
  fontconfig,
  libcosmicAppHook,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "miro";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "vincent-uden";
    repo = "miro";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uHg2RUn0k8POlV5Hod5hwLDLgjAOG6JxWsmdI4Mvx50=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    libcosmicAppHook
    pkg-config
  ];

  buildInputs = [
    fontconfig
  ];

  cargoHash = "sha256-YoLRw/HVMEKIGmAqyffEyKJ9MTkAJhr2gWWW7TXZ4Io=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native PDF viewer (Wayland/X11) with configurable keybindings";
    homepage = "https://github.com/vincent-uden/miro";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "miro-pdf";
  };
})
