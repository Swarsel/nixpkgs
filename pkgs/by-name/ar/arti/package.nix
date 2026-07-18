{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arti";
  version = "2.5.0";

  src = fetchFromGitLab {
    owner = "core";
    repo = "arti";
    tag = "arti-v${finalAttrs.version}";
    hash = "sha256-jOCFXlBI2xAzgpb7Fa8ap53SpDF6kcRGYnBXcu3vpk4=";
    domain = "gitlab.torproject.org";
    group = "tpo";
  };

  # Working around a bug in cargo that appears with cargo-auditable, see
  # https://github.com/rust-secure-code/cargo-auditable/issues/124.
  postPatch = ''
    substituteInPlace crates/arti/Cargo.toml \
      --replace-fail '"tokio-util"' '"dep:tokio-util"'
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];
  buildInputs = [ sqlite ] ++ lib.optionals stdenv.hostPlatform.isLinux [ openssl ];
  cargoHash = "sha256-JK6ubp697jZ98ErNrZdFe0mXIez3lUZ5SmAHkyD97WQ=";
  # some of the CLI tests attempt to validate that the filesystem and runtime
  # environment are securely configured, which breaks inside the nix build
  # sandbox. this does NOT affect downstream users of Arti.
  env.ARTI_FS_DISABLE_PERMISSION_CHECKS = 1;

  checkFlags = [
    # problematic test that hangs the build
    "--skip=reload_cfg::test::watch_single_file"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "crates/arti";
  # `full` includes all stable and non-conflicting feature flags. the primary
  # downsides are increased binary size and memory usage for building, but
  # those are acceptable for nixpkgs
  buildFeatures = [ "full" ];

  # several tests under `full` require access to internal types, which are
  # currently marked as experimental for public usage.
  checkFeatures = [
    "full"
    "experimental-api"
  ];

  passthru = {
    tests = { inherit (nixosTests) tor; };
    updateScript = nix-update-script { extraArgs = [ "--version-regex=^arti-v(.*)$" ]; };
  };

  meta = {
    description = "Implementation of Tor in Rust";
    homepage = "https://arti.torproject.org/";
    changelog = "https://gitlab.torproject.org/tpo/core/arti/-/blob/arti-v${finalAttrs.version}/CHANGELOG.md";

    license =
      with lib.licenses;
      OR [
        asl20
        mit
      ];

    maintainers = with lib.maintainers; [
      rapiteanu
      whispersofthedawn
    ];

    mainProgram = "arti";
  };
})
