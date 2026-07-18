{
  lib,
  stdenv,
  curl,
  fetchCrate,
  nix-update-script,
  nodejs_latest,
  openssl,
  pkg-config,
  rustPlatform,
}:

{
  cargoDeps,
  src,
  version ? src.version,
}:

rustPlatform.buildRustPackage {
  inherit version src cargoDeps;
  pname = "wasm-bindgen-cli";
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  # tests require it to be ran in the wasm-bindgen monorepo
  doCheck = false;
  nativeCheckInputs = [ nodejs_latest ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Facilitating high-level interactions between wasm modules and JavaScript";
    homepage = "https://wasm-bindgen.github.io/wasm-bindgen/";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      rizary
      insipx
    ];

    mainProgram = "wasm-bindgen";
  };
}
