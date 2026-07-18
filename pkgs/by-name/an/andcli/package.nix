{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "andcli";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "tjblackheart";
    repo = "andcli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l+ZpAm+yHCKPalGib4OlIaGFsDHc3IFFlOvB1kXWZG0=";
  };

  vendorHash = "sha256-S2JRkVy1iLGBqoOWukTQm80fVJ2YMNHTLfUUA2530GE=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/tjblackheart/andcli/v2/internal/buildinfo.Commit=${finalAttrs.src.tag}"
    "-X github.com/tjblackheart/andcli/v2/internal/buildinfo.AppVersion=${finalAttrs.src.tag}"
  ];

  subPackages = [ "cmd/andcli" ];
  versionCheckKeepEnvironment = [ "HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "2FA TUI for your shell";
    homepage = "https://github.com/tjblackheart/andcli";
    changelog = "https://github.com/tjblackheart/andcli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Cameo007 ];
    mainProgram = "andcli";
  };
})
