{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "precious";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "houseabsolute";
    repo = "precious";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3pZ1OA1VxM1aMP1kyMzN7vlqvEQmo6kw0JBusmt8vwE=";
  };

  cargoHash = "sha256-tOkd++KxroZyFMSf9abYKiz/OTlAEyB3Wn1BzQPrX2k=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "One code quality tool to rule them all";
    homepage = "https://github.com/houseabsolute/precious";
    changelog = "https://github.com/houseabsolute/precious/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [ abhisheksingh0x558 ];
    mainProgram = "precious";
  };
})
