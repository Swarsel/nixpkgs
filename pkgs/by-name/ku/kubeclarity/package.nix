{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  lvm2,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "kubeclarity";
  version = "2.23.3";

  src = fetchFromGitHub {
    owner = "openclarity";
    repo = "kubeclarity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MC9GeJeVG7ROkpmOW2HD/fWMMnHo43q4Du9MzWTk2cg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    btrfs-progs
    lvm2
  ];

  vendorHash = "sha256-JY64fqzNBpo9Jwo8sWsWTVVAO5zzwxwXy0A2bgqJHuU=";
  env.CGO_ENABLED = "0";

  postInstall = ''
    mv $out/bin/cli $out/bin/kubeclarity
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/cli";

  meta = {
    description = "Kubernetes runtime scanner";

    longDescription = ''
      KubeClarity is a vulnerabilities scanning and CIS Docker benchmark tool that
      allows users to get an accurate and immediate risk assessment of their
      kubernetes clusters. Kubei scans all images that are being used in a
      Kubernetes cluster, including images of application pods and system pods.
    '';

    homepage = "https://github.com/openclarity/kubeclarity";
    changelog = "https://github.com/openclarity/kubeclarity/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "kubeclarity";
  };
})
