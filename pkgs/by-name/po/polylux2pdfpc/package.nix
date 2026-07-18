{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

let
  dirname = "pdfpc-extractor";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "polylux2pdfpc";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "polylux-typ";
    repo = "polylux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-41FgRejonvVTmE89WGm0Cqumm8lb6kkfxtkWV74UKJA=";
    sparseCheckout = [ dirname ];
  };

  cargoHash = "sha256-9nA18f+Dwps45M/OIY0jtx7QgyJDTVUsPndFdNBKHCQ=";
  sourceRoot = "${finalAttrs.src.name}/${dirname}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to make pdfpc interpret slides created by polylux correctly";
    homepage = "https://github.com/polylux-typ/polylux/tree/main/pdfpc-extractor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.diogotcorreia ];
    mainProgram = "polylux2pdfpc";
  };
})
