{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "scraper";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "rust-scraper";
    repo = "scraper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6gCoF+Uafw0WISuksBh4kwF7TL6N73Y8CpkcKe8Nyqw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-Mse6pO9VXturMxMpPe3zaNTsvRpADdns1zu/pX4mfgE=";

  postInstall = ''
    installManPage scraper/scraper.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to query HTML files with CSS selectors";
    homepage = "https://github.com/rust-scraper/scraper";
    changelog = "https://github.com/rust-scraper/scraper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      kachick
    ];

    mainProgram = "scraper";
  };
})
