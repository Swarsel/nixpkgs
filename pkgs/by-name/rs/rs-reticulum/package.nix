{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  dbus,
  nix-update-script,
  pkg-config,
  python3,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rs-reticulum";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "ratspeak";
    repo = "rsReticulum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MSvIgB/E1Ce8M8vOaXlHQGYnxFf0lT2hg8g0tx6QY/w=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    dbus
  ];

  cargoHash = "sha256-Kv3aVET69yI28muyaJop4YQEqOxNeyajK7j5J+jDhe0=";

  nativeCheckInputs = [
    python3
  ];

  checkFlags = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # Broken since 0.9.4
    "--skip=actor::tests::test_rate_tracking"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  versionCheckProgram = "${placeholder "out"}/bin/rnid-rs";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust implementation of the Reticulum networking stack";
    homepage = "https://github.com/ratspeak/rsReticulum";
    changelog = "https://github.com/ratspeak/rsReticulum/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
