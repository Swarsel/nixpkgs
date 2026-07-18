{
  buildWasmBindgenCli,
  fetchCrate,
  rustPlatform,
}:

buildWasmBindgenCli rec {
  src = fetchCrate {
    hash = "sha256-1AN2E9t/lZhbXdVznhTcniy+7ZzlaEp/gwLEAucs6EA=";
    pname = "wasm-bindgen-cli";
    version = "0.2.99";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    inherit (src) pname version;
    hash = "sha256-HGcqXb2vt6nAvPXBZOJn7nogjIoAgXno2OJBE1trHpc=";
  };
}
