{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "swaytreesave";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "fabienjuif";
    repo = "swaytreesave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CEhtO7gjuuQ58kWsQKJTDqSqqw2lF7EUsO/i8d0NIiU=";
  };

  cargoHash = "sha256-gbcVgdGvKxQioL6aQcMoajsJo2rTPDNqEhsywFPCQ0s=";
  __structuredAttrs = true;

  meta = {
    description = "CLI to save and load your compositors tree/layout";
    homepage = "https://github.com/fabienjuif/swaytreesave";
    changelog = "https://github.com/fabienjuif/swaytreesave/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      uzlkav
    ];

    platforms = lib.platforms.linux;
    mainProgram = "swaytreesave";
  };
})
