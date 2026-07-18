{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "uniex";
  version = "0.1.31";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "uniex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OOu8AveAsxl9RBNmBxP5MxsQv7g6lUsneBIVdwybuSg=";
  };

  vendorHash = "sha256-UIzfdK573jKHCulmP/6YH9TeYd5xkopvwJzLa7QkOVg=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unifi controller device inventory exporter, analyses all device and stat records for complete records";
    homepage = "https://paepcke.de/uniex";
    changelog = "https://github.com/paepckehh/uniex/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "uniex";
  };
})
