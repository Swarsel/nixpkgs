{
  lib,
  stdenv,
  fetchCrate,
  libiconv,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "doh-proxy-rust";
  version = "0.9.16";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-V/mWMKBsCStQovgvMtRP66+OsNF2TC0GarYY51C/Zik=";
    crateName = "doh-proxy";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-daXXjD789tJBph00FPlm2C5gW3jwcTTAZ5TVeDJz8lU=";
  passthru.tests = { inherit (nixosTests) doh-proxy-rust; };

  meta = {
    description = "Fast, mature, secure DoH server proxy written in Rust";
    homepage = "https://github.com/jedisct1/doh-server";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ stephank ];
    mainProgram = "doh-proxy";
  };
})
