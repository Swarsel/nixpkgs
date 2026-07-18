{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo2junit";
  version = "0.1.13";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-R3a87nXCnGhdeyR7409hFR5Cj3TFUWqaLNOtlXPsvto=";
  };

  cargoHash = "sha256-FPCLy4mIuUeHMuYgYGTs/fn8tUf55LVWBwrrA5hiG2k=";

  cargoPatches = [
    ./0001-update-time-rs.patch
  ];

  meta = {
    description = "Converts cargo's json output (from stdin) to JUnit XML (to stdout)";
    homepage = "https://github.com/johnterickson/cargo2junit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alekseysidorov ];
    mainProgram = "cargo2junit";
  };
})
