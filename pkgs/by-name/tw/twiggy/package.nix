{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "twiggy";
  version = "0.8.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-FguDuah3MlC0wgz8VnXV5xepIVhTwYmQzijgX0sbdNY=";
  };

  cargoHash = "sha256-FaoEqCdMb3h93zGvc+EZ8LfYgMPY3dT/fScpRgGVeAo=";

  meta = {
    description = "Code size profiler for Wasm";
    homepage = "https://rustwasm.github.io/twiggy/";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ lucperkins ];
    mainProgram = "twiggy";
  };
})
