{
  lib,
  fetchFromGitHub,
  libudev-zero,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "deepcool-digital-linux";
  version = "0.8.3-alpha";

  src = fetchFromGitHub {
    owner = "Nortank12";
    repo = "deepcool-digital-linux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Whmjd6NCOUkE7hM3FaN7grMwcC/suL7AJDVSgnZSKzM=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ libudev-zero ];
  cargoHash = "sha256-K1pEbUyENPUS4QK0lztWmw8ov1fGrx8KHdODmSByfek=";
  doInstallCheck = false; # FIXME: version cmd returns 0.8.3, set to true when we switch to a stable version
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux version for the DeepCool Digital Windows software";
    homepage = "https://github.com/Nortank12/deepcool-digital-linux";
    changelog = "https://github.com/Nortank12/deepcool-digital-linux/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ NotAShelf ];
    platforms = lib.platforms.linux;
    mainProgram = "deepcool-digital-linux";
  };
})
