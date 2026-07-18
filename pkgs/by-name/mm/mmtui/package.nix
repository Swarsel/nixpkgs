{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mmtui";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SL-RU";
    repo = "mmtui";
    tag = "mmt-v${finalAttrs.version}";
    hash = "sha256-ESnxy3TUWBb0akP471dK6wFQyJQSnjlIevA7ndLAjoE=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-Ck2mQ8PuA4apF6XKDtISmEtNFEHFRRlZwpYCDKCR/rc=";
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "mmt-v(.*)"
    ];
  };

  meta = {
    description = "TUI disk mount manager for TUI file managers";
    homepage = "https://github.com/SL-RU/mmtui";
    changelog = "https://github.com/SL-RU/mmtui/releases/tag/mmt-v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ grimmauld ];
    platforms = lib.platforms.linux;
    mainProgram = "mmtui";
  };
})
