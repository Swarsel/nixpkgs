{
  lib,
  fetchCrate,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sea-orm-cli";
  version = "1.1.19";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-dsise5MDhR4pcD3ZWDUzTG0Q4Fg/VdKw2Q59/g6BabA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-38KIJYwRvVmChGSJwaRRWbb/HPuuTp/qnvXpo3xjRpE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command line utility for SeaORM";
    homepage = "https://www.sea-ql.org/SeaORM";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [ traxys ];
    mainProgram = "sea-orm-cli";
  };
})
