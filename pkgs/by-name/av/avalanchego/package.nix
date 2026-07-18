{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "avalanchego";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "ava-labs";
    repo = "avalanchego";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SzWj4hzLTPHrPct8jejMIf5pB4DIOxe+PMpXDPKaDg8=";
  };

  vendorHash = "sha256-Ouj7amc/0VclcELz8LnR9x1U3+IQeq/veqPhXcr0M7k=";

  postInstall = ''
    mv $out/bin/{main,avalanchego}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ava-labs/avalanchego/version.GitCommit=${finalAttrs.version}"
  ];

  # https://github.com/golang/go/issues/57529
  proxyVendor = true;
  subPackages = [ "main" ];

  passthru.updateScript = nix-update-script {
    # Needed to avoid pre-releases
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "Go implementation of an Avalanche node";
    homepage = "https://github.com/ava-labs/avalanchego";
    changelog = "https://github.com/ava-labs/avalanchego/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      qjoly
    ];

    mainProgram = "avalanchego";
  };
})
