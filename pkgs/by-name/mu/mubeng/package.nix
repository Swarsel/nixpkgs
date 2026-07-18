{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "mubeng";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "mubeng";
    repo = "mubeng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zd9Cl4sFf1neDHgydxp24k84JKTAkkLB9DKRfTnKHgc=";
  };

  vendorHash = "sha256-1YO4NOxHHoSF9waI7x7yRvO4HOrs3qqaQxo3tiCp4t4=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/mubeng/mubeng/common.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Proxy checker and IP rotator";
    homepage = "https://github.com/mubeng/mubeng";
    changelog = "https://github.com/mubeng/mubeng/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "mubeng";
  };
})
