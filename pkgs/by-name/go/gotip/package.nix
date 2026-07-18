{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gotip";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "lusingander";
    repo = "gotip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CgTznW4SwKrJ4Q7dIo2ebn51G13nP36tv8n2G9T+MZ0=";
  };

  vendorHash = "sha256-Sj7JzyWviGxp10O1zGONN49TXtwquXYJ1KoijIVcyj0=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go test interactive picker";
    homepage = "https://github.com/lusingander/gotip";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "gotip";
  };
})
