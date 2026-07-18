{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-whatfeatures";
  version = "0.9.13";

  src = fetchFromGitHub {
    owner = "museun";
    repo = "cargo-whatfeatures";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-YJ08oBTn9OwovnTOuuc1OuVsQp+/TPO3vcY4ybJ26Ms=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-p95aYXsZM9xwP/OHEFwq4vRiXoO1n1M0X3TNbleH+Zw=";

  meta = {
    description = "Simple cargo plugin to get a list of features for a specific crate";
    homepage = "https://github.com/museun/cargo-whatfeatures";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      ivan-babrou
      matthiasbeyer
    ];

    mainProgram = "cargo-whatfeatures";
  };
})
