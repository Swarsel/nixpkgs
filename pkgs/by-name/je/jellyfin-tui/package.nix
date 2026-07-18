{
  lib,
  stdenv,
  fetchFromGitHub,
  mpv,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jellyfin-tui";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "dhonus";
    repo = "jellyfin-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-su2zybyRc5Tyi7F+xX/YsWxqz8vLJdX3mAccqKqkRgo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    mpv
  ];

  cargoHash = "sha256-euTJMkTPAnPJCAGUWkmcME1w6nOBq0GSUTDFEhE5nIc=";

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 src/extra/jellyfin-tui.desktop $out/share/applications/jellyfin-tui.desktop
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  preInstallCheck = ''
    mkdir -p "$HOME/${
      if stdenv.buildPlatform.isDarwin then "Library/Application Support" else ".local/share"
    }"
  '';

  versionCheckKeepEnvironment = [ "HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Jellyfin music streaming client for the terminal";
    homepage = "https://github.com/dhonus/jellyfin-tui";
    changelog = "https://github.com/dhonus/jellyfin-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GKHWB ];
    mainProgram = "jellyfin-tui";
  };
})
