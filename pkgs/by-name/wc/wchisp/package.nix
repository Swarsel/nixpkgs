{
  lib,
  stdenv,
  fetchCrate,
  libusb1,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wchisp";
  version = "0.3.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-6WNXsRvbldEjAykMn1DCiuKctBrsTHGv1fJuRXBblu0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libusb1
  ];

  cargoHash = "sha256-VC8wiMdg7BnE92m57pKSrtv7vmbRNwV1yyy3f+1e+cY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command-line implementation of WCHISPTool, for flashing ch32 MCUs";
    homepage = "https://ch32-rs.github.io/wchisp/";
    changelog = "https://github.com/ch32-rs/wchisp/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = with lib.platforms; linux ++ darwin ++ windows;
    mainProgram = "wchisp";
    broken = !stdenv.hostPlatform.isLinux;
  };
})
