{
  lib,
  fetchCrate,
  libusb1,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-hf2";
  version = "0.3.3";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-0o3j7YfgNNnfbrv9Gppo24DqYlDCxhtsJHIhAV214DU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
  cargoHash = "sha256-cRliZegzRKmoGIE96pyVuNySA2L6l+imcTHbZBXXiz4=";

  meta = {
    description = "Cargo Subcommand for Microsoft HID Flashing Library for UF2 Bootloaders";
    homepage = "https://lib.rs/crates/cargo-hf2";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ astrobeastie ];
    mainProgram = "cargo-hf2";
  };
})
