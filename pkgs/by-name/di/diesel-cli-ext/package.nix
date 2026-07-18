{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "diesel-cli-ext";
  version = "0.3.17";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-RkRnkr0xwe1ruQwGa1105CIgQl0cbRCvsJrCW/pWXDE=";
    pname = "diesel_cli_ext";
  };

  cargoHash = "sha256-l1nptYgDlMXmyhH3OC8D5ViuOG+ePSkxNOtcwuXBQIM=";

  meta = {
    description = "Provides different tools for projects using the diesel_cli";
    homepage = "https://crates.io/crates/diesel_cli_ext";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ siph ];
    mainProgram = "diesel_ext";
  };
})
