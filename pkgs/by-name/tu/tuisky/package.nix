{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuisky";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "sugyan";
    repo = "tuisky";
    tag = "v${finalAttrs.version}";
    hash = "sha256-isS3MDyQ3iv5fYAw/i9V905J+2QnMFx2bebA853fBd4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-coBP2uItI/PJv4Bt3ILDo4ruyqejGwWjaDw5DmxseXw=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "TUI client for bluesky";
    homepage = "https://github.com/sugyan/tuisky";
    changelog = "https://github.com/sugyan/tuisky/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "tuisky";
  };
})
