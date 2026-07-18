{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "resetti";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "tesselslate";
    repo = "resetti";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H4LkXTjXCuOUB9x24lEc4ofCKkAn1Eac2zMPIAgxkSE=";
  };

  vendorHash = "sha256-lhcCN5r1TSB95Y0pEoKAvftR0DMxtII3g+YOKT8I1qk=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  ldflags = [ "-s" ];
  preVersionCheck = "XDG_DATA_HOME=/tmp";
  versionCheckKeepEnvironment = [ "XDG_DATA_HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility macros for Minecraft speedrunning";
    homepage = "https://github.com/tesselslate/resetti";
    changelog = "https://github.com/tesselslate/resetti/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jess ];
    platforms = lib.platforms.linux;
    mainProgram = "resetti";
  };
})
