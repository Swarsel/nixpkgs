{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sledtool";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "vi";
    repo = "sledtool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8D1zrRecU3s4EWKRAnnQ8Ga/kvKR0TCG6agoBCw+bEI=";
  };

  cargoHash = "sha256-BrI4Xq3Kuj06aPKSXNhCKCWZurO1npIsbBil3MrbQfk=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool to work with Sled key-value databases";
    homepage = "https://github.com/vi/sledtool";
    changelog = "https://github.com/vi/sledtool/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cilki ];
    mainProgram = "sledtool";
  };
})
