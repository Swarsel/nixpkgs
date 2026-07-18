{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tzf-rs";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "ringsaturn";
    repo = "tzf-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pdh301znFcqsrXyo75W8NcIFKJnWowjoJIV9WpdeWVU=";
  };

  cargoHash = "sha256-8Ma5WhUKJCFE3X26/dl2B1QeMtwjGY2Ux1DmRge5v2M=";
  __structuredAttrs = true;

  buildFeatures = [
    # no method named `to_geojson` found for struct `DefaultFinder` in the current scope
    "export-geojson"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast timezone finder for Rust";
    homepage = "https://github.com/ringsaturn/tzf-rs";
    changelog = "https://github.com/ringsaturn/tzf-rs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
    platforms = lib.platforms.unix;
    mainProgram = "tzf";
  };
})
