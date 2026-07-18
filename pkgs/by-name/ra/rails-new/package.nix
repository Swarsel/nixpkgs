{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rails-new";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "rails";
    repo = "rails-new";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7hEdLu9Koi2K2EFIl530yA+BGZmATFCcBMe3htYb0rs=";
  };

  cargoHash = "sha256-FrndtE9hjP1WswfOYJM4LW1UsE8S9QXthYO7P3nzs2I=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Generate new Rails applications without having to install Ruby";
    homepage = "https://github.com/rails/rails-new";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ coat ];
    mainProgram = "rails-new";
  };
})
