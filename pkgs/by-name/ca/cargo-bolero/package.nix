{
  lib,
  fetchCrate,
  libbfd,
  libopcodes,
  libunwind,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-bolero";
  version = "0.13.4";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-lfBpHaY2UCBMg45S4IW8fcpkGkKJoT4qqR2yq5KiXuE=";
  };

  buildInputs = [
    libbfd
    libopcodes
    libunwind
  ];

  cargoHash = "sha256-2URFqLg2aQF7MOpwG6fEPBXyBsLENWpdiXgxW/DJxQE=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fuzzing and property testing front-end framework for Rust";
    homepage = "https://github.com/camshaft/bolero";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ekleog ];
    mainProgram = "cargo-bolero";
  };
})
