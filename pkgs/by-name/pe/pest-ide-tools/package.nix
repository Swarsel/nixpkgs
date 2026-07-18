{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pest-ide-tools";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "pest-parser";
    repo = "pest-ide-tools";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-12/FndzUbUlgcYcwMT1OfamSKgy2q+CvtGyx5YY4IFQ=";
  };

  cargoHash = "sha256-wLdVIAwrnAk8IRp4RhO3XgfYtNw2S07uAHB1mokZ2lk=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "IDE support for Pest, via the LSP";
    homepage = "https://pest.rs";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ nickhu ];
    mainProgram = "pest-language-server";
  };
})
