{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "foodfetch";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "noahfraiture";
    repo = "foodfetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TUgj3zS18lCtkyxYrG4f156YqFSCGXzfbK6b+Owacto=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-ZPV6sDQHV+G0HxRAVlcilh4tCCQspTnxnH1aHxVP8tI=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Yet another fetch to quickly get recipes";
    homepage = "https://github.com/noahfraiture/foodfetch";
    changelog = "https://github.com/noahfraiture/foodfetch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ noahfraiture ];
    mainProgram = "foodfetch";
  };
})
