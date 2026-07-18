{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "siomon";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "level1techs";
    repo = "siomon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XpVlfSIN7O0V2AeH8eeHg/jkLSCW+pWEHqo/xa7XWW0=";
  };

  cargoHash = "sha256-dUAuoIOW3pQKvb4LbJTss4RWLwHNrGefNzrV+eMjcO4=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hardware information and real-time sensor monitoring tool for Linux";
    homepage = "https://github.com/level1techs/siomon";
    changelog = "https://github.com/level1techs/siomon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sheevy ];
    platforms = lib.platforms.linux;
    mainProgram = "sio";
  };
})
