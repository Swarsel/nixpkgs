{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "parca-agent";
  version = "0.49.0";

  src = fetchFromGitHub {
    owner = "parca-dev";
    repo = "parca-agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IBDl2TKYFGBKb0IW8vRGdByFtjfrhBNdRcnVvDjcOjg=";
    fetchSubmodules = true;
  };

  buildInputs = [
    stdenv.cc.libc.static
  ];

  vendorHash = "sha256-vDjaA307C9azCKD0SRz06ZulMgHlULr6/x3yjPIefUo=";

  ldflags = [
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-extldflags=-static"
  ];

  proxyVendor = true;

  tags = [
    "osusergo"
    "netgo"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "eBPF based, always-on profiling agent";
    homepage = "https://github.com/parca-dev/parca-agent";
    changelog = "https://github.com/parca-dev/parca-agent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      brancz
      metalmatze
    ];

    platforms = lib.platforms.linux;
    mainProgram = "parca-agent";
  };
})
