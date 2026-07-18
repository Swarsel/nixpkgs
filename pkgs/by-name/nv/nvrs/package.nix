{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nvrs";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "koibtw";
    repo = "nvrs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6ATkebFYuOOvhzSO+gClPbtaz9/Zph4m8/cqkufRYFw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-h3egaj4RQImxIf0MB8ZM9V92Xlml5BK++s7RJQwAk+E=";
  buildFeatures = [ "cli" ];

  cargoBuildFlags = [
    "--bin"
    "nvrs"
  ];

  # Skip tests that rely on network access.
  # We're also not running cli tokio tests because they don't implement skipping functionality.
  cargoTestFlags = [
    "--lib"
    "--"
    "--skip=api::aur::request_test"
    "--skip=api::crates_io::request_test"
    "--skip=api::gitea::request_test"
    "--skip=api::github::request_test"
    "--skip=api::gitlab::request_test"
    "--skip=api::regex::request_test"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast new version checker for software releases";
    homepage = "https://nvrs.adamperkowski.dev";
    changelog = "https://github.com/koibtw/nvrs/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koi ];
    platforms = lib.platforms.linux;
    mainProgram = "nvrs";
  };
})
