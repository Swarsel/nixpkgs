{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "usbvfiod";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "cyberus-technology";
    repo = "usbvfiod";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gus0Bdsd0zUuhsAQ4I1Z/BphKOjAlmbpqND6W+6cNbg=";
  };

  cargoHash = "sha256-7RTaWi93WJV2HEVyljSzRVG+eCwo6+Ywq4Y+ng1UMww=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A tool for USB device pass-through using the vfio-user protocol.";
    homepage = "https://github.com/cyberus-technology/usbvfiod";
    changelog = "https://github.com/cyberus-technology/usbvfiod/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      lbeierlieb
      snu
    ];

    platforms = [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-linux"
    ];

    mainProgram = "usbvfiod";
  };
})
