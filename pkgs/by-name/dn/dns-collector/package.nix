{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "dns-collector";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "dmachard";
    repo = "dns-collector";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gm5PXEEgw98NnsfKN8JxhyTqEL9KSA6L2CgRTRJirdY=";
  };

  vendorHash = "sha256-pEex5xu3Cf6vqFp7YLwk+Ku+Yc0coOGLXP7/NUtDYbg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X=github.com/prometheus/common/version.BuildDate=1970-01-01T00:00:00Z"
    "-X=github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
    "-X=github.com/prometheus/common/version.Branch=master"
    "-X=github.com/prometheus/common/version.Revision=${finalAttrs.src.rev}"
    "-X=github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "-version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ingesting, pipelining, and enhancing your DNS logs with usage indicators, security analysis, and additional metadata";
    homepage = "https://github.com/dmachard/dns-collector";
    changelog = "https://github.com/dmachard/dns-collector/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "go-dnscollector";
  };
})
