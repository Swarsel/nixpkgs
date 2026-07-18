{
  lib,
  stdenv,
  fetchCrate,
  libusb1,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wlink";
  version = "0.1.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-kxjUDh+A4X+jddgBfrJSaVRjxo805EvJHaASElv8yKc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libusb1
    udev
  ];

  cargoHash = "sha256-GKtoGmK2Y3qmwAhlSk42iqvPd2qFXhcu4GBDGnVBxVo=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "WCH-Link flash tool for WCH's RISC-V MCUs(CH32V, CH56X, CH57X, CH58X, CH59X, CH32L103, CH32X035, CH641, CH643)";
    homepage = "https://github.com/ch32-rs/wlink";
    changelog = "https://github.com/ch32-rs/wlink/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "wlink";
    broken = !stdenv.hostPlatform.isLinux;
  };
})
