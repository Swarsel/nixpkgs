{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ttypr";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "tanciaku";
    repo = "ttypr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y6FXkNfd+4Nkus+Z6Ah2AJX9iWeXQnIDeKmuLFUZDdQ=";
  };

  cargoHash = "sha256-bmwvirAbjzD5NJDHJgbPhnNqTdfo8CWJ2JWgFEBz+2Y=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal typing practice";

    longDescription = ''
      ttypr is a simple, lightweight typing practice application that
      runs in your terminal, built with Rust and Ratatui.
    '';

    homepage = "https://github.com/hotellogical05/ttypr";
    changelog = "https://github.com/tanciaku/ttypr/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "ttypr";
  };
})
