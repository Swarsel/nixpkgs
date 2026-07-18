{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kubeconform";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "yannh";
    repo = "kubeconform";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-FTUPARckpecz1V/Io4rY6SXhlih3VJr/rTGAiik4ALA=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "FAST Kubernetes manifests validator, with support for Custom Resources";
    homepage = "https://github.com/yannh/kubeconform/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.j4m3s ];
    mainProgram = "kubeconform";
  };
})
