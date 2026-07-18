{
  buildWasmBindgenCli,
  fetchCrate,
  rustPlatform,
}:

buildWasmBindgenCli rec {
  src = fetchCrate {
    hash = "sha256-Dkkx8Bhfk+y/jEz9Fzwytmv2N3Gj/7ST+5MlPRzzetU=";
    pname = "wasm-bindgen-cli";
    version = "0.2.120";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    inherit (src) pname version;
    hash = "sha256-5Zu/Sh9aBMxB+KGC1MHWJAQ8PuE40M6lsenkpFEwJ6A=";
  };
}
