{
  lib,
  fetchFromGitHub,
  libudev-zero,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rogcat";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "flxo";
    repo = "rogcat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nXKvepuiBDIGo8Gga5tbbT/mnC6z+HipV5XYtlrURRU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libudev-zero
  ];

  cargoHash = "sha256-cl09j96UfLvga4cJBSd1he9nfW3taQMY2e+UPltNQMI=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Adb logcat wrapper";
    homepage = "https://github.com/flxo/rogcat";
    changelog = "https://github.com/flxo/rogcat/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
    platforms = lib.platforms.linux;
    mainProgram = "rogcat";
  };
})
