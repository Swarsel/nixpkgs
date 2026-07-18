{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jen";
  version = "1.7.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-dRUIyy4aQRwofZ/zWOHThclfxxrpXGWHruqg2Pp2BtQ=";
  };

  cargoHash = "sha256-2c4XHA8fl2BA/Qtz+Hp29SjiWqPEJEj4WQiIFG/O4fE=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple CLI generation tool for creating large datasets";
    homepage = "https://github.com/whitfin/jen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "jen";
  };
})
