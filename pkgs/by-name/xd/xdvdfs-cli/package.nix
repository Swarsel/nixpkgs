{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xdvdfs-cli";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "antangelo";
    repo = "xdvdfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-58f9eznPKeUVnUvslcm0CQPC+1xU3Zto+R56IXPBKT4=";
  };

  cargoHash = "sha256-vNCqfXsPjb3mph28YuYKpWTs9VHbIcXs6GVn4XgQKtQ=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoBuildFlags = [
    "--package"
    "xdvdfs-cli"
  ];

  cargoTestFlags = [
    "--package"
    "xdvdfs-cli"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/xdvdfs";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Original Xbox DVD Filesystem library and management tool";
    homepage = "https://github.com/antangelo/xdvdfs";
    changelog = "https://github.com/antangelo/xdvdfs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "xdvdfs";
  };
})
