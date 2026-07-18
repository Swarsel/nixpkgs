{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dtui";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "Troels51";
    repo = "dtui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bAg9FFoKXb6YClNQRhR7Z/MhnPkJ8r7/xM6SghaH2hU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  cargoHash = "sha256-qiFxN0bG3pUWOKKM0gHMmxjZZvqZXYYDeUuRI/V9YbM=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "dBus TUI for introspecting your current dbus session/system";
    homepage = "https://github.com/Troels51/dtui";
    changelog = "https://github.com/Troels51/dtui/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gaelj ];
    platforms = lib.platforms.unix;
    mainProgram = "dtui";
  };
})
