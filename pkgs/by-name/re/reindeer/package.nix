{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "reindeer";
  version = "2026.05.04.00";

  src = fetchFromGitHub {
    owner = "facebookincubator";
    repo = "reindeer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m27zMZbDv/2bXhb16rFxUUokEn0bxyrhpxlOSZvVcfk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-nJU9ClYxRkAfFkOq1V7k34pjdqJntDr3gJekUibq304=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generate Buck build rules from Rust Cargo dependencies";
    homepage = "https://github.com/facebookincubator/reindeer";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ amaanq ];
    mainProgram = "reindeer";
  };
})
