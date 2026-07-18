{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lepton-jpeg-util";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "lepton_jpeg_rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G46++ZRHdfaSElt9LwI1keDXXE2/VKH2m9+EY+QNOK4=";
  };

  cargoHash = "sha256-jO+LHoZKn0RORKRw5GIwO8kBoQMjvBrofRYN33OHm/I=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildAndTestSubdir = "util";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Port of DropBox Lepton compression to Rust";
    homepage = "https://github.com/microsoft/lepton_jpeg_rust";
    changelog = "https://github.com/microsoft/lepton_jpeg_rust/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ skohtv ];
    mainProgram = "lepton_jpeg_util";
  };
})
