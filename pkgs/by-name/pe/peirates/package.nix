{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "peirates";
  version = "1.29a";

  src = fetchFromGitHub {
    owner = "inguardians";
    repo = "peirates";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VSb0l1yLFl5dZQn0Pb0HWLbeFiTUhZQBsJcjmrt4C7g=";
  };

  vendorHash = "sha256-QwESK8ZTlb0boI+PCvoXYbVG6a47Ws1k8nrc7yQWPtE=";

  preBuild = ''
    export GOFLAGS="$GOFLAGS -mod=mod"
  '';

  __structuredAttrs = true;
  ldflags = [ "-s" ];
  proxyVendor = true;

  meta = {
    description = "Kubernetes Penetration Testing tool";
    homepage = "https://github.com/inguardians/peirates";
    changelog = "https://github.com/inguardians/peirates/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "peirates";
  };
})
